module UserHelperMethods
  def new_user name = "foo"
    disable_user_orchestration
    User.create!(:username => name, :password => "redhat", :email =>"foo12@redhat.com")
  end
end