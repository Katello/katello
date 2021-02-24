module Katello
  class Api::V2::PackageGroupsController < Api::V2::ApiController
    apipie_concern_subst(:a_resource => N_("a package group"), :resource => "package_groups")
    include Katello::Concerns::Api::V2::RepositoryContentController

    before_action :find_repository

    api :POST, "/package_group", N_("Create a package group")
    param :repository_id, String, :required => true, :desc => N_("repository_id")
    param :name, String, :required => true, :desc => N_("package group name")
    param :description, String, :desc => N_("package group description. Defaults to params[:name]")
    param :user_visible, :bool, :desc => N_("set \"user_visible\" flag on package group. Defaults to true")
    param :mandatory_package_names, Array, :desc => N_("mandatory package names to include in the package group")
    param :optional_package_names, Array, :desc => N_("optional package names to include in the package group")
    param :conditional_package_names, Array, :desc => N_("conditional package names to include in the package group")
    param :default_package_names, Array, :desc => N_("default package names to include in the package group")

    def create
      fail HttpErrors::BadRequest, _("name not defined.") if params[:name].blank?
      fail HttpErrors::BadRequest, _("repository_id not defined.") if params[:repository_id].blank?
      fail Katello::Errors::InvalidRepositoryContent, _("Can only upload to Yum Repositories.") unless @repo.yum?

      if params[:mandatory_package_names].empty? && params[:optional_package_names].empty? &&
         params[:conditional_package_names].empty? && params[:default_package_names].empty?
        fail HttpErrors::BadRequest, _("Must supply at least one of mandatory_package_names, " \
          "optional_package_names, conditional_package_names, default_package_names parameters")
      end

      params.each do |key, value|
        if key.to_s.include?('_package_names')
          if value.present?
            fail HttpErrors::BadRequest, _("%s must be an array.") % key unless value.is_a?(Array)
          end
        end
      end

      params[:description] = params[:name] if params[:description].empty?
      params[:user_visible] = ::Foreman::Cast.to_bool(params[:user_visible])
      params[:user_visible] ||= true

      create_params = params.slice(:name, :description, :user_visible, :mandatory_package_names, :optional_package_names, :conditional_package_names, :default_package_names).to_unsafe_h
      sync_task(::Actions::Katello::Repository::UploadPackageGroup, @repo, create_params)
      render :json => {:status => "success"}
    end

    api :DELETE, "/package_group", N_("Delete a package group")
    param :name, String, :required => true, :desc => N_("package group name")
    param :repository_id, String, :required => true, :desc => N_("repository_id")

    def destroy
      fail Katello::Errors::InvalidRepositoryContent, _("Can only destroy on Yum Repositories.") unless @repo.yum?
      fail _("name not defined.") if params[:name].blank?

      sync_task(::Actions::Katello::Repository::DestroyPackageGroup, @repo, params[:name])
      render :json => {:status => "success"}
    end

    def available_for_content_view_filter(filter, _collection)
      collection_ids = []
      current_ids = filter.package_group_rules.map(&:uuid)
      filter.applicable_repos.each do |repo|
        collection_ids.concat(repo.package_groups.map(&:pulp_id))
      end
      collection = PackageGroup.where(:pulp_id => collection_ids)
      collection = collection.where("pulp_id not in (?)", current_ids) unless current_ids.empty?
      collection
    end

    def all_for_content_view_filter(filter, _collection)
      PackageGroup.joins(:repositories).merge(filter.applicable_repos)
    end

    def default_sort
      %w(name asc)
    end

    def filter_by_content_view_filter(filter, collection)
      ids = filter.send("#{singular_resource_name}_rules").pluck(:uuid)
      filter_by_ids(ids, collection)
    end

    private

    def repo_association
      :repository_id
    end
  end
end
