module Katello
  class OstreeBranch < Katello::Model
    belongs_to :repository, :class_name => "Katello::Repository", :inverse_of => :ostree_branches
    validates :name, presence: true, uniqueness: {scope: :repository_id}
    validates :repository, :presence => true
    validate :ensure_ostree_repository

    def ensure_ostree_repository
      unless self.repository.ostree?
        errors.add(:base, _("Branch cannot be created since it does not belong to an RPM OSTree repository."))
      end
    end
  end
end
