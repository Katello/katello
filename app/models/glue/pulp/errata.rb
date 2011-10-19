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

require_dependency "resources/pulp"
require 'set'

class Glue::Pulp::Errata

  SECURITY = "security"
  BUGZILLA = "bugzilla"
  ENHANCEMENT = "enhancement"


  attr_accessor :id, :title, :description, :version, :release, :type, :status, :updated,  :issued, :from_str, :reboot_suggested, :references, :pkglist

  def initialize(params = {})
    params.each_pair {|k,v| instance_variable_set("@#{k}", v) unless v.nil? }
  end

  def self.find(id)
    Glue::Pulp::Errata.new(Pulp::Errata.find(id))
  end

  def self.filter(filter)
    errata = []
    filter_for_repo = filter.slice(:repoid, :environment_id, :product_id)
    filter_for_errata = filter.except(*filter_for_repo.keys)

    repos = repos_for_filter(filter_for_repo)
    repos.each {|repo| errata.concat(Pulp::Repository.errata(repo.id, filter_for_errata)) }
    errata
  end

  def self.repos_for_filter(filter)
    if repoid = filter[:repoid]
      return [Glue::Pulp::Repo.new(:id => repoid)]
    elsif environment_id = filter[:environment_id]
      env = KTEnvironment.find(environment_id)
      if product_id = filter[:product_id]
        products = [::Product.find_by_cp_id!(product_id)]
      else
        products = env.products
      end
      return products.map {|p| p.repos(env) }.flatten
    else
      raise "Not enough arguments for finding repos"
    end
  end

#   def self.find id
#     case (id.to_i % 4).to_s 
#     when "0"
#       Glue::Pulp::Errata.new({:id => id, :title => "RHBA-2011:#{ "%04d" % id}", :description=>"The device-mapper-multipath package provides tools to manage multipath devices using the device-mapper multipath kernel module.\n\nThe advisory text was updated on the 27th of April, 2011 with the following bug description:\n\n* Installing the device-mapper-multipath RPM package could have caused the default installed /etc/kpartx.conf configuration file to be modified. As a consequence, verifying the package with the 'rpm -V' failed due to the /etc/kpartx.conf file's size, md5sum, and last modification time having been changed. This update adds flags to the device-mapper-multipath package's spec file that inform rpm that the size, md5sum and modification time of the /etc/kpartx.conf file may change, with the result that verifying the package now succeeds in this situation. (BZ#588753)\n\nThe advisory text was updated on the 27th of April, 2011 with the following two workaround descriptions:\n\n* When the /var directory was mounted on a separate file system from the root directory ('/'), the association between mpath[n] device names and device WWIDs could have been become inconsistent. As a workaround, a bindings_file configuration option now provides a consistent mapping between mpath[n] and WWID device names. Refer to the Release Notes link provided in the References section of this erratum for further details. (BZ#509095)\n\n* Multipath is unable to reconfigure a multipath device while the multipathd service is running, or add new paths to the device. A workaround for this issue is provided in the 4.9 Release Notes, which are linked to in the References section of this advisory. (BZ#487443)\n\n[The original advisory text follows]\n\nThis update provides fixes for the following bugs:\n\n* The direction path checker occasionally dropped paths due to a too short limit for the IO. The direction checker now waits asychronously for the IO with a 30 second limit per path. (BZ#500580)\n\n* When gathering path information, multipath did not wait long enough for some sysfs files to be created. This caused it to not create some devices. It will now wait up to a minute, unless it notices that the sysfs device directory has been removed, in which case it exits early. (BZ#511034)\n\n* Multipath gave incorrect path groupings for multipath devices configured to use 'group_by_node_name'. This was due to an incorrect reporting of the target node name for iSCSI (Internet Small Computer System Interface) targets. With this update multipath checks the iSCSI target name if the fc check fails. (BZ#512065)\n\n* Multipath could have occasionally consumed a large amount of memory. This was caused by improper setting of thread size. With this update, the thread size setting is adjusted and the issue no longer occurs. (BZ#516253)\n\n* Previously, kpartx could have made incorrect partitions for devices with minor numbers greater than 255. This happened due to a mistake in calculation of minor number of devices. This update fixes the calculation procedure and the issue is fixed. (BZ#528734)\n\n* Multipathd occasionally used an incorrect UID/GID/MODE setting for the devices it created, if these were defined in multipath.conf. This was due to a race between udevd and multipathd. With this update, the issue no longer occurs. (BZ#531131)\n\n* If a multipath device configured with queue_if_no_path with no working paths was created while booting, and multipathd was not running, the machine did not boot. init scripts must call multipath with the -q option that forces multipath to disable queuing on all devices. (BZ#575244)\n\nIn addition, this updated package provides the following enhancements:\n\n* The multipath.conf file contains a new option 'queue_without_daemon' with the 'yes' default setting. If set to 'no', multipathd disables queue_if_no_paths on all devices. (BZ#488921)\n\n* A default configuration for HP HSVX700 is added. (BZ#623468)\n\nAll device-mapper-multipath users are advised to upgrade to this updated package, which resolves these issues and adds these enhancements.",
#         :type=>"Bugfix", :issued=>"1/2/2011", :updated=>"1/5/2011", :references=>[], :pkglist => ["device-mapper-multipath-0.4.5-42.el6.i386", "device-mapper-multipath-0.4.5-42.el6.x86_64"]})      
#     when "1"
#       Glue::Pulp::Errata.new({:id => id, :title => "RHBA-2011:#{ "%04d" % id}", :description=>"The Cluster Manager (cman) utility provides user-level services for managing a Linux cluster.\n\nThis update fixes the following bug:\n\n* Previous versions of the ccs_tool utility did not allow users to specify the port numbers to use when distributing the configuration. Consequent to this, changing the port numbers for Cluster Manager components rendered this utility unable to establish a connection with a cluster. With this update, the ccs_tool utility now allows users to specify the port numbers on the command line, so that the connection can be established as expected. (BZ#677814)\n\nAll users of cman are advised to upgrade to this updated package, which fixes this bug.",
#         :type=>"Bugfix", :issued=>"4/28/11", :updated=>"4/28/11", :references=>[], :pkglist => ["cman-devel-2.0.115-68.el6_6.3.i386", "cman-devel-2.0.115-68.el5_6.3.x86_64"]})      
#     when "2"
#       Glue::Pulp::Errata.new({:id => id, :title => "RHBA-2011:#{ "%04d" % id}", :description=>"The finger utility allows users to display information about the system users, including their login names, full names, and the time they logged in to the system.\n\n The update fixes the following bug:\n\n* When the finger utility is run with no additional command line options, itprovides output in the form of a table. Prior to this update, this tabular output did not include a separate column for information about a host, and this information was incorrectly displayed in the Office column. This update adds a new column named Host, so that the host information no longer appears in the wrong column. (BZ#563291)\n\nAll users of finger are advised to upgrade to these updated packages, which fix this bug.",
#         :type=>"Bugfix", :issued=>"4/27/11", :updated=>"4/27/11", :references=>[], :pkglist => ["finger-0.17-33.i386", "finger-0.17-33.x86_64"]})      
#     else
#       Glue::Pulp::Errata.new({:id => id, :title => "RHBA-2011:#{ "%04d" % id}", :description=>"The traceroute utility displays the route used by IP packets on their way to a specified network (or Internet) host. Traceroute displays the IP address and hostname (if possible) of the machines along the route taken by the packets.\n\nThis update fixes the following bugs:\n\n* Prior to this update, using the '-m' command line option to specify the\nmaximum time-to-live (TTL) value in the range 1 to 5 caused the traceroute\nutility to fail with the following error:\n\nsim hops out of range\n\nThis update applies an upstream patch to ensure that all TTL values in the range from 1 to 255 are supported as expected. (BZ#461278)\n\n* Previously, using the '-l' command line option to specify the flow label of the probing packets caused the utility to fail with the following error:\n\nsetsockopt IPV6_FLOWLABEL_MGR: Operation not permitted\n\nWith this update, the underlying source code has been modified to address this issue, and using the '-l' option no longer causes traceroute to fail.\n(BZ#644297)\n\nAll users of traceroute are advised to upgrade to this updated package, which fixes these bugs.'",
#         :type=>"Bugfix", :issued=>"4/27/11", :updated=>"4/27/11", :references=>[], :pkglist => ["traceroute-2.0.1-6.el6.i386", " traceroute-2.0.1-6.el6.x86_64"]})      
#     end
#   end
  
end
