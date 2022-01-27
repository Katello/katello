namespace :katello do
  desc <<-DESCRIPTION
  Marks a content view import only or otherwise. Only 'import_only' Content Views can import content via import/export process.
  Options:
    ID - ID of the content view that will be marked import
    VALUE - If true the provided content view will be marked as import_only. This is the default.
            If false the import_only flag of provided content view will be reset.
  DESCRIPTION

  task :set_content_view_import_only => ["environment"] do
    def fetch_content_view
      if ENV['ID'].blank?
        fail 'Content view `ID` required.'
      end
      ::Katello::ContentView.find_by(id: ENV['ID'])
    end

    def mark_import_only(value: true)
      User.current = User.anonymous_admin
      content_view = fetch_content_view
      fail('Composite content views cannot be marked import_only. Check the content view id.') if content_view.composite?
      fail('Default Organization View cannot be marked import_only. Check the content view id.') if content_view.default?
      content_view.import_only = value
      if content_view.save(validate: false)
        $stdout.print("Content View '#{content_view.name}'s import_only value updated to #{content_view.import_only} ")
      else
        $stderr.print("Unable to set the content view import_only to #{value}. Check the content view id.")
        $stderr.print(content_view.errors.inspect)
      end
    end
    value = ENV['VALUE'].blank? || ::Foreman::Cast.to_bool(ENV['VALUE'])
    mark_import_only(value: value)
  end
end
