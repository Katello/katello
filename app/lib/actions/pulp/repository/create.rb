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

module Actions
  module Pulp
    module Repository
      class Create < Pulp::Abstract

        include Helpers::Presenter

        input_format do
          param :content_type
          param :pulp_id
          param :name
          param :feed
          param :ssl_ca_cert
          param :ssl_client_cert
          param :ssl_client_key
          param :unprotected
          param :checksum_type
          param :path
          param :with_importer
        end

        def run
          output[:response] = pulp_extensions.repository.
              create_with_importer_and_distributors(input[:pulp_id],
                                                    importer,
                                                    distributors,
                                                    display_name: input[:name])
        end

        def importer
          importer = case input[:content_type]
                     when ::Katello::Repository::YUM_TYPE
                       Runcible::Models::YumImporter.new
                     when ::Katello::Repository::FILE_TYPE
                       Runcible::Models::IsoImporter.new
                     when ::Katello::Repository::PUPPET_TYPE
                       Runcible::Models::PuppetImporter.new
                     end

          if input[:with_importer]
            case input[:content_type]
            when ::Katello::Repository::YUM_TYPE,
                  ::Katello::Repository::FILE_TYPE
              importer.feed            = input[:feed]
              importer.ssl_ca_cert     = input[:ssl_ca_cert]
              importer.ssl_client_cert = input[:ssl_client_cert]
              importer.ssl_client_key  = input[:ssl_client_key]
            when ::Katello::Repository::PUPPET_TYPE
              importer.feed            = input[:feed]
            end
          end
          importer
        end

        def distributors
          case input[:content_type]
          when ::Katello::Repository::YUM_TYPE
            [yum_distributor, yum_clone_distributor, nodes_distributor]
          when ::Katello::Repository::FILE_TYPE
            [iso_distributor]
          when ::Katello::Repository::PUPPET_TYPE
            [puppet_install_distributor, nodes_distributor]
          else
            fail _("Unexpected repo type %s") % input[:content_type]
          end
        end

        def yum_distributor
            yum_dist_options = { protected: true,
                                 id: input[:pulp_id],
                                 auto_publish: true }
            yum_dist_options[:checksum_type] = input[:checksum_type] if input[:checksum_type]
            Runcible::Models::YumDistributor.new(input[:path],
                                                 input[:unprotected] || false,
                                                 true,
                                                 yum_dist_options)
        end

        def yum_clone_distributor
            Runcible::Models::YumCloneDistributor.new(id: "#{input[:pulp_id]}_clone",
                                                        destination_distributor_id: input[:pulp_id])

        end

        def nodes_distributor
          Runcible::Models::NodesHttpDistributor.new(:id => "#{input[:pulp_id]}_nodes", :auto_publish => true)
        end

        def iso_distributor
          Runcible::Models::IsoDistributor.new(true, true).tap do |dist|
            dist.auto_publish = true
          end
        end

        def puppet_install_distributor
          Runcible::Models::PuppetInstallDistributor.new(input[:path],
                                                         id: input[:pulp_id],
                                                         auto_publish: true)
        end
      end
    end
  end
end
