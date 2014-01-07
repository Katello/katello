object false

extends "katello/api/v2/common/metadata"

child @collection[:records] => :results do
  extends('katello/api/v2/systems/package')
end
