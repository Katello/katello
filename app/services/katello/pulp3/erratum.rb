module Katello
  module Pulp3
    class Erratum < PulpContentUnit
      include LazyAccessor
      PULPCORE_CONTENT_TYPE = "rpm.advisory".freeze

      def self.content_api
        PulpRpmClient::ContentAdvisoriesApi.new(Katello::Pulp3::Api::Yum.new(SmartProxy.pulp_primary!).api_client)
      end

      def self.unit_identifier
        "id"
      end

      def self.backend_unit_identifier
        "pulp_href"
      end

      def self.supports_id_fetch?
        false
      end

      def self.ids_for_repository(repo_id)
        repo = Katello::Pulp3::Repository::Yum.new(Katello::Repository.find(repo_id), SmartProxy.pulp_primary)
        repo_content_list = repo.content_list
        repo_content_list.map { |content| content.try(:pulp_href) }
      end

      def self.generate_model_row(unit)
        keys = %w(title id severity issued_date type description reboot_suggested solution updated_date summary)
        custom_json = unit.slice(*keys)
        custom_json.inject(HashWithIndifferentAccess.new({})) { |h, (k, v)| h.merge({ k => v.respond_to?(:strip) ? v.strip : v }) }
        custom_json['pulp_id'] = custom_json['id']
        custom_json["issued"] = custom_json.delete("issued_date")
        custom_json["updated"] = custom_json.delete("updated_date")
        custom_json['title'] = custom_json['title']&.truncate(255)

        # handle SUSE epoch dates
        custom_json["issued"] = convert_date_if_epoch(custom_json["issued"])
        custom_json["updated"] = convert_date_if_epoch(custom_json["updated"]) unless custom_json["updated"].blank?

        custom_json['errata_id'] = custom_json.delete('id')
        custom_json['errata_type'] = custom_json.delete('type')
        custom_json['issued'] = custom_json['issued'].to_datetime.strftime('%Y-%m-%d').to_datetime
        custom_json['updated'] = custom_json['updated'].blank? ? custom_json['issued'] : custom_json['updated'].to_datetime.strftime('%Y-%m-%d').to_datetime
        custom_json
      end

      def self.insert_child_associations(units, pulp_id_to_id)
        bugzillas = []
        cves = []
        packages = []
        modules = []

        units.each do |unit|
          katello_id = pulp_id_to_id[unit['id']]
          bugzillas += build_bugzillas(katello_id, unit['references'])
          cves += build_cves(katello_id, unit['references'])
          packages += build_packages(katello_id, unit['pkglist'])
        end

        Katello::ErratumBugzilla.insert_all(bugzillas, unique_by: [:erratum_id, :bug_id, :href]) if bugzillas.any?
        Katello::ErratumCve.insert_all(cves, unique_by: [:erratum_id, :cve_id, :href]) if cves.any?
        Katello::ErratumPackage.insert_all(packages, unique_by: [:erratum_id, :nvrea, :name, :filename]) if packages.any?
        units.each do |unit|
          katello_id = pulp_id_to_id[unit['id']]
          modules += build_modules(katello_id, unit['pkglist'])
        end
        ModuleStreamErratumPackage.insert_all(modules, unique_by: [:module_stream_id, :erratum_package_id]) if modules.any?
        nil
      end

      def self.build_bugzillas(katello_id, ref_list)
        ref_list.select { |r| r[:type] == "bugzilla" }.map do |bugzilla|
          {
            bug_id: bugzilla[:id],
            href: bugzilla[:href],
            erratum_id: katello_id
          }
        end
      end

      def self.build_cves(katello_id, ref_list)
        ref_list.select { |r| r[:type] == "cve" }.map do |cve|
          {
            cve_id: cve[:id],
            href: cve[:href],
            erratum_id: katello_id
          }
        end
      end

      def self.build_packages(katello_id, pkg_list)
        list = pkg_list.map do |json|
          package_hashes = json[:packages]
          package_hashes.map do |hash|
            nvrea = Util::Package.build_nvra(hash)
            {'name' => hash[:name], 'nvrea' => nvrea, 'filename' => hash[:filename], :erratum_id => katello_id}
          end
        end
        list.flatten
      end

      def self.build_modules(katello_id, module_stream_list)
        module_stream_attributes = []
        module_stream_list.each do |package_item|
          if package_item[:module]
            module_stream = ::Katello::ModuleStream.where(package_item[:module]).first
            next if module_stream.blank?
            nvreas = package_item[:packages].map { |hash| Util::Package.build_nvra(hash) }
            package_ids = Katello::ErratumPackage.where(:erratum_id => katello_id, :nvrea => nvreas).pluck(:id)

            module_stream_attributes += package_ids.map do |pkg_id|
              { :module_stream_id => module_stream.id,
                :erratum_package_id => pkg_id }
            end

          end
        end
        module_stream_attributes.uniq
      end

      def self.convert_date_if_epoch(date)
        date.to_i.to_s == date ? epoch_to_date(date) : date
      end

      def self.epoch_to_date(epoch)
        Time.at(epoch.to_i).to_s
      end
    end
  end
end
