%{!?python_sitelib: %global python_sitelib %(%{__python} -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")}

Name: katello-agent
Version: 0.10
Release: 1%{?dist}
Summary: The Katello Agent
Group:   Development/Languages
License: LGPLv2
URL: https://fedorahosted.org/pulp/
Source0: %{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch: noarch
BuildRequires: python2-devel
BuildRequires: python-setuptools
BuildRequires: rpm-python
Requires: gofer >= 0.54
Requires: gofer-package >= 0.54
Requires: subscription-manager
%description
The Katello agent.

%prep
%setup -q

%build
pushd src
%{__python} setup.py build
popd

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}/%{_sysconfdir}/gofer/plugins
mkdir -p %{buildroot}/%{_libdir}/gofer/plugins

cp etc/gofer/plugins/katelloplugin.conf %{buildroot}/%{_sysconfdir}/gofer/plugins
cp src/katello/agent/katelloplugin.py %{buildroot}/%{_libdir}/gofer/plugins

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%config(noreplace) %{_sysconfdir}/gofer/plugins/katelloplugin.conf
%{_libdir}/gofer/plugins/katelloplugin.*
%doc LICENSE

%changelog
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
