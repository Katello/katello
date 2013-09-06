#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

class PromotionChangeset < Changeset
  use_index_of Changeset if Katello.config.use_elasticsearch

  def apply(options = { })
    options = { :async => true, :notify => false }.merge options

    check_review_state!

    validate_content_view_tasks_complete!

    # if the user is attempting to promote a composite view and one or more of the
    # component views neither exists in the target environment nor is part
    # of the changeset, stop the promotion
    self.content_views.composite.each do |view|
      components = view.components_not_in_env(self.environment) - self.content_views
      unless components.blank?
        raise _("Please add '%{component_content_views}' to the changeset '%{changeset}' "\
                "if you wish to promote the composite view '%{composite_view}' with it.") %
                { :component_content_views => components.map(&:name).join(', '),
                  :changeset => self.name, :composite_view => view.name}
      end
    end
    validate_content! self.content_views

    # check no collision exists
    check_collisions!

    self.state = Changeset::PROMOTING
    self.save!

    if options[:async]
      task             = self.async(:organization => self.environment.organization).promote_content(options[:notify])
      self.task_status = task
      self.save!
      self.task_status
    else
      self.task_status = nil
      self.save!
      promote_content(options[:notify])
    end
  end

  # TODO: break up method
  # rubocop:disable MethodLength
  def promote_content(notify = false)
    update_progress! '0'

    from_env = self.environment.prior
    to_env   = self.environment
    update_progress! '30'
    PulpTaskStatus.wait_for_tasks(promote_views(from_env, to_env, self.content_views.composite(false)))
    update_progress! '50'
    PulpTaskStatus.wait_for_tasks(promote_views(from_env, to_env, self.content_views.composite(true)))
    update_progress! '60'
    self.content_views.composite(false).each{|cv| cv.index_repositories(to_env)}
    update_progress! '80'
    self.content_views.composite(true).each{|cv| cv.index_repositories(to_env)}
    update_progress! '90'

    update_view_cp_content(to_env)
    update_progress! '100'

    PulpTaskStatus.wait_for_tasks(generate_metadata(from_env, to_env))

    self.promotion_date = Time.now
    self.state          = Changeset::PROMOTED

    Glue::Event.trigger(Katello::Actions::ChangesetPromote, self)

    self.save!

    if notify
      message = _("Successfully promoted changeset '%s'.") % self.name
      Notify.success message, :request_type => "changesets___promote", :organization => self.environment.organization
    end

  rescue => e
    self.state = Changeset::FAILED
    self.save!
    Rails.logger.error(e)
    Rails.logger.error(e.backtrace.join("\n"))
    if notify
      Notify.exception _("Failed to promote changeset '%s'. Check notices for more details") % self.name, e,
                   :request_type => "changesets___promote", :organization => self.environment.organization
    end
    raise e
  end

  def promote_views(from_env, to_env, views)
    views.collect do |view|
      view.promote(from_env, to_env)
    end.flatten
  end

  def update_view_cp_content(to_env)
    self.content_views.collect do |view|
      view.update_cp_content(to_env)
    end
  end

  def generate_metadata(from_env, to_env)
    async_tasks = affected_repos.collect do |repo|
      repo.get_clone(to_env).generate_metadata
    end
    async_tasks.flatten(1)
  end

  def affected_repos
    repos = []
    repos += self.content_views.collect { |v| v.repos(self.environment.prior)}.flatten(1)
    repos.uniq
  end
end
