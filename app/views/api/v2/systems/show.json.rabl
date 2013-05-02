object @system

attributes :id, :uuid, :location, :servicelevel, :content_view_id 
attributes :environment_id, :description
attributes :name, :release, :ipv4_address
attributes :activation_key, :href, :system_template_id, :autoheal
# TODO needs investigation whether it is safe to remove
attributes :facts

node :releaseVer do |sys|
  sys.releaseVer[:releaseVer]
end

child Util::Data::ostructize(@resource.idCert) => :idCert do
  attributes :id, :key, :cert
  attributes :created, :updated
  child :serial => :serial do
  	attributes :id, :revoked, :collected, :serial, :expiration
    attributes :created, :updated
  end 
end

child Util::Data::ostructize(@resource.owner) => :owner do
  attributes :id, :key, :displayName, :href
end

child :environment => :environment do
  extends 'api/v2/environments/show'
end

extends 'api/v2/common/timestamps'