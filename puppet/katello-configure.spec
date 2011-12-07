
%global homedir %{_datarootdir}/katello/install

Name:           katello-configure
Version:        0.1.26
Release:        1%{?dist}
Summary:        Configuration tool for Katello

Group:          Applications/Internet
License:        GPLv2
URL:            http://www.katello.org
Source0:        %{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

Requires:       puppet >= 2.6.6
Requires:       wget
Requires:       katello-certs-tools
Requires:       nss-tools
BuildRequires:  /usr/bin/pod2man

BuildArch: noarch

%description
Provides katello-configure script which configures Katello installation.

%prep
%setup -q

%build

THE_VERSION=%version perl -000 -ne 'if ($X) { s/^THE_VERSION/$ENV{THE_VERSION}/; s/\s+CLI_OPTIONS/$C/; s/^CLI_OPTIONS_LONG/$X/; print; next } ($t, $l, $v, $d) = /^#\s*(.+?\n)(.+\n)?(\S+)\s*=\s*(.*?)\n+$/s; $l =~ s/^#\s*//gm; $l = $t if not $l; ($o = $v) =~ s/_/-/g; $x .= qq/=item --$o=<\U$v\E>\n\n$l\nThe default value is "$d".\n\n/; $C .= "\n        [ --$o=<\U$v\E> ]"; $X = $x if eof' default-answer-file man/katello-configure.pod \
	| /usr/bin/pod2man --name=%{name} --official --section=1 --release=%{version} - man/katello-configure.man1

%install
rm -rf %{buildroot}
#prepare dir structure
install -d -m 0755 %{buildroot}%{_sbindir}
install -m 0755 bin/katello-configure %{buildroot}%{_sbindir}
install -d -m 0755 %{buildroot}%{homedir}
install -d -m 0755 %{buildroot}%{homedir}/puppet/modules
cp -Rp modules/* %{buildroot}%{homedir}/puppet/modules
install -d -m 0755 %{buildroot}%{homedir}/puppet/lib
cp -Rp lib/* %{buildroot}%{homedir}/puppet/lib
install -m 0644 default-answer-file %{buildroot}%{homedir}
install -m 0644 options-format-file %{buildroot}%{homedir}
install -d -m 0755 %{buildroot}%{_mandir}/man1
install -m 0644 man/katello-configure.man1 %{buildroot}%{_mandir}/man1/katello-configure.1

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root)
%{homedir}
%{_sbindir}/katello-configure
%{_mandir}/man1/katello-configure.1*

%changelog
* Tue Dec 06 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.26-1
- 760265 - Puppet guesses the FQDN from /etc/resolv.conf

* Tue Dec 06 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.25-1
- 760280 - katello-configure fails with ssl key creation error

* Mon Dec 05 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.24-1
- using candlepin certificates for both katello and pulp

* Mon Dec 05 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.23-1
- SSL certificate generation and deployment
- introduce mandatory option file with predefined option format

* Mon Dec 05 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.22-1
- configure - adding hostname checks
- configure - adding exit codes table

* Tue Nov 29 2011 Shannon Hughes <shughes@redhat.com> 0.1.21-1
- Change the default password for thumbslug keystores (bkearney@redhat.com)

* Mon Nov 28 2011 Ivan Necas <inecas@redhat.com> 0.1.20-1
- Update class path for Candlepin 0.5. (dgoodwin@redhat.com)

* Mon Nov 28 2011 Ivan Necas <inecas@redhat.com> 0.1.19-1
- pulp-revocation - Fix problems with access rights to crl file
  (inecas@redhat.com)
- 757176 - Thin process count is set to 0 (lzap+git@redhat.com)

* Thu Nov 24 2011 Ivan Necas <inecas@redhat.com> 0.1.18-1
- Add thumbslug configuration for headpin (jbowes@redhat.com)

* Thu Nov 24 2011 Ivan Necas <inecas@redhat.com> 0.1.17-1
- katello-configure - wait for canlepin to really start (inecas@redhat.com)
- pulp-revocation - set Candlepin to save CRL to a place Pulp can use
  (inecas@redhat.com)
- katello-configure - catch puppet stderr to a log file (inecas@redhat.com)

* Fri Nov 18 2011 Shannon Hughes <shughes@redhat.com> 0.1.16-1
- 755048 - set pulp host using fqdn (inecas@redhat.com)

* Wed Nov 16 2011 Shannon Hughes <shughes@redhat.com> 0.1.15-1
- 

* Wed Nov 16 2011 Ivan Necas <inecas@redhat.com> 0.1.14-1
- cdn-proxy - fix typo in Puppet manifest (inecas@redhat.com)

* Tue Nov 15 2011 Shannon Hughes <shughes@redhat.com> 0.1.13-1
- Merge branch 'master' into password_reset (bbuckingham@redhat.com)
- cdn-proxy - add support to puppet answer file (inecas@redhat.com)
- 752863 - katello service will return "OK" on error (lzap+git@redhat.com)
- installer - update to use fqdn from puppet vs answer file
  (bbuckingham@redhat.com)
- Merge branch 'master' into password_reset (bbuckingham@redhat.com)
- bug - installation failed on low-memory boxes (lzap+git@redhat.com)
- update template to disable sync KBlimit (shughes@redhat.com)
- 752058 - Could not find value for 'fqdn' proper fix (lzap+git@redhat.com)
- password reset - updates from code inspection (bbuckingham@redhat.com)
- Merge branch 'master' into password_reset (bbuckingham@redhat.com)
- password reset - fixes for issues found in production install
  (bbuckingham@redhat.com)
- installer - update the default-answer-file to use root@localhost as default
  email (bbuckingham@redhat.com)
- installler - minor update to setting of email in seeds.rb
  (bbuckingham@redhat.com)
- Merge branch 'master' into password_reset (bbuckingham@redhat.com)
- installer - minor changes to support user email and host
  (bbuckingham@redhat.com)

* Wed Nov 09 2011 Shannon Hughes <shughes@redhat.com> 0.1.12-1
- 

* Wed Nov 09 2011 Clifford Perry <cperry@redhat.com> 0.1.11-1
- Expose HTTP Proxy configuration within the katello-configure installation
  process. (cperry@redhat.com)
- 751132 - force restart of httpd to occurr post pulp-migrate, but before
  katellos rake db:seed (cperry@redhat.com)
- Minor change to katello-configure for db seed log size to expect for
  installation (cperry@redhat.com)
- 752058 - Could not find value for 'fqdn' (lzap+git@redhat.com)
- Ehnahce the org name changes to not require pulp for headpin installs
  (bkearney@redhat.com)

* Fri Nov 04 2011 Clifford Perry <cperry@redhat.com> 0.1.10-1
- Adding support to katello-configure for initial user/pass & org
  (cperry@redhat.com)
- 751132 - More logging for db seed step during installation.
  (cperry@redhat.com)
- 749495 - fix for the total memory calculation (lzap+git@redhat.com)

* Wed Nov 02 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.9-1
- PATCH: katello-configure: If unexpected error is seen, report it as well.
- PATCH: katello-configure: Exit with nonzero status if error was seen in
  puppet execution.
- Make a copy of katello-configure.conf in the log directory as well.
- 749495 - installation script process count - fix
- 749495 - installation script process count - fix
- 749495 - installation script process count
- Merge branch 'breakup-puppet'
- tweak a change
- Merge
- Remove trailing spaces
- Final selinux tweaks
- Disable selinux and get the endpoints correct
- Copy over the syscnf file
- Pull the prefix off of the deployment type
- Fully qualify the deployment variable
- First cut at making puppet be katello/headpin aware
- Final selinux tweaks
- Disable selinux and get the endpoints correct
- Copy over the syscnf file
- merge
- Pull the prefix off of the deployment type
- Merge branch 'bp' into breakup-puppet
- Fully qualify the deployment variable
- First cut at making puppet be katello/headpin aware
- First cut at making puppet be katello/headpin aware
- First cut at making puppet be katello/headpin aware

* Mon Oct 31 2011 Clifford Perry <cperry@redhat.com> 0.1.8-1
- fixes BZ-745652 bug - Installation will configure itself to use 1 thin
  process if only one processor (ohadlevy@redhat.com)

* Tue Oct 25 2011 Shannon Hughes <shughes@redhat.com> 0.1.7-1
- 734517 - puppet - set pulp.conf server_name to fqdn (inecas@redhat.com)
- Hello, (jpazdziora@redhat.com)
- switching to info level of logging.  our logfiles grow to 1G+ quickly
  (mmccune@redhat.com)
- Fixing permissions to 0644 on the default-answer-file.
  (jpazdziora@redhat.com)
- Adding the man page for katello-configure. (jpazdziora@redhat.com)
- Pulp.conf remove_old_packages renamed to remove_old_versions
  (inecas@redhat.com)

* Wed Oct 12 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.6-1
- Add support for command line options and user answer file to katello-
  configure
- protect-pulp-repo - fix puppet configuration

* Tue Oct 11 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.5-1
- adding an auto-login ssh public key
- Add support for answer files.
- Make the oauth_secret dynamic
- Move installation-related parts to */install.pp.
- Upon the db:seed, we also have to db:migrate.
- katello requires puppet 2.6.6+ (Fedora updates, EPEL)
- puppet - make it possible to include just pulp

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

