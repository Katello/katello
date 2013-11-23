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

class Lock < ActiveRecord::Base

  class LockConflict < StandardError
    attr_reader :required_lock, :conflicting_locks
    def initialize(required_lock, conflicting_locks)
      super()
      @required_lock     = required_lock
      @conflicting_locks = conflicting_locks
    end
  end

  belongs_to :dynflow_execution_plan,
             class_name: 'DynflowExecutionPlan',
             foreign_key: :uuid

  belongs_to :task, foreign_key: :uuid
  belongs_to :resource, polymorphic: true

  scope :active, -> do
    joins(:dynflow_execution_plan)
    .where('dynflow_execution_plans.state != ?', :stopped)
  end

  scope :inactive, -> do
    joins(:dynflow_execution_plan)
    .where('dynflow_execution_plans.state = ?', :stopped)
  end

  validates :uuid, :name, :resource_id, :resource_type, presence: true

  validate do
    unless available?
      raise LockConflict.new(self, coliding_locks)
    end
  end

  # returns true if it's possible to aquire this kind of lock
  def available?
    return true unless coliding_locks.any?
  end

  # returns a scope of the locks coliding with this one
  def coliding_locks
    coliding_locks_scope = Lock.active.where('locks.uuid != ?', uuid)
    coliding_locks_scope = coliding_locks_scope.where(name:          name,
                                                      resource_id:  resource_id,
                                                      resource_type: resource_type)
    unless self.exclusive?
      coliding_locks_scope = coliding_locks_scope.where(:exclusive => true)
    end
    return coliding_locks_scope
  end

  class << self

    # Locks the resource so that no other task can lock it while running.
    # No other task related to the resource is not allowed (even not-locking ones)
    # A typical usecase is resource deletion, where it's good idea to make sure
    # nothing else related to the resource is really running.
    def exclusive!(resource, uuid)
      build_exclusive_locks(resource, uuid).each(&:save!)
    end

    def exclusive?(resource)
      build_exclusive_locks(resource).all?(:available?)
    end


    # Locks the resource so that no other task can lock it while running.
    # Other not-locking tasks are tolerated.
    #
    # The lock names allow to specify what locks should be activated. It has to
    # be a subset of names defined in model's class available_locks method
    #
    # When no lock name is specified, the resource is locked against all the available
    # locks.
    #
    # It also looks at +related_resources+ method of the resource to calcuate all
    # the related resources (recursively) and links the task to them as well.
    def lock!(resource, uuid, *lock_names)
      build_locks(resource, lock_names, uuid).each(&:save!)
    end

    def lock?(resource, uuid, *lock_names)
      build_locks(resource, lock_names, uuid).all?(&:available?)
    end

    # Assigns the resource to the task to easily track the task in context of
    # the resource. This doesn't prevent other actions to lock the resource
    # and should be used only for actions that tolerate other actions to be
    # performed on the resource. Usually, this shouldn't needed to be done
    # through the action directly, because the lock should assign it's parrent
    # objects to the action recursively (using +related_resources+ method in model
    # objects)
    def link!(resource, uuid)
      build_link(resource, uuid).save!
    end

    def link?(resource, uuid)
      build_link(resource, uuid).available?
    end

    # Records the information about the user that triggered the task
    def owner!(user, uuid)
      build_owner(user, uuid).save!
    end

    private

    def all_lock_names(resource, include_links = false)
      lock_names = []
      if resource.class.respond_to?(:available_locks) &&
            resource.class.available_locks.any?
        lock_names.concat(resource.class.available_locks)
      else
        raise "The resource #{resource.class.name} doesn't define any available lock"
      end
      if lock_names.include?(link_lock_name) || lock_names.include?(owner_lock_name)
        raise "Lock names #{link_lock_name} and #{owner_lock_name} are reserved"
      end
      lock_names.concat([link_lock_name, owner_lock_name]) if include_links
      return lock_names
    end

    def build_exclusive_locks(resource, uuid = nil)
      build_locks(resource, all_lock_names(resource, true), uuid)
    end

    def build_locks(resource, lock_names, uuid = nil)
      locks = []
      lock_names = all_lock_names(resource) if lock_names.empty?
      lock_names.map do |lock_name|
        locks << build(uuid, resource, lock_name, true)
      end
      locks.concat(build_links(resource, uuid))
      return locks
    end

    def build_links(resource, uuid = nil)
      related_resources(resource).map do |related_resource|
        build_link(related_resource, uuid)
      end
    end

    def build_link(resource, uuid = nil)
      build(uuid, resource, link_lock_name, false)
    end

    def build_owner(user, uuid = nil)
      build(uuid, user, owner_lock_name, false)
    end

    def build(uuid, resource, lock_name, exclusive)
      self.new(uuid:          uuid,
               name:          lock_name,
               resource_type: resource.class.name,
               resource_id:   resource.id,
               exclusive:     !!exclusive)
    end

    def link_lock_name
      :link_resource
    end

    def owner_lock_name
      :task_owner
    end

    # recursively search for related resources of the resource (using
    # the +related_resources+ method, avoiding the cycles
    def related_resources(resource, result = [])
      if resource.respond_to?(:related_resources)
        Array(resource.related_resources).each do |related_resource|
          unless result.include?(related_resource)
            result << related_resource
            related_resources(related_resource, result)
          end
        end
      end
      return result
    end
  end

end
