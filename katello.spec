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

%global homedir %{_datarootdir}/%{name}
%global datadir %{_sharedstatedir}/%{name}
%global confdir deploy/common

Name:           katello
Version:        0.2.44
Release:        1%{?dist}
Summary:        A package for managing application life-cycle for Linux systems
BuildArch:      noarch

Group:          Applications/Internet
License:        GPLv2
URL:            http://www.katello.org

# How to create the source tarball:
#
# git clone git://git.fedorahosted.org/git/katello.git/
# yum install tito
# cd src/
# tito build --tag katello-%{version}-%{release} --tgz
Source0:        %{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

Requires:        %{name}-common
Requires:        %{name}-glue-pulp
Requires:        %{name}-glue-foreman
Requires:        %{name}-glue-candlepin
Requires:        %{name}-selinux
Conflicts:       %{name}-headpin

%description
Provides a package for managing application life-cycle for Linux systems.

%package common
BuildArch:      noarch
Summary:        Common bits for all Katello instances
Requires:       httpd
Requires:       mod_ssl
Requires:       openssl
Requires:       elasticsearch
Requires:       rubygems
Requires:       rubygem(rails) >= 3.0.10
Requires:       rubygem(haml) >= 3.1.2
Requires:       rubygem(haml-rails)
Requires:       rubygem(json)
Requires:       rubygem(rest-client)
Requires:       rubygem(jammit)
Requires:       rubygem(rails_warden)
Requires:       rubygem(net-ldap)
Requires:       rubygem(compass) >= 0.11.5
Requires:       rubygem(compass-960-plugin) >= 0.10.4
Requires:       rubygem(oauth)
Requires:       rubygem(i18n_data) >= 0.2.6
Requires:       rubygem(gettext_i18n_rails)
Requires:       rubygem(simple-navigation) >= 3.3.4
Requires:       rubygem(pg)
Requires:       rubygem(delayed_job) >= 2.1.4
Requires:       rubygem(acts_as_reportable) >= 1.1.1
Requires:       rubygem(pdf-writer) >= 1.1.8
Requires:       rubygem(ruport) >= 1.6.3
Requires:       rubygem(daemons) >= 1.1.4
Requires:       rubygem(uuidtools)
Requires:       rubygem(thin)
Requires:       rubygem(fssm)
Requires:       rubygem(sass)
Requires:       rubygem(chunky_png)
Requires:       rubygem(tire)

%if 0%{?rhel} == 6
Requires:       redhat-logos >= 60.0.14
%endif

# <workaround> for 714167 - undeclared dependencies (regin & multimap)
# TODO - uncomment the statement once we push patched actionpack to our EL6 repo
#%if 0%{?fedora} && 0%{?fedora} <= 15
Requires:       rubygem(regin)
#%endif
# </workaround>

Requires(pre):  shadow-utils
Requires(preun): chkconfig
Requires(preun): initscripts
Requires(post): chkconfig
Requires(postun): initscripts coreutils sed

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
BuildRequires:  converge-ui-devel >= 0.7

%description common
Common bits for all Katello instances


%package all
BuildArch:      noarch
Summary:        A meta-package to pull in all components for Katello
Requires:       %{name}
Requires:       %{name}-configure
Requires:       %{name}-cli
Requires:       postgresql-server
Requires:       postgresql
Requires:       pulp
Requires:       candlepin-tomcat6
# the following backend engine deps are required by <katello-configure>
Requires:       mongodb mongodb-server
Requires:       qpid-cpp-server qpid-cpp-client qpid-cpp-client-ssl qpid-cpp-server-ssl
# </katello-configure>


%description all
This is the Katello meta-package.  If you want to install Katello and all
of its dependencies on a single machine, you should install this package
and then run katello-configure to configure everything.

%package glue-pulp
BuildArch:      noarch
Summary:         Katello connection classes for the Pulp backend
Requires:        %{name}-common

%description glue-pulp
Katello connection classes for the Pulp backend

%package glue-foreman
BuildArch:      noarch
Summary:         Katello connection classes for the Foreman backend
Requires:        %{name}-common

%description glue-foreman
Katello connection classes for the Foreman backend

%package glue-candlepin
BuildArch:      noarch
Summary:         Katello connection classes for the Candlepin backend
Requires:        %{name}-common

%description glue-candlepin
Katello connection classes for the Candlepin backend

%prep
%setup -q

%build

#copy converge-ui
cp -R /usr/share/converge-ui-devel/* ./vendor/converge-ui

#configure Bundler
rm -f Gemfile.lock
sed -i '/@@@DEV_ONLY@@@/,$d' Gemfile

#pull in branding if present
if [ -d branding ] ; then
  cp -r branding/* .
fi

#compile SASS files
echo Compiling SASS files...
compass compile

#generate Rails JS/CSS/... assets
echo Generating Rails assets...
LC_ALL="en_US.UTF-8" jammit --config config/assets.yml -f


#create mo-files for L10n (since we miss build dependencies we can't use #rake gettext:pack)
echo Generating gettext files...
ruby -e 'require "rubygems"; require "gettext/tools"; GetText.create_mofiles(:po_root => "locale", :mo_root => "locale")'

%install
rm -rf %{buildroot}
#prepare dir structure
install -d -m0755 %{buildroot}%{homedir}
install -d -m0755 %{buildroot}%{datadir}
install -d -m0755 %{buildroot}%{datadir}/tmp
install -d -m0755 %{buildroot}%{datadir}/tmp/pids
install -d -m0755 %{buildroot}%{_sysconfdir}/%{name}
install -d -m0755 %{buildroot}%{_localstatedir}/log/%{name}

# clean the application directory before installing
[ -d tmp ] && rm -rf tmp

#copy the application to the target directory
mkdir .bundle
mv ./deploy/bundle-config .bundle/config
cp -R .bundle * %{buildroot}%{homedir}

#copy configs and other var files (will be all overwriten with symlinks)
install -m 600 config/%{name}.yml %{buildroot}%{_sysconfdir}/%{name}/%{name}.yml
install -m 644 config/environments/production.rb %{buildroot}%{_sysconfdir}/%{name}/environment.rb

#copy cron scripts to be scheduled daily
install -d -m0755 %{buildroot}%{_sysconfdir}/cron.daily
install -m 755 script/katello-refresh-cdn %{buildroot}%{_sysconfdir}/cron.daily/katello-refresh-cdn

#copy init scripts and sysconfigs
install -Dp -m0644 %{confdir}/%{name}.sysconfig %{buildroot}%{_sysconfdir}/sysconfig/%{name}
install -Dp -m0755 %{confdir}/%{name}.init %{buildroot}%{_initddir}/%{name}
install -Dp -m0755 %{confdir}/%{name}-jobs.init %{buildroot}%{_initddir}/%{name}-jobs
install -Dp -m0644 %{confdir}/%{name}.completion.sh %{buildroot}%{_sysconfdir}/bash_completion.d/%{name}
install -Dp -m0644 %{confdir}/%{name}.logrotate %{buildroot}%{_sysconfdir}/logrotate.d/%{name}
install -Dp -m0644 %{confdir}/%{name}-jobs.logrotate %{buildroot}%{_sysconfdir}/logrotate.d/%{name}-jobs
install -Dp -m0644 %{confdir}/%{name}.httpd.conf %{buildroot}%{_sysconfdir}/httpd/conf.d/%{name}.conf
install -Dp -m0644 %{confdir}/thin.yml %{buildroot}%{_sysconfdir}/%{name}/
install -Dp -m0644 %{confdir}/mapping.yml %{buildroot}%{_sysconfdir}/%{name}/

#overwrite config files with symlinks to /etc/katello
ln -svf %{_sysconfdir}/%{name}/%{name}.yml %{buildroot}%{homedir}/config/%{name}.yml
#ln -svf %{_sysconfdir}/%{name}/database.yml %{buildroot}%{homedir}/config/database.yml
ln -svf %{_sysconfdir}/%{name}/environment.rb %{buildroot}%{homedir}/config/environments/production.rb

#create symlinks for some db/ files
ln -svf %{datadir}/schema.rb %{buildroot}%{homedir}/db/schema.rb

#create symlinks for data
ln -sv %{_localstatedir}/log/%{name} %{buildroot}%{homedir}/log
ln -sv %{datadir}/tmp %{buildroot}%{homedir}/tmp

#create symlink for Gemfile.lock (it's being regenerated each start)
ln -svf %{datadir}/Gemfile.lock %{buildroot}%{homedir}/Gemfile.lock

#create symlinks for important scripts
mkdir -p %{buildroot}%{_bindir}
ln -sv %{homedir}/script/katello-debug %{buildroot}%{_bindir}/katello-debug
ln -sv %{homedir}/script/katello-generate-passphrase %{buildroot}%{_bindir}/katello-generate-passphrase

#re-configure database to the /var/lib/katello directory
sed -Ei 's/\s*database:\s+db\/(.*)$/  database: \/var\/lib\/katello\/\1/g' %{buildroot}%{homedir}/config/database.yml

#remove files which are not needed in the homedir
rm -rf %{buildroot}%{homedir}/README
rm -rf %{buildroot}%{homedir}/LICENSE
rm -rf %{buildroot}%{homedir}/doc
rm -rf %{buildroot}%{homedir}/deploy
rm -rf %{buildroot}%{homedir}/%{name}.spec
rm -f %{buildroot}%{homedir}/lib/tasks/.gitkeep
rm -f %{buildroot}%{homedir}/public/stylesheets/.gitkeep
rm -f %{buildroot}%{homedir}/vendor/plugins/.gitkeep

#remove development tasks
rm %{buildroot}%{homedir}/lib/tasks/test.rake

#branding
if [ -d branding ] ; then
  ln -svf %{_datadir}/icons/hicolor/24x24/apps/system-logo-icon.png %{buildroot}%{homedir}/public/images/rh-logo.png
  ln -svf %{_sysconfdir}/favicon.png %{buildroot}%{homedir}/public/images/favicon.png
  rm -rf %{buildroot}%{homedir}/branding
fi

#remove development tasks
rm %{buildroot}%{homedir}/lib/tasks/rcov.rake
rm %{buildroot}%{homedir}/lib/tasks/yard.rake
rm %{buildroot}%{homedir}/lib/tasks/hudson.rake

#correct permissions
find %{buildroot}%{homedir} -type d -print0 | xargs -0 chmod 755
find %{buildroot}%{homedir} -type f -print0 | xargs -0 chmod 644
chmod +x %{buildroot}%{homedir}/script/*
chmod a+r %{buildroot}%{homedir}/ca/redhat-uep.pem

%clean
rm -rf %{buildroot}

%post common
#Add /etc/rc*.d links for the script
/sbin/chkconfig --add %{name}
/sbin/chkconfig --add %{name}-jobs

%postun common
#update config/initializers/secret_token.rb with new key
NEWKEY=$(</dev/urandom tr -dc A-Za-z0-9 | head -c128)
sed -i "s/^Src::Application.config.secret_token = '.*'/Src::Application.config.secret_token = '$NEWKEY'/" \
    %{homedir}/config/initializers/secret_token.rb

if [ "$1" -ge "1" ] ; then
    /sbin/service %{name} condrestart >/dev/null 2>&1 || :
fi

%files
%attr(600, katello, katello)
%defattr(-,root,root)
%{_bindir}/katello-*
%{homedir}/app/controllers
%{homedir}/app/helpers
%{homedir}/app/mailers
%{homedir}/app/models/*.rb
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
%{homedir}/lib/glue/*.rb
%{homedir}/lib/monkeys/*.rb
%{homedir}/lib/navigation
%{homedir}/lib/resources/cdn.rb
%{homedir}/lib/tasks
%{homedir}/lib/util
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

%files common
%defattr(-,root,root)
%doc README LICENSE doc/
%config(noreplace) %{_sysconfdir}/%{name}/%{name}.yml
%config(noreplace) %{_sysconfdir}/%{name}/thin.yml
%config(noreplace) %{_sysconfdir}/httpd/conf.d/%{name}.conf
%config %{_sysconfdir}/%{name}/environment.rb
%config %{_sysconfdir}/logrotate.d/%{name}
%config %{_sysconfdir}/logrotate.d/%{name}-jobs
%config %{_sysconfdir}/%{name}/mapping.yml
%config(noreplace) %{_sysconfdir}/sysconfig/%{name}
%{_initddir}/%{name}
%{_initddir}/%{name}-jobs
%{_sysconfdir}/bash_completion.d/%{name}
%{homedir}/log
%{homedir}/db/schema.rb

%defattr(-, katello, katello)
%{_localstatedir}/log/%{name}
%{datadir}
%ghost %attr(640, katello, katello) %{_localstatedir}/log/%{name}/production.log
%ghost %attr(640, katello, katello) %{_localstatedir}/log/%{name}/production_sql.log
%ghost %attr(640, katello, katello) %{_localstatedir}/log/%{name}/production_delayed_jobs.log
%ghost %attr(640, katello, katello) %{_localstatedir}/log/%{name}/production_delayed_jobs_sql.log

%files glue-pulp
%{homedir}/app/models/glue/pulp
%{homedir}/lib/resources/pulp.rb
%config(missingok) %{_sysconfdir}/cron.daily/katello-refresh-cdn

%files glue-candlepin
%{homedir}/app/models/glue/candlepin
%{homedir}/app/models/glue/provider.rb
%{homedir}/lib/resources/candlepin.rb

%files glue-foreman
%{homedir}/lib/resources/foreman.rb

%files all

%pre common
# Add the "katello" user and group
getent group %{name} >/dev/null || groupadd -r %{name} -g 182
getent passwd %{name} >/dev/null || \
    useradd -r -g %{name} -d %{homedir} -u 182 -s /sbin/nologin -c "Katello" %{name}
exit 0

%preun common
if [ $1 -eq 0 ] ; then
    /sbin/service %{name}-jobs stop >/dev/null 2>&1
    /sbin/chkconfig --del %{name}-jobs
    /sbin/service %{name} stop >/dev/null 2>&1
    /sbin/chkconfig --del %{name}
fi

%changelog
* Mon Jul 02 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.44-1
- 829437 - handle uploading GPG key when submitting with enter
- Removed exclamation mark from welcome message, as it is followed by a comma
  and the user name.
- Fixing navigation for HEADPIN mode (system groups)
- Band-aid commit to update submodule hash to latest due to addition of version
  requirement in katello spec.
- we should own log files
- system groups - cli - split history in to 2 actions per review feedback
- allow to run jammit on Fedora 17
- require converge-ui-devel >- 0.7 for building
- system groups - api/cli to support errata install
- system groups - api/cli to support package and package group actions
- system groups - fix the perms used in packages and errata controllers
- 835322 - when creating new user, validate email

* Wed Jun 27 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.43-1
- Stupid extra space.
- Fix for a missing 'fr' in a gradient.
- More SCSS refactoring and a fix for converge-ui spec.
- point Support link to irc channel #katello

* Mon Jun 25 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.42-1
- katello - async manifest import, missing notices
- ulimit - brad's review
- ulimit - optimizing usage validator
- changed 'update' tests to use 'put' instead of 'post'
- BZ 825262: support for moving systems between environments from CLI
- ulimit - fix for system tests
- ulimit - adding unit tests
- ulimit - new jeditable component "number"
- ulimit - frontend changes
- ulimit - backend api and cli
- ulimit - adding migration
- Merge pull request #224 from bbuckingham/fork-group_delete_systems
- katello - fix gettext wrappers
- system groups - cli/api - provide user option to delete systems when deleting
  group
- katello - asynchronous manifest import in UI
- Merge pull request #213 from jsomara/819002
- system groups - ui - provide user option to delete systems when deleting
  group
- customConfirm - add more settings and refactor current usage
- katello, unit - fixing broken unit test
- katello, unit - correcting supported versions of rspec for monkey patch
- Make sure to reference ::Pool when using the model class
- 819002 - Removing password & email validation for user creation in LDAP mode
- system groups - update views to use _tupane_header partial

* Mon Jun 18 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.41-1
- Fixes box-shadow declaration that was causing a compass deprecation warning.
- Updates SCSS importing for missing mixins.
- system groups - provide a more meaningful helptip on the index
- Fix for Events to now be "Events History" - slightly more explicit.
- katello - fix Gemfile versions
- system groups - minor updates to job and task_status
- task_status - rename method names based
- activation keys - update subscriptions pane to use the panel_link
- rename navigation_element as panel_link, use it for link on group pane
- system groups - api - include total system count in system group info
- system groups - add system count to Details page
- Removes no longer used route and asset declaration. Adds back template
  rendering test case for change password.
- system groups - add missing escape_javascript to _common_i18n.html.haml
- 830713 - broken gettext translations
- Updates to latest converge-ui to incorporate most recent adjustments to sign-
  on screens.
- 828308 - Updating sync plan does not update associated product's (repo's)
  sync schedule
- system groups - remove 'details' on job since it is a dup of as_json
- system groups - add few specs for events controller
- Fixes for broken spec tests as a result of moving password recovery views.
- system group - add some initial search support to group history
- Updates converge-ui version.
- Adds variables for upstream coloring and cleans up some unneeded converge-ui
  pieces.
- Clean-up of views that are no longer needed as a result of using converge-ui
  layouts.
- 827540 - system template - description to promotions view
- subs-tupane - changed camelCase to under_score, fixed spec tests
- subs-tupane - case statement instead of if/elsif, elasticsearch
  index_settings tweak
- subs-tupane: move some of the logic out of Pool.index_pools to the controller
- subs-tupane: since not all pools are saved as activerecords, just those
  referenced in activation keys, removed use of IndexedModel
- subs-tupane: reverted a change to indexed_model.rb
- subs-tupane: new Pool class in place of KTPool with relevant attributes, all
  indexed for search
- system events - fix specs related to changes in status retrieval
- systems - events - update search to include task owner
- system groups - remove tasks class from view
- 830713 - broken gettext translations
- system groups - support status updates on individual system tasks
- system groups - event/job status updates
- Updates to login to handle case when LDAP is enabled.
- system groups - events - add a tipsy to show status of a task
- system groups - when saving tasks for a job, associate system w/ the task
- task status - clean up some of the status messages
- 830176 - wrapped New System text w/ _()
- system and group actions - replacing .spinner with use of image_tag
- 815308 - traceback on package search
- system packages - fix event binding
- Updates pathing for some assets in converge-ui and bumps the version to
  include recent login and re-factor work.
- Adds a rake task that explicitly specifies the directories to look in for
  translations.  This was done to add in and address translations living in the
  dependent converge-ui project.
- removal of system_tasks, replace with polymorphic assoc on task_statuses
- Changes around using the user sessions layouts from converge-ui in order to
  fit with new styling and to ensure consistent wiring of views to controller.
- Adds font URL settings for compass to generate font-url's directly based off
  the Relative Root Url.
- Icons fix that is in converge-ui.
- 829208 - fix importing manifest after creating custom product
- Fixes for both extra arrows on menu in panel and for details icon
  duplication.
- UI Remodel - More updates to stylesheets to relfect changes in converge-ui
  with regards to importing the proper scss files.
- system groups - initial commit to introduce group events
- system - minor refactors for code that will be shared for system groups
- 823642 - nil checks in candlepin's product resource
- system groups - update errata and packages partials to use new spinner
  definition
- system groups - update to have Content as 3rd level nav
- Provides fix for updated yield blocks within converge-ui.
- system - updating to support Content as 3rd level nav
- Removed now unnecessary (and previously commented) code block.
- Fix for previously pulled out auto_complete functionality.
- 818726 - updated i18n translations
- katello, unit tests - track creation line of mocks
- Fix for appname in header on converge-ui.
- js - minor updates based on pull request 166 feedback
- system groups - UI - initial commit to enable pkg/group install/update/remove
- system task - missed a change on the task status refactor
- system groups - minor update to correctly reflect object being returned
- packages - refactor js utilities for reuse
- system tasks - refactor the task status for reuse in system groups...etc.
- system packages - refactor few methods that will be reused for system groups
- system package actions - fix text/parameters on some notices
- 824944 - Fix for logout button missing.
- Converge-UI and Katello SCSS and Image refactor.
- UI Remodel - Updates to login and password reset/change screens to get the
  converge-ui versions working.
- UI Remodel - Updates converge-ui javascript paths to point to base javascript
  directory and not just the lib.
- UI Remodel - Adds working login screen and footer.
- First pass integration of converge-ui login layout.  Styles the login screen
  and allows for successful login.
- Removing unused menu code.
- 818726 - update to both ui and cli and zanata pushed

* Fri Jun 01 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.40-1
- 815308 - escaping character '^' for elastic searches
- white-space formatting
- 807288 - changeset history tab raising undefined method
- 822672 - Making rake setup set the URL_ROOT correctly for headpin
- katello - fix config loading in rake setup
- katello, unit-test - fix model/sync_plan_spec
- 826249 - system by environment page generates error
- permissions/roles api - fix for organization_id required always
- system groups - adding history api
- 821644 - cli admin crl_regen command - unit and system test
- 805956 - daily cron script for checking for new content on CDN
- system groups - errata - show systems errata associated with
- system groups - fix jslint error on systems.js
- 822069 - Additional fix - left integer in return body
- 753128 - Ensures that status updates to the sync management page are driven
  solely by data returned from the server.
- system groups - improving permissions on systems check of system_group
- system groups - update index for group ids in the system model
- 823890 - delete products that were removed from new manifest
- system groups - removing multiselect widgets
- converge-ui - updated to pull in the new jquery widgets for multiselect
- system groups - minor mods for pull request comments
- system groups - fix scss - regression during refactoring to share between
  systems and groups
- system groups - prepend Resources:: to Pulp call ... fix for recent master
  merge
- system groups - fixes regression from past merge of headpin flags
- system groups - spec tests for new systems controller actions
- system groups - generate error notice if no pkg, pkg grp or errata are
  provided
- system groups - fixing spec test in api
- system groups - merge conflict
- system groups - initial specs for errata controller
- system groups - replacing add link with button
- system groups - making system group systems tab conform more to the mockups
- system groups - adding count
- system groups - Adds missing param for max_systems on system group creation.
- system groups - adding locked groups from system pages
- system groups - adding missing partials
- system groups - adding locked icon to locked groups
- system groups - minor chg to labels based on sprint review feedback
- system groups - initial UI code to support errata install for groups
- system groups - initial model/glue/resources to support system group actions
- Revert "system groups - adding environment api calls and tests"
- system groups - adding environment api calls and tests
- system groups - adding activation key validation for environments <-> system
  groups
- system groups - adding environment model to system groups
- system groups - fix broken spec on api system groups controller
- system groups - fix failed activation key specs/tests
- system groups - only list groups w/ available capacity on systems page
- system group - add group name to the validation error
- system groups - update add/remove system to handle errors
- auto_complete - update to js to allow users to reset the input
- system groups - validate max systems during a system bulk action
- system groups - validation updates for max systems
- system groups - Adds the maximum systems paramter for CLI create/update.
- system groups - fixing scope issue on systems autocomplete
- system groups - add some basic validations on max_systems
- system-groups - model - rename max_members to max_systems
- systems - fix broken systmes page after merge
- system groups - add model and ui to provision max systems for a group
- system groups - fixing create due to recent merge
- system groups - fixing broken systems page after merge
- system group - Adds support for a system that is registering via activation
  keys to be placed into the system groups associated with those activation
  keys
- system groups - adding more system permission spec tests
- system groups - fixing some broken spec tests
- system groups - update akey system groups to use the new multiselect
- system groups - fixing query issues that reduced system visibility
- system groups - fix the usage of group locking in systems controller
- system groups - fix the locked field on controller and minor fix on notices
- system groups - update Systems Bulk Action for Groups to use the multiselect
  widget
- system groups - fixing some wrongly-named methods
- system groups - adding a few more missing model level role access and tests
- system groups - permissions: deletion and UI membership
- system groups - making api honor system visibility for add/remove systems
- system groups - converting ui to only add/remove systems to a group for
  readable systems
- system groups - moving locking in ui from update action to lock action
- system groups - adding api permission tests
- system groups - Adds API support for adding system groups to an activation
  key
- system groups - unit test fix
- system groups - adding perms to api controller
- system groups - adding spec tests for UI permissions
- system group - Adds CLI/API support for adding and removing system groups
  from a system
- system groups - fixing broken create due to perms
- system groups - update Systems->System Groups to use the multiselect widget
- multiselect - introduce new jquery widget for supporting multiselect
- system groups - implementing UI controller and view permissions
- system groups - adding initial permissions
- system groups - updates to Systems->System Groups based on UI mockup
- autocomplete.js - update to support comma-separated input
- system groups - Adds support for adding systems to a system group in the CLI
- fixing some broken unit tests caused by change to find_org in api controllers
- system group - Adds support for locking and unlocking a system group in the
  CLI
- system groups - unit test fix
- system groups - Adds CLI support for listing systems in a system group.
- system groups - Adds ability to view info of single system group from CLI.
- system groups - adding add/remove systems, lock/unlock and controller tests
  for api
- system groups - add search by system and by group, plus generic index update
- system groups - adding query support for group index
- system groups - moving routes under organization for api
- system groups - adding initial api controller actions
- api - modifying find_organization in api controller to error if org_id not
  provided
- system groups - improving locking notification from UI
- i18n-ifying locked group message
- system groups - making lock control system add/remove
- systems - update view confirmation text to support i18n translations
- systems - update system group bulk action to check availability of group
  before 'add'
- making spinner appear when removing system grouops
- system groups - making add/remove buttons uniform with the rest of the app
- removing unneeded print
- few system group fixes
- system groups - adding more controller tests and checking in missing template
- system groups - fixing issue where description would not update
- initial system group systems page
- systems - disable pkg and group radio buttons when no system is selected
- systems - update icon for bulk remove action
- systems - update bulk actions to be completely disabled, unless system
  selected
- systems - add auto-complete to system group bulk action and update icons
- systems - update icons based on uxd input
- fixing filters.js to conform to the new auto_complete_box api
- adding newest changes to autocomplete box
- navigation - remove duplicate definition for system groups
- adding systems group systems page and auto complete
- system groups - add to systems navigation
- systems - update notices to support i18n translations
- system groups - add bulk action to the systems page to add/remove groups
- system groups - add ability to assign system group to a system
- system groups - adding an AR model relationship for system <-> system groups
- systems - consolidate software/packages/errata under content navigation
- system bulk actions - rework the pkg and group actions based on mockups
- adding system group locked flag and UI controls
- system groups - adding activation key controller specs
- system groups - enable associating groups to an activation key
- adding new files needed for system group UI
- adding system group controller tests
- adding tupane CRUD for system groups
- fixing issue with group creation
- adding glue layer for system groups
- system bulk actions - UI/controller... changes to support additional actions
- system bulk actions - add new routes and initial controller actions
- adding pulp orchestration for system groups
- adding base system group model for active record

* Thu May 24 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.39-1
- 824069 - adding marketing_product flag to product
- 806353 - The time selector widget on the Sync Plans page will no longer get
  stuck on the page and prevent clicking of the save button.
- 821528 - fixing %%config on httpd.conf for RPM upgrades

* Mon May 21 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.38-1
- Fixes failing users controller spec tests.
- Fixes for failing spec tests as part of the merge of new UI changes.
- 822069 - Making candlepin proxy DELETE return a body for sub-man consumer
  delete methods

* Fri May 18 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.37-1
- removing mod_authz_ldap from dependencies
- cli registration regression with aks
- Updates converge-ui for styling fix.
- Updates converge-ui for latest bug fixes and tagged version.
- Updates to latest converge-ui for bug fixes.
- Fixed hover menu setup.
- Patch to render sub menu main
- Updating the version of converge-ui.
- Fix for import path change.
- Updates to spec file for changes in converge-ui-devel.
- Hacky fix to show submenus on hover.
- Updates to include missing body tag id for each major section. Updates
  converge-ui.
- Fixes another issue with panel sliding out incorrectly due to changes in left
  offsets.
- Updates converge-ui.
- Adds changes to footer to bring i18n text into project and out of converge-
  ui.
- Fix for panel opening and closing in the wrong spot:    Due to the panel
  being relative to the container #maincontent   instead of being relative to
  the container #maincontent.maincontent
- Fix for a very minor typo in the CSS.
- IE Stickyfooter hack.
- Changes to accomodate more stuff from UXD.
- UI Remodel - Adds updates to widget styling.
- UI Remodel - Cleans up footer and adds styling to conform versioning into
  footer.
- UI Remodel - Updates the footer section and maincontent to new look.
- UI Remodel - Update to converge-ui.
- UI Remodel - Updates to header layout and new logo.
- UI Remodel - Updates converge-ui and adjusts some placement of tupane
  entities with new look.
- UI Remodel - Switched symlinks to converge-ui instead of lib to adopt a
  pattern of namespacing that will be consistent across implementations.
- UI Remodel - Adds updated version of converge-ui.  Switches default submodule
  config to read-only repository.
- adding converge-ui to build process
- UI Remodel - Moves jquery ui out of assets and updates configuration.
- UI Remodel - Typo fix for layout name.
- UI Remodel - Large UI change to use new shell and header from the converge-ui
  layouts.  Changes to scss to include new scss and modify existing to
  accomodate new shell.  Some re-organization of assets.
- UI Remodel - Removes all jquery plugins and updates paths to point at library
  of plugins in central asset repo.
- UI Remodel - Adds first symlink to javascript libraries coming from UI
  library.
- UI Remodel - Adding initial commit of a git submodule that contains common UI
  elements.

* Thu May 17 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.36-1
- encryption - fix problems with logger not being initialized
- encryption - fix running in development environment
- reduce usage of require for code in lib dir
- 797412 - Unit test fix that should ve gone with the previous commit
- 819941 - missing dependencies in katello-all (common)
- 797412 - Added a comment to explain why index rule is set to true
- 797412 - Removed an unnecessary filter since only one controller call was
  using it.
- 797412 - Moved back search to index method
- 797412 - Fixed environment search call in the cli
- system errata - mv js to load on index
- encryption - plain text passwords encryption
- 821010 - catch and log errors fetching release versions from cdn
- product model - returned last_sync and sync_state fields back to json export
  They were removed with headpin merge but cli uses them.
- adding better example output
- removing root requirement so you can keep your files owned by your user
- 814118 - fixing issue where updating gpg key did not refresh cp content
- restores the ability to use the -f force flag.  previous commit broke it
- Merge pull request #102 from mccun934/reset-dbs-dev-mode
- removing the old 'clear-all' script and moving to just one script
- 812891 - Adding hypervisor record deletion to katello cli
- Merge pull request #94 from jsomara/795869
- systems - fix error on UI create
- 795869 - Fixing org name in katello-configure to accept spaces but still
  create a proper candlepin key
- 783402 - It is possible to add a template to a change set twice
- refactoring - removing duplicate method definition

* Thu May 10 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.35-1
- adding the ability to pass in 'development' as your env
- 817848 - Adding dry-run to candlepin proxy routes
- 818689 - update spec test when activating system with activation key to check
  for hidden user
- 818689 - set the current user before attempting to access activation keys to
  allow communication with candlepin
- Fix for subscriptions SLA level switcher to fit correctly.
- 818711 - use cache of release versions from CDN
- 818711 - pull release versions from CDN
- Fixed sorting in ssl-build dir listing
- Added list of ssl-build dir to katello-debug output
- 818370 - support dots in package name in nvrea
- 808172 - Added code to show version information for katello cli
- 818159 - Error when promoting changeset
- remove test.rake from rpm package
- 807291, 817634 - bit of code clean up
- 807291, 817634 - activation key now validates pools when loaded
- 796972 - changed '+New Something' to single string for translation, and
  clarified the 'total' string
- 796972 - made a single string for translators to work with in several cases
- 817658, 812417 - i686 systems arch displayed as i686 instead of blank
- 809827: katello-reset-dbs should be aware of the deployemnt type
- system-release-version - default landing page is now subscriptions when
  selecting a system
- 772831 - proper way to determine IP address is through fact
  network.ipv4_address
- Merge branch 'master' into system-release-version
- system-release-version - cleaning up system subscriptions tab content and ui
- systems - spec tests for listing systems for a pool_id
- systems - api for listing systems for a pool_id
- add both auto-subscribe on and off options to choice list with service level

* Fri Apr 27 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.34-1
- Do not reference logical-insight unless it is configured

* Wed Apr 25 2012 Jordan OMara <jomara@redhat.com> 0.2.33-1
- Merge pull request #33 from ehelms/master (mmccune@redhat.com)
- Merge pull request #37 from jsomara/ldap-rebase (jrist@redhat.com)
- Merge pull request #36 from thomasmckay/system-release-version
  (jrist@redhat.com)
- Reverting User.all => User.visible as per ehelms+jsherrill
  (jomara@redhat.com)
- Adding destroy_ldap_group to before filter to prevent extraneous loading. Thx
  jrist + bbuck! (jomara@redhat.com)
- Fixing various LDAP issues from the last pull request (mbacovsk@redhat.com)
- Loading group roles from ldap (jomara@redhat.com)
- katello - fix broken unit test (pchalupa@redhat.com)
- Adds logical-insight Gem for development and moves the logical insight code
  to an initializer so that it can be turned on and off via config file.
  (ehelms@redhat.com)
- jenkins build failure for test that crosses katello/headpin boundary
  (thomasmckay@redhat.com)
- cleaning up use of AppConfig.katello? (thomasmckay@redhat.com)
- Merge pull request #23 from iNecas/bz767925 (lzap@seznam.cz)
- incorrect display of release version in system details tab
  (thomasmckay@redhat.com)
- 767925 - search packages command in CLI/API (inecas@redhat.com)

* Tue Apr 24 2012 Petr Chalupa <pchalupa@redhat.com> 0.2.32-1
- reverted katello.yml back to katello master version
- removed reference to headpin in client.conf and katello.yml
- fixed headpin-specific variation of available releases spec test
- fenced spec tests 
- 766647 - duplicate env creation - better error message needed
- katello-cli, katello - setting default environment for user
- 812263 - keep the original tomcat server.xml when resetting dbs
- Fixes issue on Roles page loading the edit panel where a javascript ordering
  problem caused the role details to not show properly.
- 813427 - do not delete repos from Red Hat Providers
- Fixes issue with CSRF meta tag being out of place and notifications not being
  in the proper script tag resulting from moving all inline javascript to a
  single script tag.
- 814063 - warning message for all possible urls
- 814063 - katello now returns warning when not configured
- 814063 - unable to restart httpd
- 810232 - system templates - fix issue editing multiple templates

* Wed Apr 18 2012 Petr Chalupa <pchalupa@redhat.com> 0.2.31-1
- 810378 - adding search for repos on promotion page
- Changes the way inline javascript declarations are handled such that they are
  all injected into one universal script tag.
- 741595 - uebercert POST/GET/DELETE - either support or delete the calls from
  CLI
- boot - default conf was never loaded
- added a script to restore a katello backup that was made with the matching
  backup script
- 803428 - repos - do not pass candlepin a gpgurl, if no gpgkey is defined
- 812346 - fixing org deletion envrionment error
- added basic backup script to handle backup part of
  https://fedorahosted.org/katello/wiki/GuideServerBackups

* Thu Apr 12 2012 Ivan Necas <inecas@redhat.com> 0.2.30-1
- cp-releasever - release as a scalar value in API system json
- removing bail out check for env-selector

* Wed Apr 11 2012 Petr Chalupa <pchalupa@redhat.com> 0.2.29-1
- 713153 - RFE: include IP information in consumers/systems related API calls.
- 803412 - auto-subscribe w/ SLA now on system subscription page
- reorganizing assets to reduce the number of javascript files downloaded
- removing unneeded print statement
- allowing search param for all, needed for all creates 
- system packages - fix checbox events after loading more pkgs
- system packages - add support for tabindex
- 810375 - remove page size limit on repos displayed
- 803410 - Y-stream release version is now available on System Details page +
  If no specific release version is specified (value of "") then "System
  Default" is displayed. + For Katello, release version choices come from
  enabled repos in the system's environment. For Headpin, choices are all
  available in the Library environment.

* Fri Apr 06 2012 Tomas Strachota <tstrachota@redhat.com> 0.2.28-1
- 809826 - regression in finding filters in the filters controller

* Fri Apr 06 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.27-1
- slas - fix in controller spec test

* Fri Apr 06 2012 Tomas Strachota <tstrachota@redhat.com> 0.2.26-1
- slas - field for SLA in hash export of consumer renamed We used service_level
  but subscription-manager requires serviceLevel and checks for it's presence.
- 808596 - Initial fix didn't take into consideration production mode.
- 804685 - system packages - reformat content and add tipsy help on tables for
  user

* Wed Apr 04 2012 Petr Chalupa <pchalupa@redhat.com> 0.2.25-1
- 798649 - RFE - Better listing of products and repos
- check script - initial version
- 805412 - fixing org creation error with invalid chars
- 802454 - a few fixes to support post sync url with scheduled syncs
- 805709 - spec test fix
- 805709 - making filter name unique within an org and editable
- 808576 - Regression for IE only stylesheet. Added back in.

* Mon Apr 02 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.24-1
- 750410 - katello-jobs init script links removal

* Wed Mar 28 2012 Mike McCune <mmccune@redhat.com> 0.2.21-1
- 807319 - Fix for ie8 rendering for filters page (paji@redhat.com)
- 807319 - Fix for IE8 Rendering (jrist@redhat.com)
- 807319 - Adds new version of html5shiv to handle html5 nodes inserted after
  page load. (ehelms@redhat.com)
- 806068 - repo - update pkg/errata search index on repo delete
  (bbuckingham@redhat.com)
- 807319 - Fixes errors thrown on roles page in IE8. (ehelms@redhat.com)
- 807804 - fixing issue where hidden user shows up under roles
  (jsherril@redhat.com)
- 807332 - better exception handling in case of requst time-out
  (inecas@redhat.com)
- 807319 - Fix for IE8 Rendering (jrist@redhat.com)
- 807319 - Fix for IE8 Rendering (jrist@redhat.com)
- 807319 - Fix for IE8 (regression) (jrist@redhat.com)
- removing console.log (jsherril@redhat.com)
- 805202 - changing verification of package names to do a specific search
  (jsherril@redhat.com)
- 806942 - changing all models away from keyword analyzer (jsherril@redhat.com)

* Tue Mar 27 2012 Ivan Necas <inecas@redhat.com> 0.2.20-1
- periodic-build

* Thu Mar 22 2012 Mike McCune <mmccune@redhat.com> 0.2.18-1
- retagging to fix broken tag
* Thu Mar 22 2012 Mike McCune <mmccune@redhat.com> 0.2.17-1
- Revert "removing BuildRequires we don't need anymore" (mmccune@redhat.com)

* Thu Mar 22 2012 Mike McCune <mmccune@redhat.com> 0.2.16-1
- removing BuildRequires we don't need anymore (mmccune@redhat.com)
- 798264 - Katello debug collects certificate password files and some certs
  (mbacovsk@redhat.com)
- 795780, 805122 - Improvement to the way the most recent sync status is
  determined to prevent error and show proper completion. (ehelms@redhat.com)
- 798264 - Katello debug collects certificate password files and some certs
  (mbacovsk@redhat.com)

* Thu Mar 15 2012 Ivan Necas <inecas@redhat.com> 0.2.14-1
- periodic build
* Tue Mar 13 2012 Ivan Necas <inecas@redhat.com> 0.2.13-1
- periodic build
* Tue Mar 13 2012 Ivan Necas <inecas@redhat.com> 0.2.11-1
- periodic build

* Mon Mar 12 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.10-1
- 798772 - fix conversion to local timezone
- 798376 - fix problem with discovery process
- 790063 - search - few more mods for consistency

* Fri Mar 09 2012 Mike McCune <mmccune@redhat.com> 0.2.9-1
- periodic rebuild 
* Tue Mar 06 2012 Mike McCune <mmccune@redhat.com> 0.2.7-1
- Was accidentally hiding login button if ldap was enabled (jomara@redhat.com)
- 788008 - do not attempt to poll errata status when user does not have edit
  permission (thomasmckay@redhat.com)
- Adding LDAP fencing for change email, change password and forgot password
  (jomara@redhat.com)
- 798706 - making promotions block on repodata generation for non-complete repo
  promotions (jsherril@redhat.com)
- 787305 - Fix for nasty lines when details are present in notices.
  (jrist@redhat.com)
- 796852, 789533 - search - update to handle - search queries
  (bbuckingham@redhat.com)
- 794799 - disabling the ability to delete environments that are not the last
  in a promotion path (jsherril@redhat.com)
- 782022 - adding permissions to packages and errata controllers
  (jsherril@redhat.com)

* Mon Mar 05 2012 Martin Bačovský <mbacovsk@redhat.com> 0.2.6-1
- 798264 - Katello debug collects certificate password files and some certs
  (mbacovsk@redhat.com)
- fixing syntax error (jsherril@redhat.com)
- 796264 - adding code to hopefully mitigate pulp timeouts during promotion
  (jsherril@redhat.com)
- 795780 - Sync status page will not appropriately display completed and queued
  repositories and show progress for syncs that are started on queued
  repositories. (ehelms@redhat.com)
- 786762 - Sync status in the UI will now be updated properly whenever a user
  cancels and restarts a sync. (ehelms@redhat.com)
- 790143 - Fixes display of architecture in left hand list view of systems to
  match that of the system details. (ehelms@redhat.com)
- 786495 - When syncing repositories, UI will now show updated size and package
  counts for repositories and products. (ehelms@redhat.com)

* Fri Mar 02 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.5-1
- 740931 - Long name issue with GPG key names
- 740931 - fixed a long name/desc role ui bug
- 796239 - removing system template product association from UI
- Fixed some unit test issues
- Adding some basic LDAP support to katello.
- 767574 - Promotion page - code to indicate warnings if products/repos have
  filters applied on them
- 798324 - UI permission creation widget will now handle verbs that have no
  tags properly.
- 787979 - auto-heal checkbox only enabled if system editable
- 788329 - fixing env selector not initializing properly on new user page
- 787696 - removed incorrectly calling _() in javascript
- 798007 - adding logging information for statuses
- 798737 - Promotion of only distribution fails
- Gemfile - temporarily removing the tire and hashr gem updates
- 795825 - Sync Mgmt - fix display when state is 'waiting'
- 796360 - fixing issue where system install errata button was clickable
- 783577 - removing template with unsaved changes should not prompt for saving
- 798327 - fixing stray space in debug certificate download
- 796740 - Fixes unhelpful message when attempting to create a new system with
  no environments in the current organization.
- 754873 - fixing issue where product sync bar would continually go to 100
- 798299 - fix reporting errors from Pulp

* Wed Feb 29 2012 Brad Buckingham <bbuckingham@redhat.com> 0.2.4-1
- 789533 - upgrading to tire 0.3.13pre with additional hashr dependency
  (bbuckingham@redhat.com)
- 798007 - fixing trivial error for our mem dump debug controller
  (lzap+git@redhat.com)
- 795832 - removing package download link as well as some hardcoded package
  data (jsherril@redhat.com)
- 787696, 796753 - localization corrections of roles, plus instances of
  embedded strings, plus gettext:find ran (thomasmckay@redhat.com)
- 787966 - preventing changeset history details from being jumbled if no
  description is set (jsherril@redhat.com)
- 796964 - The 'Sync Product' permission no longer allows a user to edit a
  repository. (ehelms@redhat.com)
- 773279 - show compliance status and date in systems report
  (inecas@redhat.com)
- 796573 - promotion searchable items now showing add/remove correctly
  (jsherril@redhat.com)
- removing some logging (jsherril@redhat.com)
- 790254 - fixing issue where failed changesets would show as pending on
  dashboard (jsherril@redhat.com)
- 740365 - fixing sort on systems page (jsherril@redhat.com)
- 797914 - fixing not being able to edit/view roles (jsherril@redhat.com)

* Mon Feb 27 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.3-1
- 751843 - adding counts go promotion search pages

* Fri Feb 24 2012 Mike McCune <mmccune@redhat.com> 0.2.2-1
- rebuild 
* Wed Feb 22 2012 Mike McCune <mmccune@redhat.com> 0.2.1-1
- 796268 - proper error message when erratum was not found
  (tstrachota@redhat.com)
- 770414 - Fix for remove role button moving to next line when clicked.
  (jrist@redhat.com)
- 795862 - delete assignment to activation keys on product deletion
  (inecas@redhat.com)
- 770693 - handle no reference in errata (inecas@redhat.com)

* Wed Feb 22 2012 Ivan Necas <inecas@redhat.com> 0.1.243-1
- periodic build
* Thu Feb 16 2012 Ivan Necas <inecas@redhat.com> 0.1.239-1
- 789456 - fix problem with unicode (inecas@redhat.com)

* Wed Feb 15 2012 Mike McCune <mmccune@redhat.com> 0.1.238-1
- rebuild
* Tue Feb 14 2012 Mike McCune <mmccune@redhat.com> 0.1.237-1
- rebuild
* Fri Feb 10 2012 Mike McCune <mmccune@redhat.com> 0.1.234-1
- 789516 - Promotions - fix ability to add products and distros to a changeset
  (bbuckingham@redhat.com)
- 741499-Added code to deal with weird user current org behaviour
  (paji@redhat.com)

* Fri Feb 10 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.232-1
- 789144 - promotions - redindex pkgs and errata after promotion of product or
  repo

* Fri Feb 10 2012 Ivan Necas <inecas@redhat.com> 0.1.230-1
- periodic build

* Thu Feb 09 2012 Mike McCune <mmccune@redhat.com> 0.1.229-1
- rebuild
* Wed Feb 08 2012 Jordan OMara <jomara@redhat.com> 0.1.228-1
- Updating the spec to split out common/katello to facilitate headpin
  (jomara@redhat.com)
- comment - better todo comment for unwrapping (lzap+git@redhat.com)
- comment - removing unnecessary todo (lzap+git@redhat.com)

* Wed Feb 08 2012 Jordan OMara <jomara@redhat.com>
- Updating the spec to split out common/katello to facilitate headpin
  (jomara@redhat.com)
- comment - better todo comment for unwrapping (lzap+git@redhat.com)

* Wed Feb 01 2012 Mike McCune <mmccune@redhat.com> 0.1.211-1
- rebuild
* Wed Feb 01 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.210-1
- binding - consumer must exist
- binding - implementing security rule
- errors - better error handling of 404 for CLI
- binding - adding enabled_repos controller action

* Wed Feb 01 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.208-1
- 753318: add headers to sync schedule lists
- 786160 - password reset - resolve error when saving task status

* Tue Jan 31 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.207-1
- 757817-Added code to show Activation Keys page if user has AK read privileges
- Promotion Search: Fixes for broken unit tests related to adding
  index_packages during promotion.
- 782959,747827,782239 - i18n issues creating pulp users & repos were fixed
- activation keys - fix missing navigation for Available Subscriptions
- Promotion Search - Fixes issue with tupane slider showing up partially inside
  the left side tree.
- providers - fix broken arrow for products and repos
- update to translation strings
- Added "Environment" to Initial environment page on new Org.
- 748060 - fix bbq on promotions page
- Promotion Search - Changes to init search widget state on load properly.
- Promotion Search - Re-factors search enabling on sliding tree to be more
  stand alone and decoupled.  Fixes issues with search widget not closing
  properly on tab changes.
- 757094 - Product should be readable even it has no enabled repos
- Promotion Search - Adds proper checks when there is no next environment for
  listing promotable packages.
- Promotion Search - Initial work to enable package search on the promotions
  page with proper calculations.

* Mon Jan 30 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.206-1
- 785703 - fixing user creation code

* Mon Jan 30 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.205-1
- 785703 - increasing logging for seed script fix

* Mon Jan 30 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.204-1
- Revert "Make default logging level be warn"

* Mon Jan 30 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.203-1
- 785703 - increasing logging for seed script

* Mon Jan 30 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.202-1
- changesets - fixed validations It was not checking whether the distribution's
  repo has been promoted. Validations for other content is also simplified by
  this commit.
- 783402 - unique constraint for templates in changeset
- debugging - replacing most info logs with debug
- katello-debug was having an issue with symlinks

* Fri Jan 27 2012 Mike McCune <mmccune@redhat.com> 0.1.201-1
- rebuild
* Fri Jan 27 2012 Martin Bačovský <mbacovsk@redhat.com> 0.1.200-1
- rename-locker - renamed locker in javascript (mbacovsk@redhat.com)
- 785168 - Do not remove dots from pulp ids (lzap+git@redhat.com)
- nicer errors for CLI and RHSM when service is down (lzap+git@redhat.com)
- 769954 - org and repo names in custom repo content label (inecas@redhat.com)

* Thu Jan 26 2012 Mike McCune <mmccune@redhat.com> 0.1.198-1
- periodic rebuild

* Thu Jan 26 2012 Shannon Hughes <shughes@redhat.com> 0.1.197-1
- update to i18n strings (shughes@redhat.com)
- 784679 - fixed prefs error on system subscription page that was causing the
  page to not load. [stolen from tomckay] (jomara@redhat.com)
- rename-locker - fixed locker that sneaked back during merge
  (mbacovsk@redhat.com)
- Gettext:find from master was going to be a HUGE pain. (jrist@redhat.com)
- rename-branding - Fix for a small typo. (jrist@redhat.com)
- Old string cleanup from pre-gettext days. (jrist@redhat.com)
- rename-locker - fixed paths in test helper (mbacovsk@redhat.com)
- 783511 - Wider menus for branding rename. (jrist@redhat.com)
- rename-locker - locker renamed in controllers and views (mbacovsk@redhat.com)
- locker-rename - locker renamed in model (mbacovsk@redhat.com)
- locker-rename db mgration (mbacovsk@redhat.com)
- 783512,783511,783509,783508 - Additional work for branding rename.      - New
  strings for changes.      - Fixed a spec test since it failed properly, yay!
  (jrist@redhat.com)
- 783512,783511,783509,783508 -More work for branding rename.
  (jrist@redhat.com)
- 783512,783511,783509,783508 - Initial work for branding rename.
  (jrist@redhat.com)
- Fixed error on parsing json error messagae (mbacovsk@redhat.com)
- 784607 - katello production.log can rapidly increase in size
  (lzap+git@redhat.com)
- 767475 - system packages - disable content form when no pkg/group is included
  (bbuckingham@redhat.com)
- 772744 - Removing accounts views/controllers period (jomara@redhat.com)
- 761553 - adding better UI for non-admin viewing roles (jomara@redhat.com)
- 773368 - GPG keys - update to show product the repo is associated with
  (bbuckingham@redhat.com)
- translation i18n files (shughes@redhat.com)
- adding some more password util specs (lzap+git@redhat.com)

* Tue Jan 24 2012 Martin Bačovský <mbacovsk@redhat.com> 0.1.195-1
- 782775 - Unify unsubscription in RHSM and Katello CLI (mbacovsk@redhat.com)

* Mon Jan 23 2012 Mike McCune <mmccune@redhat.com> 0.1.194-1
- daily rebuild
* Mon Jan 23 2012 Mike McCune <mmccune@redhat.com> 0.1.193-1
- perodic rebuild
* Mon Jan 23 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.192-1
- selinux - adding requirement for the main package

* Mon Jan 23 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.191-1
- adding comment to the katello spec
- Revert "adding first cut of our SELinux policy"

* Mon Jan 23 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.190-1
- adding first cut of our SELinux policy

* Fri Jan 20 2012 Mike McCune <mmccune@redhat.com> 0.1.189-1
- rebuild

* Fri Jan 20 2012 Mike McCune <mmccune@redhat.com> 0.1.188-1
- Periodic rebuild
* Fri Jan 20 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.187-1
- fix for listing available tags of KTEnvironment

* Fri Jan 20 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.186-1
- perms - fake /api/packages/ path for rhsm
- Fix to a previous commit related to user default env permissions
- Minor edits to i18n some strings
- Pushing a missed i18n string
- 783328,783320,773603-Fixed environments : user permissions issues
- 783323 - i18ned resource types names
- 754616 - Attempted fix for menu hover jiggle.  - Moved up the third level nav
  1 px.  - Tweaked the hoverIntent settings a tiny bit.
- 782883 - Updated branding_helper.rb to include headpin strings
- 782883 - AppConfig.katello? available, headpin strings added
- 769619 - Fix for repo enable/disable behavior.

* Thu Jan 19 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.185-1
- Bumping candlepin version to 0.5.10
- 773686 - Fixes issue with system template package add input box becoming
  unusable after multiple package adds.
- perms - fixing unit tests after route rename
- perms - moving /errata/id under /repositories API
- perms - moving /packages/id under /repositories API
- 761667 - JSON error message from candlepin parsed correctly

* Thu Jan 19 2012 Ivan Necas <inecas@redhat.com> 0.1.184-1
- periodic build

* Wed Jan 18 2012 Mike McCune <mmccune@redhat.com> 0.1.183-1
- 761576 - removing CSS and jquery plugins for simplePassMeter
  (mmccune@redhat.com)
- 761576 - removing the password strength meter (mmccune@redhat.com)
- Moves javascript to bottom of html page and removes redundant i18n partials
  to the base katello layout. (ehelms@redhat.com)
- 771957-Made the org deletion code a little better (paji@redhat.com)

* Wed Jan 18 2012 Ivan Necas <inecas@redhat.com> 0.1.182-1
- periodic build
* Wed Jan 18 2012 Ivan Necas <inecas@redhat.com> 0.1.181-1
- gpg cli support
* Fri Jan 13 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.178-1
- api perms review - tasks
- 771957 - Fixed an org deletion failure issue
- 755522 - fixing issue where adding filters to a product in the UI did not
  actually take effect in pulp
- adding elasticsearch to ping api
- disabling fade in for sync page
- 773137 - Made the  system search stuff adhre to permissions logic
- 746913 fix sync plan time, incorrectly using date var
- removing obsolete strings
- removing scoped search  from existing models

* Tue Jan 10 2012 Mike McCune <mmccune@redhat.com> 0.1.174-1
- fixing critical issue with 2pane search rendering
* Tue Jan 10 2012 Ivan Necas <inecas@redhat.com> 0.1.173-1
- katello-agent - fix task refreshing (inecas@redhat.com)
- fixing self roles showing up in the UI (jsherril@redhat.com)

* Tue Jan 10 2012 Ivan Necas <inecas@redhat.com> 0.1.172-1
- repetitive build

* Fri Jan 06 2012 Mike McCune <mmccune@redhat.com> 0.1.170-1
- updated translation strings (shughes@redhat.com)
- Bug 768953 - Creating a new system from the webui fails to display
  Environment ribbon correctly
* Fri Jan 06 2012 Ivan Necas <inecas@redhat.com> 0.1.168-1
- 771911 - keep facts on system update (inecas@redhat.com)

* Thu Jan 05 2012 Mike McCune <mmccune@redhat.com> 0.1.167-1
- Periodic rebuild with tons of new stuff, check git for features
* Wed Jan 04 2012 Shannon Hughes <shughes@redhat.com> 0.1.165-1
- 766977 fixing org box dropdown mouse sensitivity (shughes@redhat.com)
- Add elastic search to the debug collection (bkearney@redhat.com)
- 750117 - Fixes issue with duplicate search results being returned that
  stemmed from pressing enter within the search field too many times.
  (ehelms@redhat.com)
- translated strings from zanata (shughes@redhat.com)
- 752177 - Adds clearing of search hash when search input is cleared manually
  or via Clear from dropdown. (ehelms@redhat.com)
- 769905 remove yum 3.2.29 requirements from katello (shughes@redhat.com)

* Wed Jan 04 2012 Ivan Necas <inecas@redhat.com> 0.1.163-1
- periodic rebuild

* Tue Jan 03 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.160-1
- moving /distributions API into /repositories path
- disabling auto-complete on tupane pages
- system templates - fix packages, groups and repos to be consistent w/
  promotions
- system templates - fix label on template tree for repos
- system templates - fix specs broken by addition of repo
- system template - updates to tdl for handling templates containing individual
  repos
- system template - update to allow adding individual repos to template
- auto_search_complete - allow controller to provide object for permissions
  check
- Add missing Copyright headers.
- Added permission to list the readable repositories in an environment

* Mon Jan 02 2012 Lukas Zapletal <lzap+git@redhat.com> 0.1.157-1
- api perms review - activation keys
- 751033 - adding subscriptions to activation key exception
- perms - changesets permission review

* Fri Dec 23 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.156-1
- api perms - changesets unittests
- api perms - changesets
- permission coverage rake spec improvement
- 768047 - promotions - let user know if promotion fails
- 754609 - Sync status on dashboard now rounded percent.

* Thu Dec 22 2011 Ivan Necas <inecas@redhat.com> 0.1.155-1
- periodic rebuild
* Wed Dec 21 2011 Mike McCune <mmccune@redhat.com> 0.1.154-1
- removing indexing for changesets, as its not needed currently
  (jsherril@redhat.com)
- make sure that katello prefix is part of the gpg url (ohadlevy@redhat.com)
* Wed Dec 21 2011 Justin Sherrill <jsherril@redhat.com> 0.1.153-1
- fixing routes.js (jsherril@redhat.com)
- reverting to old package behavior (jsherril@redhat.com)
- unit test fix (jsherril@redhat.com)
- fixing broken unit tests
- ignoring tire if running tests
- Search: Adds button disabling on unsearchable content within sliding tree.
  (ehelms@redhat.com)
- making filters more flexible within application controller
  (jsherril@redhat.com)
- fixing provider search to not show redhat provider (jsherril@redhat.com)
- adding elasticsearch plugin log to logrotate for katello
  (jsherril@redhat.com)
- changing system templates auto complete to use elastic search
  (jsherril@redhat.com)
- adding package search for promotions (jsherril@redhat.com)
- Merge branch 'search' of ssh://git.fedorahosted.org/git/katello into search
  (paji@redhat.com)
- Added a way to delete the search indices when the DB was reset
  (paji@redhat.com)
- Search: Adds search on sliding tree to bbq. (ehelms@redhat.com)
- Search: Enables simple form search widget for content sliding tree on
  promotion page. (ehelms@redhat.com)
- Search: Adds ability to enable a full search widget within a sliding tree and
  adds to the content tree on promotions page. (ehelms@redhat.com)
- Sliding Tree: Refactor to sliding tree to turn the previous search widget
  into a pure filter widget. (ehelms@redhat.com)
- Search: Changes to sliding tree filtering to make way for adding sliding tree
  search. (ehelms@redhat.com)
- making user sorting be on a non-analyzed login attribute
  (jsherril@redhat.com)
- Adding delayed job after kicking off repo sync to index packages, made
  packages sortable (jsherril@redhat.com)
- fixing ordering for systems (jsherril@redhat.com)
- converting to not use a generic katello index for each model and fixing sort
  on systems and provider (jsherril@redhat.com)
- Merge branch 'master' into search (mmccune@redhat.com)
- 768191 - adding elasticsearch to our specfile (mmccune@redhat.com)
- test (jsherril@redhat.com)
- test (jsherril@redhat.com)
- adding initial system searching (jsherril@redhat.com)
- product/repo saving for providers (jsherril@redhat.com)
- adding provider searching (jsherril@redhat.com)
- controller support for indexed (jsherril@redhat.com)
- search - initial full text search additions (jsherril@redhat.com)
- Gemfile Update - adding Tire to gemfile (jsherril@redhat.com)

* Wed Dec 21 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.151-1

* Tue Dec 20 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.149-1
- 

* Mon Dec 19 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.148-1
- Revert "765888 - Error during promotion"
- ak - fixing unit tests
- ak - subscribing according products
- Bug 768388 - Perpetual spinner cursor upon changing a user's org.
  https://bugzilla.redhat.com/show_bug.cgi?id=768388 + Incorrectly loading
  env_select.js twice which was causing javascript errors   and these resulted
  in spinner not clearing
- Changes organizations tupane subnavigation to be consistent with others.

* Wed Dec 14 2011 Ivan Necas <inecas@redhat.com> 0.1.144-1
- 753804 - fix for duplicite product name exception (inecas@redhat.com)
- 741656 - fix query on resource type for search (bbuckingham@redhat.com)
- fixing typos in the seeds script (lzap+git@redhat.com)

* Wed Dec 14 2011 Shannon Hughes <shughes@redhat.com> 0.1.143-1
- + Bug 766888 - Clicking environment on system creation screen doesn't select
  an Env   https://bugzilla.redhat.com/show_bug.cgi?id=766888   The environment
  selector on the Systems pages were broken in several ways, including just not
  being hooked up properly. Two env selectors cannot co-exist in the same page
  so when the New System is opened when viewing systems by environment, the
  selector is not shown but instead just the name of the current environment.
  (thomasmckay@redhat.com)
- quick fix for ee653b28 - broke cli completely (lzap+git@redhat.com)
- 765888 - Error during promotion - unittests (lzap+git@redhat.com)
- 765888 - Error during promotion (lzap+git@redhat.com)
- 761526 - password reset - clear the token on password reset
  (bbuckingham@redhat.com)
- 732444 - Moves Red Hat products to the top of the sync management list sorted
  alphabetically followed by custom products sorted alphabetically.
  (ehelms@redhat.com)
- Changes all tupane slide out view to have Details tab and moves that tab to
  the last position. (ehelms@redhat.com)
- Removes older navigation files that appear no longer needed.
  (ehelms@redhat.com)
- system packages - minor change to status text (bbuckingham@redhat.com)

* Tue Dec 13 2011 Ivan Necas <inecas@redhat.com> 0.1.142-1
- Fix db:seed script not being able to create admin user (inecas@redhat.com)
- 753804 - handling marketing products (inecas@redhat.com)
- Fix handling of 404 from Pulp repositories API (inecas@redhat.com)
- committing czech rails locales (lzap+git@redhat.com)

* Tue Dec 13 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.141-1
- marking all katello packages as noarch again
- 766933 - katello.yml is world readable including db uname/password
- 766939 - security_token.rb should be regenerated on each install
- making seed script idempotent

* Tue Dec 13 2011 Ivan Necas <inecas@redhat.com> 0.1.140-1
- reimport-manifest - save content into repo groupid on import
  (inecas@redhat.com)

* Mon Dec 12 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.138-1
- 760290 - read only role has now permissions

* Fri Dec 09 2011 Ivan Necas <inecas@redhat.com> 0.1.136-1
- 758219 - make labels for custom content unique (inecas@redhat.com)
- spec test fix for create system (TODO: add default env tests)
  (thomasmckay@redhat.com)
- Merge branch 'master' into BZ-761726 (thomasmckay@redhat.com)
- BZ-761710 (thomasmckay@redhat.com)
- fixed another rescue handler (thomasmckay@redhat.com)

* Thu Dec 08 2011 Mike McCune <mmccune@redhat.com> 0.1.133-1
- periodic rebuild
* Thu Dec 08 2011 Ivan Necas <inecas@redhat.com> 0.1.132-1
- reimport-manifest - don't delete untracked products when importing
  (inecas@redhat.com)
- reimport-manifest - don't manipulate CP content on promotion
  (inecas@redhat.com)
- reimport-manifest - repos relative paths conform with content url
  (inecas@redhat.com)
- reimport-manifest - support for force option while manifest import
  (inecas@redhat.com)
* Wed Dec 07 2011 Shannon Hughes <shughes@redhat.com> 0.1.130-1
- bump version to fix tags (shughes@redhat.com)

* Wed Dec 07 2011 Shannon Hughes <shughes@redhat.com> 0.1.129-1
- user roles - spec test for roles api (tstrachota@redhat.com)
- user roles - new api controller (tstrachota@redhat.com)
- fix long name breadcrumb trails in roles (shughes@redhat.com)
- Fix for jrist being an idiot and putting in some bad code.`
  (jrist@redhat.com)

* Tue Dec 06 2011 Mike McCune <mmccune@redhat.com> 0.1.128-1
- periodic rebuild

* Tue Dec 06 2011 Shannon Hughes <shughes@redhat.com> 0.1.126-1
- break out branding from app controller (shughes@redhat.com)

* Tue Dec 06 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.125-1
- Revert "759533 - proper path for distributions"

* Fri Dec 02 2011 Mike McCune <mmccune@redhat.com> 0.1.123-1
- periodic rebuild

* Fri Dec 02 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.122-1
- adding 4th column to the list_permissions
- adding rake list_permissions task

* Thu Dec 01 2011 Mike McCune <mmccune@redhat.com> 0.1.120-1
 - periodic rebuild
* Wed Nov 30 2011 Mike McCune <mmccune@redhat.com> 0.1.118-1
- periodic rebuild
* Tue Nov 29 2011 Shannon Hughes <shughes@redhat.com> 0.1.117-1
- fix user tab so editable fields wrap (shughes@redhat.com)
- Fixes issue with new template for repositories from adding in gpg key.
  (ehelms@redhat.com)
- rake jsroutes (thomasmckay@redhat.com)
- + display green/yellow/red icon next to installed software products + changed
  order of packages tab for progression Subscriptions->Software->Packages +
  TODO: refactor products code based upon sys-packages branch + TODO: hide
  "More..." button if number of installed products is less than page size
  (thomasmckay@redhat.com)
- installed products listed now (still need clean up) (thomasmckay@redhat.com)
- infrastructure for system/products based upon system/packages
  (thomasmckay@redhat.com)
- Removing errant console.log that breaks FF3.6 (ehelms@redhat.com)

* Tue Nov 29 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.116-1
- adding template to the system info cli call
- more info when RecordInvalid is thrown
- Org Deletion - ensuring things are cleaned up properly during org deletion
- GPG Keys: Adds gpg key helptip.
- Merge branch 'master' into gpg
- GPG Keys: Adds uploading gpg key during edit and attempts to fix issues with
  Firefox and gpg key ajax upload.
- GPG key: Adds uploading key on creating new key from the UI.
- GPG Keys: Adds dialog for setting GPG key of product for all underlying
  repositories.
- Routing error page doesn't need user credentials
- Added some gpg key controller tests
- added some unit tests to deal with gpg keys
- Moved the super admin method to authorization_helper_methods.rb from
  login_helper_methods.rb for more consistency
- Added a reset_repo_gpgs method to reset the gpg keys of the sub product
- GPG Keys: Adds UI code to check for setting all underlying repositories with
  products GPG key on edit.
- GPG Keys: Adds view, action and route for viewing the products and
  repositories a GPG key is associated with from the details pane of a key.
- GPG Key: Adds key association to products on create and update views.
- GPG Key: Adds association of GPG key when creating repository.
- GPG Key: Adds ability to edit a repository and change the GPG key.
- Added some methods to do permission checks on repos
- Added some methods to do permission checks on products
- GPG keys: Modifies edit box for pasting key and removes upload.
- GPG keys: Adds edit support for name and pasted gpg key.
- Adding products and repositories helpers
- GPG Keys: Adds functional GPG new key view.
- GPG Keys: Adds update to controller.
- Added code for repo controller to accept gpg
- Updated some controller methods to deal with associating gpg keys on
  products/repos
- Added a menu entry for the GPG stuff
- GPG Keys: Updated jsroutes for GPG keys.
- GPG Keys: Fixes for create with permissions.
- GPG Keys: Adds create controller actions to handle both pasted GPG keys and
  uploaded GPG keys.
- GPG Keys: Adds code for handling non-CRUD controller actions.
- GPG Keys: Adds basic routes.
- GPG Keys: Adds javascript scaffolding and activation of 2pane AJAX for GPG
  Keys.
- GPG Keys: Initial view scaffolding.
- GPG Keys: Fixes issues with Rails naming conventions.
- GPG Keys: Adds basic controller and helper shell. Adds suite of unit tests
  for TDD.
- Added some permission checking, scoped and searching on names
- Adding a product association to gpg keys
- Renamed Gpg to GpgKey
- Initial commit of the Gpg Model mappings + Migration scripts

* Mon Nov 28 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.115-1
- tdl validations - backend and cli
- tdl validation - model code

* Fri Nov 25 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.114-1
- Revert "Automatic commit of package [katello] release [0.1.114-1]."
- Automatic commit of package [katello] release [0.1.114-1].
- 757094 - use arel structure instead of the array for repos

* Thu Nov 24 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.113-1
- fixing typo (space)
- 755730 - exported RHEL templates mapping
- rh providers - restriction in adding products to rh providers via api
- bug - better error message when making unauthetincated call
- repo block - fixes in spec tests
- repo blacklist - flag for displaying enabled repos via api
- repo blacklist - product api lists always all products
- repo blacklist - flag for displaying disabled products via api
- repo blacklist - enable api blocked for custom repositories
- repo blacklist - api for enabling/disabling repos
- password_reset - fix i18n for emails
- changing some translation strings upon request

* Tue Nov 22 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.112-1
- fixed failing spec tests all caused by new parameter in
  Candlepin::Consumer#update
- template export - spec tests for disabled export form a Library
- template export - disabled exporting templates from Library envs
- moved auto-heal down next to current subs
- system templates - fixing issue where distributions were not browsable on a
  newly created template without refreshing
- positioned auto-heal button; comment-removed the Socket and Guest Requirement
  (since were hard-code data populated)
- fixed missing call to 'render' at end of #update
- use PUT instead of POST
- autoheal checkbox on system; toggling not working

* Fri Nov 18 2011 Shannon Hughes <shughes@redhat.com> 0.1.111-1
- 755048 - handle multiple ks trees for a template (inecas@redhat.com)

* Thu Nov 17 2011 Shannon Hughes <shughes@redhat.com> 0.1.110-1
- Revert "fix sync disabled submit button to not sync when disabled"
  (shughes@redhat.com)
- 747032 - Fixed a bugby error in the dashboard whenever you had more than one
  synced products (paji@redhat.com)

* Thu Nov 17 2011 Shannon Hughes <shughes@redhat.com> 0.1.109-1
- fix sync disabled submit button to not sync when disabled
  (shughes@redhat.com)
- 754215 - Small temporary fix for max height on CS Trees. (jrist@redhat.com)

* Wed Nov 16 2011 shughes@redhat.com
- Pie chart updates now functions with actual data. (jrist@redhat.com)
- Fix for pie chart on dashboard page. (jrist@redhat.com)
- Fixed a permission check to only load syncplans belonging to a specific org
  as opposed to syncplnas belongign to all org (paji@redhat.com)

* Wed Nov 16 2011 Shannon Hughes <shughes@redhat.com> 0.1.107-1
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (jsherril@redhat.com)
- removing duplicated method (jsherril@redhat.com)
- incorporate redhat-logos rpm for system engine installs (shughes@redhat.com)
- 754442 - handle error status codes from CDN (inecas@redhat.com)
- 754207 - fixing issue where badly formed cdn_proxy would throw a non-sensical
  error, and we would attempt to parse a nil host (jsherril@redhat.com)
- Merge branch 'master' into sys-status (thomasmckay@redhat.com)
- minor verbage change to label: Host Type to System Type
  (thomasmckay@redhat.com)
- Merge branch 'master' into sys-status (thomasmckay@redhat.com)
- Merge branch 'master' into sys-status (thomasmckay@redhat.com)
- Merge branch 'master' into sys-status (thomasmckay@redhat.com)
- added compliant until date (thomasmckay@redhat.com)
- display a system's subscription status and colored icon
  (thomasmckay@redhat.com)
- Merge branch 'master' into sys-status (thomasmckay@redhat.com)
- display dashboard system status (thomasmckay@redhat.com)

* Wed Nov 16 2011 Brad Buckingham <bbuckingham@redhat.com> 0.1.106-1
- async job - fix for broken promotions (bbuckingham@redhat.com)

* Wed Nov 16 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.105-1
- 754430 - Product promotion fails as katello-jobs doesn't start
- system templates - adding support for adding a distribution to a system
  template in the ui
- Fixed a unit test failure
- Small fix to get the redhat enablement working in FF 3.6
- Fix to make the product.readable call only  out RH products that do not have
  any repositories enabled
- Added a message asking the user to enable repos after manifest was uploaded
- 751407 - root_controller doesn't require user authorization
- Made Product.readable call now adhere to  repo enablement constructs
- Small fix to improve the permission debug message
- bug - RAILS_ENV was ignored for thin
- Small fix to import_history, changes to styling for tabs on rh providers
  page.
- Moving the upload top right.
- Moved the redhat provider haml to a more appropriate location
- Updated some permissions on the redhat providers page
- Update to get the redhat providers repo enablement code to work.
- color shade products for sync status
- adding migration for removal of releaes version
- sync management - making sync page use major/minor versions that was added
- sync mangement - getting rid of major version
- sync management - fixing repository cancel
- fixing repo spec tests
- sync management - fixing button disabling
- sync management - fix for syncing multiple repos
- disable sync button if no repos are selected
- sync management - fixing cancel sync
- merge conflict
- sync management - adding show only syncing button
- js cleanup for progress bars
- For now automatically including all the repos in the repos call
- Initial commit on an updated repo data model to handle things like whitelists
  for rh
- handle product status progress when 100 percent
- smooth out repo progress bar for recent completed syncs
- ubercharged progress bar for previous completed syncs
- fix missing array return of pulp sync status
- sync management - fixing repo progress and adding product progress
- sync management - somre more fixes
- sync management - getting sync status showing up correct
- fixing some merge issues
- support sync status 1-call to server
- sync management - dont start periodical updater until we have added all the
  initial syncing repos
- sync management - a couple of periodical updater fixes
- removing unneeded view
- sync management - lots of javascript changes, a lot of stuff still broken
- sync management - some page/js modifications
- sync management - moving repos preopulation to a central place
- sync management =  javascript improvements
- sync mgmnt - fixing sync call
- sync management - adding sorting for repos and categories
- sync management - custom products showing up correctly now
- sync management - making table expand by major version/ minor version/arch
- use new pulp sync status, history task objects
- caching repo data and sync status to reduce sync management load time to ~40s
- adding ability to preload lazy accessors
- repos - adding release version attribute and importing

* Tue Nov 15 2011 Shannon Hughes <shughes@redhat.com> 0.1.104-1
- Reverting look.scss to previous contents. (jrist@redhat.com)
- tdl-repos - use repo name for name attribute (inecas@redhat.com)
- Merge branch 'master' into password_reset (bbuckingham@redhat.com)
- password reset - add server to logins email, ignore errors on requests for
  email (bbuckingham@redhat.com)
- cdn-proxy - accept url as well as host for cdn proxy (inecas@redhat.com)
- cdn-proxy - let proxy to be configured when calling CDN (inecas@redhat.com)
- 752863 - katello service will return "OK" on error (lzap+git@redhat.com)
- Rename of look.scss to _look.scss to reflect the fact that it's an import.
  Fixed the text-shadow deprecation error we were seeing on compass compile.
  (jrist@redhat.com)
- user edit - add 'save' text to form... lost in merge (bbuckingham@redhat.com)
- Merge branch 'master' into password_reset (bbuckingham@redhat.com)
- password reset - updates from code inspection (bbuckingham@redhat.com)
- Merge branch 'master' into password_reset (bbuckingham@redhat.com)
- password reset - fixes for issues found in production install
  (bbuckingham@redhat.com)
- katello.spec - adding mailers to be included in rpm (bbuckingham@redhat.com)
- password reset - fix issue w/ redirect to login after reset
  (bbuckingham@redhat.com)
- installler - minor update to setting of email in seeds.rb
  (bbuckingham@redhat.com)
- Merge branch 'master' into password_reset (bbuckingham@redhat.com)
- password reset - adding specs for new controller (bbuckingham@redhat.com)
- Merge branch 'master' into password_reset (bbuckingham@redhat.com)
- cli - add email address to 'user' as a required attribute
  (bbuckingham@redhat.com)
- password reset - replace flash w/ notices, add config options to
  katello.yml...ec (bbuckingham@redhat.com)
- password reset - update so that emails are sent asynchronously
  (bbuckingham@redhat.com)
- password reset - misc fixes (bbuckingham@redhat.com)
- password reset - add ability to send user login based on email
  (bbuckingham@redhat.com)
- password reset - chgs to support the actual password reset
  (bbuckingham@redhat.com)
- password reset - chgs to dev env to configure sendmail
  (bbuckingham@redhat.com)
- password reset - initial commit w/ logic for resetting user password
  (bbuckingham@redhat.com)
- Users specs - fixes for req'd email address and new tests
  (bbuckingham@redhat.com)
- Users - add email address (model/controller/view) (bbuckingham@redhat.com)

* Mon Nov 14 2011 Shannon Hughes <shughes@redhat.com> 0.1.103-1
- fix up branding file pulls (shughes@redhat.com)
- rescue exceptions retrieving a system's guests and host
  (thomasmckay@redhat.com)
- 750120 - search - fix error on org search (bbuckingham@redhat.com)
- scoped_search - updating to gem version 2.3.6 (bbuckingham@redhat.com)
- fix brand processing of source files (shughes@redhat.com)

* Mon Nov 14 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.102-1
- 753329 - distros - fix to support distros containing space in the id
- TODO: Unsure how to test this after making :host, :guests use lazy_accessor
- 749258 - new state 'failed' for changesets
- fixed save button on edit user password
- guests of a host cleanly displayed
- adding rootpw tag to the TDL export
- corrected test for creating user w/o env
- manifest import - fixes in orchestration - content remained created in library
  env - fixed infinite recursive call of set_repos
- + both new user and modifying a user's environment now work + TODO: probably
  need to wordsmith form labels
- user#create updated for optional default env
- + don't require an initial environment for new org + new user default org/env
  choice box allows none (controller not updated yet)
- installed-products - API supports consumer installedProducts
- clean up of branch merge defaultorgenv
- correctly pass default env during user create and update
- comment and whitespace cleanup
- updated rspec tests for new default org and environment
- minor clean-up
- Security enhancements for default org and environment
- Updating KAtello to work with older subscription managers (5.7) that expect
  displayMessage in the return JSON
- User environment edit page no longer clicks a link in order to refresh the
  page after a successful update, but rather fills in the new data via AJAX
- Fixing a display message when creating an organization
- Not allowing a superadmin to create a user if the org does not ahave any
  environments from which to choose
- Now older subscription managers can register against Katello without
  providing an org or environment
- You can now change the default environment for a user on the
  Administration/Users/Environments tab
- updating config file secret
- Adding missing file
- Middle of ajax environments_partial call
- Moved the user new JS to the callback in user.js instead of a separate file
  for easier debugging.
- Saving a default permission whever a new user is created, although the
  details will likely change
- Now when you create an org you MUST specify a default environment. If you do
  not the org you created will be destroyed and you will be given proper error
  messages. I added a feature to pass a prepend string to the error in case
  there are two items you are trying to create on the page. It would have been
  easier to just prepend it at the time of message creation, but that would
  have affected every page. Perhaps we can revisit this in the future
- In the middle of stuff
- begin to display guests/host for a system
- major-minor - fix down migration
- major-minor - Parsing releasever and saving result to db
- white-space

* Thu Nov 10 2011 Shannon Hughes <shughes@redhat.com> 0.1.101-1
- disable sync KBlimit (shughes@redhat.com)
- repos - orchestration fix, 'del_content' was not returning true when there
  was nothing to delete (tstrachota@redhat.com)
- 746339 - System Validates on the uniqueness of name (lzap+git@redhat.com)
- repos - orchestration fix, deleting a repo was not deleting the product
  content (tstrachota@redhat.com)

* Wed Nov 09 2011 Shannon Hughes <shughes@redhat.com> 0.1.100-1
- virt-who - support host-guests systems relationship (inecas@redhat.com)
- virt-who - support uploading the guestIds to Candlepin (inecas@redhat.com)
- sync api - fix for listing status of promoted repos A condition that ensures
  synchronization of repos only in the Library was too restrictive and affected
  also other actions. (tstrachota@redhat.com)
- 741961 - Removed traces of the anonymous user since he is no longer needed
  (paji@redhat.com)
- repo api - fix in spec tests for listing products (tstrachota@redhat.com)
- repos api - filtering by name in listing repos of a product
  (tstrachota@redhat.com)
- Merge branch 'master' into repo-remodel (paji@redhat.com)
- API - add status route for api to return the current version
  (inecas@redhat.com)
- include treetable.js in custom providers (thomasmckay@redhat.com)
- user spec tests - fix for pulp orchestration (tstrachota@redhat.com)
- Updated Gemfile.lock (inecas@redhat.com)
- 751844 - Fix for max height on right_tree sliding_container.
  (jrist@redhat.com)
- Merge branch 'master' into repo-remodel (paji@redhat.com)
- Refactored look and katello a little bit because of an order of operations
  error.` (jrist@redhat.com)
- Pulling out the header and maincontent and putting into a new SCSS file,
  look.scss for purposes of future ability to change subtle look and feel
  easily. (jrist@redhat.com)
- Switched the 3rd level nav to hoverIntent. (jrist@redhat.com)
- branding changes (shughes@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (mmccune@redhat.com)
- removed display of bundled products (thomasmckay@redhat.com)
- grouping by stacking_id now (thomasmckay@redhat.com)
- now group by subscription productId (thomasmckay@redhat.com)
- grouping by product name (which isn't right but treetable is working mostly
  (thomasmckay@redhat.com)
- show expansion with bundled products in a subscription
  (thomasmckay@redhat.com)
- changesets - added unique constraint on repos (tstrachota@redhat.com)
- Fixed distributions related spec tests (paji@redhat.com)
- Fixed sync related spec tests (paji@redhat.com)
- Fixed repo related spec tests (paji@redhat.com)
- Fixed packages test (paji@redhat.com)
- Fixed errata spec tests (paji@redhat.com)
- Merge branch 'master' into repo-remodel (paji@redhat.com)
- Fixed some repo related unit tests (paji@redhat.com)
- Removed the ChangesetRepo table + object and made it connect to the
  Repository model directly (paji@redhat.com)
- Merge branch 'master' into repo-remodel (paji@redhat.com)
- repo - using pulp id instead of AR id in pulp api calls
  (tstrachota@redhat.com)
- distributions api - fix for listing (tstrachota@redhat.com)
- Fixed some package group related tests (paji@redhat.com)
- Fixed errata based cli tests (paji@redhat.com)
- Some fixes involving issues with cli-system-test (paji@redhat.com)
- Merge branch 'master' into repo-remodel (paji@redhat.com)
- Fixed environment based spec tests (paji@redhat.com)
- Merge branch 'master' into repo-remodel (paji@redhat.com)
- Merge branch 'master' into repo-remodel (paji@redhat.com)
- removed spacing to deal with a warning (paji@redhat.com)
- Fixed the Systemtemplate spec tests (paji@redhat.com)
- Fixed errata tests (paji@redhat.com)
- Fixed sync related spec tests (paji@redhat.com)
- Fixed distribution spec tests (paji@redhat.com)
- Fixed Rep  related spec tests (paji@redhat.com)
- Fixed changeset tests (paji@redhat.com)
- fixed product spec tests that came up after master merge (paji@redhat.com)
- fixed more merge conflicts (paji@redhat.com)
- Fixed a bunch of merge conflicts (paji@redhat.com)
- More unit test fixes on the system templates stuff (paji@redhat.com)
- Fixed a good chunk of the product + repo seoc tests (paji@redhat.com)
- Merge branch 'master' into repo-remodel (paji@redhat.com)
- fixed some unit tests (paji@redhat.com)
- Fixed the repo destroy (paji@redhat.com)
- Master merge + fixed conflicts (paji@redhat.com)
- Adding the env products model (paji@redhat.com)
- Fixed merge conflicts related to master merge (paji@redhat.com)
- Added code to check for repo name conflicts before insert (paji@redhat.com)
- Updated repo code to work with promotions (paji@redhat.com)
- Added some error reporting for glue errors (paji@redhat.com)
- Glue::Pulp::Repo.find is now replaced by Repository.find_by_pulp_id now that
  we have the repository data model. (paji@redhat.com)
- Fixed a sync alert issue related to the new repo model (paji@redhat.com)
- Got the repo delete functionality working (paji@redhat.com)
- Merge branch 'master' into repo-remodel (paji@redhat.com)
- fixed the delete script for this model (paji@redhat.com)
- Got the sync pages to work with the new repo model (paji@redhat.com)
- Got the repo view to render the source url correctly (paji@redhat.com)
- Modified the code to get repo delete call working (paji@redhat.com)
- Updated the environment model to do a proper list products call
  (paji@redhat.com)
- Merge branch 'master' into repo-remodel (paji@redhat.com)
- Merge branch 'master' into repo-remodel (paji@redhat.com)
- Removed some wasted  comments (paji@redhat.com)
- Added environment mappings to the repo object and got product.repos search
  working (paji@redhat.com)
- Initial commit of the repo remodeling where the repository is created in
  katello (paji@redhat.com)

* Mon Nov 07 2011 Mike McCune <mmccune@redhat.com> 0.1.99-1
- misc rel-eng updates based on new RPMs from Fedora (mmccune@redhat.com)
* Wed Nov 02 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.98-1
- 702052 - db fields length limit review
- unit test fix
- filters - some styling improvements, as well as some permission fixes
- adding katello-job logrotate script
- moving simplify_changeset out of application controller
- Merge branch 'breakup-puppet'
- Remove trailing spaces
- filter - fixing issue where you could add a repo even if one wasnt selected
- improving package filter chosen styling
- converting chosen css to scss
- filters - fixing javascript load issue
- fixing initial_action for panel after merge
- improving error reporting for the API calls
- 731670 - improving error reporting when deleting users
- 750246 - promote content of product to different environments
- repo promotion - fix for failure when promoting a repo for second time
- Promotions - fix ajax scrolling for promotions, errata and pkgs
- repo promotion - fix for creating content (after wrong rebase)
- repo promotion - fix in spec tests
- cp content - content type taken from the provider's type
- fix for promoting repos - changeset was passing wrong parameters - repo
  promotion refactored, removed parameter for content (it is now created inside
  the repo object)
- better error messages for template validations
- adding some delays in the PulpTaskStatus
- parameter -m no longer an option in katello-jobs
- adding migration to the reset-dbs script
- templates - spec test fix
- templates - promoting parent templates
- distros - removing tdl validation
- distros - adding distribution tdl unit tests
- distros - adding package groups to TDL
- distros - adding name-version-url-arch to TDL export
- distros - adding distributions unit tests
- distros - adding import/export unit tests
- distros - adding importing
- distros - adding exporting
- distros - adding templ. distribution validator
- adding new configuration value debug_rest
- distros - adding cli portion for adding/removing distros
- distros - marking find_template as private method
- distros - adding system template handling code
- distros - adding system_template_distribution table
- distros - adding family, variant, version in CLI
- Merge branch 'filters-ui'
- filters - unit test fix and addition
- filters - adapting for  new panel ajax code
- fxiing merge conflict
- templates - spec test for checking revision numbers after promotion
- templates - fix for increased revision numbers after promotion
- filters - adding spec test for ui controller
- updated TDL schema + corresponding changes in template export & tests
- filters - fixing a few issues, such as empty package list message not going
  away/coming back
- filters - fixing empty message not appearing and dissappearing as needed
- filters - a couple more filters fixes
- filters - removing repos from select repos select box when they are selected
- filters - a few ui related fixes
- filters - package imporovements
- filters - some page changes as well as adding revert filter to products and
  repos
- filters - making products and repos add incrementally instead of re-rendering
  the entire product list
- filters - hooking up add/remove packages to the backend, as well as a few
  javascript fixes
- Merge branch 'filters' into filters-ui
- filters - hooking up product and repos to backend
- filters - improving adding removing of products and repos
- package filters - adding javascript product and repository adding
- added filters controller spec
- filters controller spec
- merge conflict
- adding/removal of packages from filters supports rollbacks now
- added support for updating of package lists of filters
- filters - a few package auto complete fixes
- filters - adding auto complete for packages, and moving library package search
  to central place from system templates controller
- moving some javascript i18n to a common area for autocomplete
- spliting out the auto complete javascript object to its own file for reuse
- filters - adding the ui part of package adding and removing, not hooked up to
  the backend since it doesnt work yet
- tupane - adding support for expanding to actions other than :edit
- filters - making filters use name instead of pulp_id, and adding remove
- merge conflict
- filters - adding initial edit code
- fixing issue where provider description was marked with the incorrect class
- forgot to commit migration for filter-product join table
- added support for filter create/list/show/delete operations in katello cli
- filters - adding creation of package filters in the ui
- more filter-related tests
- filters - initial package filtering ui
- merge conflict
- support for addition/removal of filters to already promoted products
- fixing gemfile url
- Merge branch 'master' into filters-ui
- fixed a few issues in filters controller
- application of filters during promotion
- tests around persisting of filter-product association
- fixed a few issues around association of filters with repos
- added support for associating of filters with products
- fixed a misspelled method name
- applying filters to products step 1

* Fri Oct 28 2011 Shannon Hughes <shughes@redhat.com> 0.1.97-1
- Fixed an activation key error were all activation keys across musltiple orgs
  were deemed readable if Activationkeys in one org was accessible
  (paji@redhat.com)
- Fix for systems page javascript error when no env_select on the page.
  (ehelms@redhat.com)
- Merge branch 'master' into distros (bbuckingham@redhat.com)
- Merge branch 'master' into tupane-actions (jrist@redhat.com)
- Fixed the actions thing. (jrist@redhat.com)
- temporarily commenting out test that verifies validity of system template TDL
  export generated by katello (waiting for an updated schema from aeolus team)
  (dmitri@redhat.com)
- Small fix for actions. (jrist@redhat.com)
- Promotions - update to only allow promotion of distro, if repo has been
  promoted (bbuckingham@redhat.com)
- Changeset history - fix expand/collapse arrow (bbuckingham@redhat.com)
- Fixing right actions area post merge. (jrist@redhat.com)
- Merge branch 'master' into tupane-actions (jrist@redhat.com)
- fixed failing tests (dmitri@redhat.com)
- template export in tdl now has clientcert, clientkey, and persisted fields
  (dmitri@redhat.com)
- New system on create for systems page.  Fixed offset/position bug on panel
  due to container now being relative for menu. (jrist@redhat.com)
- Minor fix for the margin-top on third_level nav. (jrist@redhat.com)
- Third_level nav working well. (jrist@redhat.com)
- Menu - Fixes issue with third level nav hover not being displayed properly.
  (ehelms@redhat.com)
- Moved thirdLevelNavSetup to menu.js. (jrist@redhat.com)
- Tweaked the experience of the tabs to be a bit snappier. (jrist@redhat.com)
- Another change to the menu to make it behave a bit better. (jrist@redhat.com)
- Hover on subnav working with a few quirks that I need to work out.
  (jrist@redhat.com)
- Menu.scss. (jrist@redhat.com)
- Initial pass at menu. (jrist@redhat.com)
- removing another console.log (mmccune@redhat.com)
- remove console log output that was breaking FF 3.6 (mmccune@redhat.com)
- Fixes for broken scss files when compass attempts to compile them for builds.
  (ehelms@redhat.com)
- Merge branch 'master' into distros (bbuckingham@redhat.com)
- Merge branch 'master' into errata_filter (bbuckingham@redhat.com)
- errata_filter - ui - update the severity value for low severity
  (bbuckingham@redhat.com)
- errata_filter - ui - update the severity value for low severity
  (bbuckingham@redhat.com)
- repo querying - simple repo cache changed to work with new pulp api
  (tstrachota@redhat.com)
- repo querying - hack to enable queries with multiple groupids when using
  oauth temporary solution until it gets fixed in pulp (tstrachota@redhat.com)
- adding env_id to unit tests (mmccune@redhat.com)
- Merge branch 'master' into tdl-download (mmccune@redhat.com)
- adding dialog and download buttons for template download from env
  (mmccune@redhat.com)
- Moves some widget css into separate scss files. (ehelms@redhat.com)
- Merge branch 'master' into tupane (ehelms@redhat.com)
- Tupane - Fixes for spec tests. (ehelms@redhat.com)
- errata_filter - add stub to resolve error w/ test in promotions controller
  (bbuckingham@redhat.com)
- delayed-job - log errors backtrace in log file (inecas@redhat.com)
- Merge branch 'master' into tupane (ehelms@redhat.com)
- Tupane - Env Select - Adds ajax environment search to systems by environment
  page. (ehelms@redhat.com)
- nvrea-optional - adding pack to template accepts both nvre and nvrea
  (inecas@redhat.com)
- nvrea-options - remove unused code (inecas@redhat.com)
- nvrea-optional - parse_nvrea_nvre for parsing both formats together
  (inecas@redhat.com)
- nvrea-optional - refactor spec test and lib (inecas@redhat.com)
- prod orch - fix for deleting subscriptions of provided products
  (tstrachota@redhat.com)
- updated Gemfile.lock (dmitri+git@redhat.com)
- fixed failing tests (dmitri@redhat.com)
- added ruport-related gems to Gemfile (dmitri@redhat.com)
- Merge branch 'reports' (dmitri@redhat.com)
- prod orch - fix in rh provider import test (ui controller)
  (tstrachota@redhat.com)
- prod orch - fixes in spec tests (tstrachota@redhat.com)
- prod orch - deleting content from provider after manifest import
  (tstrachota@redhat.com)
- prod orch - fix for deleting prducts (tstrachota@redhat.com)
- prod orch - fix for deleting repositories - CP content is deleted upon
  deletion of the first repo associated with it (tstrachota@redhat.com)
- prod orch - added content id to repo groupids (tstrachota@redhat.com)
- prod orch - saving sync schedules refactored (tstrachota@redhat.com)
- prod orch - fix for getting repos for a product It was caching repositories
  filtered by search params -> second call with different search parameters
  would return wrong results. (tstrachota@redhat.com)
- prod orch - saving sync schedule in all repos on product update
  (tstrachota@redhat.com)
- prod orch - creating product content upon first promotion
  (tstrachota@redhat.com)
- prod orch - method for checking if one cdn path is substitute of the other in
  CdnVarSubstitutor (tstrachota@redhat.com)
- prod orch - deleting unused products after manifest import - deleting
  products that were in the manifest but don't belong to the owner
  (tstrachota@redhat.com)
- prod orch - new orchestration for product creation and manifest import
  (tstrachota@redhat.com)
- products - no content in CP when a product is created (tstrachota@redhat.com)
- Merge branch 'master' into tdl-download (mmccune@redhat.com)
- moving download to a pop-up pane so you can select env + distro
  (mmccune@redhat.com)
- Merge branch 'master' into distros (bbuckingham@redhat.com)
- Merge branch 'master' into errata_filter (bbuckingham@redhat.com)
- Tupane - Systems - Fixing search for creation and editing for System CRUD.
  (ehelms@redhat.com)
- Promotions - mark distributions as promoted, if they have already been
  (bbuckingham@redhat.com)
- Tupane - Fixes for unit tests after merging in master. (ehelms@redhat.com)
- Promotions - add distributions to changeset history... fix expander/collapse
  image in js (bbuckingham@redhat.com)
- fixing nil bug found on the code review - fix (lzap+git@redhat.com)
- Merge branch 'master' into tupane (ehelms@redhat.com)
- fixing nil bug found on the code review (lzap+git@redhat.com)
- dep calc - fixes in displaying the dependencies (tstrachota@redhat.com)
- dep calc - disabling dep. calc. in promotion tests (tstrachota@redhat.com)
- dep calc - promoting dependencies (tstrachota@redhat.com)
- dep calc - returning dependencies with dependency_of (tstrachota@redhat.com)
- dep calc - new column dependency_of in changeset dependencies
  (tstrachota@redhat.com)
- dep calc - refactoring and performance improvement - not calculating
  dependencies for packages that are included in any product or repository in
  the changeset (tstrachota@redhat.com)
- calc dep - methods for listing not included errata and packages
  (tstrachota@redhat.com)
- calc dep - calc_dependencies(bool) split into two methods
  (tstrachota@redhat.com)
- Fixed an accidental remove in katello.js from commit
  ec6ce7a262af3b9c349fb98c1d58ad774206dffb (paji@redhat.com)
- Promotions - distributions - spec test updates (bbuckingham@redhat.com)
- Promotions - distributions - changes to allow for promotion
  (bbuckingham@redhat.com)
- Tupane - Search - Spec test fixes for ajaxification of search.
  (ehelms@redhat.com)
- referenced proper ::Product class... again (thomasmckay@redhat.com)
- referenced proper ::Product class (thomasmckay@redhat.com)
- Promotions - distributions - additional changes to properly support changeset
  operations (bbuckingham@redhat.com)
- Tupane - Adds notice on edit when edited item no longer meets search
  criteria. (ehelms@redhat.com)
- Promotions - distributions - add/remove/view on changeset
  (bbuckingham@redhat.com)
- Promotions - distros - ui chg to allow adding to changeset
  (bbuckingham@redhat.com)
- Errata - update so that 'severity' will have an accessor
  (bbuckingham@redhat.com)
- Errata - filter - fix the severity values (bbuckingham@redhat.com)
- Tupane - Removes unnecessary anonymous function from list initialization.
  (ehelms@redhat.com)
- Tupane - Search - Refactors items function to be uniform across controllers.
  Adds total items and total results items counts. Refactors panel
  functionality to separate list and panel functions. (ehelms@redhat.com)
- Promotions - errata - some cleanup based on ui review discussion
  (bbuckingham@redhat.com)
- Promotions - system templates - make list in ui consistent w/ others in
  breadcrumb (bbuckingham@redhat.com)
- Merge branch 'master' into tdl-download (mmccune@redhat.com)
- Promotions - errata - update show to omit 'self' and include available links
  provided in errata (bbuckingham@redhat.com)
- Promotions - errata - update format of title for breadcrumb and errata
  details (bbuckingham@redhat.com)
- Errata Filters - UI - updates to integrate w/ backend errata filters
  (bbuckingham@redhat.com)
- Tupane - Search - Adds special notification if newly created object does not
  meet search criteria. (ehelms@redhat.com)
- Tupane - Refactors items controller function to be less repetitive.
  (ehelms@redhat.com)
- Tupane - Fixes changeset history page that requires extra attribute when
  searching for environment. (ehelms@redhat.com)
- errata-filters - filter all errata for a product (inecas@redhat.com)
- errata-filters - use only Pulp::Repo.errata for filtering (inecas@redhat.com)
- Tupane - Adds number of total items and current items in list to left side
  list in UI. (ehelms@redhat.com)
- Tupane - Adds message specific settings to notices and adds special notice to
  organization creation for new objects that don't meet search criteria.
  (ehelms@redhat.com)
- errata-filters - update failing tests (inecas@redhat.com)
- errata-filters - API and CLI support for filtering on severity
  (inecas@redhat.com)
- errata-filters - API and CLI restrict filtering errata on an environment
  (inecas@redhat.com)
- errata-filters - API and CLI allow errata filtering on multiple repos
  (inecas@redhat.com)
- errata-filters - API and CLI support for filtering errata by type
  (inecas@redhat.com)
- Removing the 'new' for systems_controller since it isn't quite there yet.
  (jrist@redhat.com)
- Various tupane fixes, enhancements, and modifications to styling.  More...
  - Stylize the options dialog in actions   - Remove the arrows on multi-select
  - Fix the .new to be fixed height all the time.   -  Fix the "2 items
  selected to be less space   - Move the box down, yo.   - Add Select None
  (jrist@redhat.com)
- Errata Filters - ui - initial changes to promotions breadcrumb
  (bbuckingham@redhat.com)
- Tupane - Search - Fixes for autocomplete drop down and left list not sizing
  properly on search. (ehelms@redhat.com)
- Tupane - Search - Converts fancyqueries to use new ajax search.
  (ehelms@redhat.com)
- Tupane - Search - Removes scoped search standard jquery autocompletion widget
  and replaces it with similar one fitted for Katello's needs.
  (ehelms@redhat.com)
- tupane - adding support for actions to be disabled if nothing is selected
  (jsherril@redhat.com)
- Tupane - Search - Re-factors extended scroll to use new search parameters.
  (ehelms@redhat.com)
- Search - Converts search to an ajax operation to refresh and update left side
  list. (ehelms@redhat.com)
- Fixes issue with navigationg graphic showing up on roles page tupanel.
  (ehelms@redhat.com)
- Merge branch 'master' into tupane (ehelms@redhat.com)
- Tupane - Changes pages to use new action to register with panel in
  javascript. (ehelms@redhat.com)
- Tupane - Moves list javascript object to new namespace. Moves newly created
  objects to top of the left hand list. (ehelms@redhat.com)
- Tupane - Converts the rest of ajax loading left hand list object creations to
  new style that respects search parameters. (ehelms@redhat.com)
- adding bulk delete system spec test (jsherril@redhat.com)
- tupane actions - adding icon to system bulk remove (jsherril@redhat.com)
- tupane actions - moving KT.panel action functions to KT.panel.actions
  (jsherril@redhat.com)
- Fixed the refresh of the number of items to happen automatically without
  being called. (jrist@redhat.com)
- System removal refresh of items number.. (jrist@redhat.com)
- Tupane - ActivationKeys - Changes Activation Keys to use creation format that
  respects search filters. (ehelms@redhat.com)
- Tupane - Role - Cleanup of role creation with addition of description field.
  Moves role creation in UI to new form to respect search parameters.
  (ehelms@redhat.com)
- Tupane - Modifies left hand list to obey search parameters and adds the
  ability to specify a create action on the page for automatic handling of
  creation of new objects with respect to the search parameters.
  (ehelms@redhat.com)
- re-created reports functionality after botched merge (dmitri@redhat.com)
- two pane system actions - adding remove action for bulk systems
  (jsherril@redhat.com)
- Tupane - Converts Content Management tab to use left list ajax loading.
  (ehelms@redhat.com)
- Tupane - Converts Organizations tab to ajax list loading. (ehelms@redhat.com)
- Tupane - Converts Administration tab to ajax list loading.
  (ehelms@redhat.com)
- Merge branch 'master' into tupane (ehelms@redhat.com)
- Tupane - Converts systems tab items to use new ajax loading in left hand
  list. (ehelms@redhat.com)
- Merge branch 'master' into tdl-download (mmccune@redhat.com)
- first hack to try and get the sub-edit panel to pop up (mmccune@redhat.com)
- Tupane - Initial commit of changes to loading of left hand list on tupane
  pages via ajax. (ehelms@redhat.com)
- Tupanel - Updates to tupanel slide out for smoother sliding up and down
  elongated lists.  Fix for extended scroll causing slide out panel to overrun
  footer. (ehelms@redhat.com)

* Mon Oct 24 2011 Shannon Hughes <shughes@redhat.com> 0.1.96-1
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (bkearney@redhat.com)
- Allow headpin and katello-common to install together (bkearney@redhat.com)
- Small fix for browse/upload overlap. (jrist@redhat.com)
- pools - one more unit test (lzap+git@redhat.com)
- pools - list of available unit test (lzap+git@redhat.com)
- tdl-repos-references - validate TDL in unit tests against xsd
  (inecas@redhat.com)
- tdl-repos-references - tdl repos references direct to pulp repo
  (inecas@redhat.com)
- templates - fix for cloning to an environment (tstrachota@redhat.com)
- Systems - minor change to view to address warning during render...
  (bbuckingham@redhat.com)
- Promotions - distributions - make list in ui consistent w/ products list
  (bbuckingham@redhat.com)
- Minor fix for potential overlap of Upload button on Redhat Provider page.
  (jrist@redhat.com)
- cli-akeys-pools - show pools in activation key details (inecas@redhat.com)
- cli-akeys-pools - set allocated to 1 (inecas@redhat.com)
- cli-akeys-pools - refactor spec tests (inecas@redhat.com)
- cli-akeys-pools - remove subscriptions from a activation kay
  (inecas@redhat.com)
- cli-akeys-pools - add subscription to a key through CLI (inecas@redhat.com)
- 747805 - Fix for not being able to create an environment when subpanel div
  was "in the way" via z-index and layering. (jrist@redhat.com)
- Fixing tests for System create (tsmart@redhat.com)
- Rendering the proper lsit item for a system once it has been created
  (tsmart@redhat.com)
- Minor changes to new page for systems.  Using systems_path with
  action=>create automatically defaults to post.  Doing so was because of the
  server prefix.  Also fixed the scrollbar at the bottom of the page to be
  grid_8 for the surrounding page. (jrist@redhat.com)
- If you do not have an environment selected, then we tell you to go set a
  default (tsmart@redhat.com)
- Fixing System create error validation return (tsmart@redhat.com)
- Adding environment selector to the System Create page (tsmart@redhat.com)
- Cherry picking first System CRUD commit (tsmart@redhat.com)
- Tweaks to System/Subscriptions based on feedback:    + Fix date CSS padding
  + "Available" to "Quantity" in Available table    + Remove "Total" column in
  Available table    + Add "SLA" to Available table (thomasmckay@redhat.com)
- pools - adding multi entitlement flag to the list (cli) (lzap+git@redhat.com)
- pools - making use of system.available_pools_full (lzap+git@redhat.com)
- pools - rename sys_consumed_entitlements as consumed_entitlements
  (lzap+git@redhat.com)
- pools - moving sys_consumed_entitlements into glue (lzap+git@redhat.com)
- pools - rename sys_available_pools as available_pools_full
  (lzap+git@redhat.com)
- pools - moving sys_available_pools into glue (lzap+git@redhat.com)
- pools - listing of available pools (lzap+git@redhat.com)
- refactoring - extending pool glue class (lzap+git@redhat.com)
- refactoring - extending pool glue class (lzap+git@redhat.com)
- removing unused code (lzap+git@redhat.com)
- Prevent from using sqlite as the database engine (inecas@redhat.com)
- Wrapping up today's git mess. (jrist@redhat.com)
- Revert "Revert "Red Hat Provider layout refactor" - upload is not working
  now..." (jrist@redhat.com)
- Revert "Fix for provider.js upload file." (jrist@redhat.com)
- Revert "Merge branch 'upload_fix'" (jrist@redhat.com)
- Merge branch 'upload_fix' (jrist@redhat.com)
- Fix for provider.js upload file. (jrist@redhat.com)
- Revert "Red Hat Provider layout refactor" - upload is not working now...
  (jrist@redhat.com)
- Red Hat Provider layout refactor (jrist@redhat.com)
- Removed jeditable classes off repo pages since attributes there are not
  editable anymore (paji@redhat.com)
- Break up the katello rpms into component parts (bkearney@redhat.com)
- Very minor padding issue on .dash (jrist@redhat.com)
- Fix for flot/canvas on IE. (jrist@redhat.com)
- BZ#747343 https://bugzilla.redhat.com/show_bug.cgi?id=747343 In fix to show
  subscriptions w/o products, the provider was not being checked.
  (thomasmckay@redhat.com)
- Based on jrist feedback: + add padding to rows to account for fatter spinner
  + don't increment spinner value if non-zero on checkbox click + alternate row
  coloring (maintain color on exanding rows) (thomasmckay@redhat.com)
- Unsubscribe now unsubscribes from individual entitlements, not the entire
  pool. (Only useful for multi-entitlement subscriptions where the user may
  have subscribed to multiple quantities.) (thomasmckay@redhat.com)
- adjusted tables for custom provider product, updated columns
  (thomasmckay@redhat.com)
- handle comma-separated gpgUrl values. change display of subscription from
  label to div to clean up display style (thomasmckay@redhat.com)
- subscription content url is needs the content source prefix before it is a
  clickable link (thomasmckay@redhat.com)
- changed subscription details to a list instead of a table; much cleaner
  looking (thomasmckay@redhat.com)
- data added to expanding subscription tree (thomasmckay@redhat.com)
- first cut of expander for subscription details (data fake)
  (thomasmckay@redhat.com)
- updated table info for available, including removing spinner for non-multi
  (thomasmckay@redhat.com)
- updated table info for currently subscribed (thomasmckay@redhat.com)
- 737678 - Made the provider left panes and other left panes use ellipsis
  (paji@redhat.com)

* Tue Oct 18 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.95-1
- switching to XML vs JSON for template download
- Errata - packages - list based on name-[epoch:]-version-release.arch
- 745617 fix for product sync selection
- tdl - modifying /export to return TDL format
- tdl - refactoring export_string to export_as_json
- reset dbs script now correctly load variables
- 744067 - Promotions - Errata UI - clean up format on Details tab

* Mon Oct 17 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.94-1
- adding db:truncate rake task
- templates - spec tests for revisions
- templates - fix for increasing revision numbers after update
- fixes #745245 Filter on provider page fails with postgres error
- Fixed a unit test
- 740979 - Gave provider read access for users with org sync permission
- 744067 - Promotions - Errata UI - clean up format on Packages tab
- 741416 - organizations ui - list orgs using same sort order as on roles pg

* Fri Oct 14 2011 Shannon Hughes <shughes@redhat.com> 0.1.93-1
- bump up scoped_search version to 2.3.4 (shughes@redhat.com)
- 745315 -changing application controller to not include all helpers in all
  controllers, this stops helper methods with the same name from overwriding
  each other (jsherril@redhat.com)
- 740969 - Fixed a bug where tab was being inserted. Tab is invalid for names
  (paji@redhat.com)
- 720432 - Moves the small x that closes the filter on sliding tree widgets to
  be directly to the right of the filter. (ehelms@redhat.com)
- 745279 - UI - fix deletion of repo (bbuckingham@redhat.com)
- 739588-Made the systems update call raise the error message the correct way
  (paji@redhat.com)
- 735975 - Fix for user delete link showing up for self roles page
  (paji@redhat.com)
- Added code to fix a menu highlighting issue (paji@redhat.com)
- 743415 - removing uneeded files (mmccune@redhat.com)
- update to translations (shughes@redhat.com)
- 744285 - bulletproof the spec test for repo_id (inecas@redhat.com)
- Fix for accidentaly faling tests (inecas@redhat.com)
- adding new zanata translation file (shughes@redhat.com)
- search - fix system save and notices search (bbuckingham@redhat.com)
- 744285 - Change format of repo id (inecas@redhat.com)
- Fixed a bunch of unit tests (paji@redhat.com)
- Fixed progress bar and spacing on sync management page. (jrist@redhat.com)
- Updated the ordering on the content-management menu items (paji@redhat.com)
- Refactored the create_menu method to allow navs of multiple levels
  (paji@redhat.com)
- Ported all the nav items across (paji@redhat.com)
- Added a construct to automatically imply checking for a sub level if the top
  level is missing (paji@redhat.com)
- Just added spaces to every line to keep the tabbing loking right
  (paji@redhat.com)
- Added the systems tab. (paji@redhat.com)
- Added dashboard menus and fixed a bunch of navs (paji@redhat.com)
- Reorganized the navigation a bit (paji@redhat.com)
- Modified the rendering structure to use independent nav items
  (paji@redhat.com)
- Moved menu rb to helpers since its a better fit there.. soon going to
  reorganize the files there (paji@redhat.com)
- Adding the new menu.rb to generate menu (paji@redhat.com)
- Initial commit on getting a dynamic navigation (paji@redhat.com)
- Merge branch 'comps' (jsherril@redhat.com)
- system templates - fixing last issues with comps groups (jsherril@redhat.com)
- removing z-index on helptip open icon so it does not hover over 3rd level
  navigation menu (jsherril@redhat.com)
- Moved the help tip on the redhat providers page show up at the right spot
  (paji@redhat.com)
- reduce number of sync threads (shughes@redhat.com)
- search - several fixes for issues on auto-complete (bbuckingham@redhat.com)
- tests - adding system template package group test for the ui controller
  (jsherril@redhat.com)
- 744191 - prevent some changes on red hat provider (inecas@redhat.com)
- 744191 - Prevent deleting Red Hat provider (inecas@redhat.com)
- system templates - removign uneeded route (jsherril@redhat.com)
- system templates - package groups auto complete working (jsherril@redhat.com)
- system templates - hooked up comps groups with backend with the exception of
  auto complete (jsherril@redhat.com)
- Merge branch 'master' into comps (jsherril@redhat.com)
- system templates - adding  addition and removal of package groups in the web
  ui, still does not save to server (jsherril@redhat.com)
- system templates - properly listing package groups respecting page size
  limits (jsherril@redhat.com)
- system templates - adding real package groups to system templates page
  (jsherril@redhat.com)
- system templates - adding initial ui framework for package groups in system
  templates (jsherril@redhat.com)
- system templates - adding initial comps listing for products (with fake data)
  (jsherril@redhat.com)

* Tue Oct 11 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.92-1
- Installation does not pull in katello-cli
- Revert "added ruport-related gems to Gemfile"
- jslint - fix warnings reported during build
- templates - fix in spec tests for exporting/importing
- templates - fix for cloning to next environment - added nvres to export - fix
  for importing package groups
- added ruport-related gems to Gemfile
- JsRoutes - Fix for rake task to generate javascript routes.

* Mon Oct 10 2011 Brad Buckingham <bbuckingham@redhat.com> 0.1.91-1
- scoped_search - Gemfile updates to support scoped_search 2.3.4
  (bbuckingham@redhat.com)
- 741656 - roles - search - chgs for search by perm type and verbs
  (bbuckingham@redhat.com)
- Switch of arch and support level on subscriptions page. (jrist@redhat.com)
- repo delete - cli for deleting single repos (tstrachota@redhat.com)
- repo delete - api for deleting single repos (tstrachota@redhat.com)
- Enable running rake task for production env from git repo (inecas@redhat.com)
- Fix check on sqlite when setting up db under root for production
  (inecas@redhat.com)
- Remove failing check on sqlite for root (inecas@redhat.com)
- users - fix user name on edit screen (bbuckingham@redhat.com)
- Set default rake task (inecas@redhat.com)
- Merge branch 'master' into bz731203 (bbuckingham@redhat.com)
- fixed failing roles_controller_spec (dmitri@redhat.com)
- Merge branch 'filters' (dmitri@redhat.com)
- import-stage-manifest - remove hard-coded supported archs (inecas@redhat.com)
- fix in log message (tstrachota@redhat.com)
- org orchestration - deleting dependent providers moved to orchestration layer
  Having it handled by :dependent => :destroy caused wrong order of deleting
  the records. The organization in Candlepin was deleted before providers and
  products. This led to record-not-found errors. (tstrachota@redhat.com)
- products - delete all repos in all environments when deleting a product
  (tstrachota@redhat.com)
- products - route and api for deleting products (tstrachota@redhat.com)
- Added the download icon to the system template page. (jrist@redhat.com)
- 731203 - changes so that update to the object id are reflected in pane header
  (bbuckingham@redhat.com)
- 743646: fix sync due to bad rail route paths (shughes@redhat.com)
- 731203 - update panes to use object name in header/title
  (bbuckingham@redhat.com)
- 731203 - updates to support ellipsis in header of tupane layout
  (bbuckingham@redhat.com)
- fields residing in pulp are now present in the output of index
  (dmitri@redhat.com)
- create/delete operations for filters are working now (dmitri@redhat.com)
- first cut of filters used during promotion of content from Library
  (dmitri@redhat.com)

* Fri Oct 07 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.90-1
- fix for katello-reset-dbs - pgsql support for initdb
- sms - introducing subscriptions controller
- sms - refactoring subscription -> subscriptions path
- sms - moving subscriptions list action into the backend
- sms - moving unsubscribe action into the backend
- dashboard - one last css vertical spacing issue fix
- making css for navigation require a little space in the subnav if there are
  no subnav elements
- dashboard - fixing issue where user with no orgs would recieve an error upon
  login
- panel - minor update to escape special characters in id
- dashboard - more dashboard css fixes
- 741669 - fixing issue where user with no org could not access their own user
  details page
- dashboard - adding ui tweaks from uxd

* Thu Oct 06 2011 Shannon Hughes <shughes@redhat.com> 0.1.89-1
- adding reporting gems deps (shughes@redhat.com)

* Thu Oct 06 2011 Shannon Hughes <shughes@redhat.com> 0.1.88-1
- adding yum fix until 3.2.29 hits zstream/pulp (shughes@redhat.com)
- provider - search changes resulting from split of Custom and Red Hat
  providers (bbuckingham@redhat.com)
- 715369 - use ellipsis on search favorites/history w/ long names
  (bbuckingham@redhat.com)
- repo - default value for content type when creating new repo
  (tstrachota@redhat.com)
- sms - useless comment (lzap+git@redhat.com)
- templates - removed old way of promoting templates directly
  (tstrachota@redhat.com)
- import-stage-manifest - set content type for created repo (inecas@redhat.com)
- dashboard - fixing issue where promotions ellipsis was not configured
  correctly (jsherril@redhat.com)
- dashboard - updating subscription status scss as per request
  (jsherril@redhat.com)

* Wed Oct 05 2011 Shannon Hughes <shughes@redhat.com> 0.1.87-1
- adding redhat-uep.pem to katello ca (shughes@redhat.com)
- dashboard - prevent a divide by zero (jsherril@redhat.com)
- import-stage-manifest - fix relative path for imported repos
  (inecas@redhat.com)
- Do not call reset-oauth in %post, candlepin and pulp are not installed at
  that time anyway. (jpazdziora@redhat.com)
- 739680 - include candlepin error text in error notice on manifest upload
  error (bbuckingham@redhat.com)
- import-stage-manifest - use redhat-uep.pem as feed_ca (inecas@redhat.com)
- import-stage-manifest - refactor certificate loading (inecas@redhat.com)
- import-stage-manifest - fix failing spec tests (inecas@redhat.com)
- import-stage-manifest - fix validations for options (inecas@redhat.com)
- import-stage-manifest - fix ssl verification (inecas@redhat.com)
- import-stage-manifest - small refactoring (inecas@redhat.com)
- import-stage-manifest - short documentation (inecas@redhat.com)
- import-stage-manifest - remove unused code (inecas@redhat.com)
- import-stage-manifest - use CDN to substitute vars in content url
  (inecas@redhat.com)
- import-stage-manifest - class for loading variable values from CDN
  (inecas@redhat.com)
- import-stage-manifest - refactor (inecas@redhat.com)
- import-stage-manifest - fix unit tests (inecas@redhat.com)
- import-stage-manifest - substitute release ver (inecas@redhat.com)
- packagegroups - cli changed to work with array returned from api instead of
  hashes that were returned formerly (tstrachota@redhat.com)
- templates - fixes in spec tests (tstrachota@redhat.com)
- templates - validations for package groups and group categories
  (tstrachota@redhat.com)
- package groups - groups and group categories returned in an array instead of
  in a hash (tstrachota@redhat.com)
- templates api - removed old content update (tstrachota@redhat.com)
- packages search - find latest returns array of all latest packages not only
  the first latest package found (tstrachota@redhat.com)
- templates - package groups and categories identified by name -repo ids and
  category/group ids removed (tstrachota@redhat.com)
- added index for system_template_id on system_template_packages
  (tstrachota@redhat.com)
- templates - update changes name of all environment clones
  (tstrachota@redhat.com)
- templates api - added new controller for updating templates
  (tstrachota@redhat.com)
- templates api - fix for failure in listing all templates in the system
  (tstrachota@redhat.com)
- Temporarily removing dashboard pull-down. (jrist@redhat.com)
- 740340 - manifest upload - validate file input provided
  (bbuckingham@redhat.com)
- 740970 - adding detection if a password contains the username
  (jsherril@redhat.com)
- 741669 - adding a way for users to modify their own user details
  (jsherril@redhat.com)
- Fixed providers show  + edit page to not show provider type (paji@redhat.com)
- Merge branch 'master' into notices (bbuckingham@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (bbuckingham@redhat.com)
- dashboard - adding arrow to the right of the gear (jsherril@redhat.com)
- a-keys - fix delete and behavior on create (bbuckingham@redhat.com)
- Merge branch 'master' into akeys (bbuckingham@redhat.com)
- a-keys - fix view specs (bbuckingham@redhat.com)
- a-keys - fix controller specs (bbuckingham@redhat.com)
- a-keys - mods to handle nil env on akey create (bbuckingham@redhat.com)
- Alternating family rows in Activation Keys by way of Ruby's handy cycle
  method. (jrist@redhat.com)
- a-keys - (TO BE REVERTED) temporary commit to duplicate subscriptions
  (bbuckingham@redhat.com)
- a-keys - some refactor/cleanup of js to use KT namespace
  (bbuckingham@redhat.com)
- a-keys - js fix so that clearing filter does not leave children shown
  (bbuckingham@redhat.com)
- a-keys - css updates for subscriptions (bbuckingham@redhat.com)
- a-keys - change the text used to request update to template
  (bbuckingham@redhat.com)
- a-keys - update scss to remove some of the table css used by akey
  subscriptions (bbuckingham@redhat.com)
- Merge branch 'master' into akeys (bbuckingham@redhat.com)
- a-keys - init env_select when edit pane is initialized
  (bbuckingham@redhat.com)
- a-keys - add cancel button to general tab (bbuckingham@redhat.com)
- a-keys - subscriptions - updates to support listing by product
  (bbuckingham@redhat.com)
- a-keys - update to disable the Add/Remove button after click
  (bbuckingham@redhat.com)
- a-keys - subscriptions - update to include type (virtual/physical)
  (bbuckingham@redhat.com)
- a-keys - applied subs - add link to add subs (bbuckingham@redhat.com)
- a-keys - initial changes for applied subscriptions page
  (bbuckingham@redhat.com)
- a-keys - initial changes for available subscriptions page
  (bbuckingham@redhat.com)
- Merge branch 'master' into akeys (bbuckingham@redhat.com)
- a-keys - new/edit - updates to highlight the need to change template, on env
  change... (bbuckingham@redhat.com)
- a-keys - edit - fix broken 'save' (bbuckingham@redhat.com)
- a-keys - subscriptions - add applied/available placeholders for view and
  controller (bbuckingham@redhat.com)
- a-keys - add Applied and Available subscriptions to navigation
  (bbuckingham@redhat.com)
- a-keys - new/edit - disable save buttons while retrieving template/product
  info (bbuckingham@redhat.com)
- a-keys - new - update to set env to the first available
  (bbuckingham@redhat.com)
- a-keys - remove the edit_environment action (bbuckingham@redhat.com)
- a-keys - edit - update to list products in the env selected
  (bbuckingham@redhat.com)
- a-keys - update new key ui to use environment selector
  (bbuckingham@redhat.com)
- a-keys - update setting of env and system template on general tab...
  (bbuckingham@redhat.com)
- notices - change to fix broken tests (bbuckingham@redhat.com)
- notices - change to support closing previous failure notices on a success
  (bbuckingham@redhat.com)
- notices - adding controller_name and action_name to notices
  (bbuckingham@redhat.com)

* Tue Oct 04 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.86-1
- Added some rendering on products and repos page to explicity differentiate
  the 2
- dashboard - removing system list and expanding height of big_widget and
  small_widget
- Updated katello-js to work with multiple third level navs
- 740921 - When editing a permission verbs and tags that were part of the
  permission will now show up as selected already.
- Roles UI - Fix for edit role slide up container not working after previous
  changes to the way the action bar works.
- tupane - fixing extended scroll spinner showing up on most pages
- panel - rendering generic rows more efficiently
- 740365 - fixing issue with systems sorting and extended scroll, where limits
  were being placed before teh sorting happened
- Fixes for Roles UI action bar edit breaking after trying to edit more than 1.
- 737138 - Adds action bar buttons on roles pages to tab index and adds enter
  button press handlers to activate actions.
- 733722 - When hitting enter after editing an input will cause the next button
  to click.
- 741399 - Fixes for Global permissions to hide 'On' field for all resource
  types.
- Tupane - Changes for consistency of tupane css.
- 741422 - Roles UI - Fixes issue with sliding tree expanding in height instead
  of overflowing container.
- Row/grouping coloring for products and repos.
- Fixed a unit test failure
- Got pretty much the providers functionality done with this
- Initial commit related to the provider page redesign
- sms - cli system subscribe command
- Commiting a bunch of unit fixes
- Made organization create a default redhat provider on its inception
- Updated dashboard systems snippet. fixed a couple of bugs w.r.t ellipsis
- Dashboard - lighter hr color, and shorter big_widgets.
- 740936 - Roles UI - Fixes issue with back button disappearing, container
  border not surrounding actior bar and with wrong containers being displayed
  for permission create.
- BZ 741357: fixed a spelling mistake in katello-jobs.init
- Revert "BZ 741357: fixed a spelling mistake in katello-jobs.init"
- BZ 741357: fixed a spelling mistake in katello-jobs.init
- 741444/741648/739981/739655 - update *.js.haml to use the new KT namespace
  for javascript
- Added some modifications for the dashboard systems overview widget to include
  the product name
- add a spec test to the new download
- Adding system template download button.
- Updated the dashboard systems view to be more consistent and show an icon if
  entitlements are valid
- Moved methods from the systems_help to application so that the time
  formatting can be conisistent across all helpers
- Lighter color footer version.
- Tupane - Fixes typo from earlier change related to tupane closing not
  scrolling back up to top.
- dashboard - making subscription widget load with the page
- Added some better error handling and removed katello_error.haml as we can do
  the same with katello.haml
- dashboard - fixing issue where errata would not expand properly when loaded
  via async, also moved jscroll initalization to a more central place
- dashboard - fixing issue where scrollbar would not initialize for ajax loaded
  widgets
- dashboard - removing console.logs
- dashboard - making all widgets load asyncronously
  dashboard
- Changes to the dashboard layout.
- dashboard - adding errata widget with fake data
- Dashboard gear icon in button.
- 739654 - Tupane - Fixes issue with tupane jumping to top of page upon being
  closed.
- katello-all -- a meta-package to pull in all components for Katello.
- Stroke 0 on dashboard pie graph.
- 736090 - Tupane - Fixes for tupane drifting into footer.
- 736828 - Promotions - Fixes packages tupane to close whenever the breadcrumb
  is navigated away from the packages list.
- Overlay for graph on sub status for dasyboard.  Fix for a few small bad haml
  and js things.
- Fixed a var name goofup
- dashboard - adding owner infor object to katello and having the dashboard use
  it for total systems
- dashboard - fixing color values to work properly in firefox
- Updated some scss styling to lengthen the scroll
- Added a message to show empty systems
- Added  some styling on the systems snippet
- dashboard - adding subscription widget for dashboard with fake data
- Added the ellipsis widget
- glue - caching teh sync status object in repos to reduce overhead
- dashboard - a few visual fixes
- Fixed some merge conflicts
- Initial cut of the systems snippet on the dashboard
- dashboard - adding sync dashboard widget
- dashboard - making helper function names more consistent
- dashboard - fixing changeset link and fixing icon links on promotions
- Made the current_organization failure check to also log the exception trace
- dashboard - mostly got promotions pane on dashboard working
- dashboard - got notices dashboard widget in place
- move the SSL fix into the rpm files
- Additional work on the dashboard L&F.  Still need gear in dropbutton and
  content in dashboard boxes.
- Changes to the dashboard UI headers.
- Dashboard initial layout. Added new icons to the action-icons.png as well as
  the chart overlay for the pie chart for subscriptions.
- search - modifications to support service prefix (e.g. /katello)
- search - add completer_scope to role model
- search - systems - update to properly handle autocomplete
- search - initial commit to address auto-complete support w/ perms

* Tue Sep 27 2011 Shannon Hughes <shughes@redhat.com> 0.1.85-1
- remove capistrano from our deps (shughes@redhat.com)
- 736093 - Tupanel - Changes to tupanel to handle helptip open and close.
  (ehelms@redhat.com)
- rhsm fetch environment with owner information (lzap+git@redhat.com)
- spec tests - fix after change in api for listing templates
  (tstrachota@redhat.com)
- templates - removed content validator (tstrachota@redhat.com)
- templates api - fix for getting template by name (tstrachota@redhat.com)
- product sync - fixed too many arguments error (tstrachota@redhat.com)
- templates - spec tests for promotions and packages (tstrachota@redhat.com)
- package search - reordered parameters more logically (tstrachota@redhat.com)
- changesets - removed unused method (tstrachota@redhat.com)
- templates - spec test fixes (tstrachota@redhat.com)
- repos - method clone id moved from product to repo (tstrachota@redhat.com)
- templates - removed unused methods (tstrachota@redhat.com)
- templates - validation for packages (tstrachota@redhat.com)
- templates promotion - fix for spec tests (tstrachota@redhat.com)
- async tasks - pulp status not saving new records after refresh
  (tstrachota@redhat.com)
- template promotions - added promotions of packages (tstrachota@redhat.com)
- templates - fix for unique nvre package validator the previous one was
  failing for validation after updates (tstrachota@redhat.com)
- templates - unique nvre validator for packages (tstrachota@redhat.com)
- templates - adding packages by nvre (tstrachota@redhat.com)
- spec tests - tests for package utils (tstrachota@redhat.com)
- package utils - methods for parsing and building nvrea
  (tstrachota@redhat.com)
- repos - helper methods for searching packages (tstrachota@redhat.com)
- templates - removed errata from update controller (tstrachota@redhat.com)
- template promotions - promotion of products from a template
  (tstrachota@redhat.com)
- changesets - api for adding templates to changesets (tstrachota@redhat.com)
- templates - fixed spec tests after errata removal (tstrachota@redhat.com)
- templates - removed errata from imports, exports and promotions
  (tstrachota@redhat.com)
- templates - deleted TemplateErrata model (tstrachota@redhat.com)
- templates - errata removed from model (tstrachota@redhat.com)
- Tupanel - Fixes issue with tupanel ajax data being inserted twice into DOM.
  (ehelms@redhat.com)
- Tupanel - Fixes smoothness issue between normal tupane and sliding tree.
  (ehelms@redhat.com)
- Tupanel - Fixes for resizing and height setting.  Fixes for subpanel.
  (ehelms@redhat.com)
- Merge branch 'master' into tupanel (ehelms@redhat.com)
- Tupanel - Changes to tupanel for look and feel and consistency.
  (ehelms@redhat.com)
- fixed a bunch of tests that were failing because of new user orchestration
  (dmitri@redhat.com)
- pulp user with 'super-users' role are now being created when a katello user
  is created (dmitri@redhat.com)
- first cut at pulp user glue layer (dmitri@redhat.com)
- added interface for pulp user-related operations (dmitri@redhat.com)
- added glue layer for pulp user (dmitri@redhat.com)
- 740254 - dep API in pulp changed - these changes reflect new struct
  (mmccune@redhat.com)
- make sure we only capture everything after /katello/ and not /katello*
  (mmccune@redhat.com)
- adding in mod_ssl requirement. previously this was beeing indirectly pulled
  in by pulp but katello should require it as well. (shughes@redhat.com)
- bump down rack-test. 0.5.7 is only needed. (shughes@redhat.com)
- Merge branch 'master' into routesjs (ehelms@redhat.com)
- import-stage-manifest - prepare a valid name for a product
  (inecas@redhat.com)
- Remove debug messages to stdout (inecas@redhat.com)
- import-stage-manifest - use pulp-valid names for repos (inecas@redhat.com)
- import-stage-manifest - temp solution for not-supported archs in Pulp
  (inecas@redhat.com)
- import-stage-manifest - support for more archs with one content
  (inecas@redhat.com)
- import-stage-manifest - refactor clone repo id - remove duplicities
  (inecas@redhat.com)
- import-stage-manifest - make clone_repo_id instance method
  (inecas@redhat.com)
- import-stage-manifest - tests for clone repo id (inecas@redhat.com)
- JsRoutes - Adds the base functionality to use and generate the Rails routes
  in Javascript. (ehelms@redhat.com)
- Adds js-routes gem as a development gem. (ehelms@redhat.com)
- Tupane - A slew of changes to how the tupane slideout works with regards to
  positioning. (ehelms@redhat.com)
- bump down tzinfo version. actionpack/activerecord only need > 3.23
  (shughes@redhat.com)
- Tupanel - Cleanup and fixes for making the tupanel slide out panel stop at
  the bottom. (ehelms@redhat.com)

* Fri Sep 23 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.84-1
- asub - adding unit tests
- asub - ak subscribes to pool which starts most recently
- asub - renaming KTSubscription to KTPool
- Merge branch 'master' into rails309
- adding dep for rails 3.0.10
- new deps for rails 3.0.10
- 740389 - include repoid and remove unused security checks
- Merge branch 'master' into rails309
- bumping candlepin to the latest rev
- Promoted content enabled by default
- fixed a bug with parsing of oauth provider parameters
- Hid the select all/none button if the user doesnt have any syncable
  products..
- More roles controller spec fixes
- Roles - Fixes for spec tests that made assumptions that don't hold true on
  postgres.
- Added some comments for app controller
- Roles UI - Updates to edit permission workflow as a result of changes to add
  permission workflow.
- Roles Spec - Adds unit tests to cover CRUD on permissions.
- Roles UI - Fixes to permission add workflow for edge cases.
- Roles UI - Modifies role add permission workflow to add a progress bar and
  move the name and description to the bottom of the workflow.
- Added some padding for perm denied message
- Updated the config file to illustrate the use of allow_roles_logging..
- forgot to evalute the exception correctly
- Added ordering for roles based on names
- Added a config entry allow_roles_logging for roles logs to be printed on the
  output log. This was becasue roles check was cluttering the console window.
- Made the rails error messages log a nice stack trace
- packagegroups-templates - better validation messages
- packagegroups-templates - fix for notification message
- More user-friendly validation failed message in CLI
- removing an unused migration
- Disable unstable spec test
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
- regin dep issue workaround enabled for EL6 now
- removed access control from UebercertsController
- Merge branch 'uebercert'
- updates routes to support uebercert operations
- fixed a few issues with uebercert controller specs
- katello now uses cp's uebercert generation/retrieval
- gemfile mods for rails 3.0.9
- fixed a bunch of issues during uebercert generation
- first cut at supporting ueber certs
- ueber cert - adding cli support

* Tue Sep 20 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.83-1
- Updates on the promotion controller page to deal with weird permission models
- 732444 - make sure we uppercase before we sort so it is case indifferent
- fixed an accidental typo
- Updated the promotions page nav and rules to work correctly
- Updated the handling of the 500 error to deal with null org cases
- 734526 - improving error messages for promotions to include changeset names.
- 733270 - fix failing unit tests
- 733270 - validate uniquenss of system name
- 734882 - format RestClient error message only for katello-cli agent
- 734882 - User-Agent header in katello-cli and custom error messages
- changed candlepin url in Candlepin::Consumer integration tests
- removing unecessary debug line that was causing JS errors
- notices - making default polling inverval 120s (when omitted from conf)
- activation keys - fixing new env selector for activation keys
- fixing poor coding around enabling create due to permission that had creeped
  into multiple controllers
- 739200 - moving system template new button to the top left instead of on the
  bottom action bar
- system templates - updating page to ensure list items are vertical centered,
  required due to some changes by ehelms
- javascript - some fixes for the new panel object
- merging in env-selector
- env-select - adding more javascript documentation and improving spacing
  calculations
- Fix proxy to candlepin due to change RAILS_RELATIVE_URL_ROOT
- env-select - fixing a few spacing issues as well as having selected item be
  expanded more so than others
- 738762 - SSLVerifyClient for apache+thin
- env select - corrected env select widget to work with the expanding nodes
- 722439 - adding version to the footer
- Roles UI - Fix for broken role editing on the UI.
- env select - fixing up the new environment selector and ditching the old
  jbreadcrumb
- Two other small changes to fix the hidden features of subscribe and
  unsubscribe.
- Fix for .hidden not working :)
- Roles UI - Fixes broken add permission workflow.
- Fixes a number of look and feel issues related to sliding tree items and
  clicking list items.
- Changes multiselect to have add from list on the left and add to list on the
  right. Moves multiselect widget css to its own file.
- Fixes for changes to panel javascript due to rebase.
- Fixes for editing a permission when setting the all tags or all verbs.
- A refactor of panel in preparation for changes to address a series of bugs
  related to making the slide out panel of tupane more robust.
- Roles UI - Adds back missing css for blue box around roles widget.
- CSS cleanup focused on organizing colors and adding more variable
  definitions.
- initial breadcrumb revamp

* Thu Sep 15 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.82-1
- removing two unnecessarry macros in spec file
- correcting workaround for BZ 714167 (undeclared dependencies) in spec
- adding copyright and modeline to our spec files
- correcting indentatin (Jan Pazdziora)
- packagegroups - add pacakge groups and categories to JSON
- pacakgegroups - refactor template exports to meet Ruby conventions
- packagegroups - add to string export of template
- packagegroups - support for group and categories in temp import
- adding two configuration values debug_pulp_proxy
- promotions - fixing error where you could not add a product
- Fixed some unit tests...
- 734460 - Fix to have the roles UI complain on bad role names
- Fix to get tags.formatted to work with the new changes
- Fixed several broken tests in postgres
- Removed 'tags' table for we could just deal with that using unique tag ids.
  To avoid the dreaded "explicit cast" exception when joining tags to entity
  ids table in postgres (example - Environments), we need tags to be integers.
  All our tags at the present time are integers anyway so this seems an easy
  enough change.
- refactor - remove debug message to stdout
- fixed a few issues with repo creation on manifest import test
- added support for preserving of repo metadata during import of manifests
- 738200 - use action_name instead of params[:action]
- templates api - route for listing templates in an environment

* Tue Sep 13 2011 Brad Buckingham <bbuckingham@redhat.com> 0.1.81-1
- notices - fix change to app controller that accidentally affected notices
  (bbuckingham@redhat.com)
- systems - spec test fix (jsherril@redhat.com)
- panel - fixing issue where panel closing would not close the subpanel
  (jsherril@redhat.com)
- 733157 - removing ability to change prior environment, and showing correct
  prior on details/edit page (jsherril@redhat.com)
- notices - fixing javascript error that happens when uploading a manifest via
  the UI (jsherril@redhat.com)
- 734894 - promotions - fixing issue where hover text on promoting changeset
  would still say it is being promoted even after it has been promoted
  (jsherril@redhat.com)
- Subscriptions udpates, packages fix, ui spinner fix, universal KT object for
  applying subs. (jrist@redhat.com)
- Subscription quantity inside spinner now. (jrist@redhat.com)
- 403 code, 500 code, and some changes to the 500 render. (jrist@redhat.com)
- Fix for the look of the error. (jrist@redhat.com)
- 404 and 500 error pages. (jrist@redhat.com)
- Fixed a unit test (paji@redhat.com)
- adding logging catch for notices that are objects we dont expect
  (jsherril@redhat.com)
- 737563 - Subscription Manager fails permissions on accessing subscriptions
  (lzap+git@redhat.com)
- 736141 - Systems Registration perms need to be reworked (lzap+git@redhat.com)
- Revert "736384 - workaround for perm. denied (unit test)"
  (lzap+git@redhat.com)
- Revert "736384 - workaround for perm. denied for rhsm registration"
  (lzap+git@redhat.com)
- remove-depretactions - use let variables insted of constants in rspec
  (inecas@redhat.com)
- remove-deprecations - already defined constant in katello_url_helper
  (inecas@redhat.com)
- remove-deprecations - Object#id deprecated (inecas@redhat.com)
- remove-deprecations - use errors.add :base instead of add_to_base
  (inecas@redhat.com)
- remove-deprecations - should_not be_redirect insted of redirect_to()
  (inecas@redhat.com)
- remove-deprecations - validate overriding (inecas@redhat.com)
- Fixed the tags_for to return an empty array instead of nil and also removed
  the list tags in org since we are not doling out org perms on a per org basis
  (paji@redhat.com)
- system templates - adding more rules spec tests (jsherril@redhat.com)
- Fix typo in template error messages (inecas@redhat.com)
- packagegroups-templates - CLI for package groups in templates
  (inecas@redhat.com)
- packagegroups-templates - assigning packege group categories to template
  (inecas@redhat.com)
- packagegroups-templates - assigning package groups to system templates
  (inecas@redhat.com)
- templates - unittest fix (tstrachota@redhat.com)
- unit test fixes (jsherril@redhat.com)
- Fixes to get  the promotion pages working (paji@redhat.com)
- Fix on system template model - no_tag was returning map instead of array
  (paji@redhat.com)
- Merge branch 'master' into template-ui (jsherril@redhat.com)
- system templates - making sure that all ui elements are looked up again in
  each function in case they are redrawn (jsherril@redhat.com)
- system templates - making jslint happy, and looking up elements that may have
  been redrawn (jsherril@redhat.com)
- system templates - a few javascript fixes for product removal
  (jsherril@redhat.com)
- Updated katello.js to keep jslint happy (paji@redhat.com)
- Updated katello.js to keep jslint happy (paji@redhat.com)
- Updated katello.js to keep jslint happy (paji@redhat.com)
- Code changes to make jslint happy (paji@redhat.com)
- Fixed some system template conflict handling issues (paji@redhat.com)
- system templates - adding permission for system templates
  (jsherril@redhat.com)
- system templates - fixing things that broke due to master merge
  (jsherril@redhat.com)
- merge fix (jsherril@redhat.com)
- system templates - fixing issue with firefox showing a longer form than
  chrome causing the add button to go to another line (jsherril@redhat.com)
- Added a 'details' page for system templates promotion (paji@redhat.com)
- changeset history - adding bbq support for cs history, and making bbq work
  properly on this page for panel (jsherril@redhat.com)
- Added a system templates details page needed for promotion (paji@redhat.com)
- Quick fix on promotions javascript to get the add/remove properly showing up
  (paji@redhat.com)
- 734899 - fixing issue where changeset history would default to library
  (jsherril@redhat.com)
- changeset history - adding indentation to content items (jsherril@redhat.com)
- Added some auth rules for changeset updating (paji@redhat.com)
- adding system templates to changeset history and fixing spacing issues with
  accordion (jsherril@redhat.com)
- Got the add remove working on system templates (paji@redhat.com)
- system templates - fixing action bar buttons from not changing name properly
  (jsherril@redhat.com)
- Added code to show 'empty' templates (paji@redhat.com)
-  fixing merge conflict (jsherril@redhat.com)
- system templates - adapting the system templates tow ork with the new action
  bar api (jsherril@redhat.com)
- Fixed errors that crept up in a previous commit (paji@redhat.com)
- Fixed the simplyfy_changeset to have an init :system_templates
  (paji@redhat.com)
- Made got the add/remove system templates functionality somewhat working
  (paji@redhat.com)
- fixing merge conflicts (jsherril@redhat.com)
- system templates - adding additional tests (jsherril@redhat.com)
- system templates - adding help tip (jsherril@redhat.com)
- system templates - adding & removing from content pane now works as well as
  saving product changes within the template (jsherril@redhat.com)
- system templates - adding working auto complete box for products
  (jsherril@redhat.com)
- system-templates - making the auto complete box more abstract so products can
  still use it, as well as adding product rendering (jsherril@redhat.com)
- system templates - adding missing view (jsherril@redhat.com)
- breaking out packge actions to their own js object (jsherril@redhat.com)
- Initial cut of the system templates promotion page - Add/remove changeset
  functionality TBD (paji@redhat.com)
- system template - add warning when browsing away from an unsaved changeset
  (jsherril@redhat.com)
- system template - fixing issue where clicking add when default search text
  was there would attempt to add a package (jsherril@redhat.com)
- system templates - added save dialog for moving away from a template when it
  was modified (jsherril@redhat.com)
- sliding tree - making it so that links to invalid breadcrumb entries redirect
  to teh default tab (jsherril@redhat.com)
- system templates - got floating box to work with scrolling properly and list
  to have internal scrolling instead of making the box bigger
  (jsherril@redhat.com)
- system templates - adding package add/remove on left hand content panel, and
  only showing package names (jsherril@redhat.com)
- system template - only show 20 packages in auto complete drop down
  (jsherril@redhat.com)
- Adding changeset to system templates connection (paji@redhat.com)
- adding saving indicator and moving tree_loading css to be a class instead of
  an id (jsherril@redhat.com)
- adding package validation before adding (jsherril@redhat.com)
- adding autocomplete for packages on system template page
  (jsherril@redhat.com)
- making save functionality work to actually save template packages
  (jsherril@redhat.com)
- added client side adding of packages to system templates
  (jsherril@redhat.com)
- adding search and sorting to templates page (jsherril@redhat.com)
- moving system templates to a sliding tree and to the content section
  (jsherril@redhat.com)
- making sure sliding tree does not double render on page load
  (jsherril@redhat.com)
- only allowing modification of a system template in library within system
  templates controller (jsherril@redhat.com)
- adding spec tests for system_templates controller (jsherril@redhat.com)
- fixing row height on system templates (jsherril@redhat.com)
- adding initial system template CRUD (jsherril@redhat.com)

* Mon Sep 12 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.80-1
- error text now include 'Warning' not to confuse users
- initscript - removing temporary sleep
- initscript - removing pid removal
- 736716 - product api was returning 2 ids per product
- 736438 - implement permission check for list_owners
- 736438 - move list_owners from orgs to users controller
- app server - updates to use thin Rack handler vs script/thin
- script/rails - adding back in... needed to run rails console
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
- renaming the 2 providers to something more useful
- Changeset History - Fix for new URL scheme on changeset history page.
- Roles UI - Adds selected color border to roles slide out widget and removes
  arrow from left list on roles page only.

* Fri Sep 09 2011 Brad Buckingham <bbuckingham@redhat.com> 0.1.79-1
- Merge branch 'master' into thin (mmccune@redhat.com)
- Merge branch 'master' into thin (mmccune@redhat.com)
- moving new thin and httpd conf files to match existing config locations
  (mmccune@redhat.com)
- Simplify the stop command and make sure status works (mmccune@redhat.com)
- JS - fix image paths in javascript (bbuckingham@redhat.com)
- Promotions packages - replace hardcoded path w/ helper
  (bbuckingham@redhat.com)
- katello.init - update thin start so that log/pid files are owned by katello
  (bbuckingham@redhat.com)
- Views - updates to support /katello prefix (bbuckingham@redhat.com)
- Views/JS - updates to support /katello prefix (bbuckingham@redhat.com)
- Merge branch 'master' into thin (bbuckingham@redhat.com)
- app server - update apache katello.conf to use candlepin cert
  (bbuckingham@redhat.com)
- View warning - address view warning on Org->Subscriptions (Object#id vs
  Object#object_id) (bbuckingham@redhat.com)
- View warnings - address view warnings resulting from incorrect usage of
  form_tag (bbuckingham@redhat.com)
- app server - changes to support /katello prefix in base path
  (bbuckingham@redhat.com)
- app server - removing init.d/thin (bbuckingham@redhat.com)
- katello.spec - add thin.yml to files (bbuckingham@redhat.com)
- katello.spec - remove thin/thin.conf (bbuckingham@redhat.com)
- promotion.js - uncomment line accidentally committed (bbuckingham@redhat.com)
- app server - setting relative paths on fonts/images in css & js
  (bbuckingham@redhat.com)
- Views - update to use image_tag helper (bbuckingham@redhat.com)
- app server - removing script/rails ... developers will instead use
  script/thin start (bbuckingham@redhat.com)
- Apache - first pass update to katello.conf to add SSL
  (bbuckingham@redhat.com)
- thin - removing etc/thin/thin.yml (bbuckingham@redhat.com)
- forgot to add this config file (mmccune@redhat.com)
- adding new 'thin' startup script (mmccune@redhat.com)
- moving thin into a katello config (mmccune@redhat.com)
- first pass at having Katello use thin and apache together
  (mmccune@redhat.com)

* Thu Sep 08 2011 Brad Buckingham <bbuckingham@redhat.com> 0.1.78-1
- scoped_search - bumping version to 2.3.3 (bbuckingham@redhat.com)
- 735747 - fixing issue where creating a permission with create verb would
  result in an error (jsherril@redhat.com)
- Changes from using controller_name (a pre-defined rails function) to using
  controller_display_name for use in setting model object ids in views.
  (ehelms@redhat.com)
- 736440 - Failures based on authorization return valid json
  (tstrachota@redhat.com)
- default newrelic profiling to false in dev mode (shughes@redhat.com)
- Merge branch 'oauth_provider' (dmitri@redhat.com)
- added support for katello api acting as a 2-legged oauth provider
  (dmitri@redhat.com)

* Thu Sep 08 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.77-1
- puppet - adding initdb 'run twice' check
- 731158: add ajax call to update sync duration
- sync-status removing finish_time from ui
- sync status - add sync duration calculations
- sync status - update title per QE request
- 731158: remove 'not synced' status and leave blank
- 734196 - Disabled add and remove buttons in roles sliding tree after they
  have been clicked to prevent multiple server calls.
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
- 725842 - Fix for Search: fancyqueries dropdown - alignment
- Merge branch 'master' into roles-ui
- Role - Disabled the resizing on the roles ui sliding tree.
- Fix for when system has no packages - should not see list or filter.
- Fix for systems with no packages.
- 736148 - update code to properly cancel a sync and render it in UI
- Role - Changes to display of full access label on organizations in roles ui
  list when a permission granting full access is removed.
- 731158: misc improvements to sync status page
- 736384 - workaround for perm. denied (unit test)
- Role - Look and feel fixes for displaying of no current permissions message.
- 734448 - Fix for Broken 'logout' link at web page's footer o    modified:
  src/app/views/layouts/_footer.haml
- Package sort asc and desc via header.  Ajax refresh and indicators.
- 736384 - workaround for perm. denied for rhsm registration
- Roles - Adds text to empty permissions list instructing user what to do next
  for global and organizational permissions.
- Merge branch 'master' into roles-ui
- 736251 - use content name for repo id when importing manifest
- templates - it is possible to create/edit only templates in the library -
  added checks into template controller - spec tests fixed according to changes
- Packages offset loading via "More..." now working with registered system.
- 734026 - removing uneeded debug line that caused syncs to fail
- packagegroups - refactor: move menthods to Glue::Pulp::Repo
- Merge branch 'master' into sub
- product - removed org name from product name
- Api for listing package groups and categories
- Fixing error with spinner on pane.
- Refresh of subs page.
- Area to re-render subs.
- unsubscribe support for sub pools
- Merge branch 'subway' of ssh://git.fedorahosted.org/git/katello into subway
- Fix for avail_subs vs. consumed_subs.
- move sys pools and avail pools to private methods, reuse
- Adds class requirement 'filterable' on sliding lists that should be
  filterable by search box.
- Update to permission detail view to display verbs and tags in a cleaner way.
- Adds step indicators on permission create.  Adds more validation handling for
  blank name.
- initial subscription consumption, sunny day
- Fixes to permission add and edit flow for consistency.
- More subscriptions work. Rounded top box with shadow and borders.  Fixed some
  other stuff with spinner.
- Updated subscription spinner to have useful info.
- More work on subscriptions page.
- Small change for wrong sub.poolId.
- Added a spinner to subscriptions.
- fix error on not grabbing latest subscription pools
- Fixed views for subscriptions.
- Merge branch 'subway' of ssh://git.fedorahosted.org/git/katello into subway
- Fixed a non i18n string.
- support mvc better for subscriptions availability and consumption
- Role editing commit that adds workflow functionality.  This also provides
  updated and edits to the create permission workflow.
- Modifies sliding tree action bar to require an identifier for the toggled
  item and a dictionary with the container and setup function to be called.
  This was in order to re-use the same HTML container for two different
  actions.
- change date format for sub expires
- changing to DateTime to Date for expires sub
- Wires up edit permission button and adds summary for viewing an individual
  permission.
- Switches from ROLES object to KT.roles object.
- added consumed value for pool of subs
- Subscriptions page changes to include consumed and non-consumed.
- Subscriptions page coming along.
- remove debugger line
- add expires to subscriptions
- Subscriptions page.  Mostly mocked up (no css yet).
- cleaning up subscriptions logic
- add in subscription qty for systems
- Small change to subscriptions page, uploading of assets for new subscriptions
  page.
* Mon Sep 05 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.76-1
- 730358 - repo discovery now uses asynchronous tasks - the route has been
  changed to /organizations/ID/repositories/discovery/
- 735359 - Don't create content in CP when creating a repo.
- Fixed a couple of errors that occured due to wrong sql in postgres
- reset-dbs - katello-jobs are restarted now
- Changes roles and permission success and error notices to include the name of
  the role/permission and fit the format of other pages.
- Validate uniqueness of repo name within a product scope
- products - cp name now join of <org_name>-<product_name> used to be
  <provider_name>-<product_name>
- sync - comparing strings instead of symbols in sync_status fix for AR
  returning symbols
- sync - fix for sync_status failing when there were no syncable subitems
  (repos for product, products for providers)
- sync - change in product&provider sync_status logic
- provider sync status - cli + api
- sync - spec tests for cancel and index actions
- Fixes for editing name of changeset on changeset history page.
- Further re-work of HTML and JS model naming convention.  Changes the behavior
  of setting the HTML id for each model type by introducing a simple
  controller_name function that returns the controller name to be used for
  tupane, edit, delete and list items.
- Adds KT javascript global object for all other modules to attach to. Moves
  helptip and common to be attached to KT.
- Changes to Users page to fit new HTML model id convention.
- Changes Content Management page items to use new HTML model id convention.
- Changes to Systems page for HTML and JS model id.
- Changes Organizations section to use of new HTML model id convention.
- Changes to model id's in views.
- 734851 - service katello start - Permission denied
- Refactor providers - remove unused routes

* Wed Aug 31 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.75-1
- 734833 - service katello-jobs stop shows non-absolute home (ArgumentError)
- Refactor repo path generator
- Merge branch 'repo-path'
- Fix failing repo spec
- Pulp repo for Library products consistent with other envs
- 734755 - Service katello-jobs status shows no file or directory
- Refactor generating repo id when cloning
- Change CP content url to product/repo
- Scope system by readable permissions
- Scope users by readable permissions
- Scope products by readability scope
- Refactor - move providers from OrganziationController
- Fix scope error - readable repositories
- Remove unused code: OrganizationController#providers
- Authorization rules - fix for systmes auth check
- More specific test case pro changeset permissions
- Scope products for environment by readable providers
- Fix bug in permissions
- Scope orgranizations list in API by the readable permissions
- Fix failing spec
- Authorization rules for API actions
- Integrate authorization rules to API controllers
- Merge remote-tracking branch 'origin/master' into repo-path
- Format of CP content url: /org/env/productName/repoName

* Tue Aug 30 2011 Partha Aji <paji@redhat.com> 0.1.74-1
- Fixed more bugs related to the katello.yml and spec (paji@redhat.com)

* Tue Aug 30 2011 Partha Aji <paji@redhat.com> 0.1.73-1
- Fixed the db directory link (paji@redhat.com)
- Updated some spacing issues (paji@redhat.com)

* Tue Aug 30 2011 Partha Aji <paji@redhat.com> 0.1.72-1
- Updated spec to not include database yml in etc katello and instead for the
  user to user /etc/katello/katello.yml for db info (paji@redhat.com)
- Fixed an accidental goof up in the systems controllers test (paji@redhat.com)
- made a more comprehensive test matrix for systems (paji@redhat.com)
- Added rules based tests to test systems controller (paji@redhat.com)
- Added rules for sync_schedules spec (paji@redhat.com)
- Added tests for sync plans (paji@redhat.com)
- Added rules tests for subscriptions (paji@redhat.com)
- Restricted the routes for subscriptions  + dashboard resource to only :index
  (paji@redhat.com)
- Added tests for repositories controller (paji@redhat.com)
- Updated routes in a for a bunch of resources limiting em tp see exactly what
  they can see (paji@redhat.com)
- Added unit tests for products controller (paji@redhat.com)
- fixing permission denied on accounts controller (jsherril@redhat.com)
- 731540 - Sync Plans - update edit UI to use sync_plan vs plan
  (bbuckingham@redhat.com)
- added rules checking for environment (paji@redhat.com)
- Added tests for operations controller (paji@redhat.com)
- Bug fix - resource should be in plural when checking permissions
  (inecas@redhat.com)
- adding sync management controller rules tests (jsherril@redhat.com)
- adding users controller rules tests (jsherril@redhat.com)
- adding roles controller rules tests (jsherril@redhat.com)
- 734033 - deleteUser API call fails (inecas@redhat.com)
- 734080 - katello now returns orgs for owner (lzap+git@redhat.com)

* Fri Aug 26 2011 Justin Sherrill <jsherril@redhat.com> 0.1.71-1
- fixing a couple issues with promotions (jsherril@redhat.com)
- adding some missing navigation permission checking (jsherril@redhat.com)
- fixing issue where logout would throw a permission denied
  (jsherril@redhat.com)
- adding provider roles spec tests (jsherril@redhat.com)
- Decreasing min validate_length for name fields to 2.  (Kept getting denied
  for "QA"). (jrist@redhat.com)
- Raising a permission denied exception of org is required, but not present.
  Previously we would log the user out, which does not make much sense
  (jsherril@redhat.com)
- KPEnvironment (and subsequent kp_environment(s)) => KTEnvironment (and
  kt_environment(s)). (jrist@redhat.com)
- fixing broken unit tests (jsherril@redhat.com)
- Fixed an issue where clicking on notices caused a user with no org perms to
  log out (paji@redhat.com)
- adding promotions permissions spec tests (jsherril@redhat.com)
- Fixed some unit tests (paji@redhat.com)
- Updated the protected shared example and unit tests (paji@redhat.com)
- spec tests - modification after changes in product model/controller
  (tstrachota@redhat.com)
- fix for product name validations (tstrachota@redhat.com)
- products cli - now displaying provider name (tstrachota@redhat.com)
- products cli - fixed commands according to recent changes
  (tstrachota@redhat.com)
- products - name unique in scope of product's organziation
  (tstrachota@redhat.com)
- products - name unique in scope of provider now + product sync info reworked
  (tstrachota@redhat.com)
- product api - added synchronization data (tstrachota@redhat.com)
- sync - api for sync status and cancelling (tstrachota@redhat.com)
- katello-jobs.init executable (tstrachota@redhat.com)
- changeset controller (jsherril@redhat.com)
- removed an accidental typo (paji@redhat.com)
- Added authorization controller tests based of ivan's initial work
  (paji@redhat.com)
- adding small simplification to notices (jsherril@redhat.com)
- Fixes broken promotions page icons. (ehelms@redhat.com)
- Fixes issue with incorrect icon being displayed for custom products.
  (ehelms@redhat.com)
- 732920 - Fixes issue with right side panel in promotions moving up and down
  with scroll bar unncessarily. (ehelms@redhat.com)
- Adds missing changeset loading spinner. (ehelms@redhat.com)
- Code cleanup and fixes for filter box on promotions and roles page styling
  and actions. (ehelms@redhat.com)
- making sure sync plans page only shows readable products
  (jsherril@redhat.com)
- fixing issue where promotions would not highlight the correct nav
  (jsherril@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (ehelms@redhat.com)
- Javascript syntax and error fixing. (ehelms@redhat.com)
- Merge branch 'master' into roles-ui (paji@redhat.com)
- removing uneeded test (jsherril@redhat.com)
- Merge branch 'master' into perf (shughes@redhat.com)
- Merge branch 'roles-ui' of ssh://git.fedorahosted.org/git/katello into roles-
  ui (ehelms@redhat.com)
- Fixes to roles ui widget as a result of a re-factor as a result of bug
  729728. (ehelms@redhat.com)
- Fixed perm spec bug (paji@redhat.com)
- Further Merge conflicts as a result of merging master in. (ehelms@redhat.com)
- fixing spec tests (jsherril@redhat.com)
- Merge branch 'master' into roles-ui (ehelms@redhat.com)
- adding version for newrelic gem (shughes@redhat.com)
- adding dev gem newrelic (shughes@redhat.com)
- config for newrelic profiling (shughes@redhat.com)
- Fix failing tests - controller authorization rules (inecas@redhat.com)
- Persmissions rspec - use before(:each) instead of before(:all)
  (inecas@redhat.com)
- Shared example for authorization rules (inecas@redhat.com)
- improving reset-dbs script (lzap+git@redhat.com)
- Fixed some changeset controller tests (paji@redhat.com)
- fixing spec test (jsherril@redhat.com)
- Fixed a spec test in user controllers (paji@redhat.com)
- Made the syncable check a lambda function (paji@redhat.com)
- Fixed some unit tests (paji@redhat.com)
- 729728 - Makes it so that clicking anywhere inside a highlighted row on
  promotions page will click it instead of just a narrow strip of the
  highlighted row. (ehelms@redhat.com)
- Fixes issue with changeset loading as a result of previous bug fix.
  (ehelms@redhat.com)
- converting promotions to use a more simple url scheme that helps navigation
  not have to worry about which environments the user can access via promotions
  (jsherril@redhat.com)
- Fixed the panel sliding up and down. (jrist@redhat.com)
- Fixed panel sliding up and down when closing or opening helptips.
  (jrist@redhat.com)
- make sure we delete all the pulp database files vs just the 1
  (mmccune@redhat.com)
- Fixed merge conflicts (paji@redhat.com)
- restructured the any  rules  in org to be in environment to be more
  consistent (paji@redhat.com)
- 726724 - Fixes Validation Error text not showing up in notices.
  (ehelms@redhat.com)
- removed beaker rake task (dmitri@redhat.com)
- Fixed a rules bug that would wrongly return nil instead of true .
  (paji@redhat.com)
- commented-out non localhost setting for candlepin integration tests
  (dmitri@redhat.com)
- commented-out non localhost setting for candlepin integration tests
  (dmitri@redhat.com)
- first cut at candlepin integration tests (dmitri@redhat.com)
- fixing issue with System.any_readable? referring to self instead of org
  (jsherril@redhat.com)
- fixing systems to only look up what the user can read (jsherril@redhat.com)
- Notices - fix specs broken in in the roles refactor (bbuckingham@redhat.com)
- removing error message from initdb script (lzap+git@redhat.com)
- 723308 - verbose environment information should list names not ids
  (inecas@redhat.com)
- Made the code use environment ids instead of collecting one env at a time
  (paji@redhat.com)
- 732846 - reverting back to working code (mmccune@redhat.com)
- 732846 - purposefully checking in syntax error - see if jenkins fails
  (mmccune@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (mmccune@redhat.com)
- 732846 - adding a javascript lint to our unit tests and fixing errors
  (mmccune@redhat.com)
- Added protect_from_forgery for user_sessinos_controller - now passes auth
  token on post. (jrist@redhat.com)
- auto_tab_index - introduce a view helper to simplify adding tabindex to forms
  (bbuckingham@redhat.com)
- Role - Changes to javascript permission lockdown. (ehelms@redhat.com)
- Role - Adds tab order to permission widget input and some look and feel
  changes. (ehelms@redhat.com)
- Role - Makes permission name unique with a role and an organization.
  (ehelms@redhat.com)
- Role - Adds disable to Done button to prevent multiple clicks.
  (ehelms@redhat.com)
- Roles - updating role ui to use the new permissions model
  (bbuckingham@redhat.com)
- Re-factor of Roles-UI javascript for performance. (ehelms@redhat.com)
- Modified the super admin before destroy query to use the new way to do super
  admins (paji@redhat.com)
- Re-factoring and fixes for setting summary on roles ui. (ehelms@redhat.com)
- Adds better form and flow rest on permission widget. (ehelms@redhat.com)
- Fixes for wrong verbs showing up initially in permission widget.  Fix for
  non-display of tags on global permissions. (ehelms@redhat.com)
- Changes filter to input box.  Adds fixes for validation during permission
  creation. (ehelms@redhat.com)
- Users - fix issue where user update would remove user's roles
  (bbuckingham@redhat.com)
- Navigation related changes to hide different resources (paji@redhat.com)
- Fixing the initial summary on roles-ui page. (jrist@redhat.com)
- `Merge branch 'roles-ui' of ssh://git.fedorahosted.org/git/katello into
  roles-ui (jrist@redhat.com)
- Sliding tree summaries. (jrist@redhat.com)
- Role - Adds client side validation to permission widget steps.
  (ehelms@redhat.com)
- Adds enhancements to add/remove of users and permissions. (ehelms@redhat.com)
- Fixing a bunch of labels and the "shadow bar" on panels without nav.
  (jrist@redhat.com)
- Revert "729115 - Fix for overpass font request failure in FF.  Caused by
  ordering of request for font type." (jrist@redhat.com)
- 729115 - Fix for overpass font request failure in FF.  Caused by ordering of
  request for font type. (jrist@redhat.com)
- Merge branch 'roles-ui' of ssh://git.fedorahosted.org/git/katello into roles-
  ui (jrist@redhat.com)
- 722432 - Fix for CSRF exploit on /logout (jrist@redhat.com)
- Role - Adds fixes for sliding tree that led to multiple hashchange handlers
  and inconsistent navigation. (ehelms@redhat.com)
- Merge branch 'roles-ui' of ssh://git.fedorahosted.org/git/katello into roles-
  ui (jrist@redhat.com)
- Activation Keys - fix specs resulting from roles and perms changes
  (bbuckingham@redhat.com)
- 730754 - Fix for rendering of wider panels. (jrist@redhat.com)
- Fixes background issues on roles and permissions on users page.
  (ehelms@redhat.com)
- Moves bulk of roles sliding tree code to new file.  Changes paradigm to load
  bulk of roles editing javascript code once and have initialization/resets
  occur on individual ajax loads. (ehelms@redhat.com)
- Roles - update env breadcrumb path used by akeys...etc to better handle
  scenarios involving permissions (bbuckingham@redhat.com)
- unbind live click handler for non syncable schedules (shughes@redhat.com)
- js call to disable non syncable schedule commits (shughes@redhat.com)
- removing unnecessary products loop (shughes@redhat.com)
- Removed the 'allow' method in roles, since it was being used only in tests.
  So moved it to tests (paji@redhat.com)
- Rounded bottom corners on third level subnav. Added bg. (jrist@redhat.com)
- Merge branch 'roles-ui' of ssh://git.fedorahosted.org/git/katello into roles-
  ui (jrist@redhat.com)
- Third-level nav hover. (jrist@redhat.com)
- fix bug with viewing systems with nil environments (shughes@redhat.com)
- 3rd level nav bumped up to 2nd level for systems (shughes@redhat.com)
- remove 3rd level nav from systems page (shughes@redhat.com)
- making promotions controller rules more readable (jsherril@redhat.com)
- Subscriptions - fix accidental commit... :( (bbuckingham@redhat.com)
- having the systems environment page default to an environment the user can
  actually read (jsherril@redhat.com)
- fixing issue where changesets history would default to a changeset that the
  user was not able to read (jsherril@redhat.com)
- fixing permission for accessing the promotions page (jsherril@redhat.com)
- remove provider sync perms from schedules (shughes@redhat.com)
- update sync mgt to use org syncable perms (shughes@redhat.com)
- remove sync from provider. moved to org. (shughes@redhat.com)
- readable perms update to remove sync (shughes@redhat.com)
- Roles - Activation Keys - add the logic to UI side to honor permissions
  (bbuckingham@redhat.com)
- making the promotions page honor roles and perms (jsherril@redhat.com)
- fixing issue with sync_schedules (jsherril@redhat.com)
- Fixes for the filter. (jrist@redhat.com)
- Merge branch 'roles-ui' of ssh://git.fedorahosted.org/git/katello into roles-
  ui (jrist@redhat.com)
- Converted orgSwitcher to an ajax call for each click. Added a filter.
  (jrist@redhat.com)
- Fixed a tags glitch that was checking for id instead of name
  (paji@redhat.com)
- Fix for reseting add permission widget. (ehelms@redhat.com)
- Role - Adds support for all tags and all verbs selection when adding a
  permission. (ehelms@redhat.com)
- update product to be syncable only by org sync access (shughes@redhat.com)
- disable sync submit btn if user does not have syncable products
  (shughes@redhat.com)
- change sync plans to use org syncable permission (shughes@redhat.com)
- add sync resource to orgs (shughes@redhat.com)
- fix sync plan create/edit access (shughes@redhat.com)
- adjust sync plan to use provider readable access (shughes@redhat.com)
- remove sync plan resource type (shughes@redhat.com)
- remove sync plan permission on model (shughes@redhat.com)
- Fixed bunch of lookups that were checking on org tags instead of looking at
  org scope (paji@redhat.com)
- Fixed a typo in the perms query to make it not look for tags names for
  :organizations (paji@redhat.com)
- Fixed a typo (paji@redhat.com)
- Roles - remove debugger statement from roles controller
  (bbuckingham@redhat.com)
- Roles - fix typo on systems controller (bbuckingham@redhat.com)
- fix qunit tests for rails.allowedAction (shughes@redhat.com)
- Role - Fix for permission creation workflow. (ehelms@redhat.com)
- Role - Adds function to Tag to display pretty name of tags on permission
  detail view. (ehelms@redhat.com)
- Role - Adds display of verb and resource type names in proper formatting when
  viewing permission details. (ehelms@redhat.com)
- Role - First cut of permission widget with step through flow.
  (ehelms@redhat.com)
- Role - Re-factoring for clarity and preparation for permission widget.
  (ehelms@redhat.com)
- Role - Fix to update role name in list upon edit. (ehelms@redhat.com)
- sync js cleanup and more comments (shughes@redhat.com)
- Role - Activation Keys - add resource type, model and controller controls
  (bbuckingham@redhat.com)
- disable product repos that are not syncable by permissions
  (shughes@redhat.com)
- adding snippet to restrict tags returned for eric (jsherril@redhat.com)
- remove unwanted images for sync drop downs (shughes@redhat.com)
- Updated the navs to deal with org less login (paji@redhat.com)
- Quick fix to remove the Organization.first reference (paji@redhat.com)
- Made the login page choose the first 'accessible org' as users org
  (paji@redhat.com)
- filter out non syncable products (shughes@redhat.com)
- nil org check for authorized verbs (shughes@redhat.com)
- check if product is readable/syncable, sync mgt (shughes@redhat.com)
- adding check for nil org for authorized verbs (shughes@redhat.com)
- blocking off product remove link if provider isnt editable
  (jsherril@redhat.com)
- merging in master (jsherril@redhat.com)
- Role - Fixes fetching of verbs and tags on reload of global permission.
  (ehelms@redhat.com)
- Role - Adds missing user add/remove breadcrumb code.  Fixes for sending all
  types across and not displaying all type in UI.  Fixes sending multiple verbs
  and tags to work properly. (ehelms@redhat.com)
- Made it easier to give all_types access by letting one use all_type = method
  (paji@redhat.com)
- Role - Adds missing user add/remove breadcrumb code.  Fixes for sending all
  type across and not displaying all type in UI.  Fixes sending multiple verbs
  and tags to work properly. (ehelms@redhat.com)
- fixing issue with creation, and nested attribute not validating correctly
  (jsherril@redhat.com)
- Added some permission checking code on the save of a permission so that the
  perms with invalid resource types or verbs don;t get created
  (paji@redhat.com)
- Role - Adds validation to prevent blank name on permissions.
  (ehelms@redhat.com)
- Role - Fixes typo (ehelms@redhat.com)
- Role - Refactor to move generic actionbar code into sliding tree and add
  roles namespace to role_edit module. (ehelms@redhat.com)
- unit test fixes and adding some (jsherril@redhat.com)
- adding validator for permissions (jsherril@redhat.com)
- fix for verb check where symbol and string were not comparing correctly
  (jsherril@redhat.com)
- Made resource type called 'All' instead of using nil for 'all' so that one
  can now check if user has permissions to all in a more transparent manner
  (paji@redhat.com)
- making system environments work with env selector and permissions
  (jsherril@redhat.com)
- Role - Adds 'all' types selection to UI and allows creation of full access
  permissions on organizations. (ehelms@redhat.com)
- adapting promotions to use the env_selector with auth (jsherril@redhat.com)
- switching to a simpler string substitution that wont blow up on nil
  (mmccune@redhat.com)
- Merge branch 'roles-ui' of ssh://git.fedorahosted.org/git/katello into roles-
  ui (jrist@redhat.com)
- Org switcher with box shadow. (jrist@redhat.com)
- fixing the include on last child of env selector being at wrong level
  (jsherril@redhat.com)
- moving nohover mixin to mixins scss file (jsherril@redhat.com)
- making env-selector only accept environments the user has access to, will
  temporarily break other pages using the env selector (jsherril@redhat.com)
- Role - Fixes for opening and closing of edit subpanels from roles actionbar.
  (ehelms@redhat.com)
- Role - Adds button highlighting and text changes on add permission.
  (ehelms@redhat.com)
- Role - Changes role removal button location.  Moves role removal to bottom
  actionbar and implements custom confirm dialog. (ehelms@redhat.com)
- Merge branch 'roles-ui' of ssh://git.fedorahosted.org/git/katello into roles-
  ui (jrist@redhat.com)
- Org switcher with scroll pane. (jrist@redhat.com)
- made a method shorter (paji@redhat.com)
- Adding list filtering to roles and users (paji@redhat.com)
- LoginArrow for org switcher. (jrist@redhat.com)
- Merge branch 'roles-ui' of ssh://git.fedorahosted.org/git/katello into roles-
  ui (jrist@redhat.com)
- Working org switcher. Bit more to do, but it works :) (jrist@redhat.com)
- Added list filtering for org controllers (paji@redhat.com)
- Added code to accept org or org_id so that people sending org_ids to
  allowed_to can deal with it ok (paji@redhat.com)
- Role - Fix for tags not displaying properly on add permission.
  (ehelms@redhat.com)
- Made the names of the scopes more sensible... (paji@redhat.com)
- Role - Adds Global permission adding and fixes to getting permission details
  with bbq hash rendering. (ehelms@redhat.com)
- Role - Fix for creating new role.  Cleans up role.js (ehelms@redhat.com)
- Tupane - Removes previous custom_panel variable from tupane options and moves
  the logic into the role_edit.js file for overiding a single panel. New
  callbacks added to tupane javascript panel object. (ehelms@redhat.com)
- Role - Moved i18n for role edit to index page to only load once.  Added
  display of global permissions in list. Added heading for add permission
  widget.  Added basic global permission add widget. (ehelms@redhat.com)
- Role - Adds bbq hash clearing on panel close. (ehelms@redhat.com)
- fixing more unit tests (jsherril@redhat.com)
- Update the permissions query to effectively deal with organization resource
  vs any other resource type (paji@redhat.com)
- Fixed a permissions issue with providers page (paji@redhat.com)
- Added a display_verbs method to permissions to get a nice list of verbs
  needed by the UI (paji@redhat.com)
- added read in the non global list for orgs (paji@redhat.com)
- Role - Hides tags on adding permission when organization is selected.
  (ehelms@redhat.com)
- fixing list_tags to only show tags within an org for ones that should do so
  (jsherril@redhat.com)
- fixing merge from master conflict (jsherril@redhat.com)
- some spec test fixes (jsherril@redhat.com)
- Added a 'global' tag for verbs in a model to denote verbs that are global vs
  local (paji@redhat.com)
- Updated the debug message on perms (paji@redhat.com)
- Role - Adds cacheing of organization verbs_and_tags. (ehelms@redhat.com)
- Role - Adds Name and Description to a permission.  Adds Name and Description
  to add permission UI widget.  Adds viewing of permissiond etails in sliding
  tree. (ehelms@redhat.com)
- blocking off UI elements based on read/write perms for changeset history
  (jsherril@redhat.com)
- fixing permission http methods (jsherril@redhat.com)
- Role - Adds permission removal from Organization. (ehelms@redhat.com)
- Role - Adds pop-up panel close on breadcrumb change. (ehelms@redhat.com)
- fixing issue where environments would not show tags (jsherril@redhat.com)
- Role - Adds the ability to add and remove users from a role.
  (ehelms@redhat.com)
- spec test for user allowed orgs perms (shughes@redhat.com)
- Role - Adds permission add functionality with controller changes to return
  breadcrumb for new permission.  Adds element sorting within roles sliding
  tree. (ehelms@redhat.com)
- Role - Adds population of add permission ui widget with permission data based
  on the current organization being browsed. (ehelms@redhat.com)
- Role - Adds missing i18n call. (ehelms@redhat.com)
- Roles - Changes verbs_and_scopes route to take in organization_id and not
  resource_type.  Changes the generated verbs_and_scopes object to do it for
  all resource types based on the organization id. (ehelms@redhat.com)
- Role - Adds organization_id parameter to list_tags and tags_for methods.
  (ehelms@redhat.com)
- Role - Changes to allow multiple slide up screens from sliding tree actionbar
  and skeleton of add permission section. (ehelms@redhat.com)
- Role - Adds global count display and fixes non count object display problems.
  (ehelms@redhat.com)
- Role - Adds global permission checking.  Adds global permissions listing in
  sliding tree and adds counts to both Organization and Globals.
  (ehelms@redhat.com)
- Role - Added Globals breadcrumb and changed main load page from Organizations
  to Permissions. (ehelms@redhat.com)
- Role - Adds role detail editing to UI and controller support fixes.
  (ehelms@redhat.com)
- Role - Adds actionbar to roles sliding tree and two default buttons for add
  and edit that do not perform any actions.  Refactors more of sliding tree
  into katello.scss. (ehelms@redhat.com)
- Roles - Adds resizing to roles sliding tree to fill up right side panel
  entirely.  Adds status bar to bottom of sliding tree. Adds Remove and Close
  buttons. (ehelms@redhat.com)
- Roles - Changes to use custom panel option and make sliding tree fill up
  panel on roles page.  Adds base breadcrumb for Role name that leads down
  paths of either Organizations or Users. (ehelms@redhat.com)
- Changes to tupanel sizing calculations and changes to sliding tree to handle
  non-image based first breadcrumb. (ehelms@redhat.com)
- Tupane - Adds new option for customizing overall panel look and feel for
  specific widgets on slide out. (ehelms@redhat.com)
- Roles - Initial commit of sliding tree roles viewer. (ehelms@redhat.com)
- Roles - Adds basic roles breadcrumb that populates all organizations.
  (ehelms@redhat.com)
- Changesets - Moves breadcrumb creation to centralized helper and modularizes
  each major breadcrumb generator. (ehelms@redhat.com)
- Adds unminified jscrollpane for debugging. Sets jscrollpane elements to hide
  focus and prevent outline. (ehelms@redhat.com)
- Added a scope based auth filtering strategy that could be used
  acrossdifferent models (paji@redhat.com)
- locking down sync plans according to roles (jsherril@redhat.com)
- adding back accounts controller since it is a valid stub
  (jsherril@redhat.com)
- removing unused controllers (jsherril@redhat.com)
- hiding UI widets for systems based on roles (jsherril@redhat.com)
- removing consumers controller (jsherril@redhat.com)
- fix for org selection of allowed orgs (shughes@redhat.com)
- spec tests for org selector (shughes@redhat.com)
- blocking UI widgets for organizations based on roles (jsherril@redhat.com)
- route for org selector (shughes@redhat.com)
- stubbing out user sesson spec tests for org selector (shughes@redhat.com)
- ability to select org (shughes@redhat.com)
- hiding select UI widgets based on roles in users controller
  (jsherril@redhat.com)
- Added code to return all details about a resource type as opposed to just the
  name for the roles perms pages (paji@redhat.com)
- renaming couple of old updatable methods to editable (jsherril@redhat.com)
- adding ability to get the list of available organizations for a user
  (jsherril@redhat.com)
- walling off access to UI bits in providers management (jsherril@redhat.com)
- fixing operations controller rules (jsherril@redhat.com)
- fixing user controller roles (jsherril@redhat.com)
- some roles controller fixes for rules (jsherril@redhat.com)
- fixing rules controller rules (jsherril@redhat.com)
- fixing a few more controllers (jsherril@redhat.com)
- fixing rules for subscriptions controller (jsherril@redhat.com)
- Made the roles controller deal with the new model based rules
  (paji@redhat.com)
- Made permission model deal with 'no-tag' verbs (paji@redhat.com)
- fixing sync mgmnt controller rules (jsherril@redhat.com)
- adding better rules for provider, products, and repositories
  (jsherril@redhat.com)
- fixing organization and environmental rules (jsherril@redhat.com)
- getting promotions and changesets working with new role structure, fixing
  user referencing (jsherril@redhat.com)
- making editable updatable (jsherril@redhat.com)
- adding system rules (jsherril@redhat.com)
- adding rules to subscription page (jsherril@redhat.com)
- removing with indifferent access, since authorize now handles this
  (jsherril@redhat.com)
- adding environment rule enforcement (jsherril@redhat.com)
- adding rules to the promotions controller (jsherril@redhat.com)
- adding operations rules for role enforcement (jsherril@redhat.com)
- adding roles enforcement for the changesets controller (jsherril@redhat.com)
- Merge branch 'master' into roles-ui (ehelms@redhat.com)
- using org instead of org_id for rules (jsherril@redhat.com)
- adding rules for sync management and modifying the sync management javascript
  to send product ids (jsherril@redhat.com)
- Fixed some rules for org_controller and added rules for users and roles pages
  (paji@redhat.com)
- making provider permission rules more generic (jsherril@redhat.com)
- moving subscriptions and subscriptions update to different actions, and
  adding permission rules for providers, products, and repositories controllers
  (jsherril@redhat.com)
- Cleaned up the notices to authorize based with out a user perm. Don;t see a
  case for auth on notices. (paji@redhat.com)
- Made the app controller accept a rules manifest from each controller before
  authorizing (paji@redhat.com)
- Initial commit on the the org controllers authorization (paji@redhat.com)
- Removed the use of superadmin flag since its a permission now
  (paji@redhat.com)
- Roles cleanup + unit tests cleanup (paji@redhat.com)
- Optimized the permission check query from the Users side (paji@redhat.com)
- Updated database.yml so that one could now update katello.yml for db info
  (paji@redhat.com)
- Improved the allowed_to method to make use of rails scoping features
  (paji@redhat.com)
- Removed a duplicated unit test (paji@redhat.com)
- Fixed the role file to more elegantly handle the allowed_to and not
  allowed_to cases (paji@redhat.com)
- Updated the permissions model to deal with nil orgs and nil resource types
  (paji@redhat.com)
- Initial commit on Updated Roles UI functionality (paji@redhat.com)

* Tue Aug 23 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.70-1
- fixing miscommited database.yml
- adding kill_pg_connection rake task
- cli tests - removing assumeyes option
- a workaround for candlepin issue: gpgUrl for content must exist, as it is
  used during entitlement certificate generation
- no need to specify content id for promoted repositories, as candlepin will
  assign it

* Tue Aug 23 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.69-1
- 731670 - prevent user from deleting himself
- 731670 - reformatting rescue block
- ignore case for url validation
- add in spec tests for invalid/valid file urls
- support file based urls for validation
- spec fixes
- merging changeset promotion status to master
- hiding the promotion progress bar and replacing it with just text, also
  stopping the fade out upon completion
- fixing issue with promotions where if the repo didnt exist in the next env it
  would fail
- two spec fixes
- a few promotion fixes, waiting on syncing was n ot working, client side
  updater was caching
- fixing promotion backend to sync the cloned repo and not the repo that you
  are promoting
- changing notice on promotion
- fixing issue where promotion could cause a db lock error, fixed by not
  modifying the outside of itself
- fixing issue where promoted changeset was not removed from the
  changeset_breadcrumb
- Promotion - Adjusts alignment of changesets in the list when progress and
  locked.
- Promotions - Changes to alignment in changesets when being promoted and
  locked.
- Promtoions - Fixes issue with title not appearing on a changeset being
  promoted. Changes from redirect on promote of a changeset to return user to
  list of changesets to see progress.
- fixing types of changesets shown on the promotions page
- removed rogue debugger statement
- Promotions - Progress polling for a finished changeset now ceases upon
  promotion reaching 100%.
- Fixes issue with lock icon showing up when progress. Fixes issue with looking
  for progress as a number - should receive string.
- adding some non-accurate progress incrementing to changesets
- Promotions - Updated to submit progress information from real data off of
  changest task status.
- getting async job working with promotions
- Added basic progress spec test. Added route for getting progress along with
  stubbed controller action to return progress for a changeset.
- Adds new callback when rendering is done for changeset lists that adds locks
  and progress bars as needed on changeset list load.
- Adds javascript functionality to set a progress bar on a changeset, update it
  and remove it. Adds javascript functionality to add and remove locked status
  icons from changests.
- adding changeset dependencies to be stored upon promotion time

* Mon Aug 22 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.68-1
- init script - fixing schema.rb permissions check
- katello-jobs - suppressing error message for status info

* Mon Aug 22 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.67-1
- reset script - adding -f (force) option
- reset script - missing candlepin restart string
- fixed a broken Api::SyncController test

* Fri Aug 19 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.66-1
- katello-job - init.d script has proper name now
- katello-job - temp files now in /var/lib/katello/tmp
- katello-job - improving RAILS_ENV setting
- adding Api::SyncController specs that I forgot to add earlier

* Fri Aug 19 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.65-1
- katello-job - adding new init script for delayed_job
- 731810 Deleteing a provider renders an server side error
- spec tests for Glue::Pulp::Repo
- merge of repo#get_{env,product,org} functionality
- repo sync - check for syncing only repos in library
- updated routes to support changes in rhsm related to explicit specification
  of owners
- Activation Keys - fix API rspec tests
- Fix running rspec tests - move corrupted tests to pending
- Api::SyncController, with tests now

* Wed Aug 17 2011 Mike McCune <mmccune@redhat.com> 0.1.64-1
 - period tagging of Katello.
* Mon Aug 15 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.63-1
- 714167 - undeclared dependencies (regin & multimap)
- Revert "714167 - broken dependencies is F14"
- 725495 - katello service should return a valid result

* Mon Aug 15 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.62-1
- 714167 - broken dependencies is F14
- CLI - show last sync status in repo info and status
- Import manifest for custom provider - friendly error message
- better code coverage for changeset api controller
- adding the correct route for package profile update
- new (better?) logo
- adding sysvinit script permission check for schema.rb
- allowing users to override rake setup denial
- Moved jquery.ui.tablefilter.js into the jquery/plugins dir to conform with
  convention.
- Working packages scrollExpand (morePackages).
- Semi-working packages page.
- System Packages scrolling work.
- Currently not working packages scrolling.
- System Packages - filter.
- fix for broken changeset controller spec tests
- now logging both stdout and stderr in the initdb.log
- forcing users not to run rake setup in prod mode
- changeset cli - both environment id and name are displayed in lisitng and
  info
- fox for repo repo promotion
- fixed spec tests after changes in validation of changesets
- fixed typo in model changeset_erratum
- changesets - can't add packs/errata from repo that has not been promoted yet
- changesets - fix for packages and errata removal

* Fri Aug 12 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.61-1
- rpm in /usr/share/katello - introducing KATELLO_DATA_DIR

* Fri Aug 12 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.60-1
- katello rpm now installs to /usr/share/katello
- fixing cancel sync DELETE action call
- fixed api for listing products
- changesets - products required by packages/errata/repos are no longer being
  promoted
- changeset validations - can't add items from product that has not been
  promoted yet
- 727627 - Fix for not being able to go to Sync page.
- final solution for better RestClient exception messages
- only relevant logs are rotated now
- Have the rake task emit wiki markup as well
- added option to update system's location via python client

* Wed Aug 10 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.59-1
- improving katello-reset-dbs script
- Fixes for failing activation_keys and organization tests.
- Grid_16 wrap on subnav for systems.
- Additional work on confirm boxes.
- Confirm override on environments, products, repositories, providers, and
  organizations.
- Working alert override.
- Merged in changes from refactor of confirm.
- Add in a new rake task to generate the API

* Tue Aug 09 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.58-1
- solution to bundle install issues
- initial commit of reset-dbs script
- fixing repo sync
- improving REST exception messages
- fixing more katello-cli tests
- custom partial for tupane system show calls
- 720442: fixing system refresh on name update
- 726402: fix for nil object on sys env page
- 729110: fix for product sync status visual updates
- Upgrading check to Candlepin 0.4.10-1
- removing commented code from api systems controller spec
- changing to different url validation. can now be used outside of model layer.
- spec tests for repositories controller
- 728295: check for valid urls for yum repos
- adding spec tests for api systems_controller (upload packages, view packages,
  update a system)
- added functionality to api systems controller in :index, :update, and
  :package_profile
- support for checking missing url protocols
- changing pulp consumer update messages to show old name
- improve protocol match on reg ex url validation
- removing a debugger statement
- fixing broken orchestration in pulp consumer
- spec test for katello url helper
- fix url helper to match correct length port numbers
- url helper validator (http, https, ftp, ipv4)
- Revert "fix routing problem for POST /organizations/:organzation_id/systems"
- fix routing problem for POST /organizations/:organzation_id/systems (=)
- pretty_routes now prints some message to the stdout
- added systems packages routes and update to systems
- fixed pulp consumer package profile upload and added consumer update to pulp
  resource
- adding to systems_controller spec tests and other small changes.
- fixing find_organization in api/systems_controller.
- added action in api systems controller to get full package list for a
  specific system.

* Thu Aug 04 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.57-1
- spec - adding regin dep as workaround for BZ 714167 (F14/15)

* Wed Aug 03 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.56-1
- spec - introducing bundle install in %build section
- Merge branch 'system_errata'
- added a test for Api::SystemsController#errata call
- listing of errata by system is functional now
- added a script to make rake routes output prettier
- Views - update grid in various partial to account for panel size change
- Providers - fix error on inline edit for Products and Repos
- removing unused systems action - list systems
- 726760 - Notices: Fixes issue with promotion notice appearing on every page.
  Fixes issue with synchronous notices not being marked as viewed.
- Tupane - Fixes issue with main panel header word-wrapping on long titles.
- 727358 - Tupane: Fixes issue with tupane subpanel header text word-wrapping.
- 2Panel - Makes font resizing occur only on three column panels.
- matching F15 gem versions for tzinfo and i18n
- changing the home directory of katello to /usr/lib64/katello after recent
  spec file changes
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
- fixed pulp-proxy-controller to be correct http action
- Merge branch 'master' into system_errata
- added support for listing errata by system

* Mon Aug 01 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.55-1
- spec - rpmlint cleanup
- making changeset history show items by product
- adding descripiton to changeset history page
- 726768 - jnotify - close notice on x click and update to fade quicker on
  close
- 2panel - Adds default left panel sizing depending on number of columns for
  left panel in 2 panel views.  Adds option to 2panel for default width to be
  customizably set using left_panel_width option.
- Changes sizing of provider new page to not cause horizntal scroll bar at
  minimum width.
- fixed reporting of progress during repo synchronization in UI
- fixed an issue with Api::ActivationKeysController#index when list of all keys
  for an environment was being retrieved
- Added api support for activation keys
- Refactor - Converts all remaining javascript inclusions to new style of
  inclusion that places scripts in the head.
- Adds resize event listener to scroll-pane to account for any element in a
  tupane panel that increases the size of the panel and thus leads to needing a
  scroll pane reinitialization.
- Edits to enlarge tupane to take advantage of more screen real estate.
  Changeset package selection now highlights to match the rest of the
  promotions page highlighting.
- General UI - disable hover on Library when Library not clickable
- api error reporting - final solution
- Revert "introducing application error exception for API"
- Revert "ApiError - fixing unit tests"
- ApiError - fixing unit tests
- introducing application error exception for API
- fixing depcheck helper script
- Adds scroll pane support for roles page when clicking add permission button.
- removal of jasmine and addition of webrat, nokogiri
- Activation Keys - enabled specs that required webrat matchers
- spec_helper - update to support using webrat
- adding description for changeset creation
- Tupane - Fixes for tupane fixed position scrolling to allow proper behavior
  when window resolution is below the minimum 960px.
- remove jasmine from deps
- adding dev testing gems
- added Api::ActivationController spec
- added activation keys api controller
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
- fixing merge issues with changeset dependencies
- initial dependency spec test
- adding changeset dependency resolving take 2
- Merge branch 'master' into a-keys
- making changeset dep. solving work on product level instead of across the
  entire environment
- adding description to Changeset object, and allowing editing of the
  description
- adding icons and fixing some spacing with changeset controls
- updated control bar for changesets, including edit
- Fix for a-keys row height.
- Merge branch 'master' into a-keys
- Merge branch 'a-keys' of ssh://git.fedorahosted.org/git/katello into a-keys
- Fixes issue where when a jeditable field was clicked on, and expanded the
  contents of a panel beyond visible no scroll bar would previously appear.
  This change involved a slight re-factor to jeditable helpers to trim down and
  re-factor commonality.  Also, this change involved edits to the jeditable
  plugin itself, thus as of this commit jquery.jeditable is no longer in sync
  with the original repository.
- Activation Keys - removing unused js
- Merge branch 'master' into a-keys
- Activation Keys - add environment to search
- Merge branch 'a-keys' of ssh://git.fedorahosted.org/git/katello into a-keys
- Activation Keys - update to use new tupane layout + spec impacts
- Merge branch 'master' into a-keys
- test for multiple subscriptions assignement to keys
- Activation Keys - make it more obvious that user should select env :)
- Activation Keys - adding some additional specs (e.g. for default env)
- Activation Keys - removing empty spec
- Activation Keys - removing checkNotices from update_subscriptions
- Activation Keys - add Remove link to the subscriptions tab
- Merge branch 'master' into a-keys
- Acttivatino Keys - Adding support for default environment
- spec test for successful subscription updates
- spec test for invalid activation key subscription update
- correctly name spec description
- spec model for multiple akey subscription assigment
- akey subscription update sync action
- ajax call to update akey subscriptions
- akey subscription update action
- fix route for akey subscription updates
- refactor akey subscription list
- bi direction test for akeys/subscriptions
- models for activation key subscription mapping
- Activation Keys - fix failed specs
- Activation Keys - adding helptip text to panel and general pane
- Merge branch 'master' into a-keys
- Activation Keys - ugh.. clean up validation previous commit
- Activation Keys - update so key name is unique within an org
- Activation Key - fix akey create
- Activation Keys - initial specs for views
- Activation Keys - update edit view to improve testability
- Activation Keys - update _new partial to eliminate warning during render
- Activation Keys - removing unused _form partial
- multiselect support for akey subscriptions
- Merge branch 'master' into a-keys
- Activation Keys - update to ensure error notice is generated on before_filter
  error
- adding in activation key mapping to subscriptions
- add jquery multiselect to akey subscription associations
- views for activation key association to subscriptions
- Navigation - remove Groups from Systems subnav
- Activation Keys - controller specs for initial crud support
- adding activation key routes for handling subscription paths
- Activation Keys - fix the _edit view post adding subnav
- Activation Keys - adding the forgotten views...
- Activation Keys - added subnav for subscriptions
- Merge branch 'master' into a-keys
- initial akey model spec tests
- Activation Keys - update index to request based on current org and fix model
  error
- Activation Keys - model - org and env associations
- Merge branch 'master' into a-keys
- Sync Plans - refactor editable to remove duplication
- Systems - refactor editabl to remove duplication
- Environment - refactor editable to remove duplication
- Organization - refactor editable to remove duplication
- Providers - refactor editable to remove duplication
- Merge branch 'master' into a-keys
- Merge branch 'master' into a-keys
- Activation Keys - first commit - initial support for CRUD

* Wed Jul 27 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.54-1
- spec - logging level can be now specified in the sysconfig
- bug 726030 - Webrick wont start with the -d (daemon) option
- spec - service start forces you to run initdb first
- adding a warning message in the sysconfig comment setting
- Merge branch 'pack-profile'
- production.rb now symlinked to /etc/katello/environment.rb
- 725793 - Permission denied stylesheets/fancyqueries.css
- 725901 - Permission errors in RPM
- 720421 - Promotions Page: Adds fade in of items that meet search criteria
  that have previously been hidden due to previously not meeting a given search
  criteria.
- ignore zanta cache files
- Merge branch 'master' into pack-profile
- added pulp-consumer creation in system registration, uploading pulp-consumer
  package-profile via api, tests
- Merge branch 'master' into pack-profile
- increased priority of candlepin consumer creation to go before pulp
- Merge branch 'master' into pack-profile
- renaming/adding some candlepin and pulp consumer methods.
- proxy controller changes

* Tue Jul 26 2011 Shannon Hughes <shughes@redhat.com> 0.1.53-1
- modifying initd directory using fedora recommendation,
  https://fedoraproject.org/wiki/Packaging/RPMMacros (shughes@redhat.com)

* Tue Jul 26 2011 Mike McCune <mmccune@redhat.com> 0.1.52-1
- periodic rebuild to get past tito bug

* Mon Jul 25 2011 Shannon Hughes <shughes@redhat.com> 0.1.51-1
- upgrade to compas-960-plugin 0.10.4 (shughes@redhat.com)
- upgrade to compas 0.11.5 (shughes@redhat.com)
- upgrade to haml 3.1.2 (shughes@redhat.com)
- spec - fixing katello.org url (lzap+git@redhat.com)
- Upgrades jQuery to 1.6.2. Changes Qunit tests to reflect jQuery version
  change and placement of files from Refactor. (ehelms@redhat.com)
- Fixes height issue with subpanel when left panel is at its minimum height.
  Fixes issue with subpanel close button closing both main and subpanel.
  (ehelms@redhat.com)
* Fri Jul 22 2011 Shannon Hughes <shughes@redhat.com> 0.1.50-1
- Simple-navigation 3.3.4 fixes.  Also fake-systems needed bundle exec before
  rails runner. (jrist@redhat.com)
- adding new simple-navigation deps to lock (shughes@redhat.com)
- bumping simple navigation to 3.3.4 (shughes@redhat.com)
- adding new simple-navigation 3.3.4 (shughes@redhat.com)
- Merge branch 'master' into refactor (eric.d.helms@gmail.com)
- fixed a failing Api::ProductsController spec (dmitri@redhat.com)
- fixed several failing tests in katello-cli-simple-test suite
  (dmitri@redhat.com)
- CSS Refactor - Modifies tupane height to be shorter if the left pane is
  shorter so as not to overrun the footer. (ehelms@redhat.com)
- Improved the roles unit test a bit to look by name instead of id. To better
  indicate the ordering (paji@redhat.com)
- Merge branch 'master' into refactor (ehelms@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (ehelms@redhat.com)
- changesets - update cli and controller now taking packs/errata/repos from
  precisely given products (tstrachota@redhat.com)
- Merge branch 'master' into refactor (ehelms@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (ehelms@redhat.com)
- fix for the deprecated TaskStatus in changesets (tstrachota@redhat.com)
- Adding organization to permission (paji@redhat.com)
- CSS Refactpr - Reverts katello.spec back to that of master.
  (ehelms@redhat.com)
- Merge branch 'master' into refactor (ehelms@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (ehelms@redhat.com)
- adding task_status to changeset (jsherril@redhat.com)
- adding qunit tests for changeset conflict calculation (jsherril@redhat.com)
- async jobs now allow for tracking of progress of pulp sync processes
  (dmitri@redhat.com)
- removed unused Pool and PoolsController (dmitri@redhat.com)
- changesets - fix for spec tests #2 (tstrachota@redhat.com)
- changesets - fixed spec tests (tstrachota@redhat.com)
- changesets - fixed controller (tstrachota@redhat.com)
- changesets - model validations (tstrachota@redhat.com)
- changesets - fixed model methods for adding and removing items
  (tstrachota@redhat.com)
- changesets - fix for async promotions not being executed because of wrong
  changeset state (tstrachota@redhat.com)
- changesets - async promotions controller (tstrachota@redhat.com)
- changesets model - skipping items already promoted with product promotions
  (tstrachota@redhat.com)
- changesets api - promotions controller (tstrachota@redhat.com)
- changesets - model changed to be ready for asynchronous promotions
  (tstrachota@redhat.com)
- Merge branch 'master' into refactor (ehelms@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (ehelms@redhat.com)
- 720991 - Segmentation Fault during Roles - Add Permission
  (lzap+git@redhat.com)
- renaming password.rb to password_spec.rb (lzap+git@redhat.com)
- Fixed a broken unit test (paji@redhat.com)
- fixing broken promote (jsherril@redhat.com)
- fixing broken unit test (jsherril@redhat.com)
- adding conflict diffing for changesets in the UI, so the user is notified
  what changed (jsherril@redhat.com)
- disable logging for periodic updater (jsherril@redhat.com)
- 719426 - Fixed an issue with an unecessary group by clause causing postgres
  to go bonkers on roles index page (paji@redhat.com)
- CSS Refactor - Changes to edit panels that need new tupane subpanel layout.
  (ehelms@redhat.com)
- Merge branch 'master' into refactor (ehelms@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (ehelms@redhat.com)
- CSS Refactor - Changes the tupane subpanel to conform with the new tupane
  layout and changes environment, product and repo creation to fit new layout.
  (ehelms@redhat.com)
- CSS Refactor - Changes tupane sizing to work with window resize and sets a
  min height. (ehelms@redhat.com)
- update 32x32 icon. add physical/virtual system icons. (jimmac@gmail.com)
- CSS Refactor - Changes to changeset history page to use tupane layout.
  (ehelms@redhat.com)
- CSS Refactor - Changes promotions page partials that use tupane to use new
  layout. (ehelms@redhat.com)
- CSS Refactor - Changes sync plans page to new tupane layout.
  (ehelms@redhat.com)
- CSS Refactor - Converts providers page to use tupane layout.
  (ehelms@redhat.com)
- CSS Refactor - Modifies users and roles pages to use new tupane layout.
  (ehelms@redhat.com)
- CSS Refactor - Converts organization tupane partials to use new layout.
  (ehelms@redhat.com)
- CSS Refactor - Changes to the size of the spinner in the tupane.
  (ehelms@redhat.com)
- CSS Refactor - Changes to the systems tupane pages to respect new scroll bar
  and tupane layout formatting. (ehelms@redhat.com)
- General UI - fixes in before_filters (bbuckingham@redhat.com)
- increasing required candlepin version to 0.4.5 (lzap+git@redhat.com)
- making the incorrect warning message more bold (lzap+git@redhat.com)
- rails startup now logs to /var/log/katello/startup.log (lzap+git@redhat.com)
- 720834 - Provider URL now being stripped at the model level via a
  before_validation. (For real this time.) (jrist@redhat.com)
- CSS Refactor - Further enhancements to tupane layout.  Moves scrollbar CSS in
  SASS format and appends to the end of katello.sass. (ehelms@redhat.com)
- Sync Plans - update model validation to have name unique within org
  (bbuckingham@redhat.com)
- CSS Refactor - Changes to tupane layout to add navigation and main content
  sections. (ehelms@redhat.com)
- Revert "720834 - Provider URL now being stripped at the model level via a
  before_validation." (jrist@redhat.com)
- 720834 - Provider URL now being stripped at the model level via a
  before_validation. (jrist@redhat.com)
- CSS Refactor - Adds a shell layout for content being rendered into the tupane
  panel.  Partials being rendered to go into the tupane panel can now specify
  the tupane_layout and be constructed to put the proper pieces into the proper
  places.  See organizations/_edit.html.haml for an example.
  (ehelms@redhat.com)
- CSS Refactor - Adjusts the tupane panel to size itself based on the window
  height for larger resolutions. (ehelms@redhat.com)
- CSS Refactor - Minor change to placement of javascript and stylesheets
  included from views. (ehelms@redhat.com)
- fixing missing route for organization system list (lzap+git@redhat.com)
- Backing out 720834 fix temporarily. (jrist@redhat.com)
- 720834 - Provider URL now being stripped at the model level via a
  before_validation. (jrist@redhat.com)
- Removed redundant definition. (ehelms@redhat.com)
- added a couple of tests to validate changeset creation during template
  promotion (dmitri@redhat.com)
- CSS Refactor - Re-organizes javascript files. (ehelms@redhat.com)
- Merge branch 'refactor' of ssh://git.fedorahosted.org/git/katello into
  refactor (ehelms@redhat.com)
- CSS Refactor - Adds new helper for layout functions in views. Specifically
  adds in function for including javascript in the HTML head. See
  promotions/show.html.haml or _env_select.html.haml for examples.
  (ehelms@redhat.com)
- 722431 - Improved jQuery jNotify to include an "Always Closable" flag.  Also
  moved the notifications to the middle top of the screen, rather than floated
  right. (jrist@redhat.com)
- fixed template promotions when performed through api (dmitri@redhat.com)
- 721327 - more correcting gem versions to match (mmccune@redhat.com)
- 721327 - cleaning up mail version numbers to match what is in Fedora
  (mmccune@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (ehelms@redhat.com)
- replacing internal urls in the default config (lzap+git@redhat.com)
- changesets - model spec tests (tstrachota@redhat.com)
- changesets - fixed remove_product deleting the product from db
  (tstrachota@redhat.com)
- changesets api - controller spec tests (tstrachota@redhat.com)
- changesets api - moved logic for adding content from controller to model
  (tstrachota@redhat.com)
- changesets cli - partial updates of content (tstrachota@redhat.com)
- changesets cli - listing (tstrachota@redhat.com)
- changesets api - controller for partial updates of a content
  (tstrachota@redhat.com)
- changesets api - create, read, destroy actions in controller
  (tstrachota@redhat.com)
- changesets api - controller stub (tstrachota@redhat.com)
- Merge branch 'refactor' of ssh://git.fedorahosted.org/git/katello into
  refactor (jrist@redhat.com)
- A few minor fixes for changeset filter and "home" icon. (jrist@redhat.com)
- added product synchronization (async) (dmitri@redhat.com)
- Merge branch 'tasks' (dmitri@redhat.com)
- 720412 - changing promotions helptip to say that a changeset needs to be
  created, as well as hiding add buttons if a piece of content cannot be added
  instead of disabling it (jsherril@redhat.com)
- added specs for TaskStatus model and controller (dmitri@redhat.com)
- removed Glue::Pulp::Sync (dmitri@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (ehelms@redhat.com)

* Thu Jun 23 2011 Lukas Zapletal <lzap+git@redhat.com> 0.1.49-1
- fixing db/schema.rb symlink in the spec
- adding environment support to initdb script
- remove commented debugger in header
- 715421: fix for product size after successful repo(s) sync
- ownergeddon - fixing unit tests
- ownergeddon - organization is needed for systems now
- db/schema.rb now symlinked into /var/lib/katello
- new initscript 'initdb' command
- ownergeddon - bumping version to 0.4.4 for candlepin
- ownergeddon - improving error message
- ownergeddon - support for explicit org
- ownergeddon - user now created using new API
- ownergeddon - user refactoring
- ownergeddon - introducing CPUser entity
- ownergeddon - refactoring name_to_key
- ownergeddon - whitespace
- fixed tests that contained failing environment creation
- fixed failing environment creation test
- Small change for padding around helptip.
- 6692 & 6691: removed hardcoded admin user, as well as usernames and passwords
  from katello config file
- 707274
- Added coded related to listing system's packages
- Stylesheets import cleanup to remove redundancies.
- Refactored systems page css to extend basic block and modify only specific
  attributes.
- Re-factored creating custom rows in lists to be a true/false option that when
  true attempts to call render_rows.  Any page implementing custom rows in a
  list view should provide a render_rows function in the helper to handle it.
- Added toggle all to sync management page.
- Removal of schedule reboot and uptime from systems detail.
- Adds to the custom system list display to show additional details within a
  system information block.  Follows the three column convention placing
  details in a particular column.
- Added new css class to lists that are supposed to be ajax scrollable to
  provide better support across variations of ajax scroll usage.
- Change to fix empty columns in the left panel from being displayed without
  width and causing column misalignment.
- Changes system list to display registered and last checkin date as main
  column headers.  Switches from standard column rendering to use custom column
  rendering function via custom_columns in the systems helper module.
- Adds new option to the two panel display, :custom_columns, whereby a function
  name can be passed that will do the work of rendering the columns in the left
  side of the panel.  This is for cases when column data needs custom
  manipulation or data rows need a customized look and feel past the standard
  table look and feel.
- Made an initializer change so that cp_type is handled right
- Updated a test to create tmp dir unless it exists
- Fixed the provider_spec to actually test if the subscriptions called the
  right thing in candlepin
- fixing sql error to hopefully work with postgresql
- adding missing permission for sync_schedules
- using a better authenication checking query with some more tests
- migrating anonymous_role to not user ar_
- a couple more roles fixes
- changing roles to not populate nil resource types or nil tags
- Added spec tests for notices_controller.
- adding missing operations resource_type to seeds
- changing the roles subsystem to use the same types/verbs for active record
  and controller access
- removing old roles that were adding errant types to the database
- fixing odd sudden broken path link, possibly due to rails upgrade
- adding back subscriptions to provider filter

* Fri Jun 17 2011 Justin Sherrill <jsherril@redhat.com> 0.1.48-1
- removing hudson task during rpm building (jsherril@redhat.com)
- added api repository controller tests for repository discovery
  (dmitri@redhat.com)
- Search - adding some spec tests (bbuckingham@redhat.com)
- Removed improper test case from systems controller. (ehelms@redhat.com)
- Added systems_controller spec tests for wider coverage. (ehelms@redhat.com)
- Added system_helper_methods for spec testing that mocks the backend
  Candlepin:Consumer call to allow for controller testing against ActiveRecord.
  (ehelms@redhat.com)
- adding qunit test files for testswarm server (shughes@scooby.rdu.redhat.com)
- 6489: added support for repository discovery during custom product creation
  (dmitri@appliedlogic.ca)
- forcing a Require when task runs, doesnt seem to pick it up otherwise
  (katello-devel@redhat.com)
- testing taking out the ci_reports section for now (katello-devel@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (adprice@redhat.com)
- added specs to test against fix for bug #701406 (adprice@redhat.com)
- Fixed the unit tests for sync schedule controller (paji@redhat.com)
- converting some legacy role work arounds to the new role map in role.rb
  (jsherril@redhat.com)
- adding missing katello.yml (jsherril@redhat.com)
- 701406 - fixed issue where api was looking for org via displayName instead of
  key (adprice@redhat.com)

* Thu Jun 16 2011 Justin Sherrill <jsherril@redhat.com> 0.1.47-1
- initial public build

* Tue Jun 14 2011 Mike McCune <mmccune@redhat.com> 0.1.46-1
- initial changelog
