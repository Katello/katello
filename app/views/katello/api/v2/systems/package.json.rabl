attributes :vendor, :arch, :epoch, :version, :release, :name

node :nvrea do |pkg|
  pkg.nvrea
end
