# vim: sw=4:ts=4:et
#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

%define selinux_variants targeted
%define selinux_policyver %(sed -e 's,.*selinux-policy-\\([^/]*\\)/.*,\\1,' /usr/share/selinux/devel/policyhelp 2> /dev/null)
%define POLICYCOREUTILSVER 1.33.12-1

%define moduletype apps
%define modulename katello

Name:           %{modulename}-selinux
Version:        1.3.0
Release:        1%{?dist}
Summary:        SELinux policy module supporting Katello

Group:          System Environment/Base
License:        GPLv2+
URL:            http://www.katello.org
Source0:        https://fedorahosted.org/releases/k/a/katello/%{name}-%{version}.tar.gz

BuildRequires:  checkpolicy, selinux-policy-devel, hardlink
BuildRequires:  policycoreutils >= %{POLICYCOREUTILSVER}
BuildRequires:  /usr/bin/pod2man
BuildArch:      noarch

%if "%{selinux_policyver}" != ""
Requires:       selinux-policy >= %{selinux_policyver}
%endif
%if 0%{?rhel} == 5
Requires:       selinux-policy >= 2.4.6-80
%endif
Requires(post):   /usr/sbin/semodule, /sbin/restorecon, /usr/sbin/setsebool, /usr/sbin/selinuxenabled, /usr/sbin/semanage
Requires(post): policycoreutils-python
Requires(post): selinux-policy-targeted
Requires(postun): /usr/sbin/semodule, /sbin/restorecon
Requires(pre):       %{modulename}-common

%description
SELinux policy module supporting Katello.

%prep
%setup -q

%build
# Build SELinux policy modules
perl -i -pe 'BEGIN { $VER = join ".", grep /^\d+$/, split /\./, "%{version}.%{release}"; } s!\@\@VERSION\@\@!$VER!g;' %{modulename}.te
for selinuxvariant in %{selinux_variants}
do
    make NAME=${selinuxvariant} -f /usr/share/selinux/devel/Makefile
    bzip2 -9 %{modulename}.pp
    mv %{modulename}.pp.bz2 %{modulename}.ppbz2.${selinuxvariant}
    make NAME=${selinuxvariant} -f /usr/share/selinux/devel/Makefile clean
done

# Build man pages
/usr/bin/pod2man --name=katello-selinux-enable -c "Katello Reference" --section=8 --release=%{version} katello-selinux-enable.pod katello-selinux-enable.man8
/usr/bin/pod2man --name=katello-selinux-relabel -c "Katello Reference" --section=8 --release=%{version} katello-selinux-relabel.pod katello-selinux-relabel.man8

%install
# Install SELinux policy modules
for selinuxvariant in %{selinux_variants}
  do
    install -d %{buildroot}%{_datadir}/selinux/${selinuxvariant}
    install -p -m 644 %{modulename}.ppbz2.${selinuxvariant} \
           %{buildroot}%{_datadir}/selinux/${selinuxvariant}/%{modulename}.pp.bz2
  done

# Install SELinux interfaces
install -d %{buildroot}%{_datadir}/selinux/devel/include/%{moduletype}
install -p -m 644 %{modulename}.if \
  %{buildroot}%{_datadir}/selinux/devel/include/%{moduletype}/%{modulename}.if

# Hardlink identical policy module packages together
/usr/sbin/hardlink -cv %{buildroot}%{_datadir}/selinux

# Install %{name}-enable which will be called in %posttrans
install -d %{buildroot}%{_sbindir}
install -p -m 755 %{name}-enable %{buildroot}%{_sbindir}/%{name}-enable
install -p -m 755 %{name}-relabel %{buildroot}%{_sbindir}/%{name}-relabel

# Install man pages
install -d -m 0755 %{buildroot}%{_mandir}/man8
install -m 0644 katello-selinux-enable.man8 %{buildroot}%{_mandir}/man8/katello-selinux-enable.8
install -m 0644 katello-selinux-relabel.man8 %{buildroot}%{_mandir}/man8/katello-selinux-relabel.8

# Install secure (extra protected) directory
install -d -m 0750 %{buildroot}%{_sysconfdir}/katello/secure

%post
if /usr/sbin/selinuxenabled ; then
   %{_sbindir}/%{name}-enable
fi

%posttrans
if /usr/sbin/selinuxenabled ; then
  %{_sbindir}/%{name}-relabel
fi

%postun
# Clean up after package removal
if [ $1 -eq 0 ]; then
  for selinuxvariant in %{selinux_variants}
    do
      /usr/sbin/semodule -s ${selinuxvariant} -l > /dev/null 2>&1 \
        && /usr/sbin/semodule -s ${selinuxvariant} -r %{modulename} || :
    done
fi

%files
%doc %{modulename}.fc %{modulename}.if %{modulename}.te
%attr(0600,root,root) %{_datadir}/selinux/*/%{modulename}.pp.bz2
%{_datadir}/selinux/devel/include/%{moduletype}/%{modulename}.if
%{_mandir}/man8/*
%attr(0755,root,root) %{_sbindir}/%{name}-enable
%attr(0755,root,root) %{_sbindir}/%{name}-relabel
%attr(0750,root,katello-shared) %{_sysconfdir}/katello/secure

%changelog
* Thu Sep 27 2012 Miroslav Suchý <msuchy@redhat.com> 1.1.2-1
- package katello-selinux-relabel (msuchy@redhat.com)
- do not pretend that we support MLS or Simple selinux (msuchy@redhat.com)
- do not run restorcon twice (msuchy@redhat.com)

* Thu Aug 23 2012 Mike McCune <mmccune@redhat.com> 1.1.1-1
- buildroot and %%clean section is not needed (msuchy@redhat.com)
- Bumping package versions for 1.1. (msuchy@redhat.com)

* Tue Jul 31 2012 Miroslav Suchý <msuchy@redhat.com> 1.0.1-1
- bump up version to 1.0 (msuchy@redhat.com)

* Mon Jul 30 2012 Miroslav Suchý <msuchy@redhat.com> 0.2.7-1
- selinux - katello configure denials (lzap+git@redhat.com)
- point Source0 to fedorahosted.org where tar.gz are stored (msuchy@redhat.com)
- %%defattr is not needed since rpm 4.4 (msuchy@redhat.com)

* Wed Jun 27 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.6-1
- 828533 - removing semanage port rule from installer
- 828533 - changing to proper QPIDD SSL port

* Thu May 17 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.5-1
- encryption - plain text passwords encryption

* Mon Mar 26 2012 Martin Bačovský <mbacovsk@redhat.com> 0.2.4-1
- 805124 - security review of world-readabl fils (mbacovsk@redhat.com)
- 803761 - adding man page for selinux-enable (lzap+git@redhat.com)

* Mon Mar 12 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.3-1
- 801752 - Errors installing katello-selinux

* Mon Feb 27 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.2-1
- 761314 - Make sure katello-agent communicates with ssl

* Wed Feb 22 2012 Mike McCune <mmccune@redhat.com> 0.2.1-1
- 790507 - fixing httpds SAM denials of mod_proxy (lzap+git@redhat.com)

* Mon Jan 30 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.4-1
- selinux - adding requirement for the main package
- selinux - adding rh header

* Mon Jan 23 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.3-1
- selinux - adding katello-selinux-enable script

* Mon Jan 23 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.2-1
- new package built with tito

