require File.expand_path('../plugin.rb', __FILE__)

# Example of how to define a security block of permissions for an entity:
#
#   Foreman::Plugin.find(:katello).security_block :activation_keys do
#     permission :view_activation_keys,
#             {
#               :'katello/activation_keys' => [:all, :index],
#               :'katello/api/v2/activation_keys' => [:index, :show]
#             }, :resource_type => 'Katello::ActivationKey'
#     permission :create_activation_keys,
#             {
#               :'katello/api/v2/activation_keys' => [:create],
#                   }, :resource_type => 'Katello::ActivationKey'
#     permission :update_activation_keys,
#             {
#               :'katello/api/v2/activation_keys' => [:update],
#             }, :resource_type => 'Katello::ActivationKey'
#     permission :destroy_activation_keys,
#             {
#               :'katello/api/v2/activation_keys' => [:destroy],
#             }, :resource_type => 'Katello::ActivationKey'
#   end
