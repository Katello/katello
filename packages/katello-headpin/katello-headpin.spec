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
%global homedir %{_datarootdir}/%{katello_name}
%global datadir %{_sharedstatedir}/%{katello_name}
%global confdir deploy/common

Name:           katello-headpin
Version:        0.1.95
Release:        1%{?dist}
Summary:        A subscription management only version of katello
Group:          Applications/Internet
License:        GPLv2
URL:            http://www.katello.org
Source0:        %{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

Requires:       katello-common
Requires:       katello-glue-candlepin

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
install -d -m0755 %{buildroot}%{_sysconfdir}/%{katello_name}
install -d -m0755 %{buildroot}%{_localstatedir}/log/%{katello_name}

#copy configs and other var files (will be all overwriten with symlinks)
install -m 644 config/%{katello_name}.yml %{buildroot}%{_sysconfdir}/%{katello_name}/%{katello_name}.yml
install -m 644 config/environments/production.rb %{buildroot}%{_sysconfdir}/%{katello_name}/environment.rb

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
rm %{buildroot}%{homedir}/lib/tasks/rcov.rake
rm %{buildroot}%{homedir}/lib/tasks/yard.rake
rm %{buildroot}%{homedir}/lib/tasks/hudson.rake

%clean
rm -rf %{buildroot}

%package all
Summary:        A meta-package to pull in all components for katello-headpin
Requires:       katello-headpin
Requires:       postgresql-server
Requires:       postgresql
Requires:       candlepin-tomcat6

%description all
This is the Katello-headpin meta-package.  If you want to install Katello and all
of its dependencies on a single machine, you should install this package
and then run katello-configure to configure everything.

%files
%defattr(-,root,root)
%doc README LICENSE doc/
%config(noreplace) %{_sysconfdir}/%{katello_name}/%{katello_name}.yml
%{homedir}

%files all

%changelog

