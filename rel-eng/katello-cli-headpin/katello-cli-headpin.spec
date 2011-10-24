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

%define base_name katello
%define command_name headpin

Name:          %{base_name}-cli-headpin
Summary:       Client package for managing a katello-headpin installation
Group:         Applications/System
License:       GPLv2
URL:           http://www.katello.org
Version:       0.1.11
Release:       1%{?dist}
Source0:       %{name}-%{version}.tar.gz
BuildRoot:     %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

Requires:      %{base_name}-cli-common
BuildArch:     noarch


%description
Provides a client package for managing application life-cycle
for Linux systems

%prep
%setup -q

%build

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT%{_bindir}/
install -d $RPM_BUILD_ROOT%{_sysconfdir}/%{command_name}/
install -pm 0644 bin/%{base_name} $RPM_BUILD_ROOT%{_bindir}/%{command_name}
install -pm 0644 etc/client.conf $RPM_BUILD_ROOT%{_sysconfdir}/%{base_name}/client.conf
install -pm 0644 src/%{base_name}/*.py $RPM_BUILD_ROOT%{python_sitelib}/%{base_name}/
install -pm 0644 src/%{base_name}/client/*.py $RPM_BUILD_ROOT%{python_sitelib}/%{base_name}/client/
install -pm 0644 src/%{base_name}/client/api/*.py $RPM_BUILD_ROOT%{python_sitelib}/%{base_name}/client/api/
install -pm 0644 src/%{base_name}/client/cli/*.py $RPM_BUILD_ROOT%{python_sitelib}/%{base_name}/client/cli/
install -pm 0644 src/%{base_name}/client/core/*.py $RPM_BUILD_ROOT%{python_sitelib}/%{base_name}/client/core/


%clean
rm -rf $RPM_BUILD_ROOT

%files 
%attr(755,root,root) %{_bindir}/%{command_name}
#%config(noreplace) %attr(644,root,root) %{_sysconfdir}/%{base_name}/client.conf
%doc README LICENSE
#%{_mandir}/man8/%{command_name}.8*



%changelog
* Mon Oct 24 2011 Bryan Kearney <bkearney@redhat.com> 0.1.11-1
- new package built with tito


