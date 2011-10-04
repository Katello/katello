
%global homedir %{_datarootdir}/katello/install/puppet/modules

Name:           katello-configure
Version:        0.1.4
Release:        1%{?dist}
Summary:        Configuration tool for Katello

Group:          Applications/Internet
License:        GPLv2
URL:            http://www.katello.org
Source0:        %{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

Requires:       puppet >= 2.6.6

BuildArch: noarch

%description
Provides katello-configure script which configures Katello installation.

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
#prepare dir structure
install -d -m 0755 %{buildroot}%{homedir}
install -d -m 0755 %{buildroot}%{_sbindir}
cp -Rp modules/* %{buildroot}%{homedir}
install -m 0755 bin/katello-configure %{buildroot}%{_sbindir}

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root)
%{homedir}
%{_sbindir}/katello-configure

%changelog
* Mon Oct 03 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.4-1
- added missing template required for commit:a37cdbe8
- moved pulp config files into the pulp module, extracted values as varaibles
  etc

* Fri Sep 30 2011 Ivan Necas <inecas@redhat.com> 0.1.3-1
- 741551 - ensure pulp config is prepared before httpd starts
- do not enable pulp-testing repo
- Set pulp repo secured
- replaced pub key used by hudson
- added ssh public key for hudson job

* Mon Sep 19 2011 Mike McCune <mmccune@redhat.com> 0.1.2-1
- Correcting previous tag that was pushed improperly 
* Wed Sep 14 2011 Mike McCune <mmccune@redhat.com> 0.1.1-1
- new package built with tito

* Wed Sep 14 2011 Jan Pazdziora 0.1.1-1
- Initial package.

