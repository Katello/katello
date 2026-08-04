object @hostgroup
extends 'api/v2/hostgroups/show'
node(:content_source_id) { |hg| hg.content_source_id || hg.inherited_content_source_id }
node(:content_source_name) { |hg| hg.content_source&.name }
node(:content_view_id) { |hg| hg.content_view_id || hg.inherited_content_view_id }
node(:content_view_name) { |hg| hg.content_view&.name }
node(:lifecycle_environment_id) { |hg| hg.lifecycle_environment_id || hg.inherited_lifecycle_environment_id }
node(:lifecycle_environment_name) { |hg| hg.lifecycle_environment&.name }
node(:content_view_environment_id) { |hg| hg.content_view_environment_id || hg.inherited_content_view_environment_id }
node(:kickstart_repository_id) { |hg| hg.kickstart_repository_id || hg.inherited_kickstart_repository_id }
node(:kickstart_repository_name) { |hg| hg.kickstart_repository&.name }
