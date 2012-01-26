# vim: sw=4:ts=4:et
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

%global katello_name katello
%global headpin_name headpin
%global homedir %{_datarootdir}/%{headpin_name}
%global katello_dir %{_datarootdir}/%{katello_name}
%global datadir %{_sharedstatedir}/%{katello_name}
%global confdir deploy/common

Name:           katello-headpin
Version:        0.1.128
Release:        3%{?dist}
Summary:        A subscription management only version of katello
Group:          Applications/Internet
License:        GPLv2
URL:            http://www.katello.org
Source0:        %{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

Requires:       katello-common
Requires:       katello-glue-candlepin
Conflicts:      katello

BuildArch: noarch

%description
A subscription management only version of katello

%prep
%setup -q

%build
# How to do SASS and JAMMIT at run time.
mv src/* .
rm -rf src

#pull in branding if present
if [ -d branding ] ; then
  cp -r branding/* .
fi


%install
rm -rf %{buildroot}
#prepare dir structure
install -d -m0755 %{buildroot}%{homedir}
install -d -m0755 %{buildroot}%{katello_dir}/config
install -d -m0755 %{buildroot}%{_sysconfdir}/%{katello_name}

#copy the application to the target directory
cp -R * %{buildroot}%{homedir}

#copy configs and other var files (will be all overwriten with symlinks)
install -m 644 config/%{katello_name}.yml %{buildroot}%{_sysconfdir}/%{katello_name}/%{katello_name}.yml

#overwrite config files with symlinks to /etc/katello
ln -svf %{_sysconfdir}/%{katello_name}/%{katello_name}.yml %{buildroot}%{homedir}/config/%{katello_name}.yml

#remove files which are not needed in the homedir
rm -rf %{buildroot}%{homedir}/README
rm -rf %{buildroot}%{homedir}/LICENSE
rm -rf %{buildroot}%{homedir}/doc
rm -rf %{buildroot}%{homedir}/deploy
rm -rf %{buildroot}%{homedir}/%{name}.spec
rm -f %{buildroot}%{homedir}/lib/tasks/.gitkeep
rm -f %{buildroot}%{homedir}/public/stylesheets/.gitkeep
rm -f %{buildroot}%{homedir}/vendor/plugins/.gitkeep

#branding
if [ -d branding ] ; then
  ln -svf %{_datadir}/icons/hicolor/24x24/apps/system-logo-icon.png %{buildroot}%{homedir}/public/images/rh-logo.png
  ln -svf %{_sysconfdir}/favicon.png %{buildroot}%{homedir}/public/images/favicon.png
  rm -rf %{buildroot}%{homedir}/branding
fi

#remove development tasks
rm %{buildroot}%{homedir}/lib/tasks/test.rake

%clean
rm -rf %{buildroot}

%package all
Summary:        A meta-package to pull in all components for katello-headpin
Requires:       katello-headpin
Requires:       katello-configure
Requires:       katello-cli-headpin
Requires:       postgresql-server
Requires:       postgresql
Requires:       candlepin-tomcat6
Requires:       thumbslug

%description all
This is the Katello-headpin meta-package.  If you want to install Katello and all
of its dependencies on a single machine, you should install this package
and then run katello-configure to configure everything.

%files
%defattr(-,root,root)
%config(noreplace) %{_sysconfdir}/%{katello_name}/%{katello_name}.yml
%{homedir}

%files all

%post
# This overlays headpin onto katello
cp -Rf %{homedir}/* %{katello_dir}

%changelog
* Thu Jan 26 2012 Jordan OMara <jomara@redhat.com> 0.1.128-3
- Fixing branded header to have the right useres link (jomara@redhat.com)

* Thu Jan 26 2012 Jordan OMara <jomara@redhat.com> 0.1.128-2
- 783301 - fixing branding h1 tag for SUBSCRIPTION ACCESS MANAGER (thanks
  tom!!) (jomara@redhat.com)
- 754856 - Bryan Kearney - Katello cli improvements
- 754840 - Tom McKay - Ping command errors out on pulp
- 768421 - Tom McKay - headpin CLI product list and provider list fail with Invalid verb 'sync'
- 758447 - Tom McKay - headpin CLI shell prompts katello> v. headpin>
- 760189 - Tom McKay - headpin CLI fails with <!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
- 784679 - Jason E. Rist - Getting undefined method `[]' for nil:NilClass when looking at subscription for a system
- 773088 - Katello Internal Mailing List - During content sync, ui unresponsive and (Pulp::Repository: Request Timeout (GET /pulp/api/repositories/)
- 767475 - Brad Buckingham - Add/Remove options shouldn't be active when no package name supplied in the text box.
- 773368 - Brad Buckingham - List of repositories assigned to GPG key doesn't show products the repositories belong to
- 771343 - Jason E. Rist - 404's for missing images in log
- 759551 - Jordan OMara - dashboard widget size adjustment for headpin mode
- 760803 - Jordan OMara - Headpin/api lists too many urls
- 772744 - Jordan OMara - No visual notification when editing user's profile via /katello/account
- 782562 - Jordan OMara - "force" checkbox necessary on the Red Hat import manifest upload
- 771333 - Brad Buckingham - Password reset broken
- 761553 - Jordan OMara - non-admin display of "Roles & Permissions" needs UI clean up
- 784601 - Lukáš Zapletal - Content sync fails if /var/lib/pulp/packages is a separate disk partition
- 784563 - Tomas Strachota - It is possible to delete repos in non-locker environment
- 784607 - Lukáš Zapletal - katello production.log can rapidly increase in size (2.9G)
- 783099 - Jordan OMara - Failed to import manifest into SAM
- 754856 - Bryan Kearney - Katello cli improvements
- 784563 - Tomas Strachota - It is possible to delete repos in non-locker environment
- 783329 - Brad Buckingham - System Templates - update package check to use elastic search
- 745955 - Eric Helms - Creating template and clicking on Package Groups goes in circles
- 754724 - Eric Helms - Shouldn't be able to click "Promote" button if Changeset is already in process of being promoted
- 773690 - Eric Helms - System Templates - scroll in system template package does not immediately appear when necessary (7 packages?)
- 740931 - Partha Aji - Edit role: Entering a very long text string for a description overruns the edit graphic
- 784009 - Tom McKay - ESX hypervisors don't show up in Web UI systems
- 756518 - Partha Aji - "Access Provider" permission not sufficient to access providers
- 784319 - Eric Helms - Organization is not being saved when creating new user
* Thu Jan 19 2012 Jordan OMara <jomara@redhat.com> 0.1.126-2
- Merge remote-tracking branch 'katello/headpin' into BRANDING
  (jomara@redhat.com)
- Automatic commit of package [katello-headpin] release [0.1.125-2].
  (jomara@redhat.com)
- Merge remote-tracking branch 'katello/headpin' into BRANDING
  (jomara@redhat.com)
- Automatic commit of package [katello-headpin] release [0.1.124-2].
  (jomara@redhat.com)
- katello-headpin 0.1.124 (jomara@redhat.com)
- Automatic commit of package [katello-headpin] release [0.1.123-2].
  (jomara@redhat.com)
- Headpin 1.123-2 Merge remote-tracking branch 'katello/headpin' into BRANDING
  (jomara@redhat.com)
- Automatic commit of package [katello-headpin] release [0.1.122-2].
  (bkearney@redhat.com)
- Merge in the latest from upstream (bkearney@redhat.com)
- Automatic commit of package [katello-headpin] release [0.1.119-2].
  (bkearney@redhat.com)
- Pull in the latest version from upstream (bkearney@redhat.com)
- Automatic commit of package [katello-headpin] release [0.1.118-2].
  (bkearney@redhat.com)
- Latest upstream code (bkearney@redhat.com)
- Automatic commit of package [katello-headpin] release [0.1.116-2].
  (bkearney@redhat.com)
- Merge in the latest from upstream (bkearney@redhat.com)
- Automatic commit of package [katello-headpin] release [0.1.115-2].
  (bkearney@redhat.com)
- Bring in katello-headpin version 115 (bkearney@redhat.com)
- Change (bkearney@redhat.com)
- Automatic commit of package [katello-headpin] release [0.1.112-2].
  (bkearney@redhat.com)
- Bump the release (bkearney@redhat.com)
- Fix the README (bkearney@redhat.com)
- Pull in the branding code from system engine (bkearney@redhat.com)

* Wed Jan 18 2012 Jordan OMara <jomara@redhat.com> 0.1.125-2
- Merge remote-tracking branch 'katello/headpin' into BRANDING
  (jomara@redhat.com)
- Automatic commit of package [katello-headpin] release [0.1.124-2].
  (jomara@redhat.com)
- katello-headpin 0.1.124 (jomara@redhat.com)
- Automatic commit of package [katello-headpin] release [0.1.123-2].
  (jomara@redhat.com)
- Headpin 1.123-2 Merge remote-tracking branch 'katello/headpin' into BRANDING
  (jomara@redhat.com)
- Automatic commit of package [katello-headpin] release [0.1.122-2].
  (bkearney@redhat.com)
- Merge in the latest from upstream (bkearney@redhat.com)
- Automatic commit of package [katello-headpin] release [0.1.119-2].
  (bkearney@redhat.com)
- Pull in the latest version from upstream (bkearney@redhat.com)
- Automatic commit of package [katello-headpin] release [0.1.118-2].
  (bkearney@redhat.com)
- Latest upstream code (bkearney@redhat.com)
- Automatic commit of package [katello-headpin] release [0.1.116-2].
  (bkearney@redhat.com)
- Merge in the latest from upstream (bkearney@redhat.com)
- Automatic commit of package [katello-headpin] release [0.1.115-2].
  (bkearney@redhat.com)
- Bring in katello-headpin version 115 (bkearney@redhat.com)
- Change (bkearney@redhat.com)
- Automatic commit of package [katello-headpin] release [0.1.112-2].
  (bkearney@redhat.com)
- Bump the release (bkearney@redhat.com)
- Fix the README (bkearney@redhat.com)
- Pull in the branding code from system engine (bkearney@redhat.com)

* Thu Jan 12 2012 Jordan OMara <jomara@redhat.com> 0.1.124-2
- katello-headpin 0.1.124 (jomara@redhat.com)

* Wed Jan 11 2012 Jordan OMara <jomara@redhat.com> 0.1.123-2
- Headpin 1.123-2 merge 
  (jomara@redhat.com)
- Automatic commit of package [katello-headpin] release [0.1.122-2].
  (bkearney@redhat.com)

* Thu Jan 05 2012 Bryan Kearney <bkearney@redhat.com> 0.1.122-2
- Automatic commit of package [katello-headpin] release [0.1.119-2].
  (bkearney@redhat.com)
- Pull in the latest version from upstream (bkearney@redhat.com)
- Automatic commit of package [katello-headpin] release [0.1.118-2].
  (bkearney@redhat.com)
- Latest upstream code (bkearney@redhat.com)
- Automatic commit of package [katello-headpin] release [0.1.116-2].
  (bkearney@redhat.com)
- Merge in the latest from upstream (bkearney@redhat.com)
- Automatic commit of package [katello-headpin] release [0.1.115-2].
  (bkearney@redhat.com)
- Bring in katello-headpin version 115 (bkearney@redhat.com)
- Change (bkearney@redhat.com)
- Automatic commit of package [katello-headpin] release [0.1.112-2].
  (bkearney@redhat.com)
- Bump the release (bkearney@redhat.com)
- Fix the README (bkearney@redhat.com)
- Pull in the branding code from system engine (bkearney@redhat.com)

* Wed Dec 21 2011 Bryan Kearney <bkearney@redhat.com> 0.1.119-2
- Automatic commit of package [katello-headpin] release [0.1.118-2].
  (bkearney@redhat.com)
- Latest upstream code (bkearney@redhat.com)
- Automatic commit of package [katello-headpin] release [0.1.116-2].
  (bkearney@redhat.com)
- Merge in the latest from upstream (bkearney@redhat.com)
- Automatic commit of package [katello-headpin] release [0.1.115-2].
  (bkearney@redhat.com)
- Bring in katello-headpin version 115 (bkearney@redhat.com)
- Change (bkearney@redhat.com)
- Automatic commit of package [katello-headpin] release [0.1.112-2].
  (bkearney@redhat.com)
- Bump the release (bkearney@redhat.com)
- Fix the README (bkearney@redhat.com)
- Pull in the branding code from system engine (bkearney@redhat.com)

* Mon Dec 19 2011 Bryan Kearney <bkearney@redhat.com> 0.1.118-2
- Latest upstream code (bkearney@redhat.com)
- Automatic commit of package [katello-headpin] release [0.1.116-2].
  (bkearney@redhat.com)
- Merge in the latest from upstream (bkearney@redhat.com)
- Automatic commit of package [katello-headpin] release [0.1.115-2].
  (bkearney@redhat.com)
- Bring in katello-headpin version 115 (bkearney@redhat.com)
- Change (bkearney@redhat.com)
- Automatic commit of package [katello-headpin] release [0.1.112-2].
  (bkearney@redhat.com)
- Bump the release (bkearney@redhat.com)
- Fix the README (bkearney@redhat.com)
- Pull in the branding code from system engine (bkearney@redhat.com)

* Wed Dec 14 2011 Bryan Kearney <bkearney@redhat.com> 0.1.116-2
- Automatic commit of package [katello-headpin] release [0.1.115-2].
  (bkearney@redhat.com)
- Bring in katello-headpin version 115 (bkearney@redhat.com)
- Change (bkearney@redhat.com)
- Automatic commit of package [katello-headpin] release [0.1.112-2].
  (bkearney@redhat.com)
- Bump the release (bkearney@redhat.com)
- Fix the README (bkearney@redhat.com)
- Pull in the branding code from system engine (bkearney@redhat.com)

* Fri Dec 09 2011 Bryan Kearney <bkearney@redhat.com> 0.1.115-2
- Bring in katello-headpin version 115 (bkearney@redhat.com)
- Change (bkearney@redhat.com)
- Automatic commit of package [katello-headpin] release [0.1.112-2].
  (bkearney@redhat.com)
- Bump the release (bkearney@redhat.com)
- Fix the README (bkearney@redhat.com)
- Pull in the branding code from system engine (bkearney@redhat.com)

* Wed Dec 07 2011 Bryan Kearney <bkearney@redhat.com>
-

* Wed Dec 07 2011 Bryan Kearney <bkearney@redhat.com> 0.1.112-2
- Bump the release (bkearney@redhat.com)
- Fix the README (bkearney@redhat.com)
- Pull in the branding code from system engine (bkearney@redhat.com)
- Add in a branding check to the buildfile (bkearney@redhat.com)

* Wed Dec 07 2011 Bryan Kearney <bkearney@redhat.com>
- Fix the README (bkearney@redhat.com)
- Pull in the branding code from system engine (bkearney@redhat.com)
- Add in a branding check to the buildfile (bkearney@redhat.com)

* Mon Nov 28 2011 Tom McKay <thomasmckay@redhat.com> 0.1.107-1
- gen_changes.sh. run (thomasmckay@redhat.com)
- Add thumbslug requires for katello-headpin (jbowes@redhat.com)

* Thu Nov 17 2011 Tom McKay <thomasmckay@redhat.com> 0.1.106-1
- gen_changes.sh run (thomasmckay@redhat.com)

* Thu Nov 17 2011 Tom McKay <thomasmckay@redhat.com> 0.1.105-1
- gen_changes.sh run (thomasmckay@redhat.com)

* Fri Nov 11 2011 Tom McKay <thomasmckay@redhat.com> 0.1.104-1
- gen_changes.sh run (thomasmckay@redhat.com)

* Wed Nov 09 2011 Tom McKay <thomasmckay@redhat.com> 0.1.103-1
- gen_changes.sh run (thomasmckay@redhat.com)

* Tue Nov 08 2011 Tom McKay <thomasmckay@redhat.com> 0.1.102-1
- gen_changes.sh run (thomasmckay@redhat.com)

* Fri Nov 04 2011 Tom McKay <thomasmckay@redhat.com> 0.1.101-1
- gen_changes.sh run (thomasmckay@redhat.com)
- Add in requirements for katello-configure and the headpin cli
  (bkearney@redhat.com)
- gen_changes.sh run (thomasmckay@redhat.com)
- Remove test.rake which requires rspec/core (bkearney@redhat.com)
- Force a good copy (bkearney@redhat.com)
- debug (bkearney@redhat.com)
- Force the copy (bkearney@redhat.com)
- missed some files (bkearney@redhat.com)

* Mon Oct 31 2011 Bryan Kearney <bkearney@redhat.com> 0.1.100-1
- Overwrite the katello files with the headpin files (bkearney@redhat.com)
- Did not actually copy the files. Whoops (bkearney@redhat.com)
- Pull in the latest code from master (bkearney@redhat.com)
- Pull in the latest from source (bkearney@redhat.com)

* Wed Oct 26 2011 Bryan Kearney <bkearney@redhat.com> 0.1.99-1
- Move the headpin packaegs to a new location (bkearney@redhat.com)

* Wed Oct 19 2011 Mike McCune <mmccune@redhat.com> 0.1.98-1
- moving the headpin generated source and specfile into rel-eng
  (mmccune@redhat.com)

* Wed Oct 19 2011 Mike McCune <mmccune@redhat.com> 0.1.97-1
- new package built with tito

* Tue Oct 18 2011 Bryan Kearney <bkearney@redhat.com> 0.1.96-1
- new package built with tito


