extends("katello/api/v2/errata/show")

node :installable do |e|
  @installable_errata_ids.include?(e.id) if @installable_errata_ids
end
