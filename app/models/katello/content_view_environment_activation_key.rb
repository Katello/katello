module Katello
  class ContentViewEnvironmentActivationKey < Katello::Model
    belongs_to :content_view_environment, :class_name => "::Katello::ContentViewEnvironment", :inverse_of => :content_view_environment_activation_keys
    belongs_to :activation_key, :class_name => "::Katello::ActivationKey", :inverse_of => :content_view_environment_activation_keys

    default_scope { order(:priority => :asc) }

    validates :content_view_environment_id, presence: true
    validates :activation_key_id, presence: true, unless: :new_record?

    def self.reprioritize_for_activation_key(activation_key, new_cves)
      new_order = new_cves.map do |cve|
        activation_key.content_view_environment_activation_keys.find_by(:content_view_environment_id => cve.id)
      end
      new_order.compact.each_with_index do |cveak, index|
        cveak.update_column(:priority, index)
      end
    end
  end
end
