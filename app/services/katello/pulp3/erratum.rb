module Katello
  module Pulp3
    class Erratum < PulpContentUnit
      include LazyAccessor

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

      # rubocop:disable Metrics/AbcSize
      def update_model(model, repository = nil)
        updated = false
        keys = %w(title id severity issued_date type description reboot_suggested solution updated_date summary)
        custom_json = backend_data.slice(*keys)
        custom_json["issued"] = custom_json.delete("issued_date")
        custom_json["updated"] = custom_json.delete("updated_date")

        # handle SUSE epoch dates
        custom_json["issued"] = convert_date_if_epoch(custom_json["issued"])
        custom_json["updated"] = convert_date_if_epoch(custom_json["updated"]) unless custom_json["updated"].blank?

        custom_json['errata_id'] = custom_json.delete('id')
        custom_json['errata_type'] = custom_json.delete('type')
        custom_json['issued'] = custom_json['issued'].to_datetime.strftime('%Y-%m-%d').to_datetime
        custom_json['updated'] = custom_json['updated'].blank? ? custom_json['issued'] : custom_json['updated'].to_datetime.strftime('%Y-%m-%d').to_datetime

        if model.updated.blank? ||
          model.attributes.excluding(model.attributes.keys - custom_json.keys) != custom_json
          model.update!(custom_json)
          updated = true

          unless backend_data['references'].blank?
            update_bugzillas(model, backend_data['references'])
            update_cves(model, backend_data['references'])
          end
        end
        update_packages(model, backend_data['pkglist']) unless backend_data['pkglist'].blank?
        update_modules(model, backend_data['pkglist']) unless backend_data['pkglist'].blank?

        if !updated && repository.present?
          backend_identifier = backend_data.dig(self.class.backend_unit_identifier)
          if Katello::RepositoryErratum.where(repository_id: repository.id, erratum_id: model.id).where.not(erratum_pulp3_href: backend_identifier).any?
            # Pulp has created a new record for this erratum because it has been updated so we need to update repo association too
            updated = true
          end
        end

        return model.id if updated
      end
      # rubocop:enable Metrics/AbcSize

      def update_bugzillas(model, ref_list)
        ref_list.select { |r| r[:type] == "bugzilla" }.each do |bugzilla|
          Katello::Util::Support.active_record_retry do
            model.bugzillas.where(bug_id: bugzilla[:id]).first_or_create!(bug_id: bugzilla[:id], href: bugzilla[:href], erratum_id: model.id)
          end
        end
      end

      def update_cves(model, ref_list)
        ref_list.select { |r| r[:type] == "cve" }.each do |cve|
          Katello::Util::Support.active_record_retry do
            model.cves.where(cve_id: cve[:id]).first_or_create!(cve_id: cve[:id], href: cve[:href], erratum_id: model.id)
          end
        end
      end

      def update_packages(model, package_list)
        package_list.each do |json|
          package_hashes = json[:packages]
          package_attributes = package_hashes.map do |hash|
            nvrea = Util::Package.build_nvra(hash)
            {'name' => hash[:name], 'nvrea' => nvrea, 'filename' => hash[:filename]}
          end
          existing_nvreas = model.packages.pluck(:nvrea)
          package_attributes.delete_if { |pkg| existing_nvreas.include?(pkg['nvrea']) }
          package_attributes.uniq.each do |package|
            Katello::Util::Support.active_record_retry do
              model.packages.where(filename: package["filename"]).first_or_create!(package)
            end
          end
        end
      end

      def update_modules(model, module_stream_list)
        module_stream_attributes = []
        module_stream_list.each do |package_item|
          if package_item[:module]
            module_stream = ::Katello::ModuleStream.where(package_item[:module]).first
            next if module_stream.blank?
            nvreas = package_item[:packages].map { |hash| Util::Package.build_nvra(hash) }
            module_stream_id_column = "#{ModuleStreamErratumPackage.table_name}.module_stream_id"
            existing = ErratumPackage.joins(:module_streams).
                                      where(module_stream_id_column => module_stream.id,
                                            :nvrea => nvreas).pluck(:nvrea)

            (nvreas - existing).each do |nvrea|
              package = model.packages.find_by(:nvrea => nvrea)
              module_stream_attributes << { :module_stream_id => module_stream.id,
                                            :erratum_package_id => package.id }
            end
          end
        end
        module_stream_attributes.uniq.each do |module_stream|
          Katello::Util::Support.active_record_retry do
            if model.module_streams.empty? || !model.module_streams.pluck(:module_stream_id).include?(module_stream[:module_stream_id])
              ModuleStreamErratumPackage.create!(module_stream)
            end
          end
        end
      end

      def convert_date_if_epoch(date)
        date.to_i.to_s == date ? epoch_to_date(date) : date
      end

      def epoch_to_date(epoch)
        Time.at(epoch.to_i).to_s
      end
    end
  end
end
