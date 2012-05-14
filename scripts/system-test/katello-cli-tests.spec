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
%global homedir %{_datarootdir}/%{base_name}

Name:          %{base_name}-cli-tests
Summary:       System tests for Katello client package
Group:         Applications/System
License:       GPLv2
URL:           http://www.katello.org
Version:       0.2.14
Release:       1%{?dist}
Source0:       %{name}-%{version}.tar.gz
BuildRoot:     %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

Requires:      %{base_name}-cli
Requires:      yajl
Requires:      sed
BuildArch:     noarch


%description
Provides a test scripts for client package for managing
application life-cycle for Linux systems


%prep
%setup -q

%build

%install
rm -rf $RPM_BUILD_ROOT
install -d -m 755 $RPM_BUILD_ROOT%{homedir}/script/cli-tests
pwd
ls
cp -Rp cli_tests/ cli-system-test helpers *zip RPM-GPG-KEY* $RPM_BUILD_ROOT%{homedir}/script/cli-tests


%clean
rm -rf $RPM_BUILD_ROOT

%files
%{homedir}/script/cli-tests


%changelog
* Fri Apr 27 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.14-1
- 767925 - search packages command in CLI/API

* Tue Apr 24 2012 Petr Chalupa <pchalupa@redhat.com> 0.2.13-1
- katello-cli, katello - setting default environment for user

* Thu Apr 19 2012 Ivan Necas <inecas@redhat.com> 0.2.12-1
- cli-test-rhsmcerd - don't check the output of rhsmcertd restart

* Tue Apr 10 2012 Tomas Strachota <tstrachota@redhat.com> 0.2.11-1
- slas - all cli options --service_level renamed to --servicelevel

* Fri Apr 06 2012 Tomas Strachota <tstrachota@redhat.com> 0.2.10-1
- slas - system tests
- slas - fake manifest products with service_level
* Tue Mar 27 2012 Ivan Necas <inecas@redhat.com> 0.2.7-1
- periodic build

* Thu Mar 15 2012 Ivan Necas <inecas@redhat.com> 0.2.4-1
- periodic build

* Fri Mar 09 2012 Mike McCune <mmccune@redhat.com> 0.2.3-1
- periodic rebuild
* Wed Feb 22 2012 Mike McCune <mmccune@redhat.com> 0.2.1-1
- version bump

* Wed Feb 22 2012 Ivan Necas <inecas@redhat.com> 0.1.30-1
- repetitive build

* Fri Feb 10 2012 Ivan Necas <inecas@redhat.com> 0.1.27-1
- system-tests - disable other repos when installing from fake repo
  (inecas@redhat.com)
- system-tests - check on specific exit code (inecas@redhat.com)

* Fri Feb 10 2012 Ivan Necas <inecas@redhat.com> 0.1.26-1
- system tests - enable uebercert test (inecas@redhat.com)

* Thu Feb 09 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.25-1
- system tests - use repo with space in distribution name

* Mon Feb 06 2012 Ivan Necas <inecas@redhat.com> 0.1.24-1
- periodic build
* Fri Jan 20 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.21-1
- bug - adding missing file to system tests

* Thu Jan 19 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.20-1
- perms - fixing system tests after rename

* Thu Jan 19 2012 Ivan Necas <inecas@redhat.com> 0.1.19-1
- periodic build
* Fri Jan 13 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.17-1
- virt-who-vsphere - script for simulating virt-who vsphere response

* Mon Dec 19 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.14-1
- ak - system tests

* Wed Dec 07 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.11-1
- cli tests - adding distribution smoke test
- cli tests - switching to fixed zoo4 test repo
- cli tests - adding more debug messages to the base test
- cli tests - switching to zoo3 test repo

* Mon Dec 05 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.9-1
- fixing system tests for cli - templates

* Fri Dec 02 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.8-1
- fixing more system tests (removing --type for all imports)

* Fri Dec 02 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.7-1
- uebercert - adding to system tests
- provider cli - removed needless option '--type'
- Revert "repo blacklist - cli unit tests for repo list"
- repo blacklist - cli unit tests for repo list

* Tue Nov 22 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.6-1
- st - fixing bug with creating categories
- system tests - new function for delayed jobs check
- template export - system test for exporting from non-locker env

* Wed Nov 16 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.5-1
- adding dependencies for system tests

* Wed Nov 16 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.4-1
- system tests - removed duplicit test for provider import
- system tests - added ability to set katello, pulp and cp url
- system-tests fix load path setting
- possibility to run system tests from rpm
- getting katello-cli-tests.spec working
- adding katello-cli-tests.spec
- moving system tests into /scripts

* Thu Nov 10 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.3-1
- possibility to run system tests from rpm
- getting katello-cli-tests.spec working

* Thu Nov 10 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.2-1
- new package built with tito

* Thu Sep 08 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.1-1
- initial version
