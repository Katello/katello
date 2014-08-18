object Katello::Util::Data::ostructize(@collection)

extends("katello/api/v2/common/metadata")

child :results => :results do
  child :environments => :environments do
    extends('katello/api/v2/environments/show')
  end
end
