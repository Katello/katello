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

  def dashboard_entry name, partial, dropbutton
    render :partial=>"entry", :locals=>{:name=>name, :partial=>partial, :dropbutton=>dropbutton}
  end

  def dashboard_ajax_entry name, identifier, url, class_wrapper, dropbutton, quantity=5
    render :partial=>"ajax_entry", :locals=>{:name=>name, :url=>url, :class_wrap=>class_wrapper, :identifier=>identifier, :dropbutton=>dropbutton, :quantity=>quantity}
  end

  def user_notices num=quantity
    trim_length = 45
    current_user.notices.order("created_at DESC").limit(num).collect{|note|
      if note.text.length > trim_length + 3
        text = note.text[0..trim_length] + '...'
      else
        text =note.text
      end
      {:text=>text, :level=>note.level, :date=>note.created_at}
    }
  end

  def promotions num=quantity
    return  Changeset.joins(:task_status).
        where("changesets.environment_id"=>KTEnvironment.changesets_readable(current_organization)).
        order("task_statuses.updated_at DESC").limit(num)
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
    elsif cs.state == Changeset::FAILED
      _("Failed")
    else
      _("Pending")
    end        
  end

  def systems_list num=quantity
    System.readable(current_organization).limit(num)
  end

  def system_groups_list
    groups_hash = {}
    groups = SystemGroup.readable(current_organization)

    # determine the state (critical/warning/ok) for each system group
    #   - critical: indicates there is 1 or more security errata
    #   - warning: indicates that there is 1 or more non-security errata
    #   - ok: indicates that all systems in the group are up to date
    groups.each do |group|
      group_state = :ok

      group.systems.each do |system|
        system.errata.each do |erratum|
          case erratum.type
            when Glue::Pulp::Errata::SECURITY
              # there is a critical errata, so stop searching...
              group_state = :critical
              break

            when Glue::Pulp::Errata::BUGZILLA
            when Glue::Pulp::Errata::ENHANCEMENT
              # set state to warning, but continue searching...
              group_state = :warning
          end
        end
        break if group_state == :critical
      end

      groups_hash[group_state] ||= []
      groups_hash[group_state] << group
    end
    return groups_hash[:critical].to_a, groups_hash[:warning].to_a, groups_hash[:ok].to_a
  end

  def changeset_path_helper cs
      if cs.state === Changeset::PROMOTED
        changesets_path() + "#panel=changeset_#{cs.id}"
      else
        promotion_path(cs.environment.prior.name)
      end
  end

  def products_synced num=quantity
    syncing_products = []
    synced_products = []

    Product.readable(current_organization).each{ |prod|
      if !prod.sync_status.start_time.nil?
        syncing_products << prod
      else
        synced_products << prod
      end
    }
    
    syncing_products.sort{|a,b|
      a.sync_status.start_time <=> b.sync_status.start_time
    }

    return (syncing_products + synced_products)[0..num]

  end

  def sync_percentage(product)
    stat =product.sync_status.progress
    return 0 if stat.total_size == 0
    "%.0f" % ((stat.total_size - stat.size_left)*100/stat.total_size).to_s
  end

  def subscription_counts
    info = Glue::Candlepin::OwnerInfo.new(current_organization)
  end

  def errata_type_class errata
    case errata.type
      when  Glue::Pulp::Errata::SECURITY
        return "security_icon"
      when  Glue::Pulp::Errata::ENHANCEMENT
        return "enhancement_icon"
      when  Glue::Pulp::Errata::BUGZILLA
        return "bugzilla_icon"
    end
  end

  def errata_product_names errata, repos
    # return a comma-separated list of product names that this errata is associated with

    # the list will be determined by evaluating the repoids in the errata against the products
    # associated with the list of repos provided
    products = ""
    errata.repoids.each do |repoid|
      repos.each do |repo|
        if repo.pulp_id == repoid
          if products.length == 0
            products = repo.environment_product.product.name
          else
            products += ", " + repo.environment_product.product.name
          end
          break
        end
      end
    end
    products
  end

  def system_path_helper system
    systems_path + "#panel=system_" + system.id.to_s
  end

  def get_checkin(system)
    if system.checkinTime
      return  format_time system.checkinTime
    end
    _("Never checked in.")
  end
end
