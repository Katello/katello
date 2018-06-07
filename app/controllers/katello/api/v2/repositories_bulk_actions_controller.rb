module Katello
  class Api::V2::RepositoriesBulkActionsController < Api::V2::ApiController
    before_action :find_repositories, :except => [:audits]
    before_action :find_related_repositories, :only => [:audits]

    api :PUT, "/repositories/bulk/destroy", N_("Destroy one or more repositories")
    param :ids, Array, :desc => N_("List of repository ids"), :required => true
    def destroy_repositories
      deletion_authorized_repositories = @repositories.deletable
      unpromoted_repos = deletion_authorized_repositories.reject { |repo| repo.promoted? }
      deletable_repositories = unpromoted_repos.reject { |repo| repo.redhat? }

      messages1 = format_bulk_action_messages(
          :success    => "",
          :error      => _("You do not have permissions to delete %s"),
          :models     => @repositories,
          :authorized => deletion_authorized_repositories
      )

      messages2 = format_bulk_action_messages(
          :success    => "",
          :error      => _("Repository %s cannot be deleted since it has already been included in a published Content View."),
          :models     => deletion_authorized_repositories,
          :authorized => unpromoted_repos
      )

      messages3 = format_bulk_action_messages(
          :success    => "",
          :error      => _("Repository %s cannot be deleted since they are Red Hat repositories."),
          :models     => unpromoted_repos,
          :authorized => deletable_repositories
      )

      errors = messages3[:error] + messages1[:error] + messages2[:error]

      task = nil
      if deletable_repositories.count > 0
        task = async_task(::Actions::BulkAction, ::Actions::Katello::Repository::Destroy, deletable_repositories)
      else
        status = 400
      end
      respond_for_bulk_async :resource => OpenStruct.new(:task => task, :errors => errors), :status => status
    end

    api :POST, "/repositories/bulk/sync", N_("Synchronize repository")
    param :ids, Array, :desc => N_("List of repository ids"), :required => true
    def sync_repositories
      syncable_repositories = @repositories.syncable.has_url
      if syncable_repositories.empty?
        msg = _("Unable to synchronize any repository. You either do not have the permission to"\
                " synchronize or the selected repositories do not have a feed url.")
        fail HttpErrors::UnprocessableEntity, msg
      else
        task = async_task(::Actions::BulkAction,
                          ::Actions::Katello::Repository::Sync,
                          syncable_repositories)

        respond_for_async :resource => task
      end
    end

    api :GET, "/repositories/bulk/audits", N_("List audits for repositories")
    param :content_type, RepositoryTypeManager.repository_types.keys, :desc => N_("limit to only repositories of this type")
    # content_view_version_id
    def audits
      repository_ids = @repositories.pluck(:id)

      if params[:content_view_version_id]
        cvv = ContentViewVersion.find(params[:content_view_version_id])
        cvv_repository_ids = cvv.repositories.pluck(:id)
        repository_ids = cvv_repository_ids.reject do |id|
          !repository_ids.include? id
        end
      end

      if params[:repository_id]
        id = params[:repository_id].to_i
        if !repository_ids.include? id
          head 404 #???? log a message or just return empty?
          return
        end
        repository_ids = [params[:repository_id]]
      end

      audits = Audit.where(auditable_type: 'Katello::Repository', auditable_id: repository_ids).or(Audit.where(associated_id: repository_ids))

      respond_for_index(:collection => scoped_search(audits, "created_at", "DESC", resource_class: Audit))
    end

    private

    def find_repositories
      params.require(:ids)
      @repositories = Repository.where(:id => params[:ids])
    end

    # Reduce visible repos to include lifecycle env permissions
    # http://projects.theforeman.org/issues/22914
    def readable_repositories
      table_name = Repository.table_name
      in_products = Repository.where(:product_id => Katello::Product.authorized(:view_products)).select(:id)
      in_environments = Repository.where(:environment_id => Katello::KTEnvironment.authorized(:view_lifecycle_environments)).select(:id)
      in_content_views = Repository.joins(:content_view_repositories).where("#{ContentViewRepository.table_name}.content_view_id" => Katello::ContentView.readable).select(:id)
      in_versions = Repository.joins(:content_view_version).where("#{Katello::ContentViewVersion.table_name}.content_view_id" => Katello::ContentView.readable).select(:id)
      Repository.where("#{table_name}.id in (?) or #{table_name}.id in (?) or #{table_name}.id in (?) or #{table_name}.id in (?)", in_products, in_content_views, in_versions, in_environments)
    end

    def find_related_repositories
      #params.require(:ids)
      #@repositories = Repository.where(:id => params[:repository_ids])

      @repositories = readable_repositories
      @repositories = @repositories.where(content_type: params[:content_type]) if params[:content_type]
      @repositories = @repositories.distinct
    end
  end
end
