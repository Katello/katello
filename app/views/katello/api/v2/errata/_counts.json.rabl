totals = @object.relation.group(:errata_type).count.with_indifferent_access

node :security do |_presenter|
  totals[:security].to_i
end

node :bugfix do |_presenter|
  totals[:bugfix].to_i + totals[:recommended].to_i
end

node :enhancement do |_presenter|
  totals[:enhancement].to_i + totals[:optional].to_i
end

node :total do |_presenter|
  totals.values.inject(:+).to_i
end
