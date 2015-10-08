object @resource

extends 'katello/api/v2/puppet_modules/base'
extends 'katello/api/v2/puppet_modules/backend', :object => Katello::Pulp::PuppetModule.new(@resource.uuid)
