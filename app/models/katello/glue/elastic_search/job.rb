module Katello
  module Glue::ElasticSearch::Job
    def self.included(base)
      base.send :include, Ext::IndexedModel

      base.class_eval do
        index_options :json => {:only => [:job_owner_id, :job_owner_type]},
                      :extended_json => :extended_index_attrs
      end
    end

    def extended_index_attrs
      ret = {}

      first_task = self.task_statuses.first
      unless first_task.nil?
        ret[:username] = first_task.user.login
        ret[:parameters] = first_task.parameters
      end
      ret
    end
  end
end
