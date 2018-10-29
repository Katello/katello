totals = @object.relation.group(:errata_type).count.with_indifferent_access

node :security do |_presenter|
  totals[:security]
end

node :bugfix do |_presenter|
  totals[:bugfix]
end

node :enhancement do |_presenter|
  totals[:enhancement]
end

node :total do |_presenter|
  totals.values.inject(:+)
end
