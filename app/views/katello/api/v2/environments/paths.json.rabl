collection Katello::Util::Data::ostructize(@collection)

child :path, :root => :path do
  node :environment do |env|
    partial('katello/api/v2/environments/show', :object => env)
  end
end

node :permissions do |env|
  {
    :readonly => !@organization.environments_manageable?
  }
end
