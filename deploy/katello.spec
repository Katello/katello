# vim: sw=4:ts=4:et
#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

%if "%{?scl}" == "ruby193"
    %global scl_prefix %{scl}-
    %global scl_ruby /usr/bin/ruby193-ruby
    %global scl_rake /usr/bin/ruby193-rake
%else
    %global scl_ruby /usr/bin/ruby
    %global scl_rake /usr/bin/rake
%endif

%global homedir %{_datarootdir}/%{name}
%global confdir common

Name:           katello
Version:        2.2.0
Release:        1%{?dist}
Summary:        A package for managing application life-cycle for Linux systems
BuildArch:      noarch

Group:          Applications/Internet
License:        GPLv2
URL:            http://www.katello.org
Source0:        https://fedorahosted.org/releases/k/a/katello/%{name}-%{version}.tar.gz

# service-wait dependency
Requires:       wget
Requires:       curl
Requires:       %{?scl_prefix}rubygem-katello
Requires:       %{name}-installer
Requires:       rubygem-hammer_cli 
Requires:       rubygem-hammer_cli_foreman
Requires:       rubygem-hammer_cli_katello
Requires:       rubygem-hammer_cli_import

#foreman plugins and optional packages
Requires:       ruby193-rubygem-foreman_bootdisk
Requires:       ruby193-rubygem-foreman_discovery
Requires:       ruby193-rubygem-foreman_hooks
Requires:       foreman-libvirt
Requires:       foreman-ovirt
Requires:       foreman-vmware
Requires:       foreman-gce

BuildRequires: asciidoc
BuildRequires: util-linux

%description
Provides a package for managing application life-cycle for Linux systems.

%prep
%setup -q

%build

%if %{?scl:1}%{!?scl:0}
    #replace shebangs for SCL
    find script/ -type f | xargs sed -ri '1sX(/usr/bin/ruby|/usr/bin/env ruby)X%{scl_ruby}X'
    #use rake from SCL
    sed -ri 'sX(/usr/bin/rake|/usr/bin/env rake)X%{scl_rake}Xg' script/katello-remove-orphans
%endif

#man pages
a2x -d manpage -f manpage man/katello-service.8.asciidoc

%install
#prepare dir structure
install -d -m0755 %{buildroot}%{homedir}
install -d -m0755 %{buildroot}%{_sysconfdir}/%{name}
cp -R script %{buildroot}%{homedir}

mkdir -p %{buildroot}/%{_mandir}/man8

#copy cron scripts to be scheduled
install -d -m0755 %{buildroot}%{_sysconfdir}/cron.weekly
install -m 755 script/katello-remove-orphans %{buildroot}%{_sysconfdir}/cron.weekly/katello-remove-orphans

#copy init scripts and sysconfigs
install -Dp -m0644 %{confdir}/%{name}.sysconfig %{buildroot}%{_sysconfdir}/sysconfig/%{name}
install -Dp -m0644 %{confdir}/service-wait.sysconfig %{buildroot}%{_sysconfdir}/sysconfig/service-wait
install -Dp -m0644 %{confdir}/%{name}.logrotate %{buildroot}%{_sysconfdir}/logrotate.d/%{name}

install -p -m0644 etc/service-list %{buildroot}%{_sysconfdir}/%{name}/

#create symlinks for important scripts
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_sbindir}
mkdir -p %{buildroot}/usr/share/foreman/script/foreman-debug.d/
ln -sv %{homedir}/script/katello-debug.sh %{buildroot}/usr/share/foreman/script/foreman-debug.d/katello-debug.sh
ln -sv %{homedir}/script/katello-remove %{buildroot}%{_bindir}/katello-remove
ln -sv %{homedir}/script/katello-generate-passphrase %{buildroot}%{_bindir}/katello-generate-passphrase
ln -sv %{homedir}/script/katello-service %{buildroot}%{_bindir}/katello-service
ln -sv %{homedir}/script/service-wait %{buildroot}%{_sbindir}/service-wait

chmod +x %{buildroot}%{homedir}/script/*

# install man page
install -m 644 man/katello-service.8 %{buildroot}/%{_mandir}/man8

%post
#Generate secret token if the file does not exist
#(this must be called both for installation and upgrade)
TOKEN=/etc/katello/secret_token
# this file must not be world readable at generation time
umask 0077
test -f $TOKEN || (echo $(</dev/urandom tr -dc A-Za-z0-9 | head -c128) > $TOKEN \
    && chmod 600 $TOKEN && chown katello:katello $TOKEN)

usermod -a -G katello-shared tomcat

%files
%attr(600, katello, katello)
%{_bindir}/katello-*
%ghost %attr(600, katello, katello) %{_sysconfdir}/%{name}/secret_token

%{homedir}/script
/usr/share/foreman/script/foreman-debug.d/katello-debug.sh
%config(noreplace) %{_sysconfdir}/%{name}/service-list
%{_mandir}/man8/katello-service.8*
%{_sbindir}/service-wait
%dir %{_sysconfdir}/%{name}
%config %{_sysconfdir}/logrotate.d/%{name}
%config(noreplace) %{_sysconfdir}/sysconfig/%{name}
%config(noreplace) %{_sysconfdir}/sysconfig/service-wait
%{homedir}/script/service-wait
%defattr(-, katello, katello)
%dir %{homedir}
%config(missingok) %{_sysconfdir}/cron.weekly/katello-remove-orphans

%pre
# Add the "katello" user and group
getent group %{name} >/dev/null || groupadd -r %{name} -g 182
getent passwd %{name} >/dev/null || \
    useradd -r -g %{name} -d %{homedir} -u 182 -s /sbin/nologin -c "Katello" %{name}
# add tomcat & katello to the katello shared group for reading sensitive files
getent group katello-shared > /dev/null || groupadd -r katello-shared
usermod -a -G katello-shared katello
exit 0

%changelog
* Fri Dec 19 2014 David Davis <daviddavis@redhat.com> 2.2.0-1
- Automatic commit of package [rubygem-katello] minor release [2.2.0-1].
  (daviddavis@redhat.com)
- Fixes #6543 - updt index on cp event bz1115602 (inecas@redhat.com)

* Fri Sep 12 2014 Justin Sherrill <jsherril@redhat.com> 2.1.0-1
- bumping to katello version to 2.1 (jsherril@redhat.com)

* Fri Sep 12 2014 Justin Sherrill <jsherril@redhat.com> 2.0.0-0
- fixes #7084 - add rubygem-hammer_cli_import dep (jmontleo@redhat.com)
- Fixes #6297 - delayed jobs is dead, long live foreman-tasks
  (inecas@redhat.com)
- Fixes #7071/BZ1125391: add installer and pulp configs to katello-debug.
  (walden@redhat.com)
- Fixes #6967: Add the correct location of mongo, and collect all log files
  (bkearney@redhat.com)
- Fixes #6682 : Add a warning message if the user tries to run katello-debug.sh
  directly (bkearney@redhat.com)
- Fixes #5805: Update qpidd.conf location and grab Pulp messages in debug.
  (ericdhelms@gmail.com)
- Fixes #6245 : Add mongo and postgres logs to katello debug
  (bkearney@redhat.com)
- Fixes 6048: The spec file was not building due to the new katello-debug
  changes (bkearney@redhat.com)
- Fixes 6041: Convert katello-debug to be an extension of foreman-debug
  (bkearney@redhat.com)
- fixes #5862 - adding pulp 2.4 services to katello-service
  (jsherril@redhat.com)
- Merge pull request #3980 from iNecas/reposets-rework (inecas@redhat.com)
- Fixes #5164 - fix rpm builds (inecas@redhat.com)
- Fixes #4826 - rework reposets to not create repositories on repo set enable
  (inecas@redhat.com)
- Merge pull request #3975 from mccun934/20140409-2045 (mmccune@gmail.com)
- fixes #5164 - adding katello_remove.sh script (mmccune@redhat.com)
- fixes #4991 - adding a few foreman plugins to the default installation
  (jsherril@redhat.com)
- Fixes #4690 - Updating directory in katello deployed scripts
  (daviddavis@redhat.com)
- fixes #4744 - updating copyright to 2014 (jsherril@redhat.com)
- Merge remote-tracking branch 'origin/master' into dynflow (inecas@redhat.com)
- rename hammer_cli package for katelli support (jmontleo@redhat.com)
- Merge pull request #3609 from mccun934/requires-update9 (mmccune@gmail.com)
- remove foreman and thumbslug services now that they are no longer used
  (mmccune@redhat.com)
- Update katello-jobs to include dynflow executor (inecas@redhat.com)
- adding CLI requires so installs of katello pull in the CLI
  (mmccune@redhat.com)
- Merge pull request #3592 from mccun934/specfile-fixes3 (mmccune@gmail.com)
- remove unused calls to the defunct 'katello' service (mmccune@redhat.com)
- adding requires on the rubygem (mmccune@redhat.com)
- Spec: Removing node-installer requires and adding back katello-installer
  requires to katello RPM. (ericdhelms@gmail.com)
- removing old files from katello spec file (jsherril@redhat.com)
- removing katello's service calls and uneeded cruft

* Sat Jan 11 2014 Justin Sherrill <jsherril@redhat.com> 1.5.0-14
- adding util-linux to requires and removing f18 builds (jsherril@redhat.com)

* Sat Jan 11 2014 Justin Sherrill <jsherril@redhat.com> 1.5.0-13
- fixing requires placement in katello spec file (jsherril@redhat.com)

* Sat Jan 11 2014 Justin Sherrill <jsherril@redhat.com> 1.5.0-12
- new package built with tito

* Fri Jan 10 2014 Mike McCune <mmccune@redhat.com> 1.5.0-11
- resurrect the old katello specfile for non-ruby configs and scripts
  (mmccune@redhat.com)

* Fri Jan 10 2014 Mike McCune <mmccune@redhat.com> 1.5.0-10
- initial revision of resurrected katello package

