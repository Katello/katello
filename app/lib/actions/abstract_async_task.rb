module Actions
  class AbstractAsyncTask < Actions::EntryAction
    middleware.use Actions::Middleware::RemoteAction

    def humanized_output
      ""
    end

    def rescue_strategy
      Dynflow::Action::Rescue::Skip
    end
  end
end
