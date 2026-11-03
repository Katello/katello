module Katello
  class ContentViewEnvironmentActivationKey < Katello::Model
    belongs_to :content_view_environment, :class_name => "::Katello::ContentViewEnvironment", :inverse_of => :content_view_environment_activation_keys
    belongs_to :activation_key, :class_name => "::Katello::ActivationKey", :inverse_of => :content_view_environment_activation_keys

    default_scope { order(:priority => :asc) }

    validates :content_view_environment_id, presence: true,
              uniqueness: { scope: :activation_key_id, message: N_("has already been taken for this activation key") }
    validates :activation_key_id, presence: true, unless: :new_record?

    def self.reprioritize_for_activation_key(activation_key, new_cvenvs)
      cveaks_by_cvenv_id = activation_key.content_view_environment_activation_keys.load_target.index_by(&:content_view_environment_id)

      new_cvenvs.each_with_index do |cvenv, index|
        cveak = cveaks_by_cvenv_id[cvenv.id]
        next unless cveak

        cveak.persisted? ? cveak.update_column(:priority, index) : cveak.priority = index
      end
    end
  end
end
