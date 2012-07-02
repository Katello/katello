
%global homedir %{_datarootdir}/katello/install

Name:           katello-configure
Version:        0.2.29
Release:        1%{?dist}
Summary:        Configuration tool for Katello

Group:          Applications/Internet
License:        GPLv2
URL:            http://www.katello.org
Source0:        %{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

Requires:       puppet >= 2.6.6
Requires:       coreutils shadow-utils wget
Requires:       katello-certs-tools
Requires:       nss-tools openssl
Requires:       policycoreutils-python
BuildRequires:  /usr/bin/pod2man /usr/bin/erb
BuildRequires:  findutils puppet >= 2.6.6

BuildArch: noarch

%description
Provides katello-configure script which configures Katello installation and
katello-upgrade which handles upgrades between versions.

%prep
%setup -q

%build
#check syntax for all puppet scripts
find -name '*.pp' | xargs -n 1 -t puppet --parseonly

#check for puppet erb syntax errors
find modules/ -name \*erb | xargs aux/check_erb

#build katello-configure man page
THE_VERSION=%version perl -000 -ne 'if ($X) { s/^THE_VERSION/$ENV{THE_VERSION}/; s/\s+CLI_OPTIONS/$C/; s/^CLI_OPTIONS_LONG/$X/; print; next } ($t, $l, $v, $d) = /^#\s*(.+?\n)(.+\n)?(\S+)\s*=\s*(.*?)\n+$/s; $l =~ s/^#\s*//gm; $l = $t if not $l; ($o = $v) =~ s/_/-/g; $x .= qq/=item --$o=<\U$v\E>\n\n$l\nThe default value is "$d".\n\n/; $C .= "\n        [ --$o=<\U$v\E> ]"; $X = $x if eof' default-answer-file man/katello-configure.pod \
	| /usr/bin/pod2man --name=%{name} -c "Katello Reference" --section=1 --release=%{version} - man/katello-configure.man1

#build katello-upgrade man page
sed -e 's/THE_VERSION/%version/g' man/katello-upgrade.pod | /usr/bin/pod2man --name=katello-upgrade -c "Katello Reference" --section=1 --release=%{version} - man/katello-upgrade.man1

#build katello-passwd man page
THE_VERSION=%version sed -i "s/THE_VERSION/$THE_VERSION/g" man/katello-passwd.pod bin/katello-passwd
/usr/bin/pod2man --name=%{name} -c "Katello Reference" --section=1 --release=%{version} man/katello-passwd.pod man/katello-passwd.man1


%install
rm -rf %{buildroot}
#prepare dir structure
install -d -m 0755 %{buildroot}%{_sbindir}
install -m 0755 bin/katello-configure %{buildroot}%{_sbindir}
install -m 0755 bin/katello-upgrade %{buildroot}%{_sbindir}
install -m 0755 bin/katello-passwd %{buildroot}%{_sbindir}
install -d -m 0755 %{buildroot}%{homedir}
install -d -m 0755 %{buildroot}%{homedir}/puppet/modules
cp -Rp modules/* %{buildroot}%{homedir}/puppet/modules
install -d -m 0755 %{buildroot}%{homedir}/puppet/lib
cp -Rp lib/* %{buildroot}%{homedir}/puppet/lib
install -m 0644 default-answer-file %{buildroot}%{homedir}
install -m 0644 options-format-file %{buildroot}%{homedir}
install -d -m 0755 %{buildroot}%{_mandir}/man1
install -m 0644 man/katello-configure.man1 %{buildroot}%{_mandir}/man1/katello-configure.1
install -m 0644 man/katello-upgrade.man1 %{buildroot}%{_mandir}/man1/katello-upgrade.1
install -m 0644 man/katello-passwd.man1 %{buildroot}%{_mandir}/man1/katello-passwd.1
install -d -m 0755 %{buildroot}%{homedir}/upgrade-scripts
cp -Rp upgrade-scripts/* %{buildroot}%{homedir}/upgrade-scripts

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root)
%{homedir}/
%{_sbindir}/katello-configure
%{_sbindir}/katello-upgrade
%{_sbindir}/katello-passwd
%{_mandir}/man1/katello-configure.1*
%{_mandir}/man1/katello-upgrade.1*
%{_mandir}/man1/katello-passwd.1*


%changelog
* Mon Jul 02 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.29-1
- 834697 - explicitly disable qpid authentication

* Wed Jun 27 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.28-1
- 835152 - logs in advanced during installation fix
- fix indention
- 835152 - creating logs in advanced during installation
- pubkeys - editing README with more details
- pugkeys - adding pubkey list and Makefile
- instead of hard setting stty, restore previous value
- Fix indentation.
- 828533 - changing to proper QPIDD SSL port
- Change puppet config to generate encrypted db pass

* Mon Jun 25 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.27-1
- BZ 825262: support for moving systems between environments from CLI

* Mon Jun 18 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.26-1
- katello-upgrade is looking only for scripts marked as executable
- 824362 - puppet preallocates journal on F16+

* Thu May 24 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.25-1
- 821532 - Removing extraneous hornetq files to fix candlepin upgrades
- 824362 - workaround for mongodb/systemd Fedora bug
- Adding users to katello group the puppet way

* Mon May 21 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.24-1
- Add exit_with to reconfigure attempt.

* Fri May 18 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.23-1
- removing mod_authz_ldap from dependencies

* Thu May 17 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.22-1
- encryption - plain text passwords encryption

* Wed May 16 2012 Mike McCune <mmccune@redhat.com> 0.2.21-1
- 817933 part deux - also going to read these from katello-configure bin
  (jomara@redhat.com)
- 818679 - making some of the LDAP comments for katello-configure more helpful
  (jomara@redhat.com)
- 795869 - Fixing org name in katello-configure to accept spaces but still
  create a proper candlepin key (jomara@redhat.com)

* Thu May 10 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.20-1
- 820273 - removed change to example script
- 820273 - correct example and real upgrade scripts
- Adding back db_user & db_name to cpsetup call
- Pass the keystore/truststore password into cpsetup
- 816188 - installer minimum is 2 thins now
- Modify the installation and upgrade process for the candlepin usage of
  liquibase.
- 809823 - Blocking katello-configure from installing katello if headpin is
  installed
- 799979 - updated candlepin option to allow any characters in system name
- upgrade script - moving it all back to the package katello-configure
- upgrade script - man page
- upgrade script - subscripts being filtered accoring to a deployment at
  runtime
- upgrade script - logging
* Fri Apr 27 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.19-1
- Set the rails relative url in the installer based on the deployment option
- Installer updates upgrade history to record upgrades already included in the
  build
- upgrade script introduced
- Loading group roles from ldap
- First verision of Katello upgrade script
- 811011 - adding keep alive and expires

* Fri Apr 06 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.18-1
- puppet - adding pulp migration logging

* Mon Apr 02 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.17-1
- 794778 - option ssl_ca_certificate is set for pulp V1
- 768399 - deployment configure values are checked
- 805436 - Parametrize Candlepin db credentials, keystore and postgre passwords

* Mon Mar 26 2012 Martin Bačovský <mbacovsk@redhat.com> 0.2.16-1
- 805124 - Security review of world-readable files (mbacovsk@redhat.com)
- 804127 - adding configurable log property (jsherril@redhat.com)
- 806028 - postgres sysvinit script workaround (lzap+git@redhat.com)
- 802454 - adding support for pulp post-sync request (jsherril@redhat.com)
- fixing header in the configure man page (lzap+git@redhat.com)

* Tue Mar 20 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.15-1
- 802346 - wait for postgres to come up in puppet

* Mon Mar 19 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.14-1
- Revert "802346 - wait for postgres to come up in puppet"

* Mon Mar 19 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.13-1
- 802346 - adding puppet syntax check to the spec
- 802346 - wait for postgres to come up in puppet
- Revert "802346 - wait until PostgreSQL accepts connections"
- 802252 - adding missing Ruby build dependency

* Mon Mar 12 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.12-1
- 802346 - wait until PostgreSQL accepts connections
- pchalupa's public key
- 802252 - Adding ERB syntax checker to the SPEC
- 802252 - Unable to install Katello on Puppet 2.7

* Fri Mar 09 2012 Mike McCune <mmccune@redhat.com> 0.2.11-1
- periodic rebuild
* Tue Mar 06 2012 Mike McCune <mmccune@redhat.com> 0.2.10-1
- 788708 - moving the var/www/html/pub dir creation a bit higher up
  (mmccune@redhat.com)

* Tue Mar 06 2012 Mike McCune <mmccune@redhat.com> 0.2.9-1
- Keep the permissions for the candlepin.conf file the same as the spec file
  (bkearney@redhat.com)

* Tue Mar 06 2012 Martin Bačovský <mbacovsk@redhat.com> 0.2.8-1
- 800318 - installer fails: Working directory '/var/www/html/pub' does not
  exist (mbacovsk@redhat.com)
- 790835 - fixing deployment url and goferd restart in bootstrap
  (lzap+git@redhat.com)

* Fri Mar 02 2012 Martin Bačovský <mbacovsk@redhat.com> 0.2.7-1
- 799138 - katello-configure --deployment=headpin fails (mbacovsk@redhat.com)

* Fri Mar 02 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.6-1
- 798454 - SSLCACertificateFile not set properly
- 761314 - Make sure katello-agent communicates with ssl
- 761314 - Make sure katello-agent communicates with ssl

* Tue Feb 28 2012 Martin Bačovský <mbacovsk@redhat.com> 0.2.5-1
- 761314 - Make sure katello-agent communicates with ssl (mbacovsk@redhat.com)
- 781505 - randomize default admin password for Pulp (lzap+git@redhat.com)

* Mon Feb 27 2012 Martin Bačovský <mbacovsk@redhat.com> 0.2.4-1
- 761314 - Make sure katello-agent communicates with ssl (mbacovsk@redhat.com)

* Mon Feb 27 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.3-1
- 790835 - restart goferd after rhsm configuration and fix
- 786572 - elasticsearch - reduce heap to 256m

* Mon Feb 27 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.2-1
- 761314 - Make sure katello-agent communicates with ssl
- 790835 - Create bootstrap RPM package with cons. cert
- 795869 org_name is not overriding itself in db_seed correctly
- 786978 - updating puppet to accept sam/cfse/headpin/katello and make the url
  respond accordingly

* Wed Feb 22 2012 Mike McCune <mmccune@redhat.com> 0.2.1-1
- version bump

* Wed Feb 22 2012 Ivan Necas <inecas@redhat.com> 0.1.66-1
- periodic build

* Fri Feb 10 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.64-1
- 789290 - fixing progress bars with new puppet
- 789290 - updating log file sizes

* Thu Feb 09 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.63-1
- 768014 - katello-configure with answer-file org_name fail

* Tue Feb 07 2012 Mike McCune <mmccune@redhat.com> 0.1.62-1
- 786572 - force in max/min heap sizes to 1.5G vs the current 1G limit
  (mmccune@redhat.com)
- 788228 - increasing to 16MB limit for file uploads (mmccune@redhat.com)

* Fri Feb 03 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.61-1
- 784280 - Katello installer does not turn off SELinux now

* Thu Feb 02 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.60-1
- puppet - increasing OS/BE reserve by 100 MB

* Wed Feb 01 2012 Mike McCune <mmccune@redhat.com> 0.1.59-1
- puppet - giving longer timeout for cpsetup (5 minutes) (lzap+git@redhat.com)

* Mon Jan 30 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.58-1
- 785703 - increasing logging for seed script now used

* Mon Jan 30 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.57-1
- 785703 - increasing logging for seed script

* Fri Jan 27 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.56-1
- nicer errors for CLI and RHSM when service is down
- 771352 - SAM does need katello-jobs for email and org delete

* Thu Jan 26 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.55-1
- 784601 - sync fails if /var/lib/pulp/packages is separate mount
- 773088 - short term bump of the REST client timeout to 120
- 771343 - adding proxying for /javascripts in /etc/httpd/conf.d/katello.conf

* Thu Jan 19 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.54-1
- 749805 - httpd - katello.conf - update to remove unnecessary / in path

* Fri Jan 13 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.53-1
- 760305 - Remove names and references to 'rhn' from cert-tools

* Mon Jan 09 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.52-1
- 772574 - enabling pulp-testing repo

* Fri Jan 06 2012 Ivan Necas <inecas@redhat.com> 0.1.51-1
- 768420 - config Pulp for new content location (for Pulp 0.1.256) (inecas@redhat.com)

* Fri Jan 06 2012 Ivan Necas <inecas@redhat.com> 0.1.50-1
- 772210 - make /var/run/elasticsearch dir to fix installation
  (inecas@redhat.com)

* Tue Jan 03 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.49-1
- 771352 - SAM does not need to use the katello-jobs

* Thu Dec 22 2011 Mike McCune <mmccune@redhat.com> 0.1.48-1
- 768191 - ensure we have elasticsearch running before seed
  (mmccune@redhat.com)

* Thu Dec 22 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.47-1
- 769540 - katello-configure fails: katelloschema

* Wed Dec 21 2011 Mike McCune <mmccune@redhat.com> 0.1.46-1
- 768191 - adding a default config for elasticsearch
* Wed Dec 21 2011 Mike McCune <mmccune@redhat.com> 0.1.45-1
- rolling back to previous rev so we can re-tag (mmccune@redhat.com)
* Wed Dec 21 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.44-1
- Revert "769540 - katello-configure fails: katelloschema"
- Gave create db access to katello user
- 768191 - forgot the include so we actually execute the ES config
- 768191 - first cut at getting elasticsearch configured

* Wed Dec 21 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.43-1
- 769540 - katello-configure fails: katelloschema
- mbacovsk's public key
- tstrachota's public key
- Revert "765813 - Puppet: create-nss-db fails on RHEL 6.2 [TEMP FIX]"

* Mon Dec 19 2011 Shannon Hughes <shughes@redhat.com> 0.1.42-1
- 766933 - katello.yml perms - reformatting source (lzap+git@redhat.com)

* Fri Dec 16 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.41-1
- 766933 - katello.yml now deployed with correct perms

* Fri Dec 16 2011 Ivan Necas <inecas@redhat.com> 0.1.40-1
- Fix syntax error in dependency specification in katello service
  (inecas@redhat.com)

* Fri Dec 16 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.39-1
- puppet - migrate script depends on katello.yml

* Fri Dec 16 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.38-1
- puppet - katello-jobs now depends on katello
- adding debug options to the katello.yml
- 767812 - compress our javascript and CSS

* Wed Dec 14 2011 Shannon Hughes <shughes@redhat.com> 0.1.37-1
- system engine build

* Tue Dec 13 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.36-1
- 767139 - Puppet sometimes fails on RHEL 6.1
- 759564: Candlepin puppet module did not add the thumbslug oauth line during a
  headpin install

* Mon Dec 12 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.35-1
- 758712 - adding missing requires for candlepin sql

* Mon Dec 12 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.34-1
- 758712 - execute classes with logs in correct order

* Fri Dec 09 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.33-1
- 758712 - Installer (db:seed) sometimes fail - better [TEMP FIX]

* Fri Dec 09 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.32-1
- 765813 - Puppet: create-nss-db fails on RHEL 6.2 [TEMP FIX]
- 758712 - Installer (db:seed) sometimes fail [TEMP FIX]

* Thu Dec 08 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.31-1
- puppet - regenerate NSS db each run - fix

* Thu Dec 08 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.30-1
- puppet - regenerate NSS db each run
- puppet - better warning message

* Thu Dec 08 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.29-1
- puppet - force creation of the candlepin symlink
- puppet - type in logfile

* Thu Dec 08 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.28-1
- puppet - fixing variable reassignment

* Thu Dec 08 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.27-1
- puppet - splitting migrate and seed exec actions up
- puppet - renaming initdb_done to db_seed_done
- puppet - adding cwds to ssl-certs actions
- configure - adding 2nd run check

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

