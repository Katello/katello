node do
  if @object_root
    { @object_root => partial("katello/api/v2/#{@resource_name}/#{@action}",
                              :object => Katello::Util::Data.ostructize(@resource)) }
  else
    partial("katello/api/v2/#{@resource_name}/#{@action}", :object => Katello::Util::Data.ostructize(@resource))
  end
end
