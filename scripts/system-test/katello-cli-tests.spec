# vim: sw=4:ts=4:et
#
# Copyright 2013 Red Hat, Inc.
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
Version:       1.4.0
Release:       1%{?dist}
Source0:       https://fedorahosted.org/releases/k/a/katello/%{name}-%{version}.tar.gz

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
install -d -m 755 $RPM_BUILD_ROOT%{homedir}/script/cli-tests
pwd
ls
cp -Rp cli_tests/ cli-system-test helpers *zip RPM-GPG-KEY* $RPM_BUILD_ROOT%{homedir}/script/cli-tests


%files
%{homedir}/script/cli-tests


%changelog
* Fri Apr 12 2013 Justin Sherrill <jsherril@redhat.com> 1.3.6-1
- Remove Foreman specific code - system tests (inecas@redhat.com)
- cli custom_info restructure (komidore64@gmail.com)
- Content views: added some system tests (daviddavis@redhat.com)
- Removing system template code (daviddavis@redhat.com)
- large refactor of organization level default system info keys
  (komidore64@gmail.com)
- allowing the use of repo set name for enable disable (jsherril@redhat.com)
- adding repo set enabling for system tests (jsherril@redhat.com)
- comp resources - fixed system tests (tstrachota@redhat.com)
- hw models - system tests (tstrachota@redhat.com)

* Wed Jan 30 2013 Justin Sherrill <jsherril@redhat.com> 1.3.5-1
- removing pulpv2 prefix from pulpv2 branch (jsherril@redhat.com)
- comp. res. - system tests (tstrachota@redhat.com)
- run system-test on os x without warning (pchalupa@redhat.com)
- 879151, 879161, 879169, 879174, 879195, 880031, 880048, 880054, 880066,
  880073, 880089, 880131, 880566 (komidore64@gmail.com)

* Wed Jan 23 2013 Justin Sherrill <jsherril@redhat.com> 1.3.2.pulpv2-1
- Removing filter entries in the cli-system tests (paji@redhat.com)
- cli system test - just delete the provider (jsherril@redhat.com)

* Tue Jan 08 2013 Lukas Zapletal <lzap+git@redhat.com> 1.3.2-1
- 879151, 879161, 879169, 879174, 879195, 880031, 880048, 880054, 880066,
  880073, 880089, 880131, 880566 (komidore64@gmail.com)

* Tue Dec 18 2012 Miroslav Suchý <msuchy@redhat.com> 1.3.1-1
- system tests - tests for smart proxies (tstrachota@redhat.com)
- system tests - new function skip_message (tstrachota@redhat.com)
- cli smoke tests - adding support for beaker lib (lzap+git@redhat.com)
- cli tests for org name and label (lzap+git@redhat.com)
- Bumping package versions for 1.3. (ehelms@redhat.com)

* Thu Dec 06 2012 Eric D Helms <ehelms@redhat.com> 1.2.1-1
- subnets - system tests (tstrachota@redhat.com)
- fix rhsm cli system test (msuchy@redhat.com)
- architectures - various cli fixes (tstrachota@redhat.com)
- Bumping package versions for 1.1. (lzap+git@redhat.com)
- Architectures API fix (pajkycz@gmail.com)
- Added system tests for domains, config templates (pajkycz@gmail.com)
- architectures cli - show action renamed to info to keep naming consistency
  (tomas.str@gmail.com)
- architectures - cli smoke tests (tomas.str@gmail.com)

* Fri Oct 12 2012 Lukas Zapletal <lzap+git@redhat.com> 1.1.7-1
- cli test - adding new test for template deletion
- cli tests - addressing error when getting POOL_ID
- cli tests - determine terminal size and use it
- cli tests - adding -t option to exit on failure
- Merge pull request #764 from xsuchy/pull-req-cli2
- fix test according to recent change in printer.py

* Thu Sep 27 2012 Miroslav Suchý <msuchy@redhat.com> 1.1.6-1
- demote repo before promotion (msuchy@redhat.com)

* Wed Sep 12 2012 Miroslav Suchý <msuchy@redhat.com> 1.1.5-1
- 839575 - [CLI] Adding a system to system group using incorrect uuid should
  raise an error instead of success (pajkycz@gmail.com)
- skip RHSM test when registred against hosted (msuchy@redhat.com)

* Thu Sep 06 2012 Ivan Necas <inecas@redhat.com> 1.1.4-1
- system test - solving rhsm ordering issue (lzap+git@redhat.com)
- system test - better random generation (lzap+git@redhat.com)
- fix un-determinism in rhsm system test (inecas@redhat.com)
- system tests - PoolId has been renamed to Id (lzap+git@redhat.com)
- system tests - do not run sudo when running as root (lzap+git@redhat.com)
- 746765 - systems can be referenced by uuid (lzap+git@redhat.com)
- cli tests - removing excessive logging (lzap+git@redhat.com)

* Thu Aug 23 2012 Mike McCune <mmccune@redhat.com> 1.1.3-1
- Changeset#remove_package! fix (pajkycz@gmail.com)
- Merge pull request #436 from omaciel/userlocale (mmccune@gmail.com)
- Allow user to update his/her own localevia cli. Also, output the default
  locale when using the info parameter. (ogmaciel@gnome.org)

* Sat Aug 11 2012 Miroslav Suchý <msuchy@redhat.com> 1.1.2-1
- fix system tests for rhsm re-subscribe (inecas@redhat.com)
- 840531 - remove nvre tests from system tests (inecas@redhat.com)

* Sat Aug 04 2012 Miroslav Suchý <msuchy@redhat.com> 1.1.1-1
- Introduce +load_remote_data+ method to lazy_attributes (inecas@redhat.com)
- buildroot and %%clean section is not needed (msuchy@redhat.com)
- Bumping package versions for 1.1. (msuchy@redhat.com)

* Tue Jul 31 2012 Miroslav Suchý <msuchy@redhat.com> 1.0.1-1
- bump up version to 1.0 (msuchy@redhat.com)

* Mon Jul 30 2012 Miroslav Suchý <msuchy@redhat.com> 0.2.21-1
- point Source0 to fedorahosted.org where tar.gz are stored (msuchy@redhat.com)
- skip subscription-manager testing if you are registred against hosted
  (msuchy@redhat.com)

* Mon Jul 02 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.20-1
- system groups - remove debug from system test
- system groups - cli - add system tests for package actions

* Wed Jun 27 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.19-1
- system tests - escaping xml reserved characters

* Mon Jun 25 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.18-1
- BZ 825262: support for moving systems between environments from CLI   - added
  system test for the system move operation
- ulimit - fix for system tests
- ulimit - system tests
- system tests - optional xml logging Can be used for better view of test
  results via ResultNG

* Fri Jun 01 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.17-1
- cli - None check in date_formatter + enabled system test for deleting filters
- 821644 - cli admin crl_regen command - unit and system test
- 823890 - delete products that were removed from new manifest

* Thu May 17 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.16-1
- product status cli - fix for key error Formatting moved to printer that
  checks whether the key exist prior to printing it.

* Thu May 10 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.15-1
- systems - more cli system tests - test for listing available subscriptions
  for a system - test for listing systems for a pool id

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
