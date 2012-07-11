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

%global katello_name katello
%global headpin_name headpin
%global homedir %{_datarootdir}/%{katello_name}
%global katello_dir %{_datarootdir}/%{katello_name}
%global datadir %{_sharedstatedir}/%{katello_name}
%global confdir deploy/common

Name:           katello-headpin
Version:        0.2.23
Release:        1%{?dist}
Summary:        A subscription management only version of katello
Group:          Applications/Internet
License:        GPLv2
URL:            http://www.katello.org
Source0:        %{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

Requires:       katello-common
Requires:       katello-glue-candlepin
Requires:       katello-selinux

%if 0%{?rhel} == 6
Requires:       redhat-logos >= 60.0.14
%endif

Conflicts:      katello

BuildArch: noarch

BuildRequires:  coreutils findutils sed
BuildRequires:  rubygems
BuildRequires:  rubygem-rake
BuildRequires:  rubygem(gettext)
BuildRequires:  rubygem(jammit)
BuildRequires:  rubygem(chunky_png)
BuildRequires:  rubygem(fssm) >= 0.2.7
BuildRequires:  rubygem(compass) >= 0.11.5
BuildRequires:  rubygem(compass-960-plugin) >= 0.10.4
BuildRequires:  java >= 0:1.6.0
BuildRequires:  converge-ui-devel

%description
A subscription management only version of katello

%prep
%setup -q

%build
# pull in converge-ui
cp -R /usr/share/converge-ui-devel/* ./vendor/converge-ui

mkdir build

# katello files are copied over in gen_changes
cp -r app/ build/
cp -r autotest/ build/
cp -r ca/ build/
cp -r config/ build/
cp config.ru build/
cp -r db/ build/
cp -r deploy/ build/
cp -r doc/ build/
cp Gemfile build/
cp -r integration_spec/ build/
cp -r lib/ build/
cp LICENSE build/
cp -r locale/ build/
cp -r public/ build/
cp Rakefile build/
cp README build/
cp -r script/ build/
cp -r spec/ build/
cp -r vendor/ build/

#pull in branding if present
if [ -d branding ] ; then
  cp -r branding/* build
fi

#configure Bundler
rm -f build/Gemfile.lock
sed -i '/@@@DEV_ONLY@@@/,$d' build/Gemfile

cd build

#compile SASS files
echo Compiling SASS files...
compass compile

#generate Rails JS/CSS/... assets
echo Generating Rails assets...
jammit --config config/assets.yml -f

# remove glue-specific files
rm -rf app/models/glue/*
rm lib/resources/candlepin.rb
rm lib/resources/pulp.rb
rm lib/resources/foreman.rb

%install
rm -rf %{buildroot}
#prepare dir structure
install -d -m0755 %{buildroot}%{homedir}
install -d -m0755 %{buildroot}%{katello_dir}/config
install -d -m0755 %{buildroot}%{_sysconfdir}/%{katello_name}

cd build 

# clean the application directory before installing
[ -d tmp ] && rm -rf tmp

#copy the application to the target directory
mkdir .bundle
mv ./deploy/bundle-config .bundle/config
cp -R .bundle * %{buildroot}%{homedir}

#remove files which are not needed in the homedir
rm -rf %{buildroot}%{homedir}/README
rm -rf %{buildroot}%{homedir}/LICENSE
rm -rf %{buildroot}%{homedir}/doc
rm -rf %{buildroot}%{homedir}/deploy
rm -rf %{buildroot}%{homedir}/%{name}.spec
rm -f %{buildroot}%{homedir}/lib/tasks/.gitkeep
rm -f %{buildroot}%{homedir}/public/stylesheets/.gitkeep
rm -f %{buildroot}%{homedir}/vendor/plugins/.gitkeep

#create symlinks for data
ln -sv %{datadir}/tmp %{buildroot}%{homedir}/tmp

#create symlink for Gemfile.lock (it's being regenerated each start)
ln -svf %{datadir}/Gemfile.lock %{buildroot}%{homedir}/Gemfile.lock

#re-configure database to the /var/lib/katello directory
sed -Ei 's/\s*database:\s+db\/(.*)$/  database: \/var\/lib\/katello\/\1/g' %{buildroot}%{homedir}/config/database.yml

#branding
if [ -d ../branding ] ; then
  ln -svf %{_datadir}/icons/hicolor/24x24/apps/system-logo-icon.png %{buildroot}%{homedir}/public/images/rh-logo.png
  ln -svf %{_sysconfdir}/favicon.png %{buildroot}%{homedir}/public/images/favicon.png
  rm -rf %{buildroot}%{homedir}/branding
fi

#remove development tasks
rm %{buildroot}%{homedir}/lib/tasks/test.rake
rm %{buildroot}%{homedir}/lib/tasks/rcov.rake
rm %{buildroot}%{homedir}/lib/tasks/yard.rake
rm %{buildroot}%{homedir}/lib/tasks/hudson.rake
rm %{buildroot}%{homedir}/lib/tasks/jshint.rake

#correct permissions
find %{buildroot}%{homedir} -type d -print0 | xargs -0 chmod 755
find %{buildroot}%{homedir} -type f -print0 | xargs -0 chmod 644
chmod +x %{buildroot}%{homedir}/script/*
chmod a+r %{buildroot}%{homedir}/ca/redhat-uep.pem

%clean
rm -rf %{buildroot}

%package all
Summary:        A meta-package to pull in all components for katello-headpin
Requires:       katello-headpin
Requires:       katello-configure
Requires:       katello-cli-headpin
Requires:       postgresql-server
Requires:       postgresql
Requires:       candlepin-tomcat6
Requires:       thumbslug

%description all
This is the Katello-headpin meta-package.  If you want to install Katello and all
of its dependencies on a single machine, you should install this package
and then run katello-configure to configure everything.

%files
%defattr(-,root,root)
%{homedir}/app/controllers
%{homedir}/app/helpers
%{homedir}/app/mailers
%{homedir}/app/models/
%{homedir}/app/stylesheets
%{homedir}/app/views
%{homedir}/autotest
%{homedir}/ca
%{homedir}/config
%{homedir}/db/migrate/
%{homedir}/db/products.json
%{homedir}/db/seeds.rb
%{homedir}/integration_spec
%{homedir}/lib/*.rb
%{homedir}/lib/monkeys
%{homedir}/lib/navigation
%{homedir}/lib/resources
%{homedir}/lib/tasks
%{homedir}/lib/util
%{homedir}/lib/glue/queue.rb
%{homedir}/locale
%{homedir}/public
%{homedir}/script
%{homedir}/spec
%{homedir}/tmp
%{homedir}/vendor
%{homedir}/.bundle
%{homedir}/config.ru
%{homedir}/Gemfile
%{homedir}/Gemfile.lock
%{homedir}/Rakefile

%files all

%post

%changelog
* Wed Jul 11 2012 Jordan OMara <jomara@redhat.com> 0.2.23-1
- Automatic commit of package [katello-headpin] release [0.2.22-1].
  (jomara@redhat.com)

* Tue Jul 10 2012 Jordan OMara <jomara@redhat.com> 0.2.22-1
- new package built with tito

* Tue Jul 03 2012 Jordan OMara <jomara@redhat.com> 0.2.21-1
- new build 

* Tue Jul 03 2012 Jordan OMara <jomara@redhat.com>
- new package built with tito

* Wed Jun 20 2012 Jordan OMara <jomara@redhat.com> 0.2.19-1
- Adding monkeys (?) to spec (jomara@redhat.com)

* Wed Jun 20 2012 Jordan OMara <jomara@redhat.com> 0.2.18-1
- Community rebase 

* Fri Jun 01 2012 Jordan OMara <jomara@redhat.com> 0.2.17-1
- Moving the vendor pull in higher (jomara@redhat.com)

* Fri Jun 01 2012 Jordan OMara <jomara@redhat.com> 0.2.16-1
- new package built with tito

* Fri Jun 01 2012 Jordan OMara <jomara@redhat.com> 0.2.15-1
- minor headpin spec fix 

* Fri Jun 01 2012 Jordan OMara <jomara@redhat.com> 0.2.14-1
- Fixing headpin spec for converge ui (jomara@redhat.com)

* Fri Jun 01 2012 Jordan OMara <jomara@redhat.com> 0.2.13-1
- new package built with tito

* Fri Jun 01 2012 Jordan OMara <jomara@redhat.com>
- new package built with tito

* Thu May 24 2012 Jordan OMara <jomara@redhat.com> 0.2.10-1
- 822069 - Manual 1.1 patch since we have not incorporated the RESOURCES::
  change (jomara@redhat.com)
- 822069 - Additional fix - left integer in return body

* Fri May 18 2012 Jordan OMara <jomara@redhat.com> 0.2.9-1
- 822069 - Making candlepin proxy DELETE return a body for sub-man consumer
  delete methods
- 821010 - catch and log errors fetching release versions from cdn
  (thomasmckay@redhat.com)

* Wed May 16 2012 Jordan OMara <jomara@redhat.com> 0.2.8-1
- 812891 - Adding hypervisor record deletion to katello cli

* Wed May 16 2012 Jordan OMara <jomara@redhat.com> 0.2.7-1
- 795869 - Fixing org name in katello-configure to accept spaces but still
  create a proper candlepin key

* Wed May 09 2012 Tom McKay <thomasmckay@redhat.com> 0.2.6-4
- cherry-picking (thomasmckay@redhat.com)
- adding the ability to pass in 'development' as your env (mmccune@redhat.com)
- 817848 - Adding dry-run to candlepin proxy routes

* Mon May 07 2012 Tom McKay <thomasmckay@redhat.com> 0.2.6-3
- cherry-picking (thomasmckay@redhat.com)
- 818689 - update spec test when activating system with activation key to check
  for hidden user
- 818689 - update spec test when activating system with activation key to check
  for hidden user
- 818689 - set the current user before attempting to access activation keys to
  allow communication with candlepin
- Fix for subscriptions SLA level switcher to fit correctly.
- 818711 - use cache of release versions from CDN
- 818711 - pull release versions from CDN
- Fixed sorting in ssl-build dir listing
- Added list of ssl-build dir to katello-debug output
- 818370 - support dots in package name in nvrea (inecas@redhat.com)
- 808172 - Added code to show version information for katello cli
  (paji@redhat.com)

* Wed May 02 2012 Tom McKay <thomasmckay@redhat.com> 0.2.6-2
- bumping versions after cherry-pick (thomasmckay@redhat.com)

* Tue May 01 2012 Jordan OMara <jomara@redhat.com> 0.2.6-1
- 807291, 817634 - bit of code clean up (thomasmckay@redhat.com)
- 807291, 817634 - activation key now validates pools when loaded
  (thomasmckay@redhat.com)
- 796972 - changed '+New Something' to single string for translation, and
  clarified the 'total' string (thomasmckay@redhat.com)
- 796972 - made a single string for translators to work with in several cases
  (thomasmckay@redhat.com)
- 817658, 812417 - i686 systems arch displayed as i686 instead of blank
  (thomasmckay@redhat.com)
- 809827: katello-reset-dbs should be aware of the deployemnt type
  (bkearney@redhat.com)
- 772831 - proper way to determine IP address is through fact
  network.ipv4_address (thomasmckay@redhat.com)
- system-release-version - default landing page is now subscriptions when
  selecting a system (thomasmckay@redhat.com)
- systems - spec tests for listing systems for a pool_id
  (tstrachota@redhat.com)
- systems - api for listing systems for a pool_id (tstrachota@redhat.com)
- system-release-version - cleaning up system subscriptions tab content and ui
  (thomasmckay@redhat.com)
- add both auto-subscribe on and off options to choice list with service level
  (thomasmckay@redhat.com)

* Mon Apr 30 2012 Jordan OMara <jomara@redhat.com> 0.2.5-3
- specfile reconfigure (jomara@redhat.com)

* Mon Apr 30 2012 Jordan OMara <jomara@redhat.com>
- specfile reconfigure (jomara@redhat.com)

* Mon Apr 30 2012 Jordan OMara <jomara@redhat.com> 0.2.5-2
- Re-arranging headpin build files (jomara@redhat.com)

* Mon Apr 30 2012 Jordan OMara <jomara@redhat.com>
- Re-arranging headpin build files (jomara@redhat.com)

* Mon Apr 30 2012 Jordan OMara <jomara@redhat.com>
- Re-arranging headpin build files (jomara@redhat.com)

* Thu Apr 26 2012 Jordan OMara <jomara@redhat.com> 0.2.4-3
- Update for katello changes (jomara@redhat.com)

* Thu Apr 26 2012 Jordan OMara <jomara@redhat.com> 0.2.4-2
- Bump for minor releasers.conf change 

* Wed Apr 25 2012 Jordan OMara <jomara@redhat.com> 0.2.4-1
- 

* Wed Apr 25 2012 Jordan OMara <jomara@redhat.com> 0.2.3-1
- Adding all the katello files back in src/ (jomara@redhat.com)

* Wed Apr 25 2012 Jordan OMara <jomara@redhat.com> 0.2.2-1
- Moving src copy to symlink (jomara@redhat.com)
- test (jomara@redhat.com)
- Merging headpin flags into master (jomara@redhat.com)

* Mon Nov 28 2011 Tom McKay <thomasmckay@redhat.com> 0.1.107-1
- gen_changes.sh. run (thomasmckay@redhat.com)
- Add thumbslug requires for katello-headpin (jbowes@redhat.com)

* Thu Nov 17 2011 Tom McKay <thomasmckay@redhat.com> 0.1.106-1
- gen_changes.sh run (thomasmckay@redhat.com)

* Thu Nov 17 2011 Tom McKay <thomasmckay@redhat.com> 0.1.105-1
- gen_changes.sh run (thomasmckay@redhat.com)

* Fri Nov 11 2011 Tom McKay <thomasmckay@redhat.com> 0.1.104-1
- gen_changes.sh run (thomasmckay@redhat.com)

* Wed Nov 09 2011 Tom McKay <thomasmckay@redhat.com> 0.1.103-1
- gen_changes.sh run (thomasmckay@redhat.com)

* Tue Nov 08 2011 Tom McKay <thomasmckay@redhat.com> 0.1.102-1
- gen_changes.sh run (thomasmckay@redhat.com)

* Fri Nov 04 2011 Tom McKay <thomasmckay@redhat.com> 0.1.101-1
- gen_changes.sh run (thomasmckay@redhat.com)
- Add in requirements for katello-configure and the headpin cli
  (bkearney@redhat.com)
- gen_changes.sh run (thomasmckay@redhat.com)
- Remove test.rake which requires rspec/core (bkearney@redhat.com)
- Force a good copy (bkearney@redhat.com)
- debug (bkearney@redhat.com)
- Force the copy (bkearney@redhat.com)
- missed some files (bkearney@redhat.com)

* Mon Oct 31 2011 Bryan Kearney <bkearney@redhat.com> 0.1.100-1
- Overwrite the katello files with the headpin files (bkearney@redhat.com)
- Did not actually copy the files. Whoops (bkearney@redhat.com)
- Pull in the latest code from master (bkearney@redhat.com)
- Pull in the latest from source (bkearney@redhat.com)

* Wed Oct 26 2011 Bryan Kearney <bkearney@redhat.com> 0.1.99-1
- Move the headpin packaegs to a new location (bkearney@redhat.com)

* Wed Oct 19 2011 Mike McCune <mmccune@redhat.com> 0.1.98-1
- moving the headpin generated source and specfile into rel-eng
  (mmccune@redhat.com)

* Wed Oct 19 2011 Mike McCune <mmccune@redhat.com> 0.1.97-1
- new package built with tito

* Tue Oct 18 2011 Bryan Kearney <bkearney@redhat.com> 0.1.96-1
- new package built with tito


