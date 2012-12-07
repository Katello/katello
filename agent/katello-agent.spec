Name: katello-agent
Version: 1.3.0
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
Requires: gofer >= 0.60
Requires: gofer-package >= 0.60
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

%files
%config(noreplace) %{_sysconfdir}/gofer/plugins/katelloplugin.conf
%{_prefix}/lib/gofer/plugins/katelloplugin.*
%doc LICENSE

%changelog
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

* Mon Mar 19 2012 Ivan Necas <inecas@redhat.com> 1.0.3-1
- 770693 - handle repos without repofile in katello-agent (inecas@redhat.com)

* Mon Feb 27 2012 Lukas Zapletal <lzap+git@redhat.com> 1.0.2-1
- 761314 - Make sure katello-agent communicates with ssl

* Wed Feb 22 2012 Mike McCune <mmccune@redhat.com> 1.0.1-1
- version bump

* Tue Feb 07 2012 Lukas Zapletal <lzap+git@redhat.com> 0.14-1
- Fixing agent conf file to match katello wiki page.  Removing now-superfluous
  install step from wiki.
- agent: final API call payload for reporting enabled repos.
- agent: send enabled repos report.

* Thu Dec 08 2011 Mike McCune <mmccune@redhat.com> 0.13-1
- moving client/ to agent/, more appropriate (mmccune@redhat.com)

* Thu Nov 10 2011 Mike McCune <mmccune@redhat.com> 0.12-1
- re-adding license file

* Thu Nov 10 2011 Mike McCune <mmccune@redhat.com> 0.11-1
- import into Katello's src

* Mon Oct 31 2011 Jeff Ortel <jortel@redhat.com> 0.10-1
- Fix typo. (jortel@redhat.com)

* Mon Oct 31 2011 Jeff Ortel <jortel@redhat.com> 0.9-1
- Correct spelling of bundle.pem (jortel@redhat.com)

* Thu Oct 27 2011 Jeff Ortel <jortel@redhat.com> 0.8-1
- requires gofer 0.54. (jortel@redhat.com)
- Update registration monitor. (jortel@redhat.com)

* Thu Oct 27 2011 Jeff Ortel <jortel@redhat.com> 0.7-1
- migrate to using pmon. (jortel@redhat.com)

* Tue Oct 25 2011 Jeff Ortel <jortel@redhat.com> 0.6-1
- Use the bundled cert. (jortel@redhat.com)
- Apply fixes from testing. (jortel@redhat.com)

* Tue Oct 25 2011 Jeff Ortel <jortel@redhat.com> 0.5-1
- Apply fixes from testing. (jortel@redhat.com)

* Mon Oct 24 2011 Jeff Ortel <jortel@redhat.com> 0.4-1
- Require gofer-package. (jortel@redhat.com)

* Mon Oct 24 2011 Jeff Ortel <jortel@redhat.com> 0.3-1
- Refit for Plugin.export(). (jortel@redhat.com)

* Thu Oct 13 2011 Jeff Ortel <jortel@redhat.com> 0.2-1
- Build fixes. (jortel@redhat.com)

* Thu Oct 13 2011 Jeff Ortel <jortel@redhat.com> 0.1-1
- new package built with tito
