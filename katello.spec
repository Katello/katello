%define ruby_sitelib %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")
%define gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)

%global homedir %{_datarootdir}/%{name}
%global datadir %{_sharedstatedir}/%{name}
%global confdir extras/fedora

Name:           katello
Version:	      0.1.77
Release:	      1%{?dist}
Summary:	      A package for managing application life-cycle for Linux systems
	
Group:          Applications/Internet
License:        GPLv2
URL:            http://www.katello.org
Source0:        %{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

Requires:       pulp
Requires:       openssl
Requires:       candlepin-tomcat6
Requires:       rubygems
Requires:       rubygem(rails) >= 3.0.5
Requires:       rubygem(multimap)
Requires:       rubygem(haml) >= 3.1.2
Requires:       rubygem(haml-rails)
Requires:       rubygem(json)
Requires:       rubygem(rest-client)
Requires:       rubygem(jammit)
Requires:       rubygem(rails_warden)
Requires:       rubygem(net-ldap)
Requires:       rubygem(compass) >= 0.11.5
Requires:       rubygem(compass-960-plugin) >= 0.10.4
Requires:       rubygem(capistrano)
Requires:       rubygem(oauth)
Requires:       rubygem(i18n_data) >= 0.2.6
Requires:       rubygem(gettext_i18n_rails)
Requires:       rubygem(simple-navigation) >= 3.3.4
Requires:       rubygem(sqlite3) 
Requires:       rubygem(pg)
Requires:       rubygem(scoped_search) >= 2.3.1
Requires:       rubygem(delayed_job) >= 2.1.4
Requires:       rubygem(daemons) >= 1.1.4
Requires:       rubygem(uuidtools)

# <workaround> for 714167 - undeclared dependencies (regin & multimap)
Requires:       rubygem(regin)
# </workaround>

Requires(pre):  shadow-utils
Requires(preun): chkconfig
Requires(preun): initscripts
Requires(post): chkconfig
Requires(postun): initscripts 

BuildRequires: 	coreutils findutils sed
BuildRequires: 	rubygems
BuildRequires:  rubygem-rake
BuildRequires:  rubygem(gettext)
BuildRequires:  rubygem(jammit)
BuildRequires:  rubygem(compass) >= 0.11.5
BuildRequires:  rubygem(compass-960-plugin) >= 0.10.4

BuildArch: noarch

%description
Provides a package for managing application life-cycle for Linux systems

%prep
%setup -q

%build
#configure Bundler
rm -f Gemfile.lock
sed -i '/@@@DEV_ONLY@@@/,$d' Gemfile
#compile SASS files
echo Compiling SASS files...
compass compile

#generate Rails JS/CSS/... assets
echo Generating Rails assets...
jammit

#create mo-files for L10n (since we miss build dependencies we can't use #rake gettext:pack)
echo Generating gettext files...
ruby -e 'require "rubygems"; require "gettext/tools"; GetText.create_mofiles(:po_root => "locale", :mo_root => "locale")'

%install
rm -rf %{buildroot}
#prepare dir structure
install -d -m0755 %{buildroot}%{homedir}
install -d -m0755 %{buildroot}%{datadir}
install -d -m0755 %{buildroot}%{datadir}/tmp
install -d -m0755 %{buildroot}%{_sysconfdir}/%{name}
install -d -m0755 %{buildroot}%{_localstatedir}/log/%{name}

# clean the application directory before installing
[ -d tmp ] && rm -rf tmp

#copy the application to the target directory
mkdir .bundle
mv ./extras/bundle-config .bundle/config
cp -R .bundle * %{buildroot}%{homedir}

#copy configs and other var files (will be all overwriten with symlinks)
install -m 644 config/%{name}.yml %{buildroot}%{_sysconfdir}/%{name}/%{name}.yml
#install -m 644 config/database.yml %{buildroot}%{_sysconfdir}/%{name}/database.yml
install -m 644 config/environments/production.rb %{buildroot}%{_sysconfdir}/%{name}/environment.rb

#copy init scripts and sysconfigs
install -Dp -m0644 %{confdir}/%{name}.sysconfig %{buildroot}%{_sysconfdir}/sysconfig/%{name}
install -Dp -m0755 %{confdir}/%{name}.init %{buildroot}%{_initddir}/%{name}
install -Dp -m0755 %{confdir}/%{name}-jobs.init %{buildroot}%{_initddir}/%{name}-jobs
install -Dp -m0644 %{confdir}/%{name}.completion.sh %{buildroot}%{_sysconfdir}/bash_completion.d/%{name}
install -Dp -m0644 %{confdir}/%{name}.logrotate %{buildroot}%{_sysconfdir}/logrotate.d/%{name}

#overwrite config files with symlinks to /etc/katello
ln -svf %{_sysconfdir}/%{name}/katello.yml %{buildroot}%{homedir}/config/katello.yml
#ln -svf %{_sysconfdir}/%{name}/database.yml %{buildroot}%{homedir}/config/database.yml
ln -svf %{_sysconfdir}/%{name}/environment.rb %{buildroot}%{homedir}/config/environments/production.rb

#create symlinks for some db/ files
ln -svf %{datadir}/schema.rb %{buildroot}%{homedir}/db/schema.rb

#create symlinks for data
ln -sv %{_localstatedir}/log/%{name} %{buildroot}%{homedir}/log
ln -sv %{datadir}/tmp %{buildroot}%{homedir}/tmp

#create symlink for Gemfile.lock (it's being regenerated each start)
ln -svf %{datadir}/Gemfile.lock %{buildroot}%{homedir}/Gemfile.lock

#re-configure database to the /var/lib/katello directory
sed -Ei 's/\s*database:\s+db\/(.*)$/  database: \/var\/lib\/katello\/\1/g' %{buildroot}%{homedir}/config/database.yml

#remove files which are not needed in the homedir
rm -rf %{buildroot}%{homedir}/README
rm -rf %{buildroot}%{homedir}/LICENSE
rm -rf %{buildroot}%{homedir}/doc
rm -rf %{buildroot}%{homedir}/extras
rm -rf %{buildroot}%{homedir}/%{name}.spec
rm -f %{buildroot}%{homedir}/lib/tasks/.gitkeep
rm -f %{buildroot}%{homedir}/public/stylesheets/.gitkeep
rm -f %{buildroot}%{homedir}/vendor/plugins/.gitkeep

#remove development tasks
rm %{buildroot}%{homedir}/lib/tasks/rcov.rake
rm %{buildroot}%{homedir}/lib/tasks/yard.rake
rm %{buildroot}%{homedir}/lib/tasks/hudson.rake

#correct permissions
find %{buildroot}%{homedir} -type d -print0 | xargs -0 chmod 755
find %{buildroot}%{homedir} -type f -print0 | xargs -0 chmod 644
chmod +x %{buildroot}%{homedir}/script/*

%clean
rm -rf %{buildroot}

%post
%{homedir}/script/reset-oauth

#Add /etc/rc*.d links for the script
/sbin/chkconfig --add %{name}

%postun
if [ "$1" -ge "1" ] ; then
    /sbin/service %{name} condrestart >/dev/null 2>&1 || :
fi

%files
%defattr(-,root,root)
%doc README LICENSE doc/
%config(noreplace) %{_sysconfdir}/%{name}/%{name}.yml
%config %{_sysconfdir}/%{name}/environment.rb
%config %{_sysconfdir}/logrotate.d/%{name}
%config(noreplace) %{_sysconfdir}/sysconfig/%{name}
%{_initddir}/%{name}
%{_initddir}/%{name}-jobs
%{_sysconfdir}/bash_completion.d/%{name}
%{homedir}

%defattr(-, katello, katello)
%{_localstatedir}/log/%{name}
%{datadir}

%pre
# Add the "katello" user and group
getent group %{name} >/dev/null || groupadd -r %{name}
getent passwd %{name} >/dev/null || \
    useradd -r -g %{name} -d %{homedir} -s /sbin/nologin -c "Katello" %{name}
exit 0

%preun
if [ $1 -eq 0 ] ; then
    /sbin/service %{name} stop >/dev/null 2>&1
    /sbin/chkconfig --del %{name}
fi

%changelog
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
- templates - it is possible to create/edit only templates in the locker -
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
- Pulp repo for Locker products consistent with other envs
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
- repo sync - check for syncing only repos in locker
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
- General UI - disable hover on Locker when Locker not clickable
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
