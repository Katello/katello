class CleanDuplicateContentUnits < ActiveRecord::Migration[6.0]
  def find_duplicate_groups(model, fields)
    model.having("count(*) > 1").group(*fields).pluck("string_agg(id::TEXT, ',') ").map do |ids|
      ids.split(',').map(&:to_i)
    end
  end

  def reassign_duplicate_associations(associated_models, duplicates, new_id, field)
    associated_models.each do |associated_model, unique_by|
      associated_duplicates = associated_model.where(field => duplicates)
      to_delete, to_update = filter_duplicates(associated_model, associated_duplicates, new_id, field, [unique_by])
      to_delete.each(&:destroy) #use destroy to destroy child models if any
      associated_model.where(id: to_update).update_all(field => new_id) if to_update.any?
    end
  end

  #returns two lists, the first of duplicates that need deleting, and
  # the 2nd of duplicates that need updating to the new_id
  def filter_duplicates(model_class, duplicate_models, new_id, new_id_field, unique_fields)
    to_delete = []
    to_update = []
    duplicate_models.each do |duplicate|
      query = { new_id_field => new_id }
      unique_fields.each do |field|
        query[field] = duplicate.send(field)
      end
      if model_class.where(query).any?
        to_delete << duplicate
      else
        to_update << duplicate
      end
    end
    return to_delete, to_update
  end

  def remove_children(reference_attribute_name, ids, child_models)
    child_models.each do |model|
      model.where(reference_attribute_name => ids).delete_all
    end
  end

  def handle_duplicate(model, reference_attribute_name, unique_by_fields, associated_models: [], child_models: [])
    find_duplicate_groups(model, unique_by_fields).each do |duplicate_ids|
      to_keep = duplicate_ids.sort!.shift

      remove_children(reference_attribute_name, duplicate_ids, child_models)
      reassign_duplicate_associations(associated_models, duplicate_ids, to_keep, reference_attribute_name)
      model.where(id: duplicate_ids).delete_all
    end
  end

  def up
    handle_null_pulp_ids
    add_foreign_keys
    delete_deprecated_models

    handle_duplicate(Katello::ModuleStream,
                     'module_stream_id',
                     [:pulp_id],
                     associated_models: { Katello::RepositoryModuleStream => :repository_id },
                     child_models: [Katello::ContentViewModuleStreamFilterRule,
                                    Katello::ContentFacetApplicableModuleStream,
                                    Katello::ModuleProfile,
                                    Katello::ModuleStreamArtifact,
                                    Katello::ModuleStreamErratumPackage,
                                    Katello::ModuleStreamRpm])

    add_index :katello_module_streams, :pulp_id, :unique => true
    add_index :katello_module_profiles, [:module_stream_id, :name], :unique => true
    add_index :katello_module_profile_rpms, [:module_profile_id, :name], :unique => true

    handle_duplicate(Katello::AnsibleTag, 'ansible_tag_id', [:name],
                     associated_models: { Katello::AnsibleCollectionTag => :ansible_collection_id })
    add_index :katello_ansible_tags, [:name], :unique => true

    handle_duplicate(Katello::AnsibleCollectionTag, 'ansible_collection_tag_id', [:ansible_collection_id, :ansible_tag_id])
    add_index :katello_ansible_collection_tags, [:ansible_collection_id, :ansible_tag_id], :unique => true,
              :name => 'katello_ans_coll_tags_coll_id_tag_id'

    handle_duplicate(Katello::GenericContentUnit,
                     'generic_content_unit_id',
                     [:pulp_id],
                     associated_models: { Katello::RepositoryGenericContentUnit => :repository_id })
    add_index :katello_generic_content_units, :pulp_id, :unique => true

    handle_duplicate(Katello::DockerManifestList, 'docker_manifest_list_id', [:pulp_id],
                     associated_models: {
                       Katello::DockerManifestListManifest => :docker_manifest_id,
                       Katello::RepositoryDockerManifestList => :repository_id
                     })
    add_index :katello_docker_manifest_lists, :pulp_id, :unique => true

    handle_duplicate(Katello::DockerManifest, 'docker_manifest_id', [:pulp_id],
                     associated_models: {
                       Katello::DockerManifestListManifest => :docker_manifest_list_id,
                       Katello::RepositoryDockerManifest => :repository_id
                     })
    add_index :katello_docker_manifests, :pulp_id, :unique => true
  end

  def handle_null_pulp_ids
    Katello::DockerTag.where(:pulp_id => nil).destroy_all
    change_column :katello_docker_tags, :pulp_id, :string, :null => false

    Katello::DockerManifestList.where(:pulp_id => nil).destroy_all
    change_column :katello_docker_manifest_lists, :pulp_id, :string, :null => false

    Katello::DockerManifest.where(:pulp_id => nil).destroy_all
    change_column :katello_docker_manifests, :pulp_id, :string, :null => false
  end

  def delete_deprecated_models
    Katello::ModuleProfileRpm.delete_all
    Katello::ModuleProfile.delete_all
  end

  def add_foreign_keys
    Katello::DockerManifestListManifest.where.not(docker_manifest_list_id: Katello::DockerManifestList.pluck(:id)).delete_all
    add_foreign_key :katello_docker_manifest_list_manifests, :katello_docker_manifest_lists, column: :docker_manifest_list_id

    Katello::RepositoryDockerManifest.where.not(docker_manifest_id: Katello::DockerManifest.pluck(:id)).delete_all
    add_foreign_key :katello_repository_docker_manifests, :katello_docker_manifests, column: :docker_manifest_id

    Katello::RepositoryDockerManifestList.where.not(docker_manifest_list_id: Katello::DockerManifestList.pluck(:id)).delete_all
    add_foreign_key :katello_repository_docker_manifest_lists, :katello_docker_manifest_lists, column: :docker_manifest_list_id
  end

  def down
    remove_index :katello_module_streams, :pulp_id
    remove_index :katello_module_profiles, [:module_stream_id, :name]
    remove_index :katello_module_profile_rpms, [:module_profile_id, :name]
    remove_index :katello_ansible_tags, :name
    remove_index :katello_ansible_collection_tags, [:ansible_collection_id, :ansible_tag_id]
    remove_index :katello_docker_manifests, :pulp_id
    remove_index :katello_docker_manifest_lists, :pulp_id
    remove_index :katello_generic_content_units, :pulp_id

    remove_foreign_key :katello_repository_docker_manifest_lists, :katello_docker_manifest_lists
    remove_foreign_key :katello_repository_docker_manifests, :katello_docker_manifests
    remove_foreign_key :katello_docker_manifest_list_manifests, :katello_docker_manifest_lists

    change_column :katello_docker_tags, :pulp_id, :string, :null => true
    change_column :katello_docker_manifest_lists, :pulp_id, :string, :null => true
    change_column :katello_docker_manifests, :pulp_id, :string, :null => true
  end
end
