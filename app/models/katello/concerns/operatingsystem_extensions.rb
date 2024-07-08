module Katello
  module Concerns
    module OperatingsystemExtensions
      extend ActiveSupport::Concern

      REDHAT_ATOMIC_HOST_DISTRO_NAME = "Red Hat Enterprise Linux Atomic Host".freeze
      REDHAT_ATOMIC_HOST_OS = "RedHat_Enterprise_Linux_Atomic_Host".freeze

      DEBIAN_DEFAULT_PROVISIONING_TEMPLATE = "Preseed default %{template_kind_name}".freeze
      DEBIAN_DEFAULT_PTABLE = "Preseed default".freeze

      SUSE_DEFAULT_PROVISIONING_TEMPLATE = "AutoYaST default %{template_kind_name}".freeze
      SUSE_DEFAULT_PTABLE = "AutoYaST entire SCSI disk".freeze

      included do
        after_create :assign_templates!
        before_create :set_atomic_attributes, :if => proc { |os| os.name == ::Operatingsystem::REDHAT_ATOMIC_HOST_OS }
      end

      def find_related_os
        Operatingsystem.unscoped.where(name: self.name).order(major: :desc, minor: :desc).where.not(id: self.id)
      end

      def assign_related_os_templates
        all_related_os = find_related_os
        return false if all_related_os.nil?

        boot_loader_template_kinds = TemplateKind.where(name: ["PXELinux", "PXEGrub", "PXEGrub2", "iPXE"]).pluck(:id)
        provision_template_kinds = TemplateKind.where(name: ["provision", "finish"]).pluck(:id)

        all_related_os.each do |related_os|
          next if related_os.provisioning_templates.empty? || related_os.ptables.empty?
          next if related_os.provisioning_templates.where(template_kind_id: boot_loader_template_kinds).size == 0
          next if related_os.provisioning_templates.where(template_kind_id: provision_template_kinds).size == 0

          Rails.logger.info "Using operating system #{related_os.name} (major: #{related_os.major}, minor: #{related_os.minor}) " \
                            "as a template source for the new OS #{name} (major: #{major}, minor: #{minor})."

          related_os.ptables.each do |ptable|
            ptables << ptable unless ptables.include?(ptable)
          end

          related_os.provisioning_templates.each do |template|
            provisioning_templates << template unless provisioning_templates.include?(template)
            OsDefaultTemplate.where(:operatingsystem_id => related_os.id, :provisioning_template_id => template.id).each do |os_default_temp|
              OsDefaultTemplate.create(:template_kind_id => os_default_temp.template_kind_id,
                                       :provisioning_template_id => os_default_temp.provisioning_template_id,
                                       :operatingsystem_id => id)
            end
          end
          return true
        end
        false
      end

      def provisioning_template_name_for_os(template_kind_name)
        case self.family
        when 'Redhat'
          if name == ::Operatingsystem::REDHAT_ATOMIC_HOST_OS && template_kind_name == "provision"
            Setting["katello_default_atomic_provision"]
          else
            Setting["katello_default_#{template_kind_name}"]
          end
        when 'Debian'
          format(DEBIAN_DEFAULT_PROVISIONING_TEMPLATE, template_kind_name: template_kind_name)
        when 'Suse'
          format(SUSE_DEFAULT_PROVISIONING_TEMPLATE, template_kind_name: template_kind_name)
        end
      end

      def partition_table_name_for_os
        case self.family
        when 'Redhat'
          Setting["katello_default_ptable"]
        when 'Debian'
          DEBIAN_DEFAULT_PTABLE
        when 'Suse'
          SUSE_DEFAULT_PTABLE
        end
      end

      def assign_templates!
        if [ 'Suse', 'Debian' ].include?(self.family) && assign_related_os_templates
          return
        end

        # Automatically assign default templates
        TemplateKind.all.each do |kind|
          provisioning_template_name = provisioning_template_name_for_os(kind.name)
          next if provisioning_template_name.nil?
          if (template = ProvisioningTemplate.unscoped.find_by_name(provisioning_template_name))
            provisioning_templates << template unless provisioning_templates.include?(template)
            if OsDefaultTemplate.where(:template_kind_id => kind.id, :operatingsystem_id => id).empty?
              OsDefaultTemplate.create(:template_kind_id => kind.id, :provisioning_template_id => template.id, :operatingsystem_id => id)
            end
          end
        end

        partition_table_name = partition_table_name_for_os
        return if partition_table_name.nil?
        if (ptable = Ptable.unscoped.find_by_name(partition_table_name)) && !ptables.include?(ptable)
          ptables << ptable
        end
      end

      def set_atomic_attributes
        self.description = "#{::Operatingsystem::REDHAT_ATOMIC_HOST_DISTRO_NAME} #{release}"
        self.architectures << Architecture.where(:name => "x86_64").first_or_create
        self.family = "Redhat"
      end

      def atomic?
        name.match(/.*atomic.*/i)
      end
    end
  end
end

class ::Operatingsystem::Jail < Safemode::Jail
  allow :atomic?
end
