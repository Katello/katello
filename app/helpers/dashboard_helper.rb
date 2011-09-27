#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module DashboardHelper

  def dashboard_entry name, partial
    render :partial=>"entry", :locals=>{:name=>name, :partial=>partial}
  end

  def dashboard_ajax_entry name, identifier, url, class_wrapper
    render :partial=>"ajax_entry", :locals=>{:name=>name, :url=>url, :class_wrap=>class_wrapper, :identifier=>identifier}
  end

  def user_notices
    trim_length = 45
    current_user.notices.order("created_at DESC").limit(10).collect{|note|
      if note.text.length > trim_length + 3
        text = note.text[0..trim_length] + '...'
      else
        text =note.text
      end
      {:text=>text, :level=>note.level, :date=>note.created_at}
    }
  end

  def promotions
    return  Changeset.joins(:task_status).
        where("changesets.environment_id"=>KTEnvironment.changesets_readable(current_organization)).
        order("task_statuses.updated_at DESC").limit(5)
  end

  def changeset_class cs
    if cs.state === Changeset::PROMOTED
      "check_icon"
    elsif cs.state === Changeset::PROMOTING && cs.task_status.start_time
      "gear_icon"  #running
    else
      "clock_icon" #pending
    end
  end

  def changeset_message cs
    if cs.state === Changeset::PROMOTED
      _("Success")
    elsif cs.state === Changeset::PROMOTING && cs.task_status.start_time
      _("Promoting")
    else
      _("Pending")
    end        
  end


  def systems_list
    System.readable(current_organization).limit(10)
  end

  def changeset_path_helper cs
      if cs.state === Changeset::PROMOTED
        changesets_path() + "#panel=changeset_#{cs.id}"
      else
        promotion_path(cs.environment.prior.name)
      end
  end

  def products_synced
    Product.readable(current_organization).reject{|prod|
      prod.sync_status.uuid.nil?
    }.sort{|a,b| a.start_time <=> b.start_time}[0..10]
  end

  def sync_percentage(product)
    stat =product.sync_status.progress
    (stat.total_size - stat.size_left)*100/stat.total_size
  end


  def subscription_counts
    info = Glue::Candlepin::OwnerInfo.new(current_organization)

  end

  #TODO Make this not be fake data
  def errata_summary
    types = [Glue::Pulp::Errata::SECURITY, Glue::Pulp::Errata::ENHANCEMENT, Glue::Pulp::Errata::BUGZILLA]

    to_ret = []
    (rand(5) + 5).times{|num|
      errata = OpenStruct.new
      errata.e_id = "RHSA-2011-01-#{num}"
      errata.systems = ([1]*(rand(10) + 1)).collect{|i| "server-" + rand(10).to_s + ".example.com"}
      errata.e_type = types[rand(3)]
      errata.product = "Red Hat Enterprise Linux 6.0"
      to_ret << errata
    }
    to_ret
  end

  def errata_type_class errata
    case errata.e_type
      when  Glue::Pulp::Errata::SECURITY
        return "security_icon"
      when  Glue::Pulp::Errata::ENHANCEMENT
        return "enhancement_icon"
      when  Glue::Pulp::Errata::BUGZILLA
        return "bugzilla_icon"
    end
  end

end
