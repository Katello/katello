%define ruby_sitelib %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")
%define gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)

%global homedir %{_prefix}/lib/%{name}
%global datadir %{_sharedstatedir}/%{name}
%global confdir extras/fedora

Name:       katello		
Version:	0.1.49
Release:	2%{?dist}
Summary:	A package for managing application lifecycle for Linux systems
	
Group:          Internet/Applications
License:        GPLv2
URL:            http://redhat.com
Source0:        %{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

Requires:       pulp
Requires:       openssl
Requires:       candlepin-tomcat6
Requires:       rubygems
Requires:       rubygem(rails) >= 3.0.5
Requires:       rubygem(multimap)
Requires:       rubygem(haml) >= 3.0.16
Requires:       rubygem(haml-rails)
Requires:       rubygem(json)
Requires:       rubygem(rest-client)
Requires:       rubygem(jammit)
Requires:       rubygem(rails_warden)
Requires:       rubygem(net-ldap)
Requires:       rubygem(compass) >= 0.11.5
Requires:       rubygem(compass-960-plugin) >= 0.10.0
Requires:	rubygem(sass) => 3.1
Requires:	rubygem(sass) < 4
Requires:	rubygem(chunky_png) => 1.2
Requires:	rubygem(chunky_png) < 2
Requires:	rubygem(fssm) >= 0.2.7
Requires:       rubygem(capistrano)
Requires:       rubygem(oauth)
Requires:       rubygem(i18n_data) >= 0.2.6
Requires:       rubygem(gettext_i18n_rails)
Requires:       rubygem(simple-navigation) >= 3.1.0
Requires:       rubygem(sqlite3) 
Requires:       rubygem(pg)
Requires:       rubygem(scoped_search) >= 2.3.1
Requires:       rubygem(delayed_job) >= 2.1.4
Requires:       rubygem(daemons) >= 1.1.4
Requires:       rubygem(uuidtools)

Requires(pre):  shadow-utils
Requires(preun): chkconfig
Requires(preun): initscripts
Requires(post): chkconfig
Requires(postun): initscripts 

BuildRequires: 	coreutils findutils sed
BuildRequires: 	rubygems
BuildRequires:  rubygem-rake
BuildRequires:  rubygem(gettext)

BuildArch: noarch

%description
Provides a package for managing application lifecycle for Linux systems

%prep
%setup -q

%build
#create mo-files for L10n (since we miss build dependencies we can't use #rake gettext:pack)
echo Generating gettext files...
ruby -e 'require "rubygems"; require "gettext/tools"; GetText.create_mofiles(:po_root => "locale", :mo_root => "locale")'

%install
rm -rf %{buildroot}
#prepare dir structure
install -d -m0755 %{buildroot}%{homedir}
install -d -m0755 %{buildroot}%{datadir}
install -d -m0755 %{buildroot}%{datadir}/public-assets
install -d -m0755 %{buildroot}%{datadir}/public-compiled-stylesheets
install -d -m0755 %{buildroot}%{_sysconfdir}/%{name}
install -d -m0750 %{buildroot}%{_localstatedir}/log/%{name}

#copy the application to the target directory
mkdir .bundle
mv ./extras/bundle-config .bundle/config
cp -R .bundle * %{buildroot}%{homedir}

#copy configs and other var files (will be all overwriten with symlinks)
install -m 644 config/%{name}.yml %{buildroot}%{_sysconfdir}/%{name}/%{name}.yml
install -m 644 config/database.yml %{buildroot}%{_sysconfdir}/%{name}/database.yml
install -m 644 config/environments/production.rb %{buildroot}%{_sysconfdir}/%{name}/prod_env.rb
install -m 644 config/environments/development.rb %{buildroot}%{_sysconfdir}/%{name}/dev_env.rb

#copy init scripts and sysconfigs
install -Dp -m0644 %{confdir}/%{name}.sysconfig %{buildroot}%{_sysconfdir}/sysconfig/%{name}
install -Dp -m0755 %{confdir}/%{name}.init %{buildroot}%{_initrddir}/%{name}
install -Dp -m0644 %{confdir}/%{name}.completion.sh %{buildroot}%{_sysconfdir}/bash_completion.d/%{name}
install -Dp -m0644 %{confdir}/%{name}.logrotate %{buildroot}%{_sysconfdir}/logrotate.d/%{name}

#overwrite config files with symlinks to /etc/katello
ln -svf %{_sysconfdir}/%{name}/katello.yml %{buildroot}%{homedir}/config/katello.yml
ln -svf %{_sysconfdir}/%{name}/database.yml %{buildroot}%{homedir}/config/database.yml
ln -svf %{_sysconfdir}/%{name}/prod_env.rb %{buildroot}%{homedir}/config/environments/production.rb
ln -svf %{_sysconfdir}/%{name}/dev_env.rb %{buildroot}%{homedir}/config/environments/development.rb

#create symlinks for some db/ files
ln -svf %{datadir}/schema.rb %{buildroot}%{homedir}/db/schema.rb

#create symlinks for data
ln -sv %{_localstatedir}/log/%{name} %{buildroot}%{homedir}/log
ln -sv %{_tmppath} %{buildroot}%{homedir}/tmp
ln -sv %{datadir}/public-assets %{buildroot}%{homedir}/public/assets
ln -sv %{datadir}/public-compiled-stylesheets %{buildroot}%{homedir}/public/stylesheets/compiled

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
%config(noreplace) %{_sysconfdir}/%{name}/prod_env.rb
%config(noreplace) %{_sysconfdir}/%{name}/dev_env.rb
%config(noreplace) %{_sysconfdir}/logrotate.d/%{name}
%config(noreplace) %{_sysconfdir}/sysconfig/%{name}
%{_initddir}/%{name}
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
* Fri Jul 15 2011 Eric D Helms <eric.d.helms@gmail.com> 0.1.49-2
- Updates to use version 0.11.5 or greater of Compass. (eric.d.helms@gmail.com)
- Adds padding to empty changeset text. (eric.d.helms@gmail.com)
- Merge branch 'master' into refactor (eric.d.helms@gmail.com)
- initdb does not print unnecessary info anymore (lzap+git@redhat.com)
- ignoring ping.rb in code coverage (lzap+git@redhat.com)
- do not install .gitkeep files (msuchy@redhat.com)
- setting failure threshold to code coverage to 60 % (lzap+git@redhat.com)
- adding failure threshold to code doverage (lzap+git@redhat.com)
- 720414 - fixing issue where hitting enter while on the new changeset name box
  would result in a form submitting (jsherril@redhat.com)
- get unit tests working with rconv (lzap+git@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (adprice@redhat.com)
- spec test fix (jsherril@redhat.com)
- improving env_selector to auto-select the path properly so the controller
  doesnt have to (jsherril@redhat.com)
- fixing the env_selector to properly display secondary paths, this broke at
  some point (jsherril@redhat.com)
- system info - adding /api/systems/:uuid/packages controller
  (lzap+git@redhat.com)
- ignoring coverage/ dir (lzap+git@redhat.com)
- merging systems resource in the routes into one (lzap+git@redhat.com)
- Merge branch 'master' into templates (adprice@redhat.com)
- fixing broken unit tests (jsherril@redhat.com)
- 720431 - fixing issue where creating a changeset that already exists would
  fail silently (jsherril@redhat.com)
- fixing stray comman in promotion.js (jsherril@redhat.com)
- Merge branch 'master' into refactor (eric.d.helms@gmail.com)
- added ability to track pulp async jobs through katello task api
  (dmitri@redhat.com)
- updating localization strings for zanata server (shughes@redhat.com)
- removing katello_client.js from assets and removing inclusions in all haml
  files (jsherril@redhat.com)
- refactoring javascript to get rid of katello_client.js (jsherril@redhat.com)
- changing level inclusion validator of notices to handle the string forms of
  the types, so a notice can actually be saved if modified
  (jsherril@redhat.com)
- 717714: adding friendly sync conflict messaging (shughes@redhat.com)
- remove js debug alerts from sync (shughes@redhat.com)
- refactoring environment creation/deleteion in javascript to not use
  katello_client.js (jsherril@redhat.com)
- refactoring role.js to be more modular and not have global functions
  (jsherril@redhat.com)
- Added permission enforcement for all_verbs and all_tags (paji@redhat.com)
- system info - systems list now supports name query param
  (lzap+git@redhat.com)
- auto_complete_search - move routes in to collection blocks
  (bbuckingham@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (mmccune@redhat.com)
- adding spec test (mmccune@redhat.com)
- hopefully done changing 'locker' to 'Locker' (adprice@redhat.com)
- CSS Refactor - more cleanup and removal of old unused css.
  (ehelms@redhat.com)
- adding tests for listing templates (adprice@redhat.com)
- CSS Refactor - Large scale cleanup of old CSS. Moved chunks of css to the
  appropriate page level css files. (ehelms@redhat.com)
- Merge branch 'master' into templates (adprice@redhat.com)
- cleanup of user.js and affected views/routes (jsherril@redhat.com)
- reworking template list to work with existing code in client
  (adprice@redhat.com)
- 715422: update sync mgt status method and routes to use non reserved name
  (shughes@redhat.com)
- 713959: add 'none' interval type to sync plan edit, add rspec test
  (shughes@redhat.com)
- spec path test for promotions env (shughes@redhat.com)
- rspec for systems environment selections (shughes@redhat.com)
- env selector for systems and env model refactor (shughes@redhat.com)
- add new route and trilevel nav for registered systems (shughes@redhat.com)
- env selector support for systems listing (shughes@redhat.com)
- fixed a broken test (dmitri@redhat.com)
- added ability to persist results of async operations (dmitri@redhat.com)
- Merge branch 'master' into refactor (ehelms@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (ehelms@redhat.com)
- fix for env-selector not selecting the correct path if an environment is
  selected (jsherril@redhat.com)
- CSS Refactor - Combines all the css for the environment selector into sass
  nesting format. (ehelms@redhat.com)
- Merge branch 'master' into org-subs (mmccune@redhat.com)
- added requirement of org and env when listing templates via api
  (adprice@redhat.com)
- CSS Refactor - converts all color variables to end in _color for readability
  and organization. (ehelms@redhat.com)
- CSS Refactor - Moved each section stylesheet into a sections folder. Removed
  all colors from _base and moved them into a _colors css file. Re-named _base
  to _mixins as a place to define and have project wide css mixins. Moved all
  imports to katello.scss and it is now being treated as the base level scss
  import. (ehelms@redhat.com)
- CSS Refactor - Moves all basic css imports to base (e.g. grid, text, sprits).
  Removes katello.css directly from page, and instead each section css file
  (e.g. contents, dashboard) imports katello.scss.  The intent is for
  katello.scss to hold cross-app and re-usable css while each individual
  section scss file will hold overrides and custom css. (ehelms@redhat.com)
- CSS Refactor - Moves icon and image sprites out to seperate file for easier
  reference and to aid in any future spriting. (ehelms@redhat.com)
- Commits missing file to stop Jammit warning. (ehelms@redhat.com)
- Notifications polling time increased to 2 minutes. Small fix for
  subscriptions helptip. (jrist@redhat.com)
- Provider - update controller to query based on current org
  (bbuckingham@redhat.com)
- added optional functionality for org and environment inclusion in template
  viewing (adprice@redhat.com)
- 720003 - moves page load notifications inside document ready function to
  properly display across browsers (ehelms@redhat.com)
- 720002 - Adds generic css file for notification page to conform with css file
  for each main page. (ehelms@redhat.com)
- fixed tests broken by async job merge (dmitri@redhat.com)
- removed a bit of async job sample code from api/systems_controller
  (dmitri@redhat.com)
- merging async job status tracking changes into master (dmitri@redhat.com)
- uuid value is now being stored in Delayed::Job uuid field (dmitri@redhat.com)
- added uuidtools gem requirements into Gemfile and katello.spec
  (dmitri@redhat.com)
- added uuids to track status of async jobs (dmitri@redhat.com)
- spec - moving syntax checks to external script (CI) (lzap+git@redhat.com)
- users - better logging during authentication (lzap+git@redhat.com)
- users - updating bash completion (lzap+git@redhat.com)
- users - adding support for users CRUD in CLI (lzap+git@redhat.com)
- api auth code stores user/pass with auth_ prefix (lzap+git@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (ehelms@redhat.com)
- Added missing loginpage css file. (ehelms@redhat.com)
- add daemons gem dep for delayed job (shughes@redhat.com)
- Adds section in head of katello.yml for including extra javascripts from a
  template view.  This is intended to move included javascripts out of the
  body. (ehelms@redhat.com)
- Moves locked icon on breadcrumbs next to the changeset name instead of at the
  front of the breadcrumb list. (ehelms@redhat.com)
- Moves subheader, maincontent and footer up a few pixels. (ehelms@redhat.com)
- Adds new option to sliding tree - base_icon for displaying an image as the
  first breadcrumb instead of text. Modifies changeset breadcrumbs to use home
  icon for first breadcrumb. (ehelms@redhat.com)
- fixed a config issue with delayed jobs (dmitri@redhat.com)
- delayed jobs are now associated with organizations (dmitri@redhat.com)
- Adds big logo to empty dashboard page. (ehelms@redhat.com)
- first cut at tracking of async jobs (dmitri@redhat.com)
- Adding breadcrumb icon sprite. (jimmac@gmail.com)
- speed up header spinner, more style-appropriate grabber (jimmac@gmail.com)
- Added whitespace on the sides of help-tips looks very unbalanced.
  (jimmac@gmail.com)
- Same spinner for the header as it is in the body. Might need to invert to
  white. (jimmac@gmail.com)
- Update header to the latest upstream design. (jimmac@gmail.com)
- clean up favicon. (jimmac@gmail.com)
- 719414 - changest:  New changeset view now returns message instructing user
  that a changeset cannot be created if a next environment is not present for
  the current environment. (ehelms@redhat.com)
- continuing to fix capital 'Locker' (adprice@redhat.com)
- spec - more tests for permissions (super admin) (lzap+git@redhat.com)
- spec - making permission_spec much faster (lzap+git@redhat.com)
- adding new spec tests for promotions controller (jsherril@redhat.com)
- Fix copyright on several files (bbuckingham@redhat.com)
- fixed an error in katello.spec (dmitri@redhat.com)
- fixing changeset deletion client side (jsherril@redhat.com)
- fixing odd promotions button issues caused by removing the default changeset
  upon environment creation (jsherril@redhat.com)
- Merge branch 'errors' (dmitri@redhat.com)
- added delayed_job gem dependency (dmitri@redhat.com)
- 2pane column sorter module helper for controllers (shughes@redhat.com)
- Provider - Update so that 'remove provider' link is accessible from subpanels
  (bbuckingham@redhat.com)
- errors are now being returned in an array, under :errors hash key
  (dmitri@redhat.com)
- Merge branch 'promotions' (jsherril@redhat.com)
- removing the automatic creating of changesets, since you can now create them
  manually (jsherril@redhat.com)
- prompting the user if they are leaving the promotions page with unsaved
  changeset changes (jsherril@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- Makes current crumb different color than the rest of the breadcrumbs. Adds
  highlighting of list items in changeset trees. (ehelms@redhat.com)
- added delayed_job gem dependency (dmitri@redhat.com)
- adding wait dialog when switching out of a changeset if updates are left to
  process (jsherril@redhat.com)
- update po files for translation (shughes@redhat.com)
- Fixes lock image location when changeset is being promoted and breadcrumbs
  attempt to wrap. (ehelms@redhat.com)
- Re-works scroll mechanism in sliding tree to handle left-right scrolling with
  container of any height or fixed height containers that need scrollable
  overflow. (ehelms@redhat.com)
- remove flies config (shughes@redhat.com)
- adding waiting indicator prior to review if there is still items to process
  in the queue (jsherril@redhat.com)
- Promotion page look and feel changes. Border and background colors of left
  and right panels changed. Border color of search filter changed.
  (ehelms@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- Merge branch 'master' into sso-prototype (bbuckingham@redhat.com)
- fixing issue where adding a partial product after a full product would result
  in not being able to browse the partial product (jsherril@redhat.com)
- Merge branch 'master' into url_format (adprice@redhat.com)
- Added default env upon entering changeset history page. (jrist@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (jrist@redhat.com)
- Ajax listing and searching on Changeset History page. (jrist@redhat.com)
- SSO - prototype - additional mods for error handling (bbuckingham@redhat.com)
- Login - fix error message when user logs in with invalid credentials
  (bbuckingham@redhat.com)
- SSO - update warden for HTTP_X_FORWARDED_USER (bbuckingham@redhat.com)
- added support for sso auth in ui and api controllers (dmitri@redhat.com)
- fixing issue where promotion would redirect to the incorrect environment
  (jsherril@redhat.com)
- updated katello url format validator with port number options.
  (adprice@redhat.com)
- Initial promotion QUnit page tests. (ehelms@redhat.com)
- fixing issue where creating a changeset make it appear to be locked
  (jsherril@redhat.com)
- added more tests around system registration with environments
  (dmitri@redhat.com)
- fixed a bunch of failing tests (dmitri@redhat.com)
- got rhsm client mostly working with system registration with environments
  (dmitri@redhat.com)
- fixed merging conflicts (dmitri@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (jrist@redhat.com)
- In-place search for changesets. (jrist@redhat.com)
- fixing previous notices change to work with polling as well, and work around
  issue whith update after a query would result in the query not actually
  returning anything retroactively (jsherril@redhat.com)
- fixing promotions redirection and notices not actually rendering properly on
  page load (jsherril@redhat.com)
- added/modified some tests and fixed a typo (adprice@redhat.com)
- removed unused code after commenting on a previous commit.
  (adprice@redhat.com)
- 703528 - checks provider url for valid format (adprice@redhat.com)
- templates - tests for controller (tstrachota@redhat.com)
- templates - tests for the model (tstrachota@redhat.com)
- added api-namespace resource discovery (dmitri@redhat.com)
- Role: sort permission type alphabetically (bbuckingham@redhat.com)
- stop changeset modifications when changeset is in the correct state
  (jsherril@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- Splits product list in changeset into Full Products and Partial Products.
  Full Products can be removed but Partial Products cannot. (ehelms@redhat.com)
- adding next environment name to promote button (jsherril@redhat.com)
- fixing text vs varchar problem on pgsql (lzap+git@redhat.com)
- roles - disabled flag is now in effect (lzap+git@redhat.com)
- roles - adding disabled flag to users (lzap+git@redhat.com)
- possibility to run rake setup without REST interaction (lzap+git@redhat.com)
- roles - adding description column to roles (lzap+git@redhat.com)
- roles - role name may contain spaces now (lzap+git@redhat.com)
- roles - self-roles now named 'username_salt' (lzap+git@redhat.com)
- roles - giving fancy names to basic roles (lzap+git@redhat.com)
- roles - superadmin role allowed by default, new reader role
  (lzap+git@redhat.com)
- roles - setting permissions rather on superadmin role than admin self-role
  (lzap+git@redhat.com)
- roles - reordering and cleaning seeds.rb (lzap+git@redhat.com)
- templates - added foreign key reference to environments
  (tstrachota@redhat.com)
- navigation for subscriptions page (mmccune@redhat.com)
- Merge branch 'org-subs' of ssh://git.fedorahosted.org/git/katello into org-
  subs (mmccune@redhat.com)
- Added Expand/Contract All (jrist@redhat.com)
- Fix for firt-child of TD not being aligned properly with expanding tree.
  (jrist@redhat.com)
- Merge branch 'master' into org-subs (mmccune@redhat.com)
- making the resizable panel not resizable for promotions (jsherril@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- fixing callback call that was cuasing lots of issues with promotions
  (jsherril@redhat.com)
- Fixes issue with multiple icons appearing in changeset breadcrumbs.
  (ehelms@redhat.com)
- Merge branch 'master' into url_format (adprice@redhat.com)
- 718054: updating gem requirements to match Gemfile versions
  (shughes@redhat.com)
- update to get sparklines going (mmccune@redhat.com)
- added spec for api/systems_controller (dmitri@redhat.com)
- force 2.3.1 version of scoped search for katello installs; supports sorting
  (shughes@redhat.com)
- Small fix for breadcrumb not expanding to full height. (jrist@redhat.com)
- Fixed #changeset_tree moving over when scrolling. (jrist@redhat.com)
- moved find_organization() method from api controllers into API_Controller and
  fixed some associated tests. (adprice@redhat.com)
- Small fix for closing filter. (jrist@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (jrist@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (jrist@redhat.com)
- fixed broken tests (dmitri@redhat.com)
- 703528 - checks provider url for valid format (adprice@redhat.com)
- fixing  issue with promotions page and no environment after locker
  (jsherril@redhat.com)
- adding additional javascript and removing debugger (mmccune@redhat.com)
- Filter working on right changeset for current .has_content selector.
  (jrist@redhat.com)
- updating gemlock for scoped_search changes (shughes@redhat.com)
- sorting systems on both ar/non ar data from cp (shughes@redhat.com)
- scoped_search gem support for column sorting (shughes@redhat.com)
- 2pane support for AR/NONAR column sorting (shughes@redhat.com)
- Merge branch 'master' into roles (bbuckingham@redhat.com)
- fixing issue where adding a package to a changeset for a product that doesnt
  exist would not setup the breadrumb and changeset properly
  (jsherril@redhat.com)
- adding summary of changeset to promotions page (jsherril@redhat.com)
- superadmin columnt in role model (lzap+git@redhat.com)
- ownergeddon - fixing unit tests (lzap+git@redhat.com)
- renaming Candlepin::User to CPUser (lzap+git@redhat.com)
- ownergeddon - organization now belogs to user who created it
  (lzap+git@redhat.com)
- fixing User vs candlepin User reference (lzap+git@redhat.com)
- ownergeddon - superadmin role has access to all orgs (lzap+git@redhat.com)
- ownergeddon - creating superadmin role (lzap+git@redhat.com)
- ownergeddon - removing special user creation (lzap+git@redhat.com)
- changing org-user relationship to plural (lzap+git@redhat.com)
- Adds new button look and feel to errata and repos. (ehelms@redhat.com)
- Typo fix that prevented changeset creation in the UI. (ehelms@redhat.com)
- Fixes broken changeset creation. (ehelms@redhat.com)
- Roles - spec fix: self-role naming no longer dependent on user name
  (bbuckingham@redhat.com)
- Re-refactoring of templateLibrary to remove direct references to
  promotion_page. (ehelms@redhat.com)
- Adds back missing code that makes the right side changeset panel scroll along
  with page. (ehelms@redhat.com)
- 704577 - Role - delete self-role on user delete (bbuckingham@redhat.com)
- Converts promotion_page object into module pattern. (ehelms@redhat.com)
- getting client side sorting working again on the promotions page
  (jsherril@redhat.com)
- moved find_organization() method from api controllers into API_Controller and
  fixed some associated tests. (adprice@redhat.com)
- 717368 - fixing issue where the environment picker would not properly show
  the environment you were on if that environment had no successor
  (jsherril@redhat.com)
- moving changeset buttons to only show up if changesets exist
  (jsherril@redhat.com)
- added support for system registration to an environment in an organization
  (dmitri@redhat.com)
- 704632 -speeding up role rendering (jsherril@redhat.com)
- Roles - update seeds to account for changes to self-role naming
  (bbuckingham@redhat.com)
- Roles - fix delete of user from Roles & Perms tab (bbuckingham@redhat.com)
- Merge branch 'master' into org-subs (mmccune@redhat.com)
- adding locking icons to the changeset list and the breadcrumb bar
  (jsherril@redhat.com)
- including statistics at the org level, pulled in from Headpin
  (mmccune@redhat.com)
- Merge branch 'master' into roles (bbuckingham@redhat.com)
- Changeset list now returns to list of products for that changeset if an item
  removal renders no errata, no repos and no packages for that product and
  removes the product from the list. (ehelms@redhat.com)
- User - self-role name - update to be random generated string
  (bbuckingham@redhat.com)
- Changes promotion page slide_link icon. (ehelms@redhat.com)
- Merge branch 'master' into roles (bbuckingham@redhat.com)
- fixed providers page where promotions link looked up 'locker' instead of
  'Locker' (adprice@redhat.com)
- Roles - refactor self-roles to associated directly with a user
  (bbuckingham@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- Changes to Add/Remove button look and feel across promotion pages.
  (ehelms@redhat.com)
- Add an icon for the promotions page breadcrumb. (jimmac@gmail.com)
- making promotion actually work again (jsherril@redhat.com)
- cleaning up some of katello_client.js (jsherril@redhat.com)
- restriciting promotion based off changeset state (jsherril@redhat.com)
- ownergeddon - adding /users/:username/owners support for sm
  (lzap+git@redhat.com)
- correcting identation in two haml files (lzap+git@redhat.com)
- spec - enabling verbose mode for syntax checking (lzap+git@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- Re-removing previously removed file that got added back by merge.
  (ehelms@redhat.com)
- Merge commit 'eb9c97b3c5b1b1174e3ba4c732690068c9f81f3a' into promotions
  (ehelms@redhat.com)
- adding callback for extended scroll so we can properly reset the page
  (jsherril@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into grid
  (ehelms@redhat.com)
- hiding left hand buttons if changeset is in review phase
  (jsherril@redhat.com)
- Adds data-product_id field to all products for consistency with other
  function calls in promotionjs and fixes adding a product. (ehelms@redhat.com)
- making a locked changeset look different, and not showing add/remove buttons
  on the right if the changeset is locked (jsherril@redhat.com)
- fixing unit tests because of pwd hashing (lzap+git@redhat.com)
- global access to Rake DSL methods is deprecated (lzap+git@redhat.com)
- passwords are stored in secure format (lzap+git@redhat.com)
- default password for admin is 'admin' (lzap+git@redhat.com)
- 717554 - NoMethodError in User sessionsController#create
  (lzap+git@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (jrist@redhat.com)
- Changesets - filter dropdown - initial work on changeset history (might not
  be functional yet). (jrist@redhat.com)
- additional columns added and proper data displayed on page
  (mmccune@redhat.com)
- getting  review/cancel working properly (jsherril@redhat.com)
- listing of systems by environment works now (dmitri@redhat.com)
- specs for changeset controller updates, changesetusers (shughes@redhat.com)
- fixing issue where odd changeset concurrency issue was being taken into
  account even when ti didnt exist (jsherril@redhat.com)
- jquery, css changes for changeset users viewers (shughes@redhat.com)
- made the systems create accept org_name or owner tags (paji@redhat.com)
- Adds breadcrumb creation whenever a blank product is added to the changeset
  as a result of adding packages directly. (ehelms@redhat.com)
- Merge branch 'master' into Locker (adprice@redhat.com)
- Merge branch 'master' into provider_name (adprice@redhat.com)
- first stab at the real data (mmccune@redhat.com)
- Fixes a set of failing tests by setting the prior on a created environment.
  (ehelms@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- Fixes for broken tests. (ehelms@redhat.com)
- fixing issue where package changeset removal was not working
  (jsherril@redhat.com)
- remove debugger statements...oops. (shughes@redhat.com)
- minor syntax fixes to changeset user list in view (shughes@redhat.com)
- varname syntax fix for double render issue (shughes@redhat.com)
- add changeset users to promotions page (shughes@redhat.com)
- Adding back commented out private declaration. (ehelms@redhat.com)
- Adds extra check to ensure product in reset_page exists when doing an all
  check. (ehelms@redhat.com)
- Adds disable all when a full product is added. Fixes typo bug preventing
  changeset deletion. (ehelms@redhat.com)
- Adds button disable/enable on product add/remove. (ehelms@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- Fixes backend error with adding individual packages to changeset.
  (ehelms@redhat.com)
- templates - removal of old code (tstrachota@redhat.com)
- templates - fix for promotions (tstrachota@redhat.com)
- templates - fixed validations (tstrachota@redhat.com)
- templates - inheritance (tstrachota@redhat.com)
- templates - model changed to enable foreign key checking - products
  referenced in associations - new class SystemTemplateErratum - new class
  SystemTenokatePackage (tstrachota@redhat.com)
- templates - products and errata stored as associated records
  (tstrachota@redhat.com)
- templates - lazy accessor attributes in template model
  (tstrachota@redhat.com)
- templates - hostgroup parameters and kickstart attributes merged
  (tstrachota@redhat.com)
- templates - listing package names instead of ids in cli
  (tstrachota@redhat.com)
- templates - CLI for template promotions (tstrachota@redhat.com)
- templates - added cli for updating template content (tstrachota@redhat.com)
- templates - template updates (tstrachota@redhat.com)
- templates - api for editing content of the template (tstrachota@redhat.com)
- templates - reworked model (tstrachota@redhat.com)
- Fixes typos from merge. Adds setting current_changeset upon creating new
  changest. (ehelms@redhat.com)
- Removed debugger statement. (ehelms@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- reverting to a better default changeset name (jsherril@redhat.com)
- Adds ability to add an entire product to a changeset. (ehelms@redhat.com)
- converting the product details partial in the changeset to be rendered client
  side in order to allow for dynamic content (jsherril@redhat.com)
- initial support for system lookup by environment in cli (dmitri@redhat.com)
- spec - fixing whitespace only (lzap+git@redhat.com)
- spec - adding syntax check for haml (lzap+git@redhat.com)
- spec - adding syntax check for ruby (lzap+git@redhat.com)
- moving 'bundle install' from spec to init script (lzap+git@redhat.com)
- Revert "adding bundle install to the spec" (lzap+git@redhat.com)
- Revert "adding bundler rubygem to build requires" (lzap+git@redhat.com)
- properly showing the loading page and not doing a syncronous request
  (jsherril@redhat.com)
- Changed the system register code to use owner instead of org)name
  (paji@redhat.com)
- unifying 'Locker' name throughout API and UI (adprice@redhat.com)
- 2nd pass at copy-paste from headpin (mmccune@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- initial changeset loading screen (jsherril@redhat.com)
- added systems to environments (dmitri@redhat.com)
- fixing changeset rendering to only show changesets.... again
  (jsherril@redhat.com)
- initial copy-paste from headpin (mmccune@redhat.com)
- fixing merge conflicts (jsherril@redhat.com)
- More changes for show on changesets. (jrist@redhat.com)
- adding update for repositories back to seeds.rb (jsherril@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (jrist@redhat.com)
- fixing organizations controller from stray character (jsherril@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- Fixes sliding tree direction regression. (ehelms@redhat.com)
- started on association of consumers with environments (dmitri@redhat.com)
- 714297 - fixed promotions - fixed promotions of products - added promotions
  of packeges - added promotions of errata - added promotions of repositories
  (tstrachota@redhat.com)
- fixing bbq with changesets on the promotion page (jsherril@redhat.com)
- adding repos/errata to changeset with working add/remove, removing some old
  code as well (jsherril@redhat.com)
- 705563 - fixed issue where provider name could not be modified after creating
  repos for said provider (adprice@redhat.com)
- commenting out sort function temporarily since sliding changes broke it
  (jsherril@redhat.com)
- getting add/remove of packages working much much better (jsherril@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (jrist@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (jrist@redhat.com)
- Small fix to get slidingtree sliding smoother. (ehelms@redhat.com)
- Search addition to breadcrumb in Changesets. (jrist@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- On promotions page, right tree, makes it such that the changesets panel will
  float alongside the left side on scroll.  Fixes slide animation to not show
  ghosts. (ehelms@redhat.com)
- fixing promotions page to show correct changesets (jsherril@redhat.com)
- package rendering in javascript (jsherril@redhat.com)
- adding bundler rubygem to build requires (lzap+git@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (jrist@redhat.com)
- Small changes here and there for the promotions and changesets pages.
  (jrist@redhat.com)
- adding bundle install to the spec (lzap+git@redhat.com)
- Fixes add and delete of changesets to work with new rendering scheme.
  (ehelms@redhat.com)
- add/remove items from the changeset object client side when the user does so
  in the UI (jsherril@redhat.com)
- changing the way the render_cb functions to pass the content back to the
  sliding tree (jsherril@redhat.com)
- fixing the add/remove of changeset items (jsherril@redhat.com)
- Adds start of client-side javascript templating library for changesets and
  initial renderers.  Renders changesets list via breadcrumbs data object and
  templates from template library. (ehelms@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- intial work for client side changeset rendering (jsherril@redhat.com)
- Merge branch 'master' into provider_repo (adprice@redhat.com)
- fixed provider url validation and added/fixed tests (adprice@redhat.com)
- adding a packages page to promotions (jsherril@redhat.com)
- Adds remove functionality for a changeset to the UI. (ehelms@redhat.com)
- js header modifications for changeset user editors (shughes@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (adprice@redhat.com)
- fixed environment creation to allow lockers to have multiple priors and added
  tests (adprice@redhat.com)
- removed bypass warden strategy (dmitri@redhat.com)
- Merge branch 'master' into env_tests (adprice@redhat.com)
- Fixes systems controller test 'should show the system 2 pane list'.
  (ehelms@redhat.com)
- User creation errors will now be displayed in notices properly.
  (ehelms@redhat.com)
- fixed UI environment creation failure (adprice@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- Adds re-vamped changeset creation to fit with creation of changests from the
  UI.  Modifies changeset breadcrumb creation and functionality to allow for
  switching tree contexts upon changeset creation. (ehelms@redhat.com)
- Fixes typo causing wrong name to display in changeset breadcrumbs.
  (ehelms@redhat.com)
- adding condstop to the katello init script (lzap+git@redhat.com)
- adding page reloading as the changeset changes (jsherril@redhat.com)
- spec test for empty changesetuser on index view (shughes@redhat.com)
- Merge branch 'master' into promotions (jrist@redhat.com)
- fixing bug with ChangesetUser (jsherril@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- making changsets be stored client side, lots still broken
  (jsherril@redhat.com)
- adding controller logic and spec test for changesetuser destroy
  (shughes@redhat.com)
- adding find or create spec test for changeset model (shughes@redhat.com)
- Fixes to create and delete changesets properly with associated test fixes.
  (ehelms@redhat.com)
- Removed previous default name setting in kp_environment changeset creation
  and moved it into the changeset model. (ehelms@redhat.com)
- Added create and delete, tests for each and corresponding routes.
  (ehelms@redhat.com)
- Changed to use id(passed in via locals) instead of the @id(instance
  variable). (ehelms@redhat.com)
- Adds validations to changeset name to conform with Katello standards, provide
  uniqueness across environments and create a default name for the changeset
  auto-generated when an environment is created. (ehelms@redhat.com)
- local var changes for changeset spec (shughes@redhat.com)
- initial changeset model spec (shughes@redhat.com)
- fixing issue where promotions would throw an error if next environment did
  not exist (jsherril@redhat.com)
- Merge branch 'master' into promotions (jrist@redhat.com)
- adding initial changeset revamp (jsherril@redhat.com)
- initial schema for tracking changeset users (shughes@redhat.com)
- pulling out the slidingtree and putting it into a form that is reusable on
  the same page (jsherril@redhat.com)

* Fri Jul 15 2011 Eric D Helms <eric.d.helms@gmail.com>
- Updates to use version 0.11.5 or greater of Compass. (eric.d.helms@gmail.com)
- Adds padding to empty changeset text. (eric.d.helms@gmail.com)
- Merge branch 'master' into refactor (eric.d.helms@gmail.com)
- initdb does not print unnecessary info anymore (lzap+git@redhat.com)
- ignoring ping.rb in code coverage (lzap+git@redhat.com)
- do not install .gitkeep files (msuchy@redhat.com)
- setting failure threshold to code coverage to 60 % (lzap+git@redhat.com)
- adding failure threshold to code doverage (lzap+git@redhat.com)
- 720414 - fixing issue where hitting enter while on the new changeset name box
  would result in a form submitting (jsherril@redhat.com)
- get unit tests working with rconv (lzap+git@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (adprice@redhat.com)
- spec test fix (jsherril@redhat.com)
- improving env_selector to auto-select the path properly so the controller
  doesnt have to (jsherril@redhat.com)
- fixing the env_selector to properly display secondary paths, this broke at
  some point (jsherril@redhat.com)
- system info - adding /api/systems/:uuid/packages controller
  (lzap+git@redhat.com)
- ignoring coverage/ dir (lzap+git@redhat.com)
- merging systems resource in the routes into one (lzap+git@redhat.com)
- Merge branch 'master' into templates (adprice@redhat.com)
- fixing broken unit tests (jsherril@redhat.com)
- 720431 - fixing issue where creating a changeset that already exists would
  fail silently (jsherril@redhat.com)
- fixing stray comman in promotion.js (jsherril@redhat.com)
- Merge branch 'master' into refactor (eric.d.helms@gmail.com)
- added ability to track pulp async jobs through katello task api
  (dmitri@redhat.com)
- updating localization strings for zanata server (shughes@redhat.com)
- removing katello_client.js from assets and removing inclusions in all haml
  files (jsherril@redhat.com)
- refactoring javascript to get rid of katello_client.js (jsherril@redhat.com)
- changing level inclusion validator of notices to handle the string forms of
  the types, so a notice can actually be saved if modified
  (jsherril@redhat.com)
- 717714: adding friendly sync conflict messaging (shughes@redhat.com)
- remove js debug alerts from sync (shughes@redhat.com)
- refactoring environment creation/deleteion in javascript to not use
  katello_client.js (jsherril@redhat.com)
- refactoring role.js to be more modular and not have global functions
  (jsherril@redhat.com)
- Added permission enforcement for all_verbs and all_tags (paji@redhat.com)
- system info - systems list now supports name query param
  (lzap+git@redhat.com)
- auto_complete_search - move routes in to collection blocks
  (bbuckingham@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (mmccune@redhat.com)
- adding spec test (mmccune@redhat.com)
- hopefully done changing 'locker' to 'Locker' (adprice@redhat.com)
- CSS Refactor - more cleanup and removal of old unused css.
  (ehelms@redhat.com)
- adding tests for listing templates (adprice@redhat.com)
- CSS Refactor - Large scale cleanup of old CSS. Moved chunks of css to the
  appropriate page level css files. (ehelms@redhat.com)
- Merge branch 'master' into templates (adprice@redhat.com)
- cleanup of user.js and affected views/routes (jsherril@redhat.com)
- reworking template list to work with existing code in client
  (adprice@redhat.com)
- 715422: update sync mgt status method and routes to use non reserved name
  (shughes@redhat.com)
- 713959: add 'none' interval type to sync plan edit, add rspec test
  (shughes@redhat.com)
- spec path test for promotions env (shughes@redhat.com)
- rspec for systems environment selections (shughes@redhat.com)
- env selector for systems and env model refactor (shughes@redhat.com)
- add new route and trilevel nav for registered systems (shughes@redhat.com)
- env selector support for systems listing (shughes@redhat.com)
- fixed a broken test (dmitri@redhat.com)
- added ability to persist results of async operations (dmitri@redhat.com)
- Merge branch 'master' into refactor (ehelms@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (ehelms@redhat.com)
- fix for env-selector not selecting the correct path if an environment is
  selected (jsherril@redhat.com)
- CSS Refactor - Combines all the css for the environment selector into sass
  nesting format. (ehelms@redhat.com)
- Merge branch 'master' into org-subs (mmccune@redhat.com)
- added requirement of org and env when listing templates via api
  (adprice@redhat.com)
- CSS Refactor - converts all color variables to end in _color for readability
  and organization. (ehelms@redhat.com)
- CSS Refactor - Moved each section stylesheet into a sections folder. Removed
  all colors from _base and moved them into a _colors css file. Re-named _base
  to _mixins as a place to define and have project wide css mixins. Moved all
  imports to katello.scss and it is now being treated as the base level scss
  import. (ehelms@redhat.com)
- CSS Refactor - Moves all basic css imports to base (e.g. grid, text, sprits).
  Removes katello.css directly from page, and instead each section css file
  (e.g. contents, dashboard) imports katello.scss.  The intent is for
  katello.scss to hold cross-app and re-usable css while each individual
  section scss file will hold overrides and custom css. (ehelms@redhat.com)
- CSS Refactor - Moves icon and image sprites out to seperate file for easier
  reference and to aid in any future spriting. (ehelms@redhat.com)
- Commits missing file to stop Jammit warning. (ehelms@redhat.com)
- Notifications polling time increased to 2 minutes. Small fix for
  subscriptions helptip. (jrist@redhat.com)
- Provider - update controller to query based on current org
  (bbuckingham@redhat.com)
- added optional functionality for org and environment inclusion in template
  viewing (adprice@redhat.com)
- 720003 - moves page load notifications inside document ready function to
  properly display across browsers (ehelms@redhat.com)
- 720002 - Adds generic css file for notification page to conform with css file
  for each main page. (ehelms@redhat.com)
- fixed tests broken by async job merge (dmitri@redhat.com)
- removed a bit of async job sample code from api/systems_controller
  (dmitri@redhat.com)
- merging async job status tracking changes into master (dmitri@redhat.com)
- uuid value is now being stored in Delayed::Job uuid field (dmitri@redhat.com)
- added uuidtools gem requirements into Gemfile and katello.spec
  (dmitri@redhat.com)
- added uuids to track status of async jobs (dmitri@redhat.com)
- spec - moving syntax checks to external script (CI) (lzap+git@redhat.com)
- users - better logging during authentication (lzap+git@redhat.com)
- users - updating bash completion (lzap+git@redhat.com)
- users - adding support for users CRUD in CLI (lzap+git@redhat.com)
- api auth code stores user/pass with auth_ prefix (lzap+git@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (ehelms@redhat.com)
- Added missing loginpage css file. (ehelms@redhat.com)
- add daemons gem dep for delayed job (shughes@redhat.com)
- Adds section in head of katello.yml for including extra javascripts from a
  template view.  This is intended to move included javascripts out of the
  body. (ehelms@redhat.com)
- Moves locked icon on breadcrumbs next to the changeset name instead of at the
  front of the breadcrumb list. (ehelms@redhat.com)
- Moves subheader, maincontent and footer up a few pixels. (ehelms@redhat.com)
- Adds new option to sliding tree - base_icon for displaying an image as the
  first breadcrumb instead of text. Modifies changeset breadcrumbs to use home
  icon for first breadcrumb. (ehelms@redhat.com)
- fixed a config issue with delayed jobs (dmitri@redhat.com)
- delayed jobs are now associated with organizations (dmitri@redhat.com)
- Adds big logo to empty dashboard page. (ehelms@redhat.com)
- first cut at tracking of async jobs (dmitri@redhat.com)
- Adding breadcrumb icon sprite. (jimmac@gmail.com)
- speed up header spinner, more style-appropriate grabber (jimmac@gmail.com)
- Added whitespace on the sides of help-tips looks very unbalanced.
  (jimmac@gmail.com)
- Same spinner for the header as it is in the body. Might need to invert to
  white. (jimmac@gmail.com)
- Update header to the latest upstream design. (jimmac@gmail.com)
- clean up favicon. (jimmac@gmail.com)
- 719414 - changest:  New changeset view now returns message instructing user
  that a changeset cannot be created if a next environment is not present for
  the current environment. (ehelms@redhat.com)
- continuing to fix capital 'Locker' (adprice@redhat.com)
- spec - more tests for permissions (super admin) (lzap+git@redhat.com)
- spec - making permission_spec much faster (lzap+git@redhat.com)
- adding new spec tests for promotions controller (jsherril@redhat.com)
- Fix copyright on several files (bbuckingham@redhat.com)
- fixed an error in katello.spec (dmitri@redhat.com)
- fixing changeset deletion client side (jsherril@redhat.com)
- fixing odd promotions button issues caused by removing the default changeset
  upon environment creation (jsherril@redhat.com)
- Merge branch 'errors' (dmitri@redhat.com)
- added delayed_job gem dependency (dmitri@redhat.com)
- 2pane column sorter module helper for controllers (shughes@redhat.com)
- Provider - Update so that 'remove provider' link is accessible from subpanels
  (bbuckingham@redhat.com)
- errors are now being returned in an array, under :errors hash key
  (dmitri@redhat.com)
- Merge branch 'promotions' (jsherril@redhat.com)
- removing the automatic creating of changesets, since you can now create them
  manually (jsherril@redhat.com)
- prompting the user if they are leaving the promotions page with unsaved
  changeset changes (jsherril@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- Makes current crumb different color than the rest of the breadcrumbs. Adds
  highlighting of list items in changeset trees. (ehelms@redhat.com)
- added delayed_job gem dependency (dmitri@redhat.com)
- adding wait dialog when switching out of a changeset if updates are left to
  process (jsherril@redhat.com)
- update po files for translation (shughes@redhat.com)
- Fixes lock image location when changeset is being promoted and breadcrumbs
  attempt to wrap. (ehelms@redhat.com)
- Re-works scroll mechanism in sliding tree to handle left-right scrolling with
  container of any height or fixed height containers that need scrollable
  overflow. (ehelms@redhat.com)
- remove flies config (shughes@redhat.com)
- adding waiting indicator prior to review if there is still items to process
  in the queue (jsherril@redhat.com)
- Promotion page look and feel changes. Border and background colors of left
  and right panels changed. Border color of search filter changed.
  (ehelms@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- Merge branch 'master' into sso-prototype (bbuckingham@redhat.com)
- fixing issue where adding a partial product after a full product would result
  in not being able to browse the partial product (jsherril@redhat.com)
- Merge branch 'master' into url_format (adprice@redhat.com)
- Added default env upon entering changeset history page. (jrist@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (jrist@redhat.com)
- Ajax listing and searching on Changeset History page. (jrist@redhat.com)
- SSO - prototype - additional mods for error handling (bbuckingham@redhat.com)
- Login - fix error message when user logs in with invalid credentials
  (bbuckingham@redhat.com)
- SSO - update warden for HTTP_X_FORWARDED_USER (bbuckingham@redhat.com)
- added support for sso auth in ui and api controllers (dmitri@redhat.com)
- fixing issue where promotion would redirect to the incorrect environment
  (jsherril@redhat.com)
- updated katello url format validator with port number options.
  (adprice@redhat.com)
- Initial promotion QUnit page tests. (ehelms@redhat.com)
- fixing issue where creating a changeset make it appear to be locked
  (jsherril@redhat.com)
- added more tests around system registration with environments
  (dmitri@redhat.com)
- fixed a bunch of failing tests (dmitri@redhat.com)
- got rhsm client mostly working with system registration with environments
  (dmitri@redhat.com)
- fixed merging conflicts (dmitri@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (jrist@redhat.com)
- In-place search for changesets. (jrist@redhat.com)
- fixing previous notices change to work with polling as well, and work around
  issue whith update after a query would result in the query not actually
  returning anything retroactively (jsherril@redhat.com)
- fixing promotions redirection and notices not actually rendering properly on
  page load (jsherril@redhat.com)
- added/modified some tests and fixed a typo (adprice@redhat.com)
- removed unused code after commenting on a previous commit.
  (adprice@redhat.com)
- 703528 - checks provider url for valid format (adprice@redhat.com)
- templates - tests for controller (tstrachota@redhat.com)
- templates - tests for the model (tstrachota@redhat.com)
- added api-namespace resource discovery (dmitri@redhat.com)
- Role: sort permission type alphabetically (bbuckingham@redhat.com)
- stop changeset modifications when changeset is in the correct state
  (jsherril@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- Splits product list in changeset into Full Products and Partial Products.
  Full Products can be removed but Partial Products cannot. (ehelms@redhat.com)
- adding next environment name to promote button (jsherril@redhat.com)
- fixing text vs varchar problem on pgsql (lzap+git@redhat.com)
- roles - disabled flag is now in effect (lzap+git@redhat.com)
- roles - adding disabled flag to users (lzap+git@redhat.com)
- possibility to run rake setup without REST interaction (lzap+git@redhat.com)
- roles - adding description column to roles (lzap+git@redhat.com)
- roles - role name may contain spaces now (lzap+git@redhat.com)
- roles - self-roles now named 'username_salt' (lzap+git@redhat.com)
- roles - giving fancy names to basic roles (lzap+git@redhat.com)
- roles - superadmin role allowed by default, new reader role
  (lzap+git@redhat.com)
- roles - setting permissions rather on superadmin role than admin self-role
  (lzap+git@redhat.com)
- roles - reordering and cleaning seeds.rb (lzap+git@redhat.com)
- templates - added foreign key reference to environments
  (tstrachota@redhat.com)
- navigation for subscriptions page (mmccune@redhat.com)
- Merge branch 'org-subs' of ssh://git.fedorahosted.org/git/katello into org-
  subs (mmccune@redhat.com)
- Added Expand/Contract All (jrist@redhat.com)
- Fix for firt-child of TD not being aligned properly with expanding tree.
  (jrist@redhat.com)
- Merge branch 'master' into org-subs (mmccune@redhat.com)
- making the resizable panel not resizable for promotions (jsherril@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- fixing callback call that was cuasing lots of issues with promotions
  (jsherril@redhat.com)
- Fixes issue with multiple icons appearing in changeset breadcrumbs.
  (ehelms@redhat.com)
- Merge branch 'master' into url_format (adprice@redhat.com)
- 718054: updating gem requirements to match Gemfile versions
  (shughes@redhat.com)
- update to get sparklines going (mmccune@redhat.com)
- added spec for api/systems_controller (dmitri@redhat.com)
- force 2.3.1 version of scoped search for katello installs; supports sorting
  (shughes@redhat.com)
- Small fix for breadcrumb not expanding to full height. (jrist@redhat.com)
- Fixed #changeset_tree moving over when scrolling. (jrist@redhat.com)
- moved find_organization() method from api controllers into API_Controller and
  fixed some associated tests. (adprice@redhat.com)
- Small fix for closing filter. (jrist@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (jrist@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (jrist@redhat.com)
- fixed broken tests (dmitri@redhat.com)
- 703528 - checks provider url for valid format (adprice@redhat.com)
- fixing  issue with promotions page and no environment after locker
  (jsherril@redhat.com)
- adding additional javascript and removing debugger (mmccune@redhat.com)
- Filter working on right changeset for current .has_content selector.
  (jrist@redhat.com)
- updating gemlock for scoped_search changes (shughes@redhat.com)
- sorting systems on both ar/non ar data from cp (shughes@redhat.com)
- scoped_search gem support for column sorting (shughes@redhat.com)
- 2pane support for AR/NONAR column sorting (shughes@redhat.com)
- Merge branch 'master' into roles (bbuckingham@redhat.com)
- fixing issue where adding a package to a changeset for a product that doesnt
  exist would not setup the breadrumb and changeset properly
  (jsherril@redhat.com)
- adding summary of changeset to promotions page (jsherril@redhat.com)
- superadmin columnt in role model (lzap+git@redhat.com)
- ownergeddon - fixing unit tests (lzap+git@redhat.com)
- renaming Candlepin::User to CPUser (lzap+git@redhat.com)
- ownergeddon - organization now belogs to user who created it
  (lzap+git@redhat.com)
- fixing User vs candlepin User reference (lzap+git@redhat.com)
- ownergeddon - superadmin role has access to all orgs (lzap+git@redhat.com)
- ownergeddon - creating superadmin role (lzap+git@redhat.com)
- ownergeddon - removing special user creation (lzap+git@redhat.com)
- changing org-user relationship to plural (lzap+git@redhat.com)
- Adds new button look and feel to errata and repos. (ehelms@redhat.com)
- Typo fix that prevented changeset creation in the UI. (ehelms@redhat.com)
- Fixes broken changeset creation. (ehelms@redhat.com)
- Roles - spec fix: self-role naming no longer dependent on user name
  (bbuckingham@redhat.com)
- Re-refactoring of templateLibrary to remove direct references to
  promotion_page. (ehelms@redhat.com)
- Adds back missing code that makes the right side changeset panel scroll along
  with page. (ehelms@redhat.com)
- 704577 - Role - delete self-role on user delete (bbuckingham@redhat.com)
- Converts promotion_page object into module pattern. (ehelms@redhat.com)
- getting client side sorting working again on the promotions page
  (jsherril@redhat.com)
- moved find_organization() method from api controllers into API_Controller and
  fixed some associated tests. (adprice@redhat.com)
- 717368 - fixing issue where the environment picker would not properly show
  the environment you were on if that environment had no successor
  (jsherril@redhat.com)
- moving changeset buttons to only show up if changesets exist
  (jsherril@redhat.com)
- added support for system registration to an environment in an organization
  (dmitri@redhat.com)
- 704632 -speeding up role rendering (jsherril@redhat.com)
- Roles - update seeds to account for changes to self-role naming
  (bbuckingham@redhat.com)
- Roles - fix delete of user from Roles & Perms tab (bbuckingham@redhat.com)
- Merge branch 'master' into org-subs (mmccune@redhat.com)
- adding locking icons to the changeset list and the breadcrumb bar
  (jsherril@redhat.com)
- including statistics at the org level, pulled in from Headpin
  (mmccune@redhat.com)
- Merge branch 'master' into roles (bbuckingham@redhat.com)
- Changeset list now returns to list of products for that changeset if an item
  removal renders no errata, no repos and no packages for that product and
  removes the product from the list. (ehelms@redhat.com)
- User - self-role name - update to be random generated string
  (bbuckingham@redhat.com)
- Changes promotion page slide_link icon. (ehelms@redhat.com)
- Merge branch 'master' into roles (bbuckingham@redhat.com)
- fixed providers page where promotions link looked up 'locker' instead of
  'Locker' (adprice@redhat.com)
- Roles - refactor self-roles to associated directly with a user
  (bbuckingham@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- Changes to Add/Remove button look and feel across promotion pages.
  (ehelms@redhat.com)
- Add an icon for the promotions page breadcrumb. (jimmac@gmail.com)
- making promotion actually work again (jsherril@redhat.com)
- cleaning up some of katello_client.js (jsherril@redhat.com)
- restriciting promotion based off changeset state (jsherril@redhat.com)
- ownergeddon - adding /users/:username/owners support for sm
  (lzap+git@redhat.com)
- correcting identation in two haml files (lzap+git@redhat.com)
- spec - enabling verbose mode for syntax checking (lzap+git@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- Re-removing previously removed file that got added back by merge.
  (ehelms@redhat.com)
- Merge commit 'eb9c97b3c5b1b1174e3ba4c732690068c9f81f3a' into promotions
  (ehelms@redhat.com)
- adding callback for extended scroll so we can properly reset the page
  (jsherril@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into grid
  (ehelms@redhat.com)
- hiding left hand buttons if changeset is in review phase
  (jsherril@redhat.com)
- Adds data-product_id field to all products for consistency with other
  function calls in promotionjs and fixes adding a product. (ehelms@redhat.com)
- making a locked changeset look different, and not showing add/remove buttons
  on the right if the changeset is locked (jsherril@redhat.com)
- fixing unit tests because of pwd hashing (lzap+git@redhat.com)
- global access to Rake DSL methods is deprecated (lzap+git@redhat.com)
- passwords are stored in secure format (lzap+git@redhat.com)
- default password for admin is 'admin' (lzap+git@redhat.com)
- 717554 - NoMethodError in User sessionsController#create
  (lzap+git@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (jrist@redhat.com)
- Changesets - filter dropdown - initial work on changeset history (might not
  be functional yet). (jrist@redhat.com)
- additional columns added and proper data displayed on page
  (mmccune@redhat.com)
- getting  review/cancel working properly (jsherril@redhat.com)
- listing of systems by environment works now (dmitri@redhat.com)
- specs for changeset controller updates, changesetusers (shughes@redhat.com)
- fixing issue where odd changeset concurrency issue was being taken into
  account even when ti didnt exist (jsherril@redhat.com)
- jquery, css changes for changeset users viewers (shughes@redhat.com)
- made the systems create accept org_name or owner tags (paji@redhat.com)
- Adds breadcrumb creation whenever a blank product is added to the changeset
  as a result of adding packages directly. (ehelms@redhat.com)
- Merge branch 'master' into Locker (adprice@redhat.com)
- Merge branch 'master' into provider_name (adprice@redhat.com)
- first stab at the real data (mmccune@redhat.com)
- Fixes a set of failing tests by setting the prior on a created environment.
  (ehelms@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- Fixes for broken tests. (ehelms@redhat.com)
- fixing issue where package changeset removal was not working
  (jsherril@redhat.com)
- remove debugger statements...oops. (shughes@redhat.com)
- minor syntax fixes to changeset user list in view (shughes@redhat.com)
- varname syntax fix for double render issue (shughes@redhat.com)
- add changeset users to promotions page (shughes@redhat.com)
- Adding back commented out private declaration. (ehelms@redhat.com)
- Adds extra check to ensure product in reset_page exists when doing an all
  check. (ehelms@redhat.com)
- Adds disable all when a full product is added. Fixes typo bug preventing
  changeset deletion. (ehelms@redhat.com)
- Adds button disable/enable on product add/remove. (ehelms@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- Fixes backend error with adding individual packages to changeset.
  (ehelms@redhat.com)
- templates - removal of old code (tstrachota@redhat.com)
- templates - fix for promotions (tstrachota@redhat.com)
- templates - fixed validations (tstrachota@redhat.com)
- templates - inheritance (tstrachota@redhat.com)
- templates - model changed to enable foreign key checking - products
  referenced in associations - new class SystemTemplateErratum - new class
  SystemTenokatePackage (tstrachota@redhat.com)
- templates - products and errata stored as associated records
  (tstrachota@redhat.com)
- templates - lazy accessor attributes in template model
  (tstrachota@redhat.com)
- templates - hostgroup parameters and kickstart attributes merged
  (tstrachota@redhat.com)
- templates - listing package names instead of ids in cli
  (tstrachota@redhat.com)
- templates - CLI for template promotions (tstrachota@redhat.com)
- templates - added cli for updating template content (tstrachota@redhat.com)
- templates - template updates (tstrachota@redhat.com)
- templates - api for editing content of the template (tstrachota@redhat.com)
- templates - reworked model (tstrachota@redhat.com)
- Fixes typos from merge. Adds setting current_changeset upon creating new
  changest. (ehelms@redhat.com)
- Removed debugger statement. (ehelms@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- reverting to a better default changeset name (jsherril@redhat.com)
- Adds ability to add an entire product to a changeset. (ehelms@redhat.com)
- converting the product details partial in the changeset to be rendered client
  side in order to allow for dynamic content (jsherril@redhat.com)
- initial support for system lookup by environment in cli (dmitri@redhat.com)
- spec - fixing whitespace only (lzap+git@redhat.com)
- spec - adding syntax check for haml (lzap+git@redhat.com)
- spec - adding syntax check for ruby (lzap+git@redhat.com)
- moving 'bundle install' from spec to init script (lzap+git@redhat.com)
- Revert "adding bundle install to the spec" (lzap+git@redhat.com)
- Revert "adding bundler rubygem to build requires" (lzap+git@redhat.com)
- properly showing the loading page and not doing a syncronous request
  (jsherril@redhat.com)
- Changed the system register code to use owner instead of org)name
  (paji@redhat.com)
- unifying 'Locker' name throughout API and UI (adprice@redhat.com)
- 2nd pass at copy-paste from headpin (mmccune@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- initial changeset loading screen (jsherril@redhat.com)
- added systems to environments (dmitri@redhat.com)
- fixing changeset rendering to only show changesets.... again
  (jsherril@redhat.com)
- initial copy-paste from headpin (mmccune@redhat.com)
- fixing merge conflicts (jsherril@redhat.com)
- More changes for show on changesets. (jrist@redhat.com)
- adding update for repositories back to seeds.rb (jsherril@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (jrist@redhat.com)
- fixing organizations controller from stray character (jsherril@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- Fixes sliding tree direction regression. (ehelms@redhat.com)
- started on association of consumers with environments (dmitri@redhat.com)
- 714297 - fixed promotions - fixed promotions of products - added promotions
  of packeges - added promotions of errata - added promotions of repositories
  (tstrachota@redhat.com)
- fixing bbq with changesets on the promotion page (jsherril@redhat.com)
- adding repos/errata to changeset with working add/remove, removing some old
  code as well (jsherril@redhat.com)
- 705563 - fixed issue where provider name could not be modified after creating
  repos for said provider (adprice@redhat.com)
- commenting out sort function temporarily since sliding changes broke it
  (jsherril@redhat.com)
- getting add/remove of packages working much much better (jsherril@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (jrist@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (jrist@redhat.com)
- Small fix to get slidingtree sliding smoother. (ehelms@redhat.com)
- Search addition to breadcrumb in Changesets. (jrist@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- On promotions page, right tree, makes it such that the changesets panel will
  float alongside the left side on scroll.  Fixes slide animation to not show
  ghosts. (ehelms@redhat.com)
- fixing promotions page to show correct changesets (jsherril@redhat.com)
- package rendering in javascript (jsherril@redhat.com)
- adding bundler rubygem to build requires (lzap+git@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (jrist@redhat.com)
- Small changes here and there for the promotions and changesets pages.
  (jrist@redhat.com)
- adding bundle install to the spec (lzap+git@redhat.com)
- Fixes add and delete of changesets to work with new rendering scheme.
  (ehelms@redhat.com)
- add/remove items from the changeset object client side when the user does so
  in the UI (jsherril@redhat.com)
- changing the way the render_cb functions to pass the content back to the
  sliding tree (jsherril@redhat.com)
- fixing the add/remove of changeset items (jsherril@redhat.com)
- Adds start of client-side javascript templating library for changesets and
  initial renderers.  Renders changesets list via breadcrumbs data object and
  templates from template library. (ehelms@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- intial work for client side changeset rendering (jsherril@redhat.com)
- Merge branch 'master' into provider_repo (adprice@redhat.com)
- fixed provider url validation and added/fixed tests (adprice@redhat.com)
- adding a packages page to promotions (jsherril@redhat.com)
- Adds remove functionality for a changeset to the UI. (ehelms@redhat.com)
- js header modifications for changeset user editors (shughes@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (adprice@redhat.com)
- fixed environment creation to allow lockers to have multiple priors and added
  tests (adprice@redhat.com)
- removed bypass warden strategy (dmitri@redhat.com)
- Merge branch 'master' into env_tests (adprice@redhat.com)
- Fixes systems controller test 'should show the system 2 pane list'.
  (ehelms@redhat.com)
- User creation errors will now be displayed in notices properly.
  (ehelms@redhat.com)
- fixed UI environment creation failure (adprice@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- Adds re-vamped changeset creation to fit with creation of changests from the
  UI.  Modifies changeset breadcrumb creation and functionality to allow for
  switching tree contexts upon changeset creation. (ehelms@redhat.com)
- Fixes typo causing wrong name to display in changeset breadcrumbs.
  (ehelms@redhat.com)
- adding condstop to the katello init script (lzap+git@redhat.com)
- adding page reloading as the changeset changes (jsherril@redhat.com)
- spec test for empty changesetuser on index view (shughes@redhat.com)
- Merge branch 'master' into promotions (jrist@redhat.com)
- fixing bug with ChangesetUser (jsherril@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- making changsets be stored client side, lots still broken
  (jsherril@redhat.com)
- adding controller logic and spec test for changesetuser destroy
  (shughes@redhat.com)
- adding find or create spec test for changeset model (shughes@redhat.com)
- Fixes to create and delete changesets properly with associated test fixes.
  (ehelms@redhat.com)
- Removed previous default name setting in kp_environment changeset creation
  and moved it into the changeset model. (ehelms@redhat.com)
- Added create and delete, tests for each and corresponding routes.
  (ehelms@redhat.com)
- Changed to use id(passed in via locals) instead of the @id(instance
  variable). (ehelms@redhat.com)
- Adds validations to changeset name to conform with Katello standards, provide
  uniqueness across environments and create a default name for the changeset
  auto-generated when an environment is created. (ehelms@redhat.com)
- local var changes for changeset spec (shughes@redhat.com)
- initial changeset model spec (shughes@redhat.com)
- fixing issue where promotions would throw an error if next environment did
  not exist (jsherril@redhat.com)
- Merge branch 'master' into promotions (jrist@redhat.com)
- adding initial changeset revamp (jsherril@redhat.com)
- initial schema for tracking changeset users (shughes@redhat.com)
- pulling out the slidingtree and putting it into a form that is reusable on
  the same page (jsherril@redhat.com)

* Fri Jul 15 2011 Unknown name
- Updates to use version 0.11.5 or greater of Compass. (eric.d.helms@gmail.com)
- Adds padding to empty changeset text. (eric.d.helms@gmail.com)
- Merge branch 'master' into refactor (eric.d.helms@gmail.com)
- initdb does not print unnecessary info anymore (lzap+git@redhat.com)
- ignoring ping.rb in code coverage (lzap+git@redhat.com)
- do not install .gitkeep files (msuchy@redhat.com)
- setting failure threshold to code coverage to 60 % (lzap+git@redhat.com)
- adding failure threshold to code doverage (lzap+git@redhat.com)
- 720414 - fixing issue where hitting enter while on the new changeset name box
  would result in a form submitting (jsherril@redhat.com)
- get unit tests working with rconv (lzap+git@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (adprice@redhat.com)
- spec test fix (jsherril@redhat.com)
- improving env_selector to auto-select the path properly so the controller
  doesnt have to (jsherril@redhat.com)
- fixing the env_selector to properly display secondary paths, this broke at
  some point (jsherril@redhat.com)
- system info - adding /api/systems/:uuid/packages controller
  (lzap+git@redhat.com)
- ignoring coverage/ dir (lzap+git@redhat.com)
- merging systems resource in the routes into one (lzap+git@redhat.com)
- Merge branch 'master' into templates (adprice@redhat.com)
- fixing broken unit tests (jsherril@redhat.com)
- 720431 - fixing issue where creating a changeset that already exists would
  fail silently (jsherril@redhat.com)
- fixing stray comman in promotion.js (jsherril@redhat.com)
- Merge branch 'master' into refactor (eric.d.helms@gmail.com)
- added ability to track pulp async jobs through katello task api
  (dmitri@redhat.com)
- updating localization strings for zanata server (shughes@redhat.com)
- removing katello_client.js from assets and removing inclusions in all haml
  files (jsherril@redhat.com)
- refactoring javascript to get rid of katello_client.js (jsherril@redhat.com)
- changing level inclusion validator of notices to handle the string forms of
  the types, so a notice can actually be saved if modified
  (jsherril@redhat.com)
- 717714: adding friendly sync conflict messaging (shughes@redhat.com)
- remove js debug alerts from sync (shughes@redhat.com)
- refactoring environment creation/deleteion in javascript to not use
  katello_client.js (jsherril@redhat.com)
- refactoring role.js to be more modular and not have global functions
  (jsherril@redhat.com)
- Added permission enforcement for all_verbs and all_tags (paji@redhat.com)
- system info - systems list now supports name query param
  (lzap+git@redhat.com)
- auto_complete_search - move routes in to collection blocks
  (bbuckingham@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (mmccune@redhat.com)
- adding spec test (mmccune@redhat.com)
- hopefully done changing 'locker' to 'Locker' (adprice@redhat.com)
- CSS Refactor - more cleanup and removal of old unused css.
  (ehelms@redhat.com)
- adding tests for listing templates (adprice@redhat.com)
- CSS Refactor - Large scale cleanup of old CSS. Moved chunks of css to the
  appropriate page level css files. (ehelms@redhat.com)
- Merge branch 'master' into templates (adprice@redhat.com)
- cleanup of user.js and affected views/routes (jsherril@redhat.com)
- reworking template list to work with existing code in client
  (adprice@redhat.com)
- 715422: update sync mgt status method and routes to use non reserved name
  (shughes@redhat.com)
- 713959: add 'none' interval type to sync plan edit, add rspec test
  (shughes@redhat.com)
- spec path test for promotions env (shughes@redhat.com)
- rspec for systems environment selections (shughes@redhat.com)
- env selector for systems and env model refactor (shughes@redhat.com)
- add new route and trilevel nav for registered systems (shughes@redhat.com)
- env selector support for systems listing (shughes@redhat.com)
- fixed a broken test (dmitri@redhat.com)
- added ability to persist results of async operations (dmitri@redhat.com)
- Merge branch 'master' into refactor (ehelms@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (ehelms@redhat.com)
- fix for env-selector not selecting the correct path if an environment is
  selected (jsherril@redhat.com)
- CSS Refactor - Combines all the css for the environment selector into sass
  nesting format. (ehelms@redhat.com)
- Merge branch 'master' into org-subs (mmccune@redhat.com)
- added requirement of org and env when listing templates via api
  (adprice@redhat.com)
- CSS Refactor - converts all color variables to end in _color for readability
  and organization. (ehelms@redhat.com)
- CSS Refactor - Moved each section stylesheet into a sections folder. Removed
  all colors from _base and moved them into a _colors css file. Re-named _base
  to _mixins as a place to define and have project wide css mixins. Moved all
  imports to katello.scss and it is now being treated as the base level scss
  import. (ehelms@redhat.com)
- CSS Refactor - Moves all basic css imports to base (e.g. grid, text, sprits).
  Removes katello.css directly from page, and instead each section css file
  (e.g. contents, dashboard) imports katello.scss.  The intent is for
  katello.scss to hold cross-app and re-usable css while each individual
  section scss file will hold overrides and custom css. (ehelms@redhat.com)
- CSS Refactor - Moves icon and image sprites out to seperate file for easier
  reference and to aid in any future spriting. (ehelms@redhat.com)
- Commits missing file to stop Jammit warning. (ehelms@redhat.com)
- Notifications polling time increased to 2 minutes. Small fix for
  subscriptions helptip. (jrist@redhat.com)
- Provider - update controller to query based on current org
  (bbuckingham@redhat.com)
- added optional functionality for org and environment inclusion in template
  viewing (adprice@redhat.com)
- 720003 - moves page load notifications inside document ready function to
  properly display across browsers (ehelms@redhat.com)
- 720002 - Adds generic css file for notification page to conform with css file
  for each main page. (ehelms@redhat.com)
- fixed tests broken by async job merge (dmitri@redhat.com)
- removed a bit of async job sample code from api/systems_controller
  (dmitri@redhat.com)
- merging async job status tracking changes into master (dmitri@redhat.com)
- uuid value is now being stored in Delayed::Job uuid field (dmitri@redhat.com)
- added uuidtools gem requirements into Gemfile and katello.spec
  (dmitri@redhat.com)
- added uuids to track status of async jobs (dmitri@redhat.com)
- spec - moving syntax checks to external script (CI) (lzap+git@redhat.com)
- users - better logging during authentication (lzap+git@redhat.com)
- users - updating bash completion (lzap+git@redhat.com)
- users - adding support for users CRUD in CLI (lzap+git@redhat.com)
- api auth code stores user/pass with auth_ prefix (lzap+git@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (ehelms@redhat.com)
- Added missing loginpage css file. (ehelms@redhat.com)
- add daemons gem dep for delayed job (shughes@redhat.com)
- Adds section in head of katello.yml for including extra javascripts from a
  template view.  This is intended to move included javascripts out of the
  body. (ehelms@redhat.com)
- Moves locked icon on breadcrumbs next to the changeset name instead of at the
  front of the breadcrumb list. (ehelms@redhat.com)
- Moves subheader, maincontent and footer up a few pixels. (ehelms@redhat.com)
- Adds new option to sliding tree - base_icon for displaying an image as the
  first breadcrumb instead of text. Modifies changeset breadcrumbs to use home
  icon for first breadcrumb. (ehelms@redhat.com)
- fixed a config issue with delayed jobs (dmitri@redhat.com)
- delayed jobs are now associated with organizations (dmitri@redhat.com)
- Adds big logo to empty dashboard page. (ehelms@redhat.com)
- first cut at tracking of async jobs (dmitri@redhat.com)
- Adding breadcrumb icon sprite. (jimmac@gmail.com)
- speed up header spinner, more style-appropriate grabber (jimmac@gmail.com)
- Added whitespace on the sides of help-tips looks very unbalanced.
  (jimmac@gmail.com)
- Same spinner for the header as it is in the body. Might need to invert to
  white. (jimmac@gmail.com)
- Update header to the latest upstream design. (jimmac@gmail.com)
- clean up favicon. (jimmac@gmail.com)
- 719414 - changest:  New changeset view now returns message instructing user
  that a changeset cannot be created if a next environment is not present for
  the current environment. (ehelms@redhat.com)
- continuing to fix capital 'Locker' (adprice@redhat.com)
- spec - more tests for permissions (super admin) (lzap+git@redhat.com)
- spec - making permission_spec much faster (lzap+git@redhat.com)
- adding new spec tests for promotions controller (jsherril@redhat.com)
- Fix copyright on several files (bbuckingham@redhat.com)
- fixed an error in katello.spec (dmitri@redhat.com)
- fixing changeset deletion client side (jsherril@redhat.com)
- fixing odd promotions button issues caused by removing the default changeset
  upon environment creation (jsherril@redhat.com)
- Merge branch 'errors' (dmitri@redhat.com)
- added delayed_job gem dependency (dmitri@redhat.com)
- 2pane column sorter module helper for controllers (shughes@redhat.com)
- Provider - Update so that 'remove provider' link is accessible from subpanels
  (bbuckingham@redhat.com)
- errors are now being returned in an array, under :errors hash key
  (dmitri@redhat.com)
- Merge branch 'promotions' (jsherril@redhat.com)
- removing the automatic creating of changesets, since you can now create them
  manually (jsherril@redhat.com)
- prompting the user if they are leaving the promotions page with unsaved
  changeset changes (jsherril@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- Makes current crumb different color than the rest of the breadcrumbs. Adds
  highlighting of list items in changeset trees. (ehelms@redhat.com)
- added delayed_job gem dependency (dmitri@redhat.com)
- adding wait dialog when switching out of a changeset if updates are left to
  process (jsherril@redhat.com)
- update po files for translation (shughes@redhat.com)
- Fixes lock image location when changeset is being promoted and breadcrumbs
  attempt to wrap. (ehelms@redhat.com)
- Re-works scroll mechanism in sliding tree to handle left-right scrolling with
  container of any height or fixed height containers that need scrollable
  overflow. (ehelms@redhat.com)
- remove flies config (shughes@redhat.com)
- adding waiting indicator prior to review if there is still items to process
  in the queue (jsherril@redhat.com)
- Promotion page look and feel changes. Border and background colors of left
  and right panels changed. Border color of search filter changed.
  (ehelms@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- Merge branch 'master' into sso-prototype (bbuckingham@redhat.com)
- fixing issue where adding a partial product after a full product would result
  in not being able to browse the partial product (jsherril@redhat.com)
- Merge branch 'master' into url_format (adprice@redhat.com)
- Added default env upon entering changeset history page. (jrist@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (jrist@redhat.com)
- Ajax listing and searching on Changeset History page. (jrist@redhat.com)
- SSO - prototype - additional mods for error handling (bbuckingham@redhat.com)
- Login - fix error message when user logs in with invalid credentials
  (bbuckingham@redhat.com)
- SSO - update warden for HTTP_X_FORWARDED_USER (bbuckingham@redhat.com)
- added support for sso auth in ui and api controllers (dmitri@redhat.com)
- fixing issue where promotion would redirect to the incorrect environment
  (jsherril@redhat.com)
- updated katello url format validator with port number options.
  (adprice@redhat.com)
- Initial promotion QUnit page tests. (ehelms@redhat.com)
- fixing issue where creating a changeset make it appear to be locked
  (jsherril@redhat.com)
- added more tests around system registration with environments
  (dmitri@redhat.com)
- fixed a bunch of failing tests (dmitri@redhat.com)
- got rhsm client mostly working with system registration with environments
  (dmitri@redhat.com)
- fixed merging conflicts (dmitri@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (jrist@redhat.com)
- In-place search for changesets. (jrist@redhat.com)
- fixing previous notices change to work with polling as well, and work around
  issue whith update after a query would result in the query not actually
  returning anything retroactively (jsherril@redhat.com)
- fixing promotions redirection and notices not actually rendering properly on
  page load (jsherril@redhat.com)
- added/modified some tests and fixed a typo (adprice@redhat.com)
- removed unused code after commenting on a previous commit.
  (adprice@redhat.com)
- 703528 - checks provider url for valid format (adprice@redhat.com)
- templates - tests for controller (tstrachota@redhat.com)
- templates - tests for the model (tstrachota@redhat.com)
- added api-namespace resource discovery (dmitri@redhat.com)
- Role: sort permission type alphabetically (bbuckingham@redhat.com)
- stop changeset modifications when changeset is in the correct state
  (jsherril@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- Splits product list in changeset into Full Products and Partial Products.
  Full Products can be removed but Partial Products cannot. (ehelms@redhat.com)
- adding next environment name to promote button (jsherril@redhat.com)
- fixing text vs varchar problem on pgsql (lzap+git@redhat.com)
- roles - disabled flag is now in effect (lzap+git@redhat.com)
- roles - adding disabled flag to users (lzap+git@redhat.com)
- possibility to run rake setup without REST interaction (lzap+git@redhat.com)
- roles - adding description column to roles (lzap+git@redhat.com)
- roles - role name may contain spaces now (lzap+git@redhat.com)
- roles - self-roles now named 'username_salt' (lzap+git@redhat.com)
- roles - giving fancy names to basic roles (lzap+git@redhat.com)
- roles - superadmin role allowed by default, new reader role
  (lzap+git@redhat.com)
- roles - setting permissions rather on superadmin role than admin self-role
  (lzap+git@redhat.com)
- roles - reordering and cleaning seeds.rb (lzap+git@redhat.com)
- templates - added foreign key reference to environments
  (tstrachota@redhat.com)
- navigation for subscriptions page (mmccune@redhat.com)
- Merge branch 'org-subs' of ssh://git.fedorahosted.org/git/katello into org-
  subs (mmccune@redhat.com)
- Added Expand/Contract All (jrist@redhat.com)
- Fix for firt-child of TD not being aligned properly with expanding tree.
  (jrist@redhat.com)
- Merge branch 'master' into org-subs (mmccune@redhat.com)
- making the resizable panel not resizable for promotions (jsherril@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- fixing callback call that was cuasing lots of issues with promotions
  (jsherril@redhat.com)
- Fixes issue with multiple icons appearing in changeset breadcrumbs.
  (ehelms@redhat.com)
- Merge branch 'master' into url_format (adprice@redhat.com)
- 718054: updating gem requirements to match Gemfile versions
  (shughes@redhat.com)
- update to get sparklines going (mmccune@redhat.com)
- added spec for api/systems_controller (dmitri@redhat.com)
- force 2.3.1 version of scoped search for katello installs; supports sorting
  (shughes@redhat.com)
- Small fix for breadcrumb not expanding to full height. (jrist@redhat.com)
- Fixed #changeset_tree moving over when scrolling. (jrist@redhat.com)
- moved find_organization() method from api controllers into API_Controller and
  fixed some associated tests. (adprice@redhat.com)
- Small fix for closing filter. (jrist@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (jrist@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (jrist@redhat.com)
- fixed broken tests (dmitri@redhat.com)
- 703528 - checks provider url for valid format (adprice@redhat.com)
- fixing  issue with promotions page and no environment after locker
  (jsherril@redhat.com)
- adding additional javascript and removing debugger (mmccune@redhat.com)
- Filter working on right changeset for current .has_content selector.
  (jrist@redhat.com)
- updating gemlock for scoped_search changes (shughes@redhat.com)
- sorting systems on both ar/non ar data from cp (shughes@redhat.com)
- scoped_search gem support for column sorting (shughes@redhat.com)
- 2pane support for AR/NONAR column sorting (shughes@redhat.com)
- Merge branch 'master' into roles (bbuckingham@redhat.com)
- fixing issue where adding a package to a changeset for a product that doesnt
  exist would not setup the breadrumb and changeset properly
  (jsherril@redhat.com)
- adding summary of changeset to promotions page (jsherril@redhat.com)
- superadmin columnt in role model (lzap+git@redhat.com)
- ownergeddon - fixing unit tests (lzap+git@redhat.com)
- renaming Candlepin::User to CPUser (lzap+git@redhat.com)
- ownergeddon - organization now belogs to user who created it
  (lzap+git@redhat.com)
- fixing User vs candlepin User reference (lzap+git@redhat.com)
- ownergeddon - superadmin role has access to all orgs (lzap+git@redhat.com)
- ownergeddon - creating superadmin role (lzap+git@redhat.com)
- ownergeddon - removing special user creation (lzap+git@redhat.com)
- changing org-user relationship to plural (lzap+git@redhat.com)
- Adds new button look and feel to errata and repos. (ehelms@redhat.com)
- Typo fix that prevented changeset creation in the UI. (ehelms@redhat.com)
- Fixes broken changeset creation. (ehelms@redhat.com)
- Roles - spec fix: self-role naming no longer dependent on user name
  (bbuckingham@redhat.com)
- Re-refactoring of templateLibrary to remove direct references to
  promotion_page. (ehelms@redhat.com)
- Adds back missing code that makes the right side changeset panel scroll along
  with page. (ehelms@redhat.com)
- 704577 - Role - delete self-role on user delete (bbuckingham@redhat.com)
- Converts promotion_page object into module pattern. (ehelms@redhat.com)
- getting client side sorting working again on the promotions page
  (jsherril@redhat.com)
- moved find_organization() method from api controllers into API_Controller and
  fixed some associated tests. (adprice@redhat.com)
- 717368 - fixing issue where the environment picker would not properly show
  the environment you were on if that environment had no successor
  (jsherril@redhat.com)
- moving changeset buttons to only show up if changesets exist
  (jsherril@redhat.com)
- added support for system registration to an environment in an organization
  (dmitri@redhat.com)
- 704632 -speeding up role rendering (jsherril@redhat.com)
- Roles - update seeds to account for changes to self-role naming
  (bbuckingham@redhat.com)
- Roles - fix delete of user from Roles & Perms tab (bbuckingham@redhat.com)
- Merge branch 'master' into org-subs (mmccune@redhat.com)
- adding locking icons to the changeset list and the breadcrumb bar
  (jsherril@redhat.com)
- including statistics at the org level, pulled in from Headpin
  (mmccune@redhat.com)
- Merge branch 'master' into roles (bbuckingham@redhat.com)
- Changeset list now returns to list of products for that changeset if an item
  removal renders no errata, no repos and no packages for that product and
  removes the product from the list. (ehelms@redhat.com)
- User - self-role name - update to be random generated string
  (bbuckingham@redhat.com)
- Changes promotion page slide_link icon. (ehelms@redhat.com)
- Merge branch 'master' into roles (bbuckingham@redhat.com)
- fixed providers page where promotions link looked up 'locker' instead of
  'Locker' (adprice@redhat.com)
- Roles - refactor self-roles to associated directly with a user
  (bbuckingham@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- Changes to Add/Remove button look and feel across promotion pages.
  (ehelms@redhat.com)
- Add an icon for the promotions page breadcrumb. (jimmac@gmail.com)
- making promotion actually work again (jsherril@redhat.com)
- cleaning up some of katello_client.js (jsherril@redhat.com)
- restriciting promotion based off changeset state (jsherril@redhat.com)
- ownergeddon - adding /users/:username/owners support for sm
  (lzap+git@redhat.com)
- correcting identation in two haml files (lzap+git@redhat.com)
- spec - enabling verbose mode for syntax checking (lzap+git@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- Re-removing previously removed file that got added back by merge.
  (ehelms@redhat.com)
- Merge commit 'eb9c97b3c5b1b1174e3ba4c732690068c9f81f3a' into promotions
  (ehelms@redhat.com)
- adding callback for extended scroll so we can properly reset the page
  (jsherril@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into grid
  (ehelms@redhat.com)
- hiding left hand buttons if changeset is in review phase
  (jsherril@redhat.com)
- Adds data-product_id field to all products for consistency with other
  function calls in promotionjs and fixes adding a product. (ehelms@redhat.com)
- making a locked changeset look different, and not showing add/remove buttons
  on the right if the changeset is locked (jsherril@redhat.com)
- fixing unit tests because of pwd hashing (lzap+git@redhat.com)
- global access to Rake DSL methods is deprecated (lzap+git@redhat.com)
- passwords are stored in secure format (lzap+git@redhat.com)
- default password for admin is 'admin' (lzap+git@redhat.com)
- 717554 - NoMethodError in User sessionsController#create
  (lzap+git@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (jrist@redhat.com)
- Changesets - filter dropdown - initial work on changeset history (might not
  be functional yet). (jrist@redhat.com)
- additional columns added and proper data displayed on page
  (mmccune@redhat.com)
- getting  review/cancel working properly (jsherril@redhat.com)
- listing of systems by environment works now (dmitri@redhat.com)
- specs for changeset controller updates, changesetusers (shughes@redhat.com)
- fixing issue where odd changeset concurrency issue was being taken into
  account even when ti didnt exist (jsherril@redhat.com)
- jquery, css changes for changeset users viewers (shughes@redhat.com)
- made the systems create accept org_name or owner tags (paji@redhat.com)
- Adds breadcrumb creation whenever a blank product is added to the changeset
  as a result of adding packages directly. (ehelms@redhat.com)
- Merge branch 'master' into Locker (adprice@redhat.com)
- Merge branch 'master' into provider_name (adprice@redhat.com)
- first stab at the real data (mmccune@redhat.com)
- Fixes a set of failing tests by setting the prior on a created environment.
  (ehelms@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- Fixes for broken tests. (ehelms@redhat.com)
- fixing issue where package changeset removal was not working
  (jsherril@redhat.com)
- remove debugger statements...oops. (shughes@redhat.com)
- minor syntax fixes to changeset user list in view (shughes@redhat.com)
- varname syntax fix for double render issue (shughes@redhat.com)
- add changeset users to promotions page (shughes@redhat.com)
- Adding back commented out private declaration. (ehelms@redhat.com)
- Adds extra check to ensure product in reset_page exists when doing an all
  check. (ehelms@redhat.com)
- Adds disable all when a full product is added. Fixes typo bug preventing
  changeset deletion. (ehelms@redhat.com)
- Adds button disable/enable on product add/remove. (ehelms@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- Fixes backend error with adding individual packages to changeset.
  (ehelms@redhat.com)
- templates - removal of old code (tstrachota@redhat.com)
- templates - fix for promotions (tstrachota@redhat.com)
- templates - fixed validations (tstrachota@redhat.com)
- templates - inheritance (tstrachota@redhat.com)
- templates - model changed to enable foreign key checking - products
  referenced in associations - new class SystemTemplateErratum - new class
  SystemTenokatePackage (tstrachota@redhat.com)
- templates - products and errata stored as associated records
  (tstrachota@redhat.com)
- templates - lazy accessor attributes in template model
  (tstrachota@redhat.com)
- templates - hostgroup parameters and kickstart attributes merged
  (tstrachota@redhat.com)
- templates - listing package names instead of ids in cli
  (tstrachota@redhat.com)
- templates - CLI for template promotions (tstrachota@redhat.com)
- templates - added cli for updating template content (tstrachota@redhat.com)
- templates - template updates (tstrachota@redhat.com)
- templates - api for editing content of the template (tstrachota@redhat.com)
- templates - reworked model (tstrachota@redhat.com)
- Fixes typos from merge. Adds setting current_changeset upon creating new
  changest. (ehelms@redhat.com)
- Removed debugger statement. (ehelms@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- reverting to a better default changeset name (jsherril@redhat.com)
- Adds ability to add an entire product to a changeset. (ehelms@redhat.com)
- converting the product details partial in the changeset to be rendered client
  side in order to allow for dynamic content (jsherril@redhat.com)
- initial support for system lookup by environment in cli (dmitri@redhat.com)
- spec - fixing whitespace only (lzap+git@redhat.com)
- spec - adding syntax check for haml (lzap+git@redhat.com)
- spec - adding syntax check for ruby (lzap+git@redhat.com)
- moving 'bundle install' from spec to init script (lzap+git@redhat.com)
- Revert "adding bundle install to the spec" (lzap+git@redhat.com)
- Revert "adding bundler rubygem to build requires" (lzap+git@redhat.com)
- properly showing the loading page and not doing a syncronous request
  (jsherril@redhat.com)
- Changed the system register code to use owner instead of org)name
  (paji@redhat.com)
- unifying 'Locker' name throughout API and UI (adprice@redhat.com)
- 2nd pass at copy-paste from headpin (mmccune@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- initial changeset loading screen (jsherril@redhat.com)
- added systems to environments (dmitri@redhat.com)
- fixing changeset rendering to only show changesets.... again
  (jsherril@redhat.com)
- initial copy-paste from headpin (mmccune@redhat.com)
- fixing merge conflicts (jsherril@redhat.com)
- More changes for show on changesets. (jrist@redhat.com)
- adding update for repositories back to seeds.rb (jsherril@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (jrist@redhat.com)
- fixing organizations controller from stray character (jsherril@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- Fixes sliding tree direction regression. (ehelms@redhat.com)
- started on association of consumers with environments (dmitri@redhat.com)
- 714297 - fixed promotions - fixed promotions of products - added promotions
  of packeges - added promotions of errata - added promotions of repositories
  (tstrachota@redhat.com)
- fixing bbq with changesets on the promotion page (jsherril@redhat.com)
- adding repos/errata to changeset with working add/remove, removing some old
  code as well (jsherril@redhat.com)
- 705563 - fixed issue where provider name could not be modified after creating
  repos for said provider (adprice@redhat.com)
- commenting out sort function temporarily since sliding changes broke it
  (jsherril@redhat.com)
- getting add/remove of packages working much much better (jsherril@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (jrist@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (jrist@redhat.com)
- Small fix to get slidingtree sliding smoother. (ehelms@redhat.com)
- Search addition to breadcrumb in Changesets. (jrist@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- On promotions page, right tree, makes it such that the changesets panel will
  float alongside the left side on scroll.  Fixes slide animation to not show
  ghosts. (ehelms@redhat.com)
- fixing promotions page to show correct changesets (jsherril@redhat.com)
- package rendering in javascript (jsherril@redhat.com)
- adding bundler rubygem to build requires (lzap+git@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (jrist@redhat.com)
- Small changes here and there for the promotions and changesets pages.
  (jrist@redhat.com)
- adding bundle install to the spec (lzap+git@redhat.com)
- Fixes add and delete of changesets to work with new rendering scheme.
  (ehelms@redhat.com)
- add/remove items from the changeset object client side when the user does so
  in the UI (jsherril@redhat.com)
- changing the way the render_cb functions to pass the content back to the
  sliding tree (jsherril@redhat.com)
- fixing the add/remove of changeset items (jsherril@redhat.com)
- Adds start of client-side javascript templating library for changesets and
  initial renderers.  Renders changesets list via breadcrumbs data object and
  templates from template library. (ehelms@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- intial work for client side changeset rendering (jsherril@redhat.com)
- Merge branch 'master' into provider_repo (adprice@redhat.com)
- fixed provider url validation and added/fixed tests (adprice@redhat.com)
- adding a packages page to promotions (jsherril@redhat.com)
- Adds remove functionality for a changeset to the UI. (ehelms@redhat.com)
- js header modifications for changeset user editors (shughes@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (adprice@redhat.com)
- fixed environment creation to allow lockers to have multiple priors and added
  tests (adprice@redhat.com)
- removed bypass warden strategy (dmitri@redhat.com)
- Merge branch 'master' into env_tests (adprice@redhat.com)
- Fixes systems controller test 'should show the system 2 pane list'.
  (ehelms@redhat.com)
- User creation errors will now be displayed in notices properly.
  (ehelms@redhat.com)
- fixed UI environment creation failure (adprice@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- Adds re-vamped changeset creation to fit with creation of changests from the
  UI.  Modifies changeset breadcrumb creation and functionality to allow for
  switching tree contexts upon changeset creation. (ehelms@redhat.com)
- Fixes typo causing wrong name to display in changeset breadcrumbs.
  (ehelms@redhat.com)
- adding condstop to the katello init script (lzap+git@redhat.com)
- adding page reloading as the changeset changes (jsherril@redhat.com)
- spec test for empty changesetuser on index view (shughes@redhat.com)
- Merge branch 'master' into promotions (jrist@redhat.com)
- fixing bug with ChangesetUser (jsherril@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- making changsets be stored client side, lots still broken
  (jsherril@redhat.com)
- adding controller logic and spec test for changesetuser destroy
  (shughes@redhat.com)
- adding find or create spec test for changeset model (shughes@redhat.com)
- Fixes to create and delete changesets properly with associated test fixes.
  (ehelms@redhat.com)
- Removed previous default name setting in kp_environment changeset creation
  and moved it into the changeset model. (ehelms@redhat.com)
- Added create and delete, tests for each and corresponding routes.
  (ehelms@redhat.com)
- Changed to use id(passed in via locals) instead of the @id(instance
  variable). (ehelms@redhat.com)
- Adds validations to changeset name to conform with Katello standards, provide
  uniqueness across environments and create a default name for the changeset
  auto-generated when an environment is created. (ehelms@redhat.com)
- local var changes for changeset spec (shughes@redhat.com)
- initial changeset model spec (shughes@redhat.com)
- fixing issue where promotions would throw an error if next environment did
  not exist (jsherril@redhat.com)
- Merge branch 'master' into promotions (jrist@redhat.com)
- adding initial changeset revamp (jsherril@redhat.com)
- initial schema for tracking changeset users (shughes@redhat.com)
- pulling out the slidingtree and putting it into a form that is reusable on
  the same page (jsherril@redhat.com)

* Fri Jul 15 2011 Eric D Helms <eric.d.helms@gmail.com>
- Updates to use version 0.11.5 or greater of Compass. (eric.d.helms@gmail.com)
- Adds padding to empty changeset text. (eric.d.helms@gmail.com)
- Merge branch 'master' into refactor (eric.d.helms@gmail.com)
- initdb does not print unnecessary info anymore (lzap+git@redhat.com)
- ignoring ping.rb in code coverage (lzap+git@redhat.com)
- do not install .gitkeep files (msuchy@redhat.com)
- setting failure threshold to code coverage to 60 % (lzap+git@redhat.com)
- adding failure threshold to code doverage (lzap+git@redhat.com)
- 720414 - fixing issue where hitting enter while on the new changeset name box
  would result in a form submitting (jsherril@redhat.com)
- get unit tests working with rconv (lzap+git@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (adprice@redhat.com)
- spec test fix (jsherril@redhat.com)
- improving env_selector to auto-select the path properly so the controller
  doesnt have to (jsherril@redhat.com)
- fixing the env_selector to properly display secondary paths, this broke at
  some point (jsherril@redhat.com)
- system info - adding /api/systems/:uuid/packages controller
  (lzap+git@redhat.com)
- ignoring coverage/ dir (lzap+git@redhat.com)
- merging systems resource in the routes into one (lzap+git@redhat.com)
- Merge branch 'master' into templates (adprice@redhat.com)
- fixing broken unit tests (jsherril@redhat.com)
- 720431 - fixing issue where creating a changeset that already exists would
  fail silently (jsherril@redhat.com)
- fixing stray comman in promotion.js (jsherril@redhat.com)
- Merge branch 'master' into refactor (eric.d.helms@gmail.com)
- added ability to track pulp async jobs through katello task api
  (dmitri@redhat.com)
- updating localization strings for zanata server (shughes@redhat.com)
- removing katello_client.js from assets and removing inclusions in all haml
  files (jsherril@redhat.com)
- refactoring javascript to get rid of katello_client.js (jsherril@redhat.com)
- changing level inclusion validator of notices to handle the string forms of
  the types, so a notice can actually be saved if modified
  (jsherril@redhat.com)
- 717714: adding friendly sync conflict messaging (shughes@redhat.com)
- remove js debug alerts from sync (shughes@redhat.com)
- refactoring environment creation/deleteion in javascript to not use
  katello_client.js (jsherril@redhat.com)
- refactoring role.js to be more modular and not have global functions
  (jsherril@redhat.com)
- Added permission enforcement for all_verbs and all_tags (paji@redhat.com)
- system info - systems list now supports name query param
  (lzap+git@redhat.com)
- auto_complete_search - move routes in to collection blocks
  (bbuckingham@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (mmccune@redhat.com)
- adding spec test (mmccune@redhat.com)
- hopefully done changing 'locker' to 'Locker' (adprice@redhat.com)
- CSS Refactor - more cleanup and removal of old unused css.
  (ehelms@redhat.com)
- adding tests for listing templates (adprice@redhat.com)
- CSS Refactor - Large scale cleanup of old CSS. Moved chunks of css to the
  appropriate page level css files. (ehelms@redhat.com)
- Merge branch 'master' into templates (adprice@redhat.com)
- cleanup of user.js and affected views/routes (jsherril@redhat.com)
- reworking template list to work with existing code in client
  (adprice@redhat.com)
- 715422: update sync mgt status method and routes to use non reserved name
  (shughes@redhat.com)
- 713959: add 'none' interval type to sync plan edit, add rspec test
  (shughes@redhat.com)
- spec path test for promotions env (shughes@redhat.com)
- rspec for systems environment selections (shughes@redhat.com)
- env selector for systems and env model refactor (shughes@redhat.com)
- add new route and trilevel nav for registered systems (shughes@redhat.com)
- env selector support for systems listing (shughes@redhat.com)
- fixed a broken test (dmitri@redhat.com)
- added ability to persist results of async operations (dmitri@redhat.com)
- Merge branch 'master' into refactor (ehelms@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (ehelms@redhat.com)
- fix for env-selector not selecting the correct path if an environment is
  selected (jsherril@redhat.com)
- CSS Refactor - Combines all the css for the environment selector into sass
  nesting format. (ehelms@redhat.com)
- Merge branch 'master' into org-subs (mmccune@redhat.com)
- added requirement of org and env when listing templates via api
  (adprice@redhat.com)
- CSS Refactor - converts all color variables to end in _color for readability
  and organization. (ehelms@redhat.com)
- CSS Refactor - Moved each section stylesheet into a sections folder. Removed
  all colors from _base and moved them into a _colors css file. Re-named _base
  to _mixins as a place to define and have project wide css mixins. Moved all
  imports to katello.scss and it is now being treated as the base level scss
  import. (ehelms@redhat.com)
- CSS Refactor - Moves all basic css imports to base (e.g. grid, text, sprits).
  Removes katello.css directly from page, and instead each section css file
  (e.g. contents, dashboard) imports katello.scss.  The intent is for
  katello.scss to hold cross-app and re-usable css while each individual
  section scss file will hold overrides and custom css. (ehelms@redhat.com)
- CSS Refactor - Moves icon and image sprites out to seperate file for easier
  reference and to aid in any future spriting. (ehelms@redhat.com)
- Commits missing file to stop Jammit warning. (ehelms@redhat.com)
- Notifications polling time increased to 2 minutes. Small fix for
  subscriptions helptip. (jrist@redhat.com)
- Provider - update controller to query based on current org
  (bbuckingham@redhat.com)
- added optional functionality for org and environment inclusion in template
  viewing (adprice@redhat.com)
- 720003 - moves page load notifications inside document ready function to
  properly display across browsers (ehelms@redhat.com)
- 720002 - Adds generic css file for notification page to conform with css file
  for each main page. (ehelms@redhat.com)
- fixed tests broken by async job merge (dmitri@redhat.com)
- removed a bit of async job sample code from api/systems_controller
  (dmitri@redhat.com)
- merging async job status tracking changes into master (dmitri@redhat.com)
- uuid value is now being stored in Delayed::Job uuid field (dmitri@redhat.com)
- added uuidtools gem requirements into Gemfile and katello.spec
  (dmitri@redhat.com)
- added uuids to track status of async jobs (dmitri@redhat.com)
- spec - moving syntax checks to external script (CI) (lzap+git@redhat.com)
- users - better logging during authentication (lzap+git@redhat.com)
- users - updating bash completion (lzap+git@redhat.com)
- users - adding support for users CRUD in CLI (lzap+git@redhat.com)
- api auth code stores user/pass with auth_ prefix (lzap+git@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (ehelms@redhat.com)
- Added missing loginpage css file. (ehelms@redhat.com)
- add daemons gem dep for delayed job (shughes@redhat.com)
- Adds section in head of katello.yml for including extra javascripts from a
  template view.  This is intended to move included javascripts out of the
  body. (ehelms@redhat.com)
- Moves locked icon on breadcrumbs next to the changeset name instead of at the
  front of the breadcrumb list. (ehelms@redhat.com)
- Moves subheader, maincontent and footer up a few pixels. (ehelms@redhat.com)
- Adds new option to sliding tree - base_icon for displaying an image as the
  first breadcrumb instead of text. Modifies changeset breadcrumbs to use home
  icon for first breadcrumb. (ehelms@redhat.com)
- fixed a config issue with delayed jobs (dmitri@redhat.com)
- delayed jobs are now associated with organizations (dmitri@redhat.com)
- Adds big logo to empty dashboard page. (ehelms@redhat.com)
- first cut at tracking of async jobs (dmitri@redhat.com)
- Adding breadcrumb icon sprite. (jimmac@gmail.com)
- speed up header spinner, more style-appropriate grabber (jimmac@gmail.com)
- Added whitespace on the sides of help-tips looks very unbalanced.
  (jimmac@gmail.com)
- Same spinner for the header as it is in the body. Might need to invert to
  white. (jimmac@gmail.com)
- Update header to the latest upstream design. (jimmac@gmail.com)
- clean up favicon. (jimmac@gmail.com)
- 719414 - changest:  New changeset view now returns message instructing user
  that a changeset cannot be created if a next environment is not present for
  the current environment. (ehelms@redhat.com)
- continuing to fix capital 'Locker' (adprice@redhat.com)
- spec - more tests for permissions (super admin) (lzap+git@redhat.com)
- spec - making permission_spec much faster (lzap+git@redhat.com)
- adding new spec tests for promotions controller (jsherril@redhat.com)
- Fix copyright on several files (bbuckingham@redhat.com)
- fixed an error in katello.spec (dmitri@redhat.com)
- fixing changeset deletion client side (jsherril@redhat.com)
- fixing odd promotions button issues caused by removing the default changeset
  upon environment creation (jsherril@redhat.com)
- Merge branch 'errors' (dmitri@redhat.com)
- added delayed_job gem dependency (dmitri@redhat.com)
- 2pane column sorter module helper for controllers (shughes@redhat.com)
- Provider - Update so that 'remove provider' link is accessible from subpanels
  (bbuckingham@redhat.com)
- errors are now being returned in an array, under :errors hash key
  (dmitri@redhat.com)
- Merge branch 'promotions' (jsherril@redhat.com)
- removing the automatic creating of changesets, since you can now create them
  manually (jsherril@redhat.com)
- prompting the user if they are leaving the promotions page with unsaved
  changeset changes (jsherril@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- Makes current crumb different color than the rest of the breadcrumbs. Adds
  highlighting of list items in changeset trees. (ehelms@redhat.com)
- added delayed_job gem dependency (dmitri@redhat.com)
- adding wait dialog when switching out of a changeset if updates are left to
  process (jsherril@redhat.com)
- update po files for translation (shughes@redhat.com)
- Fixes lock image location when changeset is being promoted and breadcrumbs
  attempt to wrap. (ehelms@redhat.com)
- Re-works scroll mechanism in sliding tree to handle left-right scrolling with
  container of any height or fixed height containers that need scrollable
  overflow. (ehelms@redhat.com)
- remove flies config (shughes@redhat.com)
- adding waiting indicator prior to review if there is still items to process
  in the queue (jsherril@redhat.com)
- Promotion page look and feel changes. Border and background colors of left
  and right panels changed. Border color of search filter changed.
  (ehelms@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- Merge branch 'master' into sso-prototype (bbuckingham@redhat.com)
- fixing issue where adding a partial product after a full product would result
  in not being able to browse the partial product (jsherril@redhat.com)
- Merge branch 'master' into url_format (adprice@redhat.com)
- Added default env upon entering changeset history page. (jrist@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (jrist@redhat.com)
- Ajax listing and searching on Changeset History page. (jrist@redhat.com)
- SSO - prototype - additional mods for error handling (bbuckingham@redhat.com)
- Login - fix error message when user logs in with invalid credentials
  (bbuckingham@redhat.com)
- SSO - update warden for HTTP_X_FORWARDED_USER (bbuckingham@redhat.com)
- added support for sso auth in ui and api controllers (dmitri@redhat.com)
- fixing issue where promotion would redirect to the incorrect environment
  (jsherril@redhat.com)
- updated katello url format validator with port number options.
  (adprice@redhat.com)
- Initial promotion QUnit page tests. (ehelms@redhat.com)
- fixing issue where creating a changeset make it appear to be locked
  (jsherril@redhat.com)
- added more tests around system registration with environments
  (dmitri@redhat.com)
- fixed a bunch of failing tests (dmitri@redhat.com)
- got rhsm client mostly working with system registration with environments
  (dmitri@redhat.com)
- fixed merging conflicts (dmitri@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (jrist@redhat.com)
- In-place search for changesets. (jrist@redhat.com)
- fixing previous notices change to work with polling as well, and work around
  issue whith update after a query would result in the query not actually
  returning anything retroactively (jsherril@redhat.com)
- fixing promotions redirection and notices not actually rendering properly on
  page load (jsherril@redhat.com)
- added/modified some tests and fixed a typo (adprice@redhat.com)
- removed unused code after commenting on a previous commit.
  (adprice@redhat.com)
- 703528 - checks provider url for valid format (adprice@redhat.com)
- templates - tests for controller (tstrachota@redhat.com)
- templates - tests for the model (tstrachota@redhat.com)
- added api-namespace resource discovery (dmitri@redhat.com)
- Role: sort permission type alphabetically (bbuckingham@redhat.com)
- stop changeset modifications when changeset is in the correct state
  (jsherril@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- Splits product list in changeset into Full Products and Partial Products.
  Full Products can be removed but Partial Products cannot. (ehelms@redhat.com)
- adding next environment name to promote button (jsherril@redhat.com)
- fixing text vs varchar problem on pgsql (lzap+git@redhat.com)
- roles - disabled flag is now in effect (lzap+git@redhat.com)
- roles - adding disabled flag to users (lzap+git@redhat.com)
- possibility to run rake setup without REST interaction (lzap+git@redhat.com)
- roles - adding description column to roles (lzap+git@redhat.com)
- roles - role name may contain spaces now (lzap+git@redhat.com)
- roles - self-roles now named 'username_salt' (lzap+git@redhat.com)
- roles - giving fancy names to basic roles (lzap+git@redhat.com)
- roles - superadmin role allowed by default, new reader role
  (lzap+git@redhat.com)
- roles - setting permissions rather on superadmin role than admin self-role
  (lzap+git@redhat.com)
- roles - reordering and cleaning seeds.rb (lzap+git@redhat.com)
- templates - added foreign key reference to environments
  (tstrachota@redhat.com)
- navigation for subscriptions page (mmccune@redhat.com)
- Merge branch 'org-subs' of ssh://git.fedorahosted.org/git/katello into org-
  subs (mmccune@redhat.com)
- Added Expand/Contract All (jrist@redhat.com)
- Fix for firt-child of TD not being aligned properly with expanding tree.
  (jrist@redhat.com)
- Merge branch 'master' into org-subs (mmccune@redhat.com)
- making the resizable panel not resizable for promotions (jsherril@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- fixing callback call that was cuasing lots of issues with promotions
  (jsherril@redhat.com)
- Fixes issue with multiple icons appearing in changeset breadcrumbs.
  (ehelms@redhat.com)
- Merge branch 'master' into url_format (adprice@redhat.com)
- 718054: updating gem requirements to match Gemfile versions
  (shughes@redhat.com)
- update to get sparklines going (mmccune@redhat.com)
- added spec for api/systems_controller (dmitri@redhat.com)
- force 2.3.1 version of scoped search for katello installs; supports sorting
  (shughes@redhat.com)
- Small fix for breadcrumb not expanding to full height. (jrist@redhat.com)
- Fixed #changeset_tree moving over when scrolling. (jrist@redhat.com)
- moved find_organization() method from api controllers into API_Controller and
  fixed some associated tests. (adprice@redhat.com)
- Small fix for closing filter. (jrist@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (jrist@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (jrist@redhat.com)
- fixed broken tests (dmitri@redhat.com)
- 703528 - checks provider url for valid format (adprice@redhat.com)
- fixing  issue with promotions page and no environment after locker
  (jsherril@redhat.com)
- adding additional javascript and removing debugger (mmccune@redhat.com)
- Filter working on right changeset for current .has_content selector.
  (jrist@redhat.com)
- updating gemlock for scoped_search changes (shughes@redhat.com)
- sorting systems on both ar/non ar data from cp (shughes@redhat.com)
- scoped_search gem support for column sorting (shughes@redhat.com)
- 2pane support for AR/NONAR column sorting (shughes@redhat.com)
- Merge branch 'master' into roles (bbuckingham@redhat.com)
- fixing issue where adding a package to a changeset for a product that doesnt
  exist would not setup the breadrumb and changeset properly
  (jsherril@redhat.com)
- adding summary of changeset to promotions page (jsherril@redhat.com)
- superadmin columnt in role model (lzap+git@redhat.com)
- ownergeddon - fixing unit tests (lzap+git@redhat.com)
- renaming Candlepin::User to CPUser (lzap+git@redhat.com)
- ownergeddon - organization now belogs to user who created it
  (lzap+git@redhat.com)
- fixing User vs candlepin User reference (lzap+git@redhat.com)
- ownergeddon - superadmin role has access to all orgs (lzap+git@redhat.com)
- ownergeddon - creating superadmin role (lzap+git@redhat.com)
- ownergeddon - removing special user creation (lzap+git@redhat.com)
- changing org-user relationship to plural (lzap+git@redhat.com)
- Adds new button look and feel to errata and repos. (ehelms@redhat.com)
- Typo fix that prevented changeset creation in the UI. (ehelms@redhat.com)
- Fixes broken changeset creation. (ehelms@redhat.com)
- Roles - spec fix: self-role naming no longer dependent on user name
  (bbuckingham@redhat.com)
- Re-refactoring of templateLibrary to remove direct references to
  promotion_page. (ehelms@redhat.com)
- Adds back missing code that makes the right side changeset panel scroll along
  with page. (ehelms@redhat.com)
- 704577 - Role - delete self-role on user delete (bbuckingham@redhat.com)
- Converts promotion_page object into module pattern. (ehelms@redhat.com)
- getting client side sorting working again on the promotions page
  (jsherril@redhat.com)
- moved find_organization() method from api controllers into API_Controller and
  fixed some associated tests. (adprice@redhat.com)
- 717368 - fixing issue where the environment picker would not properly show
  the environment you were on if that environment had no successor
  (jsherril@redhat.com)
- moving changeset buttons to only show up if changesets exist
  (jsherril@redhat.com)
- added support for system registration to an environment in an organization
  (dmitri@redhat.com)
- 704632 -speeding up role rendering (jsherril@redhat.com)
- Roles - update seeds to account for changes to self-role naming
  (bbuckingham@redhat.com)
- Roles - fix delete of user from Roles & Perms tab (bbuckingham@redhat.com)
- Merge branch 'master' into org-subs (mmccune@redhat.com)
- adding locking icons to the changeset list and the breadcrumb bar
  (jsherril@redhat.com)
- including statistics at the org level, pulled in from Headpin
  (mmccune@redhat.com)
- Merge branch 'master' into roles (bbuckingham@redhat.com)
- Changeset list now returns to list of products for that changeset if an item
  removal renders no errata, no repos and no packages for that product and
  removes the product from the list. (ehelms@redhat.com)
- User - self-role name - update to be random generated string
  (bbuckingham@redhat.com)
- Changes promotion page slide_link icon. (ehelms@redhat.com)
- Merge branch 'master' into roles (bbuckingham@redhat.com)
- fixed providers page where promotions link looked up 'locker' instead of
  'Locker' (adprice@redhat.com)
- Roles - refactor self-roles to associated directly with a user
  (bbuckingham@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- Changes to Add/Remove button look and feel across promotion pages.
  (ehelms@redhat.com)
- Add an icon for the promotions page breadcrumb. (jimmac@gmail.com)
- making promotion actually work again (jsherril@redhat.com)
- cleaning up some of katello_client.js (jsherril@redhat.com)
- restriciting promotion based off changeset state (jsherril@redhat.com)
- ownergeddon - adding /users/:username/owners support for sm
  (lzap+git@redhat.com)
- correcting identation in two haml files (lzap+git@redhat.com)
- spec - enabling verbose mode for syntax checking (lzap+git@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- Re-removing previously removed file that got added back by merge.
  (ehelms@redhat.com)
- Merge commit 'eb9c97b3c5b1b1174e3ba4c732690068c9f81f3a' into promotions
  (ehelms@redhat.com)
- adding callback for extended scroll so we can properly reset the page
  (jsherril@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into grid
  (ehelms@redhat.com)
- hiding left hand buttons if changeset is in review phase
  (jsherril@redhat.com)
- Adds data-product_id field to all products for consistency with other
  function calls in promotionjs and fixes adding a product. (ehelms@redhat.com)
- making a locked changeset look different, and not showing add/remove buttons
  on the right if the changeset is locked (jsherril@redhat.com)
- fixing unit tests because of pwd hashing (lzap+git@redhat.com)
- global access to Rake DSL methods is deprecated (lzap+git@redhat.com)
- passwords are stored in secure format (lzap+git@redhat.com)
- default password for admin is 'admin' (lzap+git@redhat.com)
- 717554 - NoMethodError in User sessionsController#create
  (lzap+git@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (jrist@redhat.com)
- Changesets - filter dropdown - initial work on changeset history (might not
  be functional yet). (jrist@redhat.com)
- additional columns added and proper data displayed on page
  (mmccune@redhat.com)
- getting  review/cancel working properly (jsherril@redhat.com)
- listing of systems by environment works now (dmitri@redhat.com)
- specs for changeset controller updates, changesetusers (shughes@redhat.com)
- fixing issue where odd changeset concurrency issue was being taken into
  account even when ti didnt exist (jsherril@redhat.com)
- jquery, css changes for changeset users viewers (shughes@redhat.com)
- made the systems create accept org_name or owner tags (paji@redhat.com)
- Adds breadcrumb creation whenever a blank product is added to the changeset
  as a result of adding packages directly. (ehelms@redhat.com)
- Merge branch 'master' into Locker (adprice@redhat.com)
- Merge branch 'master' into provider_name (adprice@redhat.com)
- first stab at the real data (mmccune@redhat.com)
- Fixes a set of failing tests by setting the prior on a created environment.
  (ehelms@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- Fixes for broken tests. (ehelms@redhat.com)
- fixing issue where package changeset removal was not working
  (jsherril@redhat.com)
- remove debugger statements...oops. (shughes@redhat.com)
- minor syntax fixes to changeset user list in view (shughes@redhat.com)
- varname syntax fix for double render issue (shughes@redhat.com)
- add changeset users to promotions page (shughes@redhat.com)
- Adding back commented out private declaration. (ehelms@redhat.com)
- Adds extra check to ensure product in reset_page exists when doing an all
  check. (ehelms@redhat.com)
- Adds disable all when a full product is added. Fixes typo bug preventing
  changeset deletion. (ehelms@redhat.com)
- Adds button disable/enable on product add/remove. (ehelms@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- Fixes backend error with adding individual packages to changeset.
  (ehelms@redhat.com)
- templates - removal of old code (tstrachota@redhat.com)
- templates - fix for promotions (tstrachota@redhat.com)
- templates - fixed validations (tstrachota@redhat.com)
- templates - inheritance (tstrachota@redhat.com)
- templates - model changed to enable foreign key checking - products
  referenced in associations - new class SystemTemplateErratum - new class
  SystemTenokatePackage (tstrachota@redhat.com)
- templates - products and errata stored as associated records
  (tstrachota@redhat.com)
- templates - lazy accessor attributes in template model
  (tstrachota@redhat.com)
- templates - hostgroup parameters and kickstart attributes merged
  (tstrachota@redhat.com)
- templates - listing package names instead of ids in cli
  (tstrachota@redhat.com)
- templates - CLI for template promotions (tstrachota@redhat.com)
- templates - added cli for updating template content (tstrachota@redhat.com)
- templates - template updates (tstrachota@redhat.com)
- templates - api for editing content of the template (tstrachota@redhat.com)
- templates - reworked model (tstrachota@redhat.com)
- Fixes typos from merge. Adds setting current_changeset upon creating new
  changest. (ehelms@redhat.com)
- Removed debugger statement. (ehelms@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- reverting to a better default changeset name (jsherril@redhat.com)
- Adds ability to add an entire product to a changeset. (ehelms@redhat.com)
- converting the product details partial in the changeset to be rendered client
  side in order to allow for dynamic content (jsherril@redhat.com)
- initial support for system lookup by environment in cli (dmitri@redhat.com)
- spec - fixing whitespace only (lzap+git@redhat.com)
- spec - adding syntax check for haml (lzap+git@redhat.com)
- spec - adding syntax check for ruby (lzap+git@redhat.com)
- moving 'bundle install' from spec to init script (lzap+git@redhat.com)
- Revert "adding bundle install to the spec" (lzap+git@redhat.com)
- Revert "adding bundler rubygem to build requires" (lzap+git@redhat.com)
- properly showing the loading page and not doing a syncronous request
  (jsherril@redhat.com)
- Changed the system register code to use owner instead of org)name
  (paji@redhat.com)
- unifying 'Locker' name throughout API and UI (adprice@redhat.com)
- 2nd pass at copy-paste from headpin (mmccune@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- initial changeset loading screen (jsherril@redhat.com)
- added systems to environments (dmitri@redhat.com)
- fixing changeset rendering to only show changesets.... again
  (jsherril@redhat.com)
- initial copy-paste from headpin (mmccune@redhat.com)
- fixing merge conflicts (jsherril@redhat.com)
- More changes for show on changesets. (jrist@redhat.com)
- adding update for repositories back to seeds.rb (jsherril@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (jrist@redhat.com)
- fixing organizations controller from stray character (jsherril@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- Fixes sliding tree direction regression. (ehelms@redhat.com)
- started on association of consumers with environments (dmitri@redhat.com)
- 714297 - fixed promotions - fixed promotions of products - added promotions
  of packeges - added promotions of errata - added promotions of repositories
  (tstrachota@redhat.com)
- fixing bbq with changesets on the promotion page (jsherril@redhat.com)
- adding repos/errata to changeset with working add/remove, removing some old
  code as well (jsherril@redhat.com)
- 705563 - fixed issue where provider name could not be modified after creating
  repos for said provider (adprice@redhat.com)
- commenting out sort function temporarily since sliding changes broke it
  (jsherril@redhat.com)
- getting add/remove of packages working much much better (jsherril@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (jrist@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (jrist@redhat.com)
- Small fix to get slidingtree sliding smoother. (ehelms@redhat.com)
- Search addition to breadcrumb in Changesets. (jrist@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- On promotions page, right tree, makes it such that the changesets panel will
  float alongside the left side on scroll.  Fixes slide animation to not show
  ghosts. (ehelms@redhat.com)
- fixing promotions page to show correct changesets (jsherril@redhat.com)
- package rendering in javascript (jsherril@redhat.com)
- adding bundler rubygem to build requires (lzap+git@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (jrist@redhat.com)
- Small changes here and there for the promotions and changesets pages.
  (jrist@redhat.com)
- adding bundle install to the spec (lzap+git@redhat.com)
- Fixes add and delete of changesets to work with new rendering scheme.
  (ehelms@redhat.com)
- add/remove items from the changeset object client side when the user does so
  in the UI (jsherril@redhat.com)
- changing the way the render_cb functions to pass the content back to the
  sliding tree (jsherril@redhat.com)
- fixing the add/remove of changeset items (jsherril@redhat.com)
- Adds start of client-side javascript templating library for changesets and
  initial renderers.  Renders changesets list via breadcrumbs data object and
  templates from template library. (ehelms@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- intial work for client side changeset rendering (jsherril@redhat.com)
- Merge branch 'master' into provider_repo (adprice@redhat.com)
- fixed provider url validation and added/fixed tests (adprice@redhat.com)
- adding a packages page to promotions (jsherril@redhat.com)
- Adds remove functionality for a changeset to the UI. (ehelms@redhat.com)
- js header modifications for changeset user editors (shughes@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (adprice@redhat.com)
- fixed environment creation to allow lockers to have multiple priors and added
  tests (adprice@redhat.com)
- removed bypass warden strategy (dmitri@redhat.com)
- Merge branch 'master' into env_tests (adprice@redhat.com)
- Fixes systems controller test 'should show the system 2 pane list'.
  (ehelms@redhat.com)
- User creation errors will now be displayed in notices properly.
  (ehelms@redhat.com)
- fixed UI environment creation failure (adprice@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- Adds re-vamped changeset creation to fit with creation of changests from the
  UI.  Modifies changeset breadcrumb creation and functionality to allow for
  switching tree contexts upon changeset creation. (ehelms@redhat.com)
- Fixes typo causing wrong name to display in changeset breadcrumbs.
  (ehelms@redhat.com)
- adding condstop to the katello init script (lzap+git@redhat.com)
- adding page reloading as the changeset changes (jsherril@redhat.com)
- spec test for empty changesetuser on index view (shughes@redhat.com)
- Merge branch 'master' into promotions (jrist@redhat.com)
- fixing bug with ChangesetUser (jsherril@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- making changsets be stored client side, lots still broken
  (jsherril@redhat.com)
- adding controller logic and spec test for changesetuser destroy
  (shughes@redhat.com)
- adding find or create spec test for changeset model (shughes@redhat.com)
- Fixes to create and delete changesets properly with associated test fixes.
  (ehelms@redhat.com)
- Removed previous default name setting in kp_environment changeset creation
  and moved it into the changeset model. (ehelms@redhat.com)
- Added create and delete, tests for each and corresponding routes.
  (ehelms@redhat.com)
- Changed to use id(passed in via locals) instead of the @id(instance
  variable). (ehelms@redhat.com)
- Adds validations to changeset name to conform with Katello standards, provide
  uniqueness across environments and create a default name for the changeset
  auto-generated when an environment is created. (ehelms@redhat.com)
- local var changes for changeset spec (shughes@redhat.com)
- initial changeset model spec (shughes@redhat.com)
- fixing issue where promotions would throw an error if next environment did
  not exist (jsherril@redhat.com)
- Merge branch 'master' into promotions (jrist@redhat.com)
- adding initial changeset revamp (jsherril@redhat.com)
- initial schema for tracking changeset users (shughes@redhat.com)
- pulling out the slidingtree and putting it into a form that is reusable on
  the same page (jsherril@redhat.com)

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
