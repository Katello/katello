class ChangeChangeContentSourceJobTemplateName < ActiveRecord::Migration[6.1]
  TEMPLATE_NAMES = {
    "Change content source" => "Configure host for new content source",
  }.freeze

  def up
    TEMPLATE_NAMES.each do |from, to|
      token = SecureRandom.base64(5)
      ::Template.unscoped.find_by(name: to)&.update_columns(:name => "#{to} Backup #{token}")
      ::Template.unscoped.find_by(name: from)&.update_columns(:name => to)
    end
  end

  def down
    TEMPLATE_NAMES.each do |from, to|
      ::Template.unscoped.find_by(name: from)&.delete
      ::Template.unscoped.find_by(name: to)&.update_columns(:name => from)
    end
  end
end
