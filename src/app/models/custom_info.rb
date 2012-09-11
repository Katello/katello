class CustomInfo < ActiveRecord::Base
  attr_accessible :keyname, :value

  belongs_to :informable, :polymorphic => true

  validates :keyname, :presence => true
  validates :value, :presence => true
  validates_uniqueness_of :keyname, :scope => [:value], :message => "and Value combination must be unique"

  validates :informable_id, :presence => true
  validates :informable_type, :presence => true
end
