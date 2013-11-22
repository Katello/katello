node do
  { @root_name => partial("katello/api/v2/#{@resource_name}/#{@action}", :object => Katello::Util::Data::ostructize(@resource)) }
end
