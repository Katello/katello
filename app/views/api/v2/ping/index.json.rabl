object Util::Data::ostructize(@resource) => :ping

attributes :result
child :status => :services do
  attributes :elasticsearch
  attributes :katello_jobs
  attributes :foreman_auth
  attributes :candlepin, :candlepin_auth
  attributes :pulp, :pulp_auth
end
