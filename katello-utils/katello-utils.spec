# vim: sw=4:ts=4:et
#
# Copyright 2012 Red Hat, Inc.
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
%else
    %global scl_ruby /usr/bin/ruby
%endif

Name:           katello-utils
Version:        1.3.1
Release:        1%{?dist}
Summary:        Additional tools for Katello

Group:          Applications/Internet
License:        GPLv2
URL:            http://www.katello.org
Source0:        https://fedorahosted.org/releases/k/a/katello/%{name}-%{version}.tar.gz

Requires:       coreutils
Requires:       unzip
Requires:       katello-common
Requires:       katello
Requires:       katello-glue-pulp
Requires:       %{?scl_prefix}rubygems
Requires:       %{?scl_prefix}rubygem(json)
Requires:       %{?scl_prefix}rubygem(activesupport)
Requires:       %{?scl_prefix}rubygem(oauth)
Requires:       %{?scl_prefix}rubygem(rest-client)
Requires:       %{?scl_prefix}rubygem(runcible)
Requires:       %{?scl_prefix}rubygem(fast_gettext)

BuildRequires:  /usr/bin/pod2man
BuildRequires:  findutils
BuildRequires:  make
BuildRequires:  gettext translate-toolkit
BuildRequires:  %{?scl_prefix}ruby

BuildArch: noarch


%description
Provides katello-disconnected script along with few other tools for Katello
cloud lifecycle management application.


%prep
%setup -q


%build
# replace shebangs for SCL
%if "%{scl}"
    sed -i '1s|/usr/bin/ruby|%{scl_ruby}|' bin/*
%endif

# check syntax of main configure script and libs
%{scl_ruby} -c bin/katello-disconnected

# pack gettext i18n PO files into MO files
make -C po check all-mo %{?_smp_mflags}

# build katello-configure man page
pushd man
    sed -e 's/THE_VERSION/%{version}/g' katello-disconnected.pod |\
    /usr/bin/pod2man --name=katello-disconnected -c "Katello Reference" --section=1 --release=%{version} - katello-disconnected.man1
popd


%install
install -d -m 0755 %{buildroot}%{_bindir}
install -m 0755 bin/katello-disconnected %{buildroot}%{_bindir}
install -m 0755 bin/katello-cat-manifest %{buildroot}%{_bindir}

install -d -m 0755 %{buildroot}%{_datadir}/katello-disconnected/lib
install -m 0644 lib/* %{buildroot}%{_datadir}/katello-disconnected/lib

install -d -m 0755 %{buildroot}%{_datadir}/katello-disconnected/locale
pushd po
for MOFILE in $(find . -name "*.mo"); do
    DIR=$(dirname "$MOFILE")
    install -d -m 0755 %{buildroot}%{_datadir}/katello-disconnected/locale/$DIR/LC_MESSAGES
    install -m 0644 $DIR/*.mo %{buildroot}%{_datadir}/katello-disconnected/locale/$DIR/LC_MESSAGES
done
popd

install -d -m 0755 %{buildroot}%{_mandir}/man1
install -m 0644 man/katello-disconnected.man1 %{buildroot}%{_mandir}/man1/katello-disconnected.1


%files
%{_bindir}/katello-disconnected
%{_bindir}/katello-cat-manifest
%{_datadir}/katello-disconnected/lib
%{_datadir}/katello-disconnected/locale
%{_mandir}/man1/katello-disconnected.1*


%changelog
* Tue Jan 08 2013 Lukas Zapletal <lzap+git@redhat.com> 1.3.1-1
- use dependecies according the code in ./bin/katello-disconnected
- Bumping package versions for 1.3.

* Tue Oct 23 2012 Lukas Zapletal <lzap+git@redhat.com> 1.2.1-1
- Bumping package versions for 1.1.

* Thu Sep 27 2012 Lukas Zapletal <lzap+git@redhat.com> 1.1.2-1
- katello-utils - correcting build requires
- adding two requires and comps for katello-utils

* Wed Sep 26 2012 Lukas Zapletal <lzap+git@redhat.com> 1.1.1-1
- new package built with tito

* Wed Sep 26 2012 Lukas Zapletal <lzap+rpm[@]redhat.com> - 1.1.0-1
- Initial version
