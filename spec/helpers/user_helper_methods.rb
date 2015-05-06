module UserHelperMethods
  def new_user(name = "foo")
    disable_user_orchestration
    User.create!(:login => name, :password => "redhat", :mail => "foo12@redhat.com")
  end
end
