module Katello
  module Pulp
    class Erratum < PulpContentUnit
      PULP_SELECT_FIELDS = %w(errata_id).freeze
      CONTENT_TYPE = "erratum".freeze

      def self.unit_handler
        Katello.pulp_server.extensions.errata
      end

      def update_model(model)
        keys = %w(title id severity issued type description reboot_suggested solution updated summary)
        custom_json = backend_data.slice(*keys)

        # handle SUSE epoch dates
        custom_json["issued"] = convert_date_if_epoch(custom_json["issued"])
        custom_json["updated"] = convert_date_if_epoch(custom_json["updated"]) unless custom_json["updated"].blank?

        if model.updated.blank? || (custom_json['updated'].to_datetime != model.updated.to_datetime)
          custom_json['errata_id'] = custom_json.delete('id')
          custom_json['errata_type'] = custom_json.delete('type')
          custom_json['updated'] = custom_json['updated'].blank? ? custom_json['issued'] : custom_json['updated']
          model.update!(custom_json)

          unless backend_data['references'].blank?
            update_bugzillas(model, backend_data['references'].select { |r| r['type'] == 'bugzilla' })
            update_cves(model, backend_data['references'].select { |r| r['type'] == 'cve' })
          end
        end
        update_packages(model, backend_data['pkglist']) unless backend_data['pkglist'].blank?
        update_modules(model, backend_data['pkglist']) unless backend_data['pkglist'].blank?
      end

      def update_bugzillas(model, json)
        needed_function = lambda do
          existing_names = model.bugzillas.pluck(:bug_id)
          json.select { |bz| !existing_names.include?(bz['id']) }
        end
        action_function = lambda do |needed|
          model.bugzillas.create!(needed.map { |bug| {:bug_id => bug['id'], :href => bug['href']} })
        end
        run_until(model, needed_function, action_function)
      end

      def update_cves(model, json)
        needed_function = lambda do
          existing_names = model.cves.pluck(:cve_id)
          json.select { |cve| !existing_names.include?(cve['id']) }
        end
        action_function = lambda do |needed|
          model.cves.create!(needed.map { |cve| {:cve_id => cve['id'], :href => cve['href']} })
        end
        run_until(model, needed_function, action_function)
      end

      def update_packages(model, json)
        needed_function = lambda do
          package_hashes = json.map { |list| list['packages'] }.flatten
          package_attributes = package_hashes.map do |hash|
            nvrea = Util::Package.build_nvra(hash)
            {'name' => hash['name'], 'nvrea' => nvrea, 'filename' => hash['filename']}
          end
          existing_nvreas = model.packages.pluck(:nvrea)
          package_attributes.delete_if { |pkg| existing_nvreas.include?(pkg['nvrea']) }
          package_attributes.uniq { |pkg| pkg['nvrea'] }
        end
        action_function = lambda do |needed|
          model.packages.create!(needed)
        end
        run_until(model, needed_function, action_function)
      end

      def update_modules(model, json)
        needed_function = lambda do
          module_stream_attributes = []
          json.each do |package_item|
            if package_item['module']
              module_stream = ::Katello::ModuleStream.where(package_item['module']).first
              next if module_stream.blank?
              nvreas = package_item["packages"].map { |hash| Util::Package.build_nvra(hash) }
              module_stream_id_column = "#{ModuleStreamErratumPackage.table_name}.module_stream_id"
              erratum_id_column = "#{ErratumPackage.table_name}.erratum_id"
              existing = ErratumPackage.joins(:module_streams).
                                        where(module_stream_id_column => module_stream.id, erratum_id_column => model.id,
                                              :nvrea => nvreas).pluck(:nvrea)

              (nvreas - existing).each do |nvrea|
                package = model.packages.find_by(:nvrea => nvrea)
                module_stream_attributes << { :module_stream_id => module_stream.id,
                                              :erratum_package_id => package.id }
              end
            end
          end
          module_stream_attributes.uniq
        end

        action_function = lambda do |needed|
          needed.each do |msep|
            ModuleStreamErratumPackage.create!(msep)
          end
        end

        run_until(model, needed_function, action_function)
      end

      def run_until(model, needed_function, action_function)
        needed = needed_function.call
        retries = needed.length
        until needed.empty? || retries == 0
          begin
            action_function.call(needed)
          rescue ActiveRecord::RecordNotUnique
            model.reload
          end
          needed = needed_function.call
          retries -= 1
        end
        fail _('Failed indexing errata, maximum retries encountered') if retries == 0 && needed.any?
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
