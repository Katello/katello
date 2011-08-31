%define base_name katello

Name:          %{base_name}-cli
Summary:       Client package for managing application life-cycle for Linux systems
Group:         Applications/System
License:       GPLv2
URL:           http://www.katello.org
Version:       0.1.7
Release:       1%{?dist}
Source0:       %{name}-%{version}.tar.gz
BuildRoot:     %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

Requires:      python-iniparse
Requires:      python-simplejson
Requires:      m2crypto
Requires:      python-kerberos

BuildRequires: python2-devel
BuildRequires: gettext

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
install -d $RPM_BUILD_ROOT%{_sysconfdir}/%{base_name}/
install -d $RPM_BUILD_ROOT%{python_sitelib}/%{base_name}
install -d $RPM_BUILD_ROOT%{python_sitelib}/%{base_name}/client
install -d $RPM_BUILD_ROOT%{python_sitelib}/%{base_name}/client/api
install -d $RPM_BUILD_ROOT%{python_sitelib}/%{base_name}/client/cli
install -d $RPM_BUILD_ROOT%{python_sitelib}/%{base_name}/client/core
install -pm 0644 bin/%{base_name} $RPM_BUILD_ROOT%{_bindir}/%{base_name}
install -pm 0644 etc/client.conf $RPM_BUILD_ROOT%{_sysconfdir}/%{base_name}/client.conf
install -pm 0644 src/%{base_name}/*.py $RPM_BUILD_ROOT%{python_sitelib}/%{base_name}/
install -pm 0644 src/%{base_name}/client/*.py $RPM_BUILD_ROOT%{python_sitelib}/%{base_name}/client/
install -pm 0644 src/%{base_name}/client/api/*.py $RPM_BUILD_ROOT%{python_sitelib}/%{base_name}/client/api/
install -pm 0644 src/%{base_name}/client/cli/*.py $RPM_BUILD_ROOT%{python_sitelib}/%{base_name}/client/cli/
install -pm 0644 src/%{base_name}/client/core/*.py $RPM_BUILD_ROOT%{python_sitelib}/%{base_name}/client/core/


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root)
%doc README LICENSE
%{python_sitelib}/%{base_name}/
%attr(755,root,root) %{_bindir}/%{base_name}
%config(noreplace) %attr(644,root,root) %{_sysconfdir}/%{base_name}/client.conf
#%{_mandir}/man8/%{base_name}.8*


%changelog
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
