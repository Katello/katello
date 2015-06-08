module Katello
  module Validators
    class ContentViewPuppetModuleValidator < ActiveModel::Validator
      def validate(record)
        if record.uuid.blank? && (record.name.blank? || record.author.blank?)
          invalid_parameters = _("Invalid puppet module parameters specified.  Either 'uuid' or 'name' and 'author' must be specified.")
          record.errors[:base] << invalid_parameters
          return
        end

        if record.name && record.author
          # validate that a puppet module exists with this name+author
          unless PuppetModule
                  .in_repositories(record.content_view.puppet_repos)
                  .where(:name => record.name, :author => record.author).present?

            invalid_parameters = _("Puppet Module with name='%{name}' and author='%{author}' does not exist") %
                { :name => record.name, :author => record.author }

            record.errors[:base] << invalid_parameters
          end
        end
      end
    end
  end
end
