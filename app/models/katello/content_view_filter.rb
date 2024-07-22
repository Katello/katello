module Katello
  class ContentViewFilter < Katello::Model
    include Authorization::ContentViewFilter
    audited :associations => [:repositories], :associated_with => :content_view, :except => [:name, :description]
    DOCKER = 'docker'.freeze
    RPM = Rpm::CONTENT_TYPE
    PACKAGE_GROUP   = PackageGroup::CONTENT_TYPE
    ERRATA          = Erratum::CONTENT_TYPE
    MODULE_STREAM   = ModuleStream::CONTENT_TYPE
    DEB             = Deb::CONTENT_TYPE
    CONTENT_TYPES   = [RPM, PACKAGE_GROUP, ERRATA, DOCKER, DEB, MODULE_STREAM].freeze
    CONTENT_OPTIONS = { _('Packages') => RPM, _('Module Streams') => ModuleStream, _('Package Groups') => PACKAGE_GROUP, _('Errata') => ERRATA, _('Container Images') => DOCKER, _('Deb Packages') => DEB }.freeze

    belongs_to :content_view,
               :class_name => "Katello::ContentView",
               :inverse_of => :filters

    has_many :repository_content_view_filters, :class_name => "Katello::RepositoryContentViewFilter", :dependent => :delete_all, :inverse_of => :filter
    has_many :repositories, :through => :repository_content_view_filters, :class_name => "Katello::Repository"

    validates_lengths_from_database
    validate :validate_content_view
    validate :validate_repos
    validates :name, :presence => true, :allow_blank => false,
                     :uniqueness => { :scope => :content_view_id }
    validates_with Validators::KatelloNameFormatValidator, :attributes => :name

    scope :whitelist, -> { where(:inclusion => true) }
    scope :blacklist, -> { where(:inclusion => false) }

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :type, :rename => :content_type,
                  :complete_value => {Rpm::CONTENT_TYPE.to_sym => "Katello::ContentViewPackageFilter",
                                      Deb::CONTENT_TYPE.to_sym => "Katello::ContentViewDebFilter",
                                      PackageGroup::CONTENT_TYPE.to_sym => "Katello::ContentViewPackageGroupFilter",
                                      Erratum::CONTENT_TYPE.to_sym => "Katello::ContentViewErratumFilter",
                                      DOCKER.to_sym => "Katello::ContentViewDockerFilter",
                                      MODULE_STREAM.to_sym => "Katello::ContentViewModuleStreamFilter"}
    scoped_search :on => :inclusion, :rename => :inclusion_type, :complete_value => {include: "true", exclude: "false"}

    def self.yum(include_module_streams = true)
      types = [::Katello::ContentViewPackageGroupFilter.name,
               ::Katello::ContentViewErratumFilter.name,
               ::Katello::ContentViewPackageFilter.name,
              ]
      types << ::Katello::ContentViewModuleStreamFilter.name if include_module_streams
      where(:type => types)
    end

    def self.deb
      where(:type => ::Katello::ContentViewDebFilter.name)
    end

    def self.docker
      where(:type => [::Katello::ContentViewDockerFilter.name])
    end

    def self.module_stream
      where(:type => ::Katello::ContentViewModuleStreamFilter.name)
    end

    def self.errata
      where(:type => ::Katello::ContentViewErratumFilter.name)
    end

    def params_format
      {}
    end

    def content_type
      {
        ContentViewDebFilter => DEB,
        ContentViewPackageFilter => RPM,
        ContentViewErratumFilter => ERRATA,
        ContentViewPackageGroupFilter => PACKAGE_GROUP,
        ContentViewDockerFilter => DOCKER,
        ContentViewModuleStreamFilter => MODULE_STREAM,
      }[self.class]
    end

    def self.class_for(content_type)
      case content_type
      when DEB
        ContentViewDebFilter
      when RPM
        ContentViewPackageFilter
      when PACKAGE_GROUP
        ContentViewPackageGroupFilter
      when ERRATA
        ContentViewErratumFilter
      when DOCKER
        ContentViewDockerFilter
      when MODULE_STREAM
        ContentViewModuleStreamFilter
      else
        fail _("Invalid content type '%{content_type}' provided. Content types can be one of %{content_types}") %
                 { :content_type => content_type, :content_types => CONTENT_TYPES.join(", ") }
      end
    end

    def self.rule_class_for(filter)
      case filter.type
      when ContentViewDebFilter.name
        ContentViewDebFilterRule
      when ContentViewPackageFilter.name
        ContentViewPackageFilterRule
      when ContentViewPackageGroupFilter.name
        ContentViewPackageGroupFilterRule
      when ContentViewErratumFilter.name
        ContentViewErratumFilterRule
      when ContentViewModuleStreamFilter.name
        ContentViewModuleStreamFilterRule
      when ContentViewDockerFilter.name
        ContentViewDockerFilterRule
      else
        fail _("Invalid content type '%{content_type}' provided. Content types can be one of %{content_types}") %
                 { :content_type => filter.type, :content_types => CONTENT_TYPES.join(", ") }
      end
    end

    def self.rule_ids_for(filter)
      case filter.type
      when ContentViewDebFilter.name
        filter.deb_rule_ids
      when ContentViewPackageFilter.name
        filter.package_rule_ids
      when ContentViewPackageGroupFilter.name
        filter.package_group_rule_ids
      when ContentViewErratumFilter.name
        filter.erratum_rule_ids
      when ContentViewModuleStreamFilter.name
        filter.module_stream_ids
      when ContentViewDockerFilter.name
        filter.docker_rule_ids
      else
        fail _("Invalid content type '%{content_type}' provided. Content types can be one of %{content_types}") %
                 { :content_type => filter.type, :content_types => CONTENT_TYPES.join(", ") }
      end
    end

    def filter_type
      CONTENT_OPTIONS.key(content_type)
    end

    def self.create_for(content_type, options)
      clazz = class_for(content_type)
      clazz.create!(options)
    end

    def self.applicable(repo)
      query = %{ (katello_content_view_filters.id in (select content_view_filter_id from katello_repository_content_view_filters where repository_id = #{repo.id})) or
                 (katello_content_view_filters.id not in (select content_view_filter_id from katello_repository_content_view_filters))
               }
      where(query).select("DISTINCT katello_content_view_filters.id")
    end

    def as_json(options = {})
      super(options).update("content_view_label" => content_view.label,
                            "organization" => content_view.organization.label,
                            "repos" => repositories.collect(&:name),
                            "content" => content_type)
    end

    def validate_content_view
      if self.content_view.composite?
        errors.add(:base, _("cannot contain filters if composite view"))
      end

      if self.content_view.import_only?
        errors.add(:base, _("cannot add filter to import-only view"))
      end

      if self.content_view.generated?
        errors.add(:base, _("cannot add filter to generated content views"))
      end
    end

    def validate_filter_repos(errors, content_view)
      repo_diff = repositories - content_view.repositories
      unless repo_diff.empty?
        errors.add(:base, _("cannot contain filters whose repositories do not belong to this content view"))
      end
    end

    def resulting_products
      repositories.collect { |r| r.product }.uniq
    end

    def applicable_repos
      if self.repositories.blank?
        self.content_view.repositories
      else
        self.repositories
      end
    end

    def original_packages=(_include_original)
      fail "setting original_packages not supported for #{self.class.name}"
    end

    def original_module_streams=(_include_original)
      fail "setting original_module_streams not supported for #{self.class.name}"
    end

    def rules
      self.class.rule_class_for(self).where(content_view_filter_id: id)
    end

    protected

    def validate_repos
      validate_filter_repos(self.errors, self.content_view)
    end
  end
end
