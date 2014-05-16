collection Katello::Util::Data::ostructize(@collection)

child :environments => :environments do
  extends('katello/api/v2/environments/show')
end

node :permissions do |env|
  {
    :creatable => Katello::KTEnvironment.creatable?
  }
end
