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

Summary: Katello
Name: %{?scl_prefix}rubygem-%{gem_name}

Version: 1.5.1
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
BuildRequires: %{?scl_prefix}ruby(release) = 2.0.0
%else
%if "%{?scl}" == "ruby193" || 0%{?rhel} > 6 || 0%{?fedora} > 16 
Requires: %{?scl_prefix}ruby(abi) = 1.9.1
%else
Requires: ruby(abi) = 1.8
%endif
%endif

%if 0%{?fedora} > 19
BuildRequires: %{?scl_prefix}ruby(release) = 2.0.0
%else
%if "%{?scl}" == "ruby193" || 0%{?rhel} > 6 || 0%{?fedora} > 16 
BuildRequires: %{?scl_prefix}ruby(abi) = 1.9.1
%else
BuildRequires: ruby(abi) = 1.8
%endif
%endif

Requires: foreman >= 1.3.0
Requires: %{?scl_prefix}rubygems
Requires: %{?scl_prefix}rubygem-rails 
Requires: %{?scl_prefix}rubygem-json 
Requires: %{?scl_prefix}rubygem-oauth 
Requires: %{?scl_prefix}rubygem-rack-openid 
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
Requires: %{?scl_prefix}rubygem-logger 
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
Requires: %{?scl_prefix}rubygem-pdf-reader 
Requires: %{?scl_prefix}rubygem-prawn 
Requires: %{?scl_prefix}rubygem-acts_as_reportable >= 1.1.1
Requires: %{?scl_prefix}rubygem-runcible = 1.0.7
Requires: %{?scl_prefix}rubygem-anemone 
Requires: %{?scl_prefix}rubygem-simple-navigation >= 3.3.4
Requires: %{?scl_prefix}rubygem-sass-rails 
Requires: %{?scl_prefix}rubygem-compass-rails 
Requires: %{?scl_prefix}rubygem-compass-960-plugin 
Requires: %{?scl_prefix}rubygem-haml-rails 
Requires: %{?scl_prefix}rubygem-ui_alchemy-rails = 1.0.12
Requires: %{?scl_prefix}rubygem-factory_girl_rails => 1.4.0
Requires: %{?scl_prefix}rubygem-factory_girl_rails < 1.5
Requires: %{?scl_prefix}rubygem-minitest-tags 
Requires: %{?scl_prefix}rubygem-minitest-predicates 
Requires: %{?scl_prefix}rubygem-mocha => 0.14.0
Requires: %{?scl_prefix}rubygem-mocha < 0.15
Requires: %{?scl_prefix}rubygem-vcr 
Requires: %{?scl_prefix}rubygem-webmock 
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

mkdir -p %{buildroot}%{foreman_bundlerd_dir}
cat <<GEMFILE > %{buildroot}%{foreman_bundlerd_dir}/%{gem_name}.rb
gem '%{gem_name}'
GEMFILE

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-, root, root)
%{gem_instdir}/
%exclude %{gem_cache}
%{gem_spec}
%{foreman_bundlerd_dir}/%{gem_name}.rb

%files doc
%{gem_dir}/doc/%{gem_name}-%{version}
