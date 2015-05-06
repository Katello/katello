# used for sending notifications form ActiveRecord models
# @example
#   Notify.success a_message
Katello::Notify = Katello::Notifications::Notifier.new
