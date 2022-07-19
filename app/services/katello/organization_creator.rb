module Katello
  class OrganizationCreator
    DEFAULT_CONTENT_VIEW_NAME = 'Default Organization View'.freeze
    DEFAULT_CONTENT_VIEW_LABEL = 'Default_Organization_View'.freeze

    DEFAULT_LIFECYCLE_ENV_NAME = 'Library'.freeze
    DEFAULT_LIFECYCLE_ENV_LABEL = 'Library'.freeze

    attr_reader :library_view, :library_environment, :library_cvv, :content_view_environment, :anonymous_provider, :redhat_provider

    def self.seed_all_organizations!
      User.as_anonymous_admin do
        Organization.not_created_in_katello.each do |org|
          self.new(org).seed!
        end
      end
    end

    def self.create_all_organizations!
      Katello::Ping.ping!(services: [:candlepin])

      User.as_anonymous_admin do
        Organization.not_created_in_katello.each do |org|
          creator = self.new(org)
          creator.create!(raise_validation_errors: false)
        end
      end
    end

    def initialize(organization)
      @organization = organization
    end

    def seed!
      ActiveRecord::Base.transaction do
        @organization.setup_label_from_name

        # existing validation errors are not resolvable here, so don't validatate
        @organization.save(validate: false)

        create_library_environment
        create_library_view
        create_library_cvv
        create_content_view_environment
        create_anonymous_provider
        create_redhat_provider
        create_cdn_configuration
      end
    end

    def create!(raise_validation_errors: true)
      ActiveRecord::Base.transaction do
        seed!

        create_backend_objects!

        @organization.created_in_katello = true

        begin
          @organization.save!
        rescue => e
          raise e if raise_validation_errors
        end
      end
    end

    def create_backend_objects!
      Katello::Ping.ping!(services: [:candlepin])

      if needs_candlepin_organization?
        ::Katello::Resources::Candlepin::Owner.create(@organization.label, @organization.name)
      end

      ::Katello::ContentViewManager.create_candlepin_environment(
        content_view_environment: @content_view_environment
      )

      @organization.debug_cert # trigger creation
    end

    def needs_candlepin_organization?
      !@organization.candlepin_owner_exists?
    end

    private

    def create_content_view_environment
      @content_view_environment ||= ::Katello::ContentViewManager.add_version_to_environment(
        content_view_version: @library_cvv,
        environment: @library_environment
      )
    end

    def create_library_environment
      @library_environment = Katello::KTEnvironment.where(
        :name => DEFAULT_LIFECYCLE_ENV_NAME,
        :label => DEFAULT_LIFECYCLE_ENV_LABEL,
        :library => true,
        :organization => @organization
      ).first_or_create!
    end

    def create_library_view
      cv_wrong_label = Katello::ContentView.where(
        default: true,
        name: DEFAULT_CONTENT_VIEW_NAME,
        organization: @organization
      ).where.not(label: DEFAULT_CONTENT_VIEW_LABEL)&.first

      if cv_wrong_label
        cv_wrong_label.update_attribute(:label, DEFAULT_CONTENT_VIEW_LABEL)
        @library_view = cv_wrong_label
      else
        @library_view = Katello::ContentView.where(
          default: true,
          name: DEFAULT_CONTENT_VIEW_NAME,
          label: DEFAULT_CONTENT_VIEW_LABEL,
          organization: @organization
        ).first_or_create!
      end
    end

    def create_library_cvv
      @library_cvv = Katello::ContentViewVersion.where(
        content_view: @library_view,
        major: 1
      ).first_or_create!
    end

    def create_redhat_provider
      @redhat_provider = Katello::Provider.where(
        :name => "Red Hat",
        :provider_type => Katello::Provider::REDHAT,
        organization: @organization
      ).first_or_create!
    end

    def create_anonymous_provider
      @anonymous_provider = Katello::Provider.where(
        :name => Katello::Provider::ANONYMOUS,
        :provider_type => Katello::Provider::ANONYMOUS,
        organization: @organization
      ).first_or_create!
    end

    def create_cdn_configuration
      @cdn_configuration = Katello::CdnConfiguration.where(organization: @organization)

      if @cdn_configuration.blank?
        Katello::CdnConfiguration.where(
          organization: @organization,
          url: ::Katello::Resources::CDN::CdnResource.redhat_cdn_url,
          type: ::Katello::CdnConfiguration::CDN_TYPE
        ).first_or_create!
      end
    end
  end
end
