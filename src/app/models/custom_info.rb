class CustomInfo < ActiveRecord::Base
  acts_as_reportable

  attr_accessible :keyname, :value

  belongs_to :informable, :polymorphic => true

  validates :keyname, :presence => true
  validates_uniqueness_of :keyname, :scope => [:value, :informable_type, :informable_id], :message => "already exists for this object"

  validates :informable_id, :presence => true
  validates :informable_type, :presence => true
end
