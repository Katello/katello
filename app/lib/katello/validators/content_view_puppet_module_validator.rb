module Katello
  module Validators
    class ContentViewPuppetModuleValidator < ActiveModel::Validator
      def validate(record)
        if record.uuid.blank? && (record.name.blank? || record.author.blank?)
          record.errors[:base] << _("Invalid puppet module parameters specified. \
                                    Either 'uuid' or 'name' and 'author' must be specified.")
        elsif record.name && record.author &&
          !PuppetModule.exists?(name: record.name, author: record.author)
          record.errors[:base] << _("Puppet Module with name='%{name}' and author='%{author}' does\
                                    not exist") % { name: record.name, author: record.author }
        elsif record.uuid && !PuppetModule.exists?(uuid: record.uuid)
          record.errors[:base] << _("Puppet Module with uuid='%{uuid}' does not\
                                    exist") % { uuid: record.uuid }
        else
          puppet_modules = if record.uuid.blank?
                             PuppetModule.where(name: record.name, author: record.author)
                           else
                             PuppetModule.where(uuid: record.uuid)
                           end
          repositories = puppet_modules.flat_map(&:repositories)

          if repositories.present? && record.content_view.present? &&
              !repositories.map(&:organization).include?(record.content_view.organization)
            record.errors[:base] << _("Puppet Module does not belong to content view organization\
                                      '%{name}'" % { name: record.content_view.organization.name })
          end
        end
      end
    end
  end
end
