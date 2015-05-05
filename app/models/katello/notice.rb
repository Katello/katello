module Katello
  class Notice < Katello::Model
    self.include_root_in_json = false

    include Glue::ElasticSearch::Notice if Katello.config.use_elasticsearch

    has_many :user_notices, :class_name => "Katello::UserNotice", :dependent => :destroy
    has_many :users, :through => :user_notices, :class_name => "::User"
    belongs_to :organization, :class_name => "Organization", :inverse_of => :notices

    TYPES = [:message, :warning, :success, :error]

    validates_lengths_from_database
    validates :level, :inclusion => {:in => TYPES + TYPES.collect { |type| type.to_s }}
    validates :text, :presence => true, :length => {:maximum => 1024}
    validates :user_notices, :length => {:minimum => 1}
    validates :level, :length => {:maximum => 255}
    validates :request_type, :length => {:maximum => 255}

    before_validation :set_default_notice_level
    before_validation :trim_text
    before_save :add_to_all_users

    scope :readable, lambda { |user| joins(:users).where('users.id' => user) }

    def self.for_org(organization = nil)
      if organization
        where("#{Katello::Notice.table_name}.organization_id = :org_id OR #{Katello::Notice.table_name}.organization_id IS NULL", :org_id => organization.id)
      else
        scoped
      end
    end

    def self.for_user(user)
      includes(:user_notices).where(:katello_user_notices => { :user_id => user.id })
    end

    def self.viewed(viewed)
      includes(:user_notices).where(:katello_user_notices => { :viewed => viewed })
    end

    scope :read, lambda { viewed true }
    scope :unread, lambda { viewed false }

    def to_s
      "#{level}: #{text}"
    end

    private

    def add_to_all_users
      if global
        self.users = User.all
      end
    end

    def set_default_notice_level
      self.level ||= TYPES.first
    end

    def trim_text
      self.text = "#{self.text[0, 1020]} ..." if self.text.size > 1024
    end
  end
end
