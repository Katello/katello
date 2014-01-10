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

module Katello
class Changeset < Katello::Model
  self.include_root_in_json = false

  include AsyncOrchestration
  include Glue::ElasticSearch::Changeset  if Katello.config.use_elasticsearch

  NEW       = 'new'
  REVIEW    = 'review'
  PROMOTED  = 'promoted'
  PROMOTING = 'promoting'
  DELETING = 'deleting'
  DELETED  = 'deleted'
  FAILED    = 'failed'
  STATES    = [NEW, REVIEW, PROMOTING, PROMOTED, FAILED, DELETING, DELETED]

  PROMOTION = 'promotion'
  DELETION  = 'deletion'
  TYPES     = [PROMOTION, DELETION]

  validates :name, :presence => true, :allow_blank => true,
                   :uniqueness => {:scope => :environment_id,
                                   :message => N_("Label has already been taken")}
  validates :environment, :presence => true
  validates :state, :inclusion => {:in          => STATES,
                                   :allow_blank => false,
                                   :message     => <<-EOS}
        A changeset must have one of the following states: #{STATES.join(', ')}
      EOS
  validates_with Validators::KatelloDescriptionFormatValidator, :attributes => :description
  validates_with Validators::NotInLibraryValidator
  validates_with Validators::KatelloNameFormatValidator, :attributes => :name

  has_many :users, :class_name => "Katello::ChangesetUser", :inverse_of => :changeset, :dependent => :destroy
  belongs_to :environment, :class_name => "Katello::KTEnvironment", :inverse_of => :changesets
  belongs_to :task_status, :inverse_of => :changeset
  has_many :changeset_content_views, :class_name => "Katello::ChangesetContentView", :dependent => :destroy
  has_many :content_views, :through => :changeset_content_views, :class_name => "Katello::ContentView"

  # find changesets in given state/states
  scope :with_state, lambda { |*states| where(:state => states.map(&:to_s)) }
  # first thing after start is that progress is set to 0 so we can easily detect already started
  scope :started, with_state(PROMOTING, DELETING)

  # find colliding changesets which are those having target same as to.start or start same se
  # to.target or same start and target, others should be safe, ignoring self of course
  def self.colliding(to)
    start  = to.environment.prior.id
    target = to.environment.id
    joins(:environment => :priors).
        where(['"katello_changesets"."id" <> ? AND (' <<
                   '"katello_environments"."id" = ? OR "katello_environment_priors"."prior_id" = ? OR ' <<
                   '("katello_environments"."id" = ? AND "katello_environment_priors"."prior_id" = ?))',
               to.id, start, target, target, start])
  end

  def self.new_changeset(args)
    return self.changeset_class(args).new(args)
  end

  def self.changeset_class(args)
    fail "Must provide a changeset type." unless type = args.try(:[], :type)
    type.downcase!

    if type == PROMOTION
      return PromotionChangeset
    elsif type == DELETION
      return DeletionChangeset
    else
      fail _("Unknown changeset type. Choose one of: %s") % TYPES.join(", ")
    end
  end

  def key_for(item)
    "changeset_#{id}_#{item}"
  end

  # returns list of virtual permission tags for the current user
  def self.list_tags
    select('id,name').all.collect { |m| VirtualTag.new(m.id, m.name) }
  end

  def action_type
    return PROMOTION if promotion?
    DELETION
  end

  def deletion?
    self.class == DeletionChangeset
  end

  def promotion?
    self.class == PromotionChangeset
  end

  def in_review?
    self.state == REVIEW
  end

  def check_review_state!
    if !in_review?
      fail _("Cannot apply the changeset '%s' because it is not in the review phase.") % self.name
    end
  end

  def check_collisions!
    if (collision = Changeset.started.colliding(self).first)
      fail _("Cannot apply the changeset '%{changeset}' while another colliding changeset (%{another_changeset}) is being applied.") %
                { :changeset => self.name, :another_changeset => collision.name }
    end
  end

  def self.create_for(acct_type, options)
    if PROMOTION == acct_type
      PromotionChangeset.create!(options)
    else
      DeletionChangeset.create!(options)
    end
  end

  def add_content_view!(view, include_components = false)
    unless env_to_verify_on_add_content.content_views.include?(view)
      fail Errors::ChangesetContentException.new(_("Content view not found within environment you want to promote from."))
    end
    if promotion? && content_view_in_environment?(view)
      fail Errors::ChangesetContentException.new(
        _("Cannot add content view '%{view}' to changeset. View version already in environment '%{env}'.") %
        {:view => view.name, :env => environment.name})
    end

    self.content_views << view

    if include_components && type == "PromotionChangeset" && view.composite
      # This is a composite view and the caller would like to also add any component
      # views that also need to be promoted to the target environment.
      component_views = view.components_not_in_env(self.environment).
          promotable(self.environment.organization) - self.content_views

      component_views.each{ |component| self.content_views << component } unless component_views.blank?
    end

    save!
    return view, component_views
  end

  def remove_content_view!(view)
    deleted = self.content_views.delete(view)
    save!
    return deleted
  end

  def as_json(options = nil)
    options ||= {}
    super(options.merge(
          :methods => [:action_type]
          )
       )
  end

  protected

  def validate_content!(elements)
    elements.each { |e| fail ActiveRecord::RecordInvalid.new(e) if !e.valid? }
  end

  def validate_content_view_tasks_complete!
    # if the user is attempting to apply a view that is currently being
    # published/refreshed or a view that has a component view that is
    # currently being published/refreshed, stop the 'apply'
    from_env = self.environment.prior
    self.content_views.each do |view|
      version = view.version(from_env)
      if version.try(:task_status).try(:pending?)
        fail Errors::ContentViewTaskInProgress.new(_("A '%{type_of_action}' action is currently in progress for  "\
                                                      "content view '%{content_view}'.  Please retry the changeset "\
                                                      "after the action completes.") %
                                                      { :type_of_action => _(TaskStatus::TYPES[version.task_status.task_type][:english_name]),
                                                        :content_view => view.name })
      elsif view.composite
        view.content_view_definition.component_content_views.each do |component_view|
          version = component_view.version(from_env)
          if version.task_status.pending?
            fail Errors::ContentViewTaskInProgress.new(_("A '%{type_of_action}' action is currently in progress for "\
                                                          "component content view '%{content_view}'.  Please retry "\
                                                          "the changeset after the action completes.") %
                                                          { :type_of_action => _(TaskStatus::TYPES[version.task_status.task_type][:english_name]),
                                                            :content_view => view.name })
          end
        end
      end
    end
  end

  def env_to_verify_on_add_content
    if promotion?
      self.environment.prior
    else
      self.environment
    end
  end

  def content_view_in_environment?(view)
    (cvv = environment.content_view_versions.find_by_content_view_id(view)) &&
      (prior_cvv = environment.prior.content_view_versions.find_by_content_view_id(view)) &&
      cvv == prior_cvv
  end

  def update_progress!(percent)
    if self.task_status
      self.task_status.progress = percent
      self.task_status.save!
    end
  end

end
end
