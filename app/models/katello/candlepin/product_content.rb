#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Katello
  class Candlepin::ProductContent
    attr_accessor :content, :enabled

    def initialize(params = {}, product_id=nil)
      params = params.with_indifferent_access
      #controls whether repo is enabled in yum repo file on client
      #  unrelated to enable/disable from katello
      @enabled = params[:enabled]
      @content = ::Candlepin::Content.new(params[:content])
      @product_id = product_id
    end

    def create
      @content.create
    end

    def destroy
      @content.destroy
    end

    def product
      @product ||= Product.find(@product_id) if @product_id
      @product
    end

    def product=(prod)
      @product = prod
    end

    def repositories
      @repos ||= self.product.repos(self.product.organization.library, true).where(:content_id=>self.content.id)
      @repos
    end

    #Has the user enabled the 'repository set' for this product
    def katello_enabled?
      self.repositories.count > 0
    end

    def can_disable?
      #are all repos disabled?
      self.product.repos(self.product.organization.library, false).where(:content_id=>self.content.id).empty?
    end

    def disable
      raise _("One or more repositories are still enabled for this content set.") unless self.can_disable?
      repos = self.product.repos(self.product.organization.library, true).where(:content_id=>self.content.id)
      repos.each do |repo|
        repo.destroy
      end
      @repos = nil #reset repo cache
    end

    def refresh_repositories
      product = self.product

      cdn_var_substitutor = Resources::CDN::CdnResource.new(product.provider[:repository_url],
                                                       :ssl_client_cert => OpenSSL::X509::Certificate.new(product.certificate),
                                                       :ssl_client_key => OpenSSL::PKey::RSA.new(product.key),
                                                       :product        => product).substitutor(Rails.logger)

      content_url = self.content.contentUrl
      begin
        cdn_var_substitutor.precalculate([content_url])
      rescue Errors::SecurityViolation => e
        # in case we cannot access CDN server to obtain repository URLS we note down error
        self.repositories_cdn_import_failed!
        Rails.logger.error("\nproduct #{product.name} repositories import: " <<
                                     'SecurityViolation occurred when contacting CDN to fetch ' <<
                                     "listing files\n" + e.backtrace.join("\n"))
        # false would cancel orchestration and would lead to product save cancellation
        # but we want import process to succeed
        return true
      end

      ca = File.read(Resources::CDN::CdnResource.ca_file)

      cdn_var_substitutor.substitute_vars(self.content.contentUrl).each do |(substitutions, path)|
        feed_url = product.repo_url(path)
        arch = substitutions["basearch"] || "noarch"
        repo_name = [self.content.name, substitutions.sort_by {|k,_| k.to_s}.map(&:last)].flatten.compact.join(" ").gsub(/[^a-z0-9\-\._ ]/i,"")
        version = Resources::CDN::Utils.parse_version(substitutions["releasever"])

        begin
          existing_repos = Repository.where(product_id: product.id,
                                            environment_id: product.organization.library.id,
                                            pulp_id: product.repo_id(repo_name)
                                           )
          unless existing_repos.any?
            repo = Repository.create!(:environment => product.organization.library,
                                      :product => product,
                                      :pulp_id => product.repo_id(repo_name),
                                      :cp_label => self.content.label,
                                      :content_id=>self.content.id,
                                      :arch => arch,
                                      :major => version[:major],
                                      :minor => version[:minor],
                                      :relative_path => Glue::Pulp::Repos.repo_path_from_content_path(product.organization.library, path),
                                      :name => repo_name,
                                      :label => Util::Model::labelize(repo_name),
                                      :feed => feed_url,
                                      :feed_ca => ca,
                                      :feed_cert => self.product.certificate,
                                      :feed_key => self.product.key,
                                      :content_type => self.content.type,
                                      :preserve_metadata => true, #preserve repo metadata when importing from cp
                                      :enabled =>false,
                                      :unprotected => true,
                                      :content_view_version=>product.organization.library.default_content_view_version
                                     )
          end
          product.repositories_cdn_import_passed! unless product.cdn_import_success?
          @repos = nil #reset repo cache
        rescue RestClient::InternalServerError => e
          if e.message.include? "Architecture must be one of"
            Rails.logger.error("Pulp does not support arch '#{arch}'")
          else
            raise e
          end
        end
      end

    end


  end
end
