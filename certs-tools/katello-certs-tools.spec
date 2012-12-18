Name: katello-certs-tools
Summary: Katello SSL Key/Cert Tool
Group: Applications/Internet
License: GPLv2
Version: 1.3.0
Release: 1%{?dist}
URL:      https://fedorahosted.org/katello
Source0:  https://fedorahosted.org/releases/k/a/katello/%{name}-%{version}.tar.gz
BuildArch: noarch
Requires: openssl rpm-build
BuildRequires: docbook-utils
BuildRequires: python

%description
This package contains tools to generate the SSL certificates required by
Katello.

%prep
%setup -q

%build
/usr/bin/docbook2man katello-ssl-tool.sgml
%{__python} setup.py build

%install
%{__python} setup.py install --skip-build --root $RPM_BUILD_ROOT
chmod +x $RPM_BUILD_ROOT/%{python_sitelib}/certs/katello_ssl_tool.py

%files
%{python_sitelib}/*
%{_datarootdir}/katello/certs
%attr(755,root,root) %{_datarootdir}/katello/certs/*.sh
%attr(755,root,root) %{_bindir}/katello-sudo-ssl-tool
%attr(755,root,root) %{_bindir}/katello-ssl-tool
%doc %{_mandir}/man1/katello-*.1*
%doc LICENSE

%changelog
* Fri Oct 12 2012 Lukas Zapletal <lzap+git@redhat.com> 1.1.9-1
- updating copyrights

* Sat Aug 11 2012 Miroslav Suchý <msuchy@redhat.com> 1.1.8-1
- various pylint cleaning
- there is no Python license in cert-tools (msuchy@redhat.com)
- buildroot and %%clean section is not needed (msuchy@redhat.com)

* Tue Jul 31 2012 Miroslav Suchý <msuchy@redhat.com> 1.1.7-1
- update copyright years (msuchy@redhat.com)
- %%defattr is not needed since rpm 4.4 (msuchy@redhat.com)

* Thu May 10 2012 Lukas Zapletal <lzap+git@redhat.com> 1.1.6-1
- 818261 - consumer rpm was not installable on RHEL5

* Thu Mar 22 2012 Mike McCune <mmccune@redhat.com> 1.1.5-1
- 781210 - remove from specfile a txt file that was removed in dcdde7a876
  (mmccune@redhat.com)

* Tue Mar 20 2012 Lukas Zapletal <lzap+git@redhat.com> 1.1.4-1
- 781210 - cert tools man page review

* Tue Mar 06 2012 Mike McCune <mmccune@redhat.com> 1.1.3-1
- 800093 - CRL was non functional without these config options
  (jmatthew@redhat.com)
- 788708 - removing legacy bootstrap script and generator (lzap+git@redhat.com)

* Mon Feb 27 2012 Lukas Zapletal <lzap+git@redhat.com> 1.1.2-1
- 761314 - Make sure katello-agent communicates with ssl
- 790835 - Create bootstrap RPM package with cons. cert

* Wed Feb 22 2012 Mike McCune <mmccune@redhat.com> 1.1.1-1
- version bump

* Fri Jan 13 2012 Martin Bačovský <mbacovsk@redhat.com> 1.0.2-1
- 760305 - Remove names and references to 'rhn' from cert-tools
  (mbacovsk@redhat.com)

* Mon Dec 05 2011 Lukas Zapletal <lzap+git@redhat.com> 1.0.1-1
- new package built with tito

* Mon Nov 14 2011 Tomas Lestach <tlestach@redhat.com> 1.0.0-1
- introduce katello-cert-tools based on spacewalk-cert-tools 1.6.6-1
