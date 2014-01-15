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
Version:        1.5.0
Release:        14%{?dist}
Summary:        A package for managing application life-cycle for Linux systems
BuildArch:      noarch

Group:          Applications/Internet
License:        GPLv2
URL:            http://www.katello.org
Source0:        https://fedorahosted.org/releases/k/a/katello/%{name}-%{version}.tar.gz

# service-wait dependency
Requires:       wget
Requires:       curl

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
    sed -ri 'sX(/usr/bin/rake|/usr/bin/env rake)X%{scl_rake}Xg' script/katello-refresh-cdn
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
install -d -m0755 %{buildroot}%{_sysconfdir}/cron.daily
install -d -m0755 %{buildroot}%{_sysconfdir}/cron.weekly
install -m 755 script/katello-refresh-cdn %{buildroot}%{_sysconfdir}/cron.daily/katello-refresh-cdn
install -m 755 script/katello-remove-orphans %{buildroot}%{_sysconfdir}/cron.weekly/katello-remove-orphans

#copy init scripts and sysconfigs
install -Dp -m0644 %{confdir}/%{name}.sysconfig %{buildroot}%{_sysconfdir}/sysconfig/%{name}
install -Dp -m0644 %{confdir}/service-wait.sysconfig %{buildroot}%{_sysconfdir}/sysconfig/service-wait
install -Dp -m0755 %{confdir}/%{name}-jobs.init %{buildroot}%{_initddir}/%{name}-jobs
install -Dp -m0644 %{confdir}/%{name}.logrotate %{buildroot}%{_sysconfdir}/logrotate.d/%{name}

install -p -m0644 etc/service-list %{buildroot}%{_sysconfdir}/%{name}/

#create symlinks for important scripts
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_sbindir}
ln -sv %{homedir}/script/katello-jobs %{buildroot}%{_bindir}/katello-jobs
ln -sv %{homedir}/script/katello-debug %{buildroot}%{_bindir}/katello-debug
ln -sv %{homedir}/script/katello-generate-passphrase %{buildroot}%{_bindir}/katello-generate-passphrase
ln -sv %{homedir}/script/katello-service %{buildroot}%{_bindir}/katello-service
ln -sv %{homedir}/script/service-wait %{buildroot}%{_sbindir}/service-wait

chmod +x %{buildroot}%{homedir}/script/*

# install man page
install -m 644 man/katello-service.8 %{buildroot}/%{_mandir}/man8

%post
#Add /etc/rc*.d links for the script
/sbin/chkconfig --add %{name}
/sbin/chkconfig --add %{name}-jobs

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
%config(noreplace) %{_sysconfdir}/%{name}/service-list
%{_mandir}/man8/katello-service.8*
%{_sbindir}/service-wait
%dir %{_sysconfdir}/%{name}
%config %{_sysconfdir}/logrotate.d/%{name}
%config(noreplace) %{_sysconfdir}/sysconfig/%{name}
%config(noreplace) %{_sysconfdir}/sysconfig/service-wait
%{_initddir}/%{name}-jobs
%{homedir}/script/service-wait
%defattr(-, katello, katello)
%dir %{homedir}
%config(missingok) %{_sysconfdir}/cron.daily/katello-refresh-cdn
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

%preun
if [ $1 -eq 0 ] ; then
    /sbin/service %{name}-jobs stop >/dev/null 2>&1
    /sbin/chkconfig --del %{name}-jobs
    /sbin/service %{name} stop >/dev/null 2>&1
    /sbin/chkconfig --del %{name}
fi

%changelog
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

