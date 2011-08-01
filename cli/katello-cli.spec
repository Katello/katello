%define base_name katello

Name:          %{base_name}-cli
Summary:       Client package for managing application life-cycle for Linux systems
Group:         Applications/System
License:       GPLv2
URL:           http://www.katello.org
Version:       0.1.3
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
%{python_sitelib}/%{base_name}/
%attr(755,root,root) %{_bindir}/%{base_name}
%config(noreplace) %attr(644,root,root) %{_sysconfdir}/%{base_name}/client.conf
#%{_mandir}/man8/%{base_name}.8*


%changelog
* Tue Jul 26 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.3-1
- redhat provider - changing rhn to redhat in the cli
- spec - fixing files section of katello-cli
- spec - adding katello-cli package initial version

* Mon Jul 25 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.2-1
- spec - fixing files section of katello-cli

* Mon Jul 25 2011 Lukas Zapletal 0.1.1-1
- initial version
