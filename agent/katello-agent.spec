Name: katello-agent
Version: 1.3.1
Release: 1%{?dist}
Summary: The Katello Agent
Group:   Development/Languages
License: LGPLv2
URL:     https://fedorahosted.org/katello/
Source0: https://fedorahosted.org/releases/k/a/katello/%{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch: noarch
BuildRequires: python2-devel
BuildRequires: python-setuptools
BuildRequires: rpm-python
Requires: gofer >= 0.74
Requires: python-pulp-agent-lib >= 2.0.5
Requires: pulp-rpm-handlers >= 2.0.5
Requires: subscription-manager

%description
Provides plugin for gofer, which allows communicating with Katello server
and execute scheduled actions.

%prep
%setup -q

%build
pushd src
%{__python} setup.py build
popd

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}/%{_sysconfdir}/gofer/plugins
mkdir -p %{buildroot}/%{_prefix}/lib/gofer/plugins

cp etc/gofer/plugins/katelloplugin.conf %{buildroot}/%{_sysconfdir}/gofer/plugins
cp src/katello/agent/katelloplugin.py %{buildroot}/%{_prefix}/lib/gofer/plugins

%clean
rm -rf %{buildroot}

%postun
LC_ALL=C service goferd status | grep 'is running' && service goferd restart

%files
%config(noreplace) %{_sysconfdir}/gofer/plugins/katelloplugin.conf
%{_prefix}/lib/gofer/plugins/katelloplugin.*
%doc LICENSE

%changelog
* Mon Jan 07 2013 Justin Sherrill <jsherril@redhat.com> 1.3.1-1
- Refit agent for pulp v2. (jortel@redhat.com)

* Fri Oct 12 2012 Lukas Zapletal <lzap+git@redhat.com> 1.1.3-1
- 

* Fri Aug 24 2012 Miroslav Suchý <msuchy@redhat.com> 1.1.2-1
- 845643 - consistently use rpm macros (msuchy@redhat.com)

* Thu Aug 23 2012 Mike McCune <mmccune@redhat.com> 1.1.1-1
- buildroot and %%clean section is not needed (msuchy@redhat.com)
- Bumping package versions for 1.1. (msuchy@redhat.com)

* Tue Jul 31 2012 Miroslav Suchý <msuchy@redhat.com> 1.0.6-1
- update copyright years (msuchy@redhat.com)
- point Source0 to fedorahosted.org where tar.gz are stored (msuchy@redhat.com)

* Fri Jul 27 2012 Lukas Zapletal <lzap+git@redhat.com> 1.0.5-1
- macro python_sitelib is not used anywhere, removing
- provide more descriptive description
- put plugins into correct location
- build root is not used since el6 (inclusive)
- point URL to our wiki
- %%defattr is not needed since rpm 4.4

* Wed Jun 27 2012 Lukas Zapletal <lzap+git@redhat.com> 1.0.4-1
- 828533 - changing to proper QPIDD SSL port
