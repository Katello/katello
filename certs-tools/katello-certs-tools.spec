Name: katello-certs-tools
Summary: Katello SSL Key/Cert Tool
Group: Applications/Internet
License: GPLv2 and Python
Version: 1.0.1
Release: 2%{?dist}
URL:      https://fedorahosted.org/katello
Source0:  https://fedorahosted.org/releases/k/a/katello/%{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
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
/usr/bin/docbook2man rhn-bootstrap.sgml
/usr/bin/docbook2man rhn-ssl-tool.sgml
%{__python} setup.py build

%install
rm -rf $RPM_BUILD_ROOT
%{__python} setup.py install --skip-build --root $RPM_BUILD_ROOT
chmod +x $RPM_BUILD_ROOT/%{python_sitelib}/certs/client_config_update.py
chmod +x $RPM_BUILD_ROOT/%{python_sitelib}/certs/rhn_bootstrap.py
chmod +x $RPM_BUILD_ROOT/%{python_sitelib}/certs/rhn_ssl_tool.py

%clean
rm -rf $RPM_BUILD_ROOT

%files
%{python_sitelib}/*
%{_datarootdir}/katello/certs
%attr(755,root,root) %{_datarootdir}/katello/certs/*.sh
%attr(755,root,root) %{_bindir}/rhn-sudo-ssl-tool
%attr(755,root,root) %{_bindir}/rhn-ssl-tool
%attr(755,root,root) %{_bindir}/rhn-bootstrap
%doc %{_mandir}/man1/rhn-*.1*
%doc LICENSE PYTHON-LICENSES.txt
%doc ssl-howto-simple.txt ssl-howto.txt
%attr(755,root,root) %{_var}/www/html/pub/bootstrap/client_config_update.py*

%changelog
* Mon Dec 05 2011 Lukas Zapletal <lzap+git@redhat.com> 1.0.1-1
- new package built with tito

* Mon Nov 14 2011 Tomas Lestach <tlestach@redhat.com> 1.0.0-1
- introduce katello-cert-tools based on spacewalk-cert-tools 1.6.6-1
