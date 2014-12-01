extends("katello/api/v2/errata/show")

node :available do |e|
  @available_errata_ids.include?(e.id) if @available_errata_ids
end
