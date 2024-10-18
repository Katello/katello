module Katello
  module Validators
    class GpgKeyContentTypeValidator < ActiveModel::Validator
      def validate(record)
        # need to verify, that gpg_key is of GpgKey.content type "gpg_key" and
        # ssl_ca_cert, ssl_client_cert, ssl_client_key of GpgKey.content type "cert"

        if !record.gpg_key.blank? && record.gpg_key.content_type != "gpg_key"
          record.errors.add(:gpg_key, _("Wrong content type submitted."))
        end

        if record.instance_of?(Katello::Product)
          [:ssl_ca_cert, :ssl_client_cert, :ssl_client_key].each do |cert|
            if !record.send(cert).blank? && record.send(cert).content_type != "cert"
              record.errors.add(cert, _("Wrong content type submitted."))
            end
          end
        end
      end
    end
  end
end
