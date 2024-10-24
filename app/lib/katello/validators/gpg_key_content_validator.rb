# encoding: utf-8

module Katello
  module Validators
    class GpgKeyContentValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        if value
          GpgKeyContentValidator.validate_line_length(record, attribute, value)
          gpg_key_line_array = value.split("\n")
          gpg_key_line_array.delete("")

          if gpg_key_line_array.first.match(/-{5}BEGIN PGP PUBLIC KEY BLOCK-{5}/) && gpg_key_line_array.last.match(/-{5}END PGP PUBLIC KEY BLOCK-{5}/)

            gpg_key_line_array.shift
            gpg_key_line_array.pop

            if gpg_key_line_array.empty?
              record.errors.add(attribute, _("must contain valid Public GPG Key"))
            else
              unless gpg_key_line_array.drop(1).join.match(/[a-zA-Z0-9+\/=]*/)
                record.errors.add(attribute, _("must contain valid Public GPG Key"))
              end
            end

          else
            record.errors.add(attribute, _("must contain valid Public GPG Key"))
          end

        else
          record.errors.add(attribute, _("must contain GPG Key"))
        end
      end

      def self.validate_line_length(record, attribute, value)
        value.each_line do |line|
          record.errors.add(attribute, _("must contain valid  Public GPG Key")) if line.length > ContentCredential::MAX_CONTENT_LINE_LENGTH
        end
      end
    end
  end
end
