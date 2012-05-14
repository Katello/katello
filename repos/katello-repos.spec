
Name:           katello-repos
Version:        0.2.2
Release:        1%{?dist}
Summary:        Definition of yum repositories for Katello

Group:          Applications/Internet
License:        GPLv2
URL:            http://www.katello.org
Source0:        %{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildArch:      noarch

%description
Defines yum repositories for Katello and its subprojects, Candlepin and Pulp.

%package testing
Summary:        Definition of yum testing repositories for Katello

%description testing
Defines yum testing repositories for Katello and its subprojects,
Candlepin and Pulp.

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
#prepare dir structure
install -d -m 0755 %{buildroot}%{_sysconfdir}/yum.repos.d

%if 0%{?fedora}
install -m 644 fedora-katello.repo %{buildroot}%{_sysconfdir}/yum.repos.d/katello.repo
install -m 644 fedora-katello-testing.repo %{buildroot}%{_sysconfdir}/yum.repos.d/katello-testing.repo
install -m 644 fedora-candlepin.repo %{buildroot}%{_sysconfdir}/yum.repos.d/candlepin.repo
install -m 644 fedora-pulp.repo %{buildroot}%{_sysconfdir}/yum.repos.d/pulp.repo
install -m 644 fedora-pulp-testing.repo %{buildroot}%{_sysconfdir}/yum.repos.d/pulp-testing.repo
install -m 644 fedora-thumbslug.repo %{buildroot}%{_sysconfdir}/yum.repos.d/thumbslug.repo
%endif

%if 0%{?rhel}
install -m 644 rhel-katello.repo %{buildroot}%{_sysconfdir}/yum.repos.d/katello.repo
install -m 644 rhel-katello-testing.repo %{buildroot}%{_sysconfdir}/yum.repos.d/katello-testing.repo
install -m 644 rhel-candlepin.repo %{buildroot}%{_sysconfdir}/yum.repos.d/candlepin.repo
install -m 644 rhel-pulp.repo %{buildroot}%{_sysconfdir}/yum.repos.d/pulp.repo
install -m 644 rhel-pulp-testing.repo %{buildroot}%{_sysconfdir}/yum.repos.d/pulp-testing.repo
install -m 644 rhel-thumbslug.repo %{buildroot}%{_sysconfdir}/yum.repos.d/thumbslug.repo
%endif

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root)
%{_sysconfdir}/yum.repos.d/candlepin.repo
%{_sysconfdir}/yum.repos.d/katello.repo
%{_sysconfdir}/yum.repos.d/pulp.repo
%{_sysconfdir}/yum.repos.d/thumbslug.repo

%files testing
%defattr(-,root,root)
%{_sysconfdir}/yum.repos.d/katello-testing.repo
%{_sysconfdir}/yum.repos.d/pulp-testing.repo

%changelog
* Fri Apr 27 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.2-1
- correcting pulp testing repofile url

* Wed Feb 22 2012 Mike McCune <mmccune@redhat.com> 0.2.1-1
- version bump

* Thu Feb 16 2012 Mike McCune <mmccune@redhat.com> 0.1.8-1
- Revert "repos - updating pulp stable/testing CR repos" (mmccune@redhat.com)

* Thu Feb 16 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.7-1
- repos - updating pulp stable/testing CR repos

* Wed Feb 01 2012 Mike McCune <mmccune@redhat.com> 0.1.6-1
- Switching to inlined packages for candlepin and pulp (mmccune@redhat.com)

* Fri Jan 13 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.5-1
- adding katello-repos-testing rpm package

* Tue Nov 29 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.4-1
- Add yum repos for thumbslug

* Tue Sep 20 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.3-1
- no Requires of puppet in katello-repos

* Mon Sep 19 2011 Mike McCune <mmccune@redhat.com> 0.1.2-1
- Correcting previous tag that was pushed improperly  (mmccune@redhat.com)
* Wed Sep 14 2011 Mike McCune <mmccune@redhat.com> 0.1.1-1
- new package built with tito

* Wed Sep 14 2011 Jan Pazdziora 0.1.1-1
- Initial package.

