object false

extends "katello/api/v2/common/metadata"

child @collection[:results] => :results do
  extends 'katello/api/v2/errata/show'
  node :comparison do |erratum|
    erratum.comparison
  end
end
