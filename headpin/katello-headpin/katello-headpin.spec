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
Version:        0.1.100
Release:        1%{?dist}
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


