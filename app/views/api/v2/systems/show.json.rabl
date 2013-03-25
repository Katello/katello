object @system

attributes :id, :uuid, :location, :servicelevel, :content_view_id 
attributes :environment_id, :description
attributes :name, :release, :releaseVer, :ipv4_address
attributes :activation_key, :href, :system_template_id, :autoheal
# TODO needs investigation whether it is safe to remove
attributes :facts, :idCert, :environment, :owner

extends 'api/v2/common/timestamps'