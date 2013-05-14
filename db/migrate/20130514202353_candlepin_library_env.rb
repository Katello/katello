class CandlepinLibraryEnv < ActiveRecord::Migration
  def up
    User.current = User.hidden.first
    Organization.all.each do |org|
      if org.default_content_view.content_view_environments.select{|cve| cve.environment.library?}.empty?
        org.default_content_view.add_environment(org.library)
      end
    end
  end

  def down
  end
end
