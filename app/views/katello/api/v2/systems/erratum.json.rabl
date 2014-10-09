attributes :title, :version, :description, :status, :id, :errata_id
attributes :reboot_suggested, :updated, :issued, :release, :solution

node :packages do |e|
  e.packages.pluck(:nvrea).sort
end

attributes :errata_type => :type
