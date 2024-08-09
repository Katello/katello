# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# !!! PLEASE KEEP THIS SCRIPT IDEMPOTENT !!!
#

User.as_anonymous_admin do
  Bookmark.without_auditing do
    bookmarks = [
      {:name => "Without a Tag", :query => 'not has tag', :controller => "katello_docker_manifests"},
    ]

    bookmarks.each do |input|
      next if SeedHelper.audit_modified? Bookmark, input[:name], :controller => input[:controller]
      b = Bookmark.find_or_create_by({ :public => true }.merge(input))
      fail "Unable to create bookmark: #{format_errors b}" if b.nil? || b.errors.any?
    end
  end
end
