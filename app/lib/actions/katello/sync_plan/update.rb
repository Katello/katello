##DEAD CODE
# module Actions
#   module Katello
#     module SyncPlan
#       class Update < Actions::EntryAction
#         def plan(sync_plan, sync_plan_params = nil)
#           action_subject(sync_plan)
#           rec_logic_change = sync_plan.sync_date != sync_plan_params["sync_date"] || sync_plan.interval != sync_plan_params["interval"] ||
#               sync_plan.enabled != sync_plan_params["enabled"]
#           sync_date = sync_plan_params.try(:[], "sync_date").try(:to_time)
#           fail _("Sync Date is probably null" + sync_date.to_s) if sync_date.nil?
#           sync_plan.update_attributes(sync_plan_params) if sync_plan_params
#
#           if rec_logic_change
#             recurring_logic = add_recurring_logic_to_sync_plan(sync_date, sync_plan_params[:interval])
#             sync_plan.recurring_logic_id = recurring_logic.id
#             recurring_logic.start_after(::Actions::Katello::SyncPlan::Run, sync_plan_params[:sync_date].to_time, sync_plan)
#           end
#           sync_plan.save!
#           plan_self
#         end
#
#         def humanized_name
#           _("Update Sync Plan")
#         end
#
#         def add_recurring_logic_to_sync_plan(sync_date, interval)
#           sync_date_local_zone = sync_date.in_time_zone(Time.now.getlocal.zone)
#           min, hour, day = sync_date_local_zone.min, sync_date_local_zone.hour, sync_date_local_zone.wday
#           if (interval.downcase.eql? "hourly")
#             cron = min.to_s + " * * * *"
#           elsif (interval.downcase.eql? "daily")
#             cron = min.to_s + " " + hour.to_s + " * * *"
#           elsif (interval.downcase.eql? "weekly")
#             cron = min.to_s + " " + hour.to_s + " * * " + day.to_s
#           else
#             fail _("Error saving recurring logic : Interval not set correctly")
#           end
#           recurring_logic = ForemanTasks::RecurringLogic.new_from_cronline(cron)
#           if recurring_logic.save!
#             return recurring_logic
#           end
#           fail _("Error saving recurring logic")
#         end
#       end
#     end
#   end
# end
