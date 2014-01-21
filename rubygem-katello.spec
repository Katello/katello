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

Version: 1.5.0
Release: 9%{dist}
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

%if 0%{?fedora} > 18
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
Requires: pulp-katello-plugins
Requires: pulp-nodes-parent
Requires: pulp-puppet-plugins
Requires: pulp-rpm-plugins
Requires: pulp-selinux
Requires: pulp-server
Requires: mongodb
Requires: mongodb-server

#Qpid Requirements
Requires: qpid-cpp-client
Requires: qpid-cpp-client-ssl
Requires: qpid-cpp-server
Requires: qpid-cpp-server-ssl

Requires: candlepin-selinux
Requires: createrepo >= 0.9.9-18%{?dist}
Requires: elasticsearch
Requires: foreman >= 1.3.0
Requires: java-openjdk
# Still Requires katello-common which clashes with
# new build - will re-enable after fixing
#Requires: katello-selinux
Requires: libvirt-devel
Requires: lsof
Requires: node-installer
Requires: postgresql
Requires: postgresql-server
Requires: v8
Requires: %{?scl_prefix}rubygems
Requires: %{?scl_prefix}rubygem-rails 
Requires: %{?scl_prefix}rubygem-json 
Requires: %{?scl_prefix}rubygem-oauth 
Requires: %{?scl_prefix}rubygem-rest-client
Requires: %{?scl_prefix}rubygem-net-ldap 
Requires: %{?scl_prefix}rubygem-ldap_fluff >= 0.2.2
Requires: %{?scl_prefix}rubygem-foreigner => 1.4.2
Requires: %{?scl_prefix}rubygem-foreigner < 1.5
Requires: %{?scl_prefix}rubygem-daemons >= 1.1.4
Requires: %{?scl_prefix}rubygem-uuidtools 
Requires: %{?scl_prefix}rubygem-rabl 
Requires: %{?scl_prefix}rubygem-tire => 0.6.0
Requires: %{?scl_prefix}rubygem-tire < 0.7
Requires: %{?scl_prefix}rubygem-logging >= 1.8.0
Requires: %{?scl_prefix}rubygem-hooks 
Requires: %{?scl_prefix}rubygem-dynflow >= 0.1.0
Requires: %{?scl_prefix}rubygem-justified 
Requires: %{?scl_prefix}rubygem-delayed_job => 3.0.2
Requires: %{?scl_prefix}rubygem-delayed_job < 3.1
Requires: %{?scl_prefix}rubygem-delayed_job_active_record => 0.3.3
Requires: %{?scl_prefix}rubygem-delayed_job_active_record < 0.4
Requires: %{?scl_prefix}rubygem-gettext_i18n_rails 
Requires: %{?scl_prefix}rubygem-i18n_data >= 0.2.6
Requires: %{?scl_prefix}rubygem-apipie-rails >= 0.0.13
Requires: %{?scl_prefix}rubygem-maruku 
Requires: %{?scl_prefix}rubygem-runcible >= 1.0.8
Requires: %{?scl_prefix}rubygem-ruby-openid
Requires: %{?scl_prefix}rubygem-anemone 
Requires: %{?scl_prefix}rubygem-simple-navigation >= 3.3.4
Requires: %{?scl_prefix}rubygem-sass-rails
Requires: %{?scl_prefix}rubygem-less-rails 
Requires: %{?scl_prefix}rubygem-compass-rails 
Requires: %{?scl_prefix}rubygem-compass-960-plugin 
Requires: %{?scl_prefix}rubygem-haml-rails 
Requires: %{?scl_prefix}rubygem-ui_alchemy-rails = 1.0.12
Requires: %{?scl_prefix}rubygem-deface
Requires: %{?scl_prefix}rubygem-strong_parameters
BuildRequires: foreman >= 1.3.0
BuildRequires: %{?scl_prefix}rubygem-net-ldap 
BuildRequires: %{?scl_prefix}rubygem-ldap_fluff >= 0.2.2
BuildRequires: %{?scl_prefix}rubygem-sqlite3
BuildRequires: %{?scl_prefix}rubygem-tire => 0.6.0
BuildRequires: %{?scl_prefix}rubygem-tire < 0.7
BuildRequires: %{?scl_prefix}rubygem-logging >= 1.8.0
BuildRequires: %{?scl_prefix}rubygem-hooks 
BuildRequires: %{?scl_prefix}rubygem-dynflow >= 0.1.0
BuildRequires: %{?scl_prefix}rubygem-justified 
BuildRequires: %{?scl_prefix}rubygem-delayed_job => 3.0.2
BuildRequires: %{?scl_prefix}rubygem-delayed_job < 3.1
BuildRequires: %{?scl_prefix}rubygem-delayed_job_active_record => 0.3.3
BuildRequires: %{?scl_prefix}rubygem-delayed_job_active_record < 0.4
BuildRequires: %{?scl_prefix}rubygem-gettext_i18n_rails 
BuildRequires: %{?scl_prefix}rubygem-i18n_data >= 0.2.6
BuildRequires: %{?scl_prefix}rubygem-apipie-rails >= 0.0.13
BuildRequires: %{?scl_prefix}rubygem-maruku 
BuildRequires: %{?scl_prefix}rubygem-runcible >= 1.0.8
BuildRequires: %{?scl_prefix}rubygem-ruby-openid
BuildRequires: %{?scl_prefix}rubygem-anemone 
BuildRequires: %{?scl_prefix}rubygem-simple-navigation >= 3.3.4
BuildRequires: %{?scl_prefix}rubygem-sass-rails
BuildRequires: %{?scl_prefix}rubygem-less-rails 
BuildRequires: %{?scl_prefix}rubygem-compass-rails 
BuildRequires: %{?scl_prefix}rubygem-compass-960-plugin 
BuildRequires: %{?scl_prefix}rubygem-haml-rails 
BuildRequires: %{?scl_prefix}rubygem-ui_alchemy-rails = 1.0.12
BuildRequires: %{?scl_prefix}rubygem-deface
BuildRequires: %{?scl_prefix}rubygem(uglifier) >= 1.0.3
BuildRequires: %{?scl_prefix}rubygem-strong_parameters
BuildRequires: %{?scl_prefix}rubygems
BuildArch: noarch
Provides: rubygem(katello) = %{version}

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

