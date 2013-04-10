# vim: sw=4:ts=4:et
#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

%global homedir %{_datarootdir}/katello/install

Name:           katello-configure
Version:        1.3.6
Release:        1%{?dist}
Summary:        Configuration tool for Katello

Group:          Applications/Internet
License:        GPLv2
URL:            http://www.katello.org
Source0:        https://fedorahosted.org/releases/k/a/katello/%{name}-%{version}.tar.gz

Requires:       puppet >= 2.6.6
Requires:       coreutils
Requires:       wget
Requires:       katello-certs-tools
Requires:       nss-tools
Requires:       openssl
Requires:       policycoreutils-python
Requires:       initscripts
Requires:       libselinux-ruby
Requires:       rubygem(rake)
Requires:       rubygem(ruby-progressbar)
BuildRequires:  /usr/bin/pod2man /usr/bin/erb
BuildRequires:  findutils puppet >= 2.6.6
BuildRequires:  sed

BuildArch: noarch

%description
Provides katello-configure script which configures Katello installation and
katello-upgrade which handles upgrades between versions.

%prep
%setup -q

%build
%if ! 0%{?fastbuild:1}
    #check syntax of main configure script and libs
    ruby -c bin/* lib/puppet/parser/functions/*rb

    #check syntax for all puppet scripts
    %if 0%{?rhel} || 0%{?fedora} < 17
    # Puppet 2.6 parseonly mode does not handle multiple files correctly
    find -name '*.pp' | xargs -n 1 -t puppet --parseonly
    %else
    # Puppet Bug #16006 (puppet 2.7 not working without a hostname)
    find -name '*.pp' | FACTER_hostname=builder xargs -t puppet parser validate
    %endif

    #check for puppet erb syntax errors
    find modules/ -name \*erb | xargs aux/check_erb
%endif

# README is development (git) only
rm -f upgrade-scripts/README

#replace shebangs for SCL
%if %{?scl:1}%{!?scl:0}
    sed -ri '1,$s|/usr/bin/rake|/usr/bin/ruby193-rake|' upgrade-scripts/*
%endif

#build katello-configure man page
THE_VERSION=%version perl -000 -ne 'if ($X) { s/^THE_VERSION/$ENV{THE_VERSION}/; s/\s+CLI_OPTIONS/$C/; s/^CLI_OPTIONS_LONG/$X/; print; next } ($t, $l, $v, $d) = /^#\s*(.+?\n)(.+\n)?(\S+)\s*=\s*(.*?)\n+$/s; $l =~ s/^#\s*//gm; $l = $t if not $l; ($o = $v) =~ s/_/-/g; $x .= qq/=item --$o=<\U$v\E>\n\n$l\nThe default value is "$d".\n\n/; $C .= "\n        [ --$o=<\U$v\E> ]"; $X = $x if eof' default-answer-file man/katello-configure.pod \
	| /usr/bin/pod2man --name=%{name} -c "Katello Reference" --section=1 --release=%{version} - man/katello-configure.man1

#build katello-upgrade man page
sed -e 's/THE_VERSION/%version/g' man/katello-upgrade.pod | /usr/bin/pod2man --name=katello-upgrade -c "Katello Reference" --section=1 --release=%{version} - man/katello-upgrade.man1

#build katello-passwd man page
sed -i "s/THE_VERSION/%version/g" man/katello-passwd.pod bin/katello-passwd
/usr/bin/pod2man --name=%{name} -c "Katello Reference" --section=1 --release=%{version} man/katello-passwd.pod man/katello-passwd.man1

#build katello-configure-answer man page
sed -i "s/THE_VERSION/%version/g" man/katello-configure-answer.pod bin/katello-configure-answer
/usr/bin/pod2man --name=%{name} -c "Katello Reference" --section=1 --release=%{version} man/katello-configure-answer.pod man/katello-configure-answer.man1

%install
#prepare dir structure
install -d -m 0755 %{buildroot}%{_sbindir}
install -m 0755 bin/katello-configure %{buildroot}%{_sbindir}
install -m 0755 bin/katello-upgrade %{buildroot}%{_sbindir}
install -m 0755 bin/katello-passwd %{buildroot}%{_sbindir}
install -m 0755 bin/katello-configure-answer %{buildroot}%{_sbindir}
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
install -m 0644 man/katello-configure-answer.man1 %{buildroot}%{_mandir}/man1/katello-configure-answer.1
install -d -m 0755 %{buildroot}%{homedir}/upgrade-scripts
cp -Rp upgrade-scripts/* %{buildroot}%{homedir}/upgrade-scripts
chmod +x -R %{buildroot}%{homedir}/upgrade-scripts/*

%files
%{homedir}/
%{_sbindir}/katello-configure
%{_sbindir}/katello-upgrade
%{_sbindir}/katello-passwd
%{_sbindir}/katello-configure-answer
%{_mandir}/man1/katello-configure.1*
%{_mandir}/man1/katello-upgrade.1*
%{_mandir}/man1/katello-passwd.1*
%{_mandir}/man1/katello-configure-answer.1*


%changelog
* Wed Jan 30 2013 Justin Sherrill <jsherril@redhat.com> 1.3.6-1
- removing pulpv2 prefix from pulpv2 branch (jsherril@redhat.com)

* Tue Jan 29 2013 Justin Sherrill <jsherril@redhat.com> 1.3.5.pulpv2-1
- fixing sync hanging in pulpv2 (jsherril@redhat.com)

* Sun Jan 27 2013 Justin Sherrill <jsherril@redhat.com> 1.3.4.pulpv2-1
- changing pulp configure to use ssl for qpid (jsherril@redhat.com)

* Fri Jan 25 2013 Justin Sherrill <jsherril@redhat.com> 1.3.3.pulpv2-1
- fixing pulpv2 version in spec (jsherril@redhat.com)
- fixing commented line in server.conf (jsherril@redhat.com)
- 877387 - Candlepin CA certificate mode in RPM (ares@igloonet.cz)
- Automatic commit of package [katello-configure] release [1.3.3-1].
  (jsherril@redhat.com)
- emails - add default From to login/password emails (bbuckingham@redhat.com)
- adding thumbslug to headpin's ping function and tests, etc
  (komidore64@gmail.com)
- 890000 - enabling certv3 in candlepin conf (jomara@redhat.com)
- run security:generate_token only if token does not exist (msuchy@redhat.com)
- generate token for foreman (msuchy@redhat.com)
- Automatic commit of package [katello-configure] release [1.3.2-1].
  (lzap+git@redhat.com)
- do not continue if something fails (msuchy@redhat.com)
- add service-wait to path (msuchy@redhat.com)
- enable logging of all output (msuchy@redhat.com)
- tee could not be used, because it is executed under postgres which does not
  have acl for /var/log/foo (msuchy@redhat.com)
- 889488 - change selinux identity to system_u (msuchy@redhat.com)
- 889488 - run createdb only if needed (msuchy@redhat.com)
- 889488 - run create user only if it is needed (msuchy@redhat.com)
- fix typo (msuchy@redhat.com)
- 885261 - katello-configure now always loads answer file (lzap+git@redhat.com)
- move loop over puppet output to shared function (msuchy@redhat.com)
- remove dead code (msuchy@redhat.com)
- remove dead code (msuchy@redhat.com)
- add upgrade script to upgrade old configuration to a new one
  (pchalupa@redhat.com)
- fix 'nil' bug in katello-configure when running with --no-bars option
  (pchalupa@redhat.com)
- add --katello-configuration-files-only option to katello-configure
  (pchalupa@redhat.com)
- if nobars is set then progress_bar is not defined (msuchy@redhat.com)
- 865860: Change the default org and  orgunit values for the candlepin cert
  (bkearney@redhat.com)
- logging - orchestration logger and uuid request tracking
  (lzap+git@redhat.com)
- 885261 - org deletion should remove rh provider (lzap+git@redhat.com)
- 758813: Disable basic and trusted auth in the candlepin engine since it is
  not required. (bkearney@redhat.com)
- fix packaging and katello-configure (pchalupa@redhat.com)

* Tue Jan 15 2013 Justin Sherrill <jsherril@redhat.com> 1.3.3-1
- emails - add default From to login/password emails (bbuckingham@redhat.com)
- 890000 - enabling certv3 in candlepin conf (jomara@redhat.com)
- run security:generate_token only if token does not exist (msuchy@redhat.com)
- generate token for foreman (msuchy@redhat.com)
- do not continue if something fails (msuchy@redhat.com)
- add service-wait to path (msuchy@redhat.com)
- enable logging of all output (msuchy@redhat.com)
- tee could not be used, because it is executed under postgres which does not
  have acl for /var/log/foo (msuchy@redhat.com)
- 889488 - change selinux identity to system_u (msuchy@redhat.com)
- 889488 - run createdb only if needed (msuchy@redhat.com)
- 889488 - run create user only if it is needed (msuchy@redhat.com)

* Tue Jan 08 2013 Lukas Zapletal <lzap+git@redhat.com> 1.3.2-1
- fix typo
- Merge pull request #1271 from lzap/orch-logging
- Merge pull request #1259 from lzap/org-delete-885261
- 885261 - katello-configure now always loads answer file
- move loop over puppet output to shared function
- remove dead code
- Merge pull request #1314 from xsuchy/pull-req-pg24
- add upgrade script to upgrade old configuration to a new one
- fix 'nil' bug in katello-configure when running with --no-bars option
- add --katello-configuration-files-only option to katello-configure
- Merge pull request #1297 from Katello/bkearney/865860
- Merge pull request #1256 from bkearney/bkearney/758813
- if nobars is set then progress_bar is not defined
- 865860: Change the default org and  orgunit values for the candlepin cert
- if foreman is stopped, status returns 3 - in such case return 0 to make
  puppet happy
- logging - orchestration logger and uuid request tracking
- 885261 - org deletion should remove rh provider
- 758813: Disable basic and trusted auth in the candlepin engine since it is
  not required.
- fix packaging and katello-configure

* Tue Dec 18 2012 Miroslav Suchý <msuchy@redhat.com> 1.3.1-1
- stop foreman only if it is running (msuchy@redhat.com)
- when finishing, reset title of progress bar back to original state
  (msuchy@redhat.com)
- make parse_answer_option function (msuchy@redhat.com)
- move creation of temp config file to shared functions (msuchy@redhat.com)
- move creation of answer file to shared functions (msuchy@redhat.com)
- move show_resulting_answer_file to shared functions (msuchy@redhat.com)
- move code parsing answer_file to shared functions (msuchy@redhat.com)
- move check for root uid to shared functions (msuchy@redhat.com)
- move remove_option() to shared functions (msuchy@redhat.com)
- simplify progress bar (msuchy@redhat.com)
- Bumping package versions for 1.3. (ehelms@redhat.com)

* Thu Dec 06 2012 Eric D Helms <ehelms@redhat.com> 1.2.1-1
- katello-configure - setting foreman default values to make provisioning
  possible (inecas@redhat.com)
- katello-configure - make Foreman accessible through http (inecas@redhat.com)
- bundler.d - applying changes for the spec (lzap+git@redhat.com)
- katello-configure - stop foreman before dropping the database
  (inecas@redhat.com)
- katello-configure-answer review fix (lzap+git@redhat.com)
- conf-answer - finishing kconf refactoring (lzap+git@redhat.com)
- 882167 - katello-upgrade fails to call cpdb (lzap+git@redhat.com)
- conf-answer - introducing katello-configure-answer (lzap+git@redhat.com)
- conf-answer - refactoring PREFIX variable (lzap+git@redhat.com)
- conf-answer - reafactoring check_options_against_default
  (lzap+git@redhat.com)
- move check_hostname() to functions.rb (msuchy@redhat.com)
- move _request_option_interactively() to functions.rb (msuchy@redhat.com)
- move _read_password() to functions.rb (msuchy@redhat.com)
- move _is_option_true() to functions.rb (msuchy@redhat.com)
- move _get_valid_option_value() to functions.rb (msuchy@redhat.com)
- move read_options_format() to functions.rb (msuchy@redhat.com)
- move ERROR_CODES and exit_with() to functions.rb (msuchy@redhat.com)
- move read_answer_file() to functions.rb (msuchy@redhat.com)
- foreman 404 error configure fix - missing dep (lzap+git@redhat.com)
- bundler_ext - development mode support
- bundler_ext - missing colon in configure (lzap+git@redhat.com)
- bundler_ext - no need to run bundler during configure steps
  (lzap+git@redhat.com)
- katello-configure - make sure Foreman is accessible through https only
  (inecas@redhat.com)
- bundler_ext - no need to run bundler during configure (lzap+git@redhat.com)
- katello-configure - fix default values for term size (inecas@redhat.com)
- katello-configure - make exec defaults more suitable for us
  (inecas@redhat.com)
- Adding client-ca.pem to /etc/thumbslug for thumbslug .27 (jomara@redhat.com)
- katello-upgrade - fix in katello-configure first installation
  (lzap+git@redhat.com)
- katello-upgrade - tomcat start fix (lzap+git@redhat.com)
- katello-upgrade - review changes (lzap+git@redhat.com)
- katello-upgrade redesign (lzap+git@redhat.com)
- Added default value for Foreman admin's email (mbacovsk@redhat.com)
- 874160 - adding ES reindex after we migrate during upgrade
  (lzap+git@redhat.com)
- katello-configure - support reset data for the foreman (inecas@redhat.com)
- candlepin-cert-consumer.rpm should require subscription-manager
  (msuchy@redhat.com)
- 872096 - restart services and remove upgrade -y option (lzap+git@redhat.com)
- 872493 - Katello-configure --reset-data incorrectly sets mongod up
  (lzap+git@redhat.com)
- enabling foreman authentication by default (lzap+git@redhat.com)
- adding missing require for foreman service (lzap+git@redhat.com)
- puppet race condition in foreman (lzap+git@redhat.com)
- katello-configure - always chomp generated password (inecas@redhat.com)
- 872096 - add katello-configure into katello-upgrade (lzap+git@redhat.com)
- adding OpenJDK check into katello-configure (lzap+git@redhat.com)
- wrapping headpin only gems to the if statement (lzap+git@redhat.com)
- moving .bundle/config out of RPM to configure (lzap+git@redhat.com)
- 868916 - make sure we create this directory in the spec (mmccune@redhat.com)
- 868916 - wait for elasticsearch and start httpd during upgrade
  (lzap+git@redhat.com)
- precreating log file for foreman with correct perms - dep
  (lzap+git@redhat.com)
- precreating log file for foreman with correct perms (lzap+git@redhat.com)
- replacing constant with variable in puppet (lzap+git@redhat.com)
- changing user under foreman-config is run (lzap+git@redhat.com)
- headpin-foreman - fence foreman code when not configuring katello
  (thomasmckay@redhat.com)
- 868916 - katello-upgrade bash array fix (lzap+git@redhat.com)
- 865811 - use the concurrency level calculation suggested in BZ
  (inecas@redhat.com)
- katello-configure - enclose the values in hyphens (inecas@redhat.com)
- 865811 - set concurrency threshold for pulp (msuchy@redhat.com)
- raise errors on Foreman Katello DB inconsistency (pchalupa@redhat.com)
- katello-configure - fix headpin installation (inecas@redhat.com)
- do not call pulp service script, call qpidd and mongodb directly
  (msuchy@redhat.com)
- Bumping package versions for 1.1. (lzap+git@redhat.com)
- katello-configure - set oauth params when installing the server
  (inecas@redhat.com)
- move missing foreman user creation out of migration to upgrade script
  (pchalupa@redhat.com)
- do not print SQL query on output as it will confuse grep (msuchy@redhat.com)
- use md5 for connection to postgres instead of ident (msuchy@redhat.com)
- pass password to candlepin cpdb (msuchy@redhat.com)
- call /usr/share/candlepin/cpdb as postgres user (msuchy@redhat.com)
- removing sqlexec.pp (msuchy@redhat.com)
- when connecting to postgres DB you have to be postgres user
  (msuchy@redhat.com)
- Revert "802346 - wait for postgres to come up in puppet" (msuchy@redhat.com)
- 850569 - use ident method in pg_hba.conf (msuchy@redhat.com)
* Fri Oct 12 2012 Lukas Zapletal <lzap+git@redhat.com> 1.1.11-1
- 862441 - correcting error message for upgrade
- puppet - fixing web workers issue
- 860709 - pulp-migrate was not executed during upgrade
- Merge pull request #701 from mbacovsky/858283_workers
- Added --katello-web-workers and --foreman-web-worker params to installer

* Thu Sep 27 2012 Miroslav Suchý <msuchy@redhat.com> 1.1.10-1
- 858360 - Making katello-upgrade START services after upgrade is complete
  (jomara@redhat.com)
- 859407 - puppet timeout set to 0 for some steps (lzap+git@redhat.com)
- Rakefile could not be in -devel package as katello-configure call db:migrate
  and seed_with_logging rake tasks (msuchy@redhat.com)
- 858277 - tomcat6 service dependency (lzap+git@redhat.com)
- 857913 - katello-upgrade system call improvement (lzap+git@redhat.com)
- 858038 - optimizing memory division (lzap+git@redhat.com)
- 858038 - thin process calculator fix (lzap+git@redhat.com)
- 858013 - katello job workers configure option (lzap+git@redhat.com)
- 857913 - katello-upgrade auto-stop now working (lzap+git@redhat.com)
- 856220 - tomcat6 now requires keystore symlink (lzap+git@redhat.com)
- 856220 - refactoring katello_keystore variable (lzap+git@redhat.com)
- removing example upgrade scripts (lzap+git@redhat.com)
- 856220 - mongodb now configured with journal (lzap+git@redhat.com)

* Wed Sep 12 2012 Miroslav Suchý <msuchy@redhat.com> 1.1.9-1
- 856220 - adding time to puppet log (lzap+git@redhat.com)
- Removing extra configure code for headpin bin; adding provides to cli script
  for headpin (jomara@redhat.com)
- Fencing headpin CLI into katello cli. CLI will now load appropriate functions
  based on client.conf configuration. Katello cli now ships with headpin
  symlink (jomara@redhat.com)
- it is better to use "service" as it runs in predictable environment
  (msuchy@redhat.com)
- 819593 - RHSM now use /subscription as ultimate location (msuchy@redhat.com)

* Thu Sep 06 2012 Ivan Necas <inecas@redhat.com> 1.1.8-1
- fastbuild - adding macro for all spec files (lzap+git@redhat.com)
- foreman-configure - fix ordering issue in puppet module (inecas@redhat.com)

* Fri Aug 31 2012 Miroslav Suchý <msuchy@redhat.com> 1.1.7-1
- rename puppet/ to katello-configure/ (msuchy@redhat.com)

* Wed Aug 29 2012 Ivan Necas <inecas@redhat.com> 1.1.6-1
- 849224 - thin now listens only on localhost (lzap+git@redhat.com)

* Thu Aug 23 2012 Mike McCune <mmccune@redhat.com> 1.1.5-1
- katello-configure - install and config Foreman with Katello
  (inecas@redhat.com)
- configure - workaround for puppet bug 16006 (lzap+git@redhat.com)
* Thu Aug 16 2012 Lukas Zapletal <lzap+git@redhat.com> 1.1.4-1
- 828369 - katello.conf owned by katello:katello

* Sat Aug 11 2012 Miroslav Suchý <msuchy@redhat.com> 1.1.3-1
- remove ssh pub keys (msuchy@redhat.com)
- puppet - make sure we deploy previous certificate before generating new one
  (inecas@redhat.com)
- 820624 - make pgsql to listen only on localhost (lzap+git@redhat.com)

* Sat Aug 04 2012 Miroslav Suchý <msuchy@redhat.com> 1.1.2-1
- 845224 - fix adding broker cert to nssdb (inecas@redhat.com)

* Thu Aug 02 2012 Miroslav Suchý <msuchy@redhat.com> 1.1.1-1
- rb19 - fixing typo in requires (lzap+git@redhat.com)
- buildroot and %%clean section is not needed (msuchy@redhat.com)
- rb19 - correcting requires for fedora guidelines (lzap+git@redhat.com)
- rb19 - adding missing require (lzap+git@redhat.com)
- rb19 - fixing collate (lzap+git@redhat.com)
- rb19 - adding puppet bundler check (lzap+git@redhat.com)
- rb19 - one more UTF8 fix (lzap+git@redhat.com)
- rb19 - setting collate (lzap+git@redhat.com)
- rb19 - invalid char (lzap+git@redhat.com)
- rb19 - warning msg (lzap+git@redhat.com)
- rb19 - adding check (lzap+git@redhat.com)
- rb19 - extra comma (lzap+git@redhat.com)
- Bumping package versions for 1.1. (msuchy@redhat.com)

* Tue Jul 31 2012 Miroslav Suchý <msuchy@redhat.com> 1.0.1-1
- bump up version to 1.0 (msuchy@redhat.com)

* Tue Jul 31 2012 Miroslav Suchý <msuchy@redhat.com> 0.2.39-1
- update copyright years (msuchy@redhat.com)

* Mon Jul 30 2012 Miroslav Suchý <msuchy@redhat.com> 0.2.38-1
- Fix Ruby 1.9.3 compatibility issue in Puppet manifest (inecas@redhat.com)

* Mon Jul 30 2012 Miroslav Suchý <msuchy@redhat.com> 0.2.37-1
- puppet - nss generation ordering issue (lzap+git@redhat.com)
- puppet - pulp migrate must run before apache2 ensure (lzap+git@redhat.com)

* Mon Jul 30 2012 Miroslav Suchý <msuchy@redhat.com> 0.2.36-1
- puppet - fixing pulp migrate race condition (typo) (lzap+git@redhat.com)
- puppet - fixing pulp migrate race condition (lzap+git@redhat.com)

* Mon Jul 30 2012 Miroslav Suchý <msuchy@redhat.com> 0.2.35-1
- puppet - adding more logging to cert creation (lzap+git@redhat.com)
- point Source0 to fedorahosted.org where tar.gz are stored (msuchy@redhat.com)

* Fri Jul 27 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.34-1
- puppet - better help strings for reset options
- puppet - when installer fails print info about katello-debug
- puppet - adding mongod to the service-wait script
- puppet - apache2/pulp reloading was not working with systemd
- puppet - reset tasks must not return non-zero
- puppet - adding service-wait wrapper script
- 840595 - katello-configure --help optparse.rb error fix
- puppet - remove color codes from puppet log file
- puppet - upgrade scripts are marked only during first installation
- puppet - tomcat6 had problems with restarts in headpin mode
- puppet - reuse secret token also for headpin deployment
- puppet - wrap long lines for optparse
- puppet - introducing temp answer file for dangerous options
- puppet - adding k-c options -d and -b
- puppet - implementing reset_data and reset_cache options
- puppet - split add-private-key-to-nss-db into two actions
- puppet - adding logging to cpinit phase
- puppet - create katello-configure subdir for logs
- puppet - do not restart httpd everytime
- puppet - use refreshonly for cert generation
- puppet - do not rewrite pulp user pass everytime
- puppet - remove generated string from all config headers
- puppet - get rid of cpsetup and use dpdb directly
- puppet - notify services when changing config files
- puppet - do not regenerate oauth_secret every puppet run
- puppet - use keystore_password_file for tomcat too
- puppet - allowing users to set pgsql superuser password
- puppet - cleaning up default answers file
- puppet - not changing seeds.rb anymore with puppet
- puppet - moving config_value function to rails context
- puppet - adding warning comment to all configuration files
- puppet - do not regenerate tomcat password everytime
- puppet - adding elastic search parameters
- puppet - removing log dir mangling
- puppet - removing warning message
- installer review - reformatting
- installer review - adding missing log_base require
- installer review - reformatting
- installer review - introducing cpsetup_done file
- installer review - reformatting

* Fri Jul 27 2012 Miroslav Suchý <msuchy@redhat.com> 0.2.33-1
- Making auto-stop services optional (jomara@redhat.com)
- Making the script call katello-system instead of individual system calls
  thanks to msuchys update (jomara@redhat.com)
- 820280 : print output from service $ stop (jomara@redhat.com)
- 820280 : katello-upgrad should also stop httpd & elasticsearch. Using confirm
  method for input (jomara@redhat.com)
- 820280 - katello-upgrade should stop the services it requires to be stopped
  (jomara@redhat.com)

* Thu Jul 26 2012 Miroslav Suchý <msuchy@redhat.com> 0.2.32-1
- Making katello db migration upgrade script start backend services
  (jsherril@redhat.com)
- moving katello db migration to after pulp & candlepins (jsherril@redhat.com)

* Mon Jul 23 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.31-1
- %%defattr is not needed since rpm 4.4

* Mon Jul 16 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.30-1
- ldap provided by ldap_fluff. Adds support for FreeIPA & Active Directory
- fixes an incompatibility with newer puppet versions

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
