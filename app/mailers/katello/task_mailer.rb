module Katello
  class TaskMailer < ApplicationMailer
    helper ApplicationHelper
    include Rails.application.routes.url_helpers

    def repo_sync_failure(options)
      user, @repo, @task = options.values_at(:user, :repo, :task)

      ::User.as(user.login) do
        subject = _("Repository %{label} failed to synchronize") % { :label => @repo.label }

        set_locale_for(user) do
          mail(:to => user.mail, :subject => subject)
        end
      end
    end

    def cv_publish_failure(options)
      user, @content_view, @task = options.values_at(:user, :content_view, :task)

      ::User.as(user.login) do
        subject = _("%{label} failed") % { :label => @task.action }

        set_locale_for(user) do
          mail(:to => user.mail, :subject => subject)
        end
      end
    end

    def cv_promote_failure(options)
      user, @content_view, @task = options.values_at(:user, :content_view, :task)

      ::User.as(user.login) do
        subject = _("%{label} failed") % { :label => @task.action }

        set_locale_for(user) do
          mail(:to => user.mail, :subject => subject)
        end
      end
    end
  end
end
