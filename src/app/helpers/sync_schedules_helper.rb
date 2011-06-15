module SyncSchedulesHelper


  def hover_format item
    case item.interval
      when 'daily'
        _("Daily at #{item.plan_time} from #{item.plan_date} #{item.plan_zone}")
      when 'weekly'
        _("Every #{plan_day} at #{item.plan_time} from #{item.plan_date} #{item.plan_zone}")
      else
        _("Hourly from #{item.plan_date} - #{item.plan_time} #{item.plan_zone}")
    end
  end

end
