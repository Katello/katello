
Name:           katello-repos
Version:        0.1.1
Release:        1%{?dist}
Summary:        Definition of yum repositories for Katello

Group:          Applications/Internet
License:        GPLv2
URL:            http://www.katello.org
Source0:        %{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

Requires:       puppet

BuildArch:      noarch

%description
Defines yum repositories for Katello and its subprojects, Candlepin and Pulp.

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
#prepare dir structure
install -d -m 0755 %{buildroot}%{_sysconfdir}/yum.repos.d

%if 0%{?fedora}
install -m 644 fedora-katello.repo %{buildroot}%{_sysconfdir}/yum.repos.d/katello.repo
install -m 644 fedora-candlepin.repo %{buildroot}%{_sysconfdir}/yum.repos.d/candlepin.repo
install -m 644 fedora-pulp.repo %{buildroot}%{_sysconfdir}/yum.repos.d/pulp.repo
%endif

%if 0%{?rhel}
install -m 644 rhel-katello.repo %{buildroot}%{_sysconfdir}/yum.repos.d/katello.repo
install -m 644 rhel-candlepin.repo %{buildroot}%{_sysconfdir}/yum.repos.d/candlepin.repo
install -m 644 rhel-pulp.repo %{buildroot}%{_sysconfdir}/yum.repos.d/pulp.repo
%endif

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root)
%{_sysconfdir}/yum.repos.d/*.repo

%changelog
* Wed Sep 14 2011 Jan Pazdziora 0.1.1-1
- Initial package.

