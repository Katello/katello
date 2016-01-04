module Katello
  module Ext
    module LabelFromName
      def self.included(base)
        base.class_eval do
          before_validation :setup_label_from_name
          validate :label_not_changed, :on => :update
        end
      end

      def setup_label_from_name
        unless label.present?
          self.label = Util::Model.labelize(name)
          if self.class.where(:label => self.label).any?
            self.label = Util::Model.uuid
          end
        end
      end

      def label_not_changed
        if label_changed? && label_was.present?
          errors.add(:label, _("cannot be changed."))
        end
      end
    end
  end
end
