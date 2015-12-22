object Katello::Util::Data.ostructize(@resource)

attribute :status
child :services => :services do
  [:foreman_tasks, :foreman_auth, :candlepin, :candlepin_auth, :pulp, :pulp_auth].each do |service|
    child service => service do
      attribute :status
      attribute :duration_ms
    end
  end
end
