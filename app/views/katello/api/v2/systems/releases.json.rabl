object false

extends "katello/api/v2/common/metadata"

child @collection[:results] => :results do
  @collection[:releases].map do |release|
    release
  end
end
