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

%global base_name katello
%global katello_requires python-iniparse python-simplejson python-kerberos m2crypto PyXML

Name:          %{base_name}-cli
Summary:       Client package for managing application life-cycle for Linux systems
Group:         Applications/System
License:       GPLv2
URL:           http://www.katello.org
Version:       0.2.42
Release:       1%{?dist}

# Upstream uses tito rpm helper utility. To get the particular version from
# git, do the following commands:
#   git clone git://github.com/Katello/katello.git && cd cli
#   tito build --tgz --offline --tag=%{name}-%{version}-1
Source0:       %{name}-%{version}.tar.gz

# we need to keep RHEL compatibility
BuildRoot:     %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

Requires:      %{base_name}-cli-common
BuildArch:     noarch


%description
Provides a client package for managing application life-cycle for 
Linux systems with Katello

%package common
Summary:       Common Katello client bits
Group:         Applications/System
License:       GPLv2
Requires:      %{katello_requires}
BuildRequires: python2-devel
BuildRequires: gettext
BuildRequires: /usr/bin/pod2man
BuildRequires: %{katello_requires}

BuildArch:     noarch

%description common
Common classes for katello clients

%prep
%setup -q

%build
# generate usage docs and incorporate it into the man page
pushd man
PYTHONPATH=../src python ../src/katello/client/utils/usage.py >katello-usage.txt
sed -e '/^THE_USAGE/{r katello-usage.txt' -e 'd}' katello.pod |\
    sed -e 's/THE_VERSION/%{version}/g' |\
    /usr/bin/pod2man --name=katello -c "Katello Reference" --section=1 --release=%{version} - katello.man1
sed -e 's/THE_VERSION/%{version}/g' katello-debug-certificates.pod |\
/usr/bin/pod2man --name=katello -c "Katello Reference" --section=1 --release=%{version} - katello-debug-certificates.man1
popd

%install
rm -rf %{buildroot}
install -d %{buildroot}%{_bindir}/
install -d %{buildroot}%{_sysconfdir}/%{base_name}/
install -d %{buildroot}%{python_sitelib}/%{base_name}
install -d %{buildroot}%{python_sitelib}/%{base_name}/client
install -d %{buildroot}%{python_sitelib}/%{base_name}/client/api
install -d %{buildroot}%{python_sitelib}/%{base_name}/client/cli
install -d %{buildroot}%{python_sitelib}/%{base_name}/client/core
install -d %{buildroot}%{python_sitelib}/%{base_name}/client/utils
install -pm 0644 bin/%{base_name} %{buildroot}%{_bindir}/%{base_name}
install -pm 0644 bin/%{base_name}-debug-certificates %{buildroot}%{_bindir}/%{base_name}-debug-certificates
install -pm 0644 etc/client.conf %{buildroot}%{_sysconfdir}/%{base_name}/client.conf
install -pm 0644 src/%{base_name}/*.py %{buildroot}%{python_sitelib}/%{base_name}/
install -pm 0644 src/%{base_name}/client/*.py %{buildroot}%{python_sitelib}/%{base_name}/client/
install -pm 0644 src/%{base_name}/client/api/*.py %{buildroot}%{python_sitelib}/%{base_name}/client/api/
install -pm 0644 src/%{base_name}/client/cli/*.py %{buildroot}%{python_sitelib}/%{base_name}/client/cli/
install -pm 0644 src/%{base_name}/client/core/*.py %{buildroot}%{python_sitelib}/%{base_name}/client/core/
install -pm 0644 src/%{base_name}/client/utils/*.py %{buildroot}%{python_sitelib}/%{base_name}/client/utils/
install -d -m 0755 %{buildroot}%{_mandir}/man1
install -m 0644 man/%{base_name}.man1 %{buildroot}%{_mandir}/man1/%{base_name}.1
install -m 0644 man/%{base_name}-debug-certificates.man1 %{buildroot}%{_mandir}/man1/%{base_name}-debug-certificates.1

# several scripts are executable
chmod 755 %{buildroot}%{python_sitelib}/%{base_name}/client/main.py


# we need to keep RHEL compatibility
%clean
rm -rf %{buildroot}

%files 
%attr(755,root,root) %{_bindir}/%{base_name}
%attr(755,root,root) %{_bindir}/%{base_name}-debug-certificates
%config(noreplace) %{_sysconfdir}/%{base_name}/client.conf
%doc README LICENSE
%{_mandir}/man1/%{base_name}.1*
%{_mandir}/man1/%{base_name}-debug-certificates.1*

%files common
%{python_sitelib}/%{base_name}/


%changelog
* Mon Jul 02 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.42-1
- system groups - cli - fix broken test
- system groups - cli - creating a group should default max systems to
  unlimited
- system groups - cli - add description to the AsyncJob
- system groups - cli - split history in to 2 actions per review feedback
- system groups - api/cli to support errata install
- system groups - remove unused code from package action CLI
- system groups - api/cli to support package and package group actions

* Mon Jun 25 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.41-1
- ulimit - brad's review
- BZ 825262: support for moving systems between environments from CLI
- ulimit - fixing cli makefile for unit tests
- ulimit - backend api and cli
- system groups - cli/api - provide user option to delete systems when deleting
  group
- cli - updated makefile and readme to mirror the latest changes in cli
  unittests.

* Mon Jun 18 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.40-1
- Updates for broken cli unit tests that were a result of re-factoring work
  previously done.
- system groups - api - include total system count in system group info
- system group cli - removed excess lines
- cli - fix for printing version on -v option
- cli unit tests - tests splitted into packages and modules
- 822484 - cli - sync_plan list traceback
- cli - pep8 fixes
- cli - action base class renamed
- cli - usage script modified to use command container
- cli - auth methods extracted form server class
- cli - fixed shell completion and line preprocessing
- cli - katello cli turned to new-style command
- cli - unittests fixed after introduction of new option types
- cli - allow to use only user config file
- 818726 - updated i18n translations
- cli - new option types - url and list
- 818726 - update to both ui and cli and zanata pushed

* Fri Jun 01 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.39-1
- system grops - a few fixes for history cli
- cli - None check in date_formatter + enabled system test for deleting filters
- system groups - adding group history to cli
- cli - adding log file location to traceback error
- 821644 - cli admin crl_regen command - unit and system test
- 822926 - katello-cli package fedora review - fix

* Fri May 25 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.38-1
- 822926 - katello-cli package fedora review
- Fixed typo s/fing/find. Fixes BZ #824749.
- system groups - Updates for help text around options that take lists and
  command naming for adding groups to a system.
- 795525 - renaming cli column name 'subscriptions'
- system groups - Updates the system groups CLI work to be consistent with re-
  factoring work.
- system groups - merge conflict
- system groups - Updates to not require max_systems on creation in CLI.
- Two minor tweaks to output strings for removing systems from a system group.
- system groups - Adds the maximum systems paramter for CLI create/update.
- system groups - Cleans up CLI code to fit re-factoring changes from master.
- system groups - Adds CLI support for add/remove of a system group from an
  activation key.
- system groups - Clean up CLI code around adding systems to a system group
- system group - Adds CLI/API support for adding and removing system groups
  from a system
- system groups - Adds support for removing systems from a system group in CLI.
- system groups - Adds support for adding systems to a system group in the CLI
- Adds system group basic update support for the CLI
- system group - Adds system group delete to CLI.
- system group - Adds system group creation support to CLI.
- system group - Adds support for locking and unlocking a system group in the
  CLI
- system groups - Adds CLI support for listing systems in a system group.
- system groups - Adds ability to view info of single system group from CLI.
- system-groups - Adds CLI system group basics and calls to list system groups
  for a given organization.

* Thu May 24 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.37-1
- 824069 - adding new parameter --all to cli product list
- cli - workaround for error when action was not found This commit fixes error
  "object has no attribute 'parser'" appearing after attempt to call a non-
  existing action. The error is gone but classes Command and KatelloCLI need
  more cleanup. There's redundant code and they touch each other's
  responsibility.
- cli - fix for missing section 'options' client.conf Some versions of
  OptionParser throw error when you try to iterate items from non-existing
  section.
- cli validator - complete unit tests
- cli - validator and parser moved from class to local variables This helps the
  code to be more testable.
- cli - fix for wrong param validation in system register
- cli - CLITestCase divided into two classes
- cli - unit tests for required options simplified
- cli - methods for validation extracted from cli Action

* Fri May 18 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.36-1
- rpm review - katello-cli review preparation

* Fri May 18 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.35-1
- cli registration regression with aks

* Thu May 17 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.34-1
- cli_man - katello(1) man page and generator
- Changing wording for hypervisor deletion record delete
- 812891 - Adding hypervisor record deletion to katello cli
- product status cli - fix for key error Formatting moved to printer that
  checks whether the key exist prior to printing it.

* Thu May 10 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.33-1
- cli - pep8 fixes - code reidentation - trailing spaces removal - unused
  imports removed
- cli - fixes in unit tests
- cli - removal of redundant code
- task list cli - print part refactored Duplicit lines removed and changed to
  use new style printer.
- cli - new method for testing success of a record creation
- cli - api util methods changed to raise exceptions instead of returning None
  when a record was not found. This allows us to remove the ubiquitous checks
  for None value from action bodies.
- systems cli - actions use new api util method get_system
- systems cli - method get_environment moved out from system api class
- Added cli tests for ldap_roles
- Added mocks for ldap_group api call
- 808172 - Added code to show version information for katello cli
- systems - cli for listing systems for a pool_id

* Fri Apr 27 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.32-1
- Fixed addColumn to match new name
- Fixing various LDAP issues from the last pull request
- Loading group roles from ldap
- 767925 - search packages command in CLI/API

* Tue Apr 24 2012 Petr Chalupa <pchalupa@redhat.com> 0.2.31-1
- katello-cli, katello - setting default environment for user

* Thu Apr 19 2012 Tomas Strachota <tstrachota@redhat.com> 0.2.30-1
- cli - fixed wrong formatters used for product and repo last sync time

* Thu Apr 19 2012 Tomas Strachota <tstrachota@redhat.com> 0.2.29-1
- periodic-build
* Wed Apr 18 2012 Petr Chalupa <pchalupa@redhat.com> 0.2.28-1
- 812842 - complete removal of skipping None values in verbose print strategy
- 741595 - uebercert POST/GET/DELETE - either support or delete the calls from
  CLI

* Tue Apr 17 2012 Tomas Strachota <tstrachota@redhat.com> 0.2.27-1
- 812842 - fix for cli printer skipping values that are evaluated as False
- 798918 - Headpin cli unregister doesn't have environment option

* Fri Apr 13 2012 Tomas Strachota <tstrachota@redhat.com> 0.2.26-1
- cli - documentation strings for printer
- cli - output formatters in printer
- cli - fix for method set_output_mode removed from Printer
- cli - printer refactored to enable more output modes
- cli - printer class moved out from utils.py into separate file

* Thu Apr 12 2012 Ivan Necas <inecas@redhat.com> 0.2.25-1
- cp-releasever - release as a scalar value in API system json
- 769302 - CLI `system register` needs enhancement

* Wed Apr 11 2012 Petr Chalupa <pchalupa@redhat.com> 0.2.24-1
- 713153 - RFE: include IP information in consumers/systems related API calls.
- 768243 - Error msg needs to be improved

* Tue Apr 10 2012 Tomas Strachota <tstrachota@redhat.com> 0.2.23-1
- slas - all cli options --service_level renamed to --servicelevel

* Fri Apr 06 2012 Tomas Strachota <tstrachota@redhat.com> 0.2.22-1
- slas - field for SLA in hash export of consumer renamed We used service_level
  but subscription-manager requires serviceLevel and checks for it's presence.
* Wed Apr 04 2012 Petr Chalupa <pchalupa@redhat.com> 0.2.21-1
- 798649 - RFE - Better listing of products and repos

* Mon Apr 02 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.20-1
- cleanup - removing unused imports and variables
- 744199 - cli now reports all errors to stderr

* Tue Mar 27 2012 Ivan Necas <inecas@redhat.com> 0.2.18-1
- periodic-build

* Mon Mar 26 2012 Ivan Necas <inecas@redhat.com> 0.2.16-1
- periodic build

* Mon Mar 19 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.14-1
- 803441 - fix cli unit test for org subscriptions

* Thu Mar 15 2012 Ivan Necas <inecas@redhat.com> 0.2.13-1
- priodic build

* Tue Mar 13 2012 Ivan Necas <inecas@redhat.com> 0.2.12-1
- periodic build

* Mon Mar 12 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.10-1
- 801786 - putting client.conf back to the RPM

* Fri Mar 09 2012 Mike McCune <mmccune@redhat.com> 0.2.9-1
- periodic rebuild
* Fri Mar 02 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.3-1
- 798264 - Katello debug collects certificate password files and some certs

* Mon Feb 27 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.2-1
- Pull in the latest translations

* Wed Feb 22 2012 Mike McCune <mmccune@redhat.com> 0.2.1-1
- version bump

* Wed Feb 22 2012 Ivan Necas <inecas@redhat.com> 0.1.57-1
- periodic build
* Fri Feb 17 2012 Brad Buckingham <bbuckingham@redhat.com> 0.1.56-1
- 794782: Add PyXML to the cli dependencies (bkearney@redhat.com)

* Tue Feb 07 2012 Ivan Necas <inecas@redhat.com> 0.1.53-1
- 768254 - scope products API by organization (inecas@redhat.com)

* Mon Feb 06 2012 Ivan Necas <inecas@redhat.com> 0.1.51-1
- periodic build

* Mon Jan 30 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.47-1
- repo cli - option --environment removed from 'repo delete'

* Sat Jan 28 2012 Martin Bačovský <mbacovsk@redhat.com> 0.1.46-1
- Fixed failing tests (mbacovsk@redhat.com)

* Thu Jan 26 2012 Shannon Hughes <shughes@redhat.com> 0.1.44-1
- 783513 - CLI BRANDING: Locker -> Library (mbacovsk@redhat.com)

* Tue Jan 24 2012 Bryan Kearney <bkearney@redhat.com> 0.1.42-1
- 754856: Define the userdir only in the Config module (bkearney@redhat.com)

* Tue Jan 24 2012 Martin Bačovský <mbacovsk@redhat.com> 0.1.41-1
- 782775 - Unify unsubscription in RHSM and Katello CLI (mbacovsk@redhat.com)
- 772183 - ProvidedProducts: displays too much of information for RH Pools (mbacovsk@redhat.com)
- 773521 - Help text should include "entitlement ID" instead of "pool id" (mbacovsk@redhat.com)
- Added require_one_of_options checker to CLI Action (mbacovsk@redhat.com)
- Fixed exit codes in 'system subscriptions' (CLI) (mbacovsk@redhat.com)
- 767470 - Unable to fetch subscription serial numbers from cli (mbacovsk@redhat.com)
- dists - adding required string to the repo_id param (lzap+git@redhat.com)

* Thu Jan 19 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.39-1
- perms - moving /errata/id under /repositories API
- perms - moving /packages/id under /repositories API

* Thu Jan 19 2012 Ivan Necas <inecas@redhat.com> 0.1.38-1
- periodic build

* Wed Jan 18 2012 Ivan Necas <inecas@redhat.com> 0.1.37-1
- gpg cli support

* Fri Jan 06 2012 Ivan Necas <inecas@redhat.com> 0.1.34-1
- 771911 - CLI - update success message after system update (inecas@redhat.com)

* Thu Dec 22 2011 Ivan Necas <inecas@redhat.com> 0.1.31-1
- periodic rebuild

* Wed Dec 14 2011 Ivan Necas <inecas@redhat.com> 0.1.27-1
- Fix bug on cli repo info for disabled repository (inecas@redhat.com)

* Wed Dec 14 2011 Shannon Hughes <shughes@redhat.com> 0.1.25-1
- system engine build 

* Thu Dec 08 2011 Mike McCune <mmccune@redhat.com> 0.1.23-2
- periodic rebuild
* Thu Dec 08 2011 Mike McCune <mmccune@redhat.com>
- periodic rebuild

* Tue Dec 06 2011 Shannon Hughes <shughes@redhat.com> 0.1.22-1
- 758447: Allow the prompt to be customized via the config file
  (bkearney@redhat.com)

* Fri Dec 02 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.20-1
- ueber - fixing cli unit tests
- generate_uebercert -> ubercert in the cli

* Tue Nov 29 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.18-1
- adding template to the system info cli call
- show activation keys in the cli system info

* Mon Nov 28 2011 Tomas Strachota <tstrachota@redhat.com> 0.1.17-1
- cli - fix for spinner being trapped in a loop (tstrachota@redhat.com)
- cli unit tests - cancel product synchronization (tstrachota@redhat.com)
- cli unit tests - option test for SingleProductAction (tstrachota@redhat.com)
- cli - whitespace removal (tstrachota@redhat.com)
- cli unit tests - tests around provider actions (tstrachota@redhat.com)
- sync cli - cancel current provider sync (tstrachota@redhat.com)
- cli - refactoring in provider-centric actions (tstrachota@redhat.com)

* Mon Nov 28 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.16-1
- tdl validations - backend and cli

* Fri Nov 25 2011 Tomas Strachota <tstrachota@redhat.com> 0.1.15-1
- sync cli - repo status fixed according to changes in async taks format
  (tstrachota@redhat.com)
- sync cli - cancelling current product synchronization (tstrachota@redhat.com)
- cli - actions around single products refactored (tstrachota@redhat.com)
- sync cli - actions around single repositories refactored
  (tstrachota@redhat.com)
- sync cli - cancelling current repo sync (tstrachota@redhat.com)
- provider cli - removed needless option '--type' (tstrachota@redhat.com)
- repo blacklist - cli unit tests for repo list (tstrachota@redhat.com)
- Revert "repo blacklist - cli unit tests for repo list"
  (tstrachota@redhat.com)
- repo blacklist - cli unit tests for repo list (tstrachota@redhat.com)
- bug - cli was not working when locale was not set (lzap+git@redhat.com)
- repo blacklist - listing disabled repos in the cli (tstrachota@redhat.com)
- repo blacklist - cli for enabling/disabling repos (tstrachota@redhat.com)
- bug - race condition in the cli spinner (lzap+git@redhat.com)
- template export - checking output format moved to option parser
  (tstrachota@redhat.com)
- template export - disabled exporting templates from Locker envs
  (tstrachota@redhat.com)

* Tue Nov 15 2011 Shannon Hughes <shughes@redhat.com> 0.1.12-1
- Merge branch 'master' into password_reset (bbuckingham@redhat.com)
- cli - removed unused 'flag' argument from a method 'Command#require_option'
  (tstrachota@redhat.com)
- cli - parameter flag determined automatically for required arguments It is no
  longer necessary to pass both expected destination and flag string to the
  'require_option' method when those two are different. (tstrachota@redhat.com)
- Merge branch 'master' into password_reset (bbuckingham@redhat.com)
- Merge branch 'master' into password_reset (bbuckingham@redhat.com)
- Merge branch 'master' into password_reset (bbuckingham@redhat.com)
- cli - add email address to 'user' as a required attribute
  (bbuckingham@redhat.com)

* Thu Nov 10 2011 Shannon Hughes <shughes@redhat.com> 0.1.11-1
- moving system tests into /scripts (lzap+git@redhat.com)
- cli - code reindentation & pep8 fixes (tstrachota@redhat.com)
- repo cli - fixed failure in repo info caused by api not returning all
  information (tstrachota@redhat.com)
- Merge branch 'repo-remodel' of ssh://git.fedorahosted.org/git/katello into
  repo-remodel (paji@redhat.com)
- Fixed the bash script to retrieve the pulp id correctly (paji@redhat.com)
- changeset cli - fix for listing repo names in changeset info
  (tstrachota@redhat.com)
- changeset system tests - removed repo dependency +calling changeset info with
  on changeset with content (tstrachota@redhat.com)
- Merge branch 'master' into repo-remodel (paji@redhat.com)
- removing unnecessary sleep from test (lzap+git@redhat.com)
- bug - error message when registering a system (lzap+git@redhat.com)
- system tests - testing failure of package group listing
  (tstrachota@redhat.com)
- system tests - support for using pulp_repo_id (tstrachota@redhat.com)
- up-to-date fake manifest (lzap+git@redhat.com)
- bug - cli was not reporting nonexisting ak (lzap+git@redhat.com)
- cli tests - fixed wrong mocking of 'save_report' (tstrachota@redhat.com)
- cli tests - test for ping (tstrachota@redhat.com)
- cli ping - return code reflects status of subsystems (tstrachota@redhat.com)
- cli tests - using deepcopy instead of copy in utils for mocking
  (tstrachota@redhat.com)
- cli - better description for 'product promote' (tstrachota@redhat.com)
- cli - support for multiline description of actions (tstrachota@redhat.com)
- cli - support for multiline description of commands (tstrachota@redhat.com)
- 749570 - showing pool id along with subscriptions (lzap+git@redhat.com)
- fixing formatting (lzap+git@redhat.com)
- fixing cli unit tests - one more (lzap+git@redhat.com)
- fixing cli unit tests (lzap+git@redhat.com)
- system tests - changed generating random hash (tstrachota@redhat.com)
- adding new parameter --nodisc for product creation (lzap+git@redhat.com)
- distros - adding cli portion for adding/removing distros
  (lzap+git@redhat.com)
- distros - adding family, variant, version in CLI (lzap+git@redhat.com)
- fxiing merge conflict (jsherril@redhat.com)
- Merge branch 'master' into errata_filter (bbuckingham@redhat.com)
- cli test for 'org subscriptions' command (dmitri@redhat.com)
- subscription start/end dates are now being coverted into human-readable
  format (dmitri@redhat.com)
- sla information is now being added to subscriptions (dmitri@redhat.com)
- added support for listing of subscriptions for an organization
  (dmitri@redhat.com)
- tdl-export - expose template export in the CLI (inecas@redhat.com)
- Break up the cli spec file into a common and katello piece
  (bkearney@redhat.com)
- nvrea-optional - system test for nvrea support (inecas@redhat.com)
- Merge branch 'reports' (dmitri@redhat.com)
- sys tests - enabled org delete test in provider import testsuite
  (tstrachota@redhat.com)
- Merge branch 'master' into errata_filter (bbuckingham@redhat.com)
- improving python code style (lzap+git@redhat.com)
- cli-akeys-pools - show pools in activation key details (inecas@redhat.com)
- cli-akeys-pools - remove subscriptions from a activation kay
  (inecas@redhat.com)
- cli-akeys-pools - add subscription to a key through CLI (inecas@redhat.com)
- merge conflict (jsherril@redhat.com)
- add/remove package updates for cli system test for filters
  (dmitri@redhat.com)
- tests for cli for add/remove package to/from filter (dmitri@redhat.com)
- cli tests for filters (dmitri@redhat.com)
- added support for updating of package lists of filters (dmitri@redhat.com)
- merge conflict (jsherril@redhat.com)
- pools - adding multi entitlement flag to the list (cli) (lzap+git@redhat.com)
- pools - making use of system.available_pools_full (lzap+git@redhat.com)
- pools - listing of available pools (lzap+git@redhat.com)
- added filter-related tests to cli-tests (dmitri@redhat.com)
- added tests for filter operations in katello cli (dmitri@redhat.com)
- more product-filter association tests for cli (dmitri@redhat.com)
- added product-filter association tests for cli (dmitri@redhat.com)
- errata-filters - filter all errata for a product (inecas@redhat.com)
- merge conflict (jsherril@redhat.com)
- fogot to commit some filter-related files (for cli) (dmitri@redhat.com)
- added support for listing/adding/removing filters to/from products from
  katello cli (dmitri@redhat.com)
- added support for filter create/list/show/delete operations in katello cli
  (dmitri@redhat.com)
- errata-filters - API and CLI support for filtering on severity
  (inecas@redhat.com)
- errata-filters - API and CLI restrict filtering errata on an environment
  (inecas@redhat.com)
- errata-filters - API and CLI allow errata filtering on multiple repos
  (inecas@redhat.com)
- errata-filters - API and CLI support for filtering errata by type
  (inecas@redhat.com)
- errata-filters - cli support for filtering errata by type (inecas@redhat.com)
- cli - disabled two pylint false alarms (tstrachota@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (bkearney@redhat.com)
- pulp-repo-secured - system test for chekcing the seruted repo
  (inecas@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (bkearney@redhat.com)
- Small refactoring (inecas@redhat.com)
- New cli strings pushed (bkearney@redhat.com)
- repo delete - cli unit test (tstrachota@redhat.com)
- added more cli report tests (dmitri@redhat.com)
- Fix index error when printing cli table (inecas@redhat.com)
- recreated cli report tests (dmitri@redhat.com)
- re-created reports functionality after botched merge (dmitri@redhat.com)
- 743883 - propper testing on provided url (inecas@redhat.com)
- repo delete - enabled in system tests (tstrachota@redhat.com)
- repo cli - refactored way of getting repos (tstrachota@redhat.com)
- repo delete - cli for deleting single repos (tstrachota@redhat.com)
- 741274 - correct displaying of unicode values in info (inecas@redhat.com)
- 741274 - correct displaying of unicode values in listings (inecas@redhat.com)
- system tests - added option for disabling the base cleanup test -c or
  --nocleanup (tstrachota@redhat.com)
- cli unit tests - test for product delete (tstrachota@redhat.com)
- system tests - enabled removing products in cleanup test
  (tstrachota@redhat.com)
- products - cli for removing products (tstrachota@redhat.com)
- fix for katello-reset-dbs - pgsql support for initdb - typo
  (lzap+git@redhat.com)
- sms - list of certificates in the cli (lzap+git@redhat.com)
- sms - refactoring subscription -> subscriptions path (lzap+git@redhat.com)
- sms - moving subscriptions list action into the backend (lzap+git@redhat.com)
- sms - moving unsubscribe action into the backend (lzap+git@redhat.com)
- 723308 - show names instead of ids in cli environment info
  (inecas@redhat.com)
- disabling one system cli test due to bug (lzap+git@redhat.com)
- sms - subscriptions cli command (lzap+git@redhat.com)
- templates - removed old way of promoting templates directly
  (tstrachota@redhat.com)
- cli unit tests - added exit code tests for template update
  (tstrachota@redhat.com)
- cli unit tests - tests for template update (tstrachota@redhat.com)
- packagegroups - parameter 'repoid' changed to 'repo_id' to keep the cli
  consistent (tstrachota@redhat.com)
- system tests - fix for problem with dependencies test for templates require
  packagegroups (tstrachota@redhat.com)
- packagegroups cli - removed pprint form command 'info'
  (tstrachota@redhat.com)
- system tests - update of parameters for templat cli in changeset test
  (tstrachota@redhat.com)
- packagegroups - fixes in unit tests Fixes for testing api that returns arrays
  instead of hashes. (tstrachota@redhat.com)
- packagegroups - cli changed to work with array returned from api instead of
  hashes that were returned formerly (tstrachota@redhat.com)
- templates - system tests for updates (tstrachota@redhat.com)
- templates cli - update command exits when product was not found
  (tstrachota@redhat.com)
- package groups - groups and group categories returned in an array instead of
  in a hash (tstrachota@redhat.com)
- cli - removed deprecated '<>' (tstrachota@redhat.com)
- templates cli - removed old route for content update (tstrachota@redhat.com)
- templates cli - command 'update_content' removed (tstrachota@redhat.com)
- templates cli - package groups and group categories added to update
  (tstrachota@redhat.com)
- templates cli - content update using new api (tstrachota@redhat.com)
- providing final system test fix for RH autocreation (lzap+git@redhat.com)
- fixing provider import after providers branch merge (lzap+git@redhat.com)
- correcting system test for default RH provider (lzap+git@redhat.com)
- sms - improving default value for quantity (lzap+git@redhat.com)
- cli - removed default value from get_option It was colliding with default
  value from optparse and as a result the default value from get_option was
  never used. (tstrachota@redhat.com)
- sms - cli system subscribe command (lzap+git@redhat.com)
- sms - remove a subscription from a machine (lzap+git@redhat.com)
- updated bin/katello to show correct names for uebercert-related commands
  (dmitri@redhat.com)
- Revert "BZ 741357: fixed a spelling mistake in katello-jobs.init"
  (dmitri@redhat.com)
- BZ 741357: fixed a spelling mistake in katello-jobs.init (dmitri@redhat.com)
- added cli support for generation/retrieval of uebercerts (dmitri@redhat.com)
- templates cli - fix for printing None instead of Locker in template list
  (tstrachota@redhat.com)
- system tests - new tests for templates and changesets (tstrachota@redhat.com)
- templates api - fix for getting template by name (tstrachota@redhat.com)
- cli unit tests - updated template package test data - added nvre information
  - removed errata (tstrachota@redhat.com)
- templates cli - showing nvre in tepmlate info (tstrachota@redhat.com)
- templates cli - removed errata from template info (tstrachota@redhat.com)
- changesets - cli support for adding template to changesets
  (tstrachota@redhat.com)
- templates cli - removed errata from updates (tstrachota@redhat.com)
- system tests - added function for checking katello jobs
  (tstrachota@redhat.com)
- system tests - added test_success and test_failure methods
  (tstrachota@redhat.com)
- system templates - refactoring - removed ordering by numbers in filename -
  added ability to define required test suites to run them prior the current
  test suite - added function for printing a suite header, headers must be
  printed in the test files now (tstrachota@redhat.com)
- packagegroup-templates - fix failing cli unit tests (inecas@redhat.com)
- packagegroups-templates - show comps in template info (inecas@redhat.com)
- 732007 - enhanced error message in CLI (inecas@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (dmitri@redhat.com)
- 733266 - new option type bool to handle True/False options
  (inecas@redhat.com)
- 734882 - User-Agent header in katello-cli and custom error messages
  (inecas@redhat.com)
- Merge branch 'uebercert' (dmitri@redhat.com)
- 736247 - correct error message on unauthorized access (inecas@redhat.com)
- system-tests - script for generating code coverage (inecas@redhat.com)
- adding copyright and modeline to our spec files (lzap+git@redhat.com)
- packagegroups - cli system test helpers methods to separate file
  (inecas@redhat.com)
- 737563 - adding more rhsm system testing (lzap+git@redhat.com)
- 737563 - improving rhsm system testing (lzap+git@redhat.com)
- 737563 - adding more rhsm system testing (lzap+git@redhat.com)
- 737563 - adding more rhsm system tests (lzap+git@redhat.com)
- cli coverage - added --cover-inclusive to get report for all files and not
  only for those with tests. Helps finding holes in the coverage.
  (tstrachota@redhat.com)
- system tests - added check for existing test suites (tstrachota@redhat.com)
- templates cli - fix for typo in route (tstrachota@redhat.com)
- templates api - route for listing templates in an environment
  (tstrachota@redhat.com)
- added test coverage target to katello cli Makefile (dmitri@redhat.com)
- packagegroups - name cli tests using convention (inecas@redhat.com)
- packagegroups-templates - CLI for package group categories in templates
  (inecas@redhat.com)
- system-tests - refactor - use function for getting repo_id
  (inecas@redhat.com)
- packagegroups-templates - CLI system tests (inecas@redhat.com)
- packagegroups-templates - CLI for package groups in templates
  (inecas@redhat.com)
- 737591 - format function was missing positional arguments method str.format
  requires positional argument specifiers in Python < 2.7
  (tstrachota@redhat.com)
- system tests - temporarily disabled deleting a provider in provider_import
  test until we fix the bug (tstrachota@redhat.com)
- cli - removed unused imports (tstrachota@redhat.com)
- Change the default client config to work with thin/apache
  (bkearney@redhat.com)
- Merge branch 'master' into thin (mmccune@redhat.com)
- Merge branch 'master' into thin (mmccune@redhat.com)
- CLI - client.conf - update path to default to /katello
  (bbuckingham@redhat.com)
- ueber cert - adding cli support (lzap+git@redhat.com)

* Thu Sep 08 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.10-1
- cli - deprecated 'has_key' replaced by 'in'
- cli - reindented .py scripts
- system tests - fix for unknown parameter in template test removed
  --environment parameter that is no longer used in template update action
- templates cli - typo in function parameter
- cli unittests - tests for template command + mock utility can now set also
  None as return value
- template cli - removed environment option from create/update actions -
  affected actions: import, create, update, update_content - environment option
  in promote action made required
- packagegroups - don't print curl output in system test

* Tue Sep 06 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.9-1
- cli - bumping cli version because of tito bug

* Tue Sep 06 2011 Lukas Zapletal <lzap+git@redhat.com>
- system test - moving cli_tests into cli/test-system
- Fix missing import in CLI
- Cli unit tests for package group categories
- Cli unit tests for package groups
- Cli support for package groups and package group categories
- 730358 - repo discovery now uses asynchronous tasks - the route has been
  changed to /organizations/ID/repositories/discovery/
- Move the cli over to the public zanata server
- cli packages - listing now same as rpm -q for system packages
- 735038 - Storing an option as root fails when .katello does not exist
- cli - disabled two pylint false alarms
- cli - new behaviour of verbose/grep output switching - for printing single
  item verbose is default - for printing collection of items grep is default -
  can be forced by flags -v, -g or in the config file
- repo cli - parameter --repo_id renamed to --id to make the cli uniform
- cli - fix for format_date returning only current time
- cli tests - files renamed according to pattern COMMAND_ACTION_test.py
- cli tests - provider status test
- cli tests - fixed typo in product status options test
- cli tests - fixed test for provider sync
- provider sync status - cli + api
- cli tests - repo status
- cli - fix for key error in getting error details from async tasks
- Refactor providers - remove unused routes

* Wed Aug 31 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.7-1
- Scope products by readability scope
- Refactor - move providers from OrganziationController

* Mon Aug 29 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.6-1
- cli - fixes for several typos
- cli tests - removed call of nonexisting function
- cli - product and repo uses AsyncTask
- cli - changeset promotion fix
- fix for cli issues with removed cp_id
- cli tests - product promote 2
- cli tests - product promote
- cli tests - product status
- cli tests - product sync
- cli tests - tests for listing and creation use common test data
- cli tests - test data
- product cli - fix for using wrong field from hash
- cli tests - product list
- cli tests - added mocking for printer to utils
- products cli - now displaying provider name
- sync cli - sync format functions refactoring
- products cli - fixed commands according to recent changes
- products cli - added action status
- cli repo status - displaying synchronization progress
- cli - asynchronous tasks refactored
- repo status - repo now defined also by org,product,env and name
- katello-cli - storing options to client-options.conf
- katello-cli - adding LICENSE and README with unit test info
- katelli-cli spec changelog cleanup
- 723308 - verbose environment information should list names not ids
- simple puppet scripts
- cli unittests - fix in testing parameters 2
- cli unittests - fix in testing parameters tests were using stored values from
  config files
- repo cli - all '--repo' renamed to '--name' to make the paramaters consistent
  accross the cli
- fix for cli repo sync failing when sync was unsuccessful
- cli test utils - renamed variable
- cli unit tests for repo sync + cli test utils
- more tests for provider sync cli
- added provider sync tests for cli
- fixed failing product creation tests for cli
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
- Get translations in for the cli
- repo sync - check for syncing only repos in locker
- Automatic commit of package [katello-cli] release [0.1.5-1].
- 731446 - more variable name fixes

* Thu Aug 18 2011 Mike McCune <mmccune@redhat.com> 0.1.5-1
- periodic retag of the cli package

* Mon Aug 01 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.4-1
- spec - rpmlint cleanup
- Added api support for activation keys
- Turn on package updating
- Bug 725719 - Simple CLI tests are failing with -s parameter
- Bug 726416 - Katello-cli is failing on some terminals

* Tue Jul 26 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.3-1
- redhat provider - changing rhn to redhat in the cli
- spec - fixing files section of katello-cli
- spec - adding katello-cli package initial version

* Mon Jul 25 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.2-1
- spec - fixing files section of katello-cli

* Mon Jul 25 2011 Lukas Zapletal 0.1.1-1
- initial version
