node :readonly do |resource|
  !resource.editable?
end
