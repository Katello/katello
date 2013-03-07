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

Name:           katello-utils
Version:        1.3.1
Release:        1%{?dist}
Summary:        Additional tools for Katello

Group:          Applications/Internet
License:        GPLv2
URL:            http://www.katello.org
Source0:        https://fedorahosted.org/releases/k/a/katello/%{name}-%{version}.tar.gz

Requires:       coreutils
BuildRequires:  /usr/bin/pod2man
BuildRequires:  findutils
BuildRequires:  ruby
Requires:       unzip
Requires:       katello-common
Requires:       katello
Requires:       katello-glue-pulp
Requires:       rubygems
Requires:       rubygem(json)
Requires:       rubygem(activesupport)
Requires:       rubygem(oauth)
Requires:       rubygem(rest-client)
Requires:       rubygem(runcible)


BuildArch: noarch


%description
Provides katello-disconnected script along with few other tools for Katello
cloud lifecycle management application.


%prep
%setup -q


%build
%if ! 0%{?fastbuild:1}
    #check syntax of main configure script and libs
    ruby -c bin/katello-disconnected
%endif

#build katello-configure man page
pushd man
    sed -e 's/THE_VERSION/%{version}/g' katello-disconnected.pod |\
    /usr/bin/pod2man --name=katello -c "Katello Reference" --section=1 --release=%{version} - katello-disconnected.man1
popd


%install
install -d -m 0755 %{buildroot}%{_sbindir}
install -m 0755 bin/katello-disconnected %{buildroot}%{_sbindir}
install -m 0755 bin/katello-cat-manifest %{buildroot}%{_sbindir}
install -d -m 0755 %{buildroot}%{_mandir}/man1
install -m 0644 man/katello-disconnected.man1 %{buildroot}%{_mandir}/man1/katello-disconnected.1


%files
%{_sbindir}/katello-disconnected
%{_sbindir}/katello-cat-manifest
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
