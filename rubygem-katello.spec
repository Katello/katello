%{?scl:%scl_package rubygem-%{gem_name}}
%{!?scl:%global pkg_name %{name}}

%global gem_name katello

%global foreman_dir /usr/share/foreman
%global foreman_bundlerd_dir %{foreman_dir}/bundler.d

%if !("%{?scl}" == "ruby193" || 0%{?rhel} > 6 || 0%{?fedora} > 16)
%global gem_dir /usr/lib/ruby/gems/1.8
%global gem_instdir %{gem_dir}/gems/%{gem_name}-%{version}
%global gem_libdir %{gem_instdir}/lib
%global gem_cache %{gem_dir}/cache/%{gem_name}-%{version}.gem
%global gem_spec %{gem_dir}/specifications/%{gem_name}-%{version}.gemspec
%global gem_docdir %{gem_dir}/doc/%{gem_name}-%{version}
%endif

%if "%{?scl}" == "ruby193"
    %global scl_ruby /usr/bin/ruby193-ruby
    %global scl_rake /usr/bin/ruby193-rake
    ### TODO temp disabled for SCL
    %global nodoc 1
%else
    %global scl_ruby /usr/bin/ruby
    %global scl_rake /usr/bin/rake
%endif

Summary: Katello
Name: %{?scl_prefix}rubygem-%{gem_name}

Version: 2.1.0
Release: 1%{dist}
Group: Development/Ruby
License: Distributable
URL: http://www.katello.org
Source0: http://rubygems.org/downloads/%{gem_name}-%{version}.gem

%if "%{?scl}" == "ruby193"
Requires: %{?scl_prefix}ruby-wrapper
BuildRequires: %{?scl_prefix}ruby-wrapper
%endif
%if "%{?scl}" == "ruby193" || 0%{?rhel} > 6 || 0%{?fedora} > 16
BuildRequires:  %{?scl_prefix}rubygems-devel
%endif

%if 0%{?fedora} > 19
Requires: %{?scl_prefix}ruby(release) = 2.0.0
BuildRequires: %{?scl_prefix}ruby(release) = 2.0.0
%else
%if "%{?scl}" == "ruby193" || 0%{?rhel} > 6 || 0%{?fedora} > 16
Requires: %{?scl_prefix}ruby(abi) = 1.9.1
BuildRequires: %{?scl_prefix}ruby(abi) = 1.9.1
%else
Requires: ruby(abi) = 1.8
BuildRequires: ruby(abi) = 1.8
%endif
%endif

# service-wait dependency
Requires: wget
Requires: curl

%if 0%{?rhel} == 6
Requires: redhat-logos >= 60.0.14
%endif

%if 0%{?fedora} > 18 || 0%{?rhel} > 6
Requires(post): candlepin-tomcat
%else
Requires(post): candlepin-tomcat6
%endif

Requires(post): chkconfig
Requires(postun): initscripts coreutils sed
Requires(pre): shadow-utils
Requires(preun): chkconfig
Requires(preun): initscripts

#Pulp Requirements
Requires: pulp-katello
Requires: pulp-nodes-parent
Requires: pulp-puppet-plugins
Requires: pulp-rpm-plugins
Requires: pulp-puppet-tools
Requires: pulp-selinux
Requires: pulp-server
Requires: mongodb >= 2.4
Requires: mongodb-server >= 2.4
Requires: cyrus-sasl-plain

Requires: candlepin-selinux
Requires: createrepo >= 0.9.9-18%{?dist}
Requires: elasticsearch
Requires: foreman >= 1.3.0
Requires: java-openjdk >= 1:1.7.0
# Still Requires katello-common which clashes with
# new build - will re-enable after fixing
#Requires: katello-selinux
Requires: libvirt-devel
Requires: lsof
Requires: postgresql
Requires: postgresql-server
Requires: v8
Requires: %{?scl_prefix}rubygems
Requires: %{?scl_prefix}rubygem-angular-rails-templates >= 0.0.4
Requires: %{?scl_prefix}rubygem-rails
Requires: %{?scl_prefix}rubygem-json
Requires: %{?scl_prefix}rubygem-oauth
Requires: %{?scl_prefix}rubygem-rest-client
Requires: %{?scl_prefix}rubygem-foreigner => 1.4.2
Requires: %{?scl_prefix}rubygem-foreigner < 1.5
Requires: %{?scl_prefix}rubygem-uuidtools
Requires: %{?scl_prefix}rubygem-rabl
Requires: %{?scl_prefix}rubygem-tire => 0.6.2
Requires: %{?scl_prefix}rubygem-tire < 0.7
Requires: %{?scl_prefix}rubygem-logging >= 1.8.0
Requires: %{?scl_prefix}rubygem-hooks
Requires: %{?scl_prefix}rubygem-foreman-tasks >= 0.6.0
Requires: %{?scl_prefix}rubygem-justified
Requires: %{?scl_prefix}rubygem-gettext_i18n_rails
Requires: %{?scl_prefix}rubygem-i18n_data >= 0.2.6
Requires: %{?scl_prefix}rubygem-apipie-rails >= 0.1.1
Requires: %{?scl_prefix}rubygem-maruku
Requires: %{?scl_prefix}rubygem-runcible >= 1.0.8
Requires: %{?scl_prefix}rubygem-anemone
Requires: %{?scl_prefix}rubygem-sass-rails
Requires: %{?scl_prefix}rubygem-less-rails
Requires: %{?scl_prefix}rubygem-compass-rails
Requires: %{?scl_prefix}rubygem-compass-960-plugin
Requires: %{?scl_prefix}rubygem-haml-rails
Requires: %{?scl_prefix}rubygem-ui_alchemy-rails = 1.0.12
Requires: %{?scl_prefix}rubygem-deface < 1.0.0
Requires: %{?scl_prefix}rubygem-strong_parameters
Requires: %{?scl_prefix}rubygem-qpid_messaging >= 0.26.1
Requires: %{?scl_prefix}rubygem-qpid_messaging <= 0.28.1
BuildRequires: foreman >= 1.3.0
BuildRequires: %{?scl_prefix}rubygem-angular-rails-templates >= 0.0.4
BuildRequires: %{?scl_prefix}rubygem-sqlite3
BuildRequires: %{?scl_prefix}rubygem-tire => 0.6.2
BuildRequires: %{?scl_prefix}rubygem-tire < 0.7
BuildRequires: %{?scl_prefix}rubygem-logging >= 1.8.0
BuildRequires: %{?scl_prefix}rubygem-hooks
BuildRequires: %{?scl_prefix}rubygem-foreman-tasks >= 0.6.0
BuildRequires: %{?scl_prefix}rubygem-justified
BuildRequires: %{?scl_prefix}rubygem-gettext_i18n_rails
BuildRequires: %{?scl_prefix}rubygem-i18n_data >= 0.2.6
BuildRequires: %{?scl_prefix}rubygem-apipie-rails >= 0.1.1
BuildRequires: %{?scl_prefix}rubygem-maruku
BuildRequires: %{?scl_prefix}rubygem-runcible >= 1.0.8
BuildRequires: %{?scl_prefix}rubygem-anemone
BuildRequires: %{?scl_prefix}rubygem-sass-rails
BuildRequires: %{?scl_prefix}rubygem-less-rails
BuildRequires: %{?scl_prefix}rubygem-compass-rails
BuildRequires: %{?scl_prefix}rubygem-compass-960-plugin
BuildRequires: %{?scl_prefix}rubygem-haml-rails
BuildRequires: %{?scl_prefix}rubygem-ui_alchemy-rails = 1.0.12
BuildRequires: %{?scl_prefix}rubygem-deface < 1.0.0
BuildRequires: %{?scl_prefix}rubygem(uglifier) >= 1.0.3
BuildRequires: %{?scl_prefix}rubygem-strong_parameters
BuildRequires: %{?scl_prefix}rubygem-qpid_messaging >= 0.26.1
BuildRequires: %{?scl_prefix}rubygem-qpid_messaging <= 0.28.1
BuildRequires: %{?scl_prefix}rubygems
BuildArch: noarch
Provides: %{?scl_prefix}rubygem(katello) = %{version}

%description
Katello

%package doc
BuildArch:  noarch
Requires:   %{?scl_prefix}%{pkg_name} = %{version}-%{release}
Summary:    Documentation for rubygem-%{gem_name}

%description doc
This package contains documentation for rubygem-%{gem_name}.

%prep
%setup -n %{pkg_name}-%{version} -q -c -T
mkdir -p .%{gem_dir}
%{?scl:scl enable %{scl} "}
gem install --local --install-dir .%{gem_dir} --force %{SOURCE0}
%{?scl:"}

%build

%install
mkdir -p %{buildroot}%{gem_dir}
cp -a .%{gem_dir}/* \
        %{buildroot}%{gem_dir}/

mkdir -p ./usr/share
cp -r %{foreman_dir} ./usr/share || echo 0

pushd ./usr/share/foreman
export GEM_PATH=%{gem_dir}:%{buildroot}%{gem_dir}

cat <<GEMFILE > ./bundler.d/%{gem_name}.rb
group :katello do
  gem '%{gem_name}'
  gem 'sass-rails'
end
GEMFILE

unlink tmp
cp %{buildroot}%{gem_instdir}/config/katello_defaults.yml %{buildroot}%{gem_instdir}/config/katello.yml

export BUNDLER_EXT_NOSTRICT=1
export BUNDLER_EXT_GROUPS="default assets katello"
%{scl_rake} assets:precompile:katello RAILS_ENV=production --trace

popd
rm -rf ./usr
rm %{buildroot}%{gem_instdir}/config/katello.yml

mkdir -p %{buildroot}%{foreman_bundlerd_dir}
cat <<GEMFILE > %{buildroot}%{foreman_bundlerd_dir}/%{gem_name}.rb
group :katello do
  gem '%{gem_name}'
  gem 'sass-rails'
end
GEMFILE

mkdir -p %{buildroot}%{foreman_dir}/public/assets
ln -s %{gem_instdir}/public/assets/katello %{buildroot}%{foreman_dir}/public/assets/katello
ln -s %{gem_instdir}/public/assets/bastion %{buildroot}%{foreman_dir}/public/assets/bastion

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-, root, root)
%{gem_instdir}/
%exclude %{gem_cache}
%{gem_spec}
%{foreman_bundlerd_dir}/%{gem_name}.rb
%{foreman_dir}/public/assets/katello
%{foreman_dir}/public/assets/bastion

%files doc
%{gem_dir}/doc/%{gem_name}-%{version}

%changelog
* Fri Sep 12 2014 Justin Sherrill <jsherril@redhat.com> 2.1.0-1
- bumping to version to 2.1 (jsherril@redhat.com)

* Fri Sep 12 2014 Justin Sherrill <jsherril@redhat.com> 2.0.0-1
- bumping to katello 2.0 (jsherril@redhat.com)
- Automatic commit of package [katello] minor release [2.0.0-0].
  (jsherril@redhat.com)
- fixes #7410 - replaced query_params with params (thomasmckay@redhat.com)
- fixes #7404 - add salt support to katello templates (stbenjam@redhat.com)
- Fixes #7395: Turn off strong params for Candlepin proxies controller.
  (ericdhelms@gmail.com)
- fixes #6488 enable autosearch completion on Katello model filters
  (stbenjam@redhat.com)
- Fixes #7394: Stop blocking plugin routes from being loaded properly.
  (ericdhelms@gmail.com)
- Fixes #3584: Enable all tests to be run. (ericdhelms@gmail.com)
- Fixes #7390: Change global variable $/ to $INPUT_RECORD_SEPARATOR.
  (ericdhelms@gmail.com)
- Fixes #7389: Prevent undefined method error from root controller.
  (ericdhelms@gmail.com)
- Fixes #7358/BZ1138411: correct empty org message logic on dashboard.
  (walden@redhat.com)
- Fixes #6287: Remove V1 API entirely. (ericdhelms@gmail.com)
- refs #6370 - automatically associate OS's with templates
  (stbenjam@redhat.com)
- Fixes #7307 - Refactor errata/package/package group APIs
  (daviddavis@redhat.com)
- Refs #7156 - Fixing a bunch of small rubocop items (daviddavis@redhat.com)
- fixes #7360 / BZ 1120595 - UI: Product: fix Sync Now behavior
  (bbuckingham@redhat.com)
- Fixes #6942,bz1122924 - subscription reindex (inecas@redhat.com)
- Fixes #6821/BZ1117636: fix link to content hosts on CV delete page.
  (walden@redhat.com)
- fixes #7343 / BZ 1132576 - iso sync - fix issue where progress report not
  available yet (bbuckingham@redhat.com)
- fixes #7342 / BZ 1128469 - content view filter - improve behavior when
  clicking calendar icon (bbuckingham@redhat.com)
- Fixes #7341: Adds script to generate contributors with initial list.
  (ericdhelms@gmail.com)
- fixes #7309 / BZ 1093483 - Repo sync status - update UI cross-links and
  status based on dynflow task (bbuckingham@redhat.com)
- fixes #7328 - Adds route for sync-plans, BZ 1132817 (cfouant@redhat.com)
- Fixes #6773 - Host inherits Content Source from Hostgroup
  (elobatocs@gmail.com)
- Fixes #7303 - Added content view version param to errata api
  (daviddavis@redhat.com)
- Fixes #7300 - Adding a content view version parameter for packages
  (daviddavis@redhat.com)
- Fixes #7242: Script to generate formatted changelog. (ericdhelms@gmail.com)
- fixes #7292 - Fixes duplicated sync plan route, BZ 1132914
  (cfouant@redhat.com)
- Fixes #7283: using translate directive in <span> to avoid infinite loop.
  (walden@redhat.com)
- Fixes #7294: replace <th> translate filters with directives.
  (walden@redhat.com)
- Fixes #6993: Ensure repo discovery proxy setup is loaded in production.
  (ericdhelms@gmail.com)
- fixes #7273 - sync puppet and rpm content together (jsherril@redhat.com)
- fixes #7278 - Fixes activation key registration hint, BZ 1128245
  (cfouant@redhat.com)
- Fixes #7028 - fixing api docs for orgs (tstrachota@redhat.com)
- fixes #7271 - validate repositories associated to content views
  (jsherril@redhat.com)
- fixes #6605 - Adds registered by to content host, BZ 1020402
  (cfouant@redhat.com)
- fixes #7162 / BZ 1102763 - capsule - treat task as failed if sync times out
  with capsule (bbuckingham@redhat.com)
- Fixes #7272 - system has extra validation on name (dtsang@redhat.com)
- Fixes #7270/BZ1131661: remove GMT from new sync plan form.
  (walden@redhat.com)
- Fixes #6955: using CSS to mimic a <pre> for multiple line support.
  (walden@redhat.com)
- fixes #7266 - specify time when creating new ulimited subscriptions
  (jsherril@redhat.com)
- Fixes #6990 - No message for admin (oprazak@redhat.com)
- Fixes #7027: Restrict mongodb to version 2.4 or greater.
  (ericdhelms@gmail.com)
- Fixes #7251 - hammer org_id help text missing (dtsang@redhat.com)
- Fixes #7241/bz1132790 - Enable rh common for ks template (paji@redhat.com)
- fixes #7084 - add rubygem-hammer_cli_import dep (jmontleo@redhat.com)
- refs #5271 - update tito for el7 (jsherril@redhat.com)
- Fixes #7120/BZ980113: use BS3 on dashboard to make it responsive.
  (walden@redhat.com)
- Fixes #6726 - sends username in cp-user header. (aruzicka@redhat.com)

* Mon Aug 25 2014 Justin Sherrill <jsherril@redhat.com> 1.5.0-12
- refs #5271 - remove unused gem dependencies (jsherril@redhat.com)

* Fri Aug 22 2014 Justin Sherrill <jsherril@redhat.com> 1.5.0-11
- Merge pull request #4596 from jlsherrill/7175 (jlsherrill@gmail.com)
- fixes #7175 - do not treat iso repos as capsule syncable
  (jsherril@redhat.com)
- Merge pull request #4602 from stbenjam/6811-part2 (stephen@bitbin.de)
- Merge pull request #4599 from jlsherrill/5271-comps (jlsherrill@gmail.com)
- refs #6811 - install katello agent during install w/o service start
  (stbenjam@redhat.com)
- Fixes #7214: add !optional to @extends, required after sass update
  (walden@redhat.com)
- refs #5271 - prepare comps for el7 builds (jsherril@redhat.com)
- Merge pull request #4597 from waldenraines/7119 (walden@redhat.com)
- fixes #7186 - fixing rubocop to run properly (jsherril@redhat.com)
- Fixes #7119/BZ1130645: double quote host collection name in search.
  (walden@redhat.com)
- Merge pull request #4594 from waldenraines/7091 (walden@redhat.com)
- Fixes #7091/BZ1129375: fix documentation for create/update system.
  (walden@redhat.com)
- Merge pull request #4592 from waldenraines/7173 (walden@redhat.com)
- Merge pull request #4591 from komidore64/rmi7158-actkey-env-list-dead
  (komidore64@gmail.com)
- Fixes #7173: remove grunt bower:dev configuration. (walden@redhat.com)
- fixes #7158 - environments are now inside of the "results" hash, BZ 1131618
  (komidore64@gmail.com)
- Refs #6297 - workaround for incomplete pulp task from sync plan
  (inecas@redhat.com)
- Refs #6182 - fix setting the GPG keys for product content on update
  (inecas@redhat.com)
- Fixes #6182 - use url instead of feed to detect the path change
  (inecas@redhat.com)
- Fixes #6182 - Dynflowized repository update (aruzicka@redhat.com)
- Fixes #6283 - Use the Dynflow API to find out if the foreman_tasks is running
  (inecas@redhat.com)
- Fixes #6297 - delayed jobs is dead, long live foreman-tasks
  (inecas@redhat.com)
- Fixes #6297 - remove unused and unreachable code that used delayed jobs
  (inecas@redhat.com)
- Fixes #6297 - remove mailer as the code was unreachable (inecas@redhat.com)
- Fixes #6297 - dynflowize after-sync callbacks (inecas@redhat.com)
- Fixes #6297 - Dynflowize content uploads (inecas@redhat.com)
- Fixes #6304 - remove apply default info (inecas@redhat.com)
- Fixes #6296 - dynflowize organization auto-attach (inecas@redhat.com)
- Merge pull request #4589 from parthaa/install-media (parthaa@gmail.com)
- Merge pull request #4579 from komidore64/rmi5655-hammer-env-paths-broken
  (komidore64@gmail.com)
- Merge pull request #4590 from daviddavis/temp/20140818120417
  (daviddavis@redhat.com)
- fixes #5655 - sending correct json for ktenvironments paths
  (komidore64@gmail.com)
- Fixes #7138,BZ1030537 - Prevent file repos being added to views
  (daviddavis@redhat.com)
- Fixes #7116/bz1130577- Adding install media after repo sync (paji@redhat.com)
- Merge pull request #4588 from bbuckingham/issue-7110 (bbuckingham@redhat.com)
- Merge pull request #4582 from daviddavis/temp/20140814111517
  (daviddavis@redhat.com)
- Merge pull request #4587 from waldenraines/7114 (walden@redhat.com)
- Merge pull request #4522 from tstrachota/cv_versions (daviddavis@redhat.com)
- Merge pull request #4572 from mbacovsky/7059_subscription_pagination
  (walden@redhat.com)
- Fixes #7114: use the correct model for host-collection row select.
  (walden@redhat.com)
- Merge pull request #4583 from bbuckingham/issue-7069 (bbuckingham@redhat.com)
- fixes #7110 / BZ 1129424 - fix syncing of iso repos (bbuckingham@redhat.com)
- Merge pull request #4581 from waldenraines/7088 (walden@redhat.com)
- Fixes #6815,#6187/bz1125398,1125358 - Environment Destroy Dynflow
  (paji@redhat.com)
- Refs #6509 - content view versions filterable by env and version BZ1102284
  (tstrachota@redhat.com)
- fixes #7069 / BZ 1123959 - host<->content host - improve behavior when puppet
  env, lifecycle env or content view change (bbuckingham@redhat.com)
- Merge pull request #4586 from ehelms/fixes-7103 (ericdhelms@gmail.com)
- Fixes #7103: Remove unused library to fix 'npm install'.
  (ericdhelms@gmail.com)
- Fixes #7089 - Using #scoped method in the auth code (daviddavis@redhat.com)
- Fixes #7088/BZ1130224: reload filter after saving date range errata.
  (walden@redhat.com)
- Merge pull request #4578 from jlsherrill/7074 (jlsherrill@gmail.com)
- fixes #7074 - allow registrations even when there is no host
  (jsherril@redhat.com)
- Fixes #7071/BZ1125391: add installer and pulp configs to katello-debug.
  (walden@redhat.com)
- Fixes #7068/bz1129775 - Fix repo sync checksum error (paji@redhat.com)
- Merge pull request #4543 from dustint-rh/api_show_missing (dtsang@redhat.com)
- Merge pull request #4537 from bkearney/bkearney/6967
  (bryan.kearney@gmail.com)
- Merge pull request #4528 from jlsherrill/6330 (jlsherrill@gmail.com)
- Merge pull request #4515 from daviddavis/temp/20140731151434
  (daviddavis@redhat.com)
- Merge pull request #4569 from waldenraines/7000 (walden@redhat.com)
- Merge pull request #4574 from xprazak2/bug6611 (walden@redhat.com)
- Fixes #7000/BZ1080172: paginate content host packages. (walden@redhat.com)
- Merge pull request #4538 from bbuckingham/issue-6969 (bbuckingham@redhat.com)
- Merge pull request #4565 from daviddavis/7022 (daviddavis@redhat.com)
- Merge pull request #4549 from ehelms/fixes-6993 (inecas@redhat.com)
- Fixes #6611 - Section titles now in dark color, looking enabled
  (oprazak@redhat.com)
- Merge pull request #4554 from jlsherrill/6981 (jlsherrill@gmail.com)
- Merge pull request #4558 from bbuckingham/issue-7019 (bbuckingham@redhat.com)
- Merge pull request #4555 from bbuckingham/issue-7005 (bbuckingham@redhat.com)
- Merge pull request #4551 from jlsherrill/6992 (jlsherrill@gmail.com)
- Merge pull request #4567 from dustint-rh/fix_find_only_environment
  (dtsang@redhat.com)
- fixes #6981 - handle non-yum sync statuses (jsherril@redhat.com)
- Merge pull request #4568 from waldenraines/7047 (walden@redhat.com)
- Fixes #7045 - fix location undefined for user (dtsang@redhat.com)
- Merge pull request #4531 from parthaa/repo-discovery (parthaa@gmail.com)
- Fixes #7047/BZ1128467: get full result of product's repositories.
  (walden@redhat.com)
- Merge pull request #4553 from xprazak2/organization-nil-fix
  (walden@redhat.com)
- Fixes #7022 - Upgrade version of rubocop (daviddavis@redhat.com)
- Fixes #7037 - We now get a message suggesting a possible cause
  (oprazak@redhat.com)
- Merge pull request #4559 from daviddavis/temp/20140811122150
  (daviddavis@redhat.com)
- Fixes #6971,bz1085417 - api handle nonexistent id (dtsang@redhat.com)
- Merge pull request #4561 from dustint-rh/rm_default_environment_in_sys_api
  (dtsang@redhat.com)
- Merge pull request #4501 from waldenraines/6828 (walden@redhat.com)
- Merge pull request #4562 from waldenraines/7026 (walden@redhat.com)
- Merge pull request #4484 from komidore64/rmi5190-deprecated-systems-calls
  (komidore64@gmail.com)
- Merge pull request #4560 from dustint-rh/typo_in_delete_cv_from_env
  (dtsang@redhat.com)
- Merge pull request #4527 from bbuckingham/issue-6919 (bbuckingham@redhat.com)
- Fixes #7026/BZ1128471: fix error on updating errata date range filter.
  (walden@redhat.com)
- Fixes #7025 - replace default_environment in sys (dtsang@redhat.com)
- fixes #5190 - adding annotations to deprecated routes, BZ 1102264
  (komidore64@gmail.com)
- Fixes #7024 - fixes delete cv from environment (dtsang@redhat.com)
- Fixes #6175 - Handle new status icon that was added (daviddavis@redhat.com)
- Merge pull request #4541 from waldenraines/6949 (walden@redhat.com)
- Merge pull request #4525 from daviddavis/temp/20140804133452
  (daviddavis@redhat.com)
- Merge pull request #4545 from daviddavis/temp/20140807112451
  (daviddavis@redhat.com)
- fixes #7019 / BZ 1128473 - content search - change to eliminate errors with
  ambiguous 'id' (bbuckingham@redhat.com)
- Merge pull request #4550 from waldenraines/6870 (walden@redhat.com)
- Merge pull request #4556 from bbuckingham/issue-7012 (bbuckingham@redhat.com)
- Merge pull request #4535 from ehelms/fixes-6960 (walden@redhat.com)
- fixes #7012 - content search - fix 404 retrieving spinner.gif
  (bbuckingham@redhat.com)
- fixes #6970 - content host bulk actions - fix 2 regressions
  (bbuckingham@redhat.com)
- fixes #7005 / BZ 1122736 - content host - change registration behavior with
  foreman host (bbuckingham@redhat.com)
- Fixes #7059 - enable pagination in subscriptions (API)
  (martin.bacovsky@gmail.com)
- Merge pull request #4552 from waldenraines/6995 (jlsherrill@gmail.com)
- Fixes #6828/BZ1104636: show correct version of puppet module. …
  (walden@redhat.com)
- Merge pull request #4539 from isratrade/6565 (jlsherrill@gmail.com)
- Fixes #6949/BZ970600: remove unused tasks endpoint. (walden@redhat.com)
- Fixes #6870/BZ1075523: use ANONYMOUS_ADMIN for hidden user.
  (walden@redhat.com)
- Merge pull request #4548 from komidore64/rmi6720-content-management-commands
  (komidore64@gmail.com)
- Merge pull request #4540 from komidore64/revert-rmi6573
  (komidore64@gmail.com)
- Fixes #6995: restore pulp_celerybeat to list of services to restart.
  (walden@redhat.com)
- fixes #6992 - ensure rhel 5 repos can be used by el5 clients
  (jsherril@redhat.com)
- Fixes #6993: Allow repo-discovery through a proxy. (ericdhelms@gmail.com)
- refs #6720 - fixing apidoc route for errata apply (komidore64@gmail.com)
- fixes #6565 - show kickstart url from content source if it can be calculated.
  otherwise don't hide media drop down (jmagen@redhat.com)
- Fixes #6989: Add zanata file, and instructures on how to push and pull
  strings to the locale directory. (bkearney@redhat.com)
- Fixes #6985,BZ1127747 - Reusing CVEnv action in org destroy
  (daviddavis@redhat.com)
- Fixes #6983: fix typo on bastion readme page. (walden@redhat.com)
- Refs #6867,BZ1038323 - Show katello-agent status for systems
  (daviddavis@redhat.com)
- Merge pull request #4510 from stbenjam/6853 (jlsherrill@gmail.com)
- Fixes #6944/bz1106434 - Fixed Repodiscovery product validation
  (paji@redhat.com)
- Merge pull request #4508 from cfouant/facts (jlsherrill@gmail.com)
- fixes #4922, #6937 - Fixes issue with not being able to update system facts,
  BZ 1103860, 1126376 (cfouant@redhat.com)
- Revert "fixes #6573 - foretello should error when sorting by non-sortable
  field, BZ 1110431" (komidore64@gmail.com)
- Fixes #6967: Add the correct location of mongo, and collect all log files
  (bkearney@redhat.com)
- Merge pull request #4425 from dustint-rh/ch_events (dtsang@redhat.com)
- fixes #6963 - make templates compatible with RHEL 5 (stbenjam@redhat.com)
- Fixes #6960: Environments no longer disappear on hover on Content Search
  page. (ericdhelms@gmail.com)
- Merge pull request #4524 from jlsherrill/6915 (jlsherrill@gmail.com)
- Fixes #6039 - CP events in CH tasks tab (dtsang@redhat.com)
- Merge pull request #4521 from bbuckingham/issue-6550 (bbuckingham@redhat.com)
- Merge pull request #4503 from iNecas/issue/6837 (inecas@redhat.com)
- Merge pull request #4499 from waldenraines/6808 (walden@redhat.com)
- Merge pull request #4512 from waldenraines/5745 (walden@redhat.com)
- fixes #6330 - using pulp & pulp_node features of smart proxy
  (jsherril@redhat.com)
- Merge pull request #4517 from jlsherrill/6889 (jlsherrill@gmail.com)
- Merge pull request #4435 from ehelms/fixes-6639 (ericdhelms@gmail.com)
- Merge pull request #4461 from bkearney/bkearney/6682
  (bryan.kearney@gmail.com)
- fixes #6550 / BZ 1117952 - fix issues with changing org name which affected
  running db:seed (bbuckingham@redhat.com)
- Fixes #5745/BZ963572: upgrade angular-gettext to fix XSS. (walden@redhat.com)
- Merge pull request #4450 from stbenjam/4734 (stephen@bitbin.de)
- Fixes #6682 : Add a warning message if the user tries to run katello-debug.sh
  directly (bkearney@redhat.com)
- Merge pull request #4504 from dustint-rh/system_present_uuid_as_id
  (dtsang@redhat.com)
- Merge pull request #4408 from bbuckingham/issue-6547 (bbuckingham@redhat.com)
- fixes #6936 - Fixes typo in registration hint, BZ 1124075
  (cfouant@redhat.com)
- Merge pull request #4529 from isratrade/6931 (bbuckingham@redhat.com)
- Merge pull request #4471 from jlsherrill/syncing (jlsherrill@gmail.com)
- Merge pull request #4519 from cfouant/errata (ericdhelms@gmail.com)
- Merge pull request #4523 from bbuckingham/issue-6913 (bbuckingham@redhat.com)
- Fixes #6918,BZ1125999 - Removing dupe products in sync widget
  (daviddavis@redhat.com)
- fixes #4734 - make katello templates available in all taxonomies
  (stbenjam@redhat.com)
- fixes #6663 - Details tab of foreman host shows multiple entries of
  'Subscription Status' (joseph@isratrade.co.il)
- Merge pull request #4526 from thomasmckay/6883-actkey-order
  (thomasmckay@redhat.com)
- fixes #6919 / BZ 1113588 - host - show validation error if no puppet
  environment (bbuckingham@redhat.com)
- Merge pull request #4448 from parthaa/feed-to-url (parthaa@gmail.com)
- Merge pull request #4520 from dustint-rh/host-collection-doc-text
  (dtsang@redhat.com)
- fixes #6883 - reverse order of activation keys (thomasmckay@redhat.com)
- Fixes #6842 - system uuid as id bz1122938 (dtsang@redhat.com)
- fixes #6915 - cleanup activation key association on clean_backend_objects
  (jsherril@redhat.com)
- Merge pull request #4516 from stbenjam/6880 (stephen@bitbin.de)
- Merge pull request #4420 from komidore64/rmi6573-error-on-non-sort-field
  (komidore64@gmail.com)
- fixes #6913 / BZ 1092143 - content view version - disable promote/remove on
  failed task (bbuckingham@redhat.com)
- fixes #6547 / BZ 1115468 - delete puppet modules from content view on repo
  delete (bbuckingham@redhat.com)
- Merge pull request #4518 from daviddavis/temp/20140801163031
  (daviddavis@redhat.com)
- Merge pull request #4514 from bbuckingham/issue-6871 (bbuckingham@redhat.com)
- Fixes #6894,bz1123473 - rm sys from HC docs (dtsang@redhat.com)
- Fixes #6892 - Turn on IndentationConsistency cop (daviddavis@redhat.com)
- fixes #6128 - Fixes errata icons not showing, BZ 902948 (cfouant@redhat.com)
- fixes #6889 - on location creation, set default if one does not exist
  (jsherril@redhat.com)
- fixes #6880 - remove puppet from packages section (stbenjam@redhat.com)
- Merge pull request #4356 from ehelms/fixes-6293 (ericdhelms@gmail.com)
- Fixes #6808/BZ1124058: fixing permissions of product buttons.
  (walden@redhat.com)
- Merge pull request #4513 from cfouant/internationalization
  (walden@redhat.com)
- fixes #6869 - I18n not working w/unsupported languages, BZ 1093433
  (cfouant@redhat.com)
- fixes #6871 / BZ 1125397 - capsule - add error case for content sync
  (bbuckingham@redhat.com)
- Merge pull request #4507 from daviddavis/temp/20140730151145
  (daviddavis@redhat.com)
- Merge pull request #4502 from parthaa/repo-remove (parthaa@gmail.com)
- Merge pull request #4511 from dustint-rh/ak_releases_perm (dtsang@redhat.com)
- Fixes #6829,6805 - Disable repo remove if published (paji@redhat.com)
- Refs #5429,BZ1102296 - Showing hosts and keys for views
  (daviddavis@redhat.com)
- Merge pull request #4495 from waldenraines/6821 (walden@redhat.com)
- Merge pull request #4414 from jlsherrill/6322-env_delete
  (jlsherrill@gmail.com)
- Fixes #6354,bz1112717 - AK available_release perm (dtsang@redhat.com)
- fixes #4989,6734,6735 - adapting sync management page to use dynflow
  (jsherril@redhat.com)
- Merge pull request #4487 from ehelms/refs-5029 (ericdhelms@gmail.com)
- fixes #6853 - make host group provisioning work with katello
  (stbenjam@redhat.com)
- Merge pull request #4416 from waldenraines/6272 (walden@redhat.com)
- Merge pull request #4505 from daviddavis/temp/20140730131408
  (daviddavis@redhat.com)
- Merge pull request #4496 from parthaa/host-collection-fix (parthaa@gmail.com)
- Fixes #6837 - remove old hook-actions (inecas@redhat.com)
- Fixes #6848,BZ1124547 - Checking content view environments
  (daviddavis@redhat.com)
- Fixes #6821/BZ1117636: fix link to activation keys on CV delete page.
  (walden@redhat.com)
- Merge pull request #4506 from thomasmckay/6846-crosslink
  (thomasmckay@redhat.com)
- Fixes 6807/bz1103033 - Host Collection UI rows refresh code (paji@redhat.com)
- fixes #6846 - correct link to hypervisor's content hosts
  (thomasmckay@redhat.com)
- Fixes #6845 - Fix undefined method puppet_env for nil (daviddavis@redhat.com)
- Merge pull request #4500 from waldenraines/6827 (walden@redhat.com)
- Merge pull request #4475 from thomasmckay/6702-derived-products
  (thomasmckay@redhat.com)
- Merge pull request #4494 from stbenjam/6811 (ericdhelms@gmail.com)
- Merge pull request #4492 from ehelms/fixes-6804 (ericdhelms@gmail.com)
- Merge pull request #4491 from ehelms/fixes-6801 (ericdhelms@gmail.com)
- Fixes #6827/BZ1124607: hide CH Product tab if you lack permission.
  (walden@redhat.com)
- Merge pull request #4474 from thomasmckay/6737-sub-amount
  (thomasmckay@redhat.com)
- Fixes #6804: Fix de-select when individual nutupane items selected.
  (ericdhelms@gmail.com)
- Merge pull request #4340 from adamruzicka/fixes-6188 (ericdhelms@gmail.com)
- fixes #6702 - use a subscriptions derived provided products
  (thomasmckay@redhat.com)
- Merge pull request #4400 from thomasmckay/6406-associations
  (thomasmckay@redhat.com)
- Merge pull request #4296 from adamruzicka/fixes-5952 (walden@redhat.com)
- fixes #6519 - updating associations UI (thomasmckay@redhat.com)
- Merge pull request #4428 from stbenjam/6609 (inecas@redhat.com)
- Merge pull request #4444 from cfouant/auto-attach (thomasmckay@redhat.com)
- fixes #6811 - install katello-agent during kickstart (stbenjam@redhat.com)
- Merge pull request #4493 from bbuckingham/issue-6803 (bbuckingham@redhat.com)
- Fixes #6188 - Dynflowized activation key creation (aruzicka@redhat.com)
- Merge pull request #4468 from komidore64/rmi6720-content-management
  (komidore64@gmail.com)
- Fixes #6097,bz1120427 - repository.feed -> repository.url (paji@redhat.com)
- fixes #6803 / BZ 1115308 - content search - fix sql errors on product/repo
  auto-complete (bbuckingham@redhat.com)
- Merge pull request #4460 from parthaa/bulk-sync (parthaa@gmail.com)
- Merge pull request #4467 from parthaa/cv-publish-fix (parthaa@gmail.com)
- Merge pull request #4490 from dustint-rh/qpid-comps (dtsang@redhat.com)
- fixes #6652, #6578, #6738 - Enables setting auto-attach and triggers auto-
  attach and shows service level, BZ 1113879, BZ 1019227, BZ 999122
  (cfouant@redhat.com)
- fixes #6573 - foretello should error when sorting by non-sortable field, BZ
  1110431 (komidore64@gmail.com)
- Fixes #6801: Make tipsy's on content search page visible again.
  (ericdhelms@gmail.com)
- Ref #6800 - add qpid-cpp-client-devel to comps (dtsang@redhat.com)
- fixes #6609 - katello templates for image-based hosts (stbenjam@redhat.com)
- Merge pull request #4429 from jmontleon/fix-candlepin-tomcat-dependency
  (ericdhelms@gmail.com)
- Fixes #6676,bz1120820 - Dynflowing bulk repo sync page (paji@redhat.com)
- Refs #5029: Updates for initial org and location in Foreman.
  (ericdhelms@gmail.com)
- Merge pull request #4479 from daviddavis/6696 (daviddavis@redhat.com)
- Merge pull request #4463 from daviddavis/temp/20140721155712
  (daviddavis@redhat.com)
- Merge pull request #4481 from dustint-rh/ak_filter_org_id_show
  (dtsang@redhat.com)
- Merge pull request #4482 from waldenraines/6776 (walden@redhat.com)
- Fixes #6775 - AK show filters by index's params (dtsang@redhat.com)
- Merge pull request #4442 from parthaa/disable-sync (parthaa@gmail.com)
- Fixes #6776/BZ1122254: update table when repository modified.
  (walden@redhat.com)
- Fixes #6651,bz1094986 - Disable Sync without repo url (paji@redhat.com)
- Merge pull request #4478 from waldenraines/6759 (walden@redhat.com)
- Merge pull request #4473 from parthaa/cv-required (parthaa@gmail.com)
- Merge pull request #4477 from thomasmckay/6740-enabled-label
  (thomasmckay@redhat.com)
- Refs #6696 - Fixing test that doesn't work with content-type json
  (daviddavis@redhat.com)
- Fixes #6759/BZ1108928: using #content as topbar.js expects.
  (walden@redhat.com)
- Fixes #6647,BZ1120335 - Remove old foreman org destroy routes
  (daviddavis@redhat.com)
- Merge pull request #4456 from jlsherrill/5096 (jlsherrill@gmail.com)
- Merge pull request #4421 from isratrade/6596 (jlsherrill@gmail.com)
- Merge pull request #4423 from bbuckingham/issue-6603 (bbuckingham@redhat.com)
- Merge pull request #4469 from bbuckingham/issue-6719 (bbuckingham@redhat.com)
- fixes #6596 - fixes #6596 - change 'type' method to 'system_type' in
  Katello::System (jmagen@redhat.com)
- fixes #6740 - cleared up enabled text (thomasmckay@redhat.com)
- fixes #6737 - correct 'automatic' amount for subscriptions
  (thomasmckay@redhat.com)
- Fixes #5985/bz1102120 - Marked content_view_id as required param
  (paji@redhat.com)
- Merge pull request #4464 from cfouant/helptip-ak (ericdhelms@gmail.com)
- Merge pull request #4397 from cfouant/fixes-6012-new (thomasmckay@redhat.com)
- fixes #5096 - fail gracefully on pulp repo creation failure
  (jsherril@redhat.com)
- Merge pull request #4466 from cfouant/limit-activationkey
  (ericdhelms@gmail.com)
- fixes #6706 - Adds Activation Key helptip, BZ 1093180 (cfouant@redhat.com)
- fixes #6709 - Throws validation error when updating content-host limit below
  already consumed in hammer, BZ 1098425 (cfouant@redhat.com)
- Fixes #5858,bz 109961 - Updated cv published content count (paji@redhat.com)
- Merge pull request #4470 from daviddavis/temp/20140722110039
  (daviddavis@redhat.com)
- Fixes #6691,BZ1021065 - Sync status only applies to repos with feeds
  (daviddavis@redhat.com)
- fixes #6719 / BZ 1079953 - Content Notices - fix deletion and list by org
  (bbuckingham@redhat.com)
- Merge pull request #4451 from waldenraines/6664 (walden@redhat.com)
- Merge pull request #4236 from cfouant/curl (thomasmckay@redhat.com)
- refs # 6720 - necessary apidoc changes for content-management, BZ 1105276
  (komidore64@gmail.com)
- Fixes #5952, BZ1079174 - Fixes issue with content view filter name and
  description being impossible to edit (aruzicka@redhat.com)
- Merge pull request #4458 from daviddavis/temp/20140718101857
  (daviddavis@redhat.com)
- fixes #6686 - Remove extraneous alch-alert div from CV filters index
  (stbenjam@redhat.com)
- Fixes #6691,BZ1021065 - Not showing non-syncable products in dashboard
  (daviddavis@redhat.com)
- Merge pull request #4459 from bbuckingham/issue-6690 (bbuckingham@redhat.com)
- fixes #6690 / BZ 1111695 - content views & activation keys - fix bastion
  permission checking (bbuckingham@redhat.com)
- fixes #6578 - Fixes auto-attach subscriptions button, BZ 1019227
  (cfouant@redhat.com)
- fixes #6129 - Opens up /status reporting for Katello, BZ 1097875
  (cfouant@redhat.com)
- Merge pull request #4455 from bbuckingham/issue-6125 (bbuckingham@redhat.com)
- fixes #6125 / BZ 1106914 - organization ui - remove cloning
  (bbuckingham@redhat.com)
- Merge pull request #4432 from bbuckingham/issue-6626 (bbuckingham@redhat.com)
- Merge pull request #4447 from bbuckingham/issue-6646 (bbuckingham@redhat.com)
- Merge pull request #4439 from daviddavis/temp/20140716132424
  (daviddavis@redhat.com)
- Merge pull request #4434 from daviddavis/temp/20140716091214
  (daviddavis@redhat.com)
- Merge pull request #4436 from daviddavis/temp/20140716110339
  (daviddavis@redhat.com)
- Fixes #6643,BZ1105351 - Fixing drag-and-drop widgets on dashboard
  (daviddavis@redhat.com)
- Merge pull request #4445 from waldenraines/6653 (walden@redhat.com)
- Fixes #6664/BZ1103169: remove incorrect usages of control-width.
  (walden@redhat.com)
- Merge pull request #4449 from waldenraines/5948 (walden@redhat.com)
- Fixes #5948/BZ1077886: tell alch-alert to track by index instead of value.
  (walden@redhat.com)
- Merge pull request #4382 from waldenraines/6321 (walden@redhat.com)
- Merge pull request #4446 from jlsherrill/6649 (jlsherrill@gmail.com)
- Fixes #6321/BZ1111695: check permission before displaying bastion page.
  (walden@redhat.com)
- fixes #6649 - explicitly require java 1.7 since the installer now requires it
  (jsherril@redhat.com)
- Merge pull request #4443 from daviddavis/temp/20140716162734
  (daviddavis@redhat.com)
- Merge pull request #4239 from ehelms/fixes-6126 (ericdhelms@gmail.com)
- Merge pull request #4378 from komidore64/rmi6463-hammer-org-description
  (komidore64@gmail.com)
- fixes #6646 / BZ 1104104 - Content View - disable version promote/remove
  during publish/promote (bbuckingham@redhat.com)
- Fixes #6653/BZ1013689: show success message on repo creation and update.
  (walden@redhat.com)
- Fixes #6648,BZ1120336 - Reload product before destroying it
  (daviddavis@redhat.com)
- Merge pull request #4417 from waldenraines/6591 (walden@redhat.com)
- Fixes #6272/BZ1118479 - move Bastion guide to katello.org.
  (walden@redhat.com)
- Fixes #6635,BZ1114046 - Fixing undefined method cp_id error
  (daviddavis@redhat.com)
- fixes #6463 - hammer org update description , BZ 1114136
  (komidore64@gmail.com)
- Merge pull request #4440 from jlsherrill/6571 (jlsherrill@gmail.com)
- Merge pull request #4438 from jlsherrill/6572 (jlsherrill@gmail.com)
- fixes #6571 - changing text on host errata screen (jsherril@redhat.com)
- Fixes #6591/BZ1076364: include fonts that datepicker depends on.
  (walden@redhat.com)
- fixes #6572 - fix default check on path selector (jsherril@redhat.com)
- Fixes #6218,BZ1112764 - Using pulp status route for ping
  (daviddavis@redhat.com)
- Merge pull request #4430 from bbuckingham/issue-6624 (bbuckingham@redhat.com)
- Fixes #6639: Allow user actions to not be blocked by update.
  (ericdhelms@gmail.com)
- Merge pull request #4433 from jlsherrill/6628 (jlsherrill@gmail.com)
- Merge pull request #4426 from bbuckingham/issue-6607 (bbuckingham@redhat.com)
- Merge pull request #4427 from bbuckingham/issue-6619 (bbuckingham@redhat.com)
- fixes #6628 - fixing live glue pulp vcr tests (jsherril@redhat.com)
- fixes #6626 / BZ 1079958 - content dashboard - fix N results
  (bbuckingham@redhat.com)
- Merge pull request #4405 from daviddavis/org-destroy (daviddavis@redhat.com)
- fixes #6624 / BZ 1105617 - content host package actions - disable buttons
  when busy (bbuckingham@redhat.com)
- Fixes #6623 - Candlepin dependency correction for RHEL 7
  (jmontleo@redhat.com)
- Merge pull request #4412 from waldenraines/6554 (walden@redhat.com)
- fixes #6619 / BZ 1111733 - Lifecycle Environment: do not update label
  (bbuckingham@redhat.com)
- Refs #6180,BZ1100311 - Remove old del_owner method from owner
  (daviddavis@redhat.com)
- Merge pull request #4406 from waldenraines/6531 (walden@redhat.com)
- Merge pull request #4422 from bbuckingham/issue-6601 (bbuckingham@redhat.com)
- fixes #6607 / BZ 1106565 - Content View Package Filter Rules - allow
  duplicate name (bbuckingham@redhat.com)
- Fixes #6126: Moves RHSM routes to their own API (/rhsm) and routes file.
  (ericdhelms@gmail.com)
- fixes #6604 - fixing rake db:seed error (jsherril@redhat.com)
- Fixes #6180,BZ1100311 - Implement organization destroy in dynflow
  (daviddavis@redhat.com)
- fixes #6603 / BZ 1115341 - content search - fix for missing package metadata
  (bbuckingham@redhat.com)
- fixes #6601 / BZ 1115364 - content search - fix package license
  (bbuckingham@redhat.com)
- Merge pull request #4393 from stbenjam/6512-notices (walden@redhat.com)
- Merge pull request #4325 from isratrade/6329 (jlsherrill@gmail.com)
- Merge pull request #4418 from bbuckingham/issue-6592 (bbuckingham@redhat.com)
- Merge pull request #4419 from bbuckingham/issue-6593 (bbuckingham@redhat.com)
- fixes #6593 / BZ 1118897 - Host Collections - fix crosslink to edit env and
  view (bbuckingham@redhat.com)
- fixes #6592 / BZ 1118895 - Activation Keys UI: replace 'System' references
  (bbuckingham@redhat.com)
- Merge pull request #4413 from waldenraines/6551 (walden@redhat.com)
- Fixes #6411 - filter content param in CU BZ1111484 (dtsang@redhat.com)
- Merge pull request #4415 from stbenjam/6461-duplicates (walden@redhat.com)
- Merge pull request #4411 from waldenraines/6553 (walden@redhat.com)
- Merge pull request #4329 from ehelms/fixes-5502 (ericdhelms@gmail.com)
- fixes #6329 - toggle label content view/puppet environment, toggle show/hide
  installation media on new host form (jmagen@redhat.com)
- fixes #6461 - create Katello permissions without quotes in db seeds
  (stbenjam@redhat.com)
- fixes #6512 - move valid notices routes inside resources block
  (stbenjam@redhat.com)
- Fixes #5502: Removes old Katello authorization system. (ericdhelms@gmail.com)
- fixes #6322 - clean up puppet environment on cv delete (jsherril@redhat.com)
- Merge pull request #4410 from jlsherrill/6556 (jlsherrill@gmail.com)
- Fixes #6551/BZ1112644: show add/remove content hosts if user able
  (walden@redhat.com)
- Merge pull request #4409 from jlsherrill/6555 (jlsherrill@gmail.com)
- Fixes #6554/BZ1095965 - fix path to asset in jquery-ui. (walden@redhat.com)
- Fixes #6553/BZ111225: add "repositories" to product resource type name.
  (walden@redhat.com)
- Merge pull request #4399 from jlsherrill/6518-loc (jlsherrill@gmail.com)
- fixes #6556 - setting static password in rake katello:reset
  (jsherril@redhat.com)
- fixes #6555 - removing unused candlepin cert (jsherril@redhat.com)
- fixes #6518,#5619 - Enable all templates & hostgroups for new locations
  (jsherril@redhat.com)
- Fixes #6513/bz1116933- Fixed search issues with product destroy
  (paji@redhat.com)
- Merge pull request #4407 from daviddavis/temp/20140709083624
  (daviddavis@redhat.com)
- Merge pull request #4401 from jlsherrill/6523-def_loc (jlsherrill@gmail.com)
- Merge pull request #4390 from isratrade/6499 (jlsherrill@gmail.com)
- Merge pull request #4403 from bbuckingham/issue-6527 (bbuckingham@redhat.com)
- Merge pull request #4404 from jlsherrill/6516-prod_delete
  (jlsherrill@gmail.com)
- Refs #6180,1100311 - Remove old organization destroyer code
  (daviddavis@redhat.com)
- Merge pull request #4392 from jlsherrill/6508-lowercase
  (jlsherrill@gmail.com)
- fixes #6523 - adding default boolean for tracking default loc
  (jsherril@redhat.com)
- Merge pull request #4361 from jlsherrill/6422-module_repo
  (jlsherrill@gmail.com)
- fixes #6508 - fixing package group search (jsherril@redhat.com)
- fixes #6516 - various product deletion fixes (jsherril@redhat.com)
- Fixes #6531/BZ1117487 - set active menu on $state change. (walden@redhat.com)
- Merge pull request #4360 from waldenraines/6300 (walden@redhat.com)
- Fixes #6078, #6300, #6514, BZ1105175, BZ1097054, BZ1101586: fix limit fields
  (walden@redhat.com)
- Merge pull request #4396 from bbuckingham/issue-6511 (bbuckingham@redhat.com)
- Merge pull request #4373 from cfouant/sys-detail (ericdhelms@gmail.com)
- fixes #6527 / BZ 1115955 - activation keys - filter host collections by
  organization (bbuckingham@redhat.com)
- fixes #6443 - Adds help text for release version on system details UI, BZ
  1043913 (cfouant@redhat.com)
- Merge pull request #4398 from bbuckingham/issue-6515 (bbuckingham@redhat.com)
- Merge pull request #4339 from stbenjam/6373-proxy-environments
  (jlsherrill@gmail.com)
- fixes #6511 / BZ 1109085 - content host bulk errata fixes
  (bbuckingham@redhat.com)
- Merge pull request #4388 from waldenraines/6490 (walden@redhat.com)
- fixes #6515 / BZ 1107604 - content host package action: disable Perform on
  empty input (bbuckingham@redhat.com)
- Merge pull request #4358 from jlsherrill/6415-dists (jlsherrill@gmail.com)
- Merge pull request #4380 from jlsherrill/6477-proxy (jlsherrill@gmail.com)
- Merge pull request #4394 from waldenraines/6391 (walden@redhat.com)
- Fixes #6391/BZ1091844 - use complete links for content search.
  (walden@redhat.com)
- Merge pull request #4377 from daviddavis/temp/20140702112525
  (daviddavis@redhat.com)
- Merge pull request #4383 from waldenraines/6479 (walden@redhat.com)
- Merge pull request #4391 from bbuckingham/issue-6510 (bbuckingham@redhat.com)
- Merge pull request #4330 from jlsherrill/filters (jlsherrill@gmail.com)
- Merge pull request #4376 from bbuckingham/issue-6469 (bbuckingham@redhat.com)
- Merge pull request #4384 from mbacovsky/6480_apidoc_typo
  (jlsherrill@gmail.com)
- fixes #6510 / BZ 1109138 - disable pkg action buttons when no content hosts
  selected (bbuckingham@redhat.com)
- Merge pull request #4379 from bbuckingham/issue-6472 (bbuckingham@redhat.com)
- fixes #6472 / BZ 1113230 - content view filter - fix issue where filter not
  available (bbuckingham@redhat.com)
- Fixes #6394: Manifest refresh use proxy. (ericdhelms@gmail.com)
- fixes #6499 - fix css formatting on organization form to bootstrap3
  (jmagen@redhat.com)
- Fixes #6490/BZ1116143 - remove unsed Katello javascript. (walden@redhat.com)
- fixes #6489 - use candlepin activation key name when creating consumer
  (thomasmckay@redhat.com)
- Fixes #6480 - Syntax error in param description (martin.bacovsky@gmail.com)
- Merge pull request #4369 from dustint-rh/create_CH_with_type
  (jlsherrill@gmail.com)
- Fixes #6448 - CH create w/o type and doc BZ1114065 (dtsang@redhat.com)
- Fixes #6479/BZ1115633: hide product content edit button if applicable
  (walden@redhat.com)
- fixes #6477 - fixing host/smart proxy association (jsherril@redhat.com)
- Merge pull request #4370 from komidore64/rmi6450-hammer-ping-correct-
  exitstatus (komidore64@gmail.com)
- Fixes #6460,BZ1115553 - Removing old orchestration hook
  (daviddavis@redhat.com)
- Merge pull request #4372 from daviddavis/temp/20140701103734
  (daviddavis@redhat.com)
- Merge pull request #4348 from waldenraines/6390 (walden@redhat.com)
- Fixes #6390/BZ1095098 - disabled table actions if no rows are selected.
  (walden@redhat.com)
- Merge pull request #4371 from bbuckingham/issue-6442 (bbuckingham@redhat.com)
- fixes #6469 / BZ 1113740 - content view promotion - remove org id from user
  message (bbuckingham@redhat.com)
- fixes 6415 - ignore non-bootable distributions in content view
  (jsherril@redhat.com)
- fixes #6450 - server returns correctly summary status, BZ 1094826
  (komidore64@gmail.com)
- Merge pull request #4352 from waldenraines/5181 (walden@redhat.com)
- fixes #5030 - reload filter on package group/errata rule list
  (jsherril@redhat.com)
- Fixes #5181/BZ1110955 - filter available for composte CV server side.
  (walden@redhat.com)
- Fixes #6457,BZ1115089 - Match multiple items on contents changed
  (daviddavis@redhat.com)
- fixes #6442 / BZ 1090643 - content view - add support for content view
  copy/clone (bbuckingham@redhat.com)
- fixes #6373 - make lifecycle_environment_ids accessible (stbenjam@redhat.com)
- Merge pull request #4366 from stbenjam/6434-long-env-name
  (ericdhelms@gmail.com)
- Merge pull request #4367 from bbuckingham/issue-6439 (bbuckingham@redhat.com)
- Merge pull request #4363 from bbuckingham/issue-6428 (bbuckingham@redhat.com)
- Merge pull request #4362 from bbuckingham/issue-6427 (bbuckingham@redhat.com)
- Merge pull request #4365 from stbenjam/bz1111080-uncheck-env
  (ericdhelms@gmail.com)
- fixes #6433 - allow a lifecycle environment to be unselected
  (stbenjam@redhat.com)
- Merge pull request #4303 from waldenraines/5628 (walden@redhat.com)
- Merge pull request #4368 from komidore64/rmi3272 (komidore64@gmail.com)
- refs #3272 - fixing db/seeds.rb for katello, BZ 868910 (komidore64@gmail.com)
- Fixes #5628 - remove converted v1 API controllers and tests.
  (walden@redhat.com)
- Merge pull request #4338 from dustint-rh/subman_consumer_reg
  (ericdhelms@gmail.com)
- Merge pull request #4350 from stbenjam/6392-edit-repo-name
  (walden@redhat.com)
- fixes #6428 / BZ 1109062 - Bulk Host Collection - disable add/remove when no
  hosts selected (bbuckingham@redhat.com)
- fixes #6439 / BZ 1094190 - Include notification on add/remove pkg filter rule
  (bbuckingham@redhat.com)
- fixes #6434 - wrap long lifecycle environment names in CV promotion
  (stbenjam@redhat.com)
- fixes #6427 / BZ 1109737 - remove Nest option from taxonomy actions
  (bbuckingham@redhat.com)
- fixes #6392 - make repository names editable (stbenjam@redhat.com)
- Fixes #6367 - cnsmer_shw auth client/usr BZ1112664 (dtsang@redhat.com)
- Merge pull request #4353 from parthaa/fk (parthaa@gmail.com)
- Merge pull request #4355 from parthaa/bulk-product-destroy
  (parthaa@gmail.com)
- Fixes #6409, bz 1113684 - Bulk Product destroy dynflowed. (paji@redhat.com)
- fixes 6422 - validate repoid (and pick a valid one) on cv publish
  (jsherril@redhat.com)
- Fixes #4870, bz1113398 - Added missing foreign key associations
  (paji@redhat.com)
- Fixes #6419 - Change the default org name (daviddavis@redhat.com)
- Merge pull request #4354 from waldenraines/5957 (walden@redhat.com)
- Merge pull request #4351 from dustint-rh/content_view_failure_msg_system
  (ericdhelms@gmail.com)
- Merge pull request #4304 from tstrachota/5958_cv_puppet_modules
  (kontakt@pitr.ch)
- Merge pull request #4332 from dustint-rh/AK_add_host_collections
  (komidore64@gmail.com)
- Fixes #5957/BZ1091835 - prevent product tooltip from "blinking".
  (walden@redhat.com)
- Merge pull request #4343 from waldenraines/6366 (walden@redhat.com)
- Fixes #6347 - AK doc add/rm_host_coll BZ1101537 (dtsang@redhat.com)
- Fixes #6397 - cv sys in error msg BZ1111240 (dtsang@redhat.com)
- Merge pull request #4347 from jlsherrill/ohadlevy-4341-2
  (jlsherrill@gmail.com)
- Fixes #6366/BZ1112865 - restore readonly product functionality.
  (walden@redhat.com)
- refs #6381 - changing validate_media? override to alias chain
  (jsherril@redhat.com)
- Merge pull request #4349 from jlsherrill/chosts (jlsherrill@gmail.com)
- Merge pull request #4328 from cfouant/fixes-6336 (jlsherrill@gmail.com)
- fixes #6389 - removing available content for content hosts rabl
  (jsherril@redhat.com)
- fixes #6381 - properly calculate pxe image urls when using content
  (jmagen@redhat.com)
- Merge pull request #4336 from ehelms/refs-5029 (ericdhelms@gmail.com)
- fixes #6336, #6255 - Fixes issue with not being able to use same name for an
  activation key across multiple orgs, BZ 1105024, BZ 1109907, BZ 1105024
  (cfouant@redhat.com)
- Merge pull request #4274 from ehelms/fixes-4045 (ericdhelms@gmail.com)
- Merge pull request #4335 from daviddavis/temp/20140624134130
  (daviddavis@redhat.com)
- Fixes #4045: Repository name and label validations properly handled.
  (ericdhelms@gmail.com)
- Refs #5029: Allow initial organization and location to be specified during
  seed. (ericdhelms@gmail.com)
- Fixes #6183 - Convert system unregister to dynflow (daviddavis@redhat.com)
- Merge pull request #4334 from ehelms/fixes-6200 (ericdhelms@gmail.com)
- Merge pull request #4257 from ehelms/fixes-6176 (ericdhelms@gmail.com)
- Merge pull request #4337 from thomasmckay/5114-actkey-limits
  (thomasmckay@redhat.com)
- Fixes #5958 - content-view puppet module operations (tstrachota@redhat.com)
- fixes #5114 - enforce limits when registering through subscription-manager
  (thomasmckay@redhat.com)
- Merge pull request #4314 from waldenraines/6001 (walden@redhat.com)
- Fixes #6001 - specify local or server time for sync plan times.
  (walden@redhat.com)
- Fixes #6176, #5030, #4969, BZ1103492: Improving interaction of content view
  errata id filters. (ericdhelms@gmail.com)
- Fixes #6200: Rename nodes to capsules throughout UI. (ericdhelms@gmail.com)
- Merge pull request #4333 from thomasmckay/6323-page-content
  (thomasmckay@redhat.com)
- Merge pull request #4331 from mccun934/20140623-1451 (mmccune@gmail.com)
- Merge pull request #4320 from ehelms/fixes-4702 (ericdhelms@gmail.com)
- fixes #6323 - correctly get enabled products and full unpaged results
  (thomasmckay@redhat.com)
- Merge pull request #4323 from jlsherrill/capsule (jlsherrill@gmail.com)
- fixes #6346 - remove reference to unused bugzilla (mmccune@redhat.com)
- Fixes #4702: Only include selected repositories in UI when filtering for
  content view. (ericdhelms@gmail.com)
- Merge pull request #4308 from ehelms/fixes-5451 (ericdhelms@gmail.com)
- Merge pull request #4311 from ehelms/fixes-5805 (ericdhelms@gmail.com)
- Merge pull request #4299 from bbuckingham/issue-6270 (bbuckingham@redhat.com)
- Merge pull request #4321 from bbuckingham/issue-6276 (bbuckingham@redhat.com)
- fixes #6270 / BZ 1110020 - fix issues with content view version deletion
  (bbuckingham@redhat.com)
- fixes #6276 / BZ 1106378 - content view package filter - allow user to change
  existing rules (bbuckingham@redhat.com)
- Merge pull request #4327 from waldenraines/6324 (walden@redhat.com)
- Merge pull request #4302 from daviddavis/temp/20140618163727
  (daviddavis@redhat.com)
- Fixes #6342 - correct permission of environment remove button.
  (walden@redhat.com)
- Fixes #6189 - Rework activation key destroy with dynflow
  (daviddavis@redhat.com)
- Merge pull request #4316 from thomasmckay/6301-api-guests
  (thomasmckay@redhat.com)
- Refs #6113 - use dynflow tasks to modify capsule lifecycle env
  (jsherril@redhat.com)
- Merge pull request #4307 from ehelms/fixes-5040 (ericdhelms@gmail.com)
- Merge pull request #4322 from ehelms/fixes-4999 (ericdhelms@gmail.com)
- Merge pull request #4295 from MichaelMraka/master (walden@redhat.com)
- Fixes #4999: Allow repository creation using only the keyboard to traverse
  the form. (ericdhelms@gmail.com)
- Merge pull request #4312 from thomasmckay/6924-subs-rabl
  (thomasmckay@redhat.com)
- Merge pull request #4319 from jlsherrill/reindex (jlsherrill@gmail.com)
- fixes #6113 - add lifecycle environment tab to smart proxy / capsule form
  (joseph@isratrade.co.il)
- fixes #6317 - fixing reindex rake task due to improper include
  (jsherril@redhat.com)
- Fixes #5439/BZ1076357 - align "Cancel" link not to cross table border
  (michael.mraka@redhat.com)
- Merge pull request #4315 from ehelms/fixes-6165 (ericdhelms@gmail.com)
- Merge pull request #4317 from ehelms/fixes-5108 (ericdhelms@gmail.com)
- Merge pull request #4318 from ehelms/fixes-5944 (ericdhelms@gmail.com)
- Merge pull request #4218 from parthaa/product-destroy (daviddavis@redhat.com)
- Merge pull request #4282 from jlsherrill/isratrade-6145
  (jlsherrill@gmail.com)
- Merge pull request #4305 from bbuckingham/issue-6290 (bbuckingham@redhat.com)
- Fixes #5944: Ensure links to old Katello pages are followed.
  (ericdhelms@gmail.com)
- Fixes #5108: Wrap li's in ul to prevent showing up outside table cell.
  (ericdhelms@gmail.com)
- Fixes #6165: Ensure all repositories loaded on content view repository lists.
  (ericdhelms@gmail.com)
- Merge pull request #4279 from parthaa/cvv-perms-fix (parthaa@gmail.com)
- Merge pull request #4108 from ehelms/fixes-5713 (ericdhelms@gmail.com)
- Fixes #5081, #6185 - Dynflowing product delete (paji@redhat.com)
- Fixes #6195, bz1109386 - 403 on cv version delete (paji@redhat.com)
- fixes #6301 - correcting host/guest (thomasmckay@redhat.com)
- fixes #6290 / BZ 1111078 - fix host <-> content host association during
  registration (bbuckingham@redhat.com)
- Merge pull request #4280 from parthaa/provisioner (parthaa@gmail.com)
- fixes #6924 - correct subscriptions json output (thomasmckay@redhat.com)
- Merge pull request #4310 from waldenraines/5543 (walden@redhat.com)
- Fixes #5040: Fix organization wide auto attach of subscriptions via API and
  UI. (ericdhelms@gmail.com)
- Fixes #5805: Update qpidd.conf location and grab Pulp messages in debug.
  (ericdhelms@gmail.com)
- Fixes #5543/BZ1102322 - fix content search autocomplete. (walden@redhat.com)
- Merge pull request #4309 from ehelms/fixes-4981 (ericdhelms@gmail.com)
- Fixes #4981: Update link to custom content repositories on sync management.
  (ericdhelms@gmail.com)
- refs #6145 - use content source instead of pulp proxy (jsherril@redhat.com)
- refs #6145 - use content source for content upon registration
  (jsherril@redhat.com)
- Fixes #4647: Hide 'Sync Now' button on feedless repositories.
  (ericdhelms@gmail.com)
- Fixes #5713: Removes instance method declarations from included block of
  concerns. (ericdhelms@gmail.com)
- refs #6145 - calculating installation url based on smart proxy
  (jsherril@redhat.com)
- Merge pull request #4288 from GregSutcliffe/6256 (jlsherrill@gmail.com)
- Merge pull request #4256 from ehelms/fixes-5523 (ericdhelms@gmail.com)
- Fixes #5523: Content host available releases are now calculated based on
  content view. (ericdhelms@gmail.com)
- Merge pull request #4238 from iNecas/issue/5719 (inecas@redhat.com)
- Merge pull request #4276 from cfouant/fixes-6064 (jlsherrill@gmail.com)
- Merge pull request #4286 from ehelms/fixes-6239 (ericdhelms@gmail.com)
- fixes #6064 - Content-view filters can be sorted by name, BZ 1102451
  (cfouant@redhat.com)
- Merge pull request #4289 from ehelms/fixes-4847 (ericdhelms@gmail.com)
- Merge pull request #4293 from cfouant/fixes-6262 (walden@redhat.com)
- Merge pull request #4285 from ehelms/fixes-4172 (ericdhelms@gmail.com)
- Merge pull request #4277 from jlsherrill/puppet (jlsherrill@gmail.com)
- fixes #6262 - wraps system name display to prevent overlapping in table, BZ
  1019773 (cfouant@redhat.com)
- Fixes #4847: Add loading spinner for environment selector on promotion page.
  (ericdhelms@gmail.com)
- Merge pull request #4301 from waldenraines/6274 (walden@redhat.com)
- Merge pull request #4298 from waldenraines/6271 (walden@redhat.com)
- Merge pull request #4226 from waldenraines/5503 (walden@redhat.com)
- Merge pull request #4300 from cfouant/fixes-6277 (walden@redhat.com)
- fixes #6243 - making available module list org aware (jsherril@redhat.com)
- Fixes #6274 - only disable initial load if it's actually disabled.
  (walden@redhat.com)
- Fixes #6271 - add var convention to Bastion readme (walden@redhat.com)
- Merge pull request #4284 from ehelms/fixes-6249 (ericdhelms@gmail.com)
- fixes #6277 - fixes issue with promotion hint not matching functionality, BZ
  1091941 (cfouant@redhat.com)
- Fixes #6239: Ensure product label and name uniqueness is adhered to.
  (ericdhelms@gmail.com)
- Fixes #5503/BZ1102315 - restrict UI interactions to actual permissions.
  (walden@redhat.com)
- Merge pull request #4297 from bbuckingham/issue-6269 (bbuckingham@redhat.com)
- fixes #6269 / BZ 1110486 - activation key - include description on details
  pane (bbuckingham@redhat.com)
- fixes #6145 - add pulp proxy to host form (joseph@isratrade.co.il)
- fixes #6144 - fix css formatting formatting fields on katello form builder to
  bootstrap3 (joseph@isratrade.co.il)
- Merge pull request #4246 from isratrade/6156 (jlsherrill@gmail.com)
- Merge pull request #4292 from waldenraines/6260 (walden@redhat.com)
- Merge pull request #4290 from dustint-rh/ak_put_env_not_required
  (thomasmckay@redhat.com)
- Merge pull request #4291 from waldenraines/6252 (walden@redhat.com)
- Fixes #6260/BZ1023881 - display OS on content host index page.
  (walden@redhat.com)
- Fixes #6258 - env_id & cv_id optional in ak update (dtsang@redhat.com)
- Fixes #5451: Load only custom products for repo discovery.
  (ericdhelms@gmail.com)
- Fixes #6252/BZ1087079 - default to errata_id on bulk errata searches.
  (walden@redhat.com)
- Merge pull request #4263 from bbuckingham/issue-6204 (bbuckingham@redhat.com)
- Fixes #6256 - Handle a nil value in kt_env for hostgroups
  (gsutclif@redhat.com)
- Fixes #6246, bz1100582 - Services mods for  KS templates (paji@redhat.com)
- Merge pull request #4244 from dustint-rh/system_index_filter_org_env
  (thomasmckay@redhat.com)
- fixes #6204 / BZ 1099016 - Fix gpg key on repo create and yum retrieval
  (bbuckingham@redhat.com)
- Fixes #4172: Prevent alch-edit-select errors by checking if editTrigger
  exists. (ericdhelms@gmail.com)
- Merge pull request #4189 from dustint-
  rh/org_api_apipie_param_group_resource_substitution (komidore64@gmail.com)
- Merge pull request #4283 from daviddavis/temp/20140617090242
  (daviddavis@redhat.com)
- Fixes #6249,BZ1109398: Candlepin proxy routes properly looking up
  organization. (ericdhelms@gmail.com)
- Fixes #6250,BZ1110012 - Define search_type for PuppetModule class
  (daviddavis@redhat.com)
- Merge pull request #4278 from bkearney/bkearney/6245
  (bryan.kearney@gmail.com)
- Merge pull request #4265 from daviddavis/temp/20140613091921
  (daviddavis@redhat.com)
- Fixes #6147 - filter both org and env in sys (dtsang@redhat.com)
- Merge pull request #4266 from thomasmckay/6215 (thomasmckay@redhat.com)
- Merge pull request #4264 from thomasmckay/6197-host-guest
  (thomasmckay@redhat.com)
- Fixes #6245 : Add mongo and postgres logs to katello debug
  (bkearney@redhat.com)
- Merge pull request #4248 from bbuckingham/issue-5026 (bbuckingham@redhat.com)
- fixes #6215 - do not pass full objects to rabl (thomasmckay@redhat.com)
- Merge pull request #4275 from waldenraines/6242 (walden@redhat.com)
- Fixes #6242 - remove unused distributor from rabl to fix error.
  (walden@redhat.com)
- Merge pull request #4271 from parthaa/dynflow-dev (parthaa@gmail.com)
- Merge pull request #4270 from ehelms/fixes-6221 (ericdhelms@gmail.com)
- fixes #6197 - moving host/guests to virtual_host/virtual_guests
  (thomasmckay@redhat.com)
- Fixes #5555 - fix org update action's apipie param (dtsang@redhat.com)
- Merge pull request #4268 from cfouant/product-version (ericdhelms@gmail.com)
- Merge pull request #4269 from bbuckingham/issue-5955 (bbuckingham@redhat.com)
- Fixes #6221: Content host errata and host collection bulk actions no longer
  400. (ericdhelms@gmail.com)
- Merge pull request #4233 from daviddavis/temp/20140609132351
  (daviddavis@redhat.com)
- Fixes #6211,BZ1102521 - Requiring a user to ping pulp_auth
  (daviddavis@redhat.com)
- Merge pull request #4229 from waldenraines/6046 (walden@redhat.com)
- Merge pull request #4259 from ehelms/fixes-4610 (ericdhelms@gmail.com)
- Fixes #6046/BZ1103317 - fix display of version on composite CV page.
  (walden@redhat.com)
- Fixes #6237 - allow canceling remote execution actions (inecas@redhat.com)
- Fixes #5719 - poll directly after sending the cancel (inecas@redhat.com)
- Fixes #6222 - Auto Enables dynflow console for dev mode (paji@redhat.com)
- refs #5955 / BZ 1094633 - update content view removal to update history
  (bbuckingham@redhat.com)
- fixes #5955 / BZ 1094633 - update the content dashboard for content views
  (bbuckingham@redhat.com)
- fixes #6220 - Adds product version to content host details installed products
  list, BZ 1043900 (cfouant@redhat.com)
- Merge pull request #4254 from daviddavis/update-system-info-subs
  (daviddavis@redhat.com)
- Merge pull request #4262 from komidore64/rmi6206-repository-filter-by-name
  (komidore64@gmail.com)
- Merge pull request #4261 from daviddavis/temp/20140612150554
  (daviddavis@redhat.com)
- fixes #6206 - looking repositories by name, BZ 1108096 (komidore64@gmail.com)
- Merge pull request #4240 from stbenjam/5761-realm-template
  (jlsherrill@gmail.com)
- Merge pull request #4258 from ehelms/fixes-6198 (ericdhelms@gmail.com)
- Fixes #6202,BZ1085494 - Fix legacy_search for PuppetModule
  (daviddavis@redhat.com)
- Fixes #5245: Prevent selecting all items when searching.
  (ericdhelms@gmail.com)
- Fixes #4610: Stop double submission of sync action on sync management.
  (ericdhelms@gmail.com)
- Fixes #6198: API methods that load database records should request only ID
  field. (ericdhelms@gmail.com)
- Merge pull request #4247 from komidore64/rmi6168-subscription-list-require-
  org (komidore64@gmail.com)
- Merge pull request #4252 from komidore64/rmi6173-gpgkey-filter-name
  (komidore64@gmail.com)
- Fixes #6175 BZ1102951: Worked on updating content hosts details
  (daviddavis@redhat.com)
- Merge pull request #4255 from ehelms/fixes-4964 (ericdhelms@gmail.com)
- fixes #4636 - refactor OperatingsystemExtensions to RedhatExtensions and
  refactor MediumExtensions (joseph@isratrade.co.il)
- fixes #5026 / BZ 1094176 - content view package group filter - handle
  duplicate group names across repos (bbuckingham@redhat.com)
- Fixes #4964, #4963: Product json incorrectly grabbed all repositories.
  (ericdhelms@gmail.com)
- Merge pull request #4245 from parthaa/publish-fix (parthaa@gmail.com)
- Merge pull request #4253 from waldenraines/6174 (walden@redhat.com)
- Merge pull request #4251 from thomasmckay/6172-hidden-user
  (thomasmckay@redhat.com)
- Fixes #6174/BZ 1020808 - ensure host advanced info link is displayed.
  (walden@redhat.com)
- fixes #6173 - gpg info to now filter by name, BZ 1108227
  (komidore64@gmail.com)
- Merge pull request #4249 from ehelms/fixes-6171 (ericdhelms@gmail.com)
- Merge pull request #4250 from ehelms/fixes-6170 (ericdhelms@gmail.com)
- fixes #6172 - give hidden user access to all orgs (thomasmckay@redhat.com)
- Fixes #6170: Changes 'Environment' to 'Lifecycle Environment' on overriden
  Foreman pages. (ericdhelms@gmail.com)
- Fixes #6171: Remove nil UUIDs when generating content host list.
  (ericdhelms@gmail.com)
- Fixes #6153, bz1107876 - Fixed cv package excludes publish (paji@redhat.com)
- Merge pull request #4242 from daviddavis/temp/20140610140413
  (daviddavis@redhat.com)
- Fixes #6146 BZ1105623: Fixing undefined method call (daviddavis@redhat.com)
- fixes #6168 - subscription list should require org, BZ 1097647
  (komidore64@gmail.com)
- Merge pull request #4237 from bbuckingham/issue-5974 (bbuckingham@redhat.com)
- Merge pull request #4231 from bbuckingham/issue-6120 (bbuckingham@redhat.com)
- Merge pull request #4227 from bbuckingham/issue-6108 (bbuckingham@redhat.com)
- fixes #6108/BZ 1105310 - ensure unique name when creating installation media
  (bbuckingham@redhat.com)
- fixes #6151 - filter content-views by name for hammer, BZ 1107319
  (komidore64@gmail.com)
- Refs #6123,BZ1106563 - Disabling org deletion (daviddavis@redhat.com)
- Fixes #5761, #5899 - Update Katello kickstarts (stbenjam@redhat.com)
- Merge pull request #4235 from waldenraines/5552 (walden@redhat.com)
- Merge pull request #4232 from waldenraines/5162 (walden@redhat.com)
- Fixes #5719 - make pulp async actions cancellable (inecas@redhat.com)
- Merge pull request #4234 from bbuckingham/issue-6124 (bbuckingham@redhat.com)
- Merge pull request #4211 from jlsherrill/async_node_publish
  (jlsherrill@gmail.com)
- Fixes #6072 - Report issues on repo syncing and don't lock repository on
  failure (inecas@redhat.com)
- Fixes #4748 - update dependencies (inecas@redhat.com)
- Fixes #4748 - don't lock on manifest operations fail (inecas@redhat.com)
- Merge pull request #4191 from jlsherrill/original_packages
  (jlsherrill@gmail.com)
- Merge pull request #4223 from ehelms/fixes-6080 (ericdhelms@gmail.com)
- fixes #5974 / BZ1098165 - content host - fix issue with spinner on package
  deletion (bbuckingham@redhat.com)
- Fixes #5552/BZ1093751 - Prevent sorting on columns that aren't sortable.
  (walden@redhat.com)
- fixes #6124 / BZ1104807 - fix content host 'update all' action
  (bbuckingham@redhat.com)
- Merge pull request #4230 from waldenraines/6122 (walden@redhat.com)
- Merge pull request #4221 from thomasmckay/6059-prod-content
  (thomasmckay@redhat.com)
- Merge pull request #4222 from bbuckingham/issue-5742 (bbuckingham@redhat.com)
- Fixes #6122 - correct typo in new sync plan URL. (walden@redhat.com)
- Fixes #5162/BZ1096407 - fix setting of sync time for new sync plans.
  (walden@redhat.com)
- fixes #6120 / BZ1102963 - address error during content host bulk actions
  (bbuckingham@redhat.com)
- Merge pull request #4208 from ehelms/fixes-6047 (ericdhelms@gmail.com)
- Merge pull request #4225 from ehelms/fixes-6102 (ericdhelms@gmail.com)
- fixes #6059 - add 'product content' tab to content hosts UI
  (thomasmckay@redhat.com)
- Merge pull request #4224 from parthaa/repo-feed (parthaa@gmail.com)
- Fixes #6080, #6081, #6082: Fixing registration including adding back default
  organization. (ericdhelms@gmail.com)
- Fixes #6102: Allow numbers in package names, BZ1047811.
  (ericdhelms@gmail.com)
- Merge pull request #4196 from komidore64/rmi5803-content-host-list-filter-by-
  name (komidore64@gmail.com)
- Merge pull request #4187 from komidore64/rmi5892-custom-info-notification-on-
  update (komidore64@gmail.com)
- Fixes #6084, bz 1079161 - Updated sync state link (paji@redhat.com)
- Merge pull request #4169 from daviddavis/content-uploads
  (daviddavis@redhat.com)
- fixes #5803 - filter content-hosts by name, BZ 1097575 (komidore64@gmail.com)
- fixes #5449 - adding CV filter option to include packages with no errata
  (jsherril@redhat.com)
- Merge pull request #4220 from jlsherrill/tstrachota-search
  (jlsherrill@gmail.com)
- Merge pull request #4214 from bbuckingham/issue-5967 (bbuckingham@redhat.com)
- fixes #5742/BZ1098152 - fix consumer action to display failure message
  (bbuckingham@redhat.com)
- Refs #5813 - Content uploads BZ1102260 (daviddavis@redhat.com)
- fixes #6051 - do not wait for node metadata publish (jsherril@redhat.com)
- Merge pull request #4216 from cfouant/content-view-filter-by-name
  (walden@redhat.com)
- Merge pull request #4198 from parthaa/product-gpg (parthaa@gmail.com)
- Merge pull request #4212 from parthaa/cv-filter-rule (parthaa@gmail.com)
- Merge pull request #4210 from cfouant/titles (walden@redhat.com)
- Merge pull request #4205 from waldenraines/6040 (walden@redhat.com)
- Merge pull request #4185 from ehelms/fixes-5765 (ericdhelms@gmail.com)
- Merge pull request #4182 from ehelms/fixes-5027 (ericdhelms@gmail.com)
- Refs #4701 - updating VCR cassettes (jsherril@redhat.com)
- Fixes #4701, #5874 - removed lowercase filter from kt_name_analyzer
  (tstrachota@redhat.com)
- Merge pull request #4217 from bbuckingham/issue-5743 (bbuckingham@redhat.com)
- fixes #6064 - fixes content view filter not honoring the name parameter, BZ
  1102451 (cfouant@redhat.com)
- fixes #5743/BZ1097124 - content host - host collections bulk action "loading"
  fix (bbuckingham@redhat.com)
- Fixes #5027: Ensure errata filter notification on add/remove, BZ1079245.
  (ericdhelms@gmail.com)
- Merge pull request #4147 from parthaa/sys-registration (parthaa@gmail.com)
- Merge pull request #4181 from mstead/Fixes-5968-release-versions
  (ericdhelms@gmail.com)
- Fixes #5765: Ensure repositories appear on content view details when
  searching, BZ1086187. (ericdhelms@gmail.com)
- Merge pull request #4179 from ehelms/fixes-5986 (ericdhelms@gmail.com)
- Fixes #5911 - perms for system registration calls (paji@redhat.com)
- fixes #5967 - initial updates to support default capsule
  (bbuckingham@redhat.com)
- Fixes #6050 - Better error message on filter rules create (paji@redhat.com)
- Merge pull request #4215 from jmontleon/add-qpid-cpp-store
  (ericdhelms@gmail.com)
- Merge pull request #4203 from waldenraines/5163 (walden@redhat.com)
- Fixes #5992 and #5993 - qpid-cpp-server-store needs to be added to the repo
  (jmontleo@redhat.com)
- Merge pull request #4133 from thomasmckay/5860-actkey-validate
  (thomasmckay@redhat.com)
- Fixes #6049 - fixes issue with incorrect page titles, BZ 1099469
  (cfouant@redhat.com)
- Merge pull request #4204 from jlsherrill/events (jlsherrill@gmail.com)
- Merge pull request #4209 from bkearney/bkearney/6048
  (bryan.kearney@gmail.com)
- Fixes 6048: The spec file was not building due to the new katello-debug
  changes (bkearney@redhat.com)
- Merge pull request #4200 from mstead/Fixes-6021 (ericdhelms@gmail.com)
- Fixes #6047: Prevent search grid from folding under row headers, BZ1083319.
  (ericdhelms@gmail.com)
- Fixes #6027 - Made product gpg update more secure (paji@redhat.com)
- Merge pull request #4202 from daviddavis/temp/20140603101658
  (daviddavis@redhat.com)
- Merge pull request #4201 from ehelms/fixes-5769 (ericdhelms@gmail.com)
- Merge pull request #4199 from parthaa/repo-gpg-fix (parthaa@gmail.com)
- refs #5892 - adding notifcation for custom_info update, BZ 970079
  (komidore64@gmail.com)
- Merge pull request #4194 from jmontleon/update-deps-for-qpid
  (mmccune@gmail.com)
- Fixes #6021 - Remove route mapping to UsersController (mstead@redhat.com)
- Fixes 6041: Convert katello-debug to be an extension of foreman-debug
  (bkearney@redhat.com)
- Fixes #6040, adding katello permissions to foreman "viewer" role.
  (walden@redhat.com)
- fixes #6038 - removing content host event page (jsherril@redhat.com)
- Fixes #5163/BZ848564 - ensure limited host groups have >= 1 hosts.
  (walden@redhat.com)
- Merge pull request #4186 from cfouant/subscription-color
  (komidore64@gmail.com)
- Merge pull request #4188 from bbuckingham/issue-5184 (bbuckingham@redhat.com)
- Fixes #5989 - Fixing puppet repo sync check BZ1102826 (daviddavis@redhat.com)
- Merge pull request #4190 from jlsherrill/index (jlsherrill@gmail.com)
- Fixes #5769: Adding autocomplete to package filters, BZ1079181.
  (ericdhelms@gmail.com)
- Fixes 5992 and 5993 - qpid dependencies (jmontleo@redhat.com)
- Fixes #5968: Intercept candlepin request to get available releases
  (mstead@redhat.com)
- Merge pull request #4192 from iNecas/capsule-puppet (inecas@redhat.com)
- Merge pull request #4184 from iNecas/5908 (inecas@redhat.com)
- Fixes #5860 - correctly error on validation failure (thomasmckay@redhat.com)
- Fixes #6023 - Fixed code to associate gpg key to a product (paji@redhat.com)
- Fixes #6026 - Fixed repo list api call for no env case. (paji@redhat.com)
- Merge pull request #4193 from ehelms/fixes-5759 (ericdhelms@gmail.com)
- Merge pull request #4195 from cfouant/typoContentHost (walden@redhat.com)
- Fixes #6005 - speeding up content reindexing (jsherril@redhat.com)
- fixes #6018 - fixes typo in Existing Items, BZ 1103283 (cfouant@redhat.com)
- Merge pull request #4175 from dustint-rh/host_collections_create_take_uuid
  (thomasmckay@redhat.com)
- Fixes #5802 - HC update/create using system uuids (dtsang@redhat.com)
- Merge pull request #4127 from ehelms/refs-5681 (ericdhelms@gmail.com)
- Fixes #5759: Make search and filtering on Content View Filters work as
  intended. (ericdhelms@gmail.com)
- Fixes #6008 - Puppet environments synchronization capsule synchronization
  (inecas@redhat.com)
- refs #5184 - fix couple of issues when deleting foreman hosts
  (bbuckingham@redhat.com)
- fixes #6002 - updates subscription status color on webUI, BZ1019389
  (cfouant@redhat.com)
- Merge pull request #4132 from waldenraines/5843 (walden@redhat.com)
- Merge pull request #4177 from komidore64/rmi5983-id-param-for-org-delete
  (komidore64@gmail.com)
- Merge pull request #4180 from daviddavis/temp/20140529124847
  (daviddavis@redhat.com)
- Fixes #5908 - make sure the dynflow on_init are set before the world being
  initialized (inecas@redhat.com)
- Merge pull request #4165 from iNecas/issue/5950 (inecas@redhat.com)
- fixes #5983 - added missing --id param to `hammer org delete`, BZ1096241
  (komidore64@gmail.com)
- Merge pull request #3998 from jlsherrill/pkg_delete (jlsherrill@gmail.com)
- Fixes #5989 - Fixing puppet repo sync BZ1102826 (daviddavis@redhat.com)
- Fixes #5986: Ensure tipsy error details populated on sync status page,
  BZ965230. (ericdhelms@gmail.com)
- Merge pull request #4161 from jlsherrill/states (jlsherrill@gmail.com)
- Merge pull request #4176 from ehelms/fixes-5982 (ericdhelms@gmail.com)
- fixes #5402 - adding feature to remove packages from library repos
  (jsherril@redhat.com)
- Merge pull request #4159 from cfouant/cfouant-branch-0527
  (jlsherrill@gmail.com)
- Fixes #5982: Ellipsis content search package descriptions to prevent
  overflow, BZ1012606. (ericdhelms@gmail.com)
- Merge pull request #4174 from parthaa/host-reload-hack (parthaa@gmail.com)
- Fixes #5978 - Included content host in Host::Managed (paji@redhat.com)
- Merge pull request #4160 from waldenraines/5947 (walden@redhat.com)
- Merge pull request #4172 from parthaa/slash-fix (parthaa@gmail.com)
- Merge pull request #4170 from waldenraines/5956 (walden@redhat.com)
- Fixes #5975 - Fix for a Content Host  UI reload issue (paji@redhat.com)
- Merge pull request #4171 from ehelms/fixes-5231 (ericdhelms@gmail.com)
- Merge pull request #4158 from ehelms/fixes-5938 (ericdhelms@gmail.com)
- Fixes #5938: Some Candlepin routes need User authorization due to
  subscription manager GUI. (ericdhelms@gmail.com)
- Fixes #5231: Host collection action links will properly select hosts,
  BZ1096183. (ericdhelms@gmail.com)
- Fixes #5956/BZ1083314 - add puppet module count to content view versions.
  (walden@redhat.com)
- Merge pull request #4151 from ehelms/fixes-5627 (ericdhelms@gmail.com)
- Merge pull request #4162 from bbuckingham/issue-5954 (bbuckingham@redhat.com)
- Merge pull request #4168 from jlsherrill/angular-templates
  (jlsherrill@gmail.com)
- fixes #5972 - reverting to specific angular-rails-templates version
  (jsherril@redhat.com)
- Merge pull request #4166 from iNecas/issue/5961 (inecas@redhat.com)
- Fixes #5947/BZ1028098 - allow selecting empty GPG key and sync plan.
  (walden@redhat.com)
- fixes #5951 - adds environment hint to content host registration, BZ1085252
  (cfouant@redhat.com)
- Merge pull request #4146 from komidore64/rmi5892-custom-info-notifications
  (komidore64@gmail.com)
- fixes #5954 - content search - fix puppet module details
  (bbuckingham@redhat.com)
- Merge pull request #4163 from bbuckingham/issue-5962 (bbuckingham@redhat.com)
- Merge pull request #4155 from cfouant/cfouant-branch (ericdhelms@gmail.com)
- Fixes #5961 - access the Dynflow world after it had been initialized
  (inecas@redhat.com)
- Fixes #5863 - create consumer in plan phase (inecas@redhat.com)
- Refs #5950 - don't show details when the task output is empty
  (inecas@redhat.com)
- Fixes #5627: Wrapping tasks controller in new authorization.
  (ericdhelms@gmail.com)
- fixes #5962 - content search - fix link to manage environments
  (bbuckingham@redhat.com)
- fixes #5960 - also look at task states to determine completion
  (jsherril@redhat.com)
- fixes #5892 - displays notification on add and delete, BZ970079
  (komidore64@gmail.com)
- Merge pull request #4157 from waldenraines/5940 (walden@redhat.com)
- Fixes #5940/BZ1080361, show loading indicator for content view versions.
  (walden@redhat.com)
- Merge pull request #4153 from bbuckingham/issue-5800 (bbuckingham@redhat.com)
- Merge pull request #4156 from iNecas/1099221 (inecas@redhat.com)
- Merge pull request #4115 from bbuckingham/issue-5184 (bbuckingham@redhat.com)
- Fixes #5574 - consider 301 as correct response for the cdn path
  (inecas@redhat.com)
- Merge pull request #4154 from bbuckingham/issue-5801 (bbuckingham@redhat.com)
- Merge pull request #4128 from daviddavis/temp/20140521082727
  (daviddavis@redhat.com)
- Merge pull request #4150 from iNecas/5908 (inecas@redhat.com)
- Fixes #5843, removing api v1 routes. (walden@redhat.com)
- fixes #5919 - Fixes issue with katello plugin description, BZ1079191 (cfouant
  @centos-devel.local)
- fixes #5801 - host collection ui - update errors should be shown on UI
  (bbuckingham@redhat.com)
- Merge pull request #4152 from parthaa/sql-fix (parthaa@gmail.com)
- fixes #5800 - host collections ui - errors on add/remove should be displayed
  (bbuckingham@redhat.com)
- Fixes #5917 - Content search ambiguous SQL id error (paji@redhat.com)
- Merge pull request #4140 from ehelms/fixes-5884 (ericdhelms@gmail.com)
- Merge pull request #4142 from ehelms/fixes-5526 (ericdhelms@gmail.com)
- refs #5184 - rename 'remove' to 'unregister' for content host ui
  (bbuckingham@redhat.com)
- fixes #5184 - extend foreman host to provide association to katello content
  host (bbuckingham@redhat.com)
- Fixes #5908 - transfer the locale information to the dynflow run/finalize
  phase (inecas@redhat.com)
- Fixes #5884: Fix typo for list_owners authenication to be properly handled.
  (ericdhelms@gmail.com)
- Merge pull request #4148 from waldenraines/5913 (walden@redhat.com)
- Fixes #5913, BZ1093601 let org-switcher clear URLs pass through bastion.
  (walden@redhat.com)
- Merge pull request #4139 from cfouant/cfouant-branch (ericdhelms@gmail.com)
- Merge pull request #4141 from ehelms/fixes-5886 (ericdhelms@gmail.com)
- Merge pull request #4131 from thomasmckay/5857-snippet
  (thomasmckay@redhat.com)
- Fixes #5526: Ensure content APIs are properly permission wrapped.
  (ericdhelms@gmail.com)
- Fixes #5886: Return organizations for the admin user. (ericdhelms@gmail.com)
- Merge pull request #4144 from jlsherrill/iNecas-capsule-api
  (jlsherrill@gmail.com)
- Merge pull request #4118 from iNecas/capsule-api (jlsherrill@gmail.com)
- Merge pull request #4143 from bbuckingham/issue-5819 (bbuckingham@redhat.com)
- fixes #5819 - host groups - fix the cross-link to activation keys page
  (bbuckingham@redhat.com)
- Fixes #5821 - better graceful handling of node binding/unbinding
  (jsherril@redhat.com)
- Merge pull request #4138 from waldenraines/5703 (walden@redhat.com)
- Merge pull request #4137 from waldenraines/4946 (walden@redhat.com)
- updated all references from system to content host (cfouant@centos-
  devel.local)
- Fixes #5703, prevent infinite loop on trailing slash. (walden@redhat.com)
- Fixes #5768 Changed term system to content-host (cfouant@centos-devel.local)
- Fixes #4946/BZ1093601 - allow org-switcher urls to pass through angular.
  (walden@redhat.com)
- Fixes #5821 - add capsule content authorization tests (inecas@redhat.com)
- Merge pull request #4130 from waldenraines/4945 (walden@redhat.com)
- Fixes #5821 - add capsule content authorization (inecas@redhat.com)
- Fixes #5821 - fix binding repository to the node (inecas@redhat.com)
- Fixes #5821 - add tests for capsule related features (inecas@redhat.com)
- Merge pull request #4136 from parthaa/ak-fix (parthaa@gmail.com)
- Merge pull request #4117 from ehelms/fixes-5501 (ericdhelms@gmail.com)
- Fixes #5866 - Reduced Product json serialization footprint (paji@redhat.com)
- Merge pull request #4135 from jlsherrill/sync (jlsherrill@gmail.com)
- Fixes #5501: Ensures consistent permission naming with Foreman permissions.
  (ericdhelms@gmail.com)
- fixes #5864 - fix broken sync on sync status page (jsherril@redhat.com)
- Merge pull request #4129 from ehelms/refs-5502 (ericdhelms@gmail.com)
- Merge pull request #4134 from jlsherrill/services (jlsherrill@gmail.com)
- Merge pull request #4107 from ehelms/fixes-5529 (ericdhelms@gmail.com)
- fixes #5862 - adding pulp 2.4 services to katello-service
  (jsherril@redhat.com)
- Fixes #5852 - Updating gem dependencies (daviddavis@redhat.com)
- fixes #5857 - enclose sub-mgr args in quotes (thomasmckay@redhat.com)
- Fixes #4945/BZ1059846, show select an org message on 403 page.
  (walden@redhat.com)
- Merge pull request #4124 from thomasmckay/5737-index (thomasmckay@redhat.com)
- Refs #5502: Remove Content Roles access from UI. (ericdhelms@gmail.com)
- Fixes #5529: Updating dashboard with new permissions. (ericdhelms@gmail.com)
- Fixes #5821 - address PR review issues (inecas@redhat.com)
- fixes #5737 - corrected multiple index controllers (thomasmckay@redhat.com)
- Merge pull request #4099 from ehelms/fixes-5532 (ericdhelms@gmail.com)
- Refs #5681: Candlepin reset only needs to drop, create and migrate the
  database. (ericdhelms@gmail.com)
- Fixes #5532: Wraps content search in Foreman permission system.
  (ericdhelms@gmail.com)
- Fixes #5846 - CV index sql error (paji@redhat.com)
- Merge pull request #4125 from jlsherrill/enabled_repos (jlsherrill@gmail.com)
- fixes #5804 - moving enabled_repos call to the candlepin proxies controller
  (jsherril@redhat.com)
- add cyrus-sasl-plain dependency for pulp (jmontleo@redhat.com)
- Merge pull request #4122 from thomasmckay/5825-env-index
  (thomasmckay@redhat.com)
- fixes #5825 - added id to elasticsearch indexing (thomasmckay@redhat.com)
- Merge pull request #4121 from thomasmckay/5828-actkey-api
  (thomasmckay@redhat.com)
- fixes #5828 - correct regression in act key index api method
  (thomasmckay@redhat.com)
- Fixes #5821 - Remove the fort engine (inecas@redhat.com)
- Fixes #5821 - Capsule Content API/Backend (inecas@redhat.com)
- fixes #5806 - better handling multiple pulp tasks spawned from one task Refs
  #4875 - removing hack to ignore applicability generation failure
  (jsherril@redhat.com)
- Merge pull request #4103 from parthaa/env-promo (parthaa@gmail.com)
- Merge pull request #4114 from jlsherrill/comps (jlsherrill@gmail.com)
- Fixes #5654 - Permissions for env promotion/remove (paji@redhat.com)
- Merge pull request #4096 from waldenraines/host-collection-perms
  (walden@redhat.com)
- Fixes #5535, adding permissions for host collections. (walden@redhat.com)
- Merge pull request #4113 from jlsherrill/fluff (jlsherrill@gmail.com)
- fixes #5795 - removing ldap fluff requirement (jsherril@redhat.com)
- fixes #5796 - adding some comps entries for f19 (jsherril@redhat.com)
- Merge pull request #4086 from iNecas/rest-client-passenger
  (inecas@redhat.com)
- Refs #5377 - comps update for anyjson and amqp (jsherril@redhat.com)
- Refs #5377 - comps update for python-billiard (jsherril@redhat.com)
- Refs #5377 - comps update for pulp-celery (jsherril@redhat.com)
- Merge pull request #4046 from Katello/pulp-2.4 (jlsherrill@gmail.com)
- Merge pull request #4045 from abenari/master (bbuckingham@redhat.com)
- Merge pull request #4094 from thomasmckay/actkey (thomasmckay@redhat.com)
- fixes #5614 - do not expose activation key label (thomasmckay@redhat.com)
- fixes #4260 - adding products tab for act key (thomasmckay@redhat.com)
- Merge pull request #4106 from thomasmckay/5758-subs (thomasmckay@redhat.com)
- Merge pull request #4102 from parthaa/env-read (parthaa@gmail.com)
- fixes #5758 - removed errors due to updated permissions
  (thomasmckay@redhat.com)
- Merge pull request #4105 from jlsherrill/puppet-modules
  (jlsherrill@gmail.com)
- fixes #5757 - fixing puppet module upload url (jsherril@redhat.com)
- Refs #5709 - skipping auth tests for old authorization use
  (jsherril@redhat.com)
- Merge branch 'master' into pulp-2.4 (jsherril@redhat.com)
- Merge pull request #4100 from jlsherrill/pulp-2.4 (jlsherrill@gmail.com)
- Refs #5709 - Fixing api docs and test name (jsherril@redhat.com)
- Refs #5377 - updating cassettes for 2.4.0-0.14 (jsherril@redhat.com)
- Fixes #5682 - Handle Lifecycle env read perms better (paji@redhat.com)
- Merge pull request #4090 from jlsherrill/pulp-2.4-comps
  (jlsherrill@gmail.com)
- Refs #5377 - updating comps for pulp 2.4 (jsherril@redhat.com)
- Fixes #5749: Prevent error when migrating existing marketing and engineering
  Products due to STI inheritance column. (ericdhelms@gmail.com)
- Fixes #5709: Moves distributions and packages controllers to V2.
  (ericdhelms@gmail.com)
- Merge pull request #4073 from Katello/roles (ericdhelms@gmail.com)
- Fixes #5736, fixing typo in karma coverage configuration. (walden@redhat.com)
- Merge pull request #4092 from ehelms/refs-5217 (ericdhelms@gmail.com)
- Merge branch 'master' of https://github.com/Katello/katello into master-to-
  roles (ericdhelms@gmail.com)
- Refs #5217: Fix content host menu item and add organization scoping.
  (ericdhelms@gmail.com)
- Fixes #5711 - Doc id in ContentHosts update (dtsang@redhat.com)
- Refs #5217: Fix activation key destroy. (ericdhelms@gmail.com)
- Merge pull request #4087 from ehelms/refs-5217 (ericdhelms@gmail.com)
- Refs #5217: Moving permissions into lib/katello directory.
  (ericdhelms@gmail.com)
- Refs #5217: Adding check that the consumer cert matches the passed in
  consumer identity when present. (ericdhelms@gmail.com)
- Merge pull request #4083 from jlsherrill/pulp-2.4 (jlsherrill@gmail.com)
- Merge pull request #4059 from dustint-
  rh/bz1084722_hammer_queries_for_missing_system_id (ericdhelms@gmail.com)
- Fixes #5715 - make sure the rest client doesn't get
  PhusionPassenger::Utils::TeeInput (inecas@redhat.com)
- Merge pull request #4063 from mbacovsky/4478_localized_api
  (komidore64@gmail.com)
- Merge pull request #4080 from bbuckingham/issue-5706 (bbuckingham@redhat.com)
- Refs #4478 - Add support for localized API docs (martin.bacovsky@gmail.com)
- Refs #5377 - adding task example and fixing canceled tasks
  (jsherril@redhat.com)
- Merge pull request #4068 from komidore64/rmi5028-register-hosts
  (komidore64@gmail.com)
- Merge pull request #4082 from jlsherrill/pulp-2.4-merge
  (jlsherrill@gmail.com)
- Merge branch 'master' into pulp-2.4 (jsherril@redhat.com)
- Merge pull request #4078 from jlsherrill/pulp-2.4 (jlsherrill@gmail.com)
- Fixes #5702 - CV index call now respects environment_id correctly
  (paji@redhat.com)
- fixes #5706 - host collection foreign keys - fix rollback
  (bbuckingham@redhat.com)
- Refs #5377 - fixing puppet module upload (jsherril@redhat.com)
- Fixes #5613 - Fix unhandled sys errors BZ1084722 (dtsang@redhat.com)
- Merge pull request #4072 from ehelms/master-to-roles (ericdhelms@gmail.com)
- Merge pull request #4075 from daviddavis/temp/20140513152635
  (jlsherrill@gmail.com)
- Merge remote branch 'origin/master' into master-to-roles
  (ericdhelms@gmail.com)
- Fixes #5698, specify absolute URLs instead of relative in menu.
  (walden@redhat.com)
- Refs #5377 - Fixing progress report bug (daviddavis@redhat.com)
- Fixes #5700: Fixes rubocop error introduced by PR 4070.
  (ericdhelms@gmail.com)
- Merge branch 'master' of https://github.com/Katello/katello into master-to-
  roles (ericdhelms@gmail.com)
- Merge pull request #4061 from daviddavis/pulp-2.4-tests
  (daviddavis@redhat.com)
- Fixes #5422 - don't orchestrate user at login every login (inecas@redhat.com)
- Refs #5377 - Working on Pulp 2.4 tests (daviddavis@redhat.com)
- refs #5028 - correctly display the org's label for suscription manager
  (komidore64@gmail.com)
- Merge pull request #4065 from bbuckingham/issue-5601 (bbuckingham@redhat.com)
- fixes #5187 add link from host show page to system subscription fixes #5188
  show subscription status on host show page (abenari@redhat.com)
- Fixes #5533: Adding Content Host permissions. (ericdhelms@gmail.com)
- Fixes #5659 - String Extract (bkearney@redhat.com)
- refs #5601, #5603 - host collections - updates to support cli
  (bbuckingham@redhat.com)
- Refs #5377 - adapting services we restart based on pulp team advice
  (jsherril@redhat.com)
- refs #5028 - switching org lookup to `find_by_id` (komidore64@gmail.com)
- Merge remote-tracking branch 'upstream/master' into roles (walden@redhat.com)
- refs #5028 - fixing all the apipie directives (komidore64@gmail.com)
- refs #5028 - fixing tests (komidore64@gmail.com)
- fixes #5028 - changing organization_id label to ID (komidore64@gmail.com)
- Merge pull request #4060 from waldenraines/5635 (walden@redhat.com)
- Merge pull request #4050 from bbuckingham/system-group-rename
  (bbuckingham@redhat.com)
- Fixes #5635, displaying bastion unauthorized error message on 403.
  (walden@redhat.com)
- Fixes #5591, adding authorization for Red Hat Repositories.
  (walden@redhat.com)
- Merge pull request #3884 from mstead/proxy-candlepin-requests
  (thomasmckay@redhat.com)
- Merge pull request #4035 from parthaa/env-perms (parthaa@gmail.com)
- Merge pull request #4053 from waldenraines/5593 (walden@redhat.com)
- Fixes #5593, display authorized menu items post single page app.
  (walden@redhat.com)
- fixes #5191, #5193 - Rename system groups to host collections everywhere
  (bbuckingham@redhat.com)
- Fixes #4878: Proxy requests to guestid and content_overrides to candlepin
  (mstead@redhat.com)
- Merge pull request #4038 from dustint-
  rh/bz995940_redmine5514_subs_link_in_content_hosts_subs
  (ericdhelms@gmail.com)
- Refs #5217: Adjusts product organization_id migration to account for provider
  field. (ericdhelms@gmail.com)
- Fixes #5530 - CRUD perms for Environments (paji@redhat.com)
- Merge pull request #4056 from jlsherrill/content_enable
  (jlsherrill@gmail.com)
- fixes #5611 - associating content with Library in candlepin
  (jsherril@redhat.com)
- Fixes #5514 Subscription Link missing in Content Host Subscriptions
  (dtsang@redhat.com)
- Merge pull request #4054 from jlsherrill/reg (jlsherrill@gmail.com)
- Merge pull request #4051 from bkearney/bkearney/repository-set-work
  (bryan.kearney@gmail.com)
- fixes #5596 - fixing errors on system registration (jsherril@redhat.com)
- Merge pull request #4020 from dustint-rh/bz1077893_redmine_5008_fix_display_o
  f_manifest_history_and_in_v2_subs_orgs3 (walden@redhat.com)
- Fixes #5008 Manifest History not updated on import (dtsang@redhat.com)
- Merge pull request #4043 from waldenraines/content-view-roles
  (walden@redhat.com)
- Refs #5377 - fixing task status spec tests (jsherril@redhat.com)
- Refs #5377 - adding consumer support for pulp 2.4 (jsherril@redhat.com)
- Refs #5377 - fixing applicability regeneration for pulp 2.4
  (jsherril@redhat.com)
- Fixes #5588 - Enable name searching for hammer cli, and authorization fixes.
  (bkearney@redhat.com)
- Fixes #5434, adding permissions for Content Views (walden@redhat.com)
- Refs #5377 - Fixing repository glue tests for pulp 2.4 (jsherril@redhat.com)
- Merge pull request #4041 from daviddavis/repo-support (daviddavis@redhat.com)
- Refs #5377 - Fix the repository support class (daviddavis@redhat.com)
- Fixes #5531: Wrapping sync controllers in with new permissions.
  (ericdhelms@gmail.com)
- Refs #5473 - unify client authentication code (inecas@redhat.com)
- Refs #5423 - make Fort code working (inecas@redhat.com)
- Fixes #5473 - make authorization rules apply for consumer related calls
  (inecas@redhat.com)
- Merge pull request #4025 from thomasmckay/4261-actkey-releasever
  (thomasmckay@redhat.com)
- Fixes #5521: Adding permissions for managing subscriptions and manifests.
  (ericdhelms@gmail.com)
- Merge pull request #4040 from daviddavis/temp/20140502145424
  (daviddavis@redhat.com)
- Merge pull request #4039 from jlsherrill/pulp-2.4 (jlsherrill@gmail.com)
- Refs #5377 - Fixing content types test (daviddavis@redhat.com)
- Merge pull request #4037 from daviddavis/temp/20140502114027
  (daviddavis@redhat.com)
- Fixes #5536: Wraps Organization APIs in authorization protections.
  (ericdhelms@gmail.com)
- Refs #5377 - adapting to new pulp task structure (jsherril@redhat.com)
- Refs #5377 - ensure qpidd is started before running pulp-manage-db
  (jsherril@redhat.com)
- Refs #5377 - Comment out consumer tests until pulp fixes consumer API
  (daviddavis@redhat.com)
- fixes #4261, #5496 - add release version to activation key
  (thomasmckay@redhat.com)
- Merge pull request #4015 from bbuckingham/issue-5189 (bbuckingham@redhat.com)
- Merge pull request #4034 from daviddavis/temp/20140502075435
  (daviddavis@redhat.com)
- Fixes #5186, #5189 - Content Host - show provisioning details and cross-link
  to Foreman host (bbuckingham@redhat.com)
- Merge pull request #4032 from komidore64/rmi4919 (komidore64@gmail.com)
- Fixes #5548 - Add gemnasium to tell us about outdated gem requirements
  (daviddavis@redhat.com)
- refs #4919 - fixing improper apidoc for `system-group list`
  (komidore64@gmail.com)
- Refs #5377 - Fixing the reset task to use apache now (daviddavis@redhat.com)
- Merge pull request #4030 from daviddavis/temp/20140501123149
  (daviddavis@redhat.com)
- Fixes #5544 - Add alternate nvm setup for Node.js (daviddavis@redhat.com)
- Fixes #5261: Adds CRUD permissions for Products and Repositories.
  (ericdhelms@gmail.com)
- Fixes #5542 - Remove rubocop cop SymbolName (daviddavis@redhat.com)
- Merge branch 'master' of https://github.com/Katello/katello into roles
  (walden@redhat.com)
- Merge remote-tracking branch 'upstream/master' into roles (walden@redhat.com)
- Merge pull request #4026 from daviddavis/temp/20140501061121
  (daviddavis@redhat.com)
- Fixes #5534 - Set version on angular-rails-templates gem
  (daviddavis@redhat.com)
- Merge pull request #4024 from daviddavis/temp/20140430113444
  (daviddavis@redhat.com)
- Merge pull request #4022 from jlsherrill/delete_fast (daviddavis@redhat.com)
- fixes 5512 - fixing content view delete performance issues
  (jsherril@redhat.com)
- Merge pull request #4018 from ehelms/fixes-5504 (ericdhelms@gmail.com)
- Fixes #5504: Consolidates Katello about page information to the Foreman about
  page. (ericdhelms@gmail.com)
- Merge pull request #4023 from waldenraines/bug-5515 (walden@redhat.com)
- Merge pull request #4016 from sdherr/master (jlsherrill@gmail.com)
- Fixes #5515, adding Bastion config directory to whitelist for RPMs.
  (walden@redhat.com)
- Fixes #5518 - Repository.enabled no longer exists (daviddavis@redhat.com)
- Merge pull request #4021 from waldenraines/bug-5508 (walden@redhat.com)
- Fixes #5508, allow alch-checkbox display values to be formatted.
  (walden@redhat.com)
- Fixes #5037 - Enable ISO repo sets from a manifest (sherr@redhat.com)
- Fixes #5495 - Validate content urls for ISO repositories (sherr@redhat.com)
- fixes #5511 - renamed create_unlimited_supscription.rb
  (thomasmckay@redhat.com)
- Merge pull request #4014 from parthaa/env-cleanup (parthaa@gmail.com)
- Merge pull request #3979 from waldenraines/html5mode (walden@redhat.com)
- Merge pull request #4006 from waldenraines/bug-5408 (walden@redhat.com)
- Fixes #5198 - make bastion a true single page application.
  (walden@redhat.com)
- Fixes #5416 - adding CRUD permissions for activation keys.
  (walden@redhat.com)
- Fixes # 5437 - Env controller cleanup (paji@redhat.com)
- Merge remote-tracking branch 'upstream/master' into roles (walden@redhat.com)
- Merge pull request #4005 from waldenraines/bug-5000 (walden@redhat.com)
- Merge pull request #4010 from jlsherrill/manifest (jlsherrill@gmail.com)
- Fixes #5000, generate labels client side (walden@redhat.com)
- fixes #5457 - ignore content view archives repos during manifest actions
  (jsherril@redhat.com)
- Fixes #5456 - Point to new project name and version (bkearney@redhat.com)
- Merge pull request #4008 from jlsherrill/search_index (jlsherrill@gmail.com)
- fixes #5411 - precreating backend object search indexes  As part of this,
  updated the pool object to include BackendIndexedModel (jsherril@redhat.com)
- Merge pull request #4001 from jlsherrill/view_delete (jlsherrill@gmail.com)
- Merge pull request #3911 from parthaa/product-create (parthaa@gmail.com)
- fixes #5412 - adding content view deletion ui (jsherril@redhat.com)
- Fixes #5448 - Fix a typo in the subscriptions page (bkearney@redhat.com)
- Merge pull request #3980 from iNecas/reposets-rework (inecas@redhat.com)
- Fixes #4924 - dynflow migration for product create (jason.connor@gmail.com)
- Merge pull request #3999 from daviddavis/temp/20140423115449
  (daviddavis@redhat.com)
- Fixes #5408, display errors on new sync plan form. (walden@redhat.com)
- Fixes #5164 - fix rpm builds (inecas@redhat.com)
- Fixes #4826 - address review comments (inecas@redhat.com)
- Fixes #4826 - fix rubocop (inecas@redhat.com)
- Fixes #5023 - Repository::Destroy doesn't continue when failed in
  ActiveRecord (inecas@redhat.com)
- Fixes #5201 - allow disabling lazy accessors in tests (inecas@redhat.com)
- Fixes #4826 - rework reposets to not create repositories on repo set enable
  (inecas@redhat.com)
- Merge pull request #4000 from waldenraines/roles (walden@redhat.com)
- Merge pull request #3975 from mccun934/20140409-2045 (mmccune@gmail.com)
- Fixes #5418 - Migration for anonymous providers (paji@redhat.com)
- Fixes #5260 - adding CRUD permissions for Sync Plans. (walden@redhat.com)
- Merge pull request #3906 from parthaa/provider-cleanup (parthaa@gmail.com)
- Merge pull request #3928 from jlsherrill/deps (jlsherrill@gmail.com)
- Merge pull request #3994 from daviddavis/temp/20140421111807
  (daviddavis@redhat.com)
- Merge remote-tracking branch 'upstream/master' into roles (walden@redhat.com)
- Fixes #5413 - Fix content view removal error message (daviddavis@redhat.com)
- Merge pull request #3983 from thomasmckay/actkey (thomasmckay@redhat.com)
- Merge pull request #3986 from jlsherrill/deletion (jlsherrill@gmail.com)
- Fixes #4925,5147,5410 - Centralize provider creation. (paji@redhat.com)
- fixes #5034 - adding content view version deletion UI (jsherril@redhat.com)
- fixes #4978 BZ1082698 - environment and content view no longer required
  (thomasmckay@redhat.com)
- Merge pull request #3988 from jlsherrill/multi (jlsherrill@gmail.com)
- fixes #5164 - adding katello_remove.sh script (mmccune@redhat.com)
- Fix for a CV failed test (paji@redhat.com)
- Fixes #5255 - Version destroy plan phase clears packages
  (daviddavis@redhat.com)
- Merge pull request #3990 from bbuckingham/fixes-5234 (bbuckingham@redhat.com)
- Merge pull request #3995 from bbuckingham/issue-5257 (bbuckingham@redhat.com)
- fixes #5257 - UI - fix product create and manifest import
  (bbuckingham@redhat.com)
- Merge pull request #3991 from daviddavis/temp/20140418085641
  (daviddavis@redhat.com)
- Merge pull request #3989 from daviddavis/temp/20140417122656
  (jlsherrill@gmail.com)
- Merge pull request #3992 from bbuckingham/fixes-5233 (bbuckingham@redhat.com)
- fixes #5232 - System Groups UI - fix link from system count to the group's
  System list. (bbuckingham@redhat.com)
- fixes #5233 - System Groups UI - fix cross-linking to the systems page
  (bbuckingham@redhat.com)
- Merge pull request #3984 from bbuckingham/system-ui-rename
  (bbuckingham@redhat.com)
- Fixes #5243 - Store the content view next version (daviddavis@redhat.com)
- fixes #5183 - Rename Systems to Content Hosts throughout the UI
  (bbuckingham@redhat.com)
- Fixes #5230: Adds CRUD permissions for GPG Keys. (ericdhelms@gmail.com)
- fixes #5237 - adding multiple puppet module uploads from UI
  (jsherril@redhat.com)
- fixes #4991 - adding a few foreman plugins to the default installation
  (jsherril@redhat.com)
- fixes #5234 - content dashboard - fix system group links
  (bbuckingham@redhat.com)
- Merge pull request #3823 from mptap/repo_uploads (mtapaswi@redhat.com)
- Support for repo content uploads (mtapaswi@redhat.com)
- Merge pull request #3982 from waldenraines/bug-5207 (walden@redhat.com)
- Fixes #5207, show a message on empty content view puppet modules list.
  (walden@redhat.com)
- Fixes #5236 - Speed up content view publish (daviddavis@redhat.com)
- Merge pull request #3970 from bbuckingham/system-actions
  (bbuckingham@redhat.com)
- fixes #5151 - system actions: dynflow several more actions
  (bbuckingham@redhat.com)
- Merge pull request #3971 from waldenraines/bug-5156 (walden@redhat.com)
- Refs #5217: Initial location to declare and load permissions.
  (ericdhelms@gmail.com)
- Fixes #4940: Updating to support queryPaged and queryUnpaged across the UI.
  (ericdhelms@gmail.com)
- Merge pull request #3958 from ehelms/fixes-5098 (ericdhelms@gmail.com)
- Fixes #5093, updating styling to make modal dialog show up.
  (walden@redhat.com)
- Merge pull request #3950 from komidore64/bz1082180 (komidore64@gmail.com)
- fixes #5089 - organization delete action, 1082180 (komidore64@gmail.com)
- Merge pull request #3978 from komidore64/bz1079981 (komidore64@gmail.com)
- Merge pull request #3966 from daviddavis/cvv_deletion (jlsherrill@gmail.com)
- Merge pull request #3959 from thomasmckay/host-actkey
  (thomasmckay@redhat.com)
- Merge pull request #3973 from waldenraines/bug-5160 (walden@redhat.com)
- Fixes #5098: Table select all checkboxes no longer trigger one another.
  (ericdhelms@gmail.com)
- fixes #4795 - sanitize 'organization_id' param to a string, BZ 1079981
  (komidore64@gmail.com)
- Fixes #4811 - Allow users to delete a content view (daviddavis@redhat.com)
- Merge pull request #3949 from jlsherrill/puppet_orgs (jlsherrill@gmail.com)
- Merge pull request #3963 from jlsherrill/puppet_module_composite
  (jlsherrill@gmail.com)
- Merge pull request #3969 from jlsherrill/repo_feed (jlsherrill@gmail.com)
- Merge pull request #3922 from isratrade/4628b (bbuckingham@redhat.com)
- Merge pull request #3974 from waldenraines/bug-5161 (walden@redhat.com)
- Merge pull request #3972 from waldenraines/bug-5159 (walden@redhat.com)
- Fixes #5160, BZ1082163 - limit content view descriptions to 255 chars.
  (walden@redhat.com)
- Merge pull request #3976 from parthaa/csrf (parthaa@gmail.com)
- Fixes #5154 - CSRF related ng upload issue (paji@redhat.com)
- Merge pull request #3957 from komidore64/rmi5082 (komidore64@gmail.com)
- Fixes #5161, BZ1082712 - hide the default content view for composites.
  (walden@redhat.com)
- Fixes #5159, BZ1082707 - display Yes/No to indicate composite status.
  (walden@redhat.com)
- Fixes #5156, BZ1086503 - allow updating of system groups via /system/:id
  (walden@redhat.com)
- fixes #5116 BZ1085465 - add system groups to registering system through
  activation key (thomasmckay@redhat.com)
- Merge pull request #3965 from waldenraines/bug-1016203 (walden@redhat.com)
- Merge pull request #3960 from waldenraines/bug-1079152 (walden@redhat.com)
- Fixes #4957 - Allow users to delete view versions (daviddavis@redhat.com)
- Fixes #5144, BZ1079152: show last status of content view versions.
  (walden@redhat.com)
- fixes #5142 - fixing error on repo create with empty string
  (jsherril@redhat.com)
- Merge pull request #3964 from ehelms/fixes-5127 (ericdhelms@gmail.com)
- Fixes #5145, BZ1016203: display error in UI on custom info errors.
  (walden@redhat.com)
- Fixes #5127: Adds explicit requires on Bastion module by all other modules.
  (ericdhelms@gmail.com)
- Allows updates of Products by ID only. (omaciel@ogmaciel.com)
- Merge pull request #3956 from waldenraines/bug-5103 (walden@redhat.com)
- fixes #5126 - using components puppet modules for composite publishing
  (jsherril@redhat.com)
- Fixes #5103, BZ1084855: allow sync plans to be added to RH products.
  (walden@redhat.com)
- Fixes #4209: Prevents removal of all paths from the page when environments
  are deleted. (ericdhelms@gmail.com)
- fixes #5082 - adding repository_url option to subscription upload
  (komidore64@gmail.com)
- Merge pull request #3953 from daviddavis/cve-deletion (daviddavis@redhat.com)
- Merge pull request #3955 from waldenraines/bug-5102 (walden@redhat.com)
- Fixes #5102, BZ1084855, limit sync plan add list to enabled products.
  (walden@redhat.com)
- Fixes #4818 - Allow users to remove views from environments
  (daviddavis@redhat.com)
- fixes #5100 - updates to how/when foreman content is created
  (bbuckingham@redhat.com)
- Fixes #4207: More informational message when no content views are available
  when changing a system's environment. (ericdhelms@gmail.com)
- Merge pull request #3945 from iNecas/fix-non-puppet-provisioning
  (inecas@redhat.com)
- Merge pull request #3946 from iNecas/fix-safe-mode (inecas@redhat.com)
- Merge pull request #3740 from pitr-ch/story/dynflow (kontakt@pitr.ch)
- Add user orchestration for Update/Delete (git@pitr.ch)
- fixes #5080 - invalid puppet module names would show to add to CV
  (jsherril@redhat.com)
- Merge pull request #3941 from ehelms/fixes-4482 (ericdhelms@gmail.com)
- Merge pull request #3948 from ehelms/fixes-4364 (ericdhelms@gmail.com)
- Fixes #4482: Adds manual bootstrapping and modules specification for the
  Angular app. (ericdhelms@gmail.com)
- Fixes #4364: Adjust sync_management links to the proper page.
  (ericdhelms@gmail.com)
- fixes #5079 - fixing error on puppet module upload (jsherril@redhat.com)
- Merge pull request #3676 from thomasmckay/bz1063273 (thomasmckay@redhat.com)
- bz1063273 - properly enable/disable remove ui button (thomasmckay@redhat.com)
- Merge pull request #3944 from iNecas/fix-bootstrap-url (inecas@redhat.com)
- Merge pull request #3943 from waldenraines/bug-5043 (walden@redhat.com)
- Merge pull request #3802 from ehelms/enable-csrf (ericdhelms@gmail.com)
- Fixes #4966 - add subscription_manager_configuration_url to ALLOWED_HELPERS
  (inecas@redhat.com)
- Merge pull request #3915 from bkearney/bkearney/issue-4910
  (bryan.kearney@gmail.com)
- Fixes #4974 - make sure puppetmaster is set when updating the repo url
  (inecas@redhat.com)
- Fixes #4967 - use http instead of https for bootstrap rpm in kickstart
  (inecas@redhat.com)
- Fixes #5043, restore repository content search autocomplete function.
  (walden@redhat.com)
- Fixes #5068: Redirect user to login on 401 and 403 and fix CSRF header.
  (ericdhelms@gmail.com)
- Merge pull request #3937 from waldenraines/bug-5041 (walden@redhat.com)
- Merge pull request #3939 from waldenraines/bug-5045 (walden@redhat.com)
- Merge pull request #3942 from bbuckingham/issue-5039 (bbuckingham@redhat.com)
- Merge pull request #3932 from parthaa/repo-commands (parthaa@gmail.com)
- Merge pull request #3930 from mccun934/20140401-1030 (mmccune@gmail.com)
- fixes 5039 - update bulk actions before_filters to enable proper authenticate
  (bbuckingham@redhat.com)
- Merge pull request #3936 from thomasmckay/5036-pluck (thomasmckay@redhat.com)
- Merge pull request #3938 from thomasmckay/5050-sub-portlet
  (thomasmckay@redhat.com)
- Fixes #5044, fix link to subscriptions. (walden@redhat.com)
- Fixes #5045, correct link to upload manifest on empty RH repo page.
  (walden@redhat.com)
- Fixes #5401, adding back .btn-danger class to remove dialogs.
  (walden@redhat.com)
- Fixes #4984, #5001, #5010 - Adding repo enable and disable (paji@redhat.com)
- fixes #5050 BZ1082623 - adjust font size and structure slightly of portlet
  (thomasmckay@redhat.com)
- fixes #5036 BZ1075238 - specify table name explicitly in pluck
  (thomasmckay@redhat.com)
- Fixes #4934: Add item highlight when viewing details in Nutupane.
  (ericdhelms@gmail.com)
- Merge pull request #3935 from bbuckingham/issue-5013 (bbuckingham@redhat.com)
- fixes #4628 - disable Org nesting if Katello is enabled
  (joseph@isratrade.co.il)
- fixes #5013 - host groups - fix retrieval of activation keys
  (bbuckingham@redhat.com)
- Merge pull request #3929 from jlsherrill/discover (jlsherrill@gmail.com)
- Merge pull request #3931 from waldenraines/bug-5002 (walden@redhat.com)
- fixes #4745 - fixing error on repo discover (jsherril@redhat.com)
- Merge pull request #3934 from jlsherrill/media (jlsherrill@gmail.com)
- Merge pull request #3933 from waldenraines/bz-1079265 (walden@redhat.com)
- fixes #5009 - create install media for synced kickstart trees
  (jsherril@redhat.com)
- Merge pull request #3887 from jlsherrill/no_pkgs (jlsherrill@gmail.com)
- Merge pull request #3924 from jlsherrill/manifest (jlsherrill@gmail.com)
- BZ1079265 - add message that you must publish a CV to add to composite..
  (walden@redhat.com)
- Fixes #5002, BZ1081125 - add line breaks and limit width of textareas.
  (walden@redhat.com)
- fixes #4980 - enhancing manifest import ui (jsherril@redhat.com)
- fixes #5005 removes EPEL from the provisioning template (mmccune@redhat.com)
- Merge pull request #3925 from jlsherrill/sync_cancel (jlsherrill@gmail.com)
- Merge pull request #3927 from bbuckingham/issue-4985 (bbuckingham@redhat.com)
- fixes #4985 - nutupane - add padding-right to the nutupane-bar
  (bbuckingham@redhat.com)
- Merge pull request #3926 from daviddavis/temp/20140331112321
  (daviddavis@redhat.com)
- Merge pull request #3917 from parthaa/repo-hammer (parthaa@gmail.com)
- fixes #4983 - fix sync cancel button alignment issue (jsherril@redhat.com)
- Merge pull request #3916 from waldenraines/bug-4942 (walden@redhat.com)
- Merge pull request #3923 from bbuckingham/joseph-4958
  (bbuckingham@redhat.com)
- fixes #4958 - additional changes to support org kt_environments relationship
  (bbuckingham@redhat.com)
- Fixes #4910 - Insert a default location. (bkearney@redhat.com)
- Fixes #4982 - Fixing promotions dashboard bugs (daviddavis@redhat.com)
- Merge pull request #3919 from bbuckingham/issue-4956 (bbuckingham@redhat.com)
- fixes #4956 - content view errata by id filter - list available errata
  (bbuckingham@redhat.com)
- Merge pull request #3921 from thomasmckay/4962-portal-link
  (thomasmckay@redhat.com)
- Merge pull request #3913 from waldenraines/bug-4692 (walden@redhat.com)
- fixes #4962, BZ1081756 - prefix https:// on portal link if not present
  (thomasmckay@redhat.com)
- fixes #4958 - changed organization extensions has_many environments to
  kt_environments to not conflict with Foreman's has_many environments
  (joseph@isratrade.co.il)
- Merge pull request #3901 from jlsherrill/akey_cv (jlsherrill@gmail.com)
- Merge pull request #3918 from daviddavis/temp/20140329072141
  (daviddavis@redhat.com)
- Fixes #4954 - Fixing several problems in the sync plan API
  (daviddavis@redhat.com)
- fixes #4768 - various activation key page issues (jsherril@redhat.com)
- Merge pull request #3894 from bbuckingham/issue-4890 (bbuckingham@redhat.com)
- Fixes #4936 - Updated repo info to enable cli ops (paji@redhat.com)
- Fixes #4942, fix transition to details after creating a package filter.
  (walden@redhat.com)
- Fixes #4692, add titles to CV, AK, and sync status pages. (walden@redhat.com)
- Fixes #4943 - replace gettext with translate in CV details controller.
  (walden@redhat.com)
- fixes #4890 - content view filter: unable to add package groups
  (bbuckingham@redhat.com)
- Merge pull request #3895 from waldenraines/bug-4785 (walden@redhat.com)
- Merge pull request #3907 from jlsherrill/ak_update (jlsherrill@gmail.com)
- Merge pull request #3885 from jlsherrill/complete_message
  (jlsherrill@gmail.com)
- Merge pull request #3912 from jlsherrill/sub_product (jlsherrill@gmail.com)
- Merge pull request #3908 from bbuckingham/issue-4931 (bbuckingham@redhat.com)
- fixes #4937 - fixing UI product details retrival of a subscription
  (jsherril@redhat.com)
- Fixes #4785, replace gettext with translate for extraction/replacement.
  (walden@redhat.com)
- Merge pull request #3881 from waldenraines/filter-repos (walden@redhat.com)
- Fixes #4821, content views allow inclusion/exclusion of repos via filter UI.
  (walden@redhat.com)
- Merge pull request #3882 from tstrachota/search (tstrachota@redhat.com)
- fixes #4931 - content view errata by date/type rule - default types to false
  (bbuckingham@redhat.com)
- fixes #4810 - indicate completion on content view publish/promote
  (jsherril@redhat.com)
- fixes #4929 - fixing activation key CV update (jsherril@redhat.com)
- Merge pull request #3905 from bbuckingham/issue-4915 (bbuckingham@redhat.com)
- Merge pull request #3903 from bbuckingham/issue-4905 (bbuckingham@redhat.com)
- Merge pull request #3902 from bbuckingham/issue-4904 (bbuckingham@redhat.com)
- fixes #4856 - fix content view version retrieval when no content exists
  (jsherril@redhat.com)
- Merge pull request #3904 from jlsherrill/sync_plans (jlsherrill@gmail.com)
- Merge pull request #3877 from daviddavis/temp/20140324134601
  (daviddavis@redhat.com)
- fixes #4915 - content view publish - resolve method undefined errors
  (bbuckingham@redhat.com)
- fixes #4906 - respect organization for sync plans (jsherril@redhat.com)
- Refs #4701 - vcr recording for package tests updated (tstrachota@redhat.com)
- fixes #4905 - content views - add 'working' mode to couple of the Save
  buttons (bbuckingham@redhat.com)
- fixes #4904 - erratum rule filter validator: fix for updating a date/type
  rule (bbuckingham@redhat.com)
- Merge pull request #3900 from bkearney/issue-4898 (bryan.kearney@gmail.com)
- Fixes #4898 - Disable the localization for the summit build
  (bkearney@redhat.com)
- Merge pull request #3891 from bbuckingham/issue-4874 (bbuckingham@redhat.com)
- Merge pull request #3897 from bbuckingham/issue-4892 (bbuckingham@redhat.com)
- Merge pull request #3893 from ehelms/refs-4883 (ericdhelms@gmail.com)
- Merge pull request #3896 from jlsherrill/appl_regen (jlsherrill@gmail.com)
- fixes #4875 - ignore errors on applicability regeneration
  (jsherril@redhat.com)
- Merge pull request #3892 from waldenraines/bug-4860 (walden@redhat.com)
- fixes #4892 - content view filters & rules api - return object on DELETE
  (bbuckingham@redhat.com)
- Fixes #4860 - reset the content view's component IDs on save failure.
  (walden@redhat.com)
- fixes #4874 - content view filter: display validation error to user
  (bbuckingham@redhat.com)
- Merge pull request #3889 from daviddavis/cv-deletion (daviddavis@redhat.com)
- Refs #4883: Disables SMAPs from showing up in the UI menu.
  (ericdhelms@gmail.com)
- Merge pull request #3886 from ehelms/fixes-4853 (ericdhelms@gmail.com)
- Merge pull request #3890 from waldenraines/bug-4872 (walden@redhat.com)
- Fixes #4872 - restoring errata controller routes still in use.
  (walden@redhat.com)
- Fixes #4701 - unable to search unicode strings in elasticsearch
  (tstrachota@redhat.com)
- Fixes #4815 - Added foreign keys for content view tables
  (daviddavis@redhat.com)
- fixes #4858 - fixing removal of package from CV filter in UI
  (jsherril@redhat.com)
- Fixes #4853: Prevents 500 error loading subscription details from API.
  (ericdhelms@gmail.com)
- Merge pull request #3768 from mstead/manifest-import-derived-product-fix
  (jlsherrill@gmail.com)
- Merge pull request #3871 from jlsherrill/cvv_load (jlsherrill@gmail.com)
- fixes #4782 - speeding up CV Version content count methods
  (jsherril@redhat.com)
- Merge pull request #3883 from iNecas/update-foreman-tasks (inecas@redhat.com)
- Merge pull request #3878 from jlsherrill/user_del (jlsherrill@gmail.com)
- Merge pull request #3876 from jlsherrill/org_label (jlsherrill@gmail.com)
- Fixes #4690 - Updating directory in katello deployed scripts
  (daviddavis@redhat.com)
- Update foreman-tasks (inecas@redhat.com)
- Merge pull request #3880 from waldenraines/bug-4807 (walden@redhat.com)
- Merge pull request #3879 from jlsherrill/repo_create_can
  (jlsherrill@gmail.com)
- Fixes #4807 - defaulting to false if mark_translated is not provided.
  (walden@redhat.com)
- fixes #4619 - cancel button on repo create return to repo list
  (jsherril@redhat.com)
- Merge pull request #3875 from daviddavis/temp/20140324094605
  (daviddavis@redhat.com)
- fixes #4746 - removing non-existant CV History User relationship
  (jsherril@redhat.com)
- Refs #4798 - Fixing the subscription API (daviddavis@redhat.com)
- Merge pull request #3855 from ehelms/fixes-4751 (ericdhelms@gmail.com)
- Merge pull request #3861 from jlsherrill/cv_search (jlsherrill@gmail.com)
- Merge pull request #3869 from waldenraines/bug-4501 (walden@redhat.com)
- fixes #4797 - adding label to organization scoped search
  (jsherril@redhat.com)
- Merge pull request #3857 from daviddavis/temp/20140320170446
  (daviddavis@redhat.com)
- Merge pull request #3873 from daviddavis/temp/20140324081600
  (daviddavis@redhat.com)
- Merge pull request #3872 from jlsherrill/errata_details
  (jlsherrill@gmail.com)
- Merge pull request #3864 from bbuckingham/issue-4773 (bbuckingham@redhat.com)
- Merge pull request #3840 from ehelms/fixes-4723 (ericdhelms@gmail.com)
- Merge pull request #3870 from ehelms/fixes-4784 (ericdhelms@gmail.com)
- Fixes #4793 - Fixed typo in activation key show (daviddavis@redhat.com)
- Merge pull request #3858 from bbuckingham/issue-4706 (bbuckingham@redhat.com)
- fixes #4773 - Content Views: fix issue which did not allow for multiple
  errata ids per filter (bbuckingham@redhat.com)
- Merge pull request #3863 from bbuckingham/issue-4765 (bbuckingham@redhat.com)
- fixes #4706 - adding back the ability to download a debug certificate
  (bbuckingham@redhat.com)
- fixes #4780 - fixing link to system errata details (jsherril@redhat.com)
- Merge pull request #3851 from jlsherrill/env_delete (jlsherrill@gmail.com)
- Fixes #4689 - Handle default content views in API/CLI (daviddavis@redhat.com)
- Merge pull request #3868 from daviddavis/ak-sysgroup (daviddavis@redhat.com)
- Fixes #4501: rename katello JS i18n/mark translated bastion strings.
  (walden@redhat.com)
- Fixes #4784: Replaces development setup documentation with references to
  katello-devel-installer and katello-deploy. (ericdhelms@gmail.com)
- Fixes #4758: Adds client authentication to enabled repos call.
  (ericdhelms@gmail.com)
- Merge pull request #3862 from waldenraines/bug-4721 (walden@redhat.com)
- fixes #4765: Content Views: Filters: sort errata by id
  (bbuckingham@redhat.com)
- Merge pull request #3866 from jlsherrill/copyright (jlsherrill@gmail.com)
- Refs #4779 - Adding system group items to key API (daviddavis@redhat.com)
- fixes #4778 - Content View Version: package/errata counts are incorrect for
  latest version (bbuckingham@redhat.com)
- fixes #4744 - updating copyright to 2014 (jsherril@redhat.com)
- Merge pull request #3856 from thomasmckay/4754-register
  (thomasmckay@redhat.com)
- Fixes #4721 - passing systemId into system tasks calls to match API.
  (walden@redhat.com)
- Merge pull request #3860 from ehelms/fixes-4765 (ericdhelms@gmail.com)
- fixes #4767 - fixing content view search (jsherril@redhat.com)
- Fixes #4765: Errata by ID filter tabs correctly linked by passing filter ID.
  (ericdhelms@gmail.com)
- Merge pull request #3841 from ehelms/fixes-4705 (ericdhelms@gmail.com)
- Merge pull request #3845 from ehelms/fixes-4688 (ericdhelms@gmail.com)
- fixes #4754 - BZ-1075189 - 4754-register (thomasmckay@redhat.com)
- Merge pull request #3854 from jlsherrill/dev_hg (jlsherrill@gmail.com)
- Fixes #4751: Environment and Content View were being omitted from the allowed
  parameters for systems and preventing updating. (ericdhelms@gmail.com)
- Merge pull request #3853 from jlsherrill/repo_create (jlsherrill@gmail.com)
- fixes #4749 - fixed puppet env creation for non-library envs
  (jsherril@redhat.com)
- Merge pull request #3848 from thomasmckay/4730-userapi
  (thomasmckay@redhat.com)
- fixes #4752 - fixed repository creation error due to improper puppet
  detection (jsherril@redhat.com)
- fixes 4725 - fixes deletion of puppet environments with no modules
  (jsherril@redhat.com)
- Merge pull request #3837 from jlsherrill/cv-puppet (jlsherrill@gmail.com)
- Merge pull request #3832 from ehelms/fixes-4657 (ericdhelms@gmail.com)
- Merge pull request #3850 from iNecas/bug/4740 (inecas@redhat.com)
- fixes #4732 - adding puppet environment to dynflow CV publish and promote
  (jsherril@redhat.com)
- Fixes #4740 - Minimize the number of fields requesting from pulp
  (inecas@redhat.com)
- fixes #4726 - update hostgroup activation keys to support katello v2 apis
  (bbuckingham@redhat.com)
- fixes #4730 - 4730-userapi - extend foreman's v2 api user controller
  (thomasmckay@redhat.com)
- Merge pull request #3843 from iNecas/bug/4713 (inecas@redhat.com)
- Merge pull request #3844 from daviddavis/temp/20140319161944
  (daviddavis@redhat.com)
- Fixes #4688: Prevents ugly indentation of row headers on Firefox, adds back
  the missing environment selector icon, and sets the proper header row height.
  (ericdhelms@gmail.com)
- fixes #4717 - Returning cv version info to UI (daviddavis@redhat.com)
- Fixes #4713 - don't store results for copy/remove content actions
  (inecas@redhat.com)
- fixes #4708 - Prefix ambiguous id in query (daviddavis@redhat.com)
- Fixes #4657: Removes Katello current user setting and moves consumer
  authentication checking to the proxies controller. (ericdhelms@gmail.com)
- Fixes #4705: Updates repository bulk deletion to delete via dynflow actions
  and properly remove the repository from Katello and Pulp. This prevented the
  ability to create a repository with the same name after deleting it.
  (ericdhelms@gmail.com)
- Fixes #4723: Adds an explicit restart of tomcat to the reset script to ensure
  that tomcat is restarted before db:seed is run. (ericdhelms@gmail.com)
- Merge pull request #3838 from parthaa/product-cleanup (parthaa@gmail.com)
- Merge pull request #3834 from waldenraines/composite-cv-sort
  (walden@redhat.com)
- fixes #4714 - Removing traces of unused cdn_import_success code
  (paji@redhat.com)
- Composite Content-views: sorting content views by name, fixes #4704.
  (walden@redhat.com)
- 1057652: No longer delete derived products on import (mstead@redhat.com)
- Merge pull request #3836 from waldenraines/upgrade-ui-router
  (walden@redhat.com)
- Merge pull request #3835 from ehelms/fixes-4663 (ericdhelms@gmail.com)
- Bastion: upgrade angular-ui-router to 0.2.10. (walden@redhat.com)
- Fixes 4663: Available releases version will not properly populate the API and
  UI data. Further, systems can now have their release version updated from the
  UI correctly. (ericdhelms@gmail.com)
- Merge pull request #3829 from iNecas/cv-rework-add-to-env (inecas@redhat.com)
- Add tests for Actions::Katello::ContentView::AddToEnvironment
  (inecas@redhat.com)
- fixing call to private method (jsherril@redhat.com)
- Merge branch 'master' into cv-rework (jsherril@redhat.com)
- Extract adding content view version to environment into Dynflow
  (inecas@redhat.com)
- Fix cases when there is no PuppetEnvironment for the content view version
  (inecas@redhat.com)
- Merge pull request #3824 from daviddavis/temp/20140316175713
  (daviddavis@redhat.com)
- erratum filter rule validator test fix (jsherril@redhat.com)
- Merge remote branch 'upstream/cv-rework' into cv-rework-dynflow
  (jsherril@redhat.com)
- removing symlink to local dynflow (jsherril@redhat.com)
- white space fixes (jsherril@redhat.com)
- Content Views: Changing/adding version show children (daviddavis@redhat.com)
- Merge pull request #3822 from bbuckingham/cv-rework-filter_validation
  (bbuckingham@redhat.com)
- Content Views Rework: additional validations for errata filter rules
  (bbuckingham@redhat.com)
- Merge branch 'cv-rework' into cv-rework-dynflow (jsherril@redhat.com)
- Merge pull request #3816 from daviddavis/cv-rework-validation
  (daviddavis@redhat.com)
- Reload versions after publishing (inecas@redhat.com)
- Remove checking on ready_to_publish (inecas@redhat.com)
- Use fixtures instead for mocks for actions repository_test
  (inecas@redhat.com)
- Update Foreman content after promoting to environment (inecas@redhat.com)
- Fixes #4515 - Add support for dynamic bindings (mbacovsk@redhat.com)
- Content Views: Adding more validations (daviddavis@redhat.com)
- Content Views: Fixing a number of issues listed below: (ericdhelms@gmail.com)
- Merge pull request #3805 from waldenraines/cv-rework-puppet
  (walden@redhat.com)
- Disable progressbar animations for now (inecas@redhat.com)
- Support callback definition for aggregated task (inecas@redhat.com)
- Fix failing tests for provider (inecas@redhat.com)
- fixing spec test (jsherril@redhat.com)
- properly calculating repos to delete during CV publish (jsherril@redhat.com)
- fixes for CV promote and publish (jsherril@redhat.com)
- fixing manifest import after dynflow changes and fixing issue with enabling a
  repo after creating a puppet repo (jsherril@redhat.com)
- Content Views: allow CRUD operations on puppet modules. (walden@redhat.com)
- fixing issue with promotion to environment with repositories
  (jsherril@redhat.com)
- Merge pull request #3814 from bbuckingham/cv-rework-puppet
  (bbuckingham@redhat.com)
- Merge pull request #3821 from bbuckingham/cv-rework-cli_fixes
  (daviddavis@redhat.com)
- Content View Rework: fix api docs for filters (bbuckingham@redhat.com)
- removing TODO comment (jsherril@redhat.com)
- respect composite view repos during publish (jsherril@redhat.com)
- promotion dynflowification (jsherril@redhat.com)
- Adapting new dynflow work to content views UI (jsherril@redhat.com)
- Fix path to fort actions (inecas@redhat.com)
- Expanding Content Vew available puppet module apis (jsherril@redhat.com)
- Merge pull request #3810 from bbuckingham/cv-rework-puppet_validation
  (bbuckingham@redhat.com)
- Merge pull request #3811 from jlsherrill/cv-library-fix
  (jlsherrill@gmail.com)
- fixes 4655 - fixing registration to Library attaching to incorrect content
  view (jsherril@redhat.com)
- Merge remote-tracking branch 'upstream/master' into cv-merge-master-in
  (daviddavis@redhat.com)
- fixing errors from merge from cv-rework (jsherril@redhat.com)
- Content View Rework: validate that puppet module exists
  (bbuckingham@redhat.com)
- Content View Rework: update foreman puppet import (bbuckingham@redhat.com)
- Fixes 4654: Switches to using the Deface syntax for versions of Deface less
  than 1.0.0 and locks down the versions avaiable for use.
  (ericdhelms@gmail.com)
- Merge remote-tracking branch 'upstream/cv-rework' into cv-rework-dynflow
  (jsherril@redhat.com)
- Merge remote-tracking branch 'origin/master' into cv-rework
  (inecas@redhat.com)
- Merge pull request #3808 from iNecas/foreman-update-action
  (inecas@redhat.com)
- Disabe execution of hooked action in organization in tests
  (inecas@redhat.com)
- Merge pull request #3788 from ehelms/fixes-4594 (ericdhelms@gmail.com)
- Merge pull request #3799 from ehelms/fix-content-search
  (ericdhelms@gmail.com)
- Content Views: Adding back auto complete for content views and fixing missing
  icons by switching to the FontAwesome equivalents. (ericdhelms@gmail.com)
- Fix typo (inecas@redhat.com)
- Don't go to run/finalize phase of Organization creation hook in tests
  (inecas@redhat.com)
- Fixes #4646: hostgroup-akeys: fix regressions with activation keys on
  hostgroups page (bbuckingham@redhat.com)
- Fixes #4584 - use test class instead of describe (inecas@redhat.com)
- Actions::Base is preferred over Dynflow::Action (inecas@redhat.com)
- Merge Actions::Headpin into Actions::Katello (inecas@redhat.com)
- Fixes #4644: Update foreman content when library is created
  (inecas@redhat.com)
- Fixes #4644: Create Foreman environment for all content views
  (inecas@redhat.com)
- Merge pull request #3804 from bbuckingham/cv-rework-archives
  (bbuckingham@redhat.com)
- Merge pull request #3794 from jlsherrill/cv-rework-merge
  (jlsherrill@gmail.com)
- Merge branch 'master' into cv-rework (jsherril@redhat.com)
- Merge branch 'master' into cv-rework (jsherril@redhat.com)
- fixing environment creation after master merge (jsherril@redhat.com)
- Merge pull request #3796 from daviddavis/temp/20140311111528
  (daviddavis@redhat.com)
- Content Views Rework: do not publish archive repos to nodes
  (bbuckingham@redhat.com)
- Merge pull request #3803 from iNecas/fix-dynflow-from-dj (inecas@redhat.com)
- fixing tests after moving to dynflow for repo creation/deletion
  (jsherril@redhat.com)
- Reinitialize the dynflow world after forking (inecas@redhat.com)
- Composite Content Views: Publish and yum content validation
  (daviddavis@redhat.com)
- Content View Rework: update content view puppet modules to always include
  name/author (bbuckingham@redhat.com)
- Add ActionTriggering after it was extracted form ActionSubject (git@pitr.ch)
- Merge pull request #3797 from bbuckingham/cv-rework-fix-reindex
  (bbuckingham@redhat.com)
- Merge pull request #3798 from bbuckingham/cv-rework-apidoc
  (bbuckingham@redhat.com)
- Merge pull request #3792 from ehelms/fixes-4615 (ericdhelms@gmail.com)
- Fixes #4615: Add missing route that allows RHSM to update consumer facts and
  update API authentication check to account for authentication order.
  (ericdhelms@gmail.com)
- Content View Rework: updates to support publish and promote for puppet
  content (bbuckingham@redhat.com)
- Merge branch 'master' into cv-rework (jsherril@redhat.com)
- Content Views Rework: fix api docs for content view puppet modules
  (bbuckingham@redhat.com)
- Delete puppet module index during katello:reset (bbuckingham@redhat.com)
- Fixes #4634: Set karma-coffee-preprocessor version to prevent newer version
  which requires Karma 0.12.0. (ericdhelms@gmail.com)
- Merge pull request #3791 from iNecas/foreman-tasks-bump
  (jlsherrill@gmail.com)
- Merge pull request #3736 from bkearney/bkearney/downcase-usernames
  (bryan.kearney@gmail.com)
- Fixes #4594: Updates the references to the consumer cert RPM.
  (ericdhelms@gmail.com)
- Require foreman-tasks ~> 0.3.6 (inecas@redhat.com)
- Fix indexing after scheduled tasks (inecas@redhat.com)
- Index only when synchronization not handled by Dynflow action
  (inecas@redhat.com)
- Index the content when the syncing finishes (inecas@redhat.com)
- Merge pull request #3743 from parthaa/org_create (daviddavis@redhat.com)
- CV-rework: fix spacing on bastion content view routes. (walden@redhat.com)
- Merge pull request #3780 from daviddavis/temp/20140306092031
  (daviddavis@redhat.com)
- Merge pull request #3786 from jlsherrill/cv-fix (jlsherrill@gmail.com)
- fixing legacy CV publish page (jsherril@redhat.com)
- Code for Org  Create orchestration (paji@redhat.com)
- Fix action tests for repository create/destroy (inecas@redhat.com)
- Merge pull request #3784 from waldenraines/btn-primary (walden@redhat.com)
- Content Views: handle composite content views. (walden@redhat.com)
- Make filters working with Dynflow publish (inecas@redhat.com)
- Index the content when the syncing finishes (inecas@redhat.com)
- Bastion: reduce the number of .btn-primary buttons. (walden@redhat.com)
- Merge pull request #3774 from jlsherrill/cv-history (jlsherrill@gmail.com)
- Replace occurrences of .btn-danger with .btn-default. (walden@redhat.com)
- Merge pull request #3779 from daviddavis/temp/20140305190902
  (daviddavis@redhat.com)
- Merge pull request #3781 from ehelms/fixes-4575 (ericdhelms@gmail.com)
- Fix apipie documentation for systems (inecas@redhat.com)
- Content Views: Remove a few old references to content view defs
  (daviddavis@redhat.com)
- Fixes #4575: Removes horizontal scrollbar on nutupane pages caused by over
  extended header and search bar. (ericdhelms@gmail.com)
- Merge remote-tracking branch 'origin/cv-rework' into cv-rework-dynflow-
  publish (inecas@redhat.com)
- Content Views: Publishing version archives under content_views directory
  (daviddavis@redhat.com)
- Use Actions::Base as base class for Katello action (inecas@redhat.com)
- Whitespace (inecas@redhat.com)
- Make the new repository from CloneToVersoin available for superior action
  (inecas@redhat.com)
- adding content view history ui (jsherril@redhat.com)
- Update the Candlepin environment in run phase of create repo
  (inecas@redhat.com)
- The content_id not known before calling to Candlepin (inecas@redhat.com)
- Merge pull request #3778 from jlsherrill/repo_set (jlsherrill@gmail.com)
- fixing red hat repos page (jsherril@redhat.com)
- Merge pull request #3766 from daviddavis/temp/20140303113408
  (daviddavis@redhat.com)
- Refactor publish actions (inecas@redhat.com)
- Merge pull request #3773 from jlsherrill/cv-breadcrumb (jlsherrill@gmail.com)
- Merge pull request #3764 from bbuckingham/cv-rework-filters-rename
  (bbuckingham@redhat.com)
- Content Views Rework: prepend content_view on filter models, update routes
  (bbuckingham@redhat.com)
- Content Views: Added tests for updating composites (daviddavis@redhat.com)
- Adding config path that points to foreman/config/settings.plugins.d to allow
  placement of the Katello yaml file in the plugin config location.
  (ericdhelms@gmail.com)
- Fix record fixtures middleware (inecas@redhat.com)
- Finish repo deletion orchestration (inecas@redhat.com)
- Content Views: Adding description for promote action (daviddavis@redhat.com)
- changing all icon-backward icons to double-angle-left (jsherril@redhat.com)
- Merge pull request #3770 from daviddavis/temp/20140304125022
  (daviddavis@redhat.com)
- promotion page improvements (jsherril@redhat.com)
- Merge pull request #3754 from jlsherrill/cv-ui (jlsherrill@gmail.com)
- Hooking up publish and promote properly (jsherril@redhat.com)
- Content Views: Fix publish bug by refreshing repos (daviddavis@redhat.com)
- disabling checkbox on evn selector if env is disabled (ericdhelms@gmail.com)
- Merge pull request #3762 from daviddavis/temp/20140228120326
  (daviddavis@redhat.com)
- Repository create and content view publish through Dynflow
  (inecas@redhat.com)
- Content Views: Adding filter UI support for Packages, Errata and Package
  groups. (ericdhelms@gmail.com)
- Merge pull request #3769 from bbuckingham/issue-4409 (bbuckingham@redhat.com)
- Merge pull request #3758 from jlsherrill/repo_list (jlsherrill@gmail.com)
- Content Views Rework: updating publish to use the new filter models
  (bbuckingham@redhat.com)
- fixing tests from master merge (jsherril@redhat.com)
- merge conflict (jsherril@redhat.com)
- fixing a few fixture references (jsherril@redhat.com)
- Merge pull request #3760 from komidore64/manifest-async-tasks
  (komidore64@gmail.com)
- Merge branch 'master' into cv-rework (jsherril@redhat.com)
- fixes #4409 - rename the id used for the content menu
  (bbuckingham@redhat.com)
- Merge pull request #3757 from daviddavis/temp/20140227173558
  (daviddavis@redhat.com)
- Merge pull request #3765 from daviddavis/temp/20140303091538
  (daviddavis@redhat.com)
- Merge pull request #3759 from iNecas/cv-rework-fort-layout
  (inecas@redhat.com)
- Content Views: Fixed source for composite content views
  (daviddavis@redhat.com)
- Merge pull request #3756 from jmontleon/add_hammer_cli_foreman_tasks_to_repo
  (jmontleo@redhat.com)
- Merge pull request #3755 from bbuckingham/bugfixes (bbuckingham@redhat.com)
- Merge pull request #3739 from daviddavis/temp/20140226073857
  (daviddavis@redhat.com)
- Fixed ambigious id error (daviddavis@redhat.com)
- Switch from `Fort::Actions` to `Actions::Fort` (inecas@redhat.com)
- Rename the actions to follow the names of the files (inecas@redhat.com)
- Merge pull request #3761 from iNecas/update-consumer-create
  (inecas@redhat.com)
- Namespacing Katello factories and updating duplicated factories to modify
  existing ones from Foreman. Addresses the test failures introduced by Foreman
  PR #1070. (ericdhelms@gmail.com)
- Content Views: Worked more on publishing content (daviddavis@redhat.com)
- Fixing broken tests by reloading models and fixing relationships
  (daviddavis@redhat.com)
- Content Views: Working on content view rabl (daviddavis@redhat.com)
- fixes #4505 - rhsm register though Dynflow (inecas@redhat.com)
- Remove code that has been replaced by bastion/v2 APIs. (walden@redhat.com)
- subscriptions - manifest refresh and delete into dynflow actions
  (komidore64@gmail.com)
- Content Views: Updating the apidoc for v2 controller (daviddavis@redhat.com)
- Update the actions registering in fort (inecas@redhat.com)
- content views - only show library repos when fetching available
  (jsherril@redhat.com)
- add rubygem-hammer_cli_foreman_tasks to repos (jmontleo@redhat.com)
- Legacy Content View: quick fix to address issue on publish
  (bbuckingham@redhat.com)
- Fort: a few minor bug fixes, primarily namespacing (bbuckingham@redhat.com)
- Merge pull request #3722 from jlsherrill/post_sync (jlsherrill@gmail.com)
- updating post_sync action * moving to v2 controller * adding support for a
  secret token * removing http header guessing (jsherril@redhat.com)
- Merge pull request #3752 from iNecas/manifest-import-dynflow
  (inecas@redhat.com)
- Use Dynflow for async manifest import (inecas@redhat.com)
- fixes #4459 - allows proper rendering of pages using root_path
  (thomasmckay@redhat.com)
- Merge remote-tracking branch 'upstream/master' into cv-wat
  (daviddavis@redhat.com)
- Merge pull request #3742 from ehelms/fixing-scss-pathing
  (daviddavis@redhat.com)
- Change to add extra sass paths to the sass config instead of the assets
  config. (ericdhelms@gmail.com)
- fixing "the input_format has already been defined in Class" error
  (jsherril@redhat.com)
- repository sets - show action (komidore64@gmail.com)
- initial cv publishing work (jsherril@redhat.com)
- fixing node_metadata_generate action after merge (jsherril@redhat.com)
- merging master (jsherril@redhat.com)
- Usernames needs to be lowercase in foreman. (bkearney@redhat.com)
- Merge pull request #3734 from waldenraines/master (walden@redhat.com)
- Merge pull request #3729 from bbuckingham/cv-rework-available-content-2
  (bbuckingham@redhat.com)
- Make rubocop happy (inecas@redhat.com)
- Merge pull request #3709 from pitr-ch/story/dynflow (inecas@redhat.com)
- Content Views Rework: APIs for available/current content
  (bbuckingham@redhat.com)
- Update to latest ForemanTasks (git@pitr.ch)
- Fix cases when hunized input is not string nor object (inecas@redhat.com)
- Explicitly avoid /katello prefix for foreman_tasks (inecas@redhat.com)
- Bastion: remove mention of Routes service from readme. (walden@redhat.com)
- Merge pull request #3728 from iNecas/cv-rework (inecas@redhat.com)
- Merge pull request #3732 from iNecas/cv-rework-fix-constants
  (inecas@redhat.com)
- Merge remote-tracking branch 'origin/master' into dynflow (inecas@redhat.com)
- Make sure the right constants are used for CONTENT_TYPE (inecas@redhat.com)
- Fix repository organization method (daviddavis@redhat.com)
- Update the paths to content-view api (inecas@redhat.com)
- Merge pull request #3715 from daviddavis/cv-composites
  (daviddavis@redhat.com)
- Content Views: Adding in composite content views (daviddavis@redhat.com)
- Merge pull request #3725 from jlsherrill/remove_discovery
  (jlsherrill@gmail.com)
- Merge branch 'master' into merge-to-cv-rework (paji@redhat.com)
- Merge pull request #3719 from thomasmckay/ak-sysgroup
  (thomasmckay@redhat.com)
- removing provider repo discovery model additions (jsherril@redhat.com)
- Merge pull request #3720 from bkearney/bkearney/expose-paths-to-apipie
  (bryan.kearney@gmail.com)
- Merge pull request #3724 from bkearney/bkearney/products-search-by-name
  (bryan.kearney@gmail.com)
- ak-sysgroup - updated activation keys for system groups
  (thomasmckay@redhat.com)
- Downcase the name field so that product searching by name works
  (bkearney@redhat.com)
- Remove unused file (daviddavis@redhat.com)
- Expose the paths command to apipie so that it can be exposed by hammer
  (bkearney@redhat.com)
- Merge pull request #3713 from bbuckingham/cv-rework-errata
  (bbuckingham@redhat.com)
- Merge pull request #3711 from bbuckingham/cv-rework-pkggroups
  (bbuckingham@redhat.com)
- Make rubocop happy (inecas@redhat.com)
- Merge remote-tracking branch 'origin/master' into dynflow (inecas@redhat.com)
- wait for node publish before triggering node sync (jsherril@redhat.com)
- Errata: update v2 controller to allow request by repo
  (bbuckingham@redhat.com)
- Searching by environment name requires that the name be downcased
  (bkearney@redhat.com)
- Package Groups: add ability to list groups by repo and retrieve info for a
  group (bbuckingham@redhat.com)
- Disable foreman tasks hooks for user orchestration (inecas@redhat.com)
- Disable glue events in the Katello tests (inecas@redhat.com)
- Fix pulp consumer tests after getting some part to Dynflow
  (inecas@redhat.com)
- Merge pull request #3695 from daviddavis/cv-rework-publish
  (daviddavis@redhat.com)
- Merge pull request #3708 from komidore64/repo-sets (komidore64@gmail.com)
- Content Views: Redoing publish code (daviddavis@redhat.com)
- repository sets - v2 api actions for list, enable, and disable
  (komidore64@gmail.com)
- Puppet Modules: add ability to list modules by environment
  (bbuckingham@redhat.com)
- products_controller - create action needs the organization_id param
  (komidore64@gmail.com)
- Merge pull request #3686 from jlsherrill/clean_systems (jlsherrill@gmail.com)
- Remove failing consumer tests (inecas@redhat.com)
- Merge pull request #3698 from bkearney/bkearney/manifest-refresh-delete
  (bryan.kearney@gmail.com)
- Merge pull request #3691 from bbuckingham/cv-rework-filters
  (bbuckingham@redhat.com)
- Move manifest refresh and delete to the subscription controller in v2
  (bkearney@redhat.com)
- Merge pull request #3672 from daviddavis/temp/20140206131058
  (daviddavis@redhat.com)
- Content Views Rework: Filters: change parameters hash to be separate rules
  models/schema (bbuckingham@redhat.com)
- Content Views: Adding version to content view environments
  (daviddavis@redhat.com)
- adding rake task for cleaning broken systems (jsherril@redhat.com)
- Merge pull request #3705 from ehelms/fix-with-repos (ericdhelms@gmail.com)
- Update event triggering (inecas@redhat.com)
- Merge pull request #3687 from jlsherrill/fort_fix (jlsherrill@gmail.com)
- fixing a few class references in fort (jsherril@redhat.com)
- Adds ANONYMOUS provider type when checking for repositories on a product and
  fixes repository listing from the API and sync pages. (ericdhelms@gmail.com)
- Merge pull request #3682 from waldenraines/faster-es (walden@redhat.com)
- Merge pull request #3703 from jlsherrill/migra (jlsherrill@gmail.com)
- fixing down migration (jsherril@redhat.com)
- Update the tests for System create rework (inecas@redhat.com)
- Fixed a node env join issue (paji@redhat.com)
- Updated content view node publish logic (paji@redhat.com)
- Merge pull request #3674 from komidore64/products-index
  (komidore64@gmail.com)
- Content Views Rework: add ability to associate puppet modules with a content
  view (bbuckingham@redhat.com)
- Merge remote-tracking branch 'origin/master' into dynflow (inecas@redhat.com)
- Abstractize abstract classes (inecas@redhat.com)
- Remove unused param (inecas@redhat.com)
- Merge remote-tracking branch 'upstream/master' into cv-merge-master
  (daviddavis@redhat.com)
- Build: Setting the compass-rails version since the newest version (1.1.4)
  breaks the build and fixing a single broken JS test. (ericdhelms@gmail.com)
- Remove old system create orchestration code (inecas@redhat.com)
- Fix rubocop issues (inecas@redhat.com)
- Refactor runcible expectations (inecas@redhat.com)
- System dynflow tests (inecas@redhat.com)
- Reload system after orchestration is finished (inecas@redhat.com)
- Move Pulp related actions to katello action (inecas@redhat.com)
- System create Dynflow orchestration (inecas@redhat.com)
- Fix user unit tests (inecas@redhat.com)
- Fix seeding admin user (inecas@redhat.com)
- removed API docs for provider create and delete (jason.connor@gmail.com)
- Removed custom providers from the UI Added "Anonymous" providers on the
  backend that are automatically created (jason.connor@gmail.com)
- Elasticsearch: use bulk updating for errata/package indexing.
  (walden@redhat.com)
- products controller - renaming method and cleaning filters
  (komidore64@gmail.com)
- Fix rubocop issues (inecas@redhat.com)
- more ES work (jsherril@redhat.com)
- initial work to speedup re-indexing, because of our version of ES, we cant do
  bulk updating so its not any faster, when we get to a newer version we should
  switch to bulk updating (jsherril@redhat.com)
- Content Views Rework: removing the puppet module filter
  (bbuckingham@redhat.com)
- Merge pull request #3696 from jmontleon/add-rhel5-client-comps
  (jmontleo@redhat.com)
- Merge pull request #3648 from jmontleon/fixsclprovides (jmontleo@redhat.com)
- repositories - don't look up products by cp_id (komidore64@gmail.com)
- products - index action (komidore64@gmail.com)
- Merge pull request #3675 from thomasmckay/ak-api (thomasmckay@redhat.com)
- Merge pull request #3651 from komidore64/find-env-yank (komidore64@gmail.com)
- Fixing v2 rubocop error (daviddavis@redhat.com)
- Merge remote-tracking branch 'upstream/master' into parthaa-master-to-cv-
  rework (daviddavis@redhat.com)
- Merge branch 'master' into master-to-cv (paji@redhat.com)
- add comps file for RHEL 5 client (jmontleo@redhat.com)
- Merge remote-tracking branch 'origin/master' into dynflow (inecas@redhat.com)
- Don't lock the foreman-tasks version (inecas@redhat.com)
- Merge pull request #3693 from ehelms/test-performance (ericdhelms@gmail.com)
- Remove old user tests (inecas@redhat.com)
- Fix jslint issues (inecas@redhat.com)
- Merge remote-tracking branch 'origin/master' into dynflow (inecas@redhat.com)
- Test: Improving test performance by moving fixture loading from occuring with
  every test suite to once per inclusion of the fixture test case.
  (ericdhelms@gmail.com)
- ak-api - working on system groups for activation keys
  (thomasmckay@redhat.com)
- Merge pull request #3688 from ehelms/fixing-master-tests
  (ericdhelms@gmail.com)
- Fixes required to fix broken tests in master by making use of new
  empty_organization fixture from Foreman and wrapping Organization create
  calls in 'as_admin'. (ericdhelms@gmail.com)
- Merge pull request #3690 from pitr-ch/story/dynflow (kontakt@pitr.ch)
- Use new API on action Present phase (git@pitr.ch)
- Bastion: Setting Jasmine dependency to prevent 2.0 from being pulled in and
  breaking tests. (ericdhelms@gmail.com)
- Merge pull request #3684 from pitr-ch/story/dynflow (kontakt@pitr.ch)
- Merge remote-tracking branch 'origin/master' into dynflow (inecas@redhat.com)
- Address js style issues (inecas@redhat.com)
- Removed an unreachable line. As per PR 3681 comments (paji@redhat.com)
- Fixed a migration issue that arises with the master merge (paji@redhat.com)
- Add lucene4 to the Fedora 19 repo for new elasticsearch (jmontleo@redhat.com)
- update to unified action phases (git@pitr.ch)
- Merge branch 'master' into master-to-cv (paji@redhat.com)
- Monkey path PhusionPassenger only when available (inecas@redhat.com)
- Avoid conflicts with Rake::Task (inecas@redhat.com)
- Merge pull request #3671 from daviddavis/temp/20140206085205
  (daviddavis@redhat.com)
- Use action logger for action info (inecas@redhat.com)
- Tests for user orchestration (inecas@redhat.com)
- Use middleware for RemoteAction (inecas@redhat.com)
- User create orchestration with dynflow (inecas@redhat.com)
- Merge remote-tracking branch 'origin/master' into dynflow (inecas@redhat.com)
- Add missing async_task to org_controller and use Triggers module
  (git@pitr.ch)
- Merge pull request #3664 from jlsherrill/user_Fix (jlsherrill@gmail.com)
- Merge pull request #3669 from komidore64/undef-dont-use
  (komidore64@gmail.com)
- Merge pull request #3666 from waldenraines/set-title (walden@redhat.com)
- Using directive to set page title for nutupane pages. (walden@redhat.com)
- add sprockets and sprockets-rails (jmontleo@redhat.com)
- fixing issue where users would not exist in pulp (jsherril@redhat.com)
- Adding titles to old katello pages. (walden@redhat.com)
- Merge pull request #3646 from waldenraines/angular-rails-templates
  (walden@redhat.com)
- Content Views: Converting content view prototype to connect to API backend.
  (ericdhelms@gmail.com)
- Content Views: Initial work to generate a content view prototype.
  (ericdhelms@gmail.com)
- Content Views: Fixing v2 documentation (daviddavis@redhat.com)
- Merge pull request #3659 from jlsherrill/tee (jlsherrill@gmail.com)
- Content Views Rework: v2 filters controller tests (bbuckingham@redhat.com)
- apipie - :undef is not a valid apipie param type (komidore64@gmail.com)
- Bastion: adding angular templates to the $templateCache. (walden@redhat.com)
- Merge pull request #3587 from thomasmckay/mptap-ak-clean
  (thomasmckay@redhat.com)
- Merge pull request #3665 from jmontleon/remove-openjdk (jmontleo@redhat.com)
- update lucene to 4 for new elasticsearch (jmontleo@redhat.com)
- Merge pull request #3663 from daviddavis/update-rubocop
  (daviddavis@redhat.com)
- new activation keys based upon candlepin (mtapaswi@redhat.com)
- Allow addressing foreman API calls from bastion (inecas@redhat.com)
- Fix paths to RemoteAction action helper (inecas@redhat.com)
- Merge remote-tracking branch 'origin/master' into dynflow (inecas@redhat.com)
- Fix installation presenter (inecas@redhat.com)
- Merge pull request #3662 from waldenraines/fix-translate-error
  (walden@redhat.com)
- Merge pull request #3656 from thomasmckay/rhsm-api (thomasmckay@redhat.com)
- we should not have an openjdk package here (jmontleo@redhat.com)
- Merge pull request #3644 from ehelms/add-root-url (ericdhelms@gmail.com)
- rhsm-api - moving all rhsm routes to candlepin_proxies_controller
  (thomasmckay@redhat.com)
- Merge pull request #3660 from bbuckingham/cv-rework-filters
  (bbuckingham@redhat.com)
- Rubocop: Fixing error by updating gem (daviddavis@redhat.com)
- Merge pull request #3603 from jlsherrill/fort2 (jlsherrill@gmail.com)
- Bastion: fix clash between angular-gettext and ng-if. (walden@redhat.com)
- Merge pull request #3655 from waldenraines/upgrade-angular-gettext
  (walden@redhat.com)
- Re-enabling the fort engine (jsherril@redhat.com)
- Merge pull request #3661 from jmontleon/katello_api-nonscl
  (jmontleo@redhat.com)
- change katello_api to non-scl for hammer_cli_katello (jmontleo@redhat.com)
- Merge pull request #3657 from mccun934/add-jobs-readme (mmccune@gmail.com)
- Content Views: Fixing uninitialized Repository test error
  (daviddavis@redhat.com)
- API V2: Built out content views and added tests (daviddavis@redhat.com)
- Merge pull request #3643 from daviddavis/temp/20140129102533
  (daviddavis@redhat.com)
- Merge pull request #3649 from waldenraines/sync-plan-fixes
  (walden@redhat.com)
- Content Views Rework: filter updates for api consistency and to support CLI
  (bbuckingham@redhat.com)
- Merge pull request #3653 from daviddavis/more-cv-removal
  (daviddavis@redhat.com)
- use the yum_clone distributor during CV publish (jsherril@redhat.com)
- fixes for passenger in production mode (jsherril@redhat.com)
- Content views: Removing more unused files (daviddavis@redhat.com)
- Content Views: Fixing existing tests (daviddavis@redhat.com)
- update readme to indicate how to start the jobs worker (mmccune@redhat.com)
- Merge pull request #3650 from ehelms/fixes-4228 (ericdhelms@gmail.com)
- environments model - trivial spacing changes (komidore64@gmail.com)
- api v2 environments - only looking up by their numerical IDs
  (komidore64@gmail.com)
- Fixes #4228: After converting to single nav, tupane layout was not properly
  updated to reflect inclusion of inline JS. (ericdhelms@gmail.com)
- Bastion: Adds pre-fixing to AJAX calls with a single configurable RootURL.
  (ericdhelms@gmail.com)
- Bastion: upgrading angular-gettext to 0.2.3. (walden@redhat.com)
- Merge pull request #3637 from mccun934/pemfile5 (mmccune@gmail.com)
- Bastion: fix some minor issues with new sync plans functionality.
  (walden@redhat.com)
- Fix the provides statement so it is correct for SCL Builds as well
  (jmontleo@redhat.com)
- Avoid namespace variable (inecas@redhat.com)
- Delegate humanized_output to presenter object (inecas@redhat.com)
- More detailed humanized output for repository syncing (inecas@redhat.com)
- Merge remote-tracking branch 'origin/master' into dynflow (inecas@redhat.com)
- Merge pull request #3645 from waldenraines/sync-plan-form (walden@redhat.com)
- Merge pull request #3642 from daviddavis/temp/20140129090407
  (daviddavis@redhat.com)
- Fixing issue with display of new sync plan form on product pages.
  (walden@redhat.com)
- Merge pull request #3633 from daviddavis/temp/20140128110212
  (daviddavis@redhat.com)
- Merge pull request #3621 from parthaa/fk (parthaa@gmail.com)
- Merge pull request #3641 from ehelms/cleanup-scss (ericdhelms@gmail.com)
- More test fixes related to FK change (paji@redhat.com)
- Content Views Rework: filters: updating tests (bbuckingham@redhat.com)
- Add Dynflow dependencies into comps (inecas@redhat.com)
- Content Views Rework: merging filters & filter rules, CRUD support
  (bbuckingham@redhat.com)
- Content Views: Working on the V2 API (daviddavis@redhat.com)
- Documentation: Pointing to redmine now (daviddavis@redhat.com)
- Content Views: Removing more old models (daviddavis@redhat.com)
- Merge remote-tracking branch 'origin/master' into dynflow (inecas@redhat.com)
- Merge pull request #3618 from waldenraines/sync-plans (walden@redhat.com)
- Bastion: Converts to less based stylesheets completely and removes SCSS
  dependencies. (ericdhelms@gmail.com)
- Bastion: adding sync plan nutupane and removing old page. (walden@redhat.com)
- rename hammer_cli package for katelli support (jmontleo@redhat.com)
- Merge pull request #3639 from jlsherrill/reset (jlsherrill@gmail.com)
- Merge pull request #3630 from ehelms/cleanup-bower-dev (ericdhelms@gmail.com)
- fixing katello:reset when no schema exists (jsherril@redhat.com)
- Provides a new angular-based path selector widget. (ericdhelms@gmail.com)
- Updating AngularJS to 1.2.9. (ericdhelms@gmail.com)
- Bower: Sets bower development options to clean the Bower and target dirs
  before running. This is an attempt to fix the issues we occassionaly run into
  on the CI server. (ericdhelms@gmail.com)
- add back in the redhat CA file for access to the CDN (mmccune@redhat.com)
- Merge remote-tracking branch 'upstream/master' into cv-rework-merge-master
  (daviddavis@redhat.com)
- Merge pull request #3609 from mccun934/requires-update9 (mmccune@gmail.com)
- Merge pull request #3617 from mccun934/remove-unused-serviecs
  (mmccune@gmail.com)
- Merge pull request #3631 from jmontleon/rubygem-hammer_cli_katello
  (jmontleo@redhat.com)
- Merge pull request #3628 from jlsherrill/product_fix2 (jlsherrill@gmail.com)
- Merge pull request #3627 from jlsherrill/product_fix (jlsherrill@gmail.com)
- add rubygem-hammer_cli_katello to comps (jmontleo@redhat.com)
- removing non-sensical merge within TaskStatus#as_json (jsherril@redhat.com)
- Require dynflow before initializing (inecas@redhat.com)
- fixing disabled products from showing up by default in the api
  (jsherril@redhat.com)
- Fixed a couple of tests for FK violations (paji@redhat.com)
- Added back the foreign keys migration (paji@redhat.com)
- Engine: fixes #3342 - foreign keys migration (jmagen@redhat.com)
- Fix failing tests (inecas@redhat.com)
- Content Views: Supporting content view repositories in api
  (daviddavis@redhat.com)
- Merge remote-tracking branch 'origin/master' into dynflow (inecas@redhat.com)
- Action fixtures (inecas@redhat.com)
- Better humanized_output of package actions (inecas@redhat.com)
- Merge pull request #3620 from bkearney/bkearney/subscription-list
  (bryan.kearney@gmail.com)
- Fix failing tests; add assert_async_task method (git@pitr.ch)
- Merge pull request #3619 from ehelms/fix-ui (ericdhelms@gmail.com)
- Remove cli_examples from tasks (inecas@redhat.com)
- Remove unused code - angular-ui-bootstrap (inecas@redhat.com)
- Merge pull request #3614 from daviddavis/temp/20140123125928
  (daviddavis@redhat.com)
- Merge pull request #3616 from jlsherrill/ping (jlsherrill@gmail.com)
- Expose the susbcription list to the api (bkearney@redhat.com)
- Fixes gap at the top of pages stemming from recent fix to properly render
  navigation. (ericdhelms@gmail.com)
- fixing about page brokeness (jsherril@redhat.com)
- remove foreman and thumbslug services now that they are no longer used
  (mmccune@redhat.com)
- Merge remote-tracking branch 'origin/master' into dynflow (inecas@redhat.com)
- Include action tests in the test suite (inecas@redhat.com)
- Remove old workaround (inecas@redhat.com)
- Bastion: adding product and repository sync functionality.
  (walden@redhat.com)
- Merge pull request #3570 from parthaa/gpgkey-v1-to-v2 (parthaa@gmail.com)
- Merge pull request #3615 from jlsherrill/upload (jlsherrill@gmail.com)
- Make the bastion static dispatcher loaded at the right time
  (inecas@redhat.com)
- fixing ng-upload forms for firefox (jsherril@redhat.com)
- api v2 gpg controller changes (paji@redhat.com)
- Merge remote-tracking branch 'origin/master' into dynflow (inecas@redhat.com)
- Fix autoloading issues (inecas@redhat.com)
- Remove unused file (inecas@redhat.com)
- Merge pull request #3613 from jlsherrill/redhat_repos (jlsherrill@gmail.com)
- Puppet modules: Providing more explicit error message (daviddavis@redhat.com)
- fixing red hat repositories page in production (jsherril@redhat.com)
- Make rubocop happy (inecas@redhat.com)
- Merge pull request #3601 from bkearney/bkearney/candlepin-failed-auth-
  namespace (bryan.kearney@gmail.com)
- Require foreman-tasks instead of dynflow (inecas@redhat.com)
- Convent View Rework: Made initial changes (daviddavis@redhat.com)
- Merge remote-tracking branch 'origin/master' into dynflow (inecas@redhat.com)
- Update spec files (inecas@redhat.com)
- Lock dynflow version on 0.1.0 (inecas@redhat.com)
- Update katello-jobs to include dynflow executor (inecas@redhat.com)
- Merge pull request #3576 from bbuckingham/engine-integration
  (bbuckingham@redhat.com)
- Merge pull request #3607 from waldenraines/upgrade_ui_bootstrap
  (walden@redhat.com)
- Merge pull request #3595 from ehelms/fix-double-icons (ericdhelms@gmail.com)
- Engine: integration: rubocop updates (bbuckingham@redhat.com)
- Merge pull request #3610 from mccun934/add-p-requests-f19 (mmccune@gmail.com)
- Merge pull request #3606 from daviddavis/temp/20140122122803
  (daviddavis@redhat.com)
- we gotta ship the rawhide version of python-requests (mmccune@redhat.com)
- adding CLI requires so installs of katello pull in the CLI
  (mmccune@redhat.com)
- Bastion: fixing readme with regard to installing/updating bower assets.
  (walden@redhat.com)
- Bastion: upgrading angular-bootstrap to 0.10.0 and removing hacks.
  (walden@redhat.com)
- v2 api: repositories: fix retrieval of product (daviddavis@redhat.com)
- Fix searching for product when creating repository (inecas@redhat.com)
- Fix last merge (inecas@redhat.com)
- Merge remote-tracking branch 'origin/master' into dynflow (inecas@redhat.com)
- Merge pull request #3602 from waldenraines/org_switcher (walden@redhat.com)
- Engine: pull in foreman defacing from foreman-katello-engine
  (bbuckingham@redhat.com)
- Update to latest Dynflow testing (git@pitr.ch)
- Merge pull request #3596 from waldenraines/jquery (walden@redhat.com)
- Removing remnants of katello's org switcher. (walden@redhat.com)
- Fixes a unknown resources error. (bkearney@redhat.com)
- Merge pull request #3592 from mccun934/specfile-fixes3 (mmccune@gmail.com)
- this is required for pulp 2.3.1 (mmccune@redhat.com)
- Merge pull request #3599 from ehelms/spec-installer-update
  (mmccune@gmail.com)
- Merge pull request #3594 from waldenraines/full_results (walden@redhat.com)
- Merge pull request #3598 from ehelms/comps-update (ericdhelms@gmail.com)
- Merge pull request #3593 from ehelms/config-fix (ericdhelms@gmail.com)
- Fix #3985 - foreman hardhat under inner top bar. (walden@redhat.com)
- API: allowing param full_results to be passed in to show all results.
  (walden@redhat.com)
- Engine: integrate behavior from katello-foreman-engine & foreman-katello-
  engine (bbuckingham@redhat.com)
- remove unused calls to the defunct 'katello' service (mmccune@redhat.com)
- Adding tests for ::Actions::Pulp::Consumer::* (git@pitr.ch)
- test action_subject in Dynflow::Action (git@pitr.ch)
- Add test for ::Actions::Pulp::Repository::Sync (git@pitr.ch)
- fix old assert names (git@pitr.ch)
- Silent logger by default (git@pitr.ch)
- Rename space->namespace; DRY-ification (git@pitr.ch)
- Add tests for ::Actions::Katello::System::Package::* actions (git@pitr.ch)
- Add tests for ::Actions::Katello::Repository::* actions (git@pitr.ch)
- Add support for Dynflow::Action testing (git@pitr.ch)
- Spec: Removing node-installer requires and adding back katello-installer
  requires to katello RPM. (ericdhelms@gmail.com)
- Reflecting update of node-installer to katello-installer in comps.
  (ericdhelms@gmail.com)
- Fixes double editable icons appearing. (ericdhelms@gmail.com)
- Fixing broken configuration loading caused by attempting to access non-
  existent variable. (ericdhelms@gmail.com)
- Remove the TasksController (inecas@redhat.com)
- Deal with situation of current tasks widget not being shown
  (inecas@redhat.com)
- Don't use filter for specifying progress classes (inecas@redhat.com)
- Prefer attributes directive over element (inecas@redhat.com)
- Remove unused migrations (inecas@redhat.com)
- Whitespace (inecas@redhat.com)
- Fix Ruby style issues (inecas@redhat.com)
- Follow naming conventions for directives (inecas@redhat.com)
- Get rid of style attribute (inecas@redhat.com)
- Whitespace (inecas@redhat.com)
- More idiomatic less for tasks (inecas@redhat.com)
- Whitespace (inecas@redhat.com)
- Fix module info (inecas@redhat.com)
- Extract the task-table directive calls to html templates (inecas@redhat.com)
- Get rid of unnecessary clickable classes (inecas@redhat.com)
- Remove old logging code when triggering event (inecas@redhat.com)
- Move execution of Dynflow task outside of the transaction in AR hooks
  (inecas@redhat.com)
- Update documentation of tasks specific work (inecas@redhat.com)
- Fix repo sync js tests (inecas@redhat.com)
- Fix repo discovery js tests (inecas@redhat.com)
- Fix repo discovery task (inecas@redhat.com)
- Fix adding the results to nutupane twice (inecas@redhat.com)
- Fix js lint errors (inecas@redhat.com)
- Remove the dynflow configuration from Katello (inecas@redhat.com)
- Update the initializer to the foreman-tasks changes (inecas@redhat.com)
- Make seed idempotent (git@pitr.ch)
- Do not trigger katello config loading prematurely (git@pitr.ch)
- Replace the boostrap-ui workaround with better solution (inecas@redhat.com)
- Update the trigger method in events (inecas@redhat.com)
- Extract common tasks logic into Foreman tasks gem (inecas@redhat.com)
- Allow overriding the action input key for serialized resource
  (inecas@redhat.com)
- Support flat humanized_input for task in Bastion UI (inecas@redhat.com)
- Allow setting exclusive lock for entry action (inecas@redhat.com)
- Change task#uuid to task#id (inecas@redhat.com)
- Use the api from foreman-tasks for showing the task details
  (inecas@redhat.com)
- Extract the tasks and locks to separate engine (inecas@redhat.com)
- Fix the silencer after moving to enginified version (inecas@redhat.com)
- tmp (inecas@redhat.com)
- Extract the dynflow initialization to foreman-tasks gem (inecas@redhat.com)
- Use generic Pooling (git@pitr.ch)
- Add Dynflow development and production mode (git@pitr.ch)
- Update the code to the change on Dynflow::World.trigger (inecas@redhat.com)
- Rebase against engine branch (inecas@redhat.com)
- Don't stop polling when some error occurs on fetching the data
  (inecas@redhat.com)
- Tasks for repository create/delete actions (inecas@redhat.com)
- Better structure for actions (inecas@redhat.com)
- Rename Orchestrate to Actions (inecas@redhat.com)
- Fix namespacing issues (inecas@redhat.com)
- Link to task resources (inecas@redhat.com)
- Don't show known context in event details (inecas@redhat.com)
- CLI example example (inecas@redhat.com)
- Structured task humanized input (inecas@redhat.com)
- Enhanced connecting of actions to resources (inecas@redhat.com)
- Dynflow locks refined (inecas@redhat.com)
- Search on tasks is not supported for now (inecas@redhat.com)
- All tasks page (inecas@redhat.com)
- Tasks list for product (inecas@redhat.com)
- Unregistering search when leaving the tasks page (inecas@redhat.com)
- Remove old code (inecas@redhat.com)
- Current user tasks via tasks-list directive (inecas@redhat.com)
- Update silencer path to bulk_search (inecas@redhat.com)
- Use Bootstrap3 for progressbars (inecas@redhat.com)
- fix tasks-table scoping (inecas@redhat.com)
- More paranoid pulp tasks presenter (inecas@redhat.com)
- Deploy own templates for angular-ui-bootstrap progressbar (inecas@redhat.com)
- Fix after rebase against develop (inecas@redhat.com)
- Generalize the tasks-table and task details to be usable outside of system
  details (inecas@redhat.com)
- Move the periodic bulk updater for tasks to Task (inecas@redhat.com)
- Use taskListProvider for polling for discovery results (inecas@redhat.com)
- Dynflow tasks for systems (inecas@redhat.com)
- Ability to inherit from the Nutupane class to customize it a bit
  (inecas@redhat.com)
- PulpTask defines run method, expecting the action to define run_pulp_task
  (inecas@redhat.com)
- Aggregate the actions input/output in the task JSON (inecas@redhat.com)
- All action inherit from common Katello-specific action (inecas@redhat.com)
- Update the UI to use the Dynflow for repo discovery (inecas@redhat.com)
- Collect results of actions +task_output+ into task#outputs
  (inecas@redhat.com)
- Repository Discover action (inecas@redhat.com)
- reloading of dynflow actions (git@pitr.ch)
- connect dynflow logging to Katello (git@pitr.ch)
- Add Katello specific world (git@pitr.ch)
- Load orchestration files in orchestrate.rb not in application.rb
  (git@pitr.ch)
- add graceful shutdown of Dynflow World (git@pitr.ch)
- rename setup_suspend to setup_progress_updates (git@pitr.ch)
- Use middleware instead of mankey-patching to silence custom paths in dev
  (inecas@redhat.com)
- Use rabl template to generate the task hash (inecas@redhat.com)
- Ability to search for dynflow tasks (inecas@redhat.com)
- Show current tasks for the user (inecas@redhat.com)
- Show active tasks on right top corner (inecas@redhat.com)
- Link to sync repo using Dynflow (inecas@redhat.com)
- Extract pulp polling service into module (inecas@redhat.com)
- Improve UI: started_at time and correct css class for error in progress
  (inecas@redhat.com)
- RepositorySync progress based on the number of repos synced
  (inecas@redhat.com)
- Tasklist for resources (inecas@redhat.com)
- Use tailored bootstrap including only bootstrap-progressbar
  (inecas@redhat.com)
- DyntasksController#search for handling multiple tasks conditions.
  (inecas@redhat.com)
- Show progress of current orchestration task for repos (inecas@redhat.com)
- Dummy tasks progress back-end and connection the UI (inecas@redhat.com)
- taskprogress (inecas@redhat.com)
- Repo sync orch actions (inecas@redhat.com)
- Needed minimum to use new dynflow (inecas@redhat.com)
- Make sure the engine helpers are loaded for the UI (inecas@redhat.com)

* Tue Jan 21 2014 Mike McCune <mmccune@redhat.com> 1.5.0-10
- rebuild with latest in master
* Mon Dec 16 2013 Jason Montleon <jmontleo@redhat.com> 1.5.0-9
- Tag rubygem-katello-1.5.0-9

* Mon Dec 16 2013 Jason Montleon <jmontleo@redhat.com> 1.5.0-9
- fixes for engine packaging (jmontleo@redhat.com)
- Merge remote-tracking branch 'upstream/master' into engine-packaging
  (jmontleo@redhat.com)
- Merge pull request #3513 from daviddavis/temp/20131216104958
  (daviddavis@redhat.com)
- Merge pull request #3510 from mkelley33/readme-grunt-bower-task
  (michauxkelley@gmail.com)
- Reorganize dependency errors section of README (michauxkelley@gmail.com)
- Creating a katello.local.rb for development (daviddavis@redhat.com)
- Engine: Renaming localized gemfile to something less generic
  (daviddavis@redhat.com)
- Merge pull request #3483 from komidore64/system-api-v2 (komidore64@gmail.com)
- Merge pull request #3507 from ehelms/update-readme (ericdhelms@gmail.com)
- Engine: Fixing katello_dev gem echo statement (daviddavis@redhat.com)
- API v2 - v2 systems_controller w/ create, index, and show
  (komidore64@gmail.com)
- Merge pull request #3506 from jmontleon/version-fix (ericdhelms@gmail.com)
- Fixing inconsistency in setup workflow. (ericdhelms@gmail.com)
- Merge pull request #3469 from ehelms/allow-development-gems
  (ericdhelms@gmail.com)
- Changes to support Katello engine RPM builds (jmontleo@redhat.com)
- Merge pull request #3497 from mkelley33/fix-product-namespacing
  (michauxkelley@gmail.com)
- change version to 1.5.0 for next release (jmontleo@redhat.com)
- Allows development gems to be declared that can be ignored in production mode
  by bundler. (ericdhelms@gmail.com)
- add locale directory to gem.files (jmontleo@redhat.com)
- Fix namespacing in Katello::Authorization::Product (michauxkelley@gmail.com)

* Fri Dec 13 2013 Jason Montleon <jmontleo@redhat.com> 1.4.0-8
- fix gempsec (jmontleo@redhat.com)
- Changes to support Katello engine RPM builds (jmontleo@redhat.com)
- Merge pull request #3459 from ehelms/remove-travis (ericdhelms@gmail.com)
- Merge pull request #3484 from domcleal/no-puppet (ericdhelms@gmail.com)
- Merge pull request #3501 from daviddavis/temp/20131212153148
  (daviddavis@redhat.com)
- Bastion: enabling jshint whitespace detection. (daviddavis@redhat.com)
- Removing Travis configs and scripts as we rely on the Foreman CI
  infrastructure. (ericdhelms@gmail.com)
- Remove obsolete Puppet/Facter installation references (dcleal@redhat.com)

* Thu Dec 12 2013 Jason Montleon <jmontleo@redhat.com> 1.4.0-7
- add changelog (jmontleo@redhat.com)

