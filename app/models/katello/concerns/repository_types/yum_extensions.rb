module Katello
  module Concerns
    module RepositoryTypes
      module YumExtensions
        extend ActiveSupport::Concern
        YUM_TYPE = 'yum'

        module ClassMethods
          def with_errata(errata)
            joins(:repository_errata).where("#{Katello::RepositoryErratum.table_name}.erratum_id" => errata)
          end
        end

        included do
          has_many :repository_errata, :class_name => "Katello::RepositoryErratum", :dependent => :destroy
          has_many :errata, :through => :repository_errata

          has_many :repository_rpms, :class_name => "Katello::RepositoryRpm", :dependent => :destroy
          has_many :rpms, :through => :repository_rpms

          has_many :repository_package_groups, :class_name => "Katello::RepositoryPackageGroup", :dependent => :destroy
          has_many :package_groups, :through => :repository_package_groups

          scope :yum_type, -> { where(:content_type => YUM_TYPE) }
        end

        def yum?
          content_type == YUM_TYPE
        end

        def packages_without_errata
          if errata_filenames.any?
            self.rpms.where("#{Rpm.table_name}.filename NOT in (?)", errata_filenames)
          else
            self.rpms
          end
        end

        def errata_filenames
          Katello::ErratumPackage.joins(:erratum => :repository_errata).
              where("#{RepositoryErratum.table_name}.repository_id" => self.id).pluck("#{ Katello::ErratumPackage.table_name}.filename")
        end
      end
    end
  end
end
