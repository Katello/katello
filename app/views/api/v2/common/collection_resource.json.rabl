node do
  { @root_name => partial("api/v2/#{@resource_name}/#{@action}", :object => Util::Data::ostructize(@collection)) }
end
