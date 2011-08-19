%define ruby_sitelib %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")
%define gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)

%global homedir %{_datarootdir}/%{name}
%global datadir %{_sharedstatedir}/%{name}
%global confdir extras/fedora

Name:           katello
Version:	      0.1.65
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
install -m 644 config/database.yml %{buildroot}%{_sysconfdir}/%{name}/database.yml
install -m 644 config/environments/production.rb %{buildroot}%{_sysconfdir}/%{name}/environment.rb

#copy init scripts and sysconfigs
install -Dp -m0644 %{confdir}/%{name}.sysconfig %{buildroot}%{_sysconfdir}/sysconfig/%{name}
install -Dp -m0755 %{confdir}/%{name}.init %{buildroot}%{_initddir}/%{name}
install -Dp -m0755 %{confdir}/%{name}-jobs.init %{buildroot}%{_initddir}/%{name}-jobs
install -Dp -m0644 %{confdir}/%{name}.completion.sh %{buildroot}%{_sysconfdir}/bash_completion.d/%{name}
install -Dp -m0644 %{confdir}/%{name}.logrotate %{buildroot}%{_sysconfdir}/logrotate.d/%{name}

#overwrite config files with symlinks to /etc/katello
ln -svf %{_sysconfdir}/%{name}/katello.yml %{buildroot}%{homedir}/config/katello.yml
ln -svf %{_sysconfdir}/%{name}/database.yml %{buildroot}%{homedir}/config/database.yml
ln -svf %{_sysconfdir}/%{name}/environment.rb %{buildroot}%{homedir}/config/environments/production.rb

#create symlinks for some db/ files
ln -svf %{datadir}/schema.rb %{buildroot}%{homedir}/db/schema.rb

#create symlinks for data
ln -sv %{_localstatedir}/log/%{name} %{buildroot}%{homedir}/log
ln -sv %{datadir}/tmp %{buildroot}%{homedir}/tmp

#create symlink for Gemfile.lock (it's being regenerated each start)
ln -svf %{datadir}/Gemfile.lock %{buildroot}%{homedir}/Gemfile.lock

#re-configure database to the /var/lib/katello directory
sed -Ei 's/\s*database:\s+db\/(.*)$/  database: \/var\/lib\/katello\/\1/g' %{buildroot}%{_sysconfdir}/%{name}/database.yml

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
%config(noreplace) %{_sysconfdir}/%{name}/database.yml
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
