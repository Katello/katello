%define base_name katello

Name:          %{base_name}-cli
Summary:       Client package for managing application lifecycle for Linux systems
Group:         Applications/System
License:       GPLv2
URL:           http://www.katello.org
Version:       0.1.1
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
Provides a client package for managing application lifecycle
for Linux systems


%prep
%setup -q


%build


%install
rm -rf $RPM_BUILD_ROOT
#install -d $RPM_BUILD_ROOT%{python_sitelib}/%{base_name}
install -Dpm 0644 bin/%{base_name} $RPM_BUILD_ROOT%{_bindir}
install -Dpm 0644 etc/client.conf $RPM_BUILD_ROOT%{_sysconfdir}/%{base_name}
install -Dpm 0644 src/%{base_name}/*.py $RPM_BUILD_ROOT%{python_sitelib}/
install -Dpm 0644 src/%{base_name}/client/*.py $RPM_BUILD_ROOT%{python_sitelib}/client/
install -Dpm 0644 src/%{base_name}/client/api/*.py $RPM_BUILD_ROOT%{python_sitelib}/client/api/
install -Dpm 0644 src/%{base_name}/client/cli/*.py $RPM_BUILD_ROOT%{python_sitelib}/client/cli/
install -Dpm 0644 src/%{base_name}/client/core/*.py $RPM_BUILD_ROOT%{python_sitelib}/client/core/


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root)
%{python_sitelib}/%{base_name}/
%attr(755,root,root) %{_bindir}/%{base_name}
%config(noreplace) %attr(644,root,root) %{_sysconfdir}/etc/%{base_name}
#%{_mandir}/man8/%{base_name}.8*


%changelog
* Mon Jul 25 2011 Lukas Zapletal <lzap+rpm[@]redhat.com> - 0.1.1-1
- initial version
