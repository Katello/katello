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


require 'set'
class DeletionChangeset < Changeset
  use_index_of Changeset if Katello.config.use_elasticsearch
  def apply(options = { })
    options = { :async => true, :notify => false }.merge options

    self.state == Changeset::REVIEW or
        raise _("Cannot delete the changeset '%s' because it is not in the review phase.") % self.name

    validate_content_view_tasks_complete!

    # check no collision exists
    if (collision = Changeset.started.colliding(self).first)
      raise _("Cannot promote the changeset '%{changeset}' while another colliding changeset (%{another_changeset}) is being promoted.") %
                { :changeset => self.name, :another_changeset => collision.name }
    else
      self.state = Changeset::DELETING
      self.save!
    end

    if options[:async]
      task  = self.async(:organization => self.environment.organization).delete_content(options[:notify])
      self.task_status = task
      self.save!
      self.task_status
    else
      self.task_status = nil
      self.save!
      delete_content(options[:notify])
    end
  end

  def delete_content(notify = false)
    update_progress! '0'
    update_progress! '10'
    from_env = self.environment

    update_progress! '30'
    delete_views from_env
    update_progress! '70'
    from_env.content_view_environment.update_cp_content
    update_progress! '100'

    self.promotion_date = Time.now
    self.state          = Changeset::DELETED

    Glue::Event.trigger(Katello::Actions::ChangesetPromote, self)

    self.save!

    if notify
      message = _("Successfully deleted changeset '%s'.") % self.name
      Notify.success message, :request_type => "changesets___delete", :organization => self.environment.organization
    end

  rescue => e
    self.state = Changeset::FAILED
    self.save!
    Rails.logger.error(e)
    Rails.logger.error(e.backtrace.join("\n"))
    if notify
      Notify.exception _("Failed to delete changeset '%s'. Check notices for more details") % self.name, e,
                   :request_type => "changesets___delete", :organization => self.environment.organization
    end
    raise e
  end

  def delete_views(from_env)
    self.content_views.each do |view|
      view.delete(from_env)
    end
  end
end
