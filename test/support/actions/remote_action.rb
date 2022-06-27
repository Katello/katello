module Support
  module Actions
    module RemoteAction
      def stub_remote_user(admin = false)
        if admin
          User.current = users(:admin)
        else
          User.current = users(:one)
        end
      end
    end
  end
end
