object Katello::Util::Data.ostructize(@resource)

attribute :status
child :services => :services do
  attributes :elasticsearch, :katello_jobs, :foreman_auth, :candlepin, :candlepin_auth, :pulp, :pulp_auth
end
