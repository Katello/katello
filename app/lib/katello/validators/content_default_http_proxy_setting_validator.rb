module Katello
  module Validators
    class ContentDefaultHttpProxySettingValidator < ActiveModel::Validator
      def validate(record)
        proxy = HttpProxy.where(name: record.value).first
        return if proxy || record.value.blank?

        record.errors.add(:base, _('There is no such HTTP proxy'))
      end
    end
  end
end
