node :security do |presenter|
  presenter.relation.security.count
end

node :bugfix do |presenter|
  presenter.relation.bugfix.count
end

node :enhancement do |presenter|
  presenter.relation.enhancement.count
end

node :total do |presenter|
  presenter.relation.count
end
