attributes :title, :version, :description, :status, :id, :errata_id
attributes :reboot_suggested, :updated, :issued, :release, :solution

node :packages do |e|
  e.included_packages.collect{ |pkg| pkg.nvrea }.sort
end

attributes :type
