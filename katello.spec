# vim: sw=4:ts=4:et
#
# Copyright 2013 Red Hat, Inc.
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
    %global scl_rake scl enable ruby193 rake
    ### TODO temp disabled for SCL
    %global nodoc 1
%else
    %global scl_ruby /usr/bin/ruby
    %global scl_rake /usr/bin/rake
%endif

%global homedir %{_datarootdir}/%{name}
%global datadir %{_sharedstatedir}/%{name}
%global confdir deploy/common

### TODO temp disabled for F18 ###
%if 0%{?fedora} == 18
%global nodoc 1
%endif

Name:           katello
Version:        1.3.24
Release:        1%{?dist}
Summary:        A package for managing application life-cycle for Linux systems
BuildArch:      noarch

Group:          Applications/Internet
License:        GPLv2
URL:            http://www.katello.org
Source0:        https://fedorahosted.org/releases/k/a/katello/%{name}-%{version}.tar.gz

Requires:        %{name}-common
Requires:        %{name}-glue-elasticsearch
Requires:        %{name}-glue-pulp
Obsoletes:       %{name}-glue-foreman < 1.3.15
Provides:        %{name}-glue-foreman = 1.3.15
Requires:        %{name}-glue-candlepin
Requires:        %{name}-selinux
Conflicts:       %{name}-headpin

%description
Provides a package for managing application life-cycle for Linux systems.

%package common
BuildArch:      noarch
Summary:        Common bits for all Katello instances
%if 0%{?fedora} == 18
Requires:       httpd >= 2.4.4
%else
Requires:       httpd
%endif
Requires:       mod_ssl
Requires:       openssl
Requires:       elasticsearch

# service-wait dependency
Requires:       wget
Requires:       curl

Requires:       %{?scl_prefix}rubygems
Requires:       %{?scl_prefix}rubygem(rails) >= 3.2.8
Requires:       %{?scl_prefix}rubygem(haml) >= 3.1.2
Requires:       %{?scl_prefix}rubygem(haml-rails)
Requires:       %{?scl_prefix}rubygem(json)
Requires:       %{?scl_prefix}rubygem(rest-client)
Requires:       %{?scl_prefix}rubygem(therubyracer)
Requires:       %{?scl_prefix}rubygem(rails_warden)
Requires:       %{?scl_prefix}rubygem(net-ldap)
Requires:       %{?scl_prefix}rubygem(compass)
Requires:       %{?scl_prefix}rubygem(compass-rails)
Requires:       %{?scl_prefix}rubygem(sass-rails)
Requires:       %{?scl_prefix}rubygem(compass-960-plugin) >= 0.10.4
Requires:       %{?scl_prefix}rubygem(oauth)
Requires:       %{?scl_prefix}rubygem(i18n_data) >= 0.2.6
Requires:       %{?scl_prefix}rubygem(gettext_i18n_rails)
Requires:       %{?scl_prefix}rubygem(simple-navigation) >= 3.3.4
Requires:       %{?scl_prefix}rubygem(pg)
Requires:       %{?scl_prefix}rubygem(delayed_job) >= 3.0.2
Requires:       %{?scl_prefix}rubygem(delayed_job_active_record) >= 0.3.3
Requires:       %{?scl_prefix}rubygem(delayed_job_active_record) < 0.4.0
Requires:       %{?scl_prefix}rubygem(acts_as_reportable) >= 1.1.1
Requires:       %{?scl_prefix}rubygem(ruport) >= 1.7.0
Requires:       %{?scl_prefix}rubygem(prawn)
Requires:       %{?scl_prefix}rubygem(daemons) >= 1.1.4
Requires:       %{?scl_prefix}rubygem(uuidtools)
Requires:       %{?scl_prefix}rubygem(hooks)
Requires:       %{?scl_prefix}rubygem(thin)
Requires:       %{?scl_prefix}rubygem(fssm)
Requires:       %{?scl_prefix}rubygem(sass)
Requires:       %{?scl_prefix}rubygem(ui_alchemy-rails) >= 1.0.0
Requires:       %{?scl_prefix}rubygem(chunky_png)
Requires:       %{?scl_prefix}rubygem(tire) >= 0.3.0
Requires:       %{?scl_prefix}rubygem(tire) < 0.4
Requires:       %{?scl_prefix}rubygem(ldap_fluff)
Requires:       %{?scl_prefix}rubygem(anemone)
Requires:       %{?scl_prefix}rubygem(apipie-rails) >= 0.0.18
Requires:       %{?scl_prefix}rubygem(logging) >= 1.8.0
Requires:       %{?scl_prefix}rubygem(bundler_ext) >= 0.3
Requires:       lsof

%if 0%{?rhel} == 6
Requires:       redhat-logos >= 60.0.14
%endif

Requires: %{?scl_prefix}ruby(abi) = 1.9.1
Requires: %{?scl_prefix}ruby

# <workaround> for 714167 - undeclared dependencies (regin & multimap)
# TODO - uncomment the statement once we push patched actionpack to our EL6 repo
#%if 0%{?fedora} && 0%{?fedora} <= 15
Requires:       %{?scl_prefix}rubygem(regin)
#%endif
# </workaround>

Requires(pre):    shadow-utils
Requires(preun):  chkconfig
Requires(preun):  initscripts
Requires(post):   chkconfig
Requires(postun): initscripts coreutils sed

BuildRequires:  coreutils findutils sed
BuildRequires:  %{?scl_prefix}rubygems
BuildRequires:  %{?scl_prefix}rubygem-rake
BuildRequires:  %{?scl_prefix}rubygem(chunky_png)
BuildRequires:  %{?scl_prefix}rubygem(fssm) >= 0.2.7
BuildRequires:  %{?scl_prefix}rubygem(compass)
BuildRequires:  %{?scl_prefix}rubygem(compass-rails)
BuildRequires:  %{?scl_prefix}rubygem(therubyracer)
BuildRequires:  %{?scl_prefix}rubygem(uglifier)
BuildRequires:  %{?scl_prefix}rubygem(sass-rails)
BuildRequires:  %{?scl_prefix}rubygem(compass-960-plugin) >= 0.10.4
BuildRequires:  %{?scl_prefix}rubygem(bundler_ext)
BuildRequires:  %{?scl_prefix}rubygem(logging) >= 1.8.0
BuildRequires:  %{?scl_prefix}rubygem(ui_alchemy-rails) >= 1.0.0
BuildRequires:  asciidoc
BuildRequires:  /usr/bin/getopt
BuildRequires:  java >= 0:1.6.0
BuildRequires:  gettext
BuildRequires:  translate-toolkit

%if "%{?scl}" == "ruby193"
BuildRequires: ruby193-build
%endif

# we require this to be able to build api-docs
BuildRequires:       %{?scl_prefix}rubygem(rails) >= 3.0.10
BuildRequires:       %{?scl_prefix}rubygem(haml) >= 3.1.2
BuildRequires:       %{?scl_prefix}rubygem(haml-rails)
BuildRequires:       %{?scl_prefix}rubygem(json)
BuildRequires:       %{?scl_prefix}rubygem(rest-client)
BuildRequires:       %{?scl_prefix}rubygem(rails_warden)
BuildRequires:       %{?scl_prefix}rubygem(net-ldap)
BuildRequires:       %{?scl_prefix}rubygem(oauth)
BuildRequires:       %{?scl_prefix}rubygem(i18n_data) >= 0.2.6
BuildRequires:       %{?scl_prefix}rubygem(gettext_i18n_rails)
BuildRequires:       %{?scl_prefix}rubygem(simple-navigation) >= 3.3.4
BuildRequires:       %{?scl_prefix}rubygem(pg)
BuildRequires:       %{?scl_prefix}rubygem(acts_as_reportable) >= 1.1.1
BuildRequires:       %{?scl_prefix}rubygem(ruport) >= 1.7.0
BuildRequires:       %{?scl_prefix}rubygem(prawn)
BuildRequires:       %{?scl_prefix}rubygem(daemons) >= 1.1.4
BuildRequires:       %{?scl_prefix}rubygem(uuidtools)
BuildRequires:       %{?scl_prefix}rubygem(thin)
BuildRequires:       %{?scl_prefix}rubygem(sass)
BuildRequires:       %{?scl_prefix}rubygem(tire) >= 0.3.0
BuildRequires:       %{?scl_prefix}rubygem(tire) < 0.4
BuildRequires:       %{?scl_prefix}rubygem(ldap_fluff)
BuildRequires:       %{?scl_prefix}rubygem(apipie-rails) >= 0.0.18
BuildRequires:       %{?scl_prefix}rubygem(maruku)

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
Requires(post): candlepin-tomcat6
Requires:       candlepin-selinux
# the following backend engine deps are required by <katello-configure>
Requires:       mongodb
Requires:       mongodb-server
Requires:       qpid-cpp-server
Requires:       qpid-cpp-client
Requires:       qpid-cpp-client-ssl
Requires:       qpid-cpp-server-ssl
# </katello-configure>


%description all
This is the Katello meta-package.  If you want to install Katello and all
of its dependencies on a single machine, you should install this package
and then run katello-configure to configure everything.

%package glue-elasticsearch
BuildArch:      noarch
Summary:         Katello connection classes for the Elastic Search backend
Requires:        %{name}-common

%description glue-elasticsearch
Katello connection classes for the Elastic Search backend

%package glue-pulp
BuildArch:      noarch
Summary:         Katello connection classes for the Pulp backend
Requires:        %{name}-common
Requires:        pulp-server
Requires:        pulp-rpm-plugins
Requires:        pulp-selinux
Requires:        %{?scl_prefix}rubygem(runcible) >= 0.4.3

%description glue-pulp
Katello connection classes for the Pulp backend

%package glue-candlepin
BuildArch:      noarch
Summary:         Katello connection classes for the Candlepin backend
Requires:        %{name}-common

%description glue-candlepin
Katello connection classes for the Candlepin backend

%package headpin
Summary:        A subscription management only version of Katello
BuildArch:      noarch
Requires:       katello-common
Requires:       %{name}-glue-candlepin
Requires:       %{name}-glue-elasticsearch
Requires:       katello-selinux
Requires:       %{?scl_prefix}rubygem(bundler_ext)

%description headpin
A subscription management only version of Katello.

%package headpin-all
Summary:        A meta-package to pull in all components for katello-headpin
Requires:       katello-headpin
Requires:       katello-configure
Requires:       katello-cli
Requires:       postgresql-server
Requires:       postgresql
Requires(post): candlepin-tomcat6
Requires:       thumbslug
Requires:       thumbslug-selinux

%description headpin-all
This is the Katello-headpin meta-package.  If you want to install Headpin and all
of its dependencies on a single machine, you should install this package
and then run katello-configure to configure everything.

%package api-docs
Summary:         Documentation files for Katello API
BuildArch:       noarch
Requires:        %{name}-common

%description api-docs
Documentation files for Katello API.

%package headpin-api-docs
Summary:         Documentation files for Headpin API
BuildArch:       noarch
Requires:        %{name}-common

%description headpin-api-docs
Documentation files for Headpin API.

# <devel packages are not SCL enabled yet - not avaiable on SCL platforms>
%if %{?scl:0}%{!?scl:1}

%package devel-all
Summary:         Katello devel support (all subpackages)
BuildArch:       noarch
Requires:        %{name}-devel = %{version}-%{release}
Requires:        %{name}-devel-profiling = %{version}-%{release}
Requires:        %{name}-devel-test = %{version}-%{release}
Requires:        %{name}-devel-checking = %{version}-%{release}
Requires:        %{name}-devel-coverage = %{version}-%{release}
Requires:        %{name}-devel-debugging = %{version}-%{release}

%description devel-all
Meta package to install all %{name}-devel-* subpackages.

%package devel
Summary:         Katello devel support
BuildArch:       noarch
Requires:        %{name} = %{version}-%{release}
# Gemfile
Requires:        rubygem(ci_reporter) >= 1.6.3
# dependencies from bundler.d/development.rb
Requires:        rubygem(rspec-rails) >= 2.0.0
Requires:        rubygem(parallel_tests)
Requires:        rubygem(yard) >= 0.5.3
Requires:        rubygem(js-routes)
Requires:        rubygem(gettext) >= 1.9.3
Requires:        rubygem(ruby_parser)
Requires:        rubygem(sexp_processor)
Requires:        rubygem(factory_girl_rails) >= 1.4.0
# dependencies from bundler.d/development_boost.rb
Requires:        rubygem(rails-dev-boost)
# dependencies from bundler.d/apipie.rb
Requires:        rubygem(maruku)

%description devel
Rake tasks and dependecies for Katello developers

%package devel-profiling
Summary:         Katello devel support (profiling)
BuildArch:       noarch
Requires:        %{name} = %{version}-%{release}
# dependencies from bundler.d/optional.rb
Requires:        rubygem(ruby-prof)
Requires:        rubygem(newrelic_rpm)

%description devel-profiling
Rake tasks and dependecies for Katello developers, which enables
profiling.

%package devel-checking
Summary:         Katello devel support (unit test and syntax checking)
BuildArch:       noarch
Provides:        katello-devel-jshintrb = 1.2.1-1
Obsoletes:       katello-devel-jshintrb < 1.2.1-1
Requires:        %{name} = %{version}-%{release}
# dependencies from bundler.d/checking.rb
Requires:        rubygem(therubyracer)
Requires:        rubygem(ref)
Requires:        rubygem(jshintrb)

%description devel-checking
Rake tasks and dependecies for Katello developers, which enables
syntax checking and is need for unit testing.

%package devel-coverage
Summary:         Katello devel support (test coverage utils)
BuildArch:       noarch
Requires:        %{name} = %{version}-%{release}
# dependencies from bundler.d/coverage.rb
Requires:        rubygem(simplecov)

%description devel-coverage
Rake tasks and dependecies for Katello developers, which enables
code coverage for tests.

%package devel-debugging
Summary:         Katello devel support (debugging)
BuildArch:       noarch
Requires:        %{name} = %{version}-%{release}
# dependencies from bundler.d/debugging.rb
Requires:        rubygem(ruby-debug19)

%description devel-debugging
Rake tasks and dependecies for Katello developers, which enables
debugging Ruby code.

%package devel-test
Summary:         Katello devel support (testing)
BuildArch:       noarch
Requires:        %{name} = %{version}-%{release}
Requires:        %{name}-devel = %{version}-%{release}
# dependencies from bundler.d/test.rb
Requires:        rubygem(ZenTest) >= 4.4.0
Requires:        rubygem(autotest-rails) >= 4.1.0
Requires:        rubygem(rspec-rails) >= 2.0.0
Requires:        rubygem(webrat) >= 0.7.3
Requires:        rubygem(nokogiri) >= 0.9.9
Requires:        rubygem(vcr)
Requires:        rubygem(webmock)
Requires:        rubygem(minitest) <= 4.5.0
Requires:        rubygem(minitest-rails)
Requires:        rubygem(minitest_tu_shim)
Requires:        rubygem(parallel_tests)

BuildRequires:        rubygem(minitest)
BuildRequires:        rubygem(minitest-rails)
BuildRequires:        rubygem(rspec-rails)

%description devel-test
Rake tasks and dependecies for Katello developers, which enables
testing.

# </devel packages are not SCL enabled yet - not avaiable on SCL platforms>
%endif

%prep
%setup -q

%build
export RAILS_ENV=build

# when running in SCL we do not distribute any devel packages yet
%if %{?scl:1}%{!?scl:0}
    rm -f bundler.d/checking.rb
    rm -f bundler.d/coverage.rb
    rm -f bundler.d/debugging.rb
    rm -f bundler.d/development.rb
    rm -f bundler.d/development_boost.rb
    rm -f bundler.d/optional.rb
    rm -f bundler.d/test.rb
    rm -rf bundler.d/assets.rb
%endif

#replace shebangs for SCL
%if %{?scl:1}%{!?scl:0}
    sed -ri '1sX(/usr/bin/ruby|/usr/bin/env ruby)X%{scl_ruby}X' script/*
%endif

#check for gettext standards (using Ruby 1.8)
/usr/bin/ruby script/check-gettext.rb -m -i

#check and generate gettext MO files
make -C locale check all-mo %{?_smp_mflags}
# | sed -e '/Warning: obsolete msgid exists./,+1d' | sed -e '/Warning: fuzzy message was ignored./,+1d'

#use Bundler_ext instead of Bundler
mv Gemfile Gemfile.in

#pull in branding if present
if [ -d branding ] ; then
  cp -r branding/* .
fi

%if ! 0%{?fastbuild:1}
    #compile SASS files
    echo Compiling Assets...
    mv lib/tasks lib/tasks_disabled
    export BUNDLER_EXT_NOSTRICT=1
    export BUNDLER_EXT_GROUPS="default assets"
    touch config/katello.yml
%{?scl:scl enable %{scl} "}
    rake  assets:precompile:primary --trace RAILS_ENV=production
    rake  assets:precompile:nondigest --trace
%{?scl:"}
    rm config/katello.yml
    mv lib/tasks_disabled lib/tasks
%endif

#man pages
a2x -d manpage -f manpage man/katello-service.8.asciidoc

#api docs
%if ! 0%{?nodoc:1}
    # we need to rename all the extra tasks because we do not have all the dependencies, we
    # don't need them and there is no way to disable this via a rake option
    mv lib/tasks lib/tasks_disabled
    # by default do not stop on missing dep and only require "build" environment
    export BUNDLER_EXT_NOSTRICT=1
    export BUNDLER_EXT_GROUPS="default apipie"
    export RAILS_ENV=production # TODO - this is already defined above!
    touch config/katello.yml
%{?scl:scl enable %{scl} "}
    rake apipie:static apipie:cache --trace
%{?scl:"}

    # API doc for Headpin mode
    echo "common:" > config/katello.yml
    echo "  app_mode: headpin" >> config/katello.yml
%{?scl:scl enable %{scl} "}
    rake apipie:static apipie:cache OUT=doc/headpin-apidoc --trace
%{?scl:"}
    rm config/katello.yml
    mv lib/tasks_disabled lib/tasks
%endif

%install
#prepare dir structure
install -d -m0755 %{buildroot}%{homedir}
install -d -m0755 %{buildroot}%{datadir}
install -d -m0755 %{buildroot}%{datadir}/tmp
install -d -m0755 %{buildroot}%{datadir}/tmp/pids
install -d -m0755 %{buildroot}%{datadir}/config
install -d -m0755 %{buildroot}%{_sysconfdir}/%{name}

install -d -m0755 %{buildroot}%{_localstatedir}/log/%{name}
mkdir -p %{buildroot}/%{_mandir}/man8

# clean the application directory before installing
[ -d tmp ] && rm -rf tmp

# remove build gem group
rm -f bundler.d/build.rb

#copy the application to the target directory
mkdir .bundle
cp -R .bundle Gemfile.in bundler.d Rakefile app autotest ca config config.ru db integration_spec lib public script spec vendor %{buildroot}%{homedir}
rm -f {buildroot}%{homedir}/script/katello-reset-dbs

#copy MO files
pushd locale
for MOFILE in $(find . -name "*.mo"); do
    DIR=$(dirname "$MOFILE")
    install -d -m 0755 %{buildroot}%{_datadir}/katello/locale/$DIR
    install -d -m 0755 %{buildroot}%{_datadir}/katello/locale/$DIR/LC_MESSAGES
    install -m 0644 $DIR/*.mo %{buildroot}%{_datadir}/katello/locale/$DIR/LC_MESSAGES
done
popd

#copy configs and other var files (will be all overwriten with symlinks)
touch %{buildroot}%{_sysconfdir}/%{name}/%{name}.yml
chmod 600 %{buildroot}%{_sysconfdir}/%{name}/%{name}.yml
install -m 644 config/environments/production.rb %{buildroot}%{_sysconfdir}/%{name}/environment.rb

#copy cron scripts to be scheduled daily
install -d -m0755 %{buildroot}%{_sysconfdir}/cron.daily
install -m 755 script/katello-refresh-cdn %{buildroot}%{_sysconfdir}/cron.daily/katello-refresh-cdn

#copy init scripts and sysconfigs
install -Dp -m0644 %{confdir}/%{name}.sysconfig %{buildroot}%{_sysconfdir}/sysconfig/%{name}
install -Dp -m0644 %{confdir}/service-wait.sysconfig %{buildroot}%{_sysconfdir}/sysconfig/service-wait
install -Dp -m0755 %{confdir}/%{name}.init %{buildroot}%{_initddir}/%{name}
install -Dp -m0755 %{confdir}/%{name}-jobs.init %{buildroot}%{_initddir}/%{name}-jobs
install -Dp -m0644 %{confdir}/%{name}.logrotate %{buildroot}%{_sysconfdir}/logrotate.d/%{name}
install -Dp -m0644 %{confdir}/%{name}.httpd.conf %{buildroot}%{_sysconfdir}/httpd/conf.d/%{name}.conf
install -Dp -m0644 %{confdir}/thin.yml %{buildroot}%{_sysconfdir}/%{name}/
install -Dp -m0644 %{confdir}/mapping.yml %{buildroot}%{_sysconfdir}/%{name}/

#overwrite config files with symlinks to /etc/katello
ln -svf %{_sysconfdir}/%{name}/%{name}.yml %{buildroot}%{homedir}/config/%{name}.yml
#ln -svf %{_sysconfdir}/%{name}/database.yml %{buildroot}%{homedir}/config/database.yml
ln -svf %{_sysconfdir}/%{name}/environment.rb %{buildroot}%{homedir}/config/environments/production.rb
install -p -m0644 etc/service-list %{buildroot}%{_sysconfdir}/%{name}/

#create symlinks for some db/ files
ln -svf %{datadir}/schema.rb %{buildroot}%{homedir}/db/schema.rb

#create symlinks for data
ln -sv %{_localstatedir}/log/%{name} %{buildroot}%{homedir}/log
ln -sv %{datadir}/tmp %{buildroot}%{homedir}/tmp

#create symlinks for important scripts
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_sbindir}
ln -sv %{homedir}/script/katello-debug %{buildroot}%{_bindir}/katello-debug
ln -sv %{homedir}/script/katello-generate-passphrase %{buildroot}%{_bindir}/katello-generate-passphrase
ln -sv %{homedir}/script/katello-service %{buildroot}%{_bindir}/katello-service
ln -sv %{homedir}/script/service-wait %{buildroot}%{_sbindir}/service-wait

#re-configure database to the /var/lib/katello directory
sed -Ei 's/\s*database:\s+db\/(.*)$/  database: \/var\/lib\/katello\/\1/g' %{buildroot}%{homedir}/config/database.yml

#remove files which are not needed in the homedir
rm -f %{buildroot}%{homedir}/lib/tasks/.gitkeep
rm -f %{buildroot}%{homedir}/vendor/plugins/.gitkeep

#branding
if [ -d branding ] ; then
  ln -svf %{_datadir}/icons/hicolor/24x24/apps/system-logo-icon.png %{buildroot}%{homedir}/public/images/rh-logo.png
  ln -svf %{_sysconfdir}/favicon.png %{buildroot}%{homedir}/public/images/embed/favicon.png
  rm -rf %{buildroot}%{homedir}/branding
fi

#correct permissions
find %{buildroot}%{homedir} -type d -print0 | xargs -0 chmod 755
find %{buildroot}%{homedir} -type f -print0 | xargs -0 chmod 644
chmod +x %{buildroot}%{homedir}/script/*
chmod a+r %{buildroot}%{homedir}/ca/redhat-uep.pem

# install man page
install -m 644 man/katello-service.8 %{buildroot}/%{_mandir}/man8

%post common

#Add /etc/rc*.d links for the script
/sbin/chkconfig --add %{name}
/sbin/chkconfig --add %{name}-jobs

#Generate secret token if the file does not exist
#(this must be called both for installation and upgrade)
TOKEN=/etc/katello/secret_token
# this file must not be world readable at generation time
umask 0077
test -f $TOKEN || (echo $(</dev/urandom tr -dc A-Za-z0-9 | head -c128) > $TOKEN \
    && chmod 600 $TOKEN && chown katello:katello $TOKEN)

%posttrans common
/sbin/service %{name} condrestart >/dev/null 2>&1 || :

%post headpin-all
usermod -a -G katello-shared tomcat

%post all
usermod -a -G katello-shared tomcat

%files
%attr(600, katello, katello)
%{_bindir}/katello-*
%ghost %attr(600, katello, katello) %{_sysconfdir}/%{name}/secret_token
%dir %{homedir}/app
%{homedir}/app/controllers
%{homedir}/app/helpers
%{homedir}/app/mailers
%dir %{homedir}/app/models
%{homedir}/app/models/*.rb
%{homedir}/app/models/authorization/*.rb
%{homedir}/app/models/candlepin
%{homedir}/app/models/ext
%{homedir}/app/models/roles_permissions
%{homedir}/app/assets/
%{homedir}/app/assets/stylesheets
%{homedir}/app/assets/javascripts
%{homedir}/app/assets/images
%{homedir}/vendor
%{homedir}/vendor/assets
%{homedir}/vendor/assets/stylesheets
%{homedir}/vendor/assets/images
%{homedir}/app/views
%{homedir}/autotest
%{homedir}/ca
%{homedir}/config
%{homedir}/db/migrate/
%{homedir}/db/products.json
%{homedir}/db/seeds.rb
%{homedir}/integration_spec
%{homedir}/lib/*.rb
%{homedir}/lib/katello/
%exclude %{homedir}/lib/README
%{homedir}/app/lib/*.rb
%exclude %{homedir}/app/lib/README
%dir %{homedir}/app/lib/glue
%{homedir}/app/lib/glue/*.rb
%{homedir}/lib/monkeys
%{homedir}/app/lib/navigation
%{homedir}/app/lib/notifications
%{homedir}/app/lib/validators
%{homedir}/app/lib/resources/cdn.rb
%{homedir}/app/lib/content_search
%{homedir}/app/lib/experimental
%{homedir}/lib/tasks
%exclude %{homedir}/lib/tasks/yard.rake
%exclude %{homedir}/lib/tasks/hudson.rake
%exclude %{homedir}/lib/tasks/jsroutes.rake
%exclude %{homedir}/lib/tasks/jshint.rake
%exclude %{homedir}/lib/tasks/test.rake
%exclude %{homedir}/lib/tasks/simplecov.rake
%exclude %{homedir}/script/pulp_integration_tests
%{homedir}/locale
%{homedir}/public
%if ! 0%{?nodoc:1}
%exclude %{homedir}/public/apipie-cache
%endif
%{homedir}/script
%exclude %{homedir}/script/service-wait
%{homedir}/spec
%{homedir}/tmp
%dir %{homedir}/.bundle
%{homedir}/config.ru
%{homedir}/Gemfile.in
%config(noreplace) %{_sysconfdir}/%{name}/service-list
%{homedir}/Rakefile
%{_mandir}/man8/katello-service.8*

%files common
%doc LICENSE.txt
%{_sbindir}/service-wait
%dir %{_sysconfdir}/%{name}
%config(noreplace) %attr(600, katello, katello) %{_sysconfdir}/%{name}/%{name}.yml
%config(noreplace) %{_sysconfdir}/%{name}/thin.yml
%config(noreplace) %{_sysconfdir}/httpd/conf.d/%{name}.conf
%config %{_sysconfdir}/%{name}/environment.rb
%config %{_sysconfdir}/logrotate.d/%{name}
%config %{_sysconfdir}/%{name}/mapping.yml
%config(noreplace) %{_sysconfdir}/sysconfig/%{name}
%config(noreplace) %{_sysconfdir}/sysconfig/service-wait
%{_initddir}/%{name}
%{_initddir}/%{name}-jobs
%{homedir}/log
%dir %{homedir}/db
%{homedir}/db/schema.rb
%dir %{homedir}/lib
%dir %{homedir}/app/lib
%dir %{homedir}/app/lib/resources
%{homedir}/lib/util
%{homedir}/app/lib/util
%{homedir}/script/service-wait

%defattr(-, katello, katello)
%dir %{homedir}
%attr(750, katello, katello) %{_localstatedir}/log/%{name}
%{datadir}
%ghost %attr(640, katello, katello) %{_localstatedir}/log/%{name}/production.log
%ghost %attr(640, katello, katello) %{_localstatedir}/log/%{name}/delayed_production.log

%files glue-elasticsearch
%{homedir}/app/models/glue/elastic_search

%files glue-pulp
%{homedir}/bundler.d/pulp.rb
%{homedir}/app/models/glue/pulp
%config(missingok) %{_sysconfdir}/cron.daily/katello-refresh-cdn

%files glue-candlepin
%{homedir}/app/models/glue/candlepin
%{homedir}/app/models/glue/provider.rb
%{homedir}/app/lib/resources/candlepin.rb

%files all

%files headpin
%attr(600, katello, katello)
%{_bindir}/katello-*
%dir %{homedir}/app
%{homedir}/app/controllers
%{homedir}/app/helpers
%{homedir}/app/mailers
%{homedir}/app/models
%exclude %{homedir}/app/models/glue/*
%exclude %{homedir}/lib/tasks/test.rake
%exclude %{homedir}/lib/tasks/simplecov.rake
%{homedir}/app/assets/
%{homedir}/app/assets/stylesheets
%{homedir}/app/assets/javascripts
%{homedir}/app/assets/images
%{homedir}/vendor
%{homedir}/vendor/assets
%{homedir}/vendor/assets/stylesheets
%{homedir}/vendor/assets/images
%{homedir}/app/views
%{homedir}/autotest
%{homedir}/ca
%{homedir}/config
%{homedir}/db/migrate/
%{homedir}/db/products.json
%{homedir}/db/seeds.rb
%{homedir}/integration_spec
%{homedir}/lib/*.rb
%{homedir}/lib/katello/
%exclude %{homedir}/lib/README
%{homedir}/app/lib/*.rb
%exclude %{homedir}/app/lib/README
%{homedir}/lib/monkeys
%{homedir}/app/lib/navigation
%{homedir}/app/lib/notifications
%{homedir}/app/lib/validators
%exclude %{homedir}/app/lib/resources/candlepin.rb
%{homedir}/lib/tasks
%{homedir}/lib/util
%{homedir}/app/lib/util
%{homedir}/app/lib/glue/queue.rb
%{homedir}/app/lib/glue/task.rb
%{homedir}/locale
%{homedir}/public
%if ! 0%{?nodoc:1}
%exclude %{homedir}/public/apipie-cache
%endif
%{homedir}/script
%{homedir}/spec
%{homedir}/tmp
%{homedir}/vendor
%{homedir}/.bundle
%{homedir}/config.ru
%{homedir}/Gemfile.in
%{homedir}/Rakefile

%files headpin-all

%files api-docs
%if ! 0%{?nodoc:1}
%doc doc/apidoc*
%{homedir}/public/apipie-cache
%endif

%files headpin-api-docs
%if ! 0%{?nodoc:1}
%doc doc/headpin-apidoc*
%{homedir}/public/headpin-apipie-cache
%endif

# <devel packages are not SCL enabled yet - not avaiable on SCL platforms>
%if %{?scl:0}%{!?scl:1}

%files devel-all

%files devel
%{homedir}/bundler.d/development.rb
%{homedir}/bundler.d/assets.rb
%{homedir}/bundler.d/development_boost.rb
%{homedir}/lib/tasks/yard.rake
%{homedir}/lib/tasks/hudson.rake
%{homedir}/lib/tasks/jsroutes.rake

%files devel-profiling
%{homedir}/bundler.d/optional.rb

%files devel-test
%{homedir}/bundler.d/test.rb
%{homedir}/lib/tasks/test.rake
%{homedir}/lib/tasks/simplecov.rake
%{homedir}/script/pulp_integration_tests

%files devel-checking
%{homedir}/bundler.d/checking.rb
%{homedir}/lib/tasks/jshint.rake

%files devel-coverage
%{homedir}/bundler.d/coverage.rb

%files devel-debugging
%{homedir}/bundler.d/debugging.rb

# </devel packages are not SCL enabled yet - not avaiable on SCL platforms>
%endif

%pre common
# Add the "katello" user and group
getent group %{name} >/dev/null || groupadd -r %{name} -g 182
getent passwd %{name} >/dev/null || \
    useradd -r -g %{name} -d %{homedir} -u 182 -s /sbin/nologin -c "Katello" %{name}
# add tomcat & katello to the katello shared group for reading sensitive files
getent group katello-shared > /dev/null || groupadd -r katello-shared
usermod -a -G katello-shared katello
exit 0

%preun common
if [ $1 -eq 0 ] ; then
    /sbin/service %{name}-jobs stop >/dev/null 2>&1
    /sbin/chkconfig --del %{name}-jobs
    /sbin/service %{name} stop >/dev/null 2>&1
    /sbin/chkconfig --del %{name}
fi

%changelog
* Fri May 03 2013 Justin Sherrill <jsherril@redhat.com> 1.3.24-1
- monkey patching multi_json to parse "" as json properly
- fixing package details
- Sync Plans Fixes #2142 - Sync plan name edits weren't updating the tupane
  header or left hand list due to grabbing the wrong property off of a DOM
  element.

* Wed May 01 2013 Justin Sherrill <jsherril@redhat.com> 1.3.23-1
- adding back katelllo 1.3 rel-eng (jsherril@redhat.com)
- 948733 - Worked on content view definition update options
  (daviddavis@redhat.com)
- fixing issue where changeset would say applied when it wasnt finished
- 916164 - Removing old call to default_systems_reg_permission
- fixing content search subgrid links (jsherril@redhat.com)
- 956266 - Fixing bad content views SQL statement (daviddavis@redhat.com)
- 957193 - Fixed a user perm issue where verbs were getting eating
  (paji@redhat.com)
- Automatic commit of package [katello] release [1.3.22-1].
  (jsherril@redhat.com)
- fixing small js mistake
- removing uneeded javascript, which broke manifest import
- Quick fix for master
- Added validators for package and package group rules (paji@redhat.com)
- Fixes #2077 - Since the JSRoutes paths mimic the rails path API in order to
  put a hash parameter, the anchor option needs to be used.
- vcr_cassettes - regenerating cassettes
- runcible - updating spec and bundler.d to use runcible 0.4.3
- pulp - updates to address issues in copy/associate of large repos
  (bbuckingham@redhat.com)
- Promotions - Fixing issue with promotions being uncentered and the New
  Changeset button not working.
- Fixed filters cli to now associate partial products from cvd
  (paji@redhat.com)
- Automatic commit of package [katello] release [1.3.21-1].
  (jsherril@redhat.com)
- Implementation for add/remove filter rules via cli (paji@redhat.com)
- Allowing content views to be deleted from CLI
- content views - minor PR feedback on #1990
- content views - fix test that failed when running entire suite
- content views - ui - add the ability to delete a content view
  (bbuckingham@redhat.com)
- content views - refactor 'refresh' to content views controller
  (bbuckingham@redhat.com)
- Making notification count update when a notice is generated.
- Allowing any HTTP verb to access logout.
- Setting the active menu tab based on location. (walden@redhat.com)
- Experimental Menu - Updating copyright and test files.
- Experimental Menu - Adding missing folder to the spec.
- Menu - Adds support for Experimental UI section which includes the new
  navigation structure in it's current state. (ehelms@redhat.com)
- 952249 - Validating overlapping content in component views
  (daviddavis@redhat.com)
- Moving before_destroy callbacks because of rails/rails#3458
- 953983 - Fixing path to spinner.gif
- Worked on limiting content views on system edit page
- Updated js-routes to work with Rails 3.2
- Made repo clear contents also clear the search indices (paji@redhat.com)
-  953655-Added a search field needed by the content filter 'publish' call
- Querying filters with filter_id rather than filter_name
  (daviddavis@redhat.com)
- fixing re-creation of sync even notifier (jsherril@redhat.com)
- Automatic commit of package [katello] release [1.3.20-1].
  (jsherril@redhat.com)
- equality fix
- 1956 - adding unprotected checkbox to auto-discovery
- Automatic commit of package [katello] release [1.3.19-1].
  (jsherril@redhat.com)
- issue 1998 - add a test to check setting of env + content view
  (bbuckingham@redhat.com)
- issue 1998 - client cannot register to a content view
  (bbuckingham@redhat.com)
- 950539 - Adding content view option to package/errata list
- asset-pipeline - fix for multiselect on various pages
  (bbuckingham@redhat.com)
- 927598 - Remove system template section of promotion page
- Automatic commit of package [katello] release [1.3.18-1].
  (jsherril@redhat.com)
- temporarily disabling errata dashboard widget (jsherril@redhat.com)
- Merge pull request #1989 from jlsherrill/katello_cps (jlsherrill@gmail.com)
- issue 1955 - ui - open filter after create (bbuckingham@redhat.com)
- Asset Pipeline - Fixing mis-included asset edit_helpers.
- issue 1935 - fix promotion failure after view refresh
  (bbuckingham@redhat.com)
- #1963 - return true for index_content so job doesnt fail
- Merge pull request #1988 from mccun934/KATELLO-1.3 (mmccune@gmail.com)
- providers - ui - fix alignment of Add Product button (bbuckingham@redhat.com)
- product - ui - change label assignment notice to be message
  (bbuckingham@redhat.com)
- Worked on the content view options for system and changeset
- Updating issues that came out of errata dates being real dates instead of
  strings
- Asset Pipeline - Fixing issue with loading the treeTable jquery plugin since
  we don't precompile anything from an engine directly.
- Asset Pipeline - Fixing issue with missing gpp_keys JS manifest, bad
  reference to stylesheet inclusion syntax on systems group page and missing
  timpickr CSS.
- update katello-debug to the pulp-v2 configuration file location
- forgot to update the sed paths to clean the passwords
- remove whitespace (jsherril@redhat.com)
- defining repo model in migration
- upgrade fix (jsherril@redhat.com)
- moving prepared statement to be reused
- conflict fix (jsherril@redhat.com)
- whitespace fix
- hardening requirement of bundler_ext
- reseting more column information
- upgrade typo fix, reset column information
- upgrade fixes
- a couple migration fixes
- necessary upgrade changes
- migration fixes
- adding content_id migratino for repositories
- more upgrade fixes
- initial pulpv2 upgrade steps
- Automatic commit of package [katello] release [1.3.17-1].
  (jsherril@redhat.com)
- Merge pull request #1949 from ehelms/spec-fix-assets (ericdhelms@gmail.com)
- Spec - Updating spec to set RAILS_ENV=production on asset compile.
  (ehelms@redhat.com)
- Merge pull request #1948 from jlsherrill/path_selector_fix
  (jlsherrill@gmail.com)
- fixing env selector positioning on a few pages (jsherril@redhat.com)
- changesets - fix to include alchemy sortElement (bbuckingham@redhat.com)
- Automatic commit of package [katello] release [1.3.16-1].
  (jsherril@redhat.com)
- Merge pull request #1944 from bbuckingham/fork-bug_fixes
  (bbuckingham@redhat.com)
- Merge pull request #1943 from jlsherrill/build_fix (jlsherrill@gmail.com)
- Merge pull request #1940 from
  daviddavis/remove_content_views_from_activation_keys (daviddavis@redhat.com)
- content views - minor chgs to views for asset pipeline
  (bbuckingham@redhat.com)
- fix f18 build (jsherril@redhat.com)
- content view - fix issue w/ deleting filters and filter rules
  (bbuckingham@redhat.com)
- 947859 - Created a way to remove views from keys (daviddavis@redhat.com)
- Automatic commit of package [katello] release [1.3.15-1].
  (jsherril@redhat.com)
- Merge pull request #1934 from witlessbird/puppet-seeding
  (witlessbird@gmail.com)
- Merge pull request #1941 from ehelms/asset-pipeline-fixes
  (ericdhelms@gmail.com)
- Merge pull request #1922 from parthaa/date-work (parthaa@gmail.com)
- Merge pull request #1939 from jlsherrill/build_fix (jlsherrill@gmail.com)
- Fixing build for RHEL 6 (jsherril@redhat.com)
- Merge pull request #1904 from daviddavis/pluck_tables (daviddavis@redhat.com)
- Merge pull request #1918 from bbuckingham/content_views-linking
  (bbuckingham@redhat.com)
- Merge pull request #1936 from bbuckingham/fork-content-filters
  (bbuckingham@redhat.com)
- content views - update crosslinking to use hash vs string
  (bbuckingham@redhat.com)
- content views - a crosslinking from view to content search
  (bbuckingham@redhat.com)
- Asset Pipeline - Fixes for bad paths to some image and icon assets.
  (ehelms@redhat.com)
- filter rules - minor change from PR review (bbuckingham@redhat.com)
- content view - ui - allow user to specify version info for pkg filter rule
  (bbuckingham@redhat.com)
- Removed some unnecessary comments (paji@redhat.com)
- Code to get cvd refresh working with filters (paji@redhat.com)
- Follow Fedora guidelines when obsoleting subpackage (inecas@redhat.com)
- Remove Foreman specific code - cli (inecas@redhat.com)
- Remove Foreman specific code - rails (inecas@redhat.com)
- Merge pull request #1913 from thomasmckay/delayedjob-spec
  (thomasmckay@redhat.com)
- Merge pull request #1917 from daviddavis/temp_1365706716
  (daviddavis@redhat.com)
- Merge pull request #1907 from ehelms/asset-pipeline (ericdhelms@gmail.com)
- 947869 - Allowing users to create composite definitions from CLI
  (daviddavis@redhat.com)
- fixed an issue with seeds.rb when it wasn't assigning default values
  (dmitri@appliedlogic.ca)
- Rails32 - Fixing copyright years. (ehelms@redhat.com)
- Fixed a malformed url to keep jenkins happy (paji@redhat.com)
- Added more test cases (paji@redhat.com)
- Added tests for the validator (paji@redhat.com)
- Fixed a bunch of unit tests (paji@redhat.com)
- Added a space as requested in the PR (paji@redhat.com)
- Added code to deal with time zone issues (paji@redhat.com)
- Made the errata rule use real dates instead of string (paji@redhat.com)
- Merge pull request #1882 from parthaa/filters-to-master (parthaa@gmail.com)
- Modified a couple of pluck calls to fix a unit test (paji@redhat.com)
- Merge branch 'master' into filters-to-master (paji@redhat.com)
- Fixed some unit tests (paji@redhat.com)
- Changed Hash#index to Hash#key to remove some warnings (paji@redhat.com)
- replacing 'and' with '&&' (komidore64@gmail.com)
- Merge branch 'master' of github.com:Katello/katello into asset-pipeline
  (ehelms@redhat.com)
- Merge pull request #1906 from daviddavis/temp_1365624433
  (daviddavis@redhat.com)
- Merge branch 'master' into filters-to-master (paji@redhat.com)
- Rails32 - Setting Alchemy Gem version and addressing Ruby code styling
  comments. (ehelms@redhat.com)
- delayedjob-spec - set version for gem delayed_job_active_record delayedjob-
  spec - corrected syntax (thomasmckay@redhat.com)
- Merge pull request #1894 from thomasmckay/manifest-refresh
  (thomasmckay@redhat.com)
- 929106 - Displaying user friendly task not found error
  (daviddavis@redhat.com)
- Adding in table names to pluck to be safe (daviddavis@redhat.com)
- Merge pull request #1911 from daviddavis/temp_1365675606
  (daviddavis@redhat.com)
- Merge pull request #1901 from jlsherrill/logging (jlsherrill@gmail.com)
- Fixing package of content_search classes (daviddavis@redhat.com)
- Removed some white spacing issues (paji@redhat.com)
- Made some changes as suggested in PR 1882 (paji@redhat.com)
- Merge pull request #1903 from jlsherrill/test_fix (jlsherrill@gmail.com)
- fixing trailing whitespace (jsherril@redhat.com)
- fixing intermittent test failures (jsherril@redhat.com)
- Merge pull request #1902 from thomasmckay/delayedjob-gemfile
  (thomasmckay@redhat.com)
- delayedjob-gemfile - lock to lower version of delayed_job_active_record
  (thomasmckay@redhat.com)
- Merge pull request #1851 from jlsherrill/issue_1850 (jlsherrill@gmail.com)
- default logging changes (jsherril@redhat.com)
- Merge pull request #1898 from daviddavis/fix_pluck (daviddavis@redhat.com)
- spec fixes (jsherril@redhat.com)
- Merge pull request #1840 from jlsherrill/content_search
  (jlsherrill@gmail.com)
- Fixing pluck call (daviddavis@redhat.com)
- pull request fixes (jsherril@redhat.com)
- Merge pull request #1893 from daviddavis/fix_cv_readonly_error
  (daviddavis@redhat.com)
- Rails32 - Adds missing declarations to new javascript assets.
  (ehelms@redhat.com)
- Rails32 - Updating spec to move assets:precompile to be after touching the
  config file. (ehelms@redhat.com)
- manifest-refresh - changes related to refreshing manifest manifest-refresh -
  updates to distributors manifest-refresh - pylint cleaning
  (thomasmckay@redhat.com)
- Addressed some of the issues suggested in PR 1882 (paji@redhat.com)
- Removing backport of pluck (daviddavis@redhat.com)
- adding ability to enable http publishing on a per-repo basis
  (jsherril@redhat.com)
- Content Views: fixing promote readonly error (daviddavis@redhat.com)
- Merge branch 'master' of https://github.com/Katello/katello into issue_1850
  (jsherril@redhat.com)
- Rails32 - Changing URL of images in stylesheets and moving section
  stylesheets out of sections/ directory to make references to image urls more
  uniform.  Includes spec updates for packages required to perform assets
  pipeline. (ehelms@redhat.com)
- System groups: allow users to update systems via CLI (daviddavis@redhat.com)
- Merge pull request #1889 from ehelms/delayed_jobs_fix (ericdhelms@gmail.com)
- Fixing delayed_job breakages due to upgrade (daviddavis@redhat.com)
- Merge pull request #1749 from iNecas/headpin-abstract-model
  (inecas@redhat.com)
- Merge pull request #1883 from ehelms/removing-todos (ericdhelms@gmail.com)
- delayed jobs use active_record as backend (msuchy@redhat.com)
- Merge branch 'master' of github.com:Katello/katello into asset-pipeline
  (ehelms@redhat.com)
- Delayed Jobs - Fixes an issue with the update to delayed jobs 3.0 where
  to_yaml was being called on the target of AsyncOperation and not the
  AsyncOperation itself. (ehelms@redhat.com)
- Comps - Adding delayed_job_active_record needed to properly hook up the
  active_record backend to delayed_job > 3.0. (ehelms@redhat.com)
- Fixed a typo (paji@redhat.com)
- fixing rubygem(foreman-katello-engine) requires (jsherril@redhat.com)
- Removed an unnecessary requires (paji@redhat.com)
- Updated copyright notice (paji@redhat.com)
- Added some documentation for the diff_hash_params method (paji@redhat.com)
- Made some fixes as suggested in the PR (paji@redhat.com)
- Corrected a typo from rebase time (paji@redhat.com)
- Reverted back an old commit since use_pulp is always false in tests
  (paji@redhat.com)
- Changed katello to use_pulp since runcible only makes sense if you are using
  pulp (paji@redhat.com)
- Fixed a test to make travis happy (paji@redhat.com)
- Temporary fix to make travis point real errors (paji@redhat.com)
- Added some validation for parameters in the various models (paji@redhat.com)
- Fixed another unit test (paji@redhat.com)
- Added some unit test fixes to work with the new model (paji@redhat.com)
- Broke up gigantic filter rules class into 3 smaller more manageable classes
  (paji@redhat.com)
- Fixed some unit tests (paji@redhat.com)
- Refactored some code for better organization (paji@redhat.com)
- Removed trailing space (paji@redhat.com)
- Fixed some parens issues (paji@redhat.com)
- Fixed a couple of unit tests to aid with the publish process
  (paji@redhat.com)
- Made the publish handle empty errata ids in rules (paji@redhat.com)
- Made the publish handle empty package rules (paji@redhat.com)
- Added severity params to errata (paji@redhat.com)
- Forgot to move a method used by generate_clause method (paji@redhat.com)
- Made some mods as suggested in PR 1826 (paji@redhat.com)
- Changed the cvd to use elastics search format for package and package group
  filters (paji@redhat.com)
- Added a default search field param to enable one to choose diff defaults
  (paji@redhat.com)
- Made some modifications for PackageGroupSearch (paji@redhat.com)
- Added code to intergrate the package group to the cvd publish
  (paji@redhat.com)
- Added infrastructure for package groups index and search (paji@redhat.com)
- Moved the index_package and errata calls to a single method (paji@redhat.com)
- Removed unused comments (paji@redhat.com)
- Fixed a couple of unit tests to make travis happy (paji@redhat.com)
- Added tests for the errata and package_group publishes (paji@redhat.com)
- Added version compare facility for package rules (paji@redhat.com)
- Code to incorporate filters while publishing CVD (paji@redhat.com)
- Merge pull request #1868 from bbuckingham/fork-system_groups
  (bbuckingham@redhat.com)
- Merge branch 'master' into master-to-filters (paji@redhat.com)
- Merge pull request #1872 from daviddavis/rails32_deprecations
  (daviddavis@redhat.com)
- Merge pull request #1847 from bbuckingham/fork-content-filters
  (bbuckingham@redhat.com)
- remove empty line to make someone happy... (bbuckingham@redhat.com)
- Fixing Rails 3.2 deprecations (daviddavis@redhat.com)
- Rails32 - Cleaning up TODOs from the 3.0-3.2 bridge. (ehelms@redhat.com)
- Merge pull request #1862 from jlsherrill/copyright (jlsherrill@gmail.com)
- Merge pull request #1871 from xsuchy/pull-req-Gemfile32 (miroslav@suchy.cz)
- Merge pull request #1866 from komidore64/more_custom_info
  (komidore64@gmail.com)
- content views - minor updates based on PR 1847 comments
  (bbuckingham@redhat.com)
- merge conflict (jsherril@redhat.com)
- lower rails requirement and use ~> operator (msuchy@redhat.com)
- mv Gemfile32 Gemfile; rm Gemfile; And remove conditions for Fedora 16 and 17
  (msuchy@redhat.com)
- comment could not be on line with requires (msuchy@redhat.com)
- Merge pull request #1854 from daviddavis/rm_18_code (miroslav@suchy.cz)
- Fix dependency on a JavaScript engine (inecas@redhat.com)
- Rails32 - Updating to fence off minitest task in production.
  (ehelms@redhat.com)
- Rails32 - Fixing a few asset url paths. (ehelms@redhat.com)
- Merge pull request #1863 from jlsherrill/translations (miroslav@suchy.cz)
- Merge pull request #1855 from lzap/turn-on-scl (miroslav@suchy.cz)
- Rails32 - Removing compass compile from Travis. (ehelms@redhat.com)
- Rails32 - Committing some fixes for missing assets and bad paths.
  (ehelms@redhat.com)
- Rails32 - Removes Alchemy as a submodule. (ehelms@redhat.com)
- Rails32 - Moves javascript to asset pipeline, adjusts views to account for
  new manifest files. (ehelms@redhat.com)
- system groups - add test for handling edit on selected systems
  (bbuckingham@redhat.com)
- Rails32 - Converting views over to use the Alchemy engine views.
  (ehelms@redhat.com)
- system groups - allow user to change env/view for selected systems
  (bbuckingham@redhat.com)
- Rails32 - removing public/stylesheets (ehelms@redhat.com)
- Rails32 - Moves images and stylesheets to the assets pipeline.
  (ehelms@redhat.com)
- apply_to_all for default_info (komidore64@gmail.com)
- Merge pull request #1846 from komidore64/default_info (komidore64@gmail.com)
- Translations - Update .po and .pot files for katello. (jsherril@redhat.com)
- Translations - Download translations from Transifex for katello.
  (jsherril@redhat.com)
- copyright update (jsherril@redhat.com)
- happy tests (komidore64@gmail.com)
- content views - fix tests failing after adding a render of js partial
  (bbuckingham@redhat.com)
- Merge remote-tracking branch 'upstream/master' into content-filters
  (daviddavis@redhat.com)
- Merge pull request #1843 from daviddavis/cv_cli_copy (daviddavis@redhat.com)
- Content Views: allow definitions to be cloned from CLI
  (daviddavis@redhat.com)
- Removing Ruby 1.8 specific code (daviddavis@redhat.com)
- enabling SCL for katello (lzap+git@redhat.com)
- content views - after filter rule created, open the rule for edit
  (bbuckingham@redhat.com)
- fixes #1850 - auto-publish to http and https (jsherril@redhat.com)
- using lambda to render content search hover, so extra cells arent rendered
  (jsherril@redhat.com)
- trimming fields requested in package search for speed (jsherril@redhat.com)
- jeditable datepicker - allow the user to clear the date
  (bbuckingham@redhat.com)
- content views - changing from has_key to blank on several hash checks
  (bbuckingham@redhat.com)
- content_views - test fix (bbuckingham@redhat.com)
- content views - minor change to address a jeditable initialize issue
  (bbuckingham@redhat.com)
- press enter when either custom_info field is in focus to submit the creation.
  (komidore64@gmail.com)
- cli now correctly allows you to add custom_info without including a value
  (komidore64@gmail.com)
- content views - add 'summary' info to filter rule list
  (bbuckingham@redhat.com)
- fixing unpromoted library repos not showing up in
  content_view#all_version_library_instances (jsherril@redhat.com)
- minitest fix (jsherril@redhat.com)
- Merge pull request #1842 from jlsherrill/jserror (jlsherrill@gmail.com)
- Merge pull request #1838 from witlessbird/fix-readonlyrecord-exception
  (witlessbird@gmail.com)
- Merge pull request #1731 from witlessbird/session-timeout
  (witlessbird@gmail.com)
- content views - update the include/exlude to be similar to new mockups
  (bbuckingham@redhat.com)
- #1798 - fixing javascript error on promotions page (jsherril@redhat.com)
- removed trailing spaces (dmitri@appliedlogic.ca)
- content views - minimize js initialization and fix for jeditable js error
  (bbuckingham@redhat.com)
- content views - ui - hide the filter tabs until they are initialized
  (bbuckingham@redhat.com)
- merge conflict fix (jsherril@redhat.com)
- Merge remote-tracking branch 'upstream/master' into fork-content-
  filters_merge (bbuckingham@redhat.com)
- Merge pull request #1831 from jlsherrill/content_search_spec
  (jlsherrill@gmail.com)
- removing uneeded dir entry from spec (jsherril@redhat.com)
- adding back correct repo hover links (jsherril@redhat.com)
- Merge pull request #1837 from bbuckingham/fork-content_view_groups
  (bbuckingham@redhat.com)
- spec fixes (jsherril@redhat.com)
- lots of small content search/content view fixes (jsherril@redhat.com)
- index content view repositories after promotion (jsherril@redhat.com)
- adding candlepin environment.all for easier debugging (jsherril@redhat.com)
- system groups - address style comments from pull request 1837 review
  (bbuckingham@redhat.com)
- fixed a ActiveRecord::ReadOnlyRecord error occuring during the migration when
  rails 3.2 is used and there's existing data in the db.
  (dmitri@appliedlogic.ca)
- fixed test/lib/url_constrained_cookie_store_test.rb that was failing on rails
  3.2 (dmitri@appliedlogic.ca)
- Merge pull request #1834 from komidore64/default_info (komidore64@gmail.com)
- system groups - ui - allow user to change env/view for systems in a group
  (bbuckingham@redhat.com)
- activation keys - test fix (bbuckingham@redhat.com)
- ctivation keys / systems - mv i18n.update_view to _common_i18n partial
  (bbuckingham@redhat.com)
- activation keys / systems - minor refactor to allow for reuse on system
  groups (bbuckingham@redhat.com)
- system groups - update system's list to include env and view
  (bbuckingham@redhat.com)
- Merge pull request #1836 from iNecas/bz/903388 (inecas@redhat.com)
- 903388 - fix service-wait script (inecas@redhat.com)
- Merge pull request #1833 from komidore64/headpin-menu-fix
  (komidore64@gmail.com)
- session timeout is now working under Rails 3.0.x (dmitri@appliedlogic.ca)
- updated to work with Rails > 3.2 (dmitri@appliedlogic.ca)
- fixed failing test (dmitri@appliedlogic.ca)
- fixes based on comments in the PR (dmitri@appliedlogic.ca)
- moved tests to a more visible spot in the test suite (dmitri@appliedlogic.ca)
- removed a trailing space (dmitri@appliedlogic.ca)
- added comment in session_store initializer pointing to environment-specific
  initializers instead. (dmitri@appliedlogic.ca)
- added a comment re: Katello::UrlConstrainedCookieStore#call origins
  (dmitri@appliedlogic.ca)
- support for selective (based on url accessed) expiration of cookies
  (dmitri@appliedlogic.ca)
- set a 1 hour expiration on the http session (dmitri@redhat.com)
- Merge pull request #1810 from xsuchy/pull-req-old-changelog
  (miroslav@suchy.cz)
- custom_info in the UI is now using the API (komidore64@gmail.com)
- fixing content view comparison and making it faster (jsherril@redhat.com)
- synchronization page was not correctly fenced in headpin mode
  (komidore64@gmail.com)
- Content views: fixing api doc and perms in several places
  (daviddavis@redhat.com)
- making header height allow 3 lines instead of 2 for view-repo comparison
  (jsherril@redhat.com)
- adding content search models to spec file (jsherril@redhat.com)
- Merge pull request #1820 from daviddavis/filters-cli (daviddavis@redhat.com)
- Merge pull request #1824 from thomasmckay/manifest-async
  (thomasmckay@redhat.com)
- Content view: Addressed feedback for filters (daviddavis@redhat.com)
- Merge pull request #1828 from iNecas/katello-configure-foreman-engine
  (inecas@redhat.com)
- Merge pull request #1814 from bbuckingham/fork-content-filters
  (bbuckingham@redhat.com)
- a few fixes for content search (jsherril@redhat.com)
- Merge pull request #1823 from komidore64/default_info (komidore64@gmail.com)
- katello-configure - install and set up foreman-katello-engine
  (inecas@redhat.com)
- content search - fixing packages & errata search for content views
  (jsherril@redhat.com)
- Content views: backing up filters with definition archives
  (daviddavis@redhat.com)
- content views - fix test failing in rails32 (bbuckingham@redhat.com)
- Merge pull request #1822 from daviddavis/1819 (daviddavis@redhat.com)
- default info in the UI for systems (komidore64@gmail.com)
- fixing CV, product, & repo intersection and difference searches
  (jsherril@redhat.com)
- content views - ui - address test failures during rails32 and ruby193
  (bbuckingham@redhat.com)
- manifest-async - db:migrate (thomasmckay@redhat.com)
- manifest-async - switch to async job on server for CLI/api manifest import
  (thomasmckay@redhat.com)
- adding blankness validation for organization default info
  (komidore64@gmail.com)
- adding api routes to routes.js (komidore64@gmail.com)
- fixing some funky indentation, formatting, and whitespace
  (komidore64@gmail.com)
- content views - ui tests - chgs to address issues when running all
  (bbuckingham@redhat.com)
- Fixed bad check for undefined in javascript. Fixes #1819
  (daviddavis@redhat.com)
- conflict fix (jsherril@redhat.com)
- content views - ui - add permission tests for filters and filter rules
  controllers (bbuckingham@redhat.com)
- content views - ui - adding tests for filters and filter rules controllers
  (bbuckingham@redhat.com)
- Fixing places that call RAILS_ROOT (daviddavis@redhat.com)
- Added code to associate product/repos to a filter (paji@redhat.com)
- Merged content_view_definition_base with filters (daviddavis@redhat.com)
- Merge pull request #1811 from bbuckingham/fork-content_views_bugs
  (bbuckingham@redhat.com)
- content views - fix a test and update a test (bbuckingham@redhat.com)
- Merge remote-tracking branch 'upstream/master' into content-filters
  (daviddavis@redhat.com)
- Merge pull request #1808 from daviddavis/rm_test_helper
  (daviddavis@redhat.com)
- Merge pull request #1801 from daviddavis/cv_copy (daviddavis@redhat.com)
- content views - fix couple of bugs affecting publish/refresh/promote/consume
  (bbuckingham@redhat.com)
- remove old changelog entries (msuchy@redhat.com)
- Spec - Removing the simplecov development task from the production RPM.
  (ehelms@redhat.com)
- Remove unused file (daviddavis@redhat.com)
- Merge pull request #1805 from ehelms/spec-update (ericdhelms@gmail.com)
- Spec - Adding requires on Apache 2.4.4 on Fedora 18. (ehelms@redhat.com)
- Content views: archiving content defintions (daviddavis@redhat.com)
- Merge pull request #1784 from iNecas/foreman-katello-plugin-support
  (inecas@redhat.com)
- Merge pull request #1780 from komidore64/default_info_dupe
  (thomasmckay@redhat.com)
- cassette update (jsherril@redhat.com)
- bumping runcible requirement (jsherril@redhat.com)
- asdf (jsherril@redhat.com)
- jeditable - update to trim datepicker content and reset data on options
  (bbuckingham@redhat.com)
- content views - addressing PR 1794 comments (bbuckingham@redhat.com)
- content views - filters - ui - changes for filter rules (pkg, pkg group and
  errata) (bbuckingham@redhat.com)
- jeditable - minor refactoring and addition of multiselect type
  (bbuckingham@redhat.com)
- jeditable - move date/time picker to helper (bbuckingham@redhat.com)
- content views - update ui-tabs-panel to handle overflow
  (bbuckingham@redhat.com)
- content_views - filters - ui - add support for package rule and misc chgs
  (bbuckingham@redhat.com)
- content views - filters - ui - add ability to associate prod/repos w/ filter
  (bbuckingham@redhat.com)
- content views - filters - ui - add ability to create/view/delete rules
  (bbuckingham@redhat.com)
- content views - filters - ui - add ability to create/view/delete filters
  (bbuckingham@redhat.com)
- panel - allow user to specify url after subpanel submit
  (bbuckingham@redhat.com)
- Fixing output from rpm ruport check (daviddavis@redhat.com)
- removing file not meant to have been checked in (jsherril@redhat.com)
- Merge pull request #1773 from jlsherrill/default_view_change
  (jlsherrill@gmail.com)
- conflict fix (jsherril@redhat.com)
- product and repo search now all include views (jsherril@redhat.com)
- test fixes (jsherril@redhat.com)
- fixture update... yet... again (jsherril@redhat.com)
- adding addition ktenvironment tests (jsherril@redhat.com)
- Commented out tests that would be worked on later (paji@redhat.com)
- Merge pull request #1778 from lzap/i18n-cleanup (lzap@redhat.com)
- Include candlepin info about pools in activation keys details
  (inecas@redhat.com)
- i18n - modifying SPEC file to genreate MO files (lzap+git@redhat.com)
- Make oauth working (inecas@redhat.com)
- Merge pull request #1774 from daviddavis/norpm (daviddavis@redhat.com)
- Merge pull request #1775 from daviddavis/rm_system_templates
  (daviddavis@redhat.com)
- Merge pull request #1766 from lzap/resource-perm-removal (lzap@redhat.com)
- vcr update... again (jsherril@redhat.com)
- test fix (jsherril@redhat.com)
- merge conflict fix (jsherril@redhat.com)
- test fixes (jsherril@redhat.com)
- fixing mode (jsherril@redhat.com)
- Fixed based on suggestions from PR 1751 (paji@redhat.com)
- Content views: fixed double included (daviddavis@redhat.com)
- Silencing 'rpm not found' errors (daviddavis@redhat.com)
- super happy tests (komidore64@gmail.com)
- Updated apipie examples (daviddavis@redhat.com)
- adding oddly missing migration (jsherril@redhat.com)
- fixing space issues (jsherril@redhat.com)
- content search - adding views to repo search (jsherril@redhat.com)
- 923112 - Katello Nightly : Add,Apply.Remove default custom info keynames for
  subscriptions that are set at the organization level failed via Cli
- Removing system template code (daviddavis@redhat.com)
- making tests happy (komidore64@gmail.com)
- Merge branch 'default_view_change' of github.com:jlsherrill/katello into
  content_search (jsherril@redhat.com)
- fixing methods that were moved (jsherril@redhat.com)
- merge conflict fix (jsherril@redhat.com)
- Merge branch 'default_view_change' of github.com:jlsherrill/katello into
  content_search (jsherril@redhat.com)
- test fixes (jsherril@redhat.com)
- 896147 - Notify user of keyname presence when adding default_system_info to
  an org (komidore64@gmail.com)
- i18n - enabling mo for katello fast_gettext (lzap+git@redhat.com)
- Merge pull request #1771 from ehelms/rails32-fixes (ericdhelms@gmail.com)
- i18n - adding locale/Makefile for MO generation (lzap+git@redhat.com)
- renaming gettext app domain from app to katello (lzap+git@redhat.com)
- content views - migrating default content view structure
  (jsherril@redhat.com)
- fixes #1761 (komidore64@gmail.com)
- one more fix to temp disable SCL (lzap+git@redhat.com)
- removing dead code - ResourcePermissions (lzap+git@redhat.com)
- disabling scl for rhel6 temporary (lzap+git@redhat.com)
- Merge pull request #1742 from iNecas/nowrap-nav (inecas@redhat.com)
- Merge pull request #1762 from thomasmckay/busted-new-org
  (thomasmckay@redhat.com)
- Merge pull request #1763 from lzap/scl-katello (lzap@redhat.com)
- busted-new-org - accidental removal of opening new org panel
  (thomasmckay@redhat.com)
- spec - enabling scl for rhel6 - fixing F18 (lzap@redhat.com)
- Merge pull request #1755 from thomasmckay/relax-org-name
  (thomasmckay@redhat.com)
- relax-org-name - only block <, >, and / in org names (thomasmckay@redhat.com)
- content views - initial work to show CVs on product search
  (jsherril@redhat.com)
- Merge pull request #1760 from lzap/scl-katello (miroslav@suchy.cz)
- Merge pull request #1759 from daviddavis/font404 (daviddavis@redhat.com)
- spec - enabling scl for rhel6 - fixing F18 (lzap@redhat.com)
- 915289 - Fixing missing fonts (daviddavis@redhat.com)
- spec - enabling scl for rhel6 (lzap+git@redhat.com)
- spec - sorting, cleaning and indenting (lzap+git@redhat.com)
- Do not use two %%s in translation string (msuchy@redhat.com)
- Rails32 - Adding password except to json output of compute resource.
  (ehelms@redhat.com)
- Rails32 - Adding two calls to retrieve a content view version to prevent an
  ActiveRecord:ReadOnly error from being thrown. (ehelms@redhat.com)
- Rails32 - Updates use of ActiveSupport::Concern to remove deprecation
  warnings around use of InstanceMethods. (ehelms@redhat.com)
- Rails32 - Fixes glue layer tests that needed to reload EnvironmentProducts.
  (ehelms@redhat.com)
- Rails32 - Adds conditionals to use a set BUNDLE_GEMFILE environment variable
  or punt back to the basic Gemfile.  This is needed for testing both stacks on
  Travis and in the future any separate Gemfiles. (ehelms@redhat.com)
- Merge branch 'master', remote-tracking branch 'katello' into rails32-fixes
  (ehelms@redhat.com)
- Rails32 - Attempting to fix json error output. (ehelms@redhat.com)
- Merge pull request #1753 from ehelms/minor-ui-fixes (ericdhelms@gmail.com)
- Content Search: filtering views by search mode (daviddavis@redhat.com)
- Content Search: fixes to existing code (daviddavis@redhat.com)
- Content Search: showing cv filter for package search (daviddavis@redhat.com)
- Content Search: tweaked product row in cv comparison (daviddavis@redhat.com)
- Content search: fixed search modes for cv comparison (daviddavis@redhat.com)
- Content Search: not displaying total packages per product on cv comparison
  (daviddavis@redhat.com)
- Content Search: moving files to app/lib (daviddavis@redhat.com)
- Content search: Fixing product_repos method name (daviddavis@redhat.com)
- Content search: added pagination to content view comparison
  (daviddavis@redhat.com)
- Content search: fixed link and removed duplicate code (daviddavis@redhat.com)
- Content Search: Fixed metadata row in view comparison (daviddavis@redhat.com)
- Content Search: refactored code by creating module namespaces
  (daviddavis@redhat.com)
- Content Search: Refactored content view comparison (daviddavis@redhat.com)
- Content Search: created a content view comparison (daviddavis@redhat.com)
- Worked on content view search (daviddavis@redhat.com)
- Merge pull request #1743 from iNecas/default-content-view-dependent-destroy
  (inecas@redhat.com)
- Removed an unused method and fixed a validation issue with filters
  (paji@redhat.com)
- Fixed a couple of previously commented tests (paji@redhat.com)
- Rails32 - Changes simple_crud_controller tests to turn data into json using
  as_json similar to the controllers themselves. (ehelms@redhat.com)
- Rails32 - Switching to be_json matcher for some tests. (ehelms@redhat.com)
- Merge pull request #1704 from thomasmckay/906859-import-messages
  (thomasmckay@redhat.com)
- Rails32 - Adding check for secure token and Rails 32. (ehelms@redhat.com)
- Move abstract model to katello-common package (inecas@redhat.com)
- Destroy default content view on cascade when deleting environment
  (inecas@redhat.com)
- merging all .gitignores into one (lzap+git@redhat.com)
- Small test fix with the hope that it'll make travis happy (paji@redhat.com)
- Made some modifications on the unit test as suggested in PR 1746
  (paji@redhat.com)
- Removing commented code (paji@redhat.com)
- Added tests to check the new age params (paji@redhat.com)
- Merge pull request #1744 from daviddavis/removing_more_gems
  (daviddavis@redhat.com)
- Changed filter rule parameter conventions (paji@redhat.com)
- Created optional gem group for profiling gems (daviddavis@redhat.com)
- Merge branch 'master' into master-to-content (paji@redhat.com)
- Merge branch 'content-filters' into master-to-content (paji@redhat.com)
- Created a newrelic option in the configuration (daviddavis@redhat.com)
- Merge pull request #1717 from pitr-ch/bug/#1711 (kontakt@pitr.ch)
- Merge pull request #1724 from komidore64/dumb-warning (komidore64@gmail.com)
- getting rid of that pesky deprecated message (komidore64@gmail.com)
- Removing logical-insight (daviddavis@redhat.com)
- Removed comment about webrat (daviddavis@redhat.com)
- fix headpin build #1711 (pchalupa@redhat.com)
- Merge pull request #1729 from pitr-ch/story/sso (daviddavis@redhat.com)
- disconnected - adding i18n and refactoring (lzap+git@redhat.com)
- fix travis tests (pchalupa@redhat.com)
- Never warp navigation items (inecas@redhat.com)
- Commented out a couple of tests who would be acted upon later
  (paji@redhat.com)
- Renamed the repos method to applicable_repos based on suggestions in PR 1725
  (paji@redhat.com)
- Added code address remove/validation logic as recommended in pr 1725
  (paji@redhat.com)
- Rails32 - Fixing some unit tests that broke under Rails32.
  (ehelms@redhat.com)
- added a warning to comments around 'require 'glue'' in lib/glue/queue.rb
  (dmitri@appliedlogic.ca)
- force loading of glue module before defining of any other modules in Glue
  namespace (dmitri@appliedlogic.ca)
- Rails32 - Updating Travis to actually run against the 3.2 gemfile and adding
  missing logging gem. (ehelms@redhat.com)
- LookNFeel - Minor style updates to the shell. (ehelms@redhat.com)
- Merge branch 'master' into master-to-content (paji@redhat.com)
- Fixed some typos in my previous (paji@redhat.com)
- Made a couple changes related to the comments in PR 1725 (paji@redhat.com)
- Merge pull request #1716 from komidore64/custom-info (komidore64@gmail.com)
- remove katello.template.yml (pchalupa@redhat.com)
- Merge pull request #1697 from bbuckingham/fork-content_views_dashboard
  (bbuckingham@redhat.com)
- Merge pull request #1710 from lzap/debug-iptableas (lzap@redhat.com)
- Merge pull request #1722 from daviddavis/1721 (daviddavis@redhat.com)
- Minor tweak to repository object to just return product_id (paji@redhat.com)
- Added unit tests to check for the association (paji@redhat.com)
- Merge pull request #1723 from ehelms/issue-1658 (ericdhelms@gmail.com)
- Added filter association to products (paji@redhat.com)
- Fixes #1658 - Removes all user notifications regarding login due to
  redundancy and adds a helptip style message on the dashboard for users
  without access to any organizations to let them know what their next steps
  are. (ehelms@redhat.com)
- Merge pull request #1719 from omaciel/standardlabelnotif
  (omaciel@ogmaciel.com)
- Showing invalid label as error not exception. Fixes #1721
  (daviddavis@redhat.com)
- Merge pull request #1688 from daviddavis/flv (daviddavis@redhat.com)
- Standardizing notification message for re-using Labels. Fixes #1718
  (ogmaciel@gnome.org)
- large refactor of organization level default system info keys
  (komidore64@gmail.com)
- Merge pull request #1715 from ehelms/system-index-elasticsearch
  (ericdhelms@gmail.com)
- API - Updating API sytems controller spec tests. (ehelms@redhat.com)
- Merge pull request #1681 from jlsherrill/delete_changeset_test
  (jlsherrill@gmail.com)
- fixing unit tests (jsherril@redhat.com)
- Switch assert equals ordering as suggested int he PR comments
  (paji@redhat.com)
- Aligned the values in the yml to match other ymls (paji@redhat.com)
- Fixed the repository sets controller test (paji@redhat.com)
- Moved the base tests to fixtures instead of FactoryGirl as recommended
  (paji@redhat.com)
- API - Updating documentation and cleaning whitesapce. (ehelms@redhat.com)
- API - Moves the Elasticsearch items query to be a class and changes Systems
  index API to it's use.  Adds a paged and page_size option for the UI to use
  and maintain the current standard of returning all results for API calls.
  (ehelms@redhat.com)
- Merge branch 'master', remote-tracking branch 'origin' into
  delete_changeset_test (jsherril@redhat.com)
- Made the asserts clearer based on the suggestions provided inPR 1713
  (paji@redhat.com)
- removed white spaces (paji@redhat.com)
- Added tests related to filter_controller
- API - Moving Systems index API controller to using Elasticsearch.
  (ehelms@redhat.com)
- Removing a trailing white space (paji@redhat.com)
- Addded minitests  for filter model (paji@redhat.com)
- Merge pull request #1709 from thomasmckay/headpin-travis
  (thomasmckay@redhat.com)
- adding headpin tests to travis (komidore64@gmail.com)
- Updated copyright years (paji@redhat.com)
- Merge pull request #1689 from ehelms/api-session-auth (ericdhelms@gmail.com)
- Merge pull request #1703 from pitr-ch/story/sso (kontakt@pitr.ch)
- adding iptables -L output to the katello-debug (lzap+git@redhat.com)
- move Configuration to Katello namespace (pchalupa@redhat.com)
- separate reusable parts of katello configuration (pchalupa@redhat.com)
- Removed trailing spaces (paji@redhat.com)
- Removed some trailing spaces in both py and rb files (paji@redhat.com)
- removed unnecessary to_json calls as suggested in PR 1708 (paji@redhat.com)
- Filter model tweaks based on PR suggestions (paji@redhat.com)
- Label validator unit tests (daviddavis@redhat.com)
- Merge pull request #1701 from lzap/system-name-length-917033
  (lzap@redhat.com)
- Intial commit of filters functionality (paji@redhat.com)
- Fixing schema.rb (daviddavis@redhat.com)
- 906859-import-messages - cleaned up error messages for both import and delete
  manifest (thomasmckay@redhat.com)
- Setup simplecov in katello (daviddavis@redhat.com)
- 917033 - setting maximum length for system name to 250 (lzap+git@redhat.com)
- Merge branch 'master' into tdd/lib_reorganization (pchalupa@redhat.com)
- content views - haml for dashboard portlet (bbuckingham@redhat.com)
- content views - add a portlet to the dashboard for content views
  (bbuckingham@redhat.com)
- content views - support retrieving 'readable' versions
  (bbuckingham@redhat.com)
- Fixing undefined method index errors (daviddavis@redhat.com)
- Merge pull request #1685 from lzap/dis2 (lzap@redhat.com)
- Merge pull request #1693 from ares/feature/logging (ares@igloonet.cz)
- Add logging as build dependency (mhulan@redhat.com)
- Merge pull request #1653 from ares/feature/logging (ares@igloonet.cz)
- Authentication - Enables session based authentication to the API controllers.
  (ehelms@redhat.com)
- Merge pull request #1686 from pitr-ch/tdd/foreman-timeouts (kontakt@pitr.ch)
- packaging fix (pchalupa@redhat.com)
- Merge branch 'master' into tdd/lib_reorganization (pchalupa@redhat.com)
- Merge pull request #1659 from bbuckingham/fork_composite_views
  (bbuckingham@redhat.com)
- Merge pull request #1680 from bbuckingham/fork_content_view_tests
  (bbuckingham@redhat.com)
- Merge pull request #1678 from daviddavis/cs_refactor (daviddavis@redhat.com)
- Fixed label validator (daviddavis@redhat.com)
- Merge pull request #1674 from ares/tdd/remove_spec_warnings
  (ares@igloonet.cz)
- Merge pull request #1675 from ares/tdd/ping_test_fix (ares@igloonet.cz)
- Merge branch 'master' into tdd/lib_reorganization (pchalupa@redhat.com)
- Moved shared content view and product code out (daviddavis@redhat.com)
- fix missing timeout option passing to foreman_api (pchalupa@redhat.com)
- lib/util cleanup (pchalupa@redhat.com)
- Merge pull request #1669 from pitr-ch/tdd/remove_old_fixme (kontakt@pitr.ch)
- Organize lib files (pchalupa@redhat.com)
- Merge pull request #1673 from ares/tdd/system_templates_specs
  (ares@igloonet.cz)
- diconnected - pulp v2 initial support (lzap+git@redhat.com)
- Removed unnecessary require (mhulan@redhat.com)
- log each test's name (pchalupa@redhat.com)
- add support for tailing external log files (pchalupa@redhat.com)
- Better stubbing to fix specs (ares@igloonet.cz)
- Fix for TaskStatus callback (ares@igloonet.cz)
- New log files structure (ares@igloonet.cz)
- Be more tolerant about log path (ares@igloonet.cz)
- Changes of default values (ares@igloonet.cz)
- Fix for Ruby 1.8 (ares@igloonet.cz)
- Add logging dependency (ares@igloonet.cz)
- simplify #configure_children_loggers method (pchalupa@redhat.com)
- add YARD log support (pchalupa@redhat.com)
- pull out configuration post_process down same as validation definition
  (pchalupa@redhat.com)
- do not align logger names (pchalupa@redhat.com)
- Changed default settings (ares@igloonet.cz)
- Fix specs with new logging gem (ares@igloonet.cz)
- Logging configuration validation (ares@igloonet.cz)
- Move logging configuration to defaults (ares@igloonet.cz)
- Configuration cleanup (ares@igloonet.cz)
- Multiline log messages indentation (ares@igloonet.cz)
- use same format for stdout appender as for development.log
  (pchalupa@redhat.com)
- add missing log_trace option in common.logging (pchalupa@redhat.com)
- Test coverage for logging (ares@igloonet.cz)
- Inline console logging support (ares@igloonet.cz)
- Support for custom log file path (ares@igloonet.cz)
- Remove logrotate configuration not needed anymore (ares@igloonet.cz)
- Support for log trace (ares@igloonet.cz)
- Syslog support (ares@igloonet.cz)
- New logging configuration (ares@igloonet.cz)
- Use logging gem for all logs (ares@igloonet.cz)
- Merge pull request #1670 from iNecas/refactor (inecas@redhat.com)
- Merge pull request #1657 from jlsherrill/pulp_perf (jlsherrill@gmail.com)
- fixture update (jsherril@redhat.com)
- test fix (jsherril@redhat.com)
- vcr cassette update (jsherril@redhat.com)
- test fix (jsherril@redhat.com)
- content views - add some spec tests for content view & definition controllers
  (bbuckingham@redhat.com)
- content views - fix the permission checked when destroying a definition
  (bbuckingham@redhat.com)
- adding deletion changeset tests (jsherril@redhat.com)
- Merge pull request #1677 from thomasmckay/db-seeds-headpin-fence
  (thomasmckay@redhat.com)
- Refactored product content search (daviddavis@redhat.com)
- Started refactoring content search with content view search
  (daviddavis@redhat.com)
- db-seeds-headpin-fence - fence pulp call (thomasmckay@redhat.com)
- Merge pull request #1676 from bbuckingham/fix_routes (bbuckingham@redhat.com)
- Merge branch 'master' of https://github.com/Katello/katello into pulp_perf
  (jsherril@redhat.com)
- minitest test fix (jsherril@redhat.com)
- routes.js - regenerating (bbuckingham@redhat.com)
- Fix ping spec (mhulan@redhat.com)
- Remove expectations on nil warnings (mhulan@redhat.com)
- Refactored system template specs (mhulan@redhat.com)
- Merge pull request #1666 from jlsherrill/set_id_to_set_name
  (jlsherrill@gmail.com)
- Use snake_case instead of camelCase for method names (inecas@redhat.com)
- Local variables snake_case instead of CamelCase (inecas@redhat.com)
- Non action method in controller should be private (inecas@redhat.com)
- Merge pull request #1665 from bbuckingham/sort_promotion_paths
  (bbuckingham@redhat.com)
- remove old FIXME (pchalupa@redhat.com)
- Fixes #1656 - Sets a minimum width on the body to reflect that hard width set
  on the content section. (ehelms@redhat.com)
- content views - fix changeset.add_content_view test (bbuckingham@redhat.com)
- Merge pull request #1652 from witlessbird/default_view_creation
  (witlessbird@gmail.com)
- allowing the use of repo set name for enable disable (jsherril@redhat.com)
- content view - refactor add_content_view logic in controller to model
  (bbuckingham@redhat.com)
- Merge pull request #1660 from daviddavis/act_key_create_fix
  (daviddavis@redhat.com)
- env paths - sort paths by env name (bbuckingham@redhat.com)
- updated test fixtures after merge (dmitri@redhat.com)
- Merge pull request #1663 from bbuckingham/fixes_1661 (bbuckingham@redhat.com)
- updated db/schema.rb; removed default_content_view_id column from
  environments table (dmitri@redhat.com)
- reduced the number of saves during default_content_view creation.
  KTEnvironment is now being saved only once. (dmitri@redhat.com)
- Merge pull request #1621 from daviddavis/cv_system_pgs
  (daviddavis@redhat.com)
- Merge pull request #1647 from thomasmckay/distributors-minitest
  (thomasmckay@redhat.com)
- distributors-minitest - systems and distributors testing
  (thomasmckay@redhat.com)
- Fixes #1661 - add request_type to notices retrieved using client polling
  (bbuckingham@redhat.com)
- custominfo-tupane-fix - fixed tupane layout for custominfo
  (thomasmckay@redhat.com)
- Setting initial_action to fix create (daviddavis@redhat.com)
- content views - ui - composite view promotion - help users with component
  views (bbuckingham@redhat.com)
- Merge pull request #1654 from jlsherrill/bz909472 (jlsherrill@gmail.com)
- using bulk_load_size config option for determining bulk loads
  (jsherril@redhat.com)
- Merge pull request #1651 from jlsherrill/fast_import (mmccune@gmail.com)
- Merge remote-tracking branch 'upstream/master' into fork_composite_views
  (bbuckingham@redhat.com)
- 909472 - not allowing <, >, & /  in usernames (jsherril@redhat.com)
- fixing string detected as improperly formatted (jsherril@redhat.com)
- Merge pull request #1627 from jlsherrill/fast_import (jlsherrill@gmail.com)
- Merge pull request #1648 from daviddavis/rs (miroslav@suchy.cz)
- Merge pull request #1644 from iNecas/apipie-dry (inecas@redhat.com)
- test fixes (jsherril@redhat.com)
- fast import - removing product.import_logger (jsherril@redhat.com)
- Checking db/schema.rb into version control (daviddavis@redhat.com)
- spect test fix (jsherril@redhat.com)
- Merge pull request #1640 from tstrachota/comp_res_fix (tstrachota@redhat.com)
- Merge pull request #1645 from daviddavis/ff (daviddavis@redhat.com)
- Fixing fencing issues in headpin (daviddavis@redhat.com)
- DRY common apipie param descriptions into param groups (inecas@redhat.com)
- content views - address PR 1641 comments (bbuckingham@redhat.com)
- Merge pull request #1594 from xsuchy/pull-req-bz886718 (miroslav@suchy.cz)
- Fixed typo in activation_key comment (daviddavis@redhat.com)
- Merge pull request #1633 from iNecas/912698 (inecas@redhat.com)
- fast import - isloating logic to find content on a product
  (jsherril@redhat.com)
- addressing pull request comment (jsherril@redhat.com)
- content views - tests - few minor changes for composite definitions
  (bbuckingham@redhat.com)
- content views - promote - minor change to handle when there is no definition
  (bbuckingham@redhat.com)
- content views - fix a few broken tests (bbuckingham@redhat.com)
- Merge branch 'master' of https://github.com/Katello/katello into fast_import2
  (jsherril@redhat.com)
- 912698 - ak subscribe:  take the number of sockets in pool into account
  (inecas@redhat.com)
- content views - fix few bugs in view publish/refresh/promote
  (bbuckingham@redhat.com)
- comp resources - fixed system tests (tstrachota@redhat.com)
- Merge pull request #1638 from bbuckingham/fork_content_views_fix_query-2
  (bbuckingham@redhat.com)
- pulp peformance enhancements (jsherril@redhat.com)
- content views - fix query that failed on older postresql
  (bbuckingham@redhat.com)
- Merge pull request #1634 from lzap/i18n-merge-fix (bbuckingham@redhat.com)
- Merge pull request #1626 from daviddavis/cv_content_search
  (daviddavis@redhat.com)
- Merge pull request #1624 from daviddavis/1620 (daviddavis@redhat.com)
- Content views: worked on content view search (daviddavis@redhat.com)
- test fix (jsherril@redhat.com)
- test fix (jsherril@redhat.com)
- i18n - fixing merge issue introduced by 2cee9ef0d7ee53 (lzap+git@redhat.com)
- spec fix (jsherril@redhat.com)
- moving Product#repos from pulp glue to normal model, as nothing is pulp
  related (jsherril@redhat.com)
- Merge pull request #1610 from daviddavis/1592 (daviddavis@redhat.com)
- Merge pull request #1632 from witlessbird/environment_factory
  (witlessbird@gmail.com)
- Merge pull request #1631 from witlessbird/content_view_orchestration
  (witlessbird@gmail.com)
- a smal refactoring to generate more complete environment+dependencies tree
  (dmitri@redhat.com)
- a fix in content_view_environemnt: the order of callbacks is important
  (dmitri@redhat.com)
- Loading pulp gem group (jomara@redhat.com)
- content views - ui - composite definitions - help user resolve content
  conflicts (bbuckingham@redhat.com)
- whitespace fix (jsherril@redhat.com)
- Resolving headpin installation issues (jomara@redhat.com)
- spec fixes (jsherril@redhat.com)
- fast import - removing refresh_products from ui provider
  (jsherril@redhat.com)
- fast import - adding tool tip and better messaging if no manifest was
  imported (jsherril@redhat.com)
- spec test fix (jsherril@redhat.com)
- fast import - adding tests for repository set manipulation
  (jsherril@redhat.com)
- Content views: fixing content_view_definition api controller test
  (daviddavis@redhat.com)
- content views - initial support to promote composite views
  (bbuckingham@redhat.com)
- Merge pull request #1614 from ehelms/menu-updates (ericdhelms@gmail.com)
- Content views: updating list on system new page (daviddavis@redhat.com)
- Merge pull request #1611 from daviddavis/test_fix (daviddavis@redhat.com)
- Fixing #1620 by defining url_content_views_proc (daviddavis@redhat.com)
- fast import - adding spec tests and api for disable (jsherril@redhat.com)
- Merge pull request #1600 from xsuchy/pull-req-tomcat (miroslav@suchy.cz)
- merge conflict (jsherril@redhat.com)
- content views - do not list composite definitions in content list
  (bbuckingham@redhat.com)
- content views - extend the definition.repos to support composite definitions
  (bbuckingham@redhat.com)
- Content views: fixing breaking test (daviddavis@redhat.com)
- f18 - skip api pie for fedora 18 (lzap+git@redhat.com)
- Content views: addressing feedback from #1592 (daviddavis@redhat.com)
- f18 - making apipie happy during build phase (lzap+git@redhat.com)
- Merge pull request #1605 from lzap/jruby-fix (lzap@redhat.com)
- Merge pull request #1535 from iNecas/log-not-found-message
  (inecas@redhat.com)
- Merge pull request #1568 from pitr-ch/bug/781206-missing-notifications
  (kontakt@pitr.ch)
- Merge pull request #1580 from pitr-ch/story/configuration (kontakt@pitr.ch)
- Merge pull request #1604 from lzap/f18-build (lzap@redhat.com)
- rails32 - not need version constraints anymore on compass
  (lzap+git@redhat.com)
- Merge pull request #1609 from bbuckingham/fork_content_view_migrations
  (daviddavis@redhat.com)
- content views - remove trailing whitespace on comment...
  (bbuckingham@redhat.com)
- content views - migration - associate env with version
  (bbuckingham@redhat.com)
- content views - fix migration that maps repos to view versions
  (bbuckingham@redhat.com)
- new ui for repo(set) enabling (jsherril@redhat.com)
- Merge pull request #1607 from daviddavis/fix_jenkins_cv
  (daviddavis@redhat.com)
- Merge pull request #1603 from ehelms/compass-rails-32 (ericdhelms@gmail.com)
- Rewriting test to hopefully fix jenkins error (daviddavis@redhat.com)
- Merge pull request #1592 from Katello/content_views (bbuckingham@redhat.com)
- jruby - rpm installation is not supported on jruby yet (lzap+git@redhat.com)
- Merge pull request #1601 from xsuchy/pull-req-tu_shim2 (lzap@redhat.com)
- Content views: changed how exception was being raised (daviddavis@redhat.com)
- Content views: fixing minitest test (daviddavis@redhat.com)
- Merge pull request #1602 from xsuchy/pull-req-Gemfile56
  (bbuckingham@redhat.com)
- Merge pull request #1554 from thomasmckay/distributors
  (thomasmckay@redhat.com)
- s/Gemfile.32/Gemfile32/ (msuchy@redhat.com)
- initial repo set UI work (jsherril@redhat.com)
- distributors - updated tupane changes from master (thomasmckay@redhat.com)
- do not require minitest_tu_shim (msuchy@redhat.com)
- distributors - clean up based upon pull-request feedback (code format, etc.)
  (thomasmckay@redhat.com)
- distributors - 'rake jsroutes' after rebase from master
  (thomasmckay@redhat.com)
- distributors - UI (thomasmckay@redhat.com)
- rename katello-defaults.yml to katello_defaults.yml (pchalupa@redhat.com)
- changing secrets 'shhhh' to 'katello' (pchalupa@redhat.com)
- we need tomcat in %%post section (msuchy@redhat.com)
- use Gemfile.32 for Fedora 18+ (msuchy@redhat.com)
- Merge pull request #1565 from jlsherrill/bz910094 (jlsherrill@gmail.com)
- Merge remote-tracking branch 'upstream/master' into content_views
  (bbuckingham@redhat.com)
- Merge remote-tracking branch 'upstream/master' into content_views
  (bbuckingham@redhat.com)
- Content views: fixed call to ChangesetContentException
  (daviddavis@redhat.com)
- Content views: removing 1.9 method sort_by! (daviddavis@redhat.com)
- Content views: fixing indentation in api cvd controller
  (daviddavis@redhat.com)
- Content views: updating copyright years (daviddavis@redhat.com)
- Content views: addressing feedback from PR #1592 (daviddavis@redhat.com)
- Merge branch 'master' of https://github.com/Katello/katello into fast_import
  (jsherril@redhat.com)
- Merge pull request #1591 from komidore64/custom-info (komidore64@gmail.com)
- fixing le test (komidore64@gmail.com)
- Merge branch 'master' of https://github.com/Katello/katello into fast_import
  (jsherril@redhat.com)
- 886718 - allow better translation of one string (msuchy@redhat.com)
- Merge pull request #1555 from ehelms/rails32-30-bridge (ericdhelms@gmail.com)
- Menu - Fixes issue where menu updates did not correctly update API
  controller. (ehelms@redhat.com)
- Conflicts:      src/app/controllers/roles_controller.rb (jrist@redhat.com)
- content views - Rails32 - move tupane_layout declarations to views
  (bbuckingham@redhat.com)
- Merge remote-tracking branch 'upstream/master' into content_views
  (bbuckingham@redhat.com)
- Rails32 - Adds compass-rails for Compass 0.12 on Fedora 18 and updates
  configuration file for compass for both version of compass 0.11.5 and 0.12.
  (ehelms@redhat.com)
- Merge pull request #1528 from xsuchy/pull-req-msg (miroslav@suchy.cz)
- Merge pull request #1575 from jlsherrill/bz868917 (jlsherrill@gmail.com)
- Refactoring edit action in activation_keys controller (daviddavis@redhat.com)
- Rails32 - Setting haml declaration in 32 Gemfile to be consistent with
  regular Gemfile.  Re-factoring accessible_environments for readability.
  (ehelms@redhat.com)
- Rails32 - Fixing accessible_environments to properly generate an array when
  making the list unique. (ehelms@redhat.com)
- Rails32 - Removing clone and adding dup on self. (ehelms@redhat.com)
- Rails32 - Small test fix following a rebase. (ehelms@redhat.com)
- Rails32 - Whitespace cleanup. (ehelms@redhat.com)
- Rails32 - Adds a slew of updates required to get spec tests passing.
  (ehelms@redhat.com)
- Rails32 - Adds a separate gemfile to specify Rails3.2 for Travis testing.
  (ehelms@redhat.com)
- Rails32 - Updates tests that rely on loading fixtures in before and after
  suites to load them properly in both 3.2 and 3.0 (ehelms@redhat.com)
- Rails32 - ActiveRecord models now take two arguments on intialize. This
  updates each model that overrides initialize and calls superto conditionally
  call super with 1 or 2 arguments depending on the Rails version.
  (ehelms@redhat.com)
- Rails32 - Adding missing options parameter to initialize method.
  (ehelms@redhat.com)
- Rails32 - Explicitly casting sync_date to a time object since in 3.2 all
  parameters are treated as strings and not cast. (ehelms@redhat.com)
- Rails32 - Adds conditional to grab appropriate association owner since they
  diverge between 3.2 and 3.0. (ehelms@redhat.com)
- Rails32 - Adds needed options parameter for initialize methods.
  (ehelms@redhat.com)
- Rails32 - Putting submodule back to original hash. (ehelms@redhat.com)
- Rails32 - Adding bridge file to contain functionality not present in 3.2 but
  needed by 3.0 to allow temporary running on both stacks. (ehelms@redhat.com)
- Rails32 - Updating location of json custom matcher for spec testing.
  (ehelms@redhat.com)
- Removes completely deprecated and unused debug_rjs option.
  (ehelms@redhat.com)
- Removes validation covered by added indexes that further breaks in Rails 3.2
  (ehelms@redhat.com)
- Spec test fixes to allow passing in Rails 3.2 (ehelms@redhat.com)
- Fixes matching on array's that can result in occassional random order.
  (ehelms@redhat.com)
- Removes validation that is enforced by the database after index changes. This
  is also to prevent errors in Rails 3.2. (ehelms@redhat.com)
- Moves all tupane_layout declarations to the views.  Note that this is also
  required to have tupane views rendering properly in Rails 3.2.
  (ehelms@redhat.com)
- Changes class_inheritable_attribute to class_attribute since the former is
  deprecated in 3.1+. (ehelms@redhat.com)
- fixing some indentation to look nicer (jsherril@redhat.com)
- Added in some missing licenses (daviddavis@redhat.com)
- cleaning up create method, thanks to @daviddavis 's suggestion!
  (komidore64@gmail.com)
- Merge pull request #1572 from jlsherrill/bz852849 (jlsherrill@gmail.com)
- Merge pull request #1578 from jlsherrill/bz909961 (jlsherrill@gmail.com)
- Merge pull request #1587 from daviddavis/cv_fencing (daviddavis@redhat.com)
- little bit of code clean-up for custom info (komidore64@gmail.com)
- content views - 1 more test fix (bbuckingham@redhat.com)
- Content views: added more fencing to UI (daviddavis@redhat.com)
- adding custom info into system's UI page (komidore64@gmail.com)
- content views - update tests for composite definitions
  (bbuckingham@redhat.com)
- Merge pull request #1570 from ehelms/bug-814167 (ericdhelms@gmail.com)
- Merge pull request #1574 from ehelms/bug-864189 (ericdhelms@gmail.com)
- Merge pull request #1577 from ehelms/bug-904194 (ericdhelms@gmail.com)
- Merge pull request #1576 from ehelms/bug-867300 (ericdhelms@gmail.com)
- content views - address comments on PR 1549 (bbuckingham@redhat.com)
- content views - composite - disable publish/refresh on invalid definition
  (bbuckingham@redhat.com)
- Merge pull request #1581 from xsuchy/pull-req-factory_girl_rails
  (miroslav@suchy.cz)
- Merge pull request #1566 from daviddavis/ufg (miroslav@suchy.cz)
- Merge remote-tracking branch 'upstream/master' into fork_content_views_merge
  (bbuckingham@redhat.com)
- Merge pull request #1582 from ehelms/gemfile-update (bbuckingham@redhat.com)
- enable more checks (msuchy@redhat.com)
- ko - (pofilter) newlines: Different line endings (msuchy@redhat.com)
- mr - (pofilter) newlines: Different line endings (msuchy@redhat.com)
- or - (pofilter) newlines: Different line endings (msuchy@redhat.com)
- ta - (pofilter) newlines: Different line endings (msuchy@redhat.com)
- te - (pofilter) long: The translation is much longer than the original
  (msuchy@redhat.com)
- de - (pofilter) variables: Added variables: %%s (msuchy@redhat.com)
- es - (pofilter) variables: Do not translate: %%s (msuchy@redhat.com)
- hi - (pofilter) variables: Do not translate: %%s (msuchy@redhat.com)
- kn - (pofilter) variables: Do not translate: %%s (msuchy@redhat.com)
- ko - (pofilter) variables: Do not translate: %%s (msuchy@redhat.com)
- pa - (pofilter) variables: Do not translate: %%s (msuchy@redhat.com)
- ta - (pofilter) variables: Do not translate: %%s (msuchy@redhat.com)
- pofilter always return 0, fail if there is some error output
  (msuchy@redhat.com)
- Merge pull request #1436 from thomasmckay/901714-subfilters
  (thomasmckay@redhat.com)
- Gemfile - Setting haml version to be more restrictive due to new release of
  haml gem on Rubygems. (ehelms@redhat.com)
- zh_CN - (pofilter) variables: Added variables: %%s (msuchy@redhat.com)
- check po files for errors using pofilter (msuchy@redhat.com)
- check localization files for corectness (msuchy@redhat.com)
- Set factory_girl_rails to 1.4.0 per repos (daviddavis@redhat.com)
- Merge pull request #1548 from daviddavis/cv_act_key_field
  (daviddavis@redhat.com)
- Merge pull request #1579 from ares/feature/better_locale_parsing
  (ares@igloonet.cz)
- add factory_girl_rails to requirements of katello-devel (msuchy@redhat.com)
- Merge branch 'master' into story/configuration (pchalupa@redhat.com)
- documentation update (pchalupa@redhat.com)
- leave app_mode option in katello.yml (pchalupa@redhat.com)
- Merge pull request #1559 from ares/bug/883003-system_groups_validation
  (ares@igloonet.cz)
- Small fix for invalid locale input (ares@igloonet.cz)
- Changeset - Missing render tupane_layout call in view. (ehelms@redhat.com)
- 909961 - fixing cs errata add/remove from ui (jsherril@redhat.com)
- Merge pull request #1558 from bbuckingham/fork_content_views_jslint
  (daviddavis@redhat.com)
- 904194 - Changes to reference products by label instead of name since
  multiple products with the same name can exist and cause issues when
  attempting to promote a system template. (ehelms@redhat.com)
- 867300 - Moves the activation key attach button to the top left corner of the
  available subscriptions table on the activation key edit. (ehelms@redhat.com)
- 868917 - fixing terminology of comparison on content search
  (jsherril@redhat.com)
- fixing model scoping (jsherril@redhat.com)
- 864189 - Fixes issue where hovering over a top level tab and then moving to
  another top level tab would result in a flash of the menu and an improper
  display of the menu. (ehelms@redhat.com)
- 867304 - sorting first environment in paths for env selector
  (jsherril@redhat.com)
- Content views: updating content views and products on activation key page
  (daviddavis@redhat.com)
- 852849 - fixing redirect of expired sessoin (jsherril@redhat.com)
- 814167 - Changes the rendering location of the remove button on system
  templates sliding tree to be centered with text. (ehelms@redhat.com)
- Merge pull request #1564 from ehelms/bug-770690 (ericdhelms@gmail.com)
- 910094 - fixing creation of repos with internationalized names
  (jsherril@redhat.com)
- 770690 - Adds helptip to debug certificate download to explain what the debug
  certificate is used for. (ehelms@redhat.com)
- fixing route (jsherril@redhat.com)
- Pulp agent changed recently the format of the remote action report
  (inecas@redhat.com)
- add missing notification when repo discovery fails (pchalupa@redhat.com)
- replace Notify with #notify in controller (pchalupa@redhat.com)
- Condition cleanup (ares@igloonet.cz)
- 883003 - SystemGroup validation (ares@igloonet.cz)
- Merge pull request #1552 from
  ares/bug/844389-repository_deletion_and_creation (ares@igloonet.cz)
- allowing repo set enabling to be async (jsherril@redhat.com)
- 901714-subfilters - disabling busted spec, moving to minitest
  (thomasmckay@redhat.com)
- content views - address jslint warnings (bbuckingham@redhat.com)
- content views - rename nav Views to Content View Definitions
  (bbuckingham@redhat.com)
- content views - update nav to ensure unique ids (bbuckingham@redhat.com)
- Whitespace - Fixing whitespace. (ehelms@redhat.com)
- content views : fix nav to use Katello.config vs AppConfig
  (bbuckingham@redhat.com)
- spec fixes (jsherril@redhat.com)
- Merge pull request #1485 from ehelms/test-updates (ericdhelms@gmail.com)
- 901714-subfilters - subscription filters 901714 & 901715 fixed
  (thomasmckay@redhat.com)
- adding api for repository set enabling & listing (jsherril@redhat.com)
- adding content set disabling to model layer (jsherril@redhat.com)
- 844389 - Revert of content deletion checking removal (ares@igloonet.cz)
- Fixing errors on content_views (daviddavis@redhat.com)
- initial model changes to support faster imports (jsherril@redhat.com)
- Merge branch 'master' into story/configuration (pchalupa@redhat.com)
- add default values to configuration (pchalupa@redhat.com)
- Merge pull request #1544 from ares/bug/851331-provider_organization_id_format
  (ares@igloonet.cz)
- Merge pull request #1537 from
  ares/bug/844389-repository_deletion_and_creation (ares@igloonet.cz)
- 851331 - Add organization label attribute (ares@igloonet.cz)
- 844389 - unsuccessful repo deletion rollbacking (ares@igloonet.cz)
- 841013 - Allow same name distributions in changeset (ares@igloonet.cz)
- Merge pull request #1513 from daviddavis/cv_unique (daviddavis@redhat.com)
- content views - only associate cp_environment with content_view_environment
  (bbuckingham@redhat.com)
- content views - simplify environments for rhsm (bbuckingham@redhat.com)
- content view - fix content_view_version_environment to properly access view
  name (bbuckingham@redhat.com)
- content views - fix few tests broken when adding content view env
  (bbuckingham@redhat.com)
- content views - handle case where system create contains numeric id for env
  (bbuckingham@redhat.com)
- content views - consumer - see views as envs and allow registration to view
  (bbuckingham@redhat.com)
- content views - adding initial support for cv environments w/ candlepin
  support (bbuckingham@redhat.com)
- content views - fix product repo selector behavior for deleting a repo
  (bbuckingham@redhat.com)
- Merge remote-tracking branch 'upstream/master' into fork_content_views
  (bbuckingham@redhat.com)
- Merge pull request #1532 from lzap/test-script (lzap@redhat.com)
- Merge pull request #1503 from lzap/jruby (lzap@redhat.com)
- Merge pull request #1545 from jlsherrill/minitest-fix (jlsherrill@gmail.com)
- switching to <= for minitest (jsherril@redhat.com)
- forcing a lower version of minitest (jsherril@redhat.com)
- Merge pull request #1534 from daviddavis/es_move (daviddavis@redhat.com)
- spec fix (jsherril@redhat.com)
- fixing a couple issues with errata and packages (jsherril@redhat.com)
- Merge remote-tracking branch 'upstream/master' into fork_content_views_merge
  (bbuckingham@redhat.com)
- Log exception message for RecordNotFound exception (inecas@redhat.com)
- Merge pull request #1530 from pitr-ch/quick-fix/remove-bundler-patch
  (kontakt@pitr.ch)
- Moving elastisearch methods to module (daviddavis@redhat.com)
- Merge branch 'master' into story/configuration (pchalupa@redhat.com)
- Merge pull request #1229 from iNecas/apipie-headpin (inecas@redhat.com)
- Reduced API documentation for Headpin mode (inecas@redhat.com)
- Merge pull request #1511 from witlessbird/param_rules_error
  (witlessbird@gmail.com)
- Merge pull request #1430 from pitr-ch/story/yard (kontakt@pitr.ch)
- 908012 - fixing katello-check for pulp v1 (lzap+git@redhat.com)
- move exception_paranoia option form application.rb to katello.yml
  (pchalupa@redhat.com)
- Merge pull request #1522 from xsuchy/pull-req-sam-trans (miroslav@suchy.cz)
- remove bundler patch preferring rpms over gems (pchalupa@redhat.com)
- Merge branch 'master' into story/yard (pchalupa@redhat.com)
- Fixed more merge conflicts (paji@redhat.com)
- Fixed some merge conflicts Conflicts:   src/public/javascripts/routes.js
  (paji@redhat.com)
- bumping runcible requirement (jsherril@redhat.com)
- Content views: added view search to content search (daviddavis@redhat.com)
- Merge pull request #1520 from tstrachota/log_msg_fix (lzap@redhat.com)
- fix for typos in auth log messages (tstrachota@redhat.com)
- merge translation from SAM (msuchy@redhat.com)
- Translations - Download translations from Transifex for katello.
  (msuchy@redhat.com)
- build fix: replaced string evaluation with substitution in
  OwnRolePresenceValidator error message (dmitri@redhat.com)
- Merge pull request #1481 from witlessbird/default_environment
  (witlessbird@gmail.com)
- moved OwnRolePresenceValidator into a dedicated class and into lib/validators
  (dmitri@redhat.com)
- fixing jenkins runcible module issue (jsherril@redhat.com)
- Content views: making names unique (daviddavis@redhat.com)
- Fixed some merge conflicts (paji@redhat.com)
- Merge pull request #1510 from ehelms/runcible-logging (jlsherrill@gmail.com)
- Runcible - Updates logging configuration for Runcible so that all requests to
  Pulp will be logged at debug log level and if the log level is set to error,
  only exceptions thrown by Pulp will be logged. (ehelms@redhat.com)
- refactoring of handling of http errors (dmitri@redhat.com)
- replaced a 400 error with 422 (unprocessable entity) on param_rule check
  failure (dmitri@redhat.com)
- Removed the github reference in gemfile since ruby-gems is open
  (paji@redhat.com)
- Revert "Removed the github reference in gemfile since ruby-gems is open"
  (paji@redhat.com)
- Removed the github reference in gemfile since ruby-gems is open
  (paji@redhat.com)
- Changed the gemfile + spec to use new runcible (paji@redhat.com)
- Fixed an unintended insert (paji@redhat.com)
- Fixed a typo (paji@redhat.com)
- Updated katello code base to work with Runcible 0.3.2 (paji@redhat.com)
- Updated gemfile to use runcible 0.3.2 (paji@redhat.com)
- Merge pull request #1453 from jhadvig/system_group_errata
  (j.hadvig@gmail.com)
- Merge pull request #1507 from jlsherrill/runcible-version
  (jlsherrill@gmail.com)
- requiring specific runcible version (jsherril@redhat.com)
- renamed User#find_by_default_environment to User#with_default_environment
  (dmitri@redhat.com)
- removed strayed logging in users_controller (dmitri@redhat.com)
- refactoring of default system registration permission and user own role code
  in User model (dmitri@redhat.com)
- Merge pull request #1495 from iNecas/pulp-ping-fix (inecas@redhat.com)
- kt form builder - support for label help icon (tstrachota@redhat.com)
- hw models - ui pages (tstrachota@redhat.com)
- hw models - model and api (tstrachota@redhat.com)
- foreman model - support for different resource name in foreman
  (tstrachota@redhat.com)
- abstract model - parse attributes properly on create (tstrachota@redhat.com)
- Using OPTIONS method on Pulp API to find out it's running (inecas@redhat.com)
- jruby - get jdbc running with bundler_ext (lzap+git@redhat.com)
- jruby - checking devel gems disabled for jruby (lzap+git@redhat.com)
- jruby - enabling threadsafe and fixing manifest upload (lzap+git@redhat.com)
- Content views: various fixes to UI and CLI (daviddavis@redhat.com)
- Merge pull request #1499 from jlsherrill/1.9fix (jlsherrill@gmail.com)
- Merge pull request #1498 from thomasmckay/jsroutes-update
  (thomasmckay@redhat.com)
- fixing ruby 1.9 error (jsherril@redhat.com)
- updated routes.js, fixed typo array_with_total (thomasmckay@redhat.com)
- Merge pull request #1480 from ehelms/pulpv2 (ericdhelms@gmail.com)
- Merge branch 'master' into v2-cv (paji@redhat.com)
- Merge branch 'content_views' into v2-cv (paji@redhat.com)
- Fixed a small error in default content view publish (paji@redhat.com)
- Revert "Fixed a small error in default content view publish"
  (paji@redhat.com)
- White-spaces fixes in Gemfiles (inecas@redhat.com)
- Merge pull request #1492 from jlsherrill/redhat-promotion-fix
  (jlsherrill@gmail.com)
- create a distributor for disabled repos (jsherril@redhat.com)
- Merge pull request #1469 from daviddavis/jsroutefix (daviddavis@redhat.com)
- Minitest - Adds flag to allow running Pulp glue tests against live Pulp
  without recording new cassettes.  This can be useful to test your Pulp setup
  and functionality without accidentally generating a set of new cassettes.
  (ehelms@redhat.com)
- Fixed a small error in default content view publish (paji@redhat.com)
- Merge branch 'master' into v2-cv (paji@redhat.com)
- Merge pull request #1479 from ares/bug/790064-manifest_import_error_handling
  (ares@igloonet.cz)
- fix YARD Documentation link (pchalupa@redhat.com)
- Content views: fixed a couple UI content view bugs
- Merge branch 'master' into story/yard (pchalupa@redhat.com)
- document workaround if running yard in reload mode fails
  (pchalupa@redhat.com)
- Fix setting environment without usage RAILS_ENV (inecas@redhat.com)
- Automatic commit of package [katello] release [1.3.14-1].
  (jsherril@redhat.com)
- bumping required runcible version (jsherril@redhat.com)
- Merge branch 'master' into v2-cv (paji@redhat.com)
- Fix to get Promotions controller test to work (paji@redhat.com)
- Fixed an accidental typo in the cv spec file (paji@redhat.com)
- merge conflict (jsherril@redhat.com)
- Merge pull request #1431 from jlsherrill/820382 (jlsherrill@gmail.com)
- Merge pull request #1482 from jlsherrill/require-selinux
  (jlsherrill@gmail.com)
- Automatic commit of package [katello] release [1.3.13-1].
  (jsherril@redhat.com)
- require pulp-selinux (jsherril@redhat.com)
- Fixed some files missed in previous merges (paji@redhat.com)
- Fixed some unit tests (paji@redhat.com)
- PulpV2 - Clean-up of authorization modules to use ActiveSupport::Concern for
  clarity and consistency. (ehelms@redhat.com)
- merge conflict (jsherril@redhat.com)
- changing default config template port for post_sync_url (jsherril@redhat.com)
- 790064 - Fix for manifest import in headpin mode (ares@igloonet.cz)
- removing pulpv2 prefix from pulpv2 branch (jsherril@redhat.com)
- fixing references to AppConfig (jsherril@redhat.com)
- Removed trailing whitespaces (paji@redhat.com)
- Merge branch 'pulpv2' into v2-cv (paji@redhat.com)
- Fixed more conflicts (paji@redhat.com)
- adding post sync url to config template (jsherril@redhat.com)
- Missed commits (paji@redhat.com)
- Fixed some merge conflicts (paji@redhat.com)
- PulpV2 - Fixes broken test by stubbing Runcible method. (ehelms@redhat.com)
- Merge pull request #1470 from daviddavis/cv_fixjsroutes
  (daviddavis@redhat.com)
- Merge pull request #1420 from bbuckingham/fork_content_views_composite
  (bbuckingham@redhat.com)
- Merge branch 'master' of github.com:Katello/katello into pulpv2
  (ehelms@redhat.com)
- running db:migrate && db:seed as different rake commands
  (jsherril@redhat.com)
- 790064 - Manifest import error handling (ares@igloonet.cz)
- 790064 - Refactoring of unreadeable methods (ares@igloonet.cz)
- Automatic commit of package [katello] release [1.3.12.pulpv2-1].
  (jsherril@redhat.com)
- fixing changelog (jsherril@redhat.com)
- Regenerating content view js routes (daviddavis@redhat.com)
- Locking down js-routes to 0.6.x due to code breakages (daviddavis@redhat.com)
- Locking down js-routes to 0.6.x due to code breakages (daviddavis@redhat.com)
- merge conflict (jsherril@redhat.com)
- Merge pull request #1466 from daviddavis/apispecfix (daviddavis@redhat.com)
- Automatic commit of package [katello] release [1.3.5-1].
  (jsherril@redhat.com)
- fixing compass version (jsherril@redhat.com)
- Automatic commit of package [katello] release [1.3.11.pulpv2-1].
  (jsherril@redhat.com)
- fixing pulp url in config template (jsherril@redhat.com)
- fix whitespace (jsherril@redhat.com)
- change ruby-linter to print out all errors (jsherril@redhat.com)
- adding use_elasticsearch to config template (jsherril@redhat.com)
- merge fix (jsherril@redhat.com)
- updating ES glue to use Ext::IndexedModel (jsherril@redhat.com)
- merge conflict (jsherril@redhat.com)
- content views - update to handle deletion of repo from a definition
  (bbuckingham@redhat.com)
- more spec fixes (jsherril@redhat.com)
- Merge pull request #1422 from daviddavis/cv_sys_search
  (daviddavis@redhat.com)
- Merge pull request #1413 from daviddavis/cv_key_ui (daviddavis@redhat.com)
- Reverting locale changes to api specs (daviddavis@redhat.com)
- fixing minitests and most specs (jsherril@redhat.com)
- Merge pull request #1464 from witlessbird/moar_spec_fixes (lzap@redhat.com)
- added lib/resources/abstract_model dir and its contents to the .spec file
  (dmitri@redhat.com)
- Merge pull request #1447 from tstrachota/Bug_895212_correct_find_org
  (tstrachota@redhat.com)
- orgs - new scope for finding by name or label (tstrachota@redhat.com)
- 895212 - correct org search (tstrachota@redhat.com)
- Merge pull request #1463 from lzap/i18n-fix-887095 (daviddavis@redhat.com)
- fixes building of foreman glue rpm (dmitri@redhat.com)
- removed redundant dir inclusion in headpin (dmitri@redhat.com)
- fix for a broken .spec: now includes files in models/ext dir during the build
  (dmitri@redhat.com)
- 887095 - fixing API breakage (lzap+git@redhat.com)
- remove dependencies on yard-activerecord and railroady (pchalupa@redhat.com)
- Merge branch 'master' into story/yard (pchalupa@redhat.com)
- Merge pull request #1451 from witlessbird/860452 (witlessbird@gmail.com)
- fixing some merge conflict broken-ness (jsherril@redhat.com)
- merge conflict (jsherril@redhat.com)
- Merge pull request #1461 from daviddavis/i18n-fallback (mmccune@gmail.com)
- 887095 - Fixing test and feedback (daviddavis@redhat.com)
- 903000 - Fix for missing params checking on System Templates
  (jrist@redhat.com)
- Merge pull request #1458 from lzap/fix-travis-revert (ericdhelms@gmail.com)
- bumping version of therubyracer (lzap+git@redhat.com)
- exclude test.rake for main rpm (jsherril@redhat.com)
- Merge pull request #1441 from ehelms/bug-901657 (ericdhelms@gmail.com)
- avoid problematic ZenTest-4.8.4 (lzap+git@redhat.com)
- Revert "fix building on F18" (lzap+git@redhat.com)
- Revert "Fix F16,EL6 after fixing F18" (lzap+git@redhat.com)
- Revert "correctly compare version" (lzap+git@redhat.com)
- Revert "do not fail if you use bundler" (lzap+git@redhat.com)
- Revert "workaround BZ 901540" (lzap+git@redhat.com)
- Revert "do not use ZenTest 4.8.4" (lzap+git@redhat.com)
- fixed a syntax error under 1.8.7 (dmitri@redhat.com)
- moved most of the modules in app/models to either models/ext or lib/
  directories (dmitri@redhat.com)
- Revert "Fixing Travis for Ruby 1.9" (lzap+git@redhat.com)
- 858877 Allow selection of all listem items when applying packages to a system
  group (j.hadvig@gmail.com)
- renamed 'CustomPermissions' into 'PermissionTagCleanup' (dmitri@redhat.com)
- fix for BZ 860452: custom tags are now being deleted when associated entity
  is deleted (dmitri@redhat.com)
- Merge pull request #1452 from lzap/uuid-tested (miroslav@suchy.cz)
- Merge pull request #1448 from tstrachota/proxies_cli (tstrachota@redhat.com)
- uuid - now works with Rails 3.2 (lzap+git@redhat.com)
- Merge pull request #1450 from mbacovsky/cli_auth_with_no_credentials
  (martin.bacovsky@gmail.com)
- Automatic commit of package [katello] release [1.3.10.pulpv2-1].
  (jsherril@redhat.com)
- fixing version (jsherril@redhat.com)
- requiring pulp rpm package in the correct place (jsherril@redhat.com)
- Merge pull request #1449 from lzap/remove-del-896074 (lzap@redhat.com)
- remove svg files from git repository (pchalupa@redhat.com)
- add missing type notation in @option tags (pchalupa@redhat.com)
- Merge pull request #1439 from ehelms/bug-795903 (ericdhelms@gmail.com)
- Merge pull request #1442 from daviddavis/rlint (daviddavis@redhat.com)
- Fixed wrong param format (mbacovsk@redhat.com)
- Merge pull request #1278 from Katello/bkearney/868045
  (bryan.kearney@gmail.com)
- 896074 - fixing remove deletion permissions (lzap+git@redhat.com)
- smart proxies - listing available features in cli info
  (tstrachota@redhat.com)
- 887095 - cli locale was not set properly (lzap+git@redhat.com)
- Merge pull request #1445 from daviddavis/travis19fix (daviddavis@redhat.com)
- Merge pull request #1438 from jlsherrill/902948 (jlsherrill@gmail.com)
- Merge pull request #1440 from jlsherrill/867991 (jlsherrill@gmail.com)
- Fixing Travis for Ruby 1.9 (daviddavis@redhat.com)
- Skipping Zentest 4.8.4 due to bad gemspec (msuchy@redhat.com)
- Streaming files instead of loading them entirely into mem
  (daviddavis@redhat.com)
- Merge pull request #1418 from xsuchy/pull-req-f18-3 (miroslav@suchy.cz)
- do not use ZenTest 4.8.4 (msuchy@redhat.com)
- workaround BZ 901540 (msuchy@redhat.com)
- do not fail if you use bundler (msuchy@redhat.com)
- correctly compare version (msuchy@redhat.com)
- Fix F16,EL6 after fixing F18 (msuchy@redhat.com)
- fix building on F18 (msuchy@redhat.com)
- update yard documentation guide (pchalupa@redhat.com)
- Automatic commit of package [katello] release [1.3.9_pulpv2-1].
  (jsherril@redhat.com)
- version bump (jsherril@redhat.com)
- spec file changes for build (jsherril@redhat.com)
- bad merge fix (jsherril@redhat.com)
- removing lib/resources/pulp.rb from spec (jsherril@redhat.com)
- Fixed whitespace (daviddavis@redhat.com)
- Added a lint check for ruby code (daviddavis@redhat.com)
- Merge pull request #1437 from ehelms/bug-858008 (ericdhelms@gmail.com)
- 901657 - Adds standard name validator to role names to prevent HTML
  injection. (ehelms@redhat.com)
- Merge pull request #1434 from jsomara/cve20123503 (jsomara@gmail.com)
- 867991 - fixing tab index on env and activation key new pages
  (jsherril@redhat.com)
- 795003 - Adds a word wrap to edit text fields so that long names, such as the
  CDN URL being long. (ehelms@redhat.com)
- 902948 - fixing errata icons in content search (jsherril@redhat.com)
- 858008 - Adds event trigger and bind to close action bar when sliding tree
  items are clicked. (ehelms@redhat.com)
- 832134 - making description search more consistent (jsherril@redhat.com)
- Merge pull request #1433 from daviddavis/spinner (daviddavis@redhat.com)
- CVE-2012-3503 - setting umask for /etc/katello/secret-token
  (jomara@redhat.com)
- 852885 - Fixing spinner image (daviddavis@redhat.com)
- Merge pull request #1374 from knowncitizen/oauth_fix (jrist@redhat.com)
- 860471 - Fix for flicker - extra .tipsify call. (jrist@redhat.com)
- 820382 - adding env_id to promoted cs link on dashboard (jsherril@redhat.com)
- add how to document guide (pchalupa@redhat.com)
- Fixing trailing whitespace (daviddavis@redhat.com)
- Automatic commit of package [katello] release [1.3.8_pulpv2-1].
  (jsherril@redhat.com)
- version bump (jsherril@redhat.com)
- adding rubygem-hooks to spec requires (jsherril@redhat.com)
- fixing bundler_ext changes (jsherril@redhat.com)
- Automatic commit of package [katello] release [1.3.7_pulpv2-1].
  (jsherril@redhat.com)
- revert of requiring compass < 0.12 (jsherril@redhat.com)
- fixing use of reserved javascript word (jsherril@redhat.com)
- Content views: added content_view to system search (daviddavis@redhat.com)
- Automatic commit of package [katello] release [1.3.6_pulpv2-1].
  (jsherril@redhat.com)
- fixing rpm build for pulpv2 (jsherril@redhat.com)
- Automatic commit of package [katello] release [1.3.5_pulpv2-1].
  (jsherril@redhat.com)
- version bump (jsherril@redhat.com)
- removing old converge-ui build code (jsherril@redhat.com)
- Merge pull request #1392 from mbacovsky/smart_proxy_ui
  (martin.bacovsky@gmail.com)
- Automatic commit of package [katello] release [1.3.4_pulpv2-1].
  (jsherril@redhat.com)
- version downgrade from mistaken bump (jsherril@redhat.com)
- Automatic commit of package [katello] release [1.4.1_pulpv2-1].
  (jsherril@redhat.com)
- temporary release bump for pulpv2 test building (jsherril@redhat.com)
- Merge pull request #1405 from tstrachota/ui_fixes (tstrachota@redhat.com)
- content views - resolve issues with promotion, publish..etc
  (bbuckingham@redhat.com)
- Merge pull request #1417 from jlsherrill/pulpv2-system (jlsherrill@gmail.com)
- minitest glue fix (jsherril@redhat.com)
- fixing spec tests (jsherril@redhat.com)
- Merge pull request #1402 from bbuckingham/fork_content_views_composite
  (bbuckingham@redhat.com)
- rails 3.2 removed ActiveSupport::SecureRandom in favor of SecureRandom
  (msuchy@redhat.com)
- Merge pull request #1409 from ehelms/pulpv2 (ericdhelms@gmail.com)
- Content views: showing content view in left pane of key layout
  (daviddavis@redhat.com)
- various cli system test fixes (jsherril@redhat.com)
- we now use unit id to refer to errata, so we need to look up errata and get
  both ids (jsherril@redhat.com)
- travis test fix (hopefully) (jsherril@redhat.com)
- fixing test runs for jenkins and travis (komidore64@gmail.com)
- Content views: worked on activation two pane (daviddavis@redhat.com)
- bundler_ext - renaming namespace (lzap+git@redhat.com)
- PulpV2 - Simplifies a join to reduce the number of DB calls.
  (ehelms@redhat.com)
- PulpV2 - Removing spec tests that are no longer valid with new test setup.
  (ehelms@redhat.com)
- Smart proxies UI (mbacovsk@redhat.com)
- vcr_update (jsherril@redhat.com)
- Content views: UI for edit/update activation key content views
  (daviddavis@redhat.com)
- updating requires for runcible to fix errata promotion (jsherril@redhat.com)
- foreman_api gem version bumped up to 0.0.10 (tstrachota@redhat.com)
- fix katello.spec (pchalupa@redhat.com)
- fix some documentation formatting errors (pchalupa@redhat.com)
- comp. res. - api, model for each provider (tstrachota@redhat.com)
- simple crud controller - support for custom as_json options
  (tstrachota@redhat.com)
- abstract model - support for instantiating subclasses (tstrachota@redhat.com)
- abstract model - setting resources made consistent (tstrachota@redhat.com)
- architectures - fixed removing all OSs on update (tstrachota@redhat.com)
- subnets - required attributes in model (tstrachota@redhat.com)
- foreman integration ui fixes (tstrachota@redhat.com)
- set Markdown as default markup (pchalupa@redhat.com)
- make inline code block noticeable (pchalupa@redhat.com)
- add model and controller graphs (pchalupa@redhat.com)
- fix yard doc reloading, render only one documentation (:single_library
  option) (pchalupa@redhat.com)
- PulpV2 - Adds missing User model tests and cleans up user.rb.
  (ehelms@redhat.com)
- PulpV2 - Updating TODOs found in UserMailer to use default organization for
  the user instead of the just the first organization. (ehelms@redhat.com)
- Content views: create/edit content views for systems (daviddavis@redhat.com)
- Merge pull request #1312 from parthaa/820404 (parthaa@gmail.com)
- Merge pull request #1401 from jlsherrill/pulpv2-group_pulp_id
  (jlsherrill@gmail.com)
- Merge pull request #1395 from ehelms/pulpv2 (ericdhelms@gmail.com)
- 881847 - allow system group names with spaces and other characters
  (jsherril@redhat.com)
- Merge pull request #1384 from komidore64/thumbslug-ping
  (komidore64@gmail.com)
- requiring 'thumbslug_url' in configuration for headpin only
  (komidore64@gmail.com)
- Automatic commit of package [katello] release [1.3.3-1].
  (jsherril@redhat.com)
- Merge pull request #1394 from daviddavis/cv_gitignore (daviddavis@redhat.com)
- content views - ui - component views may not have same repo
  (bbuckingham@redhat.com)
- content views - ui - create/update composite view definition
  (bbuckingham@redhat.com)
- make yardoc server embedding configurable (pchalupa@redhat.com)
- Merge pull request #1397 from daviddavis/mmp (miroslav@suchy.cz)
- Translations - Update .po and .pot files for katello. (jsherril@redhat.com)
- Translations - New translations from Transifex for katello.
  (jsherril@redhat.com)
- Translations - Download translations from Transifex for katello.
  (jsherril@redhat.com)
- Merge pull request #1393 from daviddavis/pulpv2 (daviddavis@redhat.com)
- Merge branch 'pulpv2' into another-v2-to-cv (paji@redhat.com)
- PulpV2 - Sets a number of spec tests to pending that depend on errata calls
  that is currently busted in Pulp. (ehelms@redhat.com)
- Setting the min_messages level to warning (daviddavis@redhat.com)
- Pulpv2: Making some tweaks based on feedback (daviddavis@redhat.com)
- Pulling in the gitignore from master (daviddavis@redhat.com)
- Merge pull request #1388 from parthaa/v2-to-cv (parthaa@gmail.com)
- Regenerated VCR files. (paji@redhat.com)
- update readme (pchalupa@redhat.com)
- add yard-activerecord plugin (pchalupa@redhat.com)
- embed YARD documentation server into Katello server in development
  (pchalupa@redhat.com)
- Merge pull request #1386 from daviddavis/param_rules (daviddavis@redhat.com)
- Merge pull request #1380 from daviddavis/cv_publish_async
  (daviddavis@redhat.com)
- add foreman integration documentation (pchalupa@redhat.com)
- Repository feed validation moved to validator (mhulan@redhat.com)
- Code cleanup (mhulan@redhat.com)
- Move all validators to one place (mhulan@redhat.com)
- 820392 - repository hostname validation (mhulan@redhat.com)
- PulpV2 - Removes test references to Resources::Pulp (ehelms@redhat.com)
- PulpV2 - Removes reference to now removed resources/pulp (ehelms@redhat.com)
- PulpV2 - Numerous clean-up around Resources::Pulp and Consumer Groups.
  (ehelms@redhat.com)
- merge conflict (jsherril@redhat.com)
- Merging branch pulpv2 to content_views (paji@redhat.com)
- ensuring previous user is reset (jsherril@redhat.com)
- Merge pull request #1385 from ehelms/pulpv2 (ericdhelms@gmail.com)
- emails - add default From to login/password emails (bbuckingham@redhat.com)
- adding thumbslug to headpin's ping function and tests, etc
  (komidore64@gmail.com)
- Content views: locking down params in api controllers (daviddavis@redhat.com)
- adding fixture for hidden user (jsherril@redhat.com)
- Content views: supporting async publishing (daviddavis@redhat.com)
- Content views: added in_environment scope to ContentView
  (daviddavis@redhat.com)
- Content views: some things I found preparing for the demo
  (daviddavis@redhat.com)
- Content views: added CLI for systems with content views
  (daviddavis@redhat.com)
- Content views: added some system/key functionality (daviddavis@redhat.com)
- PulpV2 - Fixes two broken spec tests by stubbing the correct Runcible call.
  (ehelms@redhat.com)
- repo discovery - auto filter table upon new redraw (jsherril@redhat.com)
- PulpV2 - Fixes for spec tests and removing :feed attr from glue/pulp/repo
  (ehelms@redhat.com)
- PulpV2 - Bumps Runcible to 0.3 version requirement in Gemfile.
  (ehelms@redhat.com)
- PulpV2 - Removes the Pulp proxies controller as it is no longer used.
  (ehelms@redhat.com)
- Merge pull request #1368 from bbuckingham/fork_content_views_deletion
  (bbuckingham@redhat.com)
- content views - fix on test for definition deletion (bbuckingham@redhat.com)
- 882311 - hide and check organizations being deleted (lzap+git@redhat.com)
- 882311 - remove scope-based organization hiding when deleting it
  (lzap+git@redhat.com)
- PulpV2 - Updates to version of Runcible that is built against Pulp V2
  community release. (ehelms@redhat.com)
- vcr update (jsherril@redhat.com)
- updating consumer test to handle hidden user (jsherril@redhat.com)
- validate bind & unbind actions occur succesfully (jsherril@redhat.com)
- fixing oauth using consumers (jsherril@redhat.com)
- Merge pull request #1344 from komidore64/localization (komidore64@gmail.com)
- Merge pull request #1339 from komidore64/brackets (komidore64@gmail.com)
- content_views - update has_promoted_views to perform single query
  (bbuckingham@redhat.com)
- Merge pull request #1291 from lzap/prevent-repo-creation-808461
  (lzap@redhat.com)
- Fixing the reset-oauth script to also do ../config/katello.yml if it exists.
  (jrist@redhat.com)
- Merge pull request #1371 from pitr-ch/story/configuration (lzap@redhat.com)
- fix missing assets when running in development (pchalupa@redhat.com)
- Automatic commit of package [katello] release [1.3.2-1].
  (lzap+git@redhat.com)
- fixing 1.9 minitest issue (jsherril@redhat.com)
- content views - api - do not allow deletion of definition w/ promoted views
  (bbuckingham@redhat.com)
- content views - ui - do not allow deletion of definition w/ promoted views
  (bbuckingham@redhat.com)
- content views - fix permission on default_label action
  (bbuckingham@redhat.com)
- Content views: content view can be set on keys in CLI (daviddavis@redhat.com)
- fixing broken minitest (jsherril@redhat.com)
- reverting some uneeded changes (jsherril@redhat.com)
- Fixing bundle install for content_views branch (daviddavis@redhat.com)
- porting static rails version (jsherril@redhat.com)
- PR comment updates (jsherril@redhat.com)
- Merge pull request #1307 from thomasmckay/869371-ram (thomasmckay@redhat.com)
- Merge pull request #1294 from thomasmckay/878891-actkey-alignment
  (thomasmckay@redhat.com)
- merge conflict fix (jsherril@redhat.com)
- Merge pull request #1366 from pitr-ch/story/configuration
  (daviddavis@redhat.com)
- Merge pull request #1364 from lzap/locale-update (lzap@redhat.com)
- fixing indentation (jsherril@redhat.com)
- Fix post install scriptlet (inecas@redhat.com)
- calling appropriate render, since we really don't need anything
  (jsherril@redhat.com)
- add missing documentation (pchalupa@redhat.com)
- fix error message, missing space (pchalupa@redhat.com)
- some small code fixes that never were meant to be committed
  (jsherril@redhat.com)
- removing traces of unneeded action (jsherril@redhat.com)
- content views - simply the retrieval of library version
  (bbuckingham@redhat.com)
- content_views - remove unused publishing methods from content_view.rb
  (bbuckingham@redhat.com)
- content views - updates to support retry on refresh/publish failure
  (bbuckingham@redhat.com)
- content views - if task is nil, publish failed (bbuckingham@redhat.com)
- content views - update sortElement asset to pull from alchemy vs converge-ui
  (bbuckingham@redhat.com)
- content views - adding the 'filters' placeholder back in to routes/controller
  (bbuckingham@redhat.com)
- repo discovery spec additions (jsherril@redhat.com)
- repo discovery - few small ui tweaks (jsherril@redhat.com)
- rails-i18n - upstream checker script (lzap+git@redhat.com)
- rails-i18n - pulling yml files from upstream (lzap+git@redhat.com)
- rails-i18n - adding update script (lzap+git@redhat.com)
- Merge branch 'master' into story/configuration (pchalupa@redhat.com)
- Merge pull request #1356 from daviddavis/lock_rails (daviddavis@redhat.com)
- 891926 - katello refuses to restart (lzap+git@redhat.com)
- Merge branch 'master' into story/configuration (pchalupa@redhat.com)
- fixing bug with url string (jsherril@redhat.com)
- improving spacing and height of subpanel (jsherril@redhat.com)
- fixing filter table to only match on first column (jsherril@redhat.com)
- prepopulating repo name and label based on url path (jsherril@redhat.com)
- repo discovery table ui tweaks (jsherril@redhat.com)
- content views - adding in some spec tests for definition cloning
  (bbuckingham@redhat.com)
- content views - fix permission on ContentViewDefinition.creatable?
  (bbuckingham@redhat.com)
- content views - update ui controller to use correct rules for actions
  (bbuckingham@redhat.com)
- helper cleanup (jsherril@redhat.com)
- repo discovery - ui enhancements (jsherril@redhat.com)
- pulling in repo feed url into db (jsherril@redhat.com)
- Locking rails version to fix bundle install (daviddavis@redhat.com)
- Merge pull request #1347 from daviddavis/0 (daviddavis@redhat.com)
- Merge pull request #1343 from daviddavis/rm_gemfiles (daviddavis@redhat.com)
- 879094 - fixing %%post error in spec (jomara@redhat.com)
- content views - ui - add support for cloning an existing definition
  (bbuckingham@redhat.com)
- content views - copy form - give name input focus (bbuckingham@redhat.com)
- Moving tomcat group add to katello-shared to %%post (jomara@redhat.com)
- repo discovery styling changes (jsherril@redhat.com)
- 879094 - a few updates to katello & katello-selinux spec based on comments
  (jomara@redhat.com)
- Merge branch 'master' into story/configuration (pchalupa@redhat.com)
- adding filter table for repo discovery (jsherril@redhat.com)
- renaming katello_shared -> katello-shared (jomara@redhat.com)
- 879094 - CVE-2012-5561 - fix permissions on /etc/katello/secure
  (jomara@redhat.com)
- Initial Repo discovery & creation ui (jsherril@redhat.com)
- Allowing for local gem groups (daviddavis@redhat.com)
- 868090 - [ru_RU] L10n:Content Management - Repositories: Untranslated string
  in Products and Repositories tab (komidore64@gmail.com)
- changing 'empty?' to 'blank?' (komidore64@gmail.com)
- Removing Gemfile.lock files since they are out of date
  (daviddavis@redhat.com)
- 880515 - [ALL_LANG][headpin CLI] Redundant brackets in the message of
  'Couldn't find organization '??' ()' for system report module with invalid
  --org name. (komidore64@gmail.com)
- content views - add notices for the start/end of publish/refresh
  (bbuckingham@redhat.com)
- content view - handle case where task is nil (bbuckingham@redhat.com)
- Merge branch 'master' into story/configuration (pchalupa@redhat.com)
- Merge pull request #1327 from daviddavis/unique_keys (daviddavis@redhat.com)
- Merge pull request #1315 from xsuchy/pull-req-ignore (miroslav@suchy.cz)
- Merge pull request #1280 from pitr-ch/bug/799356-stack-trace-in-production
  (kontakt@pitr.ch)
- Merge pull request #1271 from lzap/orch-logging (lzap@redhat.com)
- logging - orchestration log - review (lzap+git@redhat.com)
- Merge pull request #1328 from xsuchy/pull-req-typo (miroslav@suchy.cz)
- fixing reset issue (jsherril@redhat.com)
- Merge pull request #1321 from parthaa/merge-to-cv (daviddavis@redhat.com)
- Couple of fixes to make travis happy (paji@redhat.com)
- Regenerated the vcr files to make travis happy (paji@redhat.com)
- Merge pull request #1259 from lzap/org-delete-885261 (lzap@redhat.com)
- Merge pull request #1324 from daviddavis/README (daviddavis@redhat.com)
- Adding tests to check menu item keys for uniqueness (daviddavis@redhat.com)
- fix typo occured -> occurred (msuchy@redhat.com)
- Fixed a test to make travis happy (paji@redhat.com)
- Merge pull request #1326 from weissjeffm/menu-keys2 (jrist@redhat.com)
- Merge pull request #1288 from bbuckingham/fork-843421
  (bbuckingham@redhat.com)
- 843421 - add parens to existing code (bbuckingham@redhat.com)
- Merge pull request #1303 from ehelms/843566 (ericdhelms@gmail.com)
- Merge pull request #1298 from ehelms/bug-871093 (ericdhelms@gmail.com)
- Merge pull request #1313 from ehelms/817858 (ericdhelms@gmail.com)
- Make the :key fields of all the Setup menu items unique across all the
  navigation. (jweiss@redhat.com)
- Merge pull request #1323 from xsuchy/pull-req-sam-translations
  (miroslav@suchy.cz)
- Merge pull request #1284 from ares/bug/fix_for_system_templates_ui
  (ares@igloonet.cz)
- Merge pull request #1316 from
  ares/bugs/790216-concurrent_changeset_promotions (ares@igloonet.cz)
- merge pt_BR from SAM (msuchy@redhat.com)
- add accidentally deleted pt_BR (msuchy@redhat.com)
- Removing README and updating spec file (daviddavis@redhat.com)
- fixing ru/app.po (msuchy@redhat.com)
- forward port translation from SAM (msuchy@redhat.com)
- Merge pull request #1274 from
  ares/bug/781287-allow_notifications_for_pw_change (ares@igloonet.cz)
- Merge pull request #1273 from ares/bug/835902_notifications_for_iframe_upload
  (ares@igloonet.cz)
- Merge branch 'master' into story/configuration (pchalupa@redhat.com)
- Removing filters from the content view branch (paji@redhat.com)
- content views - fix test failure after async publish chgs
  (bbuckingham@redhat.com)
- Merge pull request #1320 from weissjeffm/remove-readme (ericdhelms@gmail.com)
- Merge pull request #1305 from ehelms/858726 (ericdhelms@gmail.com)
- Merge branch 'pulpv2' into merge-to-cv (paji@redhat.com)
- Add back katello specific readme. (jweiss@redhat.com)
- content view - refactor out retrieving the task_status associated w/ publish
  (bbuckingham@redhat.com)
- content views - support publish as 'async' in UI (includes backend chgs)
  (bbuckingham@redhat.com)
- content views - UI - views, handle case where there is no task
  (bbuckingham@redhat.com)
- Remove README that was generated by Ruby on Rails. (jweiss@redhat.com)
- Merge pull request #1317 from daviddavis/cv_cli_ref (daviddavis@redhat.com)
- allowing cancellation of repo discovery (jsherril@redhat.com)
- storing current task id within Thread.current (jsherril@redhat.com)
- Content views: fixed broken refresh tests (daviddavis@redhat.com)
- Content views: handling new refresh code from CLI/API (daviddavis@redhat.com)
- Merge pull request #1269 from daviddavis/cv_test_fixed
  (daviddavis@redhat.com)
- Merge pull request #1295 from daviddavis/pg_update (daviddavis@redhat.com)
- Merge pull request #1299 from bbuckingham/fork-844708
  (bbuckingham@redhat.com)
- Merge pull request #1304 from bbuckingham/fork-848553
  (bbuckingham@redhat.com)
- Merge pull request #1311 from bbuckingham/fork-831362
  (bbuckingham@redhat.com)
- Merge pull request #1296 from ehelms/bug-845062 (ericdhelms@gmail.com)
- Merge pull request #1290 from ehelms/bug-772199 (ericdhelms@gmail.com)
- Merge branch 'master' into story/configuration2 (pchalupa@redhat.com)
- Merge pull request #1302 from witlessbird/832148 (witlessbird@gmail.com)
- ignore obsoletes and fuzzy warnings (msuchy@redhat.com)
- Bug 799356 - systems that have been deleted that are still calling back to
  server generate stack trace (pchalupa@redhat.com)
- Merge pull request #1292 from lzap/squash-admins-873665 (lzap@redhat.com)
- Merge pull request #1289 from daviddavis/favicon_bind_fix (miroslav@suchy.cz)
- logging - orchestration log - unit test fix (lzap+git@redhat.com)
- Merge pull request #1279 from ares/bug/806096-display_repos_to_readonly_user
  (ares@igloonet.cz)
- Merge pull request #1306 from jlsherrill/bugday (jlsherrill@gmail.com)
- Merge pull request #1301 from ehelms/855945 (ericdhelms@gmail.com)
- removing console.log (jsherril@redhat.com)
- Merge pull request #1309 from ehelms/791345 (ericdhelms@gmail.com)
- 751159 - downloading a modified system template would present warning
  (jsherril@redhat.com)
- 820404- Renamed the debug cert button as suggested in the bz
  (paji@redhat.com)
- 831362 - systems - disable/enable system group widget on actions panel
  (bbuckingham@redhat.com)
- 869371-ram - able to set RAM during new system creation in UI
  (thomasmckay@redhat.com)
- 848566 - fixing verbage of system group limit (jsherril@redhat.com)
- 848553 - tupane - remove 'do_not_open' on copy (bbuckingham@redhat.com)
- user searches containing empty display attributes are no longer being saved
  in the history (dmitri@redhat.com)
- 858743 - Stop redirect after login to ajax notices path
  (daviddavis@redhat.com)
- 842745 - Fixed rspec test (daviddavis@redhat.com)
- Merge pull request #1285 from ehelms/bug-857061 (ericdhelms@gmail.com)
- 844708 - update panel action confirmation dialog to close on 'yes' click
  (bbuckingham@redhat.com)
- 842745 - Showing update message on package group update
  (daviddavis@redhat.com)
- Code review comments lead to discovery of dead code. The import_status and
  export_status files do not appear tied to any controller and they are only
  referenced by a route which is also not tied to a controller
  (bkearney@redhat.com)
- 878891-actkey-alignment - put act keys into table (thomasmckay@redhat.com)
- 873665 - getting rid of last find_by_username admin calls
  (lzap+git@redhat.com)
- 808461 - prevent from creating a repo in rh providers (lzap+git@redhat.com)
- 875225 - Binding favicon refresh to hash change (daviddavis@redhat.com)
- 888019 - fixing issue where only 10 repos would appear on content search
  (jsherril@redhat.com)
- 843421 - systems - include summary when removing system groups using bulk
  action (bbuckingham@redhat.com)
- Merge pull request #1281 from jsomara/882248 (jsomara@gmail.com)
- Merge pull request #1282 from ehelms/bug-839934 (ericdhelms@gmail.com)
- Merge branch 'master' into merge-to-v2 (paji@redhat.com)
- Fix for not loading system template detail (mhulan@redhat.com)
- Fixing a non-deterministic text failure (jomara@redhat.com)
- 848571 - fixing verbage on content search (jsherril@redhat.com)
- Merge pull request #1277 from daviddavis/favicon_fix (daviddavis@redhat.com)
- 882248 - making environment name editable (jomara@redhat.com)
- 806096 fix - display checkboxes to readonly users (mhulan@redhat.com)
- 875225 - Refreshing favicon to ensure its presence (daviddavis@redhat.com)
- 868045: Missed translating string when there are no products for a system
  (bkearney@redhat.com)
- 784326 fix for mixed locale for admin (mhulan@redhat.com)
- 781287 fix - update notification counter (mhulan@redhat.com)
- Fixes few typos (ares@igloonet.cz)
- 835902 fixes notification for GPG key upload (ares@igloonet.cz)
- logging - orchestration log rotating (lzap+git@redhat.com)
- logging - orchestration logger and uuid request tracking
  (lzap+git@redhat.com)
- Automatic commit of package [katello] release [1.3.1-1]. (msuchy@redhat.com)
- remove requires rubygem(execjs) and rubygem(multi_json) (msuchy@redhat.com)
- Merging master to pulpv2 (paji@redhat.com)
- Merge pull request #1263 from bbuckingham/fork_content_views
  (daviddavis@redhat.com)
- Content views: fixing tests due to == returning false (daviddavis@redhat.com)
- Content views: api refresh test (daviddavis@redhat.com)
- Content views: refreshing views from the CLI (daviddavis@redhat.com)
- Merge pull request #1264 from jsomara/878191 (jsomara@gmail.com)
- Removing OR for pipeor (jomara@redhat.com)
- Content views: temporarily fix breaking tests (daviddavis@redhat.com)
- Merge pull request #1262 from daviddavis/cv_act_key (daviddavis@redhat.com)
- content views - shorten length of couple of lines (bbuckingham@redhat.com)
- initial repo discovery UI (jsherril@redhat.com)
- Consumer.get was returning a 410 and surfacing that instead of continuing to
  delete the deletion record (jomara@redhat.com)
- content views - support refresh as 'async' in UI (includes backend chgs)
  (bbuckingham@redhat.com)
- Merge pull request #1251 from daviddavis/cv_tests (daviddavis@redhat.com)
- Merge branch 'master' into story/configuration (pchalupa@redhat.com)
- Fixes 790216 running changesets concurently (ares@igloonet.cz)
- 885261 - org deletion unit test correction (lzap+git@redhat.com)
- Merge pull request #1260 from jlsherrill/pulpv2 (jlsherrill@gmail.com)
- Content views: activation key without cv test (daviddavis@redhat.com)
- Content views: added activation key and validation (daviddavis@redhat.com)
- changing assert to assert_equals (jsherril@redhat.com)
- Merge pull request #1258 from jsomara/878191 (jsomara@gmail.com)
- adding file based repo discovery test, fixing small file based issue
  (jsherril@redhat.com)
- 885261 - make data repair script to work from any dir (lzap+git@redhat.com)
- 885261 - org deletion should remove rh provider (lzap+git@redhat.com)
- fixing mistaken comment in Gemfile (jsherril@redhat.com)
- adding new gem for web crawling (jsherril@redhat.com)
- spec test update (jsherril@redhat.com)
- 878191 - allowing non-consumer access to deletion record remove
  (jomara@redhat.com)
- comment update (jsherril@redhat.com)
- Setting haml-rails to 0.3.4 to fix error (daviddavis@redhat.com)
- Merge pull request #1227 from ares/bug/878156-gpg_key_wizard_refactoring
  (ares@igloonet.cz)
- Merge pull request #1249 from iNecas/apipie-maruku (inecas@redhat.com)
- Use maruku instead of redcarpet for markdown -> html (inecas@redhat.com)
- Merge pull request #1244 from knowncitizen/i18n_fix (jrist@redhat.com)
- Merge pull request #1255 from jsomara/881616 (jsomara@gmail.com)
- 881616 - showing UNLIMITED instead of -1 on activation keys edit
  (jomara@redhat.com)
- Merge pull request #1245 from thomasmckay/877894-i18n
  (thomasmckay@redhat.com)
- Merge pull request #1235 from jsomara/880113 (jsomara@gmail.com)
- Merge pull request #1250 from tstrachota/proxies (tstrachota@redhat.com)
- content views - update views treetable to reinitialize on content change
  (bbuckingham@redhat.com)
- content views - address 2 minor comments from PR review
  (bbuckingham@redhat.com)
- content views - ui - refresh - update views pane after refresh
  (bbuckingham@redhat.com)
- content views - initial ui changes to support view refresh
  (bbuckingham@redhat.com)
- content views - initial model changes to support view refresh
  (bbuckingham@redhat.com)
- content views - updates to views pane to better support multiple versions
  (bbuckingham@redhat.com)
- Content views: Added tests for new arguments (daviddavis@redhat.com)
- apipie - fix in loading nested controllers (tstrachota@redhat.com)
- smart proxies - api controller (tstrachota@redhat.com)
- better error messages (pchalupa@redhat.com)
- Merge pull request #1239 from
  ares/bug/855433-gpg_key_repository_assignment_listing (ares@igloonet.cz)
- Merge pull request #1241 from daviddavis/cvd_args (daviddavis@redhat.com)
- katello-jobs-locale - corrected missing method call
  extract_locale_from_accept_language_header (thomasmckay@redhat.com)
- Content views: fixed tests and feedback for def args (daviddavis@redhat.com)
- Merge pull request #1225 from daviddavis/cv_args (daviddavis@redhat.com)
- Merge pull request #1214 from daviddavis/cv_demotion (daviddavis@redhat.com)
- 877894-i18n - remove N_ to allow match w/ translation
  (thomasmckay@redhat.com)
- Upstream alchemy hash for i18n. (jrist@redhat.com)
- Fixes a few i18n issues:  - i18n forced to browser locale on login page  -
  fixes a few items via alchemy for login page i18n. (jrist@redhat.com)
- Ruby19 - Fixes issue with array symbols appearing in UI when running on Ruby
  1.9+. (ehelms@redhat.com)
- Merge pull request #1238 from knowncitizen/interstitial_fix
  (jrist@redhat.com)
- Minor simplification of the content_for(:content) block (jrist@redhat.com)
- Reverting a critical missing space and indenting for readability.
  (jrist@redhat.com)
- Merge pull request #1233 from thomasmckay/katello-jobs-locale
  (thomasmckay@redhat.com)
- Merge pull request #1234 from thomasmckay/ja-validation
  (thomasmckay@redhat.com)
- Merge pull request #1236 from daviddavis/ping (daviddavis@redhat.com)
- Merge pull request #1193 from tstrachota/completion (miroslav@suchy.cz)
- Enhancement for former fix for 864565 (ares@igloonet.cz)
- Fixes 855433 bug - display GPG keys repositories (ares@igloonet.cz)
- Ordering of user_session caused interstitial to not load due to string
  change. (jrist@redhat.com)
- Add elasticsearch package to ping information (daviddavis@redhat.com)
- 880113 - special validation for pool ids searching with ? (jomara@redhat.com)
- ja-validation - updated ja.yml file from https://github.com/svenfuchs/rails-
  i18n (thomasmckay@redhat.com)
- Content views: added id and name to cli definition commands
  (daviddavis@redhat.com)
- katello-jobs-locale - set user's locale (thomasmckay@redhat.com)
- Content views: removing old test (daviddavis@redhat.com)
- 860301: Updated specs for reset notice fixes (daviddavis@redhat.com)
- 860301: Showing notices for username and password resets
  (daviddavis@redhat.com)
- Use spaces instead of tabs (ares@igloonet.cz)
- Spec refactoring (ares@igloonet.cz)
- Spec refactoring (ares@igloonet.cz)
- delayed_jobs - fix for passing bundler ext environment variables
  (tstrachota@redhat.com)
- Fixes 878156 bug with GPG key updating (ares@igloonet.cz)
- Content views: added id and name to cv arguments (daviddavis@redhat.com)
- Merge pull request #1222 from lzap/development-perms (miroslav@suchy.cz)
- cli - packaged completion script (tstrachota@redhat.com)
- cli - python based shell completion (tstrachota@redhat.com)
- bundler.d - not need to require ci plugin (lzap+git@redhat.com)
- bundler.d - correcting permissions for development mode (lzap+git@redhat.com)
- ping - correcting return code for ping controller (lzap+git@redhat.com)
- 858726 - Sets the compare repos button to disable if there are 0 or 1 repos
  enabled on content search. (ehelms@redhat.com)
- 817858 - Permission edits now show tags when appropriate. (ehelms@redhat.com)
- 791345 - Deletes errant tick mark that was appearing after list updates on
  the sync plan page. (ehelms@redhat.com)
- 843566 - Sets the chosen dropdown in Content Search to not display a filter
  mechanism. (ehelms@redhat.com)
- 855945 - Content search now displays the Library if there are no
  environments. (ehelms@redhat.com)
- 871093 - Fix to show tags when "+ All" verbs is selected. (ehelms@redhat.com)
- 845062 - Fixes typo with errata search icon tooltip. (ehelms@redhat.com)
- 772199 - Adds a tool tip to explain that GPG keys are optional for products
  and repositories. (ehelms@redhat.com)
- 839394 - Changes wording on sync management page when no repositories are
  enabled to cross-link to custom repos and red hat provider link.
  (ehelms@redhat.com)
- 857061 - System template actions on the right pane will now close whenever
  the new system template button is clicked. (ehelms@redhat.com)
- Merge pull request #1216 from bbuckingham/fork_880710
  (bbuckingham@redhat.com)
- 880710 - api systems controller - query org by name or label
  (bbuckingham@redhat.com)
- Merge branch 'master' into story/configuration (pchalupa@redhat.com)
- architectures ui - architectures tied to operating systems - new model for
  operating systems - helper for operating system multiselect
  (tstrachota@redhat.com)
- abstract model - dsl for setting resource name (tstrachota@redhat.com)
- abstract model - processing apipie exceptions (tstrachota@redhat.com)
- architectures ui - basic crud actions (tstrachota@redhat.com)
- Merge pull request #1211 from daviddavis/cv_env (daviddavis@redhat.com)
- Merge pull request #1215 from bbuckingham/fork_880710 (lzap@redhat.com)
- Bumping package versions for 1.3. (ehelms@redhat.com)
- 880710 - api - updates to use org id or label when retrieving org
  (bbuckingham@redhat.com)
- Automatic commit of package [katello] release [1.2.2-1]. (ehelms@redhat.com)
- Merge pull request #1203 from bbuckingham/fork_content_views
  (daviddavis@redhat.com)
- content views - fix for specs failing in ruby 1.9.3 (bbuckingham@redhat.com)
- Content views: worked on changeset deletion of views (daviddavis@redhat.com)
- rake gettext:find was yelling about in improperly formatted haml file
  (komidore64@gmail.com)
- Merge pull request #1209 from ehelms/alchemy-update (ericdhelms@gmail.com)
- Spec - Adds line to dynamically determine installation directory of Alchemy.
  (ehelms@redhat.com)
- Content views: showing repo info in cli (daviddavis@redhat.com)
- Spec - Updates to new alchemy inclusion location in spec. (ehelms@redhat.com)
- bundler.d - adding new packages to the comp files (lzap+git@redhat.com)
- bundler.d - moving ci group into build and dev only file
  (lzap+git@redhat.com)
- Alchemy - Submodule hash update. (ehelms@redhat.com)
- String - Fixes malformed i18n string. (ehelms@redhat.com)
- Alchemy - Spec file updates for Alchemy. (ehelms@redhat.com)
- Alchemy - Updates for pathing related to the codebase change in Alchemy.
  (ehelms@redhat.com)
- Merge pull request #1199 from knowncitizen/converge_updates
  (ericdhelms@gmail.com)
- Minor fixes for content_search and about page. (jrist@redhat.com)
- content views - spec fixes based on changes to support default content views
  (bbuckingham@redhat.com)
- bundler.d - not distributing build gem group (lzap+git@redhat.com)
- Fix build_pxe_default call (inecas@redhat.com)
- Updating to lower case url.  Removing comment from previous test.
  (jrist@redhat.com)
- Fixing the password reset edit method and associated test. (jrist@redhat.com)
- Merge pull request #1198 from thomasmckay/883949-portugese
  (thomasmckay@redhat.com)
- 883949-portugese - change config mapping or portugese locale
  (thomasmckay@redhat.com)
- Content views: changesets can have views in CLI (daviddavis@redhat.com)
- Merge pull request #1196 from thomasmckay/883949-chinese
  (thomasmckay@redhat.com)
- 883949-chinese - change config mapping for chinese locale
  (thomasmckay@redhat.com)
- bundler.d - changes for build time (apipie) (lzap+git@redhat.com)
- content views - update product.repos to handle default content view
  (bbuckingham@redhat.com)
- Content views: remove checking for promotion (daviddavis@redhat.com)
- Merge pull request #1182 from ehelms/bash-completion-update
  (ericdhelms@gmail.com)
- bundler.d - pull request review fixes (lzap+git@redhat.com)
- bundler.d - applying changes for the spec (lzap+git@redhat.com)
- bundler.d - copying only some gems from test into dev (lzap+git@redhat.com)
- bundler.d - adding support for jruby (lzap+git@redhat.com)
- bundler.d - adding test group in development env (lzap+git@redhat.com)
- bundler.d - introcuding dynamic loading of gems (lzap+git@redhat.com)
- bunndler.d - cleaning Gemfile (lzap+git@redhat.com)
- fix 1.9 incompatibility (pchalupa@redhat.com)
- Merge branch 'master' into story/configuration (pchalupa@redhat.com)
- Password and Username Reset fixed. (jrist@redhat.com)
- Fix for missing images on fancyqueries dropdown. (jrist@redhat.com)
- Merge branch 'master' into converge_updates (jrist@redhat.com)
- Merge pull request #1181 from mccun934/add-foreman-service
  (miroslav@suchy.cz)
- Update git submodule to UI-Alchemy (alchemy), small fix for dashboard.
  (jrist@redhat.com)
- Fixed some unit test failures (paji@redhat.com)
- Content views: tweaks and fixes for promotion (daviddavis@redhat.com)
- Removed a typo that got added in the previous migration commit
  (paji@redhat.com)
- Updated js routes after removing filters (paji@redhat.com)
- Content views: renamed content views controller test (daviddavis@redhat.com)
- content views - update changesets content tree to retrieve repos from default
  view (bbuckingham@redhat.com)
- Modified the migration scripts to work for a fresh install (paji@redhat.com)
- Removed filters from the cli (paji@redhat.com)
- Wiped out other filter related artifacts (paji@redhat.com)
- Good Bye filter search (paji@redhat.com)
- Removing Filter related models (paji@redhat.com)
- Merge pull request #1187 from daviddavis/ci_reporter_fix
  (daviddavis@redhat.com)
- Merge remote-tracking branch 'og/missingword' (ogmaciel@gnome.org)
- Merge pull request #1185 from komidore64/overlap_issues (jrist@redhat.com)
- Locking ci_reporter version due to errors in jekins (daviddavis@redhat.com)
- Added missing word 'find' in filters searching message. (ogmaciel@gnome.org)
- 876896, 876911, 878355, 878750, 874502, 874510 - Fixed panel-name/new-link
  overlap (komidore64@gmail.com)
- only restart foreman if it is installed (mmccune@redhat.com)
- Lock therubyracer to beta version to fix jenkins (daviddavis@redhat.com)
- Merge pull request #1179 from thomasmckay/i18n-fixes (thomasmckay@redhat.com)
- Merge pull request #1183 from komidore64/foreman_fencing (jrist@redhat.com)
- content views - add content view to changeset history
  (bbuckingham@redhat.com)
- Merge pull request #1175 from bbuckingham/fork_content_views
  (bbuckingham@redhat.com)
- fixing foreman fencing that facilitated a failure (komidore64@gmail.com)
- Merge pull request #1174 from daviddavis/cv_promote (daviddavis@redhat.com)
- i18n-fixes - updating missing localizations, including time format
  (thomasmckay@redhat.com)
- Bash Completion - Updates bash completion with current command and sub-
  command sets. (ehelms@redhat.com)
- including foreman as a service to start/stop with Katello
  (mmccune@redhat.com)
- 877947-clear-es - added index clean up after import and after delete manifest
  (thomasmckay@redhat.com)
- Content views: removed promotion code out of api controller
  (daviddavis@redhat.com)
- Content views: reworking generate_repos (daviddavis@redhat.com)
- Merge branch 'master' into converge_updates (jrist@redhat.com)
- Added a check for anything besides html and json response for user#new
  (jrist@redhat.com)
- Content views: updated content view api tests (daviddavis@redhat.com)
- 868872 - do not distribute katello-reset-dbs (msuchy@redhat.com)
- Merge branch 'master' into story/configuration (pchalupa@redhat.com)
- Content views: handling async view promotion (daviddavis@redhat.com)
- fix rpm build process (pchalupa@redhat.com)
- Content views: creating changeset during promotion shortcut
  (daviddavis@redhat.com)
- content views - on changesets page, allow user to see view details
  (bbuckingham@redhat.com)
- Merge pull request #1172 from bbuckingham/fork_content_views
  (parthaa@gmail.com)
- PulpV2 - Removing unused functions and errant debugger. (ehelms@redhat.com)
- Merge pull request #1173 from weissjeffm/menu-keys-ids
  (thomasmckay@redhat.com)
- Content views: versions are dependent destroy (daviddavis@redhat.com)
- Merge pull request #1169 from knowncitizen/876869 (jrist@redhat.com)
- Content views: added cli promote command (daviddavis@redhat.com)
- Content views: added promote action to cv api (daviddavis@redhat.com)
- Added some support code for minitest controller specs (daviddavis@redhat.com)
- Change menu keys so that no menu items end up having same html 'id'
  attribute. (jweiss@redhat.com)
- PuplV2 - Fix to make list inclusion test less dynamic. (ehelms@redhat.com)
- content views - update UI to allow for changesets containing content views
  (bbuckingham@redhat.com)
- content views - add scopes to content_view_version (bbuckingham@redhat.com)
- content view - update changeset to allow deleting content view
  (bbuckingham@redhat.com)
- initial repo discovery work (jsherril@redhat.com)
- fixing code causing busted test (komidore64@gmail.com)
- 876869 - Adjusting overflow and ellipsis for Roles page. (jrist@redhat.com)
- Content views: fixed bug with content view repos getting published
  (daviddavis@redhat.com)
- Merge pull request #1159 from komidore64/headpin-system-multi
  (komidore64@gmail.com)
- Merge remote-tracking branch 'og/escapedhtml' (ogmaciel@gnome.org)
- Merge pull request #1160 from daviddavis/travis_gemfiles
  (daviddavis@redhat.com)
- Fixes Bug 882294 - HTML element being rendered unescaped in promotions help
  tip. (ogmaciel@gnome.org)
- Fixes the width of the application to 1152px. Fixes the login.
  (jrist@redhat.com)
- Merge pull request #1163 from mbacovsky/fence_off_foreman_controllers
  (martin.bacovsky@gmail.com)
- Move foreman UI to glue foreman (mbacovsk@redhat.com)
- Provide the headers for when pinging Foreman (inecas@redhat.com)
- Having TravisCI test our Gemfile.locks (daviddavis@redhat.com)
- Merge branch 'pulpv2' of github.com:Katello/katello into pulpv2
  (ehelms@redhat.com)
- content views - ui - initial code for the view definition -> Views pane
  (bbuckingham@redhat.com)
- 878693 - [RFE] Selecting multiple systems does not give me any action
  (komidore64@gmail.com)
- Merge pull request #1143 from bbuckingham/fork_content_views-2
  (bbuckingham@redhat.com)
- PulpV2 - Introduces the small Hooks gem and implements association hooks for
  system and system groups in order to create/remove the appropriate instances
  in Pulp as well as update elasticsearch. (ehelms@redhat.com)
- 880116 - pool was referencing a non-existant instance variable
  (jomara@redhat.com)
- allow beta of therubyracer (msuchy@redhat.com)
- being more specific about runcible version (jsherril@redhat.com)
- Merge pull request #1130 from daviddavis/cv_random_fixes
  (daviddavis@redhat.com)
- content views - minor cleanup (bbuckingham@redhat.com)
- Merge branch 'master' into story/configuration (pchalupa@redhat.com)
- Merge pull request #1123 from pitr-ch/quick-fix/gem-versions
  (kontakt@pitr.ch)
- Merge pull request #1125 from xsuchy/pull-req-jshintrb2 (miroslav@suchy.cz)
- Merge pull request #1147 from mbacovsky/foreman_stuf_in_debug
  (martin.bacovsky@gmail.com)
- Merge pull request #1149 from lzap/bext-path-fix (miroslav@suchy.cz)
- remove fix for Apipie v0.0.12 and switch to v0.0.13 (pchalupa@redhat.com)
- bundler_ext development - correcting path for dev mode (lzap+git@redhat.com)
- Revert "Foreman environment orchestration" (mbacovsk@redhat.com)
- Added Foreman stuff to katello-debug (mbacovsk@redhat.com)
- runcible version requirement bump (jsherril@redhat.com)
- Merge pull request #1144 from daviddavis/cv_act_key (daviddavis@redhat.com)
- Merge pull request #1141 from komidore64/library_no_i18n
  (komidore64@gmail.com)
- Content views: fixed bug in definition api controller (daviddavis@redhat.com)
- content views - ui - initial code for the view definition -> content pane
  (bbuckingham@redhat.com)
- content views - ui - add the skeleton to support views, content, filter panes
  (bbuckingham@redhat.com)
- fixing build issue caused by 56de39ba17b446a2e511c4cbf57728a548581cf4
  (komidore64@gmail.com)
- check-gettext - correct count of malformed strings (inecas@redhat.com)
- Merge pull request #1138 from komidore64/library_no_i18n
  (komidore64@gmail.com)
- 878341 - [ja_JP][SAM Web GUI] Default environment name 'Library' should not
  be localized. (komidore64@gmail.com)
- 880905 - certain locales were not escaped properly (jomara@redhat.com)
- cassette update (jsherril@redhat.com)
- promoting package groups with repos (jsherril@redhat.com)
- Merge pull request #1133 from jlsherrill/pdfreader (jlsherrill@gmail.com)
- Merge pull request #1137 from daviddavis/f16_gemfilelock
  (daviddavis@redhat.com)
- Merge pull request #1118 from lzap/be-fix (lzap@redhat.com)
- spec fix (jsherril@redhat.com)
- Merge pull request #1129 from komidore64/katellodebug (komidore64@gmail.com)
- Setting gem versions based on katello-devel-all.rpm (daviddavis@redhat.com)
- Merge pull request #1134 from daviddavis/f17_gem (daviddavis@redhat.com)
- updating comment for pdf-reader requirement (jsherril@redhat.com)
- Merge pull request #1121 from pitr-ch/quick-fix/broken_unit_test
  (kontakt@pitr.ch)
- Foreman environment orchestration (mbacovsk@redhat.com)
- pulpv2 - fixing promotion/demotion (jsherril@redhat.com)
- Updated F17 Gemfile.lock (daviddavis@redhat.com)
- requiring specific older version of pdf-reader (jsherril@redhat.com)
- Merge pull request #1132 from omaciel/master (thomasmckay@redhat.com)
- Fixed small typo s/Subscriptons/Subscriptions. (ogmaciel@gnome.org)
- Content views: couple of small fixes (daviddavis@redhat.com)
- commenting out autoreload support for runcible (jsherril@redhat.com)
- Content views: cli info and list work (daviddavis@redhat.com)
- 866972 - katello-debug needs to take headpin into consideration
  (komidore64@gmail.com)
- Ensure that the name and label is unique across all all orgs
  (bkearney@redhat.com)
- Content views: re-enabled info cli commands (daviddavis@redhat.com)
- update gems jshintrb and therubyracer (msuchy@redhat.com)
- fix unit tests when foreman is disabled (pchalupa@redhat.com)
- Content views: fixing api controller specs (daviddavis@redhat.com)
- Content views: worked on api controllers and perms (daviddavis@redhat.com)
- Fixed js routes (daviddavis@redhat.com)
- Merge branch 'pulpv2' of github.com:Katello/katello into pulpv2
  (ehelms@redhat.com)
- Merge remote-tracking branch 'upstream/pulpv2' into content_views
  (daviddavis@redhat.com)
- bundler_ext - development mode support
- Merge branch 'master' of github.com:Katello/katello into pulpv2-master
  (ehelms@redhat.com)
- PulpV2 - Adds ActiveSupport dependency clearing to resolve issue with running
  multiple test sets together. (ehelms@redhat.com)
- PulpV2 - Minor fixes and cleanup. (ehelms@redhat.com)
- PulpV2 - Adds an authorization base file that all authorization tests inherit
  from.  Moves user and repository model tests to use an inherited base instead
  of a module. (ehelms@redhat.com)
- PulpV2 - Fixes up some Glue layer fencing. (ehelms@redhat.com)
- PulpV2 - Fixes spec that was stubbing a changed API method.
  (ehelms@redhat.com)
- PulpV2 - Adds consumer glue layer tests. (ehelms@redhat.com)
- PulpV2 - Adds Distribution, Package and Errata glue layer tests. Adds support
  modules for Repositories and Tasks. (ehelms@redhat.com)
- PulpV2 - Adds task to find untested methods. (ehelms@redhat.com)
- fix packaging and katello-configure (pchalupa@redhat.com)
- new foreman_api version in gemfile (tstrachota@redhat.com)
- subnets - change data hash sent to foreman (tstrachota@redhat.com)
- abstract model - fix for indexed models not being deleted
  (tstrachota@redhat.com)
- abstract model - separate module for indexed model (tstrachota@redhat.com)
- subnet ui - workaround for bug in chosen (tstrachota@redhat.com)
- foreman ui - helpers for resource select boxes (tstrachota@redhat.com)
- foreman ui - refactoring (tstrachota@redhat.com)
- subnets - elastic search indexing (tstrachota@redhat.com)
- domain ui - controller and es indexing (tstrachota@redhat.com)
- abstract model - support for callbacks (tstrachota@redhat.com)
- forman menu - new setup menu (tstrachota@redhat.com)
- subnets ui - select boxes for domains and smart proxies
  (tstrachota@redhat.com)
- smart proxies - new model (tstrachota@redhat.com)
- subnets ui - basic CRUD actions (tstrachota@redhat.com)
- subnets - model and api controller (tstrachota@redhat.com)
- bundler_ext - require also :foreman until all require is merged
  (lzap+git@redhat.com)
- require bundler_ext - especially in buildtime (msuchy@redhat.com)
- Merge pull request #1096 from lzap/bundler_ext (lzap@redhat.com)
- setup bundler before Application definition (pchalupa@redhat.com)
- remove ENV from config.ru (pchalupa@redhat.com)
- Merge branch 'master' into story/configuration (pchalupa@redhat.com)
- Merge pull request #1106 from xsuchy/pull-req-jshintrb (miroslav@suchy.cz)
- Merge pull request #1103 from lzap/foreman-ping-support (lzap@redhat.com)
- Merge pull request #1105 from ehelms/gemfile-update (jlsherrill@gmail.com)
- Gemfile - Adds comment marking dependency. (ehelms@redhat.com)
- add rubygem-jshintrb (msuchy@redhat.com)
- add rubygem-libv8 to katello-devel-jshintrb (msuchy@redhat.com)
- add parallel_tests to devel dependecies (msuchy@redhat.com)
- Gemfile - Adds explicit require in development,test for sexp_processor due to
  not being pulled in as a dependency of ruby_parser in development.
  (ehelms@redhat.com)
- 875185 - fixing enabled redhat repos page (jsherril@redhat.com)
- add foreman ping support (lzap+git@redhat.com)
- merge conflict (jsherril@redhat.com)
- content views - update routes.js (bbuckingham@redhat.com)
- Additional color overrides, fixes for many small things throughout.
  (jrist@redhat.com)
- minitest fix (jsherril@redhat.com)
- spect fix (jsherril@redhat.com)
- spec fixes (jsherril@redhat.com)
- Merge pull request #1092 from komidore64/org_create_lib
  (thomasmckay@redhat.com)
- spec fixes (jsherril@redhat.com)
- introducing bundler_ext rubygem (lzap+git@redhat.com)
- spec fixes (jsherril@redhat.com)
- spec fixes (jsherril@redhat.com)
- Merge pull request #1093 from jlsherrill/debugging (jlsherrill@gmail.com)
- PulpV2 - Adds Runcible to spec file. (ehelms@redhat.com)
- PulpV2 - Switches the branch to start using Runcible from gem.
  (ehelms@redhat.com)
- fixing env check to look for true (jsherril@redhat.com)
- addressing PR comments (jsherril@redhat.com)
- spec fixes (jsherril@redhat.com)
- enabling debugger gem group by default (jsherril@redhat.com)
- Merge pull request #1091 from thomasmckay/875609-hypervisor
  (thomasmckay@redhat.com)
- 873038 - Entering an env name of "Library" when creating an organization does
  not give clear error message (komidore64@gmail.com)
- 875609-hypervisor - allow hypervisors to successfully register and list in
  katello (thomasmckay@redhat.com)
- fixing errata_ids (jsherril@redhat.com)
- one last clone_id fix (jsherril@redhat.com)
- 874280 - terminology changes for consistency across subman, candlepin, etc
  (jomara@redhat.com)
- cassette updates (jsherril@redhat.com)
- fixing some more spects (jsherril@redhat.com)
- simplifying sorting (jsherril@redhat.com)
- commit comment fixes (jsherril@redhat.com)
- spec fixes (jsherril@redhat.com)
- Translations - Update .po and .pot files for katello. (ehelms@redhat.com)
- Translations - New translations from Transifex for katello.
  (ehelms@redhat.com)
- Translations - Download translations from Transifex for katello.
  (ehelms@redhat.com)
- merge conflict (jsherril@redhat.com)
- content views - migrating to using CV version (jsherril@redhat.com)
- Merge pull request #1066 from tstrachota/ui-editable-helper
  (tstrachota@redhat.com)
- cassette updates (jsherril@redhat.com)
- spec test fix (jsherril@redhat.com)
- adding comment (jsherril@redhat.com)
- merge conflict (jsherril@redhat.com)
- Merge pull request #1080 from daviddavis/cv_test_fixes (jlsherrill@gmail.com)
- spec fixes (jsherril@redhat.com)
- Content views: fixing auth test (daviddavis@redhat.com)
- Content views: remove ruby-debug (daviddavis@redhat.com)
- 877473-fencing - force use_foreman and use_pulp off for headpin
  (thomasmckay@redhat.com)
- Content views: fixed authorization bug (daviddavis@redhat.com)
- Content views: fixed content view def test (daviddavis@redhat.com)
- Merge remote-tracking branch 'upstream/pulpv2' into content_views
  (daviddavis@redhat.com)
- PulpV2 - Fixes up errata tests for a repository with Pulp beta.
  (ehelms@redhat.com)
- PulpV2 - Cleans up asserts for friendlier output. (ehelms@redhat.com)
- pulpv2 - migrating to using unit_id as the errata id (jsherril@redhat.com)
- Merge pull request #1063 from komidore64/katellodebug (komidore64@gmail.com)
- PulpV2 - Adds encoding for the UTF-8 characters for 1.9.3 (ehelms@redhat.com)
- PulpV2 - Updates to fix glue layer and tests for newest pulp beta.
  (ehelms@redhat.com)
- Merge pull request #1073 from bbuckingham/fork_content_views
  (bbuckingham@redhat.com)
- content views - shorting nav label to use Views (bbuckingham@redhat.com)
- Merge pull request #1067 from bbuckingham/fork-pulpv2-consumer
  (jlsherrill@gmail.com)
- pulpv2 - convert status to string (bbuckingham@redhat.com)
- pulpv2 - remove UNARCHIVED_FINISH state from task status
  (bbuckingham@redhat.com)
- Merge pull request #1068 from mccun934/devboost-on-all-the-time
  (mmccune@gmail.com)
- changed deployment checking (komidore64@gmail.com)
- Merge branch 'master' into story/configuration (pchalupa@redhat.com)
- force devboost to be on in development mode. (mmccune@redhat.com)
- fix monkey patch when RSpec::Version is undefined (pchalupa@redhat.com)
- Merge branch 'master' into story/foreman_spec (pchalupa@redhat.com)
- fix warning text (pchalupa@redhat.com)
- add better definitions of configuration validation (pchalupa@redhat.com)
- Merge pull request #1060 from bbuckingham/fork_content_views
  (bbuckingham@redhat.com)
- pulpv2 - update to use 'finished' for task status state
  (bbuckingham@redhat.com)
- do not try to generate a remote id if validation fails (jsherril@redhat.com)
- ui - helper method for rendering editables (tstrachota@redhat.com)
- merge conflict (jsherril@redhat.com)
- remove deprecated ApiConfig (pchalupa@redhat.com)
- Merge pull request #1061 from lzap/upgrade-redesign2 (lzap@redhat.com)
- 874391-mandel - async job behind deleting manifest (thomasmckay@redhat.com)
- 866972 - katello-debug needs to take headpin into consideration
  (komidore64@gmail.com)
- make bundler happy (msuchy@redhat.com)
- Merge pull request #1050 from witlessbird/1.9.3-fixes (witlessbird@gmail.com)
- Merge pull request #960 from jhadvig/system_packages_search_redo
  (j.hadvig@gmail.com)
- katello-upgrade redesign (lzap+git@redhat.com)
- Merge pull request #1057 from ehelms/rspec-reference-fix
  (daviddavis@redhat.com)
- content view - allow publishing to views by giving name/lable/description
  (jsherril@redhat.com)
- removing relative path function that is no longer needed
  (jsherril@redhat.com)
- content views - ui - initial CRUD support for name/label/description
  (bbuckingham@redhat.com)
- Rspec - Fixes broken Rspec test. (ehelms@redhat.com)
- Content views: content view permissions and tests (daviddavis@redhat.com)
- Rspec - Fixes issue with referencing Rspec version caused by newest version
  to fix unit test runs. (ehelms@redhat.com)
- Gemfile - Fixes reference to Ruport git. (ehelms@redhat.com)
- Merge branch 'content_views' of https://github.com/Katello/katello into
  content_views (jsherril@redhat.com)
- changed logging remote_id to username based on suggestions in the pull
  request (paji@redhat.com)
- Made app cntlr use remote id instead of username (paji@redhat.com)
- Added 2 user tests one for email and one i18n (paji@redhat.com)
- Changed the place where the remote_id for user is generated (paji@redhat.com)
- Removed a white space issue based on PR comments (paji@redhat.com)
- Added changes recommended in the pull request (paji@redhat.com)
- Modified code to allow utf8 usernames (paji@redhat.com)
- Merge pull request #1046 from bbuckingham/fork-pulpv2-consumer
  (parthaa@gmail.com)
- content view - lots of changes to support repos (jsherril@redhat.com)
- Content views: fixed definition auth bugs (daviddavis@redhat.com)
- Merge pull request #1008 from parthaa/subs-page-fix (thomasmckay@redhat.com)
- switched to a more succinct way to open a binary file (dmitri@redhat.com)
- Content views: created publish permission (daviddavis@redhat.com)
- Setting therubyracer version (daviddavis@redhat.com)
- make sure katello_config is loadable stand-alone (pchalupa@redhat.com)
- fixed a few issues dicovered when running under 1.9.3 (dmitri@redhat.com)
- sort available locales (pchalupa@redhat.com)
- clean up configuration (pchalupa@redhat.com)
- content views - making view deletion support repos (jsherril@redhat.com)
- content views - allow publication of content views definitions with repos
  (jsherril@redhat.com)
- pulpv2 - consumer - updates for changes in task structure
  (bbuckingham@redhat.com)
- pulpv2 - remove migrated consumer apis from repo.rb (bbuckingham@redhat.com)
- Added unmerged changes from commit 2bcbb432322646d13a6ab74b601035dc2dc2741e
  to consumer.rb (paji@redhat.com)
- Revert "Revert "Fixed katello.spec for Ruport"" (msuchy@redhat.com)
- Revert "Revert "Fixed Gemfile for Ruport"" (msuchy@redhat.com)
- Revert "Revert "Fixing Ruport depend. on Prawn"" (msuchy@redhat.com)
- Revert "Revert "Fixing Gemfile depend."" (msuchy@redhat.com)
- Revert "Revert "Fixing Ruport dependencies"" (msuchy@redhat.com)
- Revert "Revert "Prawn gemfile and spec dependencies"" (msuchy@redhat.com)
- Revert "Revert "Prawn integration for PDF generation"" (msuchy@redhat.com)
- Content views: definitions habtm repos (daviddavis@redhat.com)
- Merge branch 'pulpv2' into content_views (daviddavis@redhat.com)
- Merge pull request #1033 from daviddavis/pulpv2 (jlsherrill@gmail.com)
- Content views: fixing route (daviddavis@redhat.com)
- Content views: Fixed bad merge in organization (daviddavis@redhat.com)
- content views - adding support for view deletion (jsherril@redhat.com)
- content views - adding content view promotion
- Fixed all the minitest tests (daviddavis@redhat.com)
- One more fix (paji@redhat.com)
- Fixed most glaring errors in the pulpv2 branch (paji@redhat.com)
- Pulp v2 - Fixing bad require in test (daviddavis@redhat.com)
- Content views: created auth for definitions (daviddavis@redhat.com)
- Content views: validation for composite content defs (daviddavis@redhat.com)
- Content views: added api specs (daviddavis@redhat.com)
- Content views: created add_view and remove_view (daviddavis@redhat.com)
- Content views: added env argument to list (daviddavis@redhat.com)
- Content views: removed erroneous api actions (daviddavis@redhat.com)
- Merged together duplicate factories (daviddavis@redhat.com)
- Content views: changesets check for invalid views (daviddavis@redhat.com)
- Content views: views can be added to changesets (daviddavis@redhat.com)
- Content views: created changeset association (daviddavis@redhat.com)
- Content views: fixed product :bug: with cp_id (daviddavis@redhat.com)
- Content views: added repo cli commands (daviddavis@redhat.com)
- Content views: Added repository association to def (daviddavis@redhat.com)
- Content views: Refactored composite/component (daviddavis@redhat.com)
- Content views: Added add_product for cli (daviddavis@redhat.com)
- Content views: fixed update cli command (daviddavis@redhat.com)
- Content views: added destroy to api controller/cli (daviddavis@redhat.com)
- Content views: fixed view -> product relationship (daviddavis@redhat.com)
- Content views: Worked on labels and cli (daviddavis@redhat.com)
- Content views: setup associations (daviddavis@redhat.com)
- Content views: initial setup of models (daviddavis@redhat.com)
- Pulpv2 - Switching FG to version from Fedora repos (daviddavis@redhat.com)
- fixing after_save whose function was moved to elastic_search glue
  (jsherril@redhat.com)
- Merge branch 'master' into pulpv2 (paji@redhat.com)
- Pulp v2 - Fixing bad require in test (daviddavis@redhat.com)
- fixing a regression i caused on one of my own bugs. (komidore64@gmail.com)
- Merge pull request #1020 from jsomara/873680 (jsomara@gmail.com)
- 874185 - make sure we don't try and process labels when env is nil
  (mmccune@redhat.com)
- Fixed a method name typo (paji@redhat.com)
- Merge branch 'master' into merge-to-pulp (paji@redhat.com)
- Fixed some merge Conflicts (paji@redhat.com)
- Merge pull request #1021 from komidore64/release-version
  (komidore64@gmail.com)
- 874510, 874502 (komidore64@gmail.com)
- 845620 - [RFE] Improve messaging around results of setting the yStream
  (komidore64@gmail.com)
- Merge pull request #1018 from iNecas/bz874185 (inecas@redhat.com)
- 873680 - disallowing blank socket count in system creation
  (jomara@redhat.com)
- Merge pull request #1019 from iNecas/bz853445 (mmccune@gmail.com)
- Merge pull request #1015 from thomasmckay/873809-js-error
  (thomasmckay@redhat.com)
- 853445 - correctly determine the affected repos after deletion
  (inecas@redhat.com)
- 874185 - fix the add_repository_library_id migration (inecas@redhat.com)
- Remove accidentally added file (inecas@redhat.com)
- Merge pull request #1014 from iNecas/reset-data-foreman (inecas@redhat.com)
- Merge pull request #1016 from parthaa/remove-login-credential
  (parthaa@gmail.com)
- Merge pull request #1013 from jlsherrill/pulpv2 (parthaa@gmail.com)
- Wiped out an unused file (paji@redhat.com)
- subsfilter - fixes BZ 859038 where the subscription filtering chooser would
  grab focus when the panel opens (thomasmckay@redhat.com)
- 873809-js-error - removing oboslete red hat provider code and references
  (two-pane subscriptions replaced) (thomasmckay@redhat.com)
- Merge pull request #1010 from bbuckingham/fork-864936-3
  (bbuckingham@redhat.com)
- katello-configure - support reset data for the foreman (inecas@redhat.com)
- Merge pull request #1009 from komidore64/environment-populate
  (komidore64@gmail.com)
- few small auth fixes and spacing fixes (jsherril@redhat.com)
- Get back Gemfile.lock symlink (inecas@redhat.com)
- Merge branch 'master' into story/foreman_spec (pchalupa@redhat.com)
- 864936 - products - labelize name on create entry (bbuckingham@redhat.com)
- 873302 - Environments do not populate when adding a new user without full
  admin (komidore64@gmail.com)
- Fixed the permissions to access the RH Subscriptions page (paji@redhat.com)
- spec fixes for building in pulpv2 (jsherril@redhat.com)
- Merge pull request #889 from ehelms/bug-861513 (ericdhelms@gmail.com)
- fix version comparison (pchalupa@redhat.com)
- Merge pull request #1001 from ehelms/pulpv2 (jlsherrill@gmail.com)
- Merge pull request #1004 from parthaa/cons-group-associate
  (ericdhelms@gmail.com)
- More color changes to derive from $primary and $kprimary (jrist@redhat.com)
- Fixed a SystemGroup namespace issue (paji@redhat.com)
- Changes for SystemGroup (dis)associate (paji@redhat.com)
- 864936 - small but important chg to fix manifest imports
  (bbuckingham@redhat.com)
- PulpV2 - Updates to fix tests running with Pulp and running in none mode.
  Skips currently broken tests in Pulp to make Travis green for now.
  (ehelms@redhat.com)
- do not use apipie env (jsherril@redhat.com)
- f16 gemfile update (jsherril@redhat.com)
- test (jsherril@redhat.com)
- adding test rake job to devel-test (jsherril@redhat.com)
- fixing bad translations (jsherril@redhat.com)
- merge conflict (jsherril@redhat.com)
- Merge pull request #971 from lzap/rpm-conf-files-review-635574
  (lzap@redhat.com)
- reorganizing after_sync to fit in with separation (jsherril@redhat.com)
- fixing changeset spec (jsherril@redhat.com)
- fixing single test runs (jsherril@redhat.com)
- PulpV2 - Switching distribution tests to match on path and not URI.
  (ehelms@redhat.com)
- Merge pull request #991 from bbuckingham/fork-864936 (mmccune@gmail.com)
- PulpV2 - Adds the pulp v2 API path to the katello config. (ehelms@redhat.com)
- Merge branch 'pulpv2' of https://github.com/Katello/katello into pulpv2
  (jsherril@redhat.com)
- only create content if the environment is library (jsherril@redhat.com)
- pulpv2 - changeset package fixes (jsherril@redhat.com)
- 864936 - api/cli - generate an error label provided is already in use
  (bbuckingham@redhat.com)
- PulpV2 - Removes deletion of db:test:prepare call to return 'rake spec'
  functionality back to expected behavior. (ehelms@redhat.com)
- PulpV2 - Updates to handle ruby 1.9.3 and adds inclusion of new tests into
  Travis config. (ehelms@redhat.com)
- 872686 - create a Role with single-character name fails
  (komidore64@gmail.com)
- Merge branch 'pulpv2' of https://github.com/Katello/katello into pulpv2
  (jsherril@redhat.com)
- Fixed some rspec errors (paji@redhat.com)
- 864936 - update product labels to ensure uniqueness (bbuckingham@redhat.com)
- 872096 - correcting typo in a comment (lzap+git@redhat.com)
- Merge pull request #983 from komidore64/consumer-headers
  (komidore64@gmail.com)
- Merge pull request #986 from ehelms/bug-871086 (ericdhelms@gmail.com)
- Merge pull request #987 from pitr-ch/quick-fix/remove_fuzzy_warnings
  (kontakt@pitr.ch)
- fix missing constant error when fast_gettext gem have older version
  (pchalupa@redhat.com)
- Merge pull request #974 from pitr-ch/quick-fix/remove_fuzzy_warnings
  (kontakt@pitr.ch)
- Merge pull request #982 from iNecas/bz872305 (inecas@redhat.com)
- 871086 - Changes to respond with template validation errors as bad requests
  instead of internal server errors. (ehelms@redhat.com)
- 872305 - scope product certificate search by organization (inecas@redhat.com)
- Merge branch 'master' into pulp v2 (paji@redhat.com)
- 866359 - API: /consumers/{id}/entitlements returns incorrect data and
  Content-Type header (komidore64@gmail.com)
- forgot to change branding helper to use release_short method
  (jomara@redhat.com)
- Moving some configuration options into branding helper (jomara@redhat.com)
- Adding more infoz to about page & footer (jomara@redhat.com)
- fixing improper class name (jsherril@redhat.com)
- fixing include order which caused repo deletion to fail (jsherril@redhat.com)
- 750660 - System packages list doesn't allow you to search for a package
  installed on the system (j.hadvig@gmail.com)
- Merge pull request #977 from lzap/foreman-service-wait (lzap@redhat.com)
- Merge pull request #956 from komidore64/1char-org (komidore64@gmail.com)
- puppet race condition in foreman (lzap+git@redhat.com)
- Merge pull request #970 from jsomara/871822 (jsomara@gmail.com)
- 871822 - str != str (jomara@redhat.com)
- remove deprecation warning (pchalupa@redhat.com)
- sync spec with Gemfile (msuchy@redhat.com)
- 872096 - review of katello rpm-delivered conf files (lzap+git@redhat.com)
- Merge pull request #966 from komidore64/unames (parthaa@gmail.com)
- 871822 - nil check for mem_mb (jomara@redhat.com)
- 871822 - Moving factname for memtotal; now in kB by default
  (jomara@redhat.com)
- pulpv2 - making after sync work properly without task_id temporarily
  (jsherril@redhat.com)
- allowing organizations (and also anything else that uses
  katello_name_format_validator) to have a name that is one character in
  length. (komidore64@gmail.com)
- Merge pull request #932 from daviddavis/gemfiles (daviddavis@redhat.com)
- pulpv2 - updating repo to use new retrieve (jsherril@redhat.com)
- Added OS-specific Gemfile.lock files (daviddavis@redhat.com)
- pulpv2 - update katello.spec for pulp v2 refactorings
  (bbuckingham@redhat.com)
- fixing a regression in headpin due to ascii username restrictions in katello.
  (komidore64@gmail.com)
- Added fonts symlink. (jrist@redhat.com)
- 869380-confirm-delete - add confirmation message before deleting manifest
  (thomasmckay@redhat.com)
- More fixes for integrating converge-ui (jrist@redhat.com)
- Merge pull request #940 from tstrachota/abstract-model
  (tstrachota@redhat.com)
- abstract model - spec tests (tstrachota@redhat.com)
- abstract model - update_attributes (tstrachota@redhat.com)
- abstract model - validation error reporting (tstrachota@redhat.com)
- abstract model - support for naming and to_key Both needed by form_for.
  (tstrachota@redhat.com)
- Merge pull request #954 from jlsherrill/pulpv2 (bbuckingham@redhat.com)
- pulpv2 - adding support for indexing packages and errata
  (jsherril@redhat.com)
- Merge pull request #953 from bbuckingham/fork-pulpv2-configure
  (jlsherrill@gmail.com)
- Merge pull request #948 from parthaa/new-cons-group (bbuckingham@redhat.com)
- pulpv2 - update katello-reset-dbs to use pulp-manage-db
  (bbuckingham@redhat.com)
- fixing pool elasticsearch bindings (jsherril@redhat.com)
- 813291 - [RFE] Username cannot contain characters other than alpha
  numerals,'_', '-', can not resume after failure (komidore64@gmail.com)
- spec fixes (jsherril@redhat.com)
- wrapping headpin only gems to the if statement (lzap+git@redhat.com)
- Initial cut of consumer group work (paji@redhat.com)
- migrating custom repo content creation to orchestration (jsherril@redhat.com)
- Merge pull request #947 from ehelms/1.9.3-fix (ericdhelms@gmail.com)
- Ruby 1.9.3 - Adds relative path to lib files to fix unittest failures on
  1.9.3 (ehelms@redhat.com)
- gpg repo creation fix (jsherril@redhat.com)
- Merge branch 'pulpv2' of https://github.com/Katello/katello into pulpv2
  (jsherril@redhat.com)
- fixing repo gpg tests (jsherril@redhat.com)
- pulpv2 - more rspec controller fixes (bbuckingham@redhat.com)
- 870456 - existing orgs do not get default value for system_info_keys in
  database (komidore64@gmail.com)
- Merge pull request #941 from lzap/bundle-config (lzap@redhat.com)
- moving .bundle/config out of RPM to configure (lzap+git@redhat.com)
- Rspec - Fixes broken test that was a result of mis-configured mocks.
  (ehelms@redhat.com)
- Travis - Updates travis config to change directory properly for bundle
  install. (ehelms@redhat.com)
- 870362 - Adding conversion method for memory str -> mb (jomara@redhat.com)
- Merge branch 'pulpv2' of github.com:Katello/katello into pulpv2
  (ehelms@redhat.com)
- Merge pull request #908 from jhadvig/user_validation (thomasmckay@redhat.com)
- Merge pull request #933 from lzap/gemfile-sam-fix (lzap@redhat.com)
- fixing jammit dep version for sam (lzap+git@redhat.com)
- 861513 - Fixes issue with failed sync's not generating proper notifications.
  (ehelms@redhat.com)
- Merge pull request #930 from bbuckingham/fork-pulpv2-tests
  (jlsherrill@gmail.com)
- headpin-dashboard - adjust size of notices portlet when in headpin mode to
  match system status (thomasmckay@redhat.com)
- pulpv2 - rspec, more controller fixes from migration (bbuckingham@redhat.com)
- 868916 - wait for elasticsearch and start httpd during upgrade
  (lzap+git@redhat.com)
- Merge pull request #918 from lzap/root-flooding-869938 (lzap@redhat.com)
- PulpV2 - Fixing tests to work the current pulp testing release and issues
  with cassette matching. (ehelms@redhat.com)
- fixing changeset, promotions, & changeset controllers (jsherril@redhat.com)
- merge conflict and test fix (jsherril@redhat.com)
- merge conflict (jsherril@redhat.com)
- Merge pull request #917 from lzap/foreman-api-require (lzap@redhat.com)
- Merge pull request #920 from jsomara/revert-prawn (jsomara@gmail.com)
- merge conflict (jsherril@redhat.com)
- headpin-foreman - return reverted foreman fencing (thomasmckay@redhat.com)
- Revert "Prawn integration for PDF generation" (jomara@redhat.com)
- Revert "Prawn gemfile and spec dependencies" (jomara@redhat.com)
- Revert "Fixing Ruport dependencies" (jomara@redhat.com)
- Revert "Fixing Gemfile depend." (jomara@redhat.com)
- Revert "Fixing Ruport depend. on Prawn" (jomara@redhat.com)
- Revert "Fixed Gemfile for Ruport" (jomara@redhat.com)
- Revert "Fixed katello.spec for Ruport" (jomara@redhat.com)
- fixing spacing (jsherril@redhat.com)
- merge conflict (jsherril@redhat.com)
- better uri building (jsherril@redhat.com)
- fixing system model spec (jsherril@redhat.com)
- Merge pull request #886 from lzap/gemfile-19 (lzap@redhat.com)
- more spec model fixes (jsherril@redhat.com)
- 866995 - additional fix for ping controller (lzap+git@redhat.com)
- Merge pull request #911 from komidore64/http-auth (lzap@redhat.com)
- 869938 - avoiding cronjob root mail folder flooding (lzap+git@redhat.com)
- removing foreman dependency from katello-common (lzap+git@redhat.com)
- adding more strict versions in the Gemfile (lzap+git@redhat.com)
- Merge pull request #905 from ehelms/pulpv2 (jlsherrill@gmail.com)
- Merge pull request #866 from parthaa/consumer-new-pulp (ericdhelms@gmail.com)
- Revert "headpin-system-groups - adding system groups to headpin"
  (jomara@redhat.com)
- Revert "headpin-system-groups - fence pulp hooks in system model"
  (jomara@redhat.com)
- fixing proivder and product specs (jsherril@redhat.com)
- changeset spec fixes (jsherril@redhat.com)
- use uri for tdl (jsherril@redhat.com)
- Merge pull request #892 from bbuckingham/fork-865472-2
  (bbuckingham@redhat.com)
- more model spec fixes (jsherril@redhat.com)
- Merge branch 'pulpv2' of https://github.com/Katello/katello into pulpv2
  (jsherril@redhat.com)
- Merge pull request #912 from bbuckingham/fork-pulpv2-tests
  (jlsherrill@gmail.com)
- Merge pull request #907 from mccun934/835586-restrict-user-ascii2
  (mmccune@gmail.com)
- pulpv2 - rspec, more fixes from migration (bbuckingham@redhat.com)
- 817946 - API not accessible from browser (komidore64@gmail.com)
- headpin-system-groups - fence pulp hooks in system model
  (thomasmckay@redhat.com)
- 835321 - Fixing the user name validation (j.hadvig@gmail.com)
- 835586 - restricting usernames to ASCII only. (mmccune@redhat.com)
- Merge pull request #902 from daviddavis/pulpv2 (ericdhelms@gmail.com)
- environment does not need indexed model (jsherril@redhat.com)
- a few model spec fixes (jsherril@redhat.com)
- moving auth method to auth user module (jsherril@redhat.com)
- moving allowed_organizations to auth module for user (jsherril@redhat.com)
- removing uneeded auth methods (jsherril@redhat.com)
- PulpV2 - Contains changes to get repository glue layer tests completely
  working in live and none modes.  Updates to test rakefile to allow running of
  all model/glue tests or each individually. (ehelms@redhat.com)
- PR comment fixes (jsherril@redhat.com)
- fixing run_spec change (jsherril@redhat.com)
- Merge branch 'pulpv2' of https://github.com/Katello/katello into pulpv2
  (jsherril@redhat.com)
- adding new user spec test (jsherril@redhat.com)
- adding auth helper from spec tests (jsherril@redhat.com)
- giving the no_perms user his own role in fixtures (jsherril@redhat.com)
- backing up resource types similarly to our spec tests (jsherril@redhat.com)
- splitting some missed environment elastic search code (jsherril@redhat.com)
- Updating the factory_girl gem requirement (daviddavis@redhat.com)
- introducing debugging group in the Gemfile (lzap+git@redhat.com)
- Merge pull request #898 from pitr-ch/quick-fix/remove_fuzzy_warnings
  (lzap@redhat.com)
- Merge pull request #891 from komidore64/system-report-filename
  (komidore64@gmail.com)
- pulpv2 - fix existing rspecs, failing after updates to pulp v2
  (bbuckingham@redhat.com)
- remove fuzzy warnings (pchalupa@redhat.com)
- update supported rspec versions in monkeypatch (pchalupa@redhat.com)
- add missing tests for foreman integration (pchalupa@redhat.com)
- 869006: Fixing variable name change for RAM support from previous pull
  request (jomara@redhat.com)
- do not run FactoryGirl.reload if not needed (jsherril@redhat.com)
- fixing broken user tests (jsherril@redhat.com)
- localizing "NOT-SPECIFIED" string in models/custom_info.rb
  (komidore64@gmail.com)
- merge conflict fix (jsherril@redhat.com)
- removing user spec (jsherril@redhat.com)
- migrating user tests to minitest (jsherril@redhat.com)
- fixing includes for glue layer (jsherril@redhat.com)
- renaming class variable to something more unique (jsherril@redhat.com)
- 865472 - system groups - fix auto-complete on add of systems to groups
  (bbuckingham@redhat.com)
- 818903 - Name of the pdf generated for headpin system report command should
  be modified (komidore64@gmail.com)
- Merge pull request #848 from jsomara/ram (jsomara@gmail.com)
- RAM entitlements (jomara@redhat.com)
- Merge pull request #877 from ehelms/bug-862997 (ericdhelms@gmail.com)
- 862997 - On content search page, during repository comparison, clicking the
  show more button will now properly load more data for packages and errata.
  (ehelms@redhat.com)
- Merge pull request #854 from bbuckingham/fork-855267 (bbuckingham@redhat.com)
- Gemfile for 1.8 and 1.9 Ruby (lzap+git@redhat.com)
- Properly setting label in before validate method (daviddavis@redhat.com)
- Merge pull request #871 from bkearney/bkearney/866995
  (bryan.kearney@gmail.com)
- Merge pull request #880 from thomasmckay/headpin-system-groups
  (komidore64@gmail.com)
- trying to fix tests for automation (komidore64@gmail.com)
- headpin-system-groups - adding system groups to headpin
  (thomasmckay@redhat.com)
- correctly address owner attribute (msuchy@redhat.com)
- Merge pull request #873 from daviddavis/label-change (miroslav@suchy.cz)
- these aren't needed during testing and are unrelated to the spec test
  (mmccune@redhat.com)
- changing to correct 'find' method (komidore64@gmail.com)
- fixing busted tests due to elastic search indexing (komidore64@gmail.com)
- adding custom info to elastic search on systems (komidore64@gmail.com)
- default custom info for systems by org (komidore64@gmail.com)
- custom info rework (work it!) (komidore64@gmail.com)
- Merge pull request #874 from mccun934/enable-parallel-tests-unit
  (daviddavis@redhat.com)
- switching to parallel_tests for our jenkins job and removing yard run
  (mmccune@redhat.com)
- Merge pull request #818 from Katello/foreman_architectures (kontakt@pitr.ch)
- Setting label on the backend if blank (daviddavis@redhat.com)
- fix failing system tests (pchalupa@redhat.com)
- Merge pull request #857 from thomasmckay/manifests (thomasmckay@redhat.com)
- Merge branch 'pulpv2' of github.com:Katello/katello into pulpv2
  (ehelms@redhat.com)
- PulpV2 - Cleans up models tests and adds usage of factories where
  appropriate.  Fixes up glue layer to use factories. (ehelms@redhat.com)
- PulpV2 - Adds ability to turn logging on for RestClient calls in glue layer.
  Adds ability to run a single suite. (ehelms@redhat.com)
- PulpV2 - Adds factory_girl to Gemfile and adds a base set of factories with
  traits. (ehelms@redhat.com)
- cache reloaded models to speed up tests (jsherril@redhat.com)
- Merge pull request #870 from jlsherrill/pulpv2 (ericdhelms@gmail.com)
- 866995: Fix the status API so that it is exposed correctly for rhsm.
  (bkearney@redhat.com)
- minitest fixes (jsherril@redhat.com)
- Add foreman_api as a build requirement (inecas@redhat.com)
- merge conflict (jsherril@redhat.com)
- fixing bad class reference (jsherril@redhat.com)
- Add Foreman integration code to rpm spec (inecas@redhat.com)
- removed a rescue used for debugging (dmitri@redhat.com)
- Consumer changes to deal with update runcible code (paji@redhat.com)
- a bunch of fixes to get katello running on ruby 1.9.3 (dmitri@redhat.com)
- Merge branch 'master' into story/foreman_architectures (pchalupa@redhat.com)
- do not send plain password to Foreman in user foreman glue
  (pchalupa@redhat.com)
- Automatic commit of package [katello] release [1.2.1-1]. (inecas@redhat.com)
- utilize Foreman search ability in rake db:seed (pchalupa@redhat.com)
- raise errors on Foreman Katello DB inconsistency (pchalupa@redhat.com)
- Merge pull request #867 from xsuchy/pull-req-symlink (inecas@redhat.com)
- Merge pull request #859 from mccun934/add-parallel_tests (miroslav@suchy.cz)
- skip symlinks during gettext check (msuchy@redhat.com)
- Merge pull request #863 from gstoeckel/notices (ericdhelms@gmail.com)
- Moved trigger from body to document element. (gstoecke@redhat.com)
- Merge pull request #864 from jlsherrill/pulpv2 (ericdhelms@gmail.com)
- merge conflict (jsherril@redhat.com)
- Moved binding of notice display event to document ready callback due to
  different code path execution during login notifications.
  (gstoecke@redhat.com)
- manifests - cleaned error message, removed unused var
  (thomasmckay@redhat.com)
- splitting Elastic search code out of all models (jsherril@redhat.com)
- Merge pull request #598 from Pajk/845041 (miroslav@suchy.cz)
- Merge pull request #721 from Pajk/832141 (miroslav@suchy.cz)
- Merge pull request #833 from iNecas/fix-gettext-strings (miroslav@suchy.cz)
- manifests - Added delete manifest while in headpin mode (not enabled in
  katello) manifests - fixed 857949
  https://bugzilla.redhat.com/show_bug.cgi?id=857949 (thomasmckay@redhat.com)
- Merge pull request #831 from bbuckingham/fork-pulpv2 (ericdhelms@gmail.com)
- Merge pull request #641 from jhadvig/fix-ff-sync-table (miroslav@suchy.cz)
- Fixed the moving of the a.cancel_sync element (j.hadvig@gmail.com)
- 855267 - CLI - changesets - update controller to use before_filter for
  product (bbuckingham@redhat.com)
- adding parallel_tests gem so our unit tests can use multiple CPUs
  (mmccune@redhat.com)
- 860952 - update Pool::find to not treat response as an array
  (bbuckingham@redhat.com)
- test fixes (jsherril@redhat.com)
- adding missing license (jsherril@redhat.com)
- do not call pulp service script, call qpidd and mongodb directly
  (msuchy@redhat.com)
- removing repo specs (jsherril@redhat.com)
- moving enforcement code out of user.rb (jsherril@redhat.com)
- Bumping package versions for 1.1. (lzap+git@redhat.com)
- Automatic commit of package [katello] release [1.1.15-1].
  (lzap+git@redhat.com)
- removing traces of old authorization module (jsherril@redhat.com)
- splitting out auth from user.rb (jsherril@redhat.com)
- splitting auth out of system templates (jsherril@redhat.com)
- splitting auth out of system groups (jsherril@redhat.com)
- fixing class reloading with underscore (jsherril@redhat.com)
- fixing system base (jsherril@redhat.com)
- Merge pull request #838 from daviddavis/about-link (daviddavis@redhat.com)
- splitting auth from systems (jsherril@redhat.com)
- splitting auth out of roles (jsherril@redhat.com)
- Automatic commit of package [katello] release [1.1.14-1].
  (lzap+git@redhat.com)
- Merge pull request #845 from xsuchy/pull-req-rpm (lzap@redhat.com)
- package katello-common should own /etc/katello (msuchy@redhat.com)
- package katello-common should own /usr/share/katello (msuchy@redhat.com)
- package katello-common should own /usr/share/katello/lib (msuchy@redhat.com)
- package katello should own /usr/share/katello/lib/resources
  (msuchy@redhat.com)
- package katello should own /usr/share/katello/lib/monkeys (msuchy@redhat.com)
- package katello should own /usr/share/katello/app/models/glue
  (msuchy@redhat.com)
- package katello (and headpin) should own /usr/share/katello/app/models and
  /usr/share/katello/app (msuchy@redhat.com)
- katello-common should own directory /usr/share/katello/db (msuchy@redhat.com)
- Merge pull request #842 from lzap/new-cli-test (miroslav@suchy.cz)
- fixing - uninitialized constant Candlepin (lzap+git@redhat.com)
- 862753 - fixing typo in template deletion (lzap+git@redhat.com)
- splitting auth out of environment (jsherril@redhat.com)
- removing UserBaseTest requirement (jsherril@redhat.com)
- gettext - fix syntax (inecas@redhat.com)
- spliting off provider auth functions (jsherril@redhat.com)
- fixing wrong requires (jsherril@redhat.com)
- splitting auth for products (jsherril@redhat.com)
- splitting out auth methods for organization (jsherril@redhat.com)
- 860952 - do not call with_indifferent_access on Array (msuchy@redhat.com)
- removing auth from notice.rb which is not needed (jsherril@redhat.com)
- spliting authentication for gpg keys (jsherril@redhat.com)
- Merge pull request #836 from witlessbird/content-updates
  (witlessbird@gmail.com)
- Merge pull request #825 from jhadvig/prawn_integration (miroslav@suchy.cz)
- Added about link to Administer menu (daviddavis@redhat.com)
- gettext - move the check to the start of RPM build phase (inecas@redhat.com)
- fix missing parameter (pchalupa@redhat.com)
- fix for broken content update call and additional tests (dmitri@redhat.com)
- A slew of changes around content updates. (dmitri@redhat.com)
- move missing foreman user creation out of migration to upgrade script
  (pchalupa@redhat.com)
- pulpv2 - splitting filter auth into its own file (jsherril@redhat.com)
- pulpv2 - moving activation key auth to new file and testing
  (jsherril@redhat.com)
- changing alfred to no_perms_user (jsherril@redhat.com)
- merge conflict (jsherril@redhat.com)
- Merge pull request #830 from daviddavis/859963 (daviddavis@redhat.com)
- Merge pull request #832 from komidore64/busted_migration
  (komidore64@gmail.com)
- fixed failing db migrations (komidore64@gmail.com)
- fixing broken minitests (jsherril@redhat.com)
- pulpv2 - system packages - remove 'todo' (bbuckingham@redhat.com)
- 859963 - Fixed bad css character (daviddavis@redhat.com)
- gettext - add a checking script to find if there are note malformed gettext
  stings (inecas@redhat.com)
- Fix missing should in gpg controller spec (daviddavis@redhat.com)
- Fixed gpg keys controller rspec (daviddavis@redhat.com)
- Merge pull request #819 from thomasmckay/864362-autocomplete
  (thomasmckay@redhat.com)
- Merge pull request #823 from daviddavis/859329 (daviddavis@redhat.com)
- Fixed katello.spec for Ruport (j.hadvig@gmail.com)
- gettext - get rid of all malformed interpolations in gettext strings
  (inecas@redhat.com)
- gettext - use named substitution in gettext with more variables
  (inecas@redhat.com)
- Fixed Gemfile for Ruport (j.hadvig@gmail.com)
- Merge pull request #826 from jsomara/864654 (thomasmckay@redhat.com)
- 864654 - katello-headpin-all correction (jomara@redhat.com)
- Fix handling of validation_errors in notices.js (daviddavis@redhat.com)
- update katello.spec to correspond with Gemfile dependencies
  (pchalupa@redhat.com)
- reuse User foreman orchestration disablement in tests (pchalupa@redhat.com)
- add missing copyright notices (pchalupa@redhat.com)
- Merge pull request #821 from knowncitizen/847002 (jrist@redhat.com)
- Merge pull request #814 from ehelms/bug-847002 (jrist@redhat.com)
- 847002, 864216 - Fixes content search row rendering issue in IE8, product
  color row in IE8 and the path selector not being set to the proper location
  in IE8. (ehelms@redhat.com)
- 859329 - Fixed errors when editing gpg key (daviddavis@redhat.com)
- Merge remote-tracking branch 'upstream/pulpv2' into fork-pulpv2
  (bbuckingham@redhat.com)
- Merge pull request #801 from gstoeckel/notices (ericdhelms@gmail.com)
- pulpv2 - consumer - updates profile, repo binding and actions
  (bbuckingham@redhat.com)
- pulpv2 - fixing tests (jsherril@redhat.com)
- pulpv2 - migrating distribution to new model (jsherril@redhat.com)
- Incorporated code review suggestions. (gstoecke@redhat.com)
- Merge pull request #822 from jsomara/navfence (jsomara@gmail.com)
- Fencing SYNCHRONIZATION link on admin dropdown in headpin mode
  (jomara@redhat.com)
- 864565 - Removing duplicate repos from gpgkey show (daviddavis@redhat.com)
- 864362-autocomplete - rescue bad searches in auto-complete fields
  (thomasmckay@redhat.com)
- Merge branch 'master' into story/foreman_architectures (pchalupa@redhat.com)
- fix broken unit tests from 71a2926 (pchalupa@redhat.com)
- update apipie and foreman_api dependencies in Gemfile (pchalupa@redhat.com)
- raise error when parsing of response fails (pchalupa@redhat.com)
- add Resources::Foreman.options method to be able to access option hash
  (pchalupa@redhat.com)
- Fixing Ruport depend. on Prawn (jhadvig@redhat.com)
- Fixing Gemfile depend. (jhadvig@redhat.com)
- Fixing Ruport dependencies (jhadvig@redhat.com)
- Prawn gemfile and spec dependencies (jhadvig@redhat.com)
- Prawn integration for PDF generation (j.hadvig@gmail.com)
- fixing 'pt_BR' translations (msuchy@redhat.com)
- merge katello.katello translation from CFSE (msuchy@redhat.com)
- Merge branch 'master' of github.com:Katello/katello into 847002
  (jrist@redhat.com)
- 847002 - Fixes rendering issue in IE9 for nested content search results.
  (ehelms@redhat.com)
- Update to notice storage mechanism for automation testing framework.
  (gstoecke@redhat.com)
- Merge branch 'master' into notices (gstoecke@redhat.com)
- 847002 - Fix for IE9 Changeset Environment Selector (jrist@redhat.com)
- Merge remote-tracking branch 'upstream/pulpv2' into fork-pulpv2
  (bbuckingham@redhat.com)
- Merge pull request #809 from jlsherrill/pulpv2 (bbuckingham@redhat.com)
- updating to allow use of local var from PR comment (mmccune@redhat.com)
- switching our schema config names to match production and relaxing reset
  (mmccune@redhat.com)
- 825858 - use organizations.label instead of cp_key (inecas@redhat.com)
- Merge remote-tracking branch 'upstream/pulpv2' into fork-pulpv2
  (bbuckingham@redhat.com)
- 859442 - systems - update query for adding system groups to system
  (bbuckingham@redhat.com)
- Merge pull request #799 from mccun934/835586-encoding-fix (inecas@redhat.com)
- Merge pull request #805 from witlessbird/824581 (witlessbird@gmail.com)
- Merge pull request #646 from Pajk/hide_new_changeset_button
  (bbuckingham@redhat.com)
- Merge pull request #802 from jsomara/859877 (jsomara@gmail.com)
- Merge pull request #804 from jlsherrill/862824 (thomasmckay@redhat.com)
- Merge pull request #734 from daviddavis/code-format (daviddavis@redhat.com)
- 825858 - implementing proxy permissions (lzap+git@redhat.com)
- 825858 - proxies permissions - removing comments (lzap+git@redhat.com)
- fix for BZ 824581: gpg keys are now being updated (dmitri@redhat.com)
- PulpV2 - Test re-factoring by breaking out the base modules for tests into
  their own files to allow easier sharing. (ehelms@redhat.com)
- PulpV2 - Fixes bug found in prevention of the deletion of last super user.
  (ehelms@redhat.com)
- PulpV2 - Test cleanup and adds a generic function to call and disable glue
  layers. (ehelms@redhat.com)
- PulpV2 - Removes old integration tests that are no longer needed since
  lib/resources/pulp.rb has been moved to a stand alone gem.
  (ehelms@redhat.com)
- PulpV2 - Adds previously removed environment_id function to repository model.
  (ehelms@redhat.com)
- Merge branch 'pulpv2' of github.com:Katello/katello into pulpv2
  (ehelms@redhat.com)
- Merge pull request #816 from jlsherrill/pulpv2 (ericdhelms@gmail.com)
- pulpv2 - removing PulpPing and relying on the call directly
  (jsherril@redhat.com)
- pulpv2 - removing unused pulp code (jsherril@redhat.com)
- pulpv2 - moving distribution deletion (jsherril@redhat.com)
- pulpv2 - converting errata/package deletion after bad merge made it return
  (jsherril@redhat.com)
- pulpv2 - fixing intermittent issue (jsherril@redhat.com)
- Changed paths for reset-oauth script (paji@redhat.com)
- pulpv2 - migrating package/errata/pkg groups/distributions to runcible
  (jsherril@redhat.com)
- PulpV2 - A slew of glue layer tests for repository and some associated
  cleanup. (ehelms@redhat.com)
- Merge branch 'pulpv2' of github.com:Katello/katello into pulpv2
  (ehelms@redhat.com)
- 862824 - load search results using where() manually (jsherril@redhat.com)
- 859877 - ipaddr does not show up for old subman version (jomara@redhat.com)
- PulpV2 - Adds ability to run a single test method by specifying method=
  (ehelms@redhat.com)
- Merge branch 'master' into notices (gstoecke@redhat.com)
- Added tracking of notices for use in test automation framework.
  (gstoecke@redhat.com)
- requiring new minitest gems (jsherril@redhat.com)
- 835586 - force the encoding in the header to be UTF8 so Pulp can decode
  (mmccune@redhat.com)
- Merge pull request #560 from Pajk/806383 (martin.bacovsky@gmail.com)
- change AbstractModel to correspond with unified apipie resource method
  signatures (pchalupa@redhat.com)
- add migration for creating missing users in foreman (pchalupa@redhat.com)
- fixing generate_metadata to be true (jsherril@redhat.com)
- Merge pull request #794 from jsomara/esinstalledproductfix
  (thomasmckay@redhat.com)
- self. calling a private method (jomara@redhat.com)
- Revert "pulpv2 - removing no longer avvailable distributor option"
  (jsherril@redhat.com)
- self.installed_products != self.installedProducts (jomara@redhat.com)
- Merge pull request #793 from jsomara/esinstalledproductfix
  (daviddavis@redhat.com)
- Defensively checking installed product names; (jomara@redhat.com)
- pulpv2 - removing no longer avvailable distributor option
  (jsherril@redhat.com)
- Show foreman packages on about page (daviddavis@redhat.com)
- reverting accidental override (msuchy@redhat.com)
- Merge pull request #767 from witlessbird/852352 (witlessbird@gmail.com)
- Merge pull request #772 from xsuchy/pull-req-transdup2 (miroslav@suchy.cz)
- Merge pull request #777 from jsomara/installedproducts
  (thomasmckay@redhat.com)
- Merge pull request #785 from jsomara/anysystemfact (thomasmckay@redhat.com)
- Merge pull request #748 from pitr-ch/bug/808581-Stack_traces_in_log
  (thomasmckay@redhat.com)
- pulpv2 - fix errors on package/errata affecting promotion
  (bbuckingham@redhat.com)
- PulpV2 - Removal of zoo5 local repository from test integration directory.
  (ehelms@redhat.com)
- PulpV2 - Re-organizes location of test fixtures. (ehelms@redhat.com)
- Removing ANY SYSTEM FACT: from system search list (jomara@redhat.com)
- Resetting locale to English before each test (daviddavis@redhat.com)
- Merge remote-tracking branch 'upstream/pulpv2' into fork-pulpv2
  (bbuckingham@redhat.com)
- fix failing test (pchalupa@redhat.com)
- pulpv2 - fixing issue where promoted repos would not have metadata
  regenerated (jsherril@redhat.com)
- Merge branch 'pulpv2' of github.com:Katello/katello into pulpv2
  (ehelms@redhat.com)
- PulpV2 - Updates to references of Package and Errata based on changes to
  splitting out of elastic search and pulp related calls to separeate files.
  This essentially removes all references to the eleastic search functionality
  that used to reside in glue pulp layer. (ehelms@redhat.com)
- Fixed rspec translation missing failures (daviddavis@redhat.com)
- merge conflict (jsherril@redhat.com)
- pulpv2 - moving event notifiers to pulp (jsherril@redhat.com)
- merge conflict (jsherril@redhat.com)
- Making systems searchable on installed products (jomara@redhat.com)
- Merge pull request #774 from xsuchy/pull-req-fuzzy (mmccune@gmail.com)
- ignore fuzzy and obsolete translations (msuchy@redhat.com)
- Fixed broken label rspec tests (davidd@scimedsolutions.com)
- pulpv2 - updates for retrieving consumer profile from pulp
  (bbuckingham@redhat.com)
- Make string more translator friendly (msuchy@redhat.com)
- add missing apostroph (msuchy@redhat.com)
- unify string "Removed repository" (msuchy@redhat.com)
- unify string "Couldn't find user role" (msuchy@redhat.com)
- unify string "Couldn't find user" (msuchy@redhat.com)
- unify string "Couldn't find template" (msuchy@redhat.com)
- unify string "Couldn't find system group" (msuchy@redhat.com)
- unify string "Couldn't find system" (msuchy@redhat.com)
- unify string "Couldn't find repository" (msuchy@redhat.com)
- unify string "Couldn't find product with id" (msuchy@redhat.com)
- unify string "Couldn't find organization" (msuchy@redhat.com)
- unify string "Couldn't find environment" (msuchy@redhat.com)
- unify string "Couldn't find changeset" (msuchy@redhat.com)
- unify string "Couldn't find activation key" (msuchy@redhat.com)
- unify string "Added repository" (msuchy@redhat.com)
- unify string "Added distribution" (msuchy@redhat.com)
- pulpv2 - removing unused pulp api classes (jsherril@redhat.com)
- Merge branch 'pulpv2' of github.com:Katello/katello into pulpv2
  (ehelms@redhat.com)
- Pulpv2 - Adds simple object for errata and package and splits out the elastic
  search and pulp related functionality for each. (ehelms@redhat.com)
- Merge pull request #622 from Pajk/848438 (martin.bacovsky@gmail.com)
- Merge pull request #770 from mccun934/803702-org-label-3
  (bbuckingham@redhat.com)
- 803702 - switch back to searching in the API by name and not label
  (mmccune@redhat.com)
- 824581 - Fixing bug resulting from bad fix (davidd@scimedsolutions.com)
- improve foreman api controllers (pchalupa@redhat.com)
- add method for parsing attributes from response (pchalupa@redhat.com)
- fix rake db:seed with foreman orchestration on (pchalupa@redhat.com)
- 808581 - Stack traces logged to production.log for user-level validation
  errors (pchalupa@redhat.com)
- Merge remote-tracking branch 'upstream/pulpv2' into fork-pulpv2
  (bbuckingham@redhat.com)
- Merge pull request #766 from jlsherrill/pulpv2 (ericdhelms@gmail.com)
- Merge pull request #702 from witlessbird/835875 (witlessbird@gmail.com)
- Merge pull request #729 from daviddavis/bz824581 (mmccune@gmail.com)
- Merge pull request #720 from pitr-
  ch/bug/857230-mouse_over_errata_item_displays_error (kontakt@pitr.ch)
- fix errors introduced by adding AbstractModel (pchalupa@redhat.com)
- 860251 - update the location of favicon.png (inecas@redhat.com)
- pulpv2 - using extensions always for repository (jsherril@redhat.com)
- Merge pull request #759 from bbuckingham/fork-859415 (bbuckingham@redhat.com)
- fix for BZ852352: changeset type is now being pre-selected depending on user
  selection of 'Deletion from' or 'Promotion to' (dmitri@redhat.com)
- Merge pull request #738 from daviddavis/about (daviddavis@redhat.com)
- pulpv2 - removing some unused repo items, and fixing some runcible calls
  (jsherril@redhat.com)
- PulpV2 - Updated tests for Repository model file, and pulls out elasticsearch
  related code to be nested under the glue layer similar to how Pulp and
  Candlepin are used. (ehelms@redhat.com)
- Merge pull request #756 from knowncitizen/859409 (jrist@redhat.com)
- pulp v2 - consumer - initial changes for
  create/review/update/delete/profile/profile upload (bbuckingham@redhat.com)
- 767297 - Removed OS information (davidd@scimedsolutions.com)
- Merge pull request #757 from mccun934/add-dev-boost (mmccune@gmail.com)
- rails-dev-boost - removing whitespace (mmccune@redhat.com)
- rails-dev-boost - moving to own group and adding RPM requires
  (mmccune@redhat.com)
- PulpV2 - Splits out authorization related code into separate module for
  repository. (ehelms@redhat.com)
- pulpv2 - moving more repo items to runcible (jsherril@redhat.com)
- BZ 835875: removed a commented-out line of code (dmitri@redhat.com)
- Automatic commit of package [katello] release [1.1.13-1]. (msuchy@redhat.com)
- PulpV2 - Adds set of repository model tests that include some updates to the
  repository model. (ehelms@redhat.com)
- Merge pull request #745 from daviddavis/857576 (daviddavis@redhat.com)
- Merge pull request #749 from lzap/manifest_parsing (lzap@redhat.com)
- Merge pull request #750 from witlessbird/860702 (witlessbird@gmail.com)
- Merge pull request #752 from witlessbird/857031 (witlessbird@gmail.com)
- 859415 - object labels - modify ui to assign a default label, if not
  specified (bbuckingham@redhat.com)
- Merge pull request #758 from jsomara/858360 (mmccune@gmail.com)
- 858360 - Making katello-upgrade START services after upgrade is complete
  (jomara@redhat.com)
- rails-dev-boost - adding rails-dev-boost gem (mmccune@redhat.com)
- pulpv2 - fixing repo schedule error (jsherril@redhat.com)
- 859409 - Fix for focus on org switcher drop down. (jrist@redhat.com)
- pulpv2 - migrating repo schedules to runcible (jsherril@redhat.com)
- Merge pull request #754 from daviddavis/859784 (daviddavis@redhat.com)
- 859604 - Fixed search results total bug (davidd@scimedsolutions.com)
- 859784 - Missing template error (davidd@scimedsolutions.com)
- 857576 - Added api filter update test (davidd@scimedsolutions.com)
- fix for BZ 857031: notifications are being shown now when a system gets added
  to/removed from a group (dmitri@redhat.com)
- 857576 - Package filter name can be edited by cli
  (davidd@scimedsolutions.com)
- fixed an inadvertent spec test change (thomasmckay@redhat.com)
- fix for BZ 860702: show systems belonging to system groups and those not in
  any on 'Systems' screen (dmitri@redhat.com)
- Merge pull request #746 from thomasmckay/release-version
  (thomasmckay@redhat.com)
- introducing katello-utils with katello-disconnected script
  (lzap+git@redhat.com)
- Merge pull request #747 from jsomara/860421 (jsomara@gmail.com)
- Merge branch 'master' into story/foreman_architectures (pchalupa@redhat.com)
- 767297 - Worked on about page and added spec (davidd@scimedsolutions.com)
- Merge pull request #742 from xsuchy/pull-req-bz854263-3 (miroslav@suchy.cz)
- Merge pull request #741 from xsuchy/pull-req-ruby (miroslav@suchy.cz)
- 860421 - Not verifying ldap roles for auth-less API calls (jomara@redhat.com)
- 767297 - Create an about page (davidd@scimedsolutions.com)
- pulpv2 - moving unit repo listing to runcible (jsherril@redhat.com)
- release-version - display message when no available release version choices
  or an error occurred fetching them (thomasmckay@redhat.com)
- Revert "workaround for bz 854263" (msuchy@redhat.com)
- Merge pull request #718 from Pajk/857720 (pajkycz@gmail.com)
- requires ruby(abi) and ruby (the command) (msuchy@redhat.com)
- pulpv2 - migrating sync tasks and deletion to runcible (jsherril@redhat.com)
- pulpv2 - moving most pulp task calls to runcible (jsherril@redhat.com)
- pulpv2 - moving all unit copy items to runcible (jsherril@redhat.com)
- Merge pull request #727 from thomasmckay/857895-sysregdate
  (thomasmckay@redhat.com)
- 824581 - Fixed bug where gpgkey wasn't getting set
  (davidd@scimedsolutions.com)
- Merge pull request #714 from komidore64/custom-attributes
  (komidore64@gmail.com)
- 858802 - Allowing associated keys to be deleted (davidd@scimedsolutions.com)
- altering custom info index and shortening the name (komidore64@gmail.com)
- Merge pull request #719 from Pajk/857539 (pajkycz@gmail.com)
- add Resources::AbstractModel (pchalupa@redhat.com)
- remove forgotten conflict indicators (msuchy@redhat.com)
- Merge pull request #736 from bbuckingham/fork-858011 (bbuckingham@redhat.com)
- 858011, 854697 - object-labels - needed to use org label on del_owners (vs
  cp_key) (bbuckingham@redhat.com)
- Merge pull request #621 from xsuchy/pull-req-transifex (miroslav@suchy.cz)
- fixing ko .po file (msuchy@redhat.com)
- fix plurals form in pt_BR (msuchy@redhat.com)
- fixing es .po file (msuchy@redhat.com)
- fixing es .po file (msuchy@redhat.com)
- fix pt_BR .po file (msuchy@redhat.com)
- Fixed code formating issue in migration (davidd@scimedsolutions.com)
- Take advantage of the new katello-service script to stop/start all required
  services. (ogmaciel@gnome.org)
- PulpV2 - Adds a base set of Katello User model unit tests that disable
  inclusion of glue layer and only tests the Katello User model using Minitest
  Unittest and fixtures. (ehelms@redhat.com)
- Removed goferd from backup script as it is never installed in the server,
  only in the clients that subscribe to it. (ogmaciel@gnome.org)
- Merge pull request #732 from mccun934/857842-mmccune (bbuckingham@redhat.com)
- 857842 - get all the packages, fixes earlier syntax error
  (mmccune@redhat.com)
- pulpv2 - moving reop create to runcible (jsherril@redhat.com)
- BZ 821345: product name now appears instead of a '#' (dmitri@redhat.com)
- Merge pull request #722 from jlsherrill/bz842838 (jlsherrill@gmail.com)
- 857895 - adding "registered date" to system lists to help distinguish between
  same-named systems (thomasmckay@redhat.com)
- Merge pull request #712 from thomasmckay/854801-autoheal
  (thomasmckay@redhat.com)
- Merge pull request #726 from iNecas/fix-build-model-utils (miroslav@suchy.cz)
- Merge pull request #723 from witlessbird/858682 (witlessbird@gmail.com)
- build-fix - don't use model classes on require time (inecas@redhat.com)
- 858678 - removing extra systems index (lzap+git@redhat.com)
- refresh translations string for katello (msuchy@redhat.com)
- Merge pull request #693 from iNecas/bz829437 (inecas@redhat.com)
- making a method in the custom_info_controller private (komidore64@gmail.com)
- PulpV2 - Adds glue layer unit tests for glue/pulp/user combining VCR to
  record Pulp data. (ehelms@redhat.com)
- Merge pull request #703 from witlessbird/858661 (bbuckingham@redhat.com)
- Merge pull request #724 from Katello/set-object-labels (mmccune@gmail.com)
- pulpv2 - making Gemfile work for installer and dev environment
  (jsherril@redhat.com)
- pulpv2 - adding runcible to requires (jsherril@redhat.com)
- BZ 858682: fixed status messages on syncs that didn't fail (yet) but didn't
  complete successfully either (dmitri@redhat.com)
- Merge pull request #716 from knowncitizen/857499 (mmccune@gmail.com)
- 829437 - fix error notification in GPG file upload form (inecas@redhat.com)
- 842838 - fixing x icon not showing up on content search (jsherril@redhat.com)
- Merge pull request #685 from bbuckingham/fork-843529 (bbuckingham@redhat.com)
- 832141 - Searching a system via 'By Environments' sub-tab doesn't save the
  recent search in history (pajkycz@gmail.com)
- 857230 - Mouse over errata item displays error in UI Content Search
  (pchalupa@redhat.com)
- 857539 - Clicking the "contract" arrow in the org selector on the main UI
  does not contract the picker (pajkycz@gmail.com)
- Javascript error if selecting Org in Changeset history detail page
  (pajkycz@gmail.com)
- 857720 - Javascript error if selecting Org in Providers page
  (pajkycz@gmail.com)
- 857499 - Fix for user with no orgs or perms. (jrist@redhat.com)
- Update the env, prod migrations to use labelize (paji@redhat.com)
- Fixed the labelize call to deal with i18n characters (paji@redhat.com)
- fixing spec tests for custom_info (komidore64@gmail.com)
- 843529 - minor update per pull request comment - use if/else vs unless
  (bbuckingham@redhat.com)
- Merge remote-tracking branch 'upstream/master' into fork-set_labels
  (bbuckingham@redhat.com)
- CustomInfo for Systems (komidore64@gmail.com)
- object labels - moving the default_label action to the application controller
  (bbuckingham@redhat.com)
- object labels - update ui for setting label values based upon server query
  (bbuckingham@redhat.com)
- object labels - by default, assign label by 'labelizing' the object name
  (bbuckingham@redhat.com)
- 854801-autoheal - word change (thomasmckay@redhat.com)
- Prevent resubmission on the interstitial screen (davidd@scimedsolutions.com)
- Merge pull request #705 from Katello/object-labels (mmccune@gmail.com)
- converge-ui - updating hash (bbuckingham@redhat.com)
- Merge pull request #707 from xsuchy/pull-req-Rakefile (lzap@redhat.com)
- Rakefile could not be in -devel package as katello-configure call db:migrate
  and seed_with_logging rake tasks (msuchy@redhat.com)
- Merge pull request #610 from Pajk/759122 (pajkycz@gmail.com)
- fixed an issue when it was impossible to remove a repository that had no
  promoted content (dmitri@redhat.com)
- 759122 - system software tab More... button displaying when no more
  (pajkycz@gmail.com)
- it is now impossible to delete a provider if one (or more) of its
  repositories or products has been promoted (dmitri@redhat.com)
- Merge remote-tracking branch 'upstream/object-labels' into object-labels
  (mmccune@redhat.com)
- object-labels - adding CLI and API calls to support object labeling
  (mmccune@redhat.com)
- fixing missing merge conflict (jsherril@redhat.com)
- master merge conflict (jsherril@redhat.com)
- converge-ui update (jsherril@redhat.com)
- pulpv2 - fixing broken model path (jsherril@redhat.com)
- PulpV2 - Updates to add logging to Rails logger of RestClient calls.  Note
  that this current method also exposes the ElasticSearch RestClient calls.
- PulpV2 - Adds early support for Runcible gem which supplies new PulpV2 API
  bindings. (ehelms@redhat.com)
- Merge branch 'master' into master-object-labels (paji@redhat.com)
- pulpv2 - requiring pulp-rpm-server instead of pulp
- Adds runcible local path declaration for easy development and auto-loading of
  runcible files for cross development in the early stages. (ehelms@redhat.com)
- pulpv2 - moving feed info to accessors
- pulpv2 - Converting repo deletion to delete the actual repo
  (jsherril@redhat.com)
- Merge pull request #694 from daviddavis/fix-org-rspec (daviddavis@redhat.com)
- 858193-automation - fencing javascript error point (thomasmckay@redhat.com)
- 854278 - fixing search validation calls to appropriately search for user
  names (jomara@redhat.com)
- Fixed organization rspec test (davidd@scimedsolutions.com)
- 843529 - fix spec test on system group events (bbuckingham@redhat.com)
- 843529 - system group tasks - better way for handling nil job
  (bbuckingham@redhat.com)
- return back Gemfile (msuchy@redhat.com)
- Merge pull request #678 from mbacovsky/857842_katello_debug_packages
  (martin.bacovsky@gmail.com)
- Merge pull request #680 from lzap/katello-service-wait-cmd
  (miroslav@suchy.cz)
- katello-service - now hard-depends on katello-wait (lzap+git@redhat.com)
- Merge pull request #673 from xsuchy/pull-req-devel (miroslav@suchy.cz)
- 843529 - system group tasks - handling when systems are removed
  (bbuckingham@redhat.com)
- Merge branch 'master' into master-object-labels (paji@redhat.com)
- Fixed some broken unit tests (paji@redhat.com)
- Merge pull request #683 from daviddavis/fix-provider-specs
  (parthaa@gmail.com)
- Merge pull request #681 from komidore64/string-fixes (komidore64@gmail.com)
- Revert "regenerating localization strings for rails app"
  (komidore64@gmail.com)
- Merge pull request #682 from jlsherrill/bz857727 (jlsherrill@gmail.com)
- Fixed provider_spec.rb tests (davidd@scimedsolutions.com)
- regenerating localization strings for rails app (komidore64@gmail.com)
- add two strings to localization (komidore64@gmail.com)
- Merge pull request #677 from mbacovsky/852388_apidoc_filters_n_sync
  (mmccune@gmail.com)
- 857727 - issue where uploading key left UI in bad state (jsherril@redhat.com)
- Merge pull request #674 from xsuchy/pull-req-pdf-writer (miroslav@suchy.cz)
- Merge branch 'master' into master-object-labels (paji@redhat.com)
- Merge pull request #672 from xsuchy/pull-req-l18n (miroslav@suchy.cz)
- katello-service - reformatting mixed tabs and spaces (lzap+git@redhat.com)
- katello-service - make use of service-wait (lzap+git@redhat.com)
- 820634 - Katello String Updates (komidore64@gmail.com)
- apidoc - added API documentation filters, sync (bz#852388)
  (mbacovsk@redhat.com)
- Fixed package listing generation in katello-debug (bz#857842)
  (mbacovsk@redhat.com)
- Merge pull request #670 from jsomara/852912 (jsomara@gmail.com)
- do not require rubygem-pdf-writer (msuchy@redhat.com)
- create new subpackages -devel-all and -devel-* (msuchy@redhat.com)
- update katello localization strings (msuchy@redhat.com)
- object labels - spec changes for the additions of label to repository..etc
  (bbuckingham@redhat.com)
- object labels - update env controller to support retrieving env by label
  (bbuckingham@redhat.com)
- object labels - update to use product and repo label (bbuckingham@redhat.com)
- object labels - update activation key edit helptip to reflect use of label
  (bbuckingham@redhat.com)
- object labels - add read-only label to edit panes for org, env, prod, repo
  (bbuckingham@redhat.com)
- object labels - update to use environment label for candlepin environments
  (bbuckingham@redhat.com)
- 852912 - fixing subscribe/unsubscribe for non-english locale 857550 - fixing
  environment loading on clean installs (jomara@redhat.com)
- Merge pull request #669 from daviddavis/bz852119 (mmccune@gmail.com)
- 852119 - Fixed default environment bug (davidd@scimedsolutions.com)
- Merge pull request #667 from daviddavis/user-rspec-fix (mmccune@gmail.com)
- Merge pull request #668 from xsuchy/pull-req-headpin (miroslav@suchy.cz)
- headpin needs RAILS_RELATIVE_URL_ROOT variable (msuchy@redhat.com)
- Fixing user spec tests that were breaking (davidd@scimedsolutions.com)
- katello-jobs - fix status exit code (inecas@redhat.com)
- Merge pull request #664 from mbacovsky/852388_apidoc_system_group
  (martin.bacovsky@gmail.com)
- apidoc - added docs for system groups (#852388) (mbacovsk@redhat.com)
- Fix rpm update from version without converge-ui (inecas@redhat.com)
- pulpv2 - converting repo promotion to use filters (jsherril@redhat.com)
- pulpv2 - converting api filter call to use search server
  (jsherril@redhat.com)
- pulpv2 - changing way we fetch packages and errata for repos for upcomign rfe
  (jsherril@redhat.com)
- pulpv2 - fixing repository distributions call (jsherril@redhat.com)
- 845041 - UI - Exact Errata search in content search does not return result
  (pajkycz@gmail.com)
- main code expect that RETVAL is set after kstatus() finish
  (msuchy@redhat.com)
- apidoc - systems_controller fix ruby 1.9 compatibility (inecas@redhat.com)
- Merge pull request #648 from iNecas/apidoc-systems-controller
  (martin.bacovsky@gmail.com)
- Merge pull request #645 from Pajk/apidoc_tasks_plans_syspack
  (martin.bacovsky@gmail.com)
- Merge pull request #657 from xsuchy/pull-req-bz855406-2 (inecas@redhat.com)
- 855406 - pass correctly environment variables which ruby needs
  (msuchy@redhat.com)
- apidoc - Sync Plans, Tasks, System Packages (pajkycz@gmail.com)
- Hide 'new changeset' button when it should not be used (pajkycz@gmail.com)
- apidoc - fix rake apipie:static when postgresql not running
  (inecas@redhat.com)
- Fixed all the product related tests (paji@redhat.com)
- Partial commit on product create (paji@redhat.com)
- Misc unit test fixes (paji@redhat.com)
- Merge pull request #612 from ehelms/pulp-integration-tests
  (mmccune@gmail.com)
- Fixed unit tests related to system groups (paji@redhat.com)
- object-label - organization - rename column cp_key to label
  (bbucking@dhcp231-20.rdu.redhat.com)
- Automatic commit of package [katello] release [1.1.12-1]. (inecas@redhat.com)
- Merge pull request #581 from Pajk/843064 (mmccune@gmail.com)
- Merge pull request #618 from mbacovsky/842271 (inecas@redhat.com)
- Merge pull request #602 from thomasmckay/subsfilter (jrist@redhat.com)
- subsfilter - Correctly update UI when subscription checkboxes toggled
  (thomasmckay@redhat.com)
- pulpv2 - fixing package cloning to work with blacklists (jsherril@redhat.com)
- Merge pull request #650 from knowncitizen/orgfixes (ericdhelms@gmail.com)
- Merge pull request #626 from bbuckingham/fork-854697 (bbuckingham@redhat.com)
- Merge pull request #623 from bbuckingham/fork-809259-2
  (bbuckingham@redhat.com)
- Org switcher "tipsy" fix and IE8 final fixes. (jrist@redhat.com)
- Added code to create product and repos with labels (paji@redhat.com)
- Merge pull request #643 from Pajk/templates_apidoc (inecas@redhat.com)
- Merge pull request #615 from parthaa/db-indexes2 (mmccune@gmail.com)
- apidoc - systems controller (inecas@redhat.com)
- Merge pull request #647 from jlsherrill/853229 (mmccune@gmail.com)
- 853229 - blank sync plan date gives incorrect error (jsherril@redhat.com)
- Merge pull request #636 from jsomara/856303 (jsomara@gmail.com)
- Let errata types options be selectable (mbacovsk@redhat.com)
- Merge remote-tracking branch 'upstream/master' into fork-809259-2
  (bbucking@dhcp231-20.rdu.redhat.com)
- APIDOC - templates, templates_content (pajkycz@gmail.com)
- Merge pull request #642 from Pajk/852388_providers_subscriptions_apidoc
  (pajkycz@gmail.com)
- Automatic commit of package [katello] release [1.1.11-1]. (msuchy@redhat.com)
- APIDOC - providers, subscriptions (pajkycz@gmail.com)
- Merge pull request #640 from lzap/servicewait_856220 (lzap@redhat.com)
- 856220 - adding time to puppet log (lzap+git@redhat.com)
- Merge pull request #593 from Pajk/truncate_notice (pajkycz@gmail.com)
- Merge pull request #637 from knowncitizen/orgfixes (mmccune@gmail.com)
- Fixed all KTEnvironment.create unit tests to take the label (paji@redhat.com)
- Fix for removing user's default org. (jrist@redhat.com)
- Fixed all organizatio.create related unit tests (paji@redhat.com)
- Merge pull request #520 from ehelms/bug-846719 (mmccune@gmail.com)
- 856303 - fencing system permission checks (jomara@redhat.com)
- Improved the message in the katello label validator (paji@redhat.com)
- Made the label columns non null (paji@redhat.com)
- Added indexes to the migration script to enforce uniqueness constraints
  (paji@redhat.com)
- Added code to get the initial org + env create working in the UI
  (paji@redhat.com)
- Initial commit to setup the models and migrations for object-labels
  (paji@redhat.com)
- Merge pull request #603 from knowncitizen/orgfixes (parthaa@gmail.com)
- Merge branch 'master' into orgfixes (jrist@redhat.com)
- Fix for initial suggestion from @parthaa with new suggestion.
  (jrist@redhat.com)
- removed referebce to package autocomplete widget from content search page
  (dmitri@redhat.com)
- fix for BZ 843059: removed autocomplete on packages (dmitri@redhat.com)
- Merge pull request #633 from witlessbird/835875 (witlessbird@gmail.com)
- Merge pull request #631 from lzap/servicewait_856220 (lzap@redhat.com)
- BZ 835875: a couple of small fixes based on pull comments (dmitri@redhat.com)
- Merge pull request #597 from Pajk/811136 (bbuckingham@redhat.com)
- Updating some permissions stuff and the save based on comments in the Pull
  Request. (jrist@redhat.com)
- Merge pull request #632 from xsuchy/pull-req-katello-jobs-env
  (inecas@redhat.com)
- preserve enviroment variable, especiall RAILS_ENV (msuchy@redhat.com)
- Merge pull request #606 from Pajk/852460 (bbuckingham@redhat.com)
- 856220 - improving service-wait wrapper script (lzap+git@redhat.com)
- Merge pull request #630 from Pajk/852320-fix (bbuckingham@redhat.com)
- 856227 - set the height of the tabel row in the products_table to 32px
  (j.hadvig@gmail.com)
- 848438 - Content search auto-complete should enable the 'Add' button after
  typing full content name. (pajkycz@gmail.com)
- Merge pull request #616 from Pajk/839575 (pajkycz@gmail.com)
- Test fix for changeset creation without env (pajkycz@gmail.com)
- fixes for BZ 835875: no longer possible to delete a repository if it's been
  promoted. (dmitri@redhat.com)
- Merge pull request #627 from Pajk/852320 (pajkycz@gmail.com)
- 854697 - manifest import - if first import fails, rollback (unimport it)
  (bbuckingham@redhat.com)
- PulpIntegrationTests - Updates for tests that were having incosistent run
  times between live and recorded data versions. (ehelms@redhat.com)
- Merge pull request #611 from komidore64/user-search-notice
  (komidore64@gmail.com)
- Merge pull request #625 from iNecas/fix-ak (bbuckingham@redhat.com)
- 853056 - fix regression for registering with activation keys
  (inecas@redhat.com)
- fix dependecies on Fedora17+ (msuchy@redhat.com)
- 852320 - undefined method `library?' for nil:NilClass (NoMethodError) when
  creating a changeset without an environment (pajkycz@gmail.com)
- 809259 - activation key - cli permissions changes (continued)
  (bbuckingham@redhat.com)
- 809259 - activation key - cli permissions changes (bbuckingham@redhat.com)
- PulpIntegrationTests - Adds removal of pulp integration tests test runner
  script from spec. (ehelms@redhat.com)
- 839575 - [CLI] Adding a system to system group using incorrect uuid should
  raise an error instead of success (pajkycz@gmail.com)
- Fixed #842271 - filtering the "bugfix" errata in CLI doesn't work
  (mbacovsk@redhat.com)
- Merge pull request #613 from xsuchy/pull-req-bz754738 (miroslav@suchy.cz)
- Merge pull request #608 from Pajk/786226 (pajkycz@gmail.com)
- Merge pull request #589 from bbuckingham/fork-843529 (mmccune@gmail.com)
- Fixing the org serialization, tipsifying, some suggested tweaks.
  (jrist@redhat.com)
- pulpv2 - mostly fixed post sync actions (jsherril@redhat.com)
- PulpIntegrationTests - Adds require for rails gem. (ehelms@redhat.com)
- PulpIntegrationTests - Removes unused rake task and reference to rake task
  from spec. (ehelms@redhat.com)
- PulpIntegrationTests - Updates to fix errors between running live tests and
  running tests against recorded data. (ehelms@redhat.com)
- PulpIntegrationTests - Adds tests for uncovered actions and updates for a
  successful test suite beginning to end. (ehelms@redhat.com)
- PulpIntegrationTests - A ton of re-factoring and added test cases.
  (ehelms@redhat.com)
- PulpIntegrationTests - Adds Consumer tests and a local repository for usage
  in testing. (ehelms@redhat.com)
- PulpIntegrationTests - Adds a number of tests for filters, packages, package
  groups, tasks, and errata. (ehelms@redhat.com)
- PulpIntegrationTests - Updates to repository tests. (ehelms@redhat.com)
- PulpIntegrationTests - Slew of repository related tests. (ehelms@redhat.com)
- PulpIntegrationTests - Adds integration tests for pulp users.
  (ehelms@redhat.com)
- PulpIntegrationTests - Initial integration test setup using VCR and minitest
  to test basic Pulp Ping. (ehelms@redhat.com)
- Initial commit on updated indexing appropriate stuff (paji@redhat.com)
- 754738 - do not override variables in other procedures (msuchy@redhat.com)
- 754738 - do not override status() from /etc/rc.d/init.d/functions
  (msuchy@redhat.com)
- 754738 - fix name of monitor pid file (msuchy@redhat.com)
- 754738 - if program is already running, print failure, but return 0
  (msuchy@redhat.com)
- 754738 - if we fail in stopping delayed_jobs, kill it. One by one.
  (msuchy@redhat.com)
- 75473 - correctly solve status for all processes of delayed_jobs
  (msuchy@redhat.com)
- 754738 - log even output of service stop (msuchy@redhat.com)
- use runuser instead of su (msuchy@redhat.com)
- 75473 - do not delete nor truncate log (msuchy@redhat.com)
- 754738 - properly return when katello is not configured (msuchy@redhat.com)
- 854278 - After adding certain objects to katello one will see a warning, ''
  did not meet the current search criteria and is not being shown
  (komidore64@gmail.com)
- pulpv2 - converting errata promotion (jsherril@redhat.com)
- 786226 - List of product repositories not sorted alphabetically
  (pajkycz@gmail.com)
- 852460 - System Groups left pane list does not use ellipsis
  (pajkycz@gmail.com)
- 855184 - Using --add_package gives undefined method `empty?' for nil:NilClass
  error (pajkycz@gmail.com)
- Final org switcher and interstitial changes for default organization.
  (jrist@redhat.com)
- pulpv2 - migrating package and errata promotion (jsherril@redhat.com)
- Changes to accomodate the System Registration Defaults (jrist@redhat.com)
- Merge pull request #551 from thomasmckay/834013-releaseVer
  (thomasmckay@redhat.com)
- Merge pull request #588 from ehelms/master (ericdhelms@gmail.com)
- Merge pull request #586 from mccun934/kt-debug-all-packages
  (mmccune@gmail.com)
- 840735 - headpin create environment returned error :There was an error
  retrieving that row:Not Found (komidore64@gmail.com)
- Merge pull request #599 from Pajk/841121_next (pajkycz@gmail.com)
- 841121 -  Long description returns PG error (pajkycz@gmail.com)
- Merge pull request #579 from Pajk/841300 (pajkycz@gmail.com)
- Merge pull request #594 from Pajk/841121 (pajkycz@gmail.com)
- Automatic commit of package [katello] release [1.1.10-1]. (inecas@redhat.com)
- add foreman user orchestration tests (pchalupa@redhat.com)
- 811136 - Rendering error in production.log while editing the org's
  description (pajkycz@gmail.com)
- 841121 - Long description while creating system group returns PG error
  (pajkycz@gmail.com)
- Truncate Notice text to max 1024 characters. (pajkycz@gmail.com)
- Merge pull request #590 from bbuckingham/fork-852631 (miroslav@suchy.cz)
- 841300 - Zoom out on 2-Pane page causes rendering error (pajkycz@gmail.com)
- Merge pull request #582 from Pajk/844413 (pajkycz@gmail.com)
- Merge pull request #587 from ehelms/bug-854573 (jrist@redhat.com)
- 852631 - system group - update model to raise exception when no groups exist
  (bbuckingham@redhat.com)
- 843529 - cleanup task_statuses and job_tasks on system deletion
  (bbuckingham@redhat.com)
- Merge pull request #567 from xsuchy/pull-req-status2 (bbuckingham@redhat.com)
- Merge pull request #584 from thomasmckay/linkback (thomasmckay@redhat.com)
- Updates ConvergeUI to the latest. (ehelms@redhat.com)
- pulpv2 - fixing return on refresh task (jsherril@redhat.com)
- 854573, 852167 - Fixes missing icons issue which also resolves an alignment
  issue on the content search page. (ehelms@redhat.com)
- gather up all packages for katello-debug (mmccune@redhat.com)
- Merge pull request #569 from pitr-
  ch/bug/803548-notification_pop_up_in_other_organization (kontakt@pitr.ch)
- linkback - make app prefix link helper (thomasmckay@redhat.com)
- workaround for bz 854263 (msuchy@redhat.com)
- 844413 - Creating user fails if role is created with same name
  (pajkycz@gmail.com)
- 843064 - Content Search - Products: Not required unless searching for
  Products itself, it's misleading when searching for Repos, Packages and
  Errata (pajkycz@gmail.com)
- Merge pull request #575 from xsuchy/pull-req-bz758651 (miroslav@suchy.cz)
- Merge branch 'master' into story/foreman_architectures (pchalupa@redhat.com)
- 760180,803548 - add Organization to Notice (pchalupa@redhat.com)
- Merge pull request #570 from lzap/system_register_853056 (lzap@redhat.com)
- fastbuild - adding macro for all spec files (lzap+git@redhat.com)
- 758651 - check if thin port is free before starting thin (msuchy@redhat.com)
- Merge pull request #543 from bbuckingham/fork-841289 (lzap@redhat.com)
- 853056 - system register without environment is working again
  (lzap+git@redhat.com)
- 853056 - improve 404 generic error message (lzap+git@redhat.com)
- job without task should not exists, this is error (msuchy@redhat.com)
- 851142 - CLI: changeset update shows strange error (pajkycz@gmail.com)
- List of sync plans added (pajkycz@gmail.com)
- fix for BZ 821345 (dmitri@redhat.com)
- Merge pull request #526 from pitr-ch/quick-fix/bundler_patch
  (kontakt@pitr.ch)
- Always use environment when requesting repo (pajkycz@gmail.com)
- Stupid default setting for user set_org (jrist@redhat.com)
- Minor accidental fix for extra char. (jrist@redhat.com)
- Initial workings of new default org stuff. (jrist@redhat.com)
- link back to source of manifest in import history (thomasmckay@redhat.com)
- pulpv2 - adding back role support now that it is present
  (jsherril@redhat.com)
- 806383 - [RFE] As the SE administrator I want to see all active and scheduled
  sync tasks for all organizations in one place (pajkycz@gmail.com)
- pulpv2 - migrating to proper repo cloning via unit copy (jsherril@redhat.com)
- Merge pull request #554 from mbacovsky/852804_updated_cui_reqs
  (martin.bacovsky@gmail.com)
- Updating Converge-UI (mbacovsk@redhat.com)
- Merge pull request #550 from lzap/sys_constraint_746765 (miroslav@suchy.cz)
- 746765 - systems can be referenced by uuid (lzap+git@redhat.com)
- Merge pull request #548 from pitr-ch/bug/831664
  -Repository_sync_failure_no_notice-error-details (kontakt@pitr.ch)
- Automatic commit of package [katello] release [1.1.9-1]. (msuchy@redhat.com)
- 834013 - return releaseVer as part of consumer json (thomasmckay@redhat.com)
- 746765 - removing system unique name constraint (lzap+git@redhat.com)
- Merge pull request #497 from Pajk/811556 (pajkycz@gmail.com)
- 831664 - Repository sync failures not displaying detailed error in Notices
  (pchalupa@redhat.com)
- Do not insert spaces before changesets description (pajkycz@gmail.com)
- 847858-actkeypool - fixed spec test failure (thomasmckay@redhat.com)
- Merge pull request #535 from jsomara/841857 (jrist@redhat.com)
- Updating converge-ui (jomara@redhat.com)
- 841289 - perform cleanup on failed registration with activation key
  (bbuckingham@redhat.com)
- 847858 - only remove act keys when resource not found error
  (thomasmckay@redhat.com)
- Merge pull request #537 from parthaa/content-deletion-perms
  (mmccune@gmail.com)
- Merge pull request #540 from Pajk/847115 (thomasmckay@redhat.com)
- katello - disable bundler patch by default, fix broken condition
  (pchalupa@redhat.com)
- 847115 - Extend scroll bug on content tab, with > 50 subscriptions only the
  first 50 will populate. (pajkycz@gmail.com)
- Merge pull request #536 from bbuckingham/fork-843462 (bbuckingham@redhat.com)
- Merge pull request #518 from bbuckingham/fork-842569 (bbuckingham@redhat.com)
- Automatic commit of package [katello] release [1.1.8-1]. (inecas@redhat.com)
- Added some unit to test the perm fixes (paji@redhat.com)
- 843462 - system group search indexing should not include pulp content
  (bbuckingham@redhat.com)
- Added permissions for content delete (paji@redhat.com)
- 841857 - fixing LDAP logins in katello mode (jomara@redhat.com)
- pulpv2 - breaking out importers and exporters (jsherril@redhat.com)
- subsfilter - reset the cycle of table row colors to avoid having first row of
  bottom table having same shading as the table header (ie. always start with
  light color row) (thomasmckay@redhat.com)
- subsfilter - removed second spinner when updating filtered subscriptions
  (thomasmckay@redhat.com)
- Available subscriptions on systems page now allow filtering matching what is
  available in subscription-manager-gui (thomasmckay@redhat.com)
- katello - add bundler patch to prefer rpm-gems (pchalupa@redhat.com)
- Merge pull request #528 from iNecas/cdn-substitutor-isolate (lzap@redhat.com)
- Rescue foreman model exceptions (pajkycz@gmail.com)
- Architectures API fix (pajkycz@gmail.com)
- Merge pull request #525 from ehelms/content-search-updates
  (jlsherrill@gmail.com)
- Content Search - Adds new data fields "data_type" and "value" to make testing
  easier. (ehelms@redhat.com)
- Merge pull request #524 from thomasmckay/845613-subs-display
  (jrist@redhat.com)
- cdn-var-substitutor - isolate the logic to separate class (inecas@redhat.com)
- 845613 - fix display of subscription status and rows (thomasmckay@redhat.com)
- Merge pull request #522 from bbuckingham/fork-845668 (mmccune@gmail.com)
- 845668 - removing console.log usage from js, which cause FF3.6 failures
  (bbuckingham@redhat.com)
- Merge pull request #494 from komidore64/product-names
  (thomasmckay@redhat.com)
- 846719 - Removes footer links entirely. (ehelms@redhat.com)
- pulpv2 - fixing package/errata list for new candidate build
  (jsherril@redhat.com)
- 842569 - system groups - fix for TypeError on status of errata install
  (bbuckingham@redhat.com)
- Merge pull request #505 from bkearney/bkearney/846321
  (thomasmckay@redhat.com)
- Merge pull request #176 from Katello/exception_handling (kontakt@pitr.ch)
- pulpv2 - fixing manifest import (jsherril@redhat.com)
- 845995 - fix syntax error (msuchy@redhat.com)
- pulpv2 - cancel sync now working (jsherril@redhat.com)
- Merge pull request #492 from lzap/thin_localhost_849224 (mmccune@gmail.com)
- Merge pull request #510 from mbacovsky/service-wait2commons
  (mmccune@gmail.com)
- Merge pull request #504 from bkearney/bkearney/845995 (mmccune@gmail.com)
- Moved service-wait link target to katello-common (mbacovsk@redhat.com)
- Merge pull request #503 from bbuckingham/fork-content-deletion-bugs
  (mmccune@gmail.com)
- 846321: Support creating permissions for all tags from the API and the cli
  (bkearney@redhat.com)
- Fix destroy foreman user (pajkycz@gmail.com)
- katello - add spec for Resources::ForemanModel (pchalupa@redhat.com)
- katello - fix foreman architetures, make sure actions won't fail silently
  (pchalupa@redhat.com)
- 845995: Add local and server side checks for passing in bad group names and
  ids (bkearney@redhat.com)
- Automatic commit of package [katello] release [1.1.7-1]. (mmccune@redhat.com)
- Merge remote-tracking branch 'upstream/foreman_architectures' into
  foreman_architectures (mbacovsk@redhat.com)
- Merge remote-tracking branch 'upstream/master' into foreman_architectures
  (mbacovsk@redhat.com)
- content-deletion - update content tree after product deletion
  (bbuckingham@redhat.com)
- 846251: Do not specify the attribute name for uniqueness validation
  (bkearney@redhat.com)
- 846251: Do not specify the attribute name for uniqueness validation
  (bkearney@redhat.com)
- Merge pull request #495 from iNecas/foreman (inecas@redhat.com)
- 850745 - secret_token is not generated properly (CVE-2012-3503)
  (lzap+git@redhat.com)
- katello-all - installs foreman as well (inecas@redhat.com)
- 805127 - require candlepin-selinux (msuchy@redhat.com)
- pulpv2 - fixing sync with candidate build, and improving sync status
  reporting (jsherril@redhat.com)
- content-deletion - update so that clicking on undefined changeset category
  doesnothing (bbuckingham@redhat.com)
- 844806 - katello incorrectly prevents products with the same name in an
  organization (adprice@redhat.com)
- 811556 - Displaced 'save' button while editing the changeset description
  under "changeset history" tab (pajkycz@gmail.com)
- fix build errors (msuchy@redhat.com)
- fix build errors on F17 (msuchy@redhat.com)
- Automatic commit of package [katello] release [1.1.6-1]. (msuchy@redhat.com)
- 844806 - katello incorrectly prevents products with the same name in an
  organization (adprice@redhat.com)
- Merge pull request #491 from mccun934/cd-unit-test-fix
  (bbuckingham@redhat.com)
- katello - be paranoid about Exceptions in production (pchalupa@redhat.com)
- remove Gemfile.lock after all packages are installed (msuchy@redhat.com)
- Merge branch 'foreman_architectures' of github.com:Katello/katello into
  foreman_architectures (pajkycz@gmail.com)
- Foreman Config Templates improvements (pajkycz@gmail.com)
- apidoc - added docs for config_templates (mbacovsk@redhat.com)
- apidoc -  added docs for domains (mbacovsk@redhat.com)
- 849224 - thin now listens only on localhost (lzap+git@redhat.com)
- Merge branch 'master' into story/exception_handling (pchalupa@redhat.com)
- Config templates CLI - print template kind (pajkycz@gmail.com)
- content deletion - unit test fix (mmccune@redhat.com)
- content-deletion - update product deletion to allow for re-promotion
  (bbuckingham@redhat.com)
- content-deletion - cleanup a few ui text strings (bbuckingham@redhat.com)
- Merge remote-tracking branch 'upstream/master' into content-deletion
  (bbuckingham@redhat.com)
- Merge pull request #461 from komidore64/systems-compliance
  (komidore64@gmail.com)
- Merge branch 'foreman_cli_domain' into foreman_architectures
  (pajkycz@gmail.com)
- Foreman domains added to CLI client (pajkycz@gmail.com)
- Changeset#remove_package! fix (pajkycz@gmail.com)
- katello - remove lists of rescue Exception usage (pchalupa@redhat.com)
- Merge branch 'master' into story/exception_handling (pchalupa@redhat.com)
- Merge pull request #484 from Pajk/api_test_fix (pajkycz@gmail.com)
- Merge branch 'master' into story/exception_handling (pchalupa@redhat.com)
- katello - fix tests after merge (pchalupa@redhat.com)
- changesets content api test fix (pajkycz@gmail.com)
- apidoc - removed duplicite api doc entry (mbacovsk@redhat.com)
- Merge remote-tracking branch 'upstream/master' into foreman_architectures
  (mbacovsk@redhat.com)
- apidoc - added api doc for architectures (mbacovsk@redhat.com)
- Merge pull request #431 from Pajk/api_issues (pajkycz@gmail.com)
- Foreman's Config Templates added to CLI client. (pajkycz@gmail.com)
- converge-ui - accidentally downgraded during previous merge... :(
  (bbuckingham@redhat.com)
- Merge remote-tracking branch 'upstream/master' into content-deletion
  (bbuckingham@redhat.com)
- Real. Fix. (Thx mmccne) for the user_sessions_controller (jrist@redhat.com)
- Fix for user_sessions_controller.rb spec test failure. (jrist@redhat.com)
- content deletion - putting commented code back in (mmccune@redhat.com)
- Merge branch 'content-deletion' of github.com:mccun934/katello into content-
  deletion (mmccune@redhat.com)
- content deletion - adding support for product deletion (mmccune@redhat.com)
- content deletion - adding support for product deletion (mmccune@redhat.com)
- pulpv2 - fixing some task related parsing and urls, sync management page now
  mostly works (jsherril@redhat.com)
- Merge pull request #477 from parthaa/delete-sys-templates
  (bbuckingham@redhat.com)
- Removed misleading/unused code in the deletion_changesets (paji@redhat.com)
- Merge pull request #457 from komidore64/systems-actions-fence
  (mmccune@gmail.com)
- Merge pull request #472 from mbacovsky/apidoc-role_ldap_group
  (mmccune@gmail.com)
- Merge pull request #436 from omaciel/userlocale (mmccune@gmail.com)
- Merge pull request #473 from parthaa/delete-sys-templates (mmccune@gmail.com)
- Merge branch 'master' into story/exception_handling (pchalupa@redhat.com)
- api docs - fix loading environment in build phase (inecas@redhat.com)
- api docs - show trace when API docs build fails (inecas@redhat.com)
- Fix 1.9 compatibility issue in the ContentSearchController
  (inecas@redhat.com)
- api docs - fix wrong syntax for param description (inecas@redhat.com)
- api docs - fix building for f17 - ruby 1.8 vs. 1.9 difference
  (inecas@redhat.com)
- Commented out unused parent template logic (paji@redhat.com)
- content-deletion - fix issue w/ deletion tree not loading on last env
  (bbuckingham@redhat.com)
- changesets - fix notice type on successful promotion/deletion
  (bbuckingham@redhat.com)
- Added system template deletion feature (paji@redhat.com)
- apidoc - docs for role_ldap_groups_controller (mbacovsk@redhat.com)
- Pulpv2 - fixing schedule application (jsherril@redhat.com)
- pulpv2 - cleaning some unused/no longer available repo attrs
  (jsherril@redhat.com)
- Pulpv2 - converting Repo creation/deletion (jsherril@redhat.com)
- Merge branch 'master' into story/exception_handling (pchalupa@redhat.com)
- api docs - don't require redcarpet if cache is turned on (inecas@redhat.com)
- Automatic commit of package [katello] release [1.1.5-1].
  (lzap+git@redhat.com)
- Merge pull request #464 from knowncitizen/orgfixes (ericdhelms@gmail.com)
- Merge remote-tracking branch 'upstream/content-deletion' into fork-content-
  deletion-3 (bbuckingham@redhat.com)
- content-deletion - convert action titles to tipsy for consistency
  (bbuckingham@redhat.com)
- Icon fix for content search: selector_icon-black (jrist@redhat.com)
- content-deletion - update helptip to include both deletion and promotion
  (bbuckingham@redhat.com)
- Switching oauth warden strategy to use request.headers (calfonso@redhat.com)
- content-deletion - add a tipsy to the 'Added' item in content tree
  (bbuckingham@redhat.com)
- Converge-UI update for spinner fadeOut. (jrist@redhat.com)
- Merge pull request #443 from pitr-ch/bug/830713-broken-gettext-translations
  (kontakt@pitr.ch)
- 838115 - Spinner fixes and org selection updates. (jrist@redhat.com)
- Merge branch 'master' into orgfixes (jrist@redhat.com)
- 841228, 844414 - Fix for logging in and not having an org. (jrist@redhat.com)
- content-deletion - add custom confirms for changeset deletion
  (bbuckingham@redhat.com)
- content-deletion - add title attribute to the changeset action bar
  (bbuckingham@redhat.com)
- content-deletion - update the content tree to use 'Added (Undo)' vs 'Remove'
  (bbuckingham@redhat.com)
- Revert "fixed a small typo." (adprice@redhat.com)
- content-deletion - update the content tree to use 'Added (Undo)' vs 'Remove'
  (bbuckingham@redhat.com)
- changing message to "Insufficient Subscriptions are Attached to This System"
  (adprice@redhat.com)
- Merge pull request #454 from eanxgeek/populate-systems-random
  (elsammons@gmail.com)
- 845611 - Subscriptions are not current message is confusing for system with
  insufficient subscriptions (adprice@redhat.com)
- api docs - katello-api-docs requires katello-common (inecas@redhat.com)
- api doc - don't require database to generate the html files
  (inecas@redhat.com)
- Use elasticsearch only in development and production (inecas@redhat.com)
- api docs - generate API docs in build time (inecas@redhat.com)
- api doc - separate environment for generating documentation in build phase
  (inecas@redhat.com)
- api doc - fix loading rake tasks when some dependencies not met
  (inecas@redhat.com)
- api doc - katello-api-docs package (inecas@redhat.com)
- disable using X-Sendfile for sending files (inecas@redhat.com)
- api doc - add dependency on rubygems-apipie-rails (inecas@redhat.com)
- api doc - recorded examples for API documentation (inecas@redhat.com)
- api docs - repositories controller (tomas.str@gmail.com)
- cli docs - fix for wrong system id type (tomas.str@gmail.com)
- api docs - system groups controller (tomas.str@gmail.com)
- api docs - fixed :bool param types (tomas.str@gmail.com)
- api docs - products (lzap+git@redhat.com)
- api docs - gpg keys (lzap+git@redhat.com)
- api docs - packages (lzap+git@redhat.com)
- api docs - environments (lzap+git@redhat.com)
- api docs - distributions (lzap+git@redhat.com)
- api docs - errata controller (msuchy@redhat.com)
- api docs - fix for wrong validation type in changeset and changeset_content
  controllers (tstrachota@redhat.com)
- Add documentation to the changeset controller. My notes, which I will share
  with the list, are (bkearney@redhat.com)
- Add documentation to the changeset content controller. (bkearney@redhat.com)
- api docs - uebercert controller (lzap+git@redhat.com)
- api docs - status controller (lzap+git@redhat.com)
- api docs - ping controller review (lzap+git@redhat.com)
- api docs - crls review (lzap+git@redhat.com)
- api docs - activation keys review (lzap+git@redhat.com)
- api docs - permissions controller (tstrachota@redhat.com)
- api docs - roles controller (tstrachota@redhat.com)
- api docs - users controller (inecas@redhat.com)
- api docs - for the organizations controller (tstrachota@redhat.com)
- api doc - config katello to use apipie (inecas@redhat.com)
- Merge branch 'foreman_architectures' of github.com:Katello/katello into
  foreman_architectures (pajkycz@gmail.com)
- Foreman config templates added, foreman model small changes
  (pajkycz@gmail.com)
- katello - remove password_confirmation from foreman user model
  (pchalupa@redhat.com)
- Fixed packaging of foreman stuff (mbacovsk@redhat.com)
- 830713 - fix monkey patch for ruby 1.9 (pchalupa@redhat.com)
- architectures - add conditional exposure of foreman api proxy
  (mbacovsk@redhat.com)
- Merge pull request #437 from xsuchy/pull-req-service-wait (lzap@redhat.com)
- content-deletion - remove the changeset type from the sliding tree listing
  (bbuckingham@redhat.com)
- content-deletion - load changeset sliding tree based on changeset hash
  (bbuckingham@redhat.com)
- Quick fix to a bug introduced in the package deletion and promotion
  (paji@redhat.com)
- 843904 - Systems page: user will see System Group and Errata elements along
  with install button and other. (adprice@redhat.com)
- content-deletion - fix some references to accessing current chgset breadcrumb
  (bbuckingham@redhat.com)
- changesets - fix the locked icon image on changeset list
  (bbuckingham@redhat.com)
- removed an extraneous logging to js console (dmitri@redhat.com)
- modified updating of system's environment on system edit page to piggyback on
  jeditable events. (dmitri@redhat.com)
- support for updating of system information screen-wide on system edit
  (dmitri@redhat.com)
- save button in path_selector is now being disabled after clicking
  (dmitri@redhat.com)
- various changes per code review (dmitri@redhat.com)
- Support for editing of system environment via web ui (dmitri@redhat.com)
- content-deletion - initial chgs to support 2 changeset trees
  (deletion/promotion) (bbuckingham@redhat.com)
- Org interstitial and switcher cleanup. 843853 and 841686 were fixed.
  (jrist@redhat.com)
- Merge branch 'master' of git://github.com/Katello/katello into populate-
  systems-random (elsammons@gmail.com)
- fixed a small typo. (elsammons@gmail.com)
- Fix overriding the Rails.env in jshint.rake (inecas@redhat.com)
- make user orchestration to use Foreman::User (pchalupa@redhat.com)
- foreman model polishing (pchalupa@redhat.com)
- Foreman models: Architecture, Domain (pajkycz@gmail.com)
- katello - foreman user mapping (pchalupa@redhat.com)
- Validation of locale during update handled by model. (ogmaciel@gnome.org)
- Allow user to update his/her own localevia cli. Also, output the default
  locale when using the info parameter. (ogmaciel@gnome.org)
- Added --default_locale to CLI for user creation. (ogmaciel@gnome.org)
- remove old foreman code (pchalupa@redhat.com)
- Fixed more spec tests (paji@redhat.com)
- Fixed broken spec tests that occured after master merge (paji@redhat.com)
- Merge remote-tracking branch 'upstream/content-deletion' into fork-content-
  deletion-3 (bbuckingham@redhat.com)
- 815802 - Description on package filter does not save properly
  (pajkycz@gmail.com)
- Removed unused methods in the pulp and reporb (paji@redhat.com)
- Automatic commit of package [katello] release [1.1.4-1]. (msuchy@redhat.com)
- Merge pull request #445 from ehelms/bz-842858 (mmccune@gmail.com)
- 842858 - Fixes path issue to locked icon when viewing available changesets on
  the promotion page. (ehelms@redhat.com)
- Content search - make positioning more custom (jsherril@redhat.com)
- Merge pull request #440 from iNecas/bz844678 (inecas@redhat.com)
- Merge pull request #418 from Pajk/844458 (pajkycz@gmail.com)
- 844678 - don't use multi-entitlements on custom products (inecas@redhat.com)
- Moved the add+remove repo packages method to orchestration layer
  (paji@redhat.com)
- Merge pull request #434 from jlsherrill/content-browser (jrist@redhat.com)
- CS - fixing vert align on view tipsy (jsherril@redhat.com)
- Merge pull request #433 from jsomara/840969 (jsomara@gmail.com)
- CS - fixing error on repo search with selected product (jsherril@redhat.com)
- architectures - code cleanup (mbacovsk@redhat.com)
- Fixed katello config file template (mbacovsk@redhat.com)
- Correcting grammar on user notification for deleted environment / User. ->
  self. (jomara@redhat.com)
- Fixed problem with storing resource class in class var (mbacovsk@redhat.com)
- Merge pull request #419 from komidore64/systems-cpu-sockets
  (adprice@redhat.com)
- Merge pull request #435 from komidore64/string-fix (adprice@redhat.com)
- Automatic commit of package [katello] release [1.1.3-1]. (msuchy@redhat.com)
- move service-wait to katello-common (msuchy@redhat.com)
- fixing bad merge conflict resolution (jsherril@redhat.com)
- 820634 - Katello String Updates (adprice@redhat.com)
- CS - fixing issue where select env before search threw error
  (jsherril@redhat.com)
- merge conflict (jsherril@redhat.com)
- CS - Adds missing variablization of color. (ehelms@redhat.com)
- Committed the wrong converge ui hash or something, EHELMS (jomara@redhat.com)
- 820634 - Katello String Updates (adprice@redhat.com)
- CS - making search button change text depending on context
  (jsherril@redhat.com)
- 840969 - making KT environment deletes ALSO remove the "default environment"
  relationship to any applicable users. It also notifies the users when they
  log in (jomara@redhat.com)
- 820634 - Katello String Updates (adprice@redhat.com)
- 820634 - Katello String Updates (adprice@redhat.com)
- 820634 - Katello String Updates (adprice@redhat.com)
- 820634 - Katello String Updates (adprice@redhat.com)
- 820634 - Katello String Updates (adprice@redhat.com)
- Merge branch 'master' of github.com:Katello/katello into content-browser
  (ehelms@redhat.com)
- CS - A number of minor updates. (ehelms@redhat.com)
- 821929 - Typo: You -> Your (adprice@redhat.com)
- content-deletion - add a promotion/deletion banner to the changeset tree
  (bbuckingham@redhat.com)
- CS - auto complete enhancements (jsherril@redhat.com)
- Speeded up package deletion and promotion by using a differnt call in pulp
- CS - fixing repo compare title (jsherril@redhat.com)
- Introduce +load_remote_data+ method to lazy_attributes (inecas@redhat.com)
- New Role form rewritten (pajkycz@gmail.com)
- Merge branch 'form_builder' into master (pajkycz@gmail.com)
- CS - fixing caching not working properly (jsherril@redhat.com)
- Merge pull request #424 from bbuckingham/fork-content-deletion-3
  (parthaa@gmail.com)
- Merge pull request #392 from Pajk/system_keys_list (pajkycz@gmail.com)
- Revert "update converge ui" (mmccune@redhat.com)
- update converge ui (mmccune@redhat.com)
- Merge remote-tracking branch 'upstream/content-deletion' into content-
  deletion (mmccune@redhat.com)
- content deletion - taking out unecessary fields from the JSON
  (mmccune@redhat.com)
- Updating the converge-ui version (paji@redhat.com)
- content-deletion - update repo deletion to disable or remove based on env
  (bbuckingham@redhat.com)
- content-deletion - updates to handle last env in path
  (bbuckingham@redhat.com)
- adding test for commit 6ed001305416785dab12a94c99f11f93332a3a4a
  (adprice@redhat.com)
- 841984 - Creating new user displays confusing/misleading notification
  (adprice@redhat.com)
- Fixed some merge conflicts (paji@redhat.com)
- Automatic commit of package [katello] release [1.1.2-1].
  (thomasmckay@redhat.com)
- little test fix (adprice@redhat.com)
- fixing broken tests due to commit 3bf7ccfbe0f6a82a8d7a7d3108ab9c1358ecb657
  (adprice@redhat.com)
- 803757 - Systems: Users should not be able to enter anything other than
  positive integers for sockets (adprice@redhat.com)
- Merge pull request #411 from thomasmckay/crosslink (thomasmckay@redhat.com)
- 844458 - GET of unknown user returns 500 (pajkycz@gmail.com)
- Merge pull request #415 from Pajk/765989 (thomasmckay@redhat.com)
- Automatic commit of package [katello] release [1.1.1-1]. (msuchy@redhat.com)
- Merge pull request #409 from xsuchy/pull-req-buildroot2 (lzap@redhat.com)
- 765989 - Read Only account shows unused checkbox on System / Subscription
  page (pajkycz@gmail.com)
- buildroot and %%clean section is not needed (msuchy@redhat.com)
- Merge pull request #408 from lzap/installer_f17 (miroslav@suchy.cz)
- Merge branch 'master' into exception_handling (pajkycz@gmail.com)
- Fixes for some of API issues (pajkycz@gmail.com)
- CS - Adds removal of metadata row whenever all elements have been loaded.
  (ehelms@redhat.com)
- CS - Turn more colors into variables. Fixes issue with label appearing
  uncentered.  Adds disabling and tooltip to compare repos button.
  (ehelms@redhat.com)
- 842003 - fixing error on search when no errata existed (jsherril@redhat.com)
- 844796 - For async manifest import, there were double-render errors while the
  progress was being checked from javascript. In addition, notices were not
  being displayed after a very quick manifest import. (thomasmckay@redhat.com)
- build katello-headpin and katello-headpin-all from the same src.rpm as
  katello (msuchy@redhat.com)
- crosslink - updated attribute for multi-entitlement pool
  (thomasmckay@redhat.com)
- Include css for activation_keys/system_groups. (pajkycz@gmail.com)
- Merge branch 'master' into system_keys_list (pajkycz@gmail.com)
- Merge pull request #405 from lzap/migrate_fix (miroslav@suchy.cz)
- Merge pull request #400 from thomasmckay/crosslink (inecas@redhat.com)
- CS - Adds permission check for managing environments on environment selector.
  Adds direct link to current organization if link is present.
  (ehelms@redhat.com)
- rb19 - encoding fix turned off for 1.9 (lzap+git@redhat.com)
- fixing old env selector issue caused by new path selector
  (jsherril@redhat.com)
- Check if systems/keys are readable by user. (pajkycz@gmail.com)
- rb19 - removing exact versions from Gemfile (lzap+git@redhat.com)
- rb19 - and one more UTF8 encoding fix (lzap+git@redhat.com)
- CS - Sort environments on repo comparison according to promotion path
  (jsherril@redhat.com)
- CS - adding tipsy for view selector and changing terminology
  (jsherril@redhat.com)
- Move activation key to system events section (pajkycz@gmail.com)
- US22811 - added architecture controller proxy (mbacovsk@redhat.com)
- puppet - better wait code for mongod (lzap+git@redhat.com)
- Merge pull request #404 from lzap/installer (miroslav@suchy.cz)
- Bumping package versions for 1.1. (msuchy@redhat.com)
- puppet - moving lib/util into common subpackage (lzap+git@redhat.com)
- Automatic commit of package [katello] release [1.0.1-1]. (msuchy@redhat.com)
- bump up version to 1.0 (msuchy@redhat.com)
- content deletion - proper deletion support in the CLI (mmccune@redhat.com)
- Automatic commit of package [katello] release [0.2.56-1]. (msuchy@redhat.com)
- crosslink - links from system and activation key subscriptions
  (thomasmckay@redhat.com)
- Merge branch 'master' of github.com:Katello/katello into content-browser
  (jsherril@redhat.com)
- CS - Addition of ellipsis names of column headers with regards to showing
  both the repository name and environment name on repo compare.
  (ehelms@redhat.com)
- CS - Adds Manage Organizations link to the environment selector.
  (ehelms@redhat.com)
- CS - Moves the comparison grid JS into the widgets section.
  (ehelms@redhat.com)
- CS - Updates path selector footer to allow for arbitrary content.
  (ehelms@redhat.com)
- CS - Updates to the way package names are displayed. (ehelms@redhat.com)
- CS - Updates for taller rows to accomodate larger repository names. Adds
  tooltipping to ellipsied names. (ehelms@redhat.com)
- CS - Fixes checkbox showing through env selector, remove auto complete icon
  and button sliding under input box. (ehelms@redhat.com)
- CS - Styling updates. (ehelms@redhat.com)
- CS - Adding repo search help (jsherril@redhat.com)
- spec - fixing invalid perms for /var/log/katello (lzap+git@redhat.com)
- Fencing system groups from activation keys nav (pajkycz@gmail.com)
- Activation key - show list of registered systems (pajkycz@gmail.com)
- Automatic commit of package [katello] release [0.2.55-1]. (msuchy@redhat.com)
- Merge pull request #389 from lzap/quick_certs_fix (miroslav@suchy.cz)
- Automatic commit of package [katello] release [0.2.54-1]. (msuchy@redhat.com)
- Merge pull request #379 from xsuchy/pull-req-entity (lzap@redhat.com)
- puppet - improving katello-debug script (lzap+git@redhat.com)
- Automatic commit of package [katello] release [0.2.53-1]. (msuchy@redhat.com)
- content-deletion - minor changes to changeset history
  (bbuckingham@redhat.com)
- content-deletion - add changeset type to changeset listing (changesets pg)
  (bbuckingham@redhat.com)
- content-deletion - update specs to account for the promote vs apply name
  change (bbuckingham@redhat.com)
- content-deletion - change cs promote status text to apply (to be generic)
  (bbuckingham@redhat.com)
- content-deletion - update cs create to default to promotion
  (bbuckingham@redhat.com)
- content-deletion - add backend support for deleting repos
  (bbuckingham@redhat.com)
- content-deletion - add backend support for deleting distributions
  (bbuckingham@redhat.com)
- content-deletion - add backend support for deleting errata
  (bbuckingham@redhat.com)
- Adding a missing 'deleted' state to indicate succesfu completion of delete
  (paji@redhat.com)
- Made the promotion UI use the 'apply' method generated by the model
  (paji@redhat.com)
- Added methods to generate repo metadata when packages are deleted
  (paji@redhat.com)
- Made the delete packages call use packages object (paji@redhat.com)
- Merge pull request #378 from xsuchy/pull-req-tar-gz (mmccune@gmail.com)
- Merge branch 'content-deletion' into package-changes (paji@redhat.com)
- Made the deletion changeset more bare bones . Trying to just get package
  delete workign at this point (paji@redhat.com)
- content deletion - adding back in the CLI promote and apply
  (mmccune@redhat.com)
- content-deletion - update how changesets are listed when page loaded
  (bbuckingham@redhat.com)
- content-deletion - skip dependency resolution for deletion changesets
  (bbuckingham@redhat.com)
- content-deletion - first mods to integrate js w/ controller (apply/status)
  (bbuckingham@redhat.com)
- Added the deleting state (paji@redhat.com)
- Fixed a compile glitch (paji@redhat.com)
- CS - using newer errata icon classes (jsherril@redhat.com)
- making 'Id' be i18n'd (jsherril@redhat.com)
- content-deletion - fix promotion... accidental regression for env handling
  (bbuckingham@redhat.com)
- content-deletion - minor changes to allow creation of changeset in UI
  (bbuckingham@redhat.com)
- Merge branch 'master' of github.com:Katello/katello into content-browser
  (jsherril@redhat.com)
- replace character by html entity (msuchy@redhat.com)
- point Source0 to fedorahosted.org where tar.gz are stored (msuchy@redhat.com)
- converge ui update (jsherril@redhat.com)
- INitial work on remove packages (paji@redhat.com)
- Automatic commit of package [katello] release [0.2.52-1].
  (lzap+git@redhat.com)
- Merge pull request #345 from lzap/installer_review (lzap@redhat.com)
- Merge pull request #371 from jsomara/840609 (jsomara@gmail.com)
- require recent converge-ui (msuchy@redhat.com)
- Automatic commit of package [katello] release [0.2.51-1]. (msuchy@redhat.com)
- revert submodule pointer accidentaly moved in 97319cd (msuchy@redhat.com)
- fix typo in repo files (msuchy@redhat.com)
- Fixed some unit tests. (paji@redhat.com)
- fixed a typo (paji@redhat.com)
- Adding a new changeset model for Content Deletion (paji@redhat.com)
- spec test fix (jsherril@redhat.com)
- 840609 - fencing SYSTEM GROUPS from activation keys nav (jomara@redhat.com)
- Merge pull request #362 from ehelms/convergeui-updates (mmccune@gmail.com)
- Fixes active button state increasing the size of the button awkwardly.
  (ehelms@redhat.com)
- CS - fixing various issues with cache not being properly saved/loaded
  (jsherril@redhat.com)
- CS - fix issue with drop-downs not being updated properly
  (jsherril@redhat.com)
- CS - Add errata details tipsy to other errata lists (jsherril@redhat.com)
- CS - handle case when errata has no packages (jsherril@redhat.com)
- CS - fixing a couple of issues (jsherril@redhat.com)
- CS - fixing issue where environments were not properly remembered
  (jsherril@redhat.com)
- CS - adding errata details using ajax tipsy (jsherril@redhat.com)
- puppet - adding mongod to the service-wait script (lzap+git@redhat.com)
- content-deletion - set the ui action button to promote/delete based on cs
  type (bbuckingham@redhat.com)
- content-deletion - update navigation for changesets (bbuckingham@redhat.com)
- content-deletion - only allow promotion changesets when in Library
  (bbuckingham@redhat.com)
- content-deletion - fix specs broken on previous commit
  (bbuckingham@redhat.com)
- content-deletion - associate proper env with changeset upon creation
  (bbuckingham@redhat.com)
- content-deletion - fix broken spec (bbuckingham@redhat.com)
- Automatic commit of package [katello] release [0.2.50-1]. (msuchy@redhat.com)
- Merge pull request #365 from jlsherrill/content-browser-unit-test
  (parthaa@gmail.com)
- unit test fix (jsherril@redhat.com)
- Updates the submodule hash to point to 0.8.3-1 of ConvergeUI.
  (ehelms@redhat.com)
- Merge remote-tracking branch 'katello/master' into bug-840531
  (ehelms@redhat.com)
- puppet - adding service-wait wrapper script (lzap+git@redhat.com)
- All specs passing (pajkycz@gmail.com)
- Updates to make integration of converge-ui's newest changes cleaner and
  remove repetition of CSS styling in the browser. (ehelms@redhat.com)
- Adds override on header for thick border to the left and right of tabs.
  (ehelms@redhat.com)
- Fixes for updates from ConvergeUI. (ehelms@redhat.com)
- content-deletion - changeset history - show changeset type
  (bbuckingham@redhat.com)
- content-deletion - show cs type on promotions cs edit details pane
  (bbuckingham@redhat.com)
- content-deletion - initial ui chgs for add/remove to deletion changeset
  (bbuckingham@redhat.com)
- Merge pull request #354 from jsomara/841691 (mmccune@gmail.com)
- More tweaks + a spec test (jomara@redhat.com)
- fixing issue where repos only in library would show up (jsherril@redhat.com)
- promotions - bug - promoted repo can be promoted over and over
  (bbuckingham@redhat.com)
- Style changes as per pull request comments (jomara@redhat.com)
- Adding fresh copy of katello.spec due to bad merge (jsherril@redhat.com)
- master merge conflict (jsherril@redhat.com)
- 840531 - Fixes issue with inability to individually promote packages attached
  to a system template or changeset that have more than a single dash in the
  name. (ehelms@redhat.com)
- Exceptions - review and cleanup (pajkycz@gmail.com)
- Merge pull request #346 from xsuchy/pull-req-spec-gemfile (lzap@redhat.com)
- Automatic commit of package [katello] release [0.2.49-1].
  (lzap+git@redhat.com)
- Merge pull request #355 from lzap/rake_compatibility (miroslav@suchy.cz)
- rake - make rake compatible with 0.8.7 - fix (lzap+git@redhat.com)
- rake - make rake compatible with 0.8.7 (lzap+git@redhat.com)
- fixing mistaken name change (jsherril@redhat.com)
- 841691 - Moving interface display to DETAILS page and removing it from system
  list (jomara@redhat.com)
- promotions - fix bugs with removing packages from a changeset
  (bbuckingham@redhat.com)
- need a sudo in front of the cat so it can read the pass file
  (mmccune@redhat.com)
- exceptions - review and cleanup (pajkycz@gmail.com)
- Automatic commit of package [katello] release [0.2.48-1].
  (lzap+git@redhat.com)
- gemfile - decreasing thin 1.2.11 requirement to 1.2.8 (lzap+git@redhat.com)
- put spec on pair with Gemfile (msuchy@redhat.com)
- puppet - introducing temp answer file for dangerous options
  (lzap+git@redhat.com)
- puppet - not changing seeds.rb anymore with puppet (lzap+git@redhat.com)
- puppet - moving config_value function to rails context (lzap+git@redhat.com)
- puppet - removing log dir mangling (lzap+git@redhat.com)
- Merge pull request #338 from bbuckingham/fork-bug_fixes (parthaa@gmail.com)
- content-deletion - remove 'promotion' from several display text items
  (bbuckingham@redhat.com)
- content-deletion - update ui to support defining an action type on changeset
  (bbuckingham@redhat.com)
- CS - properly handling search error (jsherril@redhat.com)
- merge conflict (jsherril@redhat.com)
- CS - changing collect{} ids on active record queries to use pluck
  (jsherril@redhat.com)
- Merge branch 'master' into exception_handling (pajkycz@gmail.com)
- Adding pluck support to active record, new feature backported from 3.1
  (jsherril@redhat.com)
- Fixed some unit test breakages caused by commit
  f06bf0c5383dffef7ee2aea6597aaa06c4964ab9 (paji@redhat.com)
- Fencing more system groups code for systems page (jomara@redhat.com)
- system groups - fix query on systems -> system groups pane
  (bbuckingham@redhat.com)
- Forgot to undo one part (paji@redhat.com)
- Made some modifications on the initial model based on comments
  (paji@redhat.com)
- master merge conflict fix (jsherril@redhat.com)
- CS - greatly condensing bbq for environments (jsherril@redhat.com)
- Added action type to  changeset to accomadate content deletion
  (paji@redhat.com)
- CS - fixing initially selected environment (jsherril@redhat.com)
- system groups - updates to validation of max_systems (bbuckingham@redhat.com)
- CS - fixing consistency with page_size arguments (jsherril@redhat.com)
- Merge pull request #329 from Pajk/sticky_thirdlvl_nav
  (thomasmckay@redhat.com)
- master merge (jsherril@redhat.com)
- CS - a few suggested fixes (jsherril@redhat.com)
- Added a way to return 'empty search results', an array with 'total' attribute
  (paji@redhat.com)
- CS - implementing roles based access controls (jsherril@redhat.com)
- Merge pull request #315 from mccun934/group-copy (bbuckingham@redhat.com)
- system groups - API accepts max_systems and CLI unit tests
  (mmccune@redhat.com)
- 839265 - system - generate proper error if user attempts to add groups w/o
  providing any (bbuckingham@redhat.com)
- Fixed an issue where the rescue in Packages and Errata search was catching
  non bad query exceptions (paji@redhat.com)
- system groups - close copy widget when switching objects or panes
  (bbuckingham@redhat.com)
- Added unit tests to test differnt actions in content search (paji@redhat.com)
- Automatic commit of package [katello] release [0.2.47-1]. (msuchy@redhat.com)
- fixing build issue (msuchy@redhat.com)
- a2x require /usr/bin/getopt (msuchy@redhat.com)
- Automatic commit of package [katello] release [0.2.46-1]. (msuchy@redhat.com)
- do not copy files which we do not need/want (msuchy@redhat.com)
- introduce katello-service for managing katello services (msuchy@redhat.com)
- Merge branch 'master' into bug/808437-notifications_after_cli
  (pchalupa@redhat.com)
- Merge pull request #177 from pitr-ch/profiling (kontakt@pitr.ch)
- Make third level navigation in panel sticky (pajkycz@gmail.com)
- 841000 - fixing product autocomplete issues (jsherril@redhat.com)
- Merge pull request #330 from bbuckingham/fork-system_group_dashboard
  (jlsherrill@gmail.com)
- CS - adding shared/unique modes to the repo search (jsherril@redhat.com)
- Merge pull request #325 from jsomara/ldap_test_fix (thomasmckay@redhat.com)
- system groups - move the listing of groups by updates needed to the model
  (bbuckingham@redhat.com)
- CS - adding all/unique/shared selector to product search
  (jsherril@redhat.com)
- system group - fix accidental change on file header (bbuckingham@redhat.com)
- Merge remote-tracking branch 'upstream/master' into fork-
  system_group_dashboard (bbuckingham@redhat.com)
- system groups - update dashboard to account for critical/warning/up-to-date
  (bbuckingham@redhat.com)
- Merge branch 'master' into 808437-RFE-no_notifications_for_CLI_actions_in_GUI
  (pchalupa@redhat.com)
- Removing the global after/do for role spec (jomara@redhat.com)
- CS - adding mode switcher to repo comparison (jsherril@redhat.com)
- 840625 - Post 'import manifest' subscriptions return row:NotFound
  (pajkycz@gmail.com)
- system groups - add portlet to the dashboard for groups
  (bbuckingham@redhat.com)
- system groups - fix js syntax error (bbuckingham@redhat.com)
- from petr; improving config setting in role test for ldap (jomara@redhat.com)
- Merge pull request #323 from Pajk/840600 (thomasmckay@redhat.com)
- Merge pull request #256 from xsuchy/pull-req-defattr (miroslav@suchy.cz)
- 840600 - Post creating new environment in headpin, webui returns row:NotFound
  error (pajkycz@gmail.com)
- katello - action profiling (pchalupa@redhat.com)
- Fixing some ldap config issues that were polluting unrelated tests
  (jomara@redhat.com)
- master merge conflict (jsherril@redhat.com)
- reverting to the same hash as I had originally (mmccune@redhat.com)
- Merge pull request #310 from thomasmckay/null_activeBlockId
  (thomasmckay@redhat.com)
- Merge pull request #319 from jlsherrill/content-browser
  (ericdhelms@gmail.com)
- spec test fix (jsherril@redhat.com)
- Merge pull request #316 from jlsherrill/content-browser
  (ericdhelms@gmail.com)
- CS - Changes sliding aspect of grid to be more inuitive to a user's
  experience such that clicking to slide right reveals more columns to the
  right. (ehelms@redhat.com)
- content browser - fixing migration script to properly propogate
  (jsherril@redhat.com)
- system groups - removing local modifications not intended for upstream
  (mmccune@redhat.com)
- Merge branch 'master' into group-copy (mmccune@redhat.com)
- system groups - unit tests and error conditions (mmccune@redhat.com)
- content browser - fixing migration to migrate clone.library_instance_id
  properly (jsherril@redhat.com)
- Merge pull request #311 from pitr-ch/make_jshintrb_optional
  (ericdhelms@gmail.com)
- katello - make jshintrb optional (pchalupa@redhat.com)
- Automatic commit of package [katello] release [0.2.45-1].
  (lzap+git@redhat.com)
- null_activeBlockId - fixed case where active block was not known
  (thomasmckay@redhat.com)
- system_details - added display of environment to left list and details page
  (thomasmckay@redhat.com)
- Added server side code for Repo Compare Shared/Unique (paji@redhat.com)
- Merge pull request #305 from jsomara/ldap_fluff (mmccune@gmail.com)
- productid - fixed html for System / Subscriptions (thomasmckay@redhat.com)
- Merge pull request #300 from thomasmckay/839005_force
  (thomasmckay@redhat.com)
- Merge pull request #284 from bbuckingham/fork-group_remove_lock
  (thomasmckay@redhat.com)
- ldap provided by ldap_fluff. Adds support for FreeIPA & Active Directory
  (jomara@redhat.com)
- Removes test data from code that prevents production asset compiling.
  (ehelms@redhat.com)
- Merge remote-tracking branch 'katello/master' into content-browser
  (ehelms@redhat.com)
- Adds fencing around jshint for development environment only.
  (ehelms@redhat.com)
- 811564_subs_match - change default user preference to 'false' for 'match
  subscriptions to system' (thomasmckay@redhat.com)
- CS - Minor styling updates and a fix for packages with the same ID showing up
  only once in the grid. (ehelms@redhat.com)
- Merge pull request #299 from thomasmckay/bonus_rename (ericdhelms@gmail.com)
- 839005 - removed 'force' from upload manifest in UI (thomasmckay@redhat.com)
- bonus_rename - changed Bonus From to Virt Guest From in System Details page
  (thomasmckay@redhat.com)
- system groups - fix css for handling separator between copy and remove links
  (bbuckingham@redhat.com)
- system groups - close 'copy' form when panel is closed
  (bbuckingham@redhat.com)
- Merge branch 'master' into 808437-RFE-no_notifications_for_CLI_actions_in_GUI
  (pchalupa@redhat.com)
- group copy cli and API first pass (mmccune@redhat.com)
- CS - Fixes issue with data export for returning to results.
  (ehelms@redhat.com)
- content  browser - adding search mode selector (jsherril@redhat.com)
- Merge branch 'content-browser' of github.com:Katello/katello into content-
  browser (jsherril@redhat.com)
- CS - Styling updates for browse box. (ehelms@redhat.com)
- actkey_section - activation_keys_controller returning incorrect section_id
  (thomasmckay@redhat.com)
- content browser - fixing metadata ro wmissing (jsherril@redhat.com)
- content browser - preparing for mode selector and other fixes
  (jsherril@redhat.com)
- Merge branch 'content-browser' of github.com:Katello/katello into content-
  browser (jsherril@redhat.com)
- CS - Update to how columns are handled to produce logical pathing order
  across browsers. (ehelms@redhat.com)
- CS - Styling updates to environment selector widget. (ehelms@redhat.com)
- merge conflict (jsherril@redhat.com)
- Merge pull request #289 from bbuckingham/fork-group_copy2
  (jlsherrill@gmail.com)
- Merge remote-tracking branch 'upstream/master' into fork-group_remove_lock
  (bbuckingham@redhat.com)
- content browser - adding show/hide support for compare button
  (jsherril@redhat.com)
- Initial stab at the server side interaction of shared vs unique
  (paji@redhat.com)
- Adds removal of two development tasks from spec file. (ehelms@redhat.com)
- system groups - removing 'locked' feature from the javascript
  (bbuckingham@redhat.com)
- system groups - remove initialization of variable to undefined
  (bbuckingham@redhat.com)
- system groups - updating packages table header based on UXD input
  (bbuckingham@redhat.com)
- system groups - include system count on panel for create and copy
  (bbuckingham@redhat.com)
- system group - update pkgs controller notices to use %%s vs named params
  (bbuckingham@redhat.com)
- subs-tupane - two pane subscriptions view (thomasmckay@redhat.com)
- Merge pull request #282 from bbuckingham/fork-group_copy2
  (thomasmckay@redhat.com)
- system groups - update notices to use %%s vs named params
  (bbuckingham@redhat.com)
- Merge pull request #276 from ehelms/jshintrb (jlsherrill@gmail.com)
- 837136 - fixing promotions packages sometimes not loading
  (jsherril@redhat.com)
- Fix for broken GPG Keys unit test. (ehelms@redhat.com)
- system groups - removing the 'locked' feature from system groups UI/API/CLI
  (bbuckingham@redhat.com)
- content browser - intitial comparison wiring (jsherril@redhat.com)
- Merge pull request #283 from knowncitizen/master (ericdhelms@gmail.com)
- Updated hash for login fix. (jrist@redhat.com)
- Fix for spinner issues on login page. (jrist@redhat.com)
- system groups - copy - add spec tests (bbuckingham@redhat.com)
- CS - Proper hash from master merge. (ehelms@redhat.com)
- CS - Changes for repository comparison checkboxes supplying column and row
  id. (ehelms@redhat.com)
- revert - accidental commit to development.rb (bbuckingham@redhat.com)
- system groups - ui - add the ability to create a group based on copy of an
  existing group (bbuckingham@redhat.com)
- Merge pull request #268 from bbuckingham/fork-group_events
  (ericdhelms@gmail.com)
- Merge remote-tracking branch 'katello/master' into content-browser
  (ehelms@redhat.com)
- content browser - manually switching to results mode on search to fix some
  oddities (jsherril@redhat.com)
- content browser - making content selector show selected value
  (jsherril@redhat.com)
- content browser - fixing issue with more rows showing up when not needed
  (jsherril@redhat.com)
- content browser - fixing issue with more rows on repo contents
  (jsherril@redhat.com)
- content browser - fixing issue where packages and errata were not including a
  parent_row (jsherril@redhat.com)
- content browser - fixing merge conflict and making all data returned as a
  hash (jsherril@redhat.com)
- CS - Fixes for empty space when last column is visible and another column is
  removed from the visible set. (ehelms@redhat.com)
- Katello-debug should pull in httpd logs and conf files (bkearney@redhat.com)
- JSHint - Adds support for running JSHint in development via a rake task.
  (ehelms@redhat.com)
- CS - Fixes messed up errata column headers. (ehelms@redhat.com)
- content browser - adding more rows support for repo errata & packages
  (jsherril@redhat.com)
- CS - Adds count updates on metadata row. (ehelms@redhat.com)
- CS - Adds spinner and disabled load more link. (ehelms@redhat.com)
- CS - Updates to load extra data above the load more row instead of underneath
  it. (ehelms@redhat.com)
- CS - Adjusts spinner location and look. (ehelms@redhat.com)
- CS - Adds display of repository name when viewing repo details.
  (ehelms@redhat.com)
- content browser - making package ids not analyzed in elastic search
  (jsherril@redhat.com)
- content browser - some small performance improvements, adding hover on
  products (jsherril@redhat.com)
- content browser - adding tipsy for search help (jsherril@redhat.com)
- Updated hash for converge-ui to include pull request. (jrist@redhat.com)
- adding a library_instance_id to the repository object (jsherril@redhat.com)
- CS - Rows nested deeper than 2 levels will now be collapsed on initial draw.
  (ehelms@redhat.com)
- CS - Cleanup for loading screen. (ehelms@redhat.com)
- content browser - content selector and more rows wiring (jsherril@redhat.com)
- jsroutes update (jsherril@redhat.com)
- panelpage - rename BBQ from 'action' to 'panelpage' (thomasmckay@redhat.com)
- Merge branch 'content-browser' of github.com:Katello/katello into content-
  browser (jsherril@redhat.com)
- CS - RE-factor of how child rows are handled to support loading of more rows
  in a cleaner manor. (ehelms@redhat.com)
- panelpage - clean up var declaration (thomasmckay@redhat.com)
- Merge branch 'master' into exception_handling (pchalupa@redhat.com)
- panelpage - maintain which tab of panel was last visible
  (thomasmckay@redhat.com)
- Merge branch 'exception_handling' of git://github.com/Katello/katello into
  exception_handling (pchalupa@redhat.com)
- Merge pull request #265 from bbuckingham/fork-cli_actions
  (thomasmckay@redhat.com)
- Merge pull request #270 from knowncitizen/orgswitcher
  (thomasmckay@redhat.com)
- Automatic commit of package [katello] release [0.2.44-1].
  (lzap+git@redhat.com)
- Removed duplicate .versionining declaration. (jrist@redhat.com)
- Fixed menu for organizations in administer, tweak on org switcher.
  (jrist@redhat.com)
- Updated hash for lastest converge-ui. (jrist@redhat.com)
- Merge branch 'master' into orgswitcher (jrist@redhat.com)
- Org switcher interstitial post-login. (jrist@redhat.com)
- errata module - moving it from controllers to lib (bbuckingham@redhat.com)
- Merge branch 'content-browser' of github.com:Katello/katello into content-
  browser (jsherril@redhat.com)
- Merge branch 'content-browser' of github.com:Katello/katello into content-
  browser (ehelms@redhat.com)
- CS - Adds initial support paginated loading of data via "show more" row.
  (ehelms@redhat.com)
- content browser - improving user experience of selecting environments
  (jsherril@redhat.com)
- systems - update packages pane to support accessing task details on
  completion (bbuckingham@redhat.com)
- systems - fix specs due to uuid to id change for actions
  (bbuckingham@redhat.com)
- initial untested pagination (jsherril@redhat.com)
- system - update the packages UI to use task id vs uuid
  (bbuckingham@redhat.com)
- system groups - update packages pane to support accessing job details
  (bbuckingham@redhat.com)
- system groups - update errata pane to support accessing job details
  (bbuckingham@redhat.com)
- CS - Cleanup around row collapse. (ehelms@redhat.com)
- CS - Adds ability to enable checkboxes on individual cells.
  (ehelms@redhat.com)
- 829437 - handle uploading GPG key when submitting with enter
  (inecas@redhat.com)
- content browser - making path selector not reserve checkbox space
  (jsherril@redhat.com)
- CS - Adds ability to set a title in the details view, and specify a details
  content selector. (ehelms@redhat.com)
- system groups - api/cli - add ability to list errata by group
  (bbuckingham@redhat.com)
- content browser - fixing package/errata search issues (jsherril@redhat.com)
- content browser - changing position of path selector (jsherril@redhat.com)
- content browser - fixing nonenabled repos showing up (jsherril@redhat.com)
- Merge pull request #244 from bbuckingham/fork-cli_actions (inecas@redhat.com)
- content browser - a few fixes (jsherril@redhat.com)
- Merge pull request #255 from xsuchy/pull-req-ownlogfiles
  (jlsherrill@gmail.com)
- katello - corrections after pull request review (pchalupa@redhat.com)
- Removed exclamation mark from welcome message, as it is followed by a comma
  and the user name. (ogmaciel@gnome.org)
- Additional params for the condition to check if manage orgs ability.
  (jrist@redhat.com)
- Added perm for org editablity. (jrist@redhat.com)
- content browser - fixing 2 issues with grid caching (jsherril@redhat.com)
- content browser - hooking up back button (jsherril@redhat.com)
- Fixing navigation for HEADPIN mode (system groups) (jomara@redhat.com)
- CS - Adds support for allowing columns to span multiple column widths.
  (ehelms@redhat.com)
- CS - Adds back to results button and associated generic event upon click.
  (ehelms@redhat.com)
- content browser - fixing error when no errata exist (jsherril@redhat.com)
- Band-aid commit to update submodule hash to latest due to addition of version
  requirement in katello spec. (ehelms@redhat.com)
- %%defattr is not needed since rpm 4.4 (msuchy@redhat.com)
- we should own log files (msuchy@redhat.com)
- fixing path selector not maintaining selected environments
  (jsherril@redhat.com)
- system groups - cli - split history in to 2 actions per review feedback
  (bbuckingham@redhat.com)
- Merge pull request #253 from xsuchy/pull-req-jammit (inecas@redhat.com)
- Merge pull request #251 from xsuchy/pull-req-fix-br (inecas@redhat.com)
- allow to run jammit on Fedora 17 (msuchy@redhat.com)
- Merge pull request #240 from xsuchy/pull-req-bz835322 (ericdhelms@gmail.com)
- content browser - adding errata search (jsherril@redhat.com)
- fixing issue with rows having odd characters in their names
  (jsherril@redhat.com)
- require converge-ui-devel >- 0.7 for building (msuchy@redhat.com)
- Automatic commit of package [katello] release [0.2.43-1].
  (lzap+git@redhat.com)
- Org switcher interstitial working minus scrolling in the switcher itself. :(
  (jrist@redhat.com)
- fixing merge conflict (jsherril@redhat.com)
- Merge pull request #248 from parthaa/repo-compare-server-side
  (ericdhelms@gmail.com)
- removing console.log statement (jsherril@redhat.com)
- Changes to login to accomodate org switcher interstitial. (jrist@redhat.com)
- merge conflcit (jsherril@redhat.com)
- CS - Updates to deep copy exported object states from the grid.
  (ehelms@redhat.com)
- Added server side bindings for cs compare packages and errata calls
  (paji@redhat.com)
- system groups - api/cli to support errata install (bbuckingham@redhat.com)
- content browser - adding initial search caching support (jsherril@redhat.com)
- Merge branch 'content-browser' of github.com:Katello/katello into content-
  browser (jsherril@redhat.com)
- CS - Exposes export/import functionality to instantiated grid objects.
  (ehelms@redhat.com)
- Merge branch 'content-browser' of github.com:Katello/katello into content-
  browser (jsherril@redhat.com)
- CS - Adds seperated data layer for import/export of states.
  (ehelms@redhat.com)
- fixing converge-ui hash (jsherril@redhat.com)
- merge conflict (jsherril@redhat.com)
- content browser - initial subgrid support initially just packages
  (jsherril@redhat.com)
- Merge remote-tracking branch 'upstream/master' into fork-cli_actions
  (bbuckingham@redhat.com)
- system groups - api/cli to support package and package group actions
  (bbuckingham@redhat.com)
- system groups - fix the perms used in packages and errata controllers
  (bbuckingham@redhat.com)
- 808437 - [RFE] Don't make notifications for CLI actions performed (and pop
  them up in UI) (pchalupa@redhat.com)
- katello - notifications cleanup (pchalupa@redhat.com)
- katello - remove unused methods (pchalupa@redhat.com)
- Merge remote-tracking branch 'katello/master' into content-browser
  (ehelms@redhat.com)
- routes update (jsherril@redhat.com)
- jsroutes update (jsherril@redhat.com)
- merge conflict (jsherril@redhat.com)
- 835322 - when creating new user, validate email (msuchy@redhat.com)
- Added serverside code for package and repo contents (paji@redhat.com)
- content browser - initial pkg pagination support (jsherril@redhat.com)
- Merge branch 'content-browser' of github.com:Katello/katello into content-
  browser (jsherril@redhat.com)
- content browser - fixing some mistaken text labels (jsherril@redhat.com)
- content browser - adding initial package pagination (jsherril@redhat.com)
- Merge branch 'master' of github.com:Katello/katello into orgswitcher
  (jrist@redhat.com)
- content browser - adding library id to search index for respositories
  (jsherril@redhat.com)
- Merge pull request #237 from knowncitizen/spritesfix (ericdhelms@gmail.com)
- Stupid extra space. (jrist@redhat.com)
- Fix for a missing 'fr' in a gradient. (jrist@redhat.com)
- More SCSS refactoring and a fix for converge-ui spec. (jrist@redhat.com)
- point Support link to irc channel #katello (miroslav@suchy.cz)
- Automatic commit of package [katello] release [0.2.42-1].
  (lzap+git@redhat.com)
- CS - Fixes nesting collapse for multiple children. (ehelms@redhat.com)
- content browser - having package search return packages (jsherril@redhat.com)
- merge conflict (jsherril@redhat.com)
- CS - Clean-up and refactoring. (ehelms@redhat.com)
- CS - Adds basic footer to grid component. (ehelms@redhat.com)
- CS - Makes environment selector a more generic feature of the grid.
  (ehelms@redhat.com)
- CS - Adds loading screen for switching grid data. (ehelms@redhat.com)
- CS - Updates to styling and adding hover states to sliding arrows.
  (ehelms@redhat.com)
- CS - Adds generic row nesting with colllapse functionality attached to parent
  rows. (ehelms@redhat.com)
- CS - Adds hover support and custom display data for cells.
  (ehelms@redhat.com)
- CS - Adjustments to sliding states of arrows.  Addition of new environment
  selector icon. (ehelms@redhat.com)
- initial package search (jsherril@redhat.com)
- jsroutes update (jsherril@redhat.com)
- Merge pull request #232 from pitr-ch/asynchronous_manifest_import
  (thomasmckay@redhat.com)
- katello - async manifest import, missing notices (pchalupa@redhat.com)
- Merge pull request #227 from witlessbird/move-system (lzap@redhat.com)
- ulimit - brad's review (lzap+git@redhat.com)
- Added some initial permissions stubs for search controller (paji@redhat.com)
- Merge branch 'content-browser' of github.com:Katello/katello into content-
  browser (jsherril@redhat.com)
- Redirect working. (jrist@redhat.com)
- Working on interstitial for Orgs! (jrist@redhat.com)
- ulimit - optimizing usage validator (lzap+git@redhat.com)
- changed 'update' tests to use 'put' instead of 'post'
  (dmitri@appliedlogic.ca)
- BZ 825262: support for moving systems between environments from CLI
  (dmitri@appliedlogic.ca)
- ulimit - fix for system tests (lzap+git@redhat.com)
- ulimit - adding unit tests (lzap+git@redhat.com)
- ulimit - new jeditable component "number" (lzap+git@redhat.com)
- ulimit - frontend changes (lzap+git@redhat.com)
- ulimit - backend api and cli (lzap+git@redhat.com)
- ulimit - adding migration (lzap+git@redhat.com)
- Added code to render the product and repo search results in a new json
  structure (paji@redhat.com)
- Merge pull request #224 from bbuckingham/fork-group_delete_systems
  (parthaa@gmail.com)
- katello - fix gettext wrappers (pchalupa@redhat.com)
- Merge remote-tracking branch 'upstream/master' into fork-group_delete_systems
  (bbuckingham@redhat.com)
- system groups - cli/api - provide user option to delete systems when deleting
  group (bbuckingham@redhat.com)
- content browser - adding autocomplete for packages (jsherril@redhat.com)
- CS - Fix for hiding column. (ehelms@redhat.com)
- CS - Updates to add first level row nesting support. (ehelms@redhat.com)
- CS - Additional styling and addition of on hover state for scrolling.
  (ehelms@redhat.com)
- Updated stylings and added icons for content search. (ehelms@redhat.com)
- CS - Fixes up spacing for grids and cells.  Adds left and right sliding of
  content area with column headers. (ehelms@redhat.com)
- CS - Applying some base styling. (ehelms@redhat.com)
- katello - asynchronous manifest import in UI (pchalupa@redhat.com)
- Merge pull request #213 from jsomara/819002 (thomasmckay@redhat.com)
- Merge remote-tracking branch 'upstream/master' into fork-group_delete_systems
  (bbuckingham@redhat.com)
- system groups - ui - provide user option to delete systems when deleting
  group (bbuckingham@redhat.com)
- content browse - some style fixes (jsherril@redhat.com)
- customConfirm - add more settings and refactor current usage
  (bbuckingham@redhat.com)
- content-browser - initial selection of library environment
  (jsherril@redhat.com)
- katello, unit - fixing broken unit test (pchalupa@redhat.com)
- katello, unit - correcting supported versions of rspec for monkey patch
  (pchalupa@redhat.com)
- path selector - making path selector adjust horizontally based on available
  space (jsherril@redhat.com)
- Make sure to reference ::Pool when using the model class (inecas@redhat.com)
- Automatic commit of package [katello] release [0.2.41-1].
  (lzap+git@redhat.com)
- Merge branch 'content-browser' of github.com:Katello/katello into content-
  browser (ehelms@redhat.com)
- Merge pull request #205 from jlsherrill/content-browser (parthaa@gmail.com)
- Updates as a result of merging master and updating converge-ui.
  (ehelms@redhat.com)
- Merge remote-tracking branch 'katello/master' into content-browser
  (ehelms@redhat.com)
- 819002 - Removing password & email validation for user creation in LDAP mode
  (jomara@redhat.com)
- Updates to git left and right arrows showing up only when more than 3
  environments are present. (ehelms@redhat.com)
- Adds structure and functionality for scrolling environments left and right in
  the column headers. (ehelms@redhat.com)
- Merge branch 'master' of github.com:Katello/katello into orgswitcher
  (jrist@redhat.com)
- system groups - update views to use _tupane_header partial
  (bbuckingham@redhat.com)
- Fixes box-shadow declaration that was causing a compass deprecation warning.
  (ehelms@redhat.com)
- Updates SCSS importing for missing mixins. (ehelms@redhat.com)
- Merge pull request #199 from bbuckingham/fork-group_events (jrist@redhat.com)
- Merge branch 'fork-master' into fork-group_events (bbuckingham@redhat.com)
- system groups - provide a more meaningful helptip on the index
  (bbuckingham@redhat.com)
- Fix for Events to now be "Events History" - slightly more explicit.
  (jrist@redhat.com)
- katello - fix Gemfile versions (pchalupa@redhat.com)
- system groups - minor updates to job and task_status (bbuckingham@redhat.com)
- task_status - rename method names based (bbuckingham@redhat.com)
- CS - Adds the structure and building blocks for allowing environments to be
  scrolled left to right when they overflow the header. (ehelms@redhat.com)
- CS - Setting of margins and general spacings for grid and browse boxes.
  (ehelms@redhat.com)
- Merge pull request #198 from ehelms/froyo (jrist@redhat.com)
- activation keys - update subscriptions pane to use the panel_link
  (bbuckingham@redhat.com)
- rename navigation_element as panel_link, use it for link on group pane
  (bbuckingham@redhat.com)
- Added smarts to only do the search call if necessary in content_search
  (paji@redhat.com)
- Added bbq support for environments in the content_search page
  (paji@redhat.com)
- content browser - adding product information for repos (jsherril@redhat.com)
- system groups - api - include total system count in system group info
  (bbuckingham@redhat.com)
- system groups - add system count to Details page (bbuckingham@redhat.com)
- content-browser - initial repo search (jsherril@redhat.com)
- js routes update (jsherril@redhat.com)
- Removes no longer used route and asset declaration. Adds back template
  rendering test case for change password. (ehelms@redhat.com)
- Merge pull request #202 from pitr-ch/fix_gettext_translations
  (inecas@redhat.com)
- content-browser - making browse box support search & autocomplete
  (jsherril@redhat.com)
- system groups - add missing escape_javascript to _common_i18n.html.haml
  (bbuckingham@redhat.com)
- Removing orgs from top level menu. (jrist@redhat.com)
- 830713 - broken gettext translations (pchalupa@redhat.com)
- Updates to latest converge-ui to incorporate most recent adjustments to sign-
  on screens. (ehelms@redhat.com)
- 828308 - Updating sync plan does not update associated product's (repo's)
  sync schedule (pchalupa@redhat.com)
- Merge remote-tracking branch 'upstream/master' into fork-group_events
  (bbuckingham@redhat.com)
- system groups - remove 'details' on job since it is a dup of as_json
  (bbuckingham@redhat.com)
- system groups - add few specs for events controller (bbuckingham@redhat.com)
- Merge pull request #196 from thomasmckay/subs-tupane (jlsherrill@gmail.com)
- Fixes for broken spec tests as a result of moving password recovery views.
  (ehelms@redhat.com)
- system group - add some initial search support to group history
  (bbuckingham@redhat.com)
- exceptions - review by lzap (lzap+git@redhat.com)
- Merge remote-tracking branch 'katello/master' into froyo (ehelms@redhat.com)
- Updates converge-ui version. (ehelms@redhat.com)
- Org switcher movement and Administer button movement. (jrist@redhat.com)
- Adds variables for upstream coloring and cleans up some unneeded converge-ui
  pieces. (ehelms@redhat.com)
- Clean-up of views that are no longer needed as a result of using converge-ui
  layouts. (ehelms@redhat.com)
- 827540 - system template - description to promotions view
  (bbuckingham@redhat.com)
- subs-tupane - changed camelCase to under_score, fixed spec tests
  (thomasmckay@redhat.com)
- subs-tupane - case statement instead of if/elsif, elasticsearch
  index_settings tweak (thomasmckay@redhat.com)
- subs-tupane: move some of the logic out of Pool.index_pools to the controller
  (thomasmckay@redhat.com)
- subs-tupane: since not all pools are saved as activerecords, just those
  referenced in activation keys, removed use of IndexedModel
  (thomasmckay@redhat.com)
- subs-tupane: reverted a change to indexed_model.rb (thomasmckay@redhat.com)
- subs-tupane: new Pool class in place of KTPool with relevant attributes, all
  indexed for search (thomasmckay@redhat.com)
- system events - fix specs related to changes in status retrieval
  (bbuckingham@redhat.com)
- exceptions - tstrachota's portion reviewed (tstrachota@redhat.com)
- systems - events - update search to include task owner
  (bbuckingham@redhat.com)
- system groups - remove tasks class from view (bbuckingham@redhat.com)
- 830713 - broken gettext translations (pchalupa@redhat.com)
- system groups - support status updates on individual system tasks
  (bbuckingham@redhat.com)
- system groups - event/job status updates (bbuckingham@redhat.com)
- Merge pull request #192 from jlsherrill/content-browser
  (ericdhelms@gmail.com)
- Added a landing point for Content Search page under Content Management
  (paji@redhat.com)
- content browser - adding bbq to main search (jsherril@redhat.com)
- Updates to login to handle case when LDAP is enabled. (ehelms@redhat.com)
- CFB - Wires up basic product search results to grid view to allow viewing of
  products and marking with an 'x' which environments currently visible a
  product is in. (ehelms@redhat.com)
- CFB - Fix to set the line height in path selector and not inherit from parent
  elements. (ehelms@redhat.com)
- CFB - Adds some basic styling for cells and support for adding rows with new
  column paradigm. (ehelms@redhat.com)
- CFB - Changes the way columns are added to the grid structure and wires up
  the environment selector to add/remove columns. (ehelms@redhat.com)
- CFB - Adds support for adding new rows and new columns. (ehelms@redhat.com)
- CFB - Wires up basic row/column adding within grid view. (ehelms@redhat.com)
- content browser - product autocomplete and autocomplete list support
  (jsherril@redhat.com)
- Merge pull request #189 from thomasmckay/830176-missing-localization
  (bbuckingham@redhat.com)
- system groups - events - add a tipsy to show status of a task
  (bbuckingham@redhat.com)
- system groups - when saving tasks for a job, associate system w/ the task
  (bbuckingham@redhat.com)
- task status - clean up some of the status messages (bbuckingham@redhat.com)
- 830176 - wrapped New System text w/ _() (thomasmckay@redhat.com)
- system and group actions - replacing .spinner with use of image_tag
  (bbuckingham@redhat.com)
- 815308 - traceback on package search (tstrachota@redhat.com)
- Check for current user. (jrist@redhat.com)
- Org Switcher initial changes. (jrist@redhat.com)
- Added product search + Autocomplete for the content browser
- system packages - fix event binding (bbuckingham@redhat.com)
- Merge remote-tracking branch 'katello/master' into froyo (ehelms@redhat.com)
- Updates pathing for some assets in converge-ui and bumps the version to
  include recent login and re-factor work. (ehelms@redhat.com)
- Merge branch 'master' of github.com:Katello/katello into fork-group_events
  (bbuckingham@redhat.com)
- Adds a rake task that explicitly specifies the directories to look in for
  translations.  This was done to add in and address translations living in the
  dependent converge-ui project. (ehelms@redhat.com)
- removal of system_tasks, replace with polymorphic assoc on task_statuses
  (bbuckingham@redhat.com)
- content browser - changing return value of products (jsherril@redhat.com)
- content browser - adding browse box logic, and initial search logic
  (jsherril@redhat.com)
- updated js routes (jsherril@redhat.com)
- Changes around using the user sessions layouts from converge-ui in order to
  fit with new styling and to ensure consistent wiring of views to controller.
  (ehelms@redhat.com)
- Adds font URL settings for compass to generate font-url's directly based off
  the Relative Root Url. (ehelms@redhat.com)
- Merge pull request #182 from knowncitizen/master (bbuckingham@redhat.com)
- Icons fix that is in converge-ui. (jrist@redhat.com)
- 829208 - fix importing manifest after creating custom product
  (inecas@redhat.com)
- Fixes for both extra arrows on menu in panel and for details icon
  duplication. (jrist@redhat.com)
- UI Remodel - More updates to stylesheets to relfect changes in converge-ui
  with regards to importing the proper scss files. (ehelms@redhat.com)
- system groups - initial commit to introduce group events
  (bbuckingham@redhat.com)
- system - minor refactors for code that will be shared for system groups
  (bbuckingham@redhat.com)
- 823642 - nil checks in candlepin's product resource (tstrachota@redhat.com)
- Merge branch 'master' into froyo (ehelms@redhat.com)
- environment selector - making return data ordered, and fixing returned name
  (jsherril@redhat.com)
- Merge pull request #169 from ehelms/content-browser (jrist@redhat.com)
- Merge branch 'master' into exception_handling (pchalupa@redhat.com)
- katello - remove 'rescue Exception' (pchalupa@redhat.com)
- system groups - update errata and packages partials to use new spinner
  definition (bbuckingham@redhat.com)
- system groups - update to have Content as 3rd level nav
  (bbuckingham@redhat.com)
- fixing missing pixel (jsherril@redhat.com)
- Merge remote-tracking branch 'upstream/master' into system-groups
  (bbuckingham@redhat.com)
- Merge pull request #175 from ehelms/master (jrist@redhat.com)
- Provides fix for updated yield blocks within converge-ui. (ehelms@redhat.com)
- Merge pull request #174 from bbuckingham/master (jrist@redhat.com)
- system - updating to support Content as 3rd level nav
  (bbuckingham@redhat.com)
- changing env selector to use a label instead of an anchor
  (jsherril@redhat.com)
- Merge pull request #171 from pitr-ch/track_creation_of_mocks
  (eric.d.helms@gmail.com)
- minor path selector improvements and additional interface functions
  (jsherril@redhat.com)
- Merge pull request #161 from knowncitizen/converge-fix
  (bbuckingham@redhat.com)
- Removed now unnecessary (and previously commented) code block.
  (jrist@redhat.com)
- Fix for previously pulled out auto_complete functionality. (jrist@redhat.com)
- Merge pull request #172 from thomasmckay/818726-i18n (jsomara@gmail.com)
- 818726 - updated i18n translations (thomasmckay@redhat.com)
- Merge branch 'master' into 818726-i18n (thomasmckay@redhat.com)
- Automatic commit of package [katello] release [0.2.40-1].
  (lzap+git@redhat.com)
- katello, unit tests - track creation line of mocks (pchalupa@redhat.com)
- Merge branch 'master' into converge-fix (jrist@redhat.com)
- Merge pull request #157 from pitr-ch/fix_sync_plan_spec
  (eric.d.helms@gmail.com)
- environment selector - more improvements to selector (jsherril@redhat.com)
- CFB - Adds selection and input elements for browse box as basic layout - no
  functionality. (ehelms@redhat.com)
- Fix for appname in header on converge-ui. (jrist@redhat.com)
- environment selector - add first environment linkage for selection
  (jsherril@redhat.com)
- adding selectability to the path selector (jsherril@redhat.com)
- js - minor updates based on pull request 166 feedback
  (bbuckingham@redhat.com)
- CFB - Adds basic layouts for browse box and grid. (ehelms@redhat.com)
- system groups - UI - initial commit to enable pkg/group install/update/remove
  (bbuckingham@redhat.com)
- system task - missed a change on the task status refactor
  (bbuckingham@redhat.com)
- system groups - minor update to correctly reflect object being returned
  (bbuckingham@redhat.com)
- packages - refactor js utilities for reuse (bbuckingham@redhat.com)
- system tasks - refactor the task status for reuse in system groups...etc.
  (bbuckingham@redhat.com)
- system packages - refactor few methods that will be reused for system groups
  (bbuckingham@redhat.com)
- system package actions - fix text/parameters on some notices
  (bbuckingham@redhat.com)
- initial new environment selector (jsherril@redhat.com)
- 815308 - escaping character '^' for elastic searches (tstrachota@redhat.com)
- white-space formatting (pchalupa@redhat.com)
- 807288 - changeset history tab raising undefined method (pchalupa@redhat.com)
- 824944 - Fix for logout button missing. (jrist@redhat.com)
- Converge-UI and Katello SCSS and Image refactor. (jrist@redhat.com)
- 822672 - Making rake setup set the URL_ROOT correctly for headpin
  (jomara@redhat.com)
- Merge pull request #154 from jlsherrill/system-groups
  (eric.d.helms@gmail.com)
- Merge pull request #151 from lzap/crl_regen_821644 (tstrachota@redhat.com)
- katello - fix config loading in rake setup (pchalupa@redhat.com)
- katello, unit-test - fix model/sync_plan_spec (pchalupa@redhat.com)
- Merge pull request #155 from tstrachota/cli_api_fixes (inecas@redhat.com)
- 826249 - system by environment page generates error (bbuckingham@redhat.com)
- UI Remodel - Updates to login and password reset/change screens to get the
  converge-ui versions working. (ehelms@redhat.com)
- Initial content search boilerplate (jsherril@redhat.com)
- permissions/roles api - fix for organization_id required always
  (tstrachota@redhat.com)
- system groups - adding history api (jsherril@redhat.com)
- Merge pull request #137 from iNecas/bz805956 (mmccune@gmail.com)
- Merge pull request #144 from iNecas/bz823890 (thomasmckay@redhat.com)
- UI Remodel - Updates converge-ui javascript paths to point to base javascript
  directory and not just the lib. (ehelms@redhat.com)
- 821644 - cli admin crl_regen command - unit and system test
  (lzap+git@redhat.com)
- UI Remodel - Adds working login screen and footer. (ehelms@redhat.com)
- 805956 - daily cron script for checking for new content on CDN
  (inecas@redhat.com)
- system groups - errata - show systems errata associated with
  (bbuckingham@redhat.com)
- Merge branch 'master' into system-groups (bbuckingham@redhat.com)
- system groups - fix jslint error on systems.js (bbuckingham@redhat.com)
- Merge pull request #138 from Katello/system-groups (parthaa@gmail.com)
- Merge pull request #148 from jsomara/822069 (eric.d.helms@gmail.com)
- 822069 - Additional fix - left integer in return body (jomara@redhat.com)
- 753128 - Ensures that status updates to the sync management page are driven
  solely by data returned from the server. (ehelms@redhat.com)
- First pass integration of converge-ui login layout.  Styles the login screen
  and allows for successful login. (ehelms@redhat.com)
- system groups - improving permissions on systems check of system_group
  (jsherril@redhat.com)
- Merge pull request #141 from bbuckingham/master (eric.d.helms@gmail.com)
- system groups - update index for group ids in the system model
  (bbuckingham@redhat.com)
- 823890 - delete products that were removed from new manifest
  (inecas@redhat.com)
- Automatic commit of package [katello] release [0.2.39-1].
  (lzap+git@redhat.com)
- system groups - removing multiselect widgets (bbuckingham@redhat.com)
- converge-ui - updated to pull in the new jquery widgets for multiselect
  (bbuckingham@redhat.com)
- system groups - minor mods for pull request comments (bbuckingham@redhat.com)
- 824069 - adding marketing_product flag to product (lzap+git@redhat.com)
- Merge branch 'master' into system-groups (bbuckingham@redhat.com)
- system groups - fix scss - regression during refactoring to share between
  systems and groups (bbuckingham@redhat.com)
- system groups - prepend Resources:: to Pulp call ... fix for recent master
  merge (bbuckingham@redhat.com)
- system groups - fixes regression from past merge of headpin flags
  (bbuckingham@redhat.com)
- system groups - spec tests for new systems controller actions
  (bbuckingham@redhat.com)
- system groups - generate error notice if no pkg, pkg grp or errata are
  provided (bbuckingham@redhat.com)
- system groups - fixing spec test in api (jsherril@redhat.com)
- 806353 - The time selector widget on the Sync Plans page will no longer get
  stuck on the page and prevent clicking of the save button.
  (ehelms@redhat.com)
- 821528 - fixing %%config on httpd.conf for RPM upgrades (jomara@redhat.com)
- system groups - merge conflict (jsherril@redhat.com)
- system groups - initial specs for errata controller (bbuckingham@redhat.com)
- Automatic commit of package [katello] release [0.2.38-1].
  (lzap+git@redhat.com)
- Fixes failing users controller spec tests. (ehelms@redhat.com)
- Fixes for failing spec tests as part of the merge of new UI changes.
  (ehelms@redhat.com)
- system groups - replacing add link with button (jsherril@redhat.com)
- system groups - making system group systems tab conform more to the mockups
  (jsherril@redhat.com)
- Merge pull request #127 from jsomara/822069 (thomasmckay@redhat.com)
- Removing unused menu code. (jrist@redhat.com)
- Automatic commit of package [katello] release [0.2.37-1].
  (lzap+git@redhat.com)
- Merge pull request #125 from ehelms/master (mmccune@gmail.com)
- 822069 - Making candlepin proxy DELETE return a body for sub-man consumer
  delete methods (jomara@redhat.com)
- system groups - adding count (jsherril@redhat.com)
- system groups - Adds missing param for max_systems on system group creation.
  (ehelms@redhat.com)
- system groups - adding locked groups from system pages (jsherril@redhat.com)
- system groups - adding missing partials (jsherril@redhat.com)
- system groups - adding locked icon to locked groups (jsherril@redhat.com)
- system groups - minor chg to labels based on sprint review feedback
  (bbuckingham@redhat.com)
- system groups - initial UI code to support errata install for groups
  (bbuckingham@redhat.com)
- system groups - initial model/glue/resources to support system group actions
  (bbuckingham@redhat.com)
- Revert "system groups - adding environment api calls and tests"
  (jsherril@redhat.com)
- Merge pull request #126 from lzap/cli_ak_regression (tstrachota@redhat.com)
- removing mod_authz_ldap from dependencies (lzap+git@redhat.com)
- cli registration regression with aks (lzap+git@redhat.com)
- Automatic commit of package [katello] release [0.2.36-1].
  (lzap+git@redhat.com)
- encryption - fix problems with logger not being initialized
  (inecas@redhat.com)
- encryption - fix running in development environment (inecas@redhat.com)
- Merge pull request #124 from iNecas/require-refactor (lzap@seznam.cz)
- Merge pull request #111 from lzap/encryption3 (necasik@gmail.com)
- Merge pull request #120 from lzap/qpiddrpm_819941 (necasik@gmail.com)
- Updates converge-ui for styling fix. (ehelms@redhat.com)
- system groups - adding environment api calls and tests (jsherril@redhat.com)
- Updates converge-ui for latest bug fixes and tagged version.
  (ehelms@redhat.com)
- Merge branch 'master' into froyo (ehelms@redhat.com)
- reduce usage of require for code in lib dir (inecas@redhat.com)
- 797412 - Unit test fix that should ve gone with the previous commit
  (paji@redhat.com)
- system groups - adding activation key validation for environments <-> system
  groups (jsherril@redhat.com)
- Updates to latest converge-ui for bug fixes. (ehelms@redhat.com)
- Merge pull request #119 from knowncitizen/froyo (eric.d.helms@gmail.com)
- 819941 - missing dependencies in katello-all (common) (lzap+git@redhat.com)
- Fixed hover menu setup. (jrist@redhat.com)
- 797412 - Added a comment to explain why index rule is set to true
  (paji@redhat.com)
- Patch to render sub menu main (paji@redhat.com)
- Updating the version of converge-ui. (ehelms@redhat.com)
- 797412 - Removed an unnecessary filter since only one controller call was
  using it. (paji@redhat.com)
- 797412 - Moved back search to index method (paji@redhat.com)
- system groups - adding environment model to system groups
  (jsherril@redhat.com)
- Fix for import path change. (ehelms@redhat.com)
- Updates to spec file. (ehelms@redhat.com)
- Updates to spec file for changes in converge-ui-devel. (ehelms@redhat.com)
- Hacky fix to show submenus on hover. (jrist@redhat.com)
- 797412 - Fixed environment search call in the cli (paji@redhat.com)
- Merge branch 'master' into system-groups (bbuckingham@redhat.com)
- system errata - mv js to load on index (bbuckingham@redhat.com)
- encryption - plain text passwords encryption (lzap+git@redhat.com)
- 818726 - update to both ui and cli and zanata pushed (thomasmckay@redhat.com)
- Merge pull request #108 from thomasmckay/821010-cdn-fail (jrist@redhat.com)
- Merge branch 'master' into froyo (ehelms@redhat.com)
- Merge pull request #104 from jlsherrill/bz814118 (eric.d.helms@gmail.com)
- Updates to include missing body tag id for each major section. Updates
  converge-ui. (ehelms@redhat.com)
- 821010 - catch and log errors fetching release versions from cdn
  (thomasmckay@redhat.com)
- product model - returned last_sync and sync_state fields back to json export
  They were removed with headpin merge but cli uses them.
  (tstrachota@redhat.com)
- fixing code style (jsherril@redhat.com)
- Merge branch 'master' into system-groups (bbuckingham@redhat.com)
- fixing spacing (mmccune@redhat.com)
- adding better example output (mmccune@redhat.com)
- removing root requirement so you can keep your files owned by your user
  (mmccune@redhat.com)
- 814118 - fixing issue where updating gpg key did not refresh cp content
  (jsherril@redhat.com)
- system groups - fix broken spec on api system groups controller
  (bbuckingham@redhat.com)
- system groups - fix failed activation key specs/tests
  (bbuckingham@redhat.com)
- system groups - only list groups w/ available capacity on systems page
  (bbuckingham@redhat.com)
- system group - add group name to the validation error
  (bbuckingham@redhat.com)
- system groups - update add/remove system to handle errors
  (bbuckingham@redhat.com)
- auto_complete - update to js to allow users to reset the input
  (bbuckingham@redhat.com)
- restores the ability to use the -f force flag.  previous commit broke it
  (mmccune@redhat.com)
- Merge pull request #102 from mccun934/reset-dbs-dev-mode (jrist@redhat.com)
- removing the old 'clear-all' script and moving to just one script
  (mmccune@redhat.com)
- Fixes another issue with panel sliding out incorrectly due to changes in left
  offsets. (ehelms@redhat.com)
- Updates converge-ui. (ehelms@redhat.com)
- Adds changes to footer to bring i18n text into project and out of converge-
  ui. (ehelms@redhat.com)
- system groups - validate max systems during a system bulk action
  (bbuckingham@redhat.com)
- Fix for panel opening and closing in the wrong spot:    Due to the panel
  being relative to the container #maincontent   instead of being relative to
  the container #maincontent.maincontent (jrist@redhat.com)
- system groups - validation updates for max systems (bbuckingham@redhat.com)
- system groups - Adds the maximum systems paramter for CLI create/update.
  (ehelms@redhat.com)
- 812891 - Adding hypervisor record deletion to katello cli (jomara@redhat.com)
- system groups - fixing scope issue on systems autocomplete
  (jsherril@redhat.com)
- system groups - add some basic validations on max_systems
  (bbuckingham@redhat.com)
- system-groups - model - rename max_members to max_systems
  (bbuckingham@redhat.com)
- Merge pull request #94 from jsomara/795869 (jrist@redhat.com)
- systems - fix broken systmes page after merge (bbuckingham@redhat.com)
- system groups - add model and ui to provision max systems for a group
  (bbuckingham@redhat.com)
- systems - fix error on UI create (bbuckingham@redhat.com)
- 795869 - Fixing org name in katello-configure to accept spaces but still
  create a proper candlepin key (jomara@redhat.com)
- system groups - fixing create due to recent merge (jsherril@redhat.com)
- system groups - fixing broken systems page after merge (jsherril@redhat.com)
- white space formatting (pchalupa@redhat.com)
- 783402 - It is possible to add a template to a change set twice
  (pchalupa@redhat.com)
- refactoring - removing duplicate method definition (pchalupa@redhat.com)
- Automatic commit of package [katello] release [0.2.35-1].
  (lzap+git@redhat.com)
- Merge branch 'master' into system-groups (ehelms@redhat.com)
- Fix for a very minor typo in the CSS. (jrist@redhat.com)
- adding the ability to pass in 'development' as your env (mmccune@redhat.com)
- 817848 - Adding dry-run to candlepin proxy routes (jomara@redhat.com)
- system group - Adds support for a system that is registering via activation
  keys to be placed into the system groups associated with those activation
  keys (ehelms@redhat.com)
- system groups - adding more system permission spec tests
  (jsherril@redhat.com)
- system groups - fixing some broken spec tests (jsherril@redhat.com)
- system groups - update akey system groups to use the new multiselect
  (bbuckingham@redhat.com)
- system groups - fixing query issues that reduced system visibility
  (jsherril@redhat.com)
- system groups - fix the usage of group locking in systems controller
  (bbuckingham@redhat.com)
- system groups - fix the locked field on controller and minor fix on notices
  (bbuckingham@redhat.com)
- system groups - update Systems Bulk Action for Groups to use the multiselect
  widget (bbuckingham@redhat.com)
- system groups - fixing some wrongly-named methods (jsherril@redhat.com)
- system groups - adding a few more missing model level role access and tests
  (jsherril@redhat.com)
- 818689 - update spec test when activating system with activation key to check
  for hidden user (thomasmckay@redhat.com)
- 818689 - update spec test when activating system with activation key to check
  for hidden user (thomasmckay@redhat.com)
- 818689 - set the current user before attempting to access activation keys to
  allow communication with candlepin (thomasmckay@redhat.com)
- system groups - permissions: deletion and UI membership (jsherril@redhat.com)
- Merge pull request #85 from knowncitizen/subs-rework (thomasmckay@redhat.com)
- Fix for subscriptions SLA level switcher to fit correctly. (jrist@redhat.com)
- system groups - making api honor system visibility for add/remove systems
  (jsherril@redhat.com)
- system groups - converting ui to only add/remove systems to a group for
  readable systems (jsherril@redhat.com)
- IE Stickyfooter hack. (jrist@redhat.com)
- 818711 - use cache of release versions from CDN (thomasmckay@redhat.com)
- 818711 - pull release versions from CDN (thomasmckay@redhat.com)
- Fixed sorting in ssl-build dir listing (mbacovsk@redhat.com)
- Added list of ssl-build dir to katello-debug output (mbacovsk@redhat.com)
- 818370 - support dots in package name in nvrea (inecas@redhat.com)
- system groups - moving locking in ui from update action to lock action
  (jsherril@redhat.com)
- system groups - adding api permission tests (jsherril@redhat.com)
- system groups - Adds API support for adding system groups to an activation
  key (ehelms@redhat.com)
- 808172 - Added code to show version information for katello cli
  (paji@redhat.com)
- system groups - unit test fix (jsherril@redhat.com)
- system groups - adding perms to api controller (jsherril@redhat.com)
- system groups - adding spec tests for UI permissions (jsherril@redhat.com)
- system group - Adds CLI/API support for adding and removing system groups
  from a system (ehelms@redhat.com)
- system groups - fixing broken create due to perms (jsherril@redhat.com)
- system groups - update Systems->System Groups to use the multiselect widget
  (bbuckingham@redhat.com)
- multiselect - introduce new jquery widget for supporting multiselect
  (bbuckingham@redhat.com)
- 818159 - Error when promoting changeset (pchalupa@redhat.com)
- remove test.rake from rpm package (inecas@redhat.com)
- system groups - implementing UI controller and view permissions
  (jsherril@redhat.com)
- system groups - adding initial permissions (jsherril@redhat.com)
- 807291, 817634 - bit of code clean up (thomasmckay@redhat.com)
- 807291, 817634 - activation key now validates pools when loaded
  (thomasmckay@redhat.com)
- 796972 - changed '+New Something' to single string for translation, and
  clarified the 'total' string (thomasmckay@redhat.com)
- 796972 - made a single string for translators to work with in several cases
  (thomasmckay@redhat.com)
- system groups - updates to Systems->System Groups based on UI mockup
  (bbuckingham@redhat.com)
- autocomplete.js - update to support comma-separated input
  (bbuckingham@redhat.com)
- 817658, 812417 - i686 systems arch displayed as i686 instead of blank
  (thomasmckay@redhat.com)
- system groups - Adds support for adding systems to a system group in the CLI
  (ehelms@redhat.com)
- 809827: katello-reset-dbs should be aware of the deployemnt type
  (bkearney@redhat.com)
- Merge pull request #52 from thomasmckay/772831-ip-address (jsomara@gmail.com)
- fixing some broken unit tests caused by change to find_org in api controllers
  (jsherril@redhat.com)
- system group - Adds support for locking and unlocking a system group in the
  CLI (ehelms@redhat.com)
- system groups - unit test fix (jsherril@redhat.com)
- system-release-version - default landing page is now subscriptions when
  selecting a system (thomasmckay@redhat.com)
- 772831 - proper way to determine IP address is through fact
  network.ipv4_address (thomasmckay@redhat.com)
- Merge branch 'master' into system-release-version (thomasmckay@redhat.com)
- system groups - Adds CLI support for listing systems in a system group.
  (ehelms@redhat.com)
- system groups - Adds ability to view info of single system group from CLI.
  (ehelms@redhat.com)
- system-release-version - cleaning up system subscriptions tab content and ui
  (thomasmckay@redhat.com)
- system groups - adding add/remove systems, lock/unlock and controller tests
  for api (jsherril@redhat.com)
- Merge pull request #45 from tstrachota/sys_by_subscription
  (necasik@gmail.com)
- system groups - add search by system and by group, plus generic index update
  (bbuckingham@redhat.com)
- Automatic commit of package [katello] release [0.2.34-1].
  (lzap+git@redhat.com)
- systems - spec tests for listing systems for a pool_id
  (tstrachota@redhat.com)
- systems - api for listing systems for a pool_id (tstrachota@redhat.com)
- add both auto-subscribe on and off options to choice list with service level
  (thomasmckay@redhat.com)
- system groups - adding query support for group index (jsherril@redhat.com)
- Do not reference logical-insight unless it is configured
  (bkearney@redhat.com)
- system groups - moving routes under organization for api
  (jsherril@redhat.com)
- system groups - adding initial api controller actions (jsherril@redhat.com)
- api - modifying find_organization in api controller to error if org_id not
  provided (jsherril@redhat.com)
- Changes to accomodate more stuff from UXD. (jrist@redhat.com)
- system groups - improving locking notification from UI (jsherril@redhat.com)
- i18n-ifying locked group message (jsherril@redhat.com)
- system groups - making lock control system add/remove (jsherril@redhat.com)
- Automatic commit of package [katello] release [0.2.33-1]. (jomara@redhat.com)
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
- systems - update view confirmation text to support i18n translations
  (bbuckingham@redhat.com)
- systems - update system group bulk action to check availability of group
  before 'add' (bbuckingham@redhat.com)
- making spinner appear when removing system grouops (jsherril@redhat.com)
- system groups - making add/remove buttons uniform with the rest of the app
  (jsherril@redhat.com)
- removing unneeded print (jsherril@redhat.com)
- few system group fixes (jsherril@redhat.com)
- katello - fix broken unit test (pchalupa@redhat.com)
- system groups - adding more controller tests and checking in missing template
  (jsherril@redhat.com)
- Adds logical-insight Gem for development and moves the logical insight code
  to an initializer so that it can be turned on and off via config file.
  (ehelms@redhat.com)
- system groups - fixing issue where description would not update
  (jsherril@redhat.com)
- jenkins build failure for test that crosses katello/headpin boundary
  (thomasmckay@redhat.com)
- initial system group systems page (jsherril@redhat.com)
- cleaning up use of AppConfig.katello? (thomasmckay@redhat.com)
- Merge pull request #23 from iNecas/bz767925 (lzap@seznam.cz)
- Automatic commit of package [katello] release [0.2.32-1].
  (pchalupa@redhat.com)
- Merge branch 'master' into add_default_org_and_environment_of_user_to_cli
  (pchalupa@redhat.com)
- Merge pull request #27 from jsomara/headpin (mmccune@redhat.com)
- systems - disable pkg and group radio buttons when no system is selected
  (bbuckingham@redhat.com)
- systems - update icon for bulk remove action (bbuckingham@redhat.com)
- reverted katello.yml back to katello master version (thomasmckay@redhat.com)
- removed reference to headpin in client.conf and katello.yml
  (thomasmckay@redhat.com)
- incorrect display of release version in system details tab
  (thomasmckay@redhat.com)
- systems - update bulk actions to be completely disabled, unless system
  selected (bbuckingham@redhat.com)
- Merge pull request #24 from pitr-ch/766647-duplicate_env_creation-
  better_error_message_needed (eric.d.helms@gmail.com)
- Merge pull request #20 from ehelms/master (bbuckingham@redhat.com)
- fixed headpin-specific variation of available releases spec test
  (thomasmckay@redhat.com)
- fenced spec tests (thomasmckay@redhat.com)
- systems - add auto-complete to system group bulk action and update icons
  (bbuckingham@redhat.com)
- systems - update icons based on uxd input (bbuckingham@redhat.com)
- Merging headpin flags into master (jomara@redhat.com)
- 766647 - duplicate env creation - better error message needed
  (pchalupa@redhat.com)
- fixing filters.js to conform to the new auto_complete_box api
  (jsherril@redhat.com)
- adding newest changes to autocomplete box (jsherril@redhat.com)
- 767925 - search packages command in CLI/API (inecas@redhat.com)
- navigation - remove duplicate definition for system groups
  (bbuckingham@redhat.com)
- adding systems group systems page and auto complete (jsherril@redhat.com)
- system groups - add to systems navigation (bbuckingham@redhat.com)
- removes forgotten TODOs (pchalupa@redhat.com)
- systems - update notices to support i18n translations
  (bbuckingham@redhat.com)
- system groups - add bulk action to the systems page to add/remove groups
  (bbuckingham@redhat.com)
- system groups - add ability to assign system group to a system
  (bbuckingham@redhat.com)
- white-space formatting (pchalupa@redhat.com)
- katello-cli, katello - setting default environment for user
  (pchalupa@redhat.com)
- 812263 - keep the original tomcat server.xml when resetting dbs
  (inecas@redhat.com)
- Fixes issue on Roles page loading the edit panel where a javascript ordering
  problem caused the role details to not show properly. (ehelms@redhat.com)
- system groups - adding an AR model relationship for system <-> system groups
  (bbuckingham@redhat.com)
- systems - consolidate software/packages/errata under content navigation
  (bbuckingham@redhat.com)
- Merge branch 'system-groups' of github.com:Katello/katello into system-groups
  (bbuckingham@redhat.com)
- system bulk actions - rework the pkg and group actions based on mockups
  (bbuckingham@redhat.com)
- adding system group locked flag and UI controls (jsherril@redhat.com)
- 813427 - do not delete repos from Red Hat Providers (jsherril@redhat.com)
- Fixes issue with CSRF meta tag being out of place and notifications not being
  in the proper script tag resulting from moving all inline javascript to a
  single script tag. (ehelms@redhat.com)
- Merge pull request #14 from lzap/httpd_restart (martin.bacovsky@gmail.com)
- 814063 - warning message for all possible urls (lzap+git@redhat.com)
- 814063 - katello now returns warning when not configured
  (lzap+git@redhat.com)
- 814063 - unable to restart httpd (lzap+git@redhat.com)
- 810232 - system templates - fix issue editing multiple templates
  (bbuckingham@redhat.com)
- Automatic commit of package [katello] release [0.2.31-1].
  (pchalupa@redhat.com)
- Merge pull request #11 from ehelms/master (jsomara@gmail.com)
- Merge pull request #10 from jlsherrill/bz810378 (eric.d.helms@gmail.com)
- 810378 - adding search for repos on promotion page (jsherril@redhat.com)
- Changes the way inline javascript declarations are handled such that they are
  all injected into one universal script tag. (ehelms@redhat.com)
- system groups - adding activation key controller specs
  (bbuckingham@redhat.com)
- 741595 - uebercert POST/GET/DELETE - either support or delete the calls from
  CLI (pchalupa@redhat.com)
- system groups - enable associating groups to an activation key
  (bbuckingham@redhat.com)
- adding new files needed for system group UI (jsherril@redhat.com)
- adding system group controller tests (jsherril@redhat.com)
- Merge pull request #7 from lzap/bootstrap_issues (jlsherrill@gmail.com)
- boot - default conf was never loaded (lzap+git@redhat.com)
- adding tupane CRUD for system groups (jsherril@redhat.com)
- fixing issue with group creation (jsherril@redhat.com)
- added a script to restore a katello backup that was made with the matching
  backup script (jweiss@redhat.com)
- 803428 - repos - do not pass candlepin a gpgurl, if no gpgkey is defined
  (bbuckingham@redhat.com)
- 812346 - fixing org deletion envrionment error (jsherril@redhat.com)
- adding glue layer for system groups (jsherril@redhat.com)
- system bulk actions - UI/controller... changes to support additional actions
  (bbuckingham@redhat.com)
- system bulk actions - add new routes and initial controller actions
  (bbuckingham@redhat.com)
- adding pulp orchestration for system groups (jsherril@redhat.com)
- adding base system group model for active record (jsherril@redhat.com)
- added basic backup script to handle backup part of
  https://fedorahosted.org/katello/wiki/GuideServerBackups (jweiss@redhat.com)
- Automatic commit of package [katello] release [0.2.30-1]. (inecas@redhat.com)
- cp-releasever - release as a scalar value in API system json
  (inecas@redhat.com)
- removing bail out check for env-selector (jsherril@redhat.com)
- Automatic commit of package [katello] release [0.2.29-1].
  (pchalupa@redhat.com)
- 713153 - RFE: include IP information in consumers/systems related API calls.
  (pchalupa@redhat.com)
- 803412 - auto-subscribe w/ SLA now on system subscription page
  (thomasmckay@redhat.com)
- reorganizing assets to reduce the number of javascript files downloaded
  (jsherril@redhat.com)
- removing unneeded print statement (jsherril@redhat.com)
- allowing search param for all, needed for all creates (jsherril@redhat.com)
- system packages - fix checbox events after loading more pkgs
  (bbuckingham@redhat.com)
- system packages - add support for tabindex (bbuckingham@redhat.com)
- UI Remodel - Adds updates to widget styling. (ehelms@redhat.com)
- UI Remodel - Cleans up footer and adds styling to conform versioning into
  footer. (ehelms@redhat.com)
- UI Remodel - Updates the footer section and maincontent to new look.
  (ehelms@redhat.com)
- 810375 - remove page size limit on repos displayed (thomasmckay@redhat.com)
- 803410 - Y-stream release version is now available on System Details page +
  If no specific release version is specified (value of "") then "System
  Default" is displayed. + For Katello, release version choices come from
  enabled repos in the system's environment. For Headpin, choices are all
  available in the Library environment. (thomasmckay@redhat.com)
- UI Remodel - Update to converge-ui. (ehelms@redhat.com)
- UI Remodel - Updates to header layout and new logo. (ehelms@redhat.com)
- Automatic commit of package [katello] release [0.2.28-1].
  (tstrachota@redhat.com)
- 809826 - regression in finding filters in the filters controller
  (tstrachota@redhat.com)
- Automatic commit of package [katello] release [0.2.27-1].
  (lzap+git@redhat.com)
- slas - fix in controller spec test (tstrachota@redhat.com)
- Automatic commit of package [katello] release [0.2.26-1].
  (tstrachota@redhat.com)
- slas - field for SLA in hash export of consumer renamed We used service_level
  but subscription-manager requires serviceLevel and checks for it's presence.
  (tstrachota@redhat.com)
- 808596 - Initial fix didn't take into consideration production mode.
  (jrist@redhat.com)
- 804685 - system packages - reformat content and add tipsy help on tables for
  user (bbuckingham@redhat.com)
- Automatic commit of package [katello] release [0.2.25-1].
  (pchalupa@redhat.com)
- 798649 - RFE - Better listing of products and repos (pchalupa@redhat.com)
- check script - initial version (lzap+git@redhat.com)
- 805412 - fixing org creation error with invalid chars (jsherril@redhat.com)
- 802454 - a few fixes to support post sync url with scheduled syncs
  (jsherril@redhat.com)
- 805709 - spec test fix (jsherril@redhat.com)
- 805709 - making filter name unique within an org and editable
  (jsherril@redhat.com)
- 808576 - Regression for IE only stylesheet. Added back in. (jrist@redhat.com)
- Automatic commit of package [katello] release [0.2.24-1].
  (lzap+git@redhat.com)
- 750410 - katello-jobs init script links removal (lzap+git@redhat.com)
- Automatic commit of package [katello] release [0.2.23-1].
  (tstrachota@redhat.com)
- slas - fixed typo - missing parenthesis (tstrachota@redhat.com)
- slas - updated spec tests (tstrachota@redhat.com)
- slas - api/model for getting and setting service level
  (tstrachota@redhat.com)
- 803688 - need to add the new location for common glue code
  (mmccune@redhat.com)
- 802925 - fixing escaped html in activation key tooltip (jsherril@redhat.com)
- UI Remodel - Updates converge-ui and adjusts some placement of tupane
  entities with new look. (ehelms@redhat.com)
- UI Remodel - Switched symlinks to converge-ui instead of lib to adopt a
  pattern of namespacing that will be consistent across implementations.
  (ehelms@redhat.com)
- UI Remodel - Adds updated version of converge-ui.  Switches default submodule
  config to read-only repository. (ehelms@redhat.com)
- 733474 - bad request response when repo url format is wrong
  (inecas@redhat.com)
- white space (inecas@redhat.com)
- 803688 - class Queue overrides class Queue from Ruby Std-lib (git@pitr.ch)
- adding converge-ui to build process (ehelms@redhat.com)
- 806478 - Adding an attribute to the params matching to enable/disable
  helptips (paji@redhat.com)
- Automatic commit of package [katello] release [0.2.22-1].
  (pchalupa@redhat.com)
- api 410 http code - api returns 410 instead of 404 (pchalupa@redhat.com)
- Automatic commit of package [katello] release [0.2.21-1].
  (mmccune@redhat.com)
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
- UI Remodel - Moves jquery ui out of assets and updates configuration.
  (ehelms@redhat.com)
- 806942 - changing all models away from keyword analyzer (jsherril@redhat.com)
- Automatic commit of package [katello] release [0.2.20-1]. (inecas@redhat.com)
- cp-releasever - support setting releaseVer for the system (inecas@redhat.com)
- UI Remodel - Typo fix for layout name. (ehelms@redhat.com)
- UI Remodel - Large UI change to use new shell and header from the converge-ui
  layouts.  Changes to scss to include new scss and modify existing to
  accomodate new shell.  Some re-organization of assets. (ehelms@redhat.com)
- Automatic commit of package [katello] release [0.2.19-1].
  (tstrachota@redhat.com)
- slas - api for listing service level agreements per org
  (tstrachota@redhat.com)
- 787696 - updated translations zanata ticket #144039 (thomasmckay@redhat.com)
- 806741 - added missing environment_id to api/activation_keys_controller
  param_rules (thomasmckay@redhat.com)
- 806482 - BR for java so we can actually run jammit compression
  (mmccune@redhat.com)
- 804127 - adding configurable log property (jsherril@redhat.com)
- 805324 - making lucene style search syntax work on packages/errata panes in
  promotions (jsherril@redhat.com)
- 805627 - fixing password mismatch text from not appearing on new user page
  (jsherril@redhat.com)
- 806078 - Changeset History - update name in left pane when cs name is changed
  (bbuckingham@redhat.com)
- 806083 - Users - add Remove User to Environments tab (bbuckingham@redhat.com)
- 806076 - Promotion - update templates to list repos, pkg groups and distro
  (bbuckingham@redhat.com)
- 805956 - CLI/API for refreshing repositories from CDN (inecas@redhat.com)
- 802454 - adding support for pulp post-sync request (jsherril@redhat.com)
- Automatic commit of package [katello] release [0.2.18-1].
  (mmccune@redhat.com)
- Automatic commit of package [katello] release [0.2.17-1].
  (mmccune@redhat.com)
- Revert "removing BuildRequires we don't need anymore" (mmccune@redhat.com)
- 803357 - errata with packages affected by filters are not promoted
  (tstrachota@redhat.com)
- Automatic commit of package [katello] release [0.2.16-1].
  (mmccune@redhat.com)
- removing BuildRequires we don't need anymore (mmccune@redhat.com)
- 798264 - Katello debug collects certificate password files and some certs
  (mbacovsk@redhat.com)
- 798264 - Katello debug collects certificate password files and some certs
  (mbacovsk@redhat.com)
- UI Remodel - Removes all jquery plugins and updates paths to point at library
  of plugins in central asset repo. (ehelms@redhat.com)
- 795780, 805122 - Improvement to the way the most recent sync status is
  determined to prevent error and show proper completion. (ehelms@redhat.com)
- 798264 - Katello debug collects certificate password files and some certs
  (mbacovsk@redhat.com)
- 798264 - Katello debug collects certificate password files and some certs
  (mbacovsk@redhat.com)
- Automatic commit of package [katello] release [0.2.15-1].
  (tstrachota@redhat.com)
- 790455 - api for updating changeset name and description
  (tstrachota@redhat.com)
- 800573 - Comprehensive bug fix to deal with mass-assign vulnerability
  (paji@redhat.com)
- Updated the script for better formatting (paji@redhat.com)
- 803740 - adding our assigned uid/groupid for katello (jsherril@redhat.com)
- 799357 - provide descriptive information on CDN access denied
  (inecas@redhat.com)
- 803409 - providers - on provider create, open products & repos tab
  (bbuckingham@redhat.com)
- 803420 - 2pane - incorrect pane opens on object create
  (bbuckingham@redhat.com)
- UI Remodel - Adds first symlink to javascript libraries coming from UI
  library. (ehelms@redhat.com)
- UI Remodel - Adding initial commit of a git submodule that contains common UI
  elements. (ehelms@redhat.com)
- Automatic commit of package [katello] release [0.2.14-1]. (inecas@redhat.com)
- 803441 - handle space in organization when importing manifest
  (inecas@redhat.com)
- Bug 801580 - Updating sync plan does not update associated product's (repo's)
  sync schedule (pchalupa@redhat.com)
- 799357 - manifest import - fix for nil error message (bbuckingham@redhat.com)
- 801797 - Fixes regression with environment selector and tupane pages not
  filtering on environment. (ehelms@redhat.com)
- 800169 - Users - do not allow setting of def org, if the org has no envs
  (bbuckingham@redhat.com)
- 799122 - showing warning if trying to promote repo with failed sync or
  currently syncing (jsherril@redhat.com)
- 802897 - setting default index type for all facts to string
  (jsherril@redhat.com)
- 801148 - providers - fix tabindex for products and repos
  (bbuckingham@redhat.com)
- Automatic commit of package [katello] release [0.2.13-1]. (inecas@redhat.com)
- 798683 - handle errors comming from repo synchronization (inecas@redhat.com)
- 798376 - fix finding the recent task status for sync in UI
  (inecas@redhat.com)
- 799052 - Promoting template with assigned repo should fail if product is not
  already in the target environment (mbacovsk@redhat.com)
- 799052 - Promoting template with assigned repo should fail if product is not
  already in the target environment (mbacovsk@redhat.com)
- 801547 - GPG Key: Adds validation that gpg key does not contain binary data.
  (ehelms@redhat.com)
- 801516 - Fixes issue with details tupane sizing on medium sized tupane lists.
  (ehelms@redhat.com)
- 801070 - Better error message for deleting ends from middle of the path
  (pchalupa@redhat.com)
- Automatic commit of package [katello] release [0.2.12-1].
  (tstrachota@redhat.com)
- 799351 - system reports does not show first 2 columns (in pdf format)
  (tstrachota@redhat.com)
- Automatic commit of package [katello] release [0.2.11-1]. (inecas@redhat.com)
- 798376 - handle change in value returned by repo.sync method
  (inecas@redhat.com)
- 799538 - Fix for filters "click" event, as well as icon placement.
  (jrist@redhat.com)
- marking unreachable method for removal (pchalupa@redhat.com)
- Automatic commit of package [katello] release [0.2.10-1].
  (lzap+git@redhat.com)
- 798772 - fix conversion to local timezone (inecas@redhat.com)
- 798376 - fix problem with discovery process (inecas@redhat.com)
- 790063 - search - few more mods for consistency (bbuckingham@redhat.com)
- Automatic commit of package [katello] release [0.2.9-1]. (mmccune@redhat.com)
- 798376 - Sync management page reworked to generate error and success notices
  once upon sync completion. (ehelms@redhat.com)
- 801445 - fixing issue with errata filters not returning any errata
  (jsherril@redhat.com)
- 801107 - don't crush if mapping file does not exist (inecas@redhat.com)
- 740365 - fixing issue where 2pane extended scroll was prepending instead of
  appending (jsherril@redhat.com)
- 798772 - fixing issue where sync plans were being set in UTC
  (jsherril@redhat.com)
- 801107 - allow wildcards in image factory names mappings (inecas@redhat.com)
- 799523 - Fix for new environment full page load. (jrist@redhat.com)
- 790063 - search - changes for consistency/behavior (bbuckingham@redhat.com)
- 783576 - performing validation on system template prior to export
  (jsherril@redhat.com)
- 801448 - Missing resource (font) in UI (pchalupa@redhat.com)
- cli, kattelo - whitespace formatting (pchalupa@redhat.com)
- 794799 - fix deleting organization (inecas@redhat.com)
- 752547: Add -notar option to improve integratoin with sos tooling
  (pep@redhat.com)
- 794883 - wait for repositories to be synced when promoting template
  (inecas@redhat.com)
- 799036 - Promoting template with repo that is not already in target
  environment fails (mbacovsk@redhat.com)
- Automatic commit of package [katello] release [0.2.8-1].
  (tstrachota@redhat.com)
- 799149 - disabling add/remove of products from a system template in api
  (jsherril@redhat.com)
- Automatic commit of package [katello] release [0.2.7-1]. (mmccune@redhat.com)
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
- Automatic commit of package [katello] release [0.2.6-1].
  (mbacovsk@redhat.com)
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
- 798264 - Katello debug collects certificate password files and some certs
  (mbacovsk@redhat.com)
- 798264 - Katello debug collects certificate password files and some cert
  (mbacovsk@redhat.com)
- 798264 - Katello debug collects certificate password files and some certs
  (mbacovsk@redhat.com)
- 798264 - Katello debug collects certificate password files and some certs
  (mbacovsk@redhat.com)
- Automatic commit of package [katello] release [0.2.5-1].
  (lzap+git@redhat.com)
- 740931 - Long name issue with GPG key names (paji@redhat.com)
- 740931 - fixed a long name/desc role ui bug (paji@redhat.com)
- 796239 - removing system template product association from UI
  (jsherril@redhat.com)
- Fixed some unit test issues (paji@redhat.com)
- Adding some basic LDAP support to katello. If you login with a valid LDAP
  username and password (after turning on ldap) it will create a dummy user for
  you that you can assign roles to. It also now supports start_tls and
  simple_tls encryption in the ldap config. TODO: add support for roles
  bootstrapping based on LDAP roles (jomara@redhat.com)
- 767574 - Promotion page - code to indicate warnings if products/repos have
  filters applied on them (paji@redhat.com)
- 798324 - UI permission creation widget will now handle verbs that have no
  tags properly. (ehelms@redhat.com)
- 787979 - auto-heal checkbox only enabled if system editable
  (thomasmckay@redhat.com)
- 788329 - fixing env selector not initializing properly on new user page
  (jsherril@redhat.com)
- 787696 - removed incorrectly calling _() in javascript
  (thomasmckay@redhat.com)
- 798007 - adding logging information for statuses (lzap+git@redhat.com)
- 798737 - Promotion of only distribution fails (lzap+git@redhat.com)
- Gemfile - temporarily removing the tire and hashr gem updates
  (bbuckingham@redhat.com)
- 795825 - Sync Mgmt - fix display when state is 'waiting'
  (bbuckingham@redhat.com)
- 796360 - fixing issue where system install errata button was clickable even
  if no errata exist (jsherril@redhat.com)
- 783577 - removing template with unsaved changes should not prompt for saving
  (jsherril@redhat.com)
- 798327 - fixing stray space in debug certificate download
  (jsherril@redhat.com)
- 796740 - Fixes unhelpful message when attempting to create a new system with
  no environments in the current organization. (ehelms@redhat.com)
- 754873 - fixing issue where product sync bar would continually go to 100
  (jsherril@redhat.com)
- 798299 - fix reporting errors from Pulp (inecas@redhat.com)
- Automatic commit of package [katello] release [0.2.4-1].
  (bbuckingham@redhat.com)
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
- Automatic commit of package [katello] release [0.2.3-1].
  (lzap+git@redhat.com)
- 751843 - adding counts go promotion search pages (jsherril@redhat.com)
- Automatic commit of package [katello] release [0.2.2-1]. (mmccune@redhat.com)
- 790520 - Fixes styling around product icons and product names in promotions
  and system templates. (ehelms@redhat.com)
- 796853 - Resolves issue of having two different rails.js files in code base.
  (ehelms@redhat.com)
- 786109 - Fixes issue where sync status dashboard widget caused an error when
  more than one product had a sync plan attached to it. (ehelms@redhat.com)
- 790489 - Changes to allow read only user to have a read only view of the sync
  management pages. (ehelms@redhat.com)
- 795908 - Changes title of repository edit view to 'Repository Details' to
  address lack of editable content within view. (ehelms@redhat.com)
- 771999 - Added UI bits to associate repositories to package filters
  (paji@redhat.com)
- 796021 - On sytems subscriptions page, prevents user clicking subscribe or
  unsubscribe multiple times before the action completes. (ehelms@redhat.com)
- 794892 - Fix for new key width and highlighting. (jrist@redhat.com)
- 790143 - Systems will now show the architecture by name instead of by label.
  (e.g. Itanium instead of ia64) (ehelms@redhat.com)
- Automatic commit of package [katello] release [0.2.1-1]. (mmccune@redhat.com)
- 796268 - proper error message when erratum was not found
  (tstrachota@redhat.com)
- 770414 - Fix for remove role button moving to next line when clicked.
  (jrist@redhat.com)
- 795862 - delete assignment to activation keys on product deletion
  (inecas@redhat.com)
- 770693 - handle no reference in errata (inecas@redhat.com)
- Automatic commit of package [katello] release [0.1.243-1].
  (inecas@redhat.com)
- 760124 - When editing or creating a gpg key, the UI now consitently orders
  the upload and paste options. (ehelms@redhat.com)
- 787226 - removed 'editable' form env name form field (thomasmckay@redhat.com)
- 795447 - ignore 'save' clicks if button is disabled; also don't allow save w/
  blank password (thomasmckay@redhat.com)
- 788992 - calls to subsystems include locale in the request headers
  (tstrachota@redhat.com)
- 790408 - changing order of loaded gems - Tire vs. JSON (inecas@redhat.com)
- 740923 - When creating or editing a permission, hitting enter with the name
  field focused will now cause the permission to save. (ehelms@redhat.com)
- 795758 - new logging class also for delayed jobs (lzap+git@redhat.com)
- 787226 - disable updating environment name (inecas@redhat.com)
- 787233 - text-shadow is deprecated in favor of single-text-shadow
  (jomara@redhat.com)
- 795452 - fix regression - handling environment comming from CP
  (inecas@redhat.com)
- 795404 - Katello does not respect KATELLO_LOGGING setting
  (lzap+git@redhat.com)
- cdn-optimize - optimized access to CDN (inecas@redhat.com)
- 795349 - delete product in CP unless other org still uses it
  (inecas@redhat.com)
- 791221 - run only one update per product deletion (inecas@redhat.com)
- Automatic commit of package [katello] release [0.1.242-1].
  (tstrachota@redhat.com)
- 791194 - Spaces in env names replaced by underscores in repo path creation
  (tstrachota@redhat.com)
- 791221 - wait for CP update jobs before proceeding when deleting ORG
  (inecas@redhat.com)
- 750558,748472,752967 - Adjusts breadcrumbs in sliding trees to ellipsis long
  names appropriately. (ehelms@redhat.com)
- 758831 - Adjusts the z-index on tupane details and sliding tree slide ups in
  order to prevent clipping of tupane on top of slide up containers.
  (ehelms@redhat.com)
- 748467 - Adjusts the height of tupane's to use more screen real estate on
  larger browser window sizes. (ehelms@redhat.com)
- Automatic commit of package [katello] release [0.1.241-1].
  (tstrachota@redhat.com)
- 788073 - do not schedule tasks in past (tstrachota@redhat.com)
- 770693 - bind consumer to repo in environment (inecas@redhat.com)
- updated todo comments (tstrachota@redhat.com)
- resolved todo - removed method Repo#uri This attribute is now provided
  directly by Pulp. (tstrachota@redhat.com)
- 784649 - Fix for empty changeset message when System Templates are added.
  (jrist@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (shughes@redhat.com)
- 790966 - updated date format (mmccune@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (shughes@redhat.com)
- 790966-Added a logger for the prod env to print timestamp information on
  errors and warnings. (paji@redhat.com)
- 791268 - SAM does not contain valid version (lzap+git@redhat.com)
- Automatic commit of package [katello] release [0.1.240-1].
  (tstrachota@redhat.com)
- 788073 - fixes in spec tests after changes (tstrachota@redhat.com)
- 788073 - fix for rescheduling repo synces after sync plan update
  (tstrachota@redhat.com)
- 788073 - fix for updating sync plans in pulp (tstrachota@redhat.com)
- 788073 - fix for planning non-recurring scheduled synces at correct time
  (tstrachota@redhat.com)
- Automatic commit of package [katello] release [0.1.239-1].
  (inecas@redhat.com)
- unit-tests - fix another memory leak (inecas@redhat.com)
- 789456 - fix problem with unicode (inecas@redhat.com)
- 789456 - candlepin environment orchestration (inecas@redhat.com)
- 789456 - pre-save and post-save queues in orchestration (inecas@redhat.com)
- removing uneeded logging entry (mmccune@redhat.com)
- 786376 add waiting state to non running pulp list (shughes@redhat.com)
- Automatic commit of package [katello] release [0.1.238-1].
  (mmccune@redhat.com)
- 788599 - system templates - fix to handle mix of repos with and without
  distros (bbuckingham@redhat.com)
- dashboard - remove notice that was accidentally committed
  (bbuckingham@redhat.com)
- 765806 - Adding the Brisbane slash  - thanks Lana (paji@redhat.com)
- 765806 - Adding the oxford comma  - thanks cliff (paji@redhat.com)
- 765806 - updated the failed login message based on patch provided by Og
  (paji@redhat.com)
- 787796 - Improvements to rh providers + repo enablement pages
  (paji@redhat.com)
- 786520 - clear out duration column when active sync is running
  (shughes@redhat.com)
- 790502 - Fixes inability to add system templates to changeset as a result of
  changes related to adding top level errata to a changeset.
  (ehelms@redhat.com)
- Automatic commit of package [katello] release [0.1.237-1].
  (mmccune@redhat.com)
- Revert "786762: fix sync complete update after successful sync cancel"
  (shughes@redhat.com)
- 790487 - Fix for width of promotion changset new button. (jrist@redhat.com)
- 789155 - system templates - update repo search query to support dash and
  space (bbuckingham@redhat.com)
- 790355 - Count on the fact that repo in errata might be deleted
  (inecas@redhat.com)
- 790342 - Error in async task is not returned (lzap+git@redhat.com)
- 755001 - Fix for + in changeset name. (jrist@redhat.com)
- 786762: fix sync complete update after successful sync cancel
  (shughes@redhat.com)
- fix misspelled state (shughes@redhat.com)
- 788213 - Removes the Changelog and Filelist tabs from the packages tupane
  details. (ehelms@redhat.com)
- 782518 - search history - parse out host using URI class vs using HTTP_HOST
  (bbuckingham@redhat.com)
- 788657 - to not display product content details in the System/Subscriptions
  tab of UI (thomasmckay@redhat.com)
- 767083 - Fixes javascript error when attempting to add a repository directly
  to a package filter. (ehelms@redhat.com)
- 786179 - notices - delete all displaying notices after completed
  (bbuckingham@redhat.com)
- 754914 - When selecting a repository in package filters the name of the
  repository will properly show up beside the Remove link. (ehelms@redhat.com)
- system packages - remove hard-coded offset (bbuckingham@redhat.com)
- Automatic commit of package [katello] release [0.1.236-1].
  (tstrachota@redhat.com)
- fix for parsing nvrea of packages with dash in name (tstrachota@redhat.com)
- Automatic commit of package [katello] release [0.1.235-1].
  (tstrachota@redhat.com)
- 740254 - fixed dependency calculation Previous version was looping forever on
  circular dependencies. (tstrachota@redhat.com)
- fix for package search not returning correct packages Pulp's package api
  expects regular expressions when filtering by name. (tstrachota@redhat.com)
- Automatic commit of package [katello] release [0.1.234-1].
  (mmccune@redhat.com)
- 789516 - Promotions - fix ability to add products and distros to a changeset
  (bbuckingham@redhat.com)
- 741499-Added code to deal with weird user current org behaviour
  (paji@redhat.com)
- Automatic commit of package [katello] release [0.1.233-1].
  (jomara@redhat.com)
- Fixing content prefix for headpin mode in glue-candlepin (jomara@redhat.com)
- Merge branch 'promotions-errata' (ehelms@redhat.com)
- Merge branch 'master' into promotions-errata (ehelms@redhat.com)
- 786138 - system templates - search for only enabled repos on repo search
  query (bbuckingham@redhat.com)
- Automatic commit of package [katello] release [0.1.232-1].
  (lzap+git@redhat.com)
- Promotion Errata: Adds functionality to reset content tree to root breadcrumb
  when a promotion is triggered. (ehelms@redhat.com)
- 789144 - promotions - redindex pkgs and errata after promotion of product or
  repo (bbuckingham@redhat.com)
- Automatic commit of package [katello] release [0.1.231-1].
  (tstrachota@redhat.com)
- 771666, 785139 - fixed formatting of subsystem error messages for katello cli
  (tstrachota@redhat.com)
- repos - fix for package counts not being displayed in repo list cli
  (tstrachota@redhat.com)
- Automatic commit of package [katello] release [0.1.230-1].
  (inecas@redhat.com)
- rest_debug - fix issue with file upload (inecas@redhat.com)
- 788932 - temporary fix to avoid race condition in CP (inecas@redhat.com)
- Looks like my previous commit broke quite a few tests.. Temporarily reverting
  (paji@redhat.com)
- 741499-Added code to deal with weird user current org behaviour
  (paji@redhat.com)
- Promotion Errata: Adds top level adding of errata to a changeset.  Adds
  detection of errata in changeset products to all removal from individual
  products or removal from changeset all together. (ehelms@redhat.com)
- Adds underscorejs as a set of utility methods for use in javascript.
  (ehelms@redhat.com)
- Automatic commit of package [katello] release [0.1.229-1].
  (mmccune@redhat.com)
- 755028 - promotions - fix issue where spinner not found
  (bbuckingham@redhat.com)
- 787302 - promotion - fix error promotion of repo (bbuckingham@redhat.com)
- Promotion Errata: Adds indexing, search and display of errata in promotions.
  (ehelms@redhat.com)
- special numbers/symbols (shughes@redhat.com)
- ta special numbers/symbols (shughes@redhat.com)
- pa special numbers/symbols (shughes@redhat.com)
- or special numbers/symbols (shughes@redhat.com)
- mr special symbols/numbers (shughes@redhat.com)
- gu special numbers/symbols (shughes@redhat.com)
- unit tests - fix problem with accidental freezing (inecas@redhat.com)
- NOBZ - removing uneeded logging line (mmccune@redhat.com)
- 771957 - Added code to raise an exception on create if another org with the
  same name already existed and was  scheduled to be deleted (paji@redhat.com)
- Merge remote-tracking branch 'origin/master' (jomara@redhat.com)
- 788599 - system template - fix distribution download (bbuckingham@redhat.com)
- Automatic commit of package [katello] release [0.1.228-1].
  (jomara@redhat.com)
- Updating the spec to split out common/katello to facilitate headpin
  (jomara@redhat.com)
- comment - better todo comment for unwrapping (lzap+git@redhat.com)
- comment - removing unnecessary todo (lzap+git@redhat.com)
- Automatic commit of package [katello] release [0.1.227-1].
  (tstrachota@redhat.com)
- 786438 - better error message when package not found (tstrachota@redhat.com)
- binding - better error reporting and specs (lzap+git@redhat.com)
- todo - better comment for authorization code (lzap+git@redhat.com)
- Automatic commit of package [katello] release [0.1.226-1].
  (mmccune@redhat.com)
- activation keys - remove 'allocated' from model and code
  (bbuckingham@redhat.com)
- Added format_time as a helper method so even partials from views can use it
  (paji@redhat.com)
- 788149 - activation keys - fix format_time error (bbuckingham@redhat.com)
- Promotions Errata: Re-works permission check in the event an errata belongs
  to multiple products. (ehelms@redhat.com)
- API - nice rendering of 404 error (inecas@redhat.com)
- 788078 - distro arch - fixing unit test (lzap+git@redhat.com)
- 788078 - distro arch is not ignored anymore (lzap+git@redhat.com)
- infra - improving list_permissions rake task (lzap+git@redhat.com)
- Automatic commit of package [katello] release [0.1.225-1].
  (inecas@redhat.com)
- 768254 - scope products API by organization (inecas@redhat.com)
- Automatic commit of package [katello] release [0.1.224-1].
  (lzap+git@redhat.com)
- binding - better error reporting fix (lzap+git@redhat.com)
- Automatic commit of package [katello] release [0.1.223-1].
  (lzap+git@redhat.com)
- binding - better error reporting (lzap+git@redhat.com)
- infra - improving rake routes script (lzap+git@redhat.com)
- 740964 - Added validation to make sure that there is atleast 1 user in the
  Administrator/superadmin role (paji@redhat.com)
- system template - update repos to use elastic search query
  (bbuckingham@redhat.com)
- 769425 - set minimum width of selector box (thomasmckay@redhat.com)
- Automatic commit of package [katello] release [0.1.222-1].
  (mmccune@redhat.com)
- binding - removing unnecessary param checks (lzap+git@redhat.com)
- binding - disabling unit tests for today (lzap+git@redhat.com)
- 787745 - system template - fix download containing distros
  (bbuckingham@redhat.com)
- Automatic commit of package [katello] release [0.1.221-1].
  (lzap+git@redhat.com)
- binding - implementing the glue logic (lzap+git@redhat.com)
- spec - removing some warning messages (lzap+git@redhat.com)
- binding - adding cp_label to repository model class (lzap+git@redhat.com)
- 785799 - show error message suggesting use of force upload not shown when
  force upload is already set (thomasmckay@redhat.com)
- 786598 - system templates - improve support for repos having same name
  (bbuckingham@redhat.com)
- Adds escaping of ID due to colon in errata ID and adds search cleanup within
  sliding tree. (ehelms@redhat.com)
- Automatic commit of package [katello] release [0.1.220-1].
  (inecas@redhat.com)
- filters - fixed filter delete route to pulp (tstrachota@redhat.com)
- org-deletion - CLI wait for org to be deleted (inecas@redhat.com)
- 771957 - let repositories deal with content deletion (inecas@redhat.com)
- delayed-job-logging - better handling of logging in development
  (inecas@redhat.com)
- Added notifications on success of org delete and promoted (paji@redhat.com)
- 766968- Made the dashboard page acl on tabs based on user perms
  (paji@redhat.com)
- Automatic commit of package [katello] release [0.1.219-1].
  (tstrachota@redhat.com)
- changeset - fixes in controller spec tests (tstrachota@redhat.com)
- Automatic commit of package [katello] release [0.1.218-1].
  (inecas@redhat.com)
- Fix problem with admin user password in production mode (inecas@redhat.com)
- Automatic commit of package [katello] release [0.1.217-1].
  (tstrachota@redhat.com)
- changeset - packages can be optionaly addded by name (tstrachota@redhat.com)
- changeset - fix for spec tests (tstrachota@redhat.com)
- changeset - packages specified by nvre in api (tstrachota@redhat.com)
- changeset - methods for removing errata and distros simplified
  (tstrachota@redhat.com)
- changeset - new method promotable_repositories for changeset content items
  (tstrachota@redhat.com)
- katello-debug - adding SELinux log to the report (lzap+git@redhat.com)
- katello-debug - reindenting only (lzap+git@redhat.com)
- katello-debug - removing Ruby warning about whitespace (lzap+git@redhat.com)
- Automatic commit of package [katello] release [0.1.216-1].
  (tstrachota@redhat.com)
- removed candlepin version check from thin start script
  (tstrachota@redhat.com)
- Automatic commit of package [katello] release [0.1.215-1].
  (lzap+git@redhat.com)
- logging - setting default production level to 'warn' (lzap+git@redhat.com)
- 771886 - system packages - fix ui staying in processing state on pkg install
  (bbuckingham@redhat.com)
- Automatic commit of package [katello] release [0.1.214-1].
  (mmccune@redhat.com)
- 771957-Made org delete raise a UI notice on delete failure (paji@redhat.com)
- Changed the notice on  promote_contents. (paji@redhat.com)
- 740007-i18ned the dates on the UI pages (paji@redhat.com)
- Increases the wait time between checking async pulp tasks to 10 seconds.
  (ehelms@redhat.com)
- 783509 - Forgot to append the word "environment". (jrist@redhat.com)
- Automatic commit of package [katello] release [0.1.213-1].
  (lzap+git@redhat.com)
- spec - moving newrelic gem out of test env (faster) (lzap+git@redhat.com)
- spec - making unit tests faster (lzap+git@redhat.com)
- spec - optimizing unit tests (lzap+git@redhat.com)
- binding - fetch existing bound repos from pulp (lzap+git@redhat.com)
- repos - removing unused repo_id class method (lzap+git@redhat.com)
- 783465 - Fixes issue with failed or changesets with repositories added
  directly causing an undefined method error. (ehelms@redhat.com)
- Fixes issue with adding errata individually not updating Add or Remove
  buttons. (ehelms@redhat.com)
- 786110 - system template - fix failure on removal if repo added
  (bbuckingham@redhat.com)
- Allows sliding tree header to expand vertically without scrollbar as the size
  of crumbs text increases. Fixes broken load spinner. (ehelms@redhat.com)
- Removes extra slash from spinner url. (ehelms@redhat.com)
- Automatic commit of package [katello] release [0.1.212-1].
  (tstrachota@redhat.com)
- filters - cli option to list inherited filters for repos
  (tstrachota@redhat.com)
- 786586 - system template - do not include duplicate repos in tdl export
  (bbuckingham@redhat.com)
- Automatic commit of package [katello] release [0.1.211-1].
  (mmccune@redhat.com)
- 0000000 - we don't use this gem anymore (mmccune@redhat.com)
- 786222 - system templates - allow selecting of distro based on repos
  (bbuckingham@redhat.com)
- 786574 - 'autoheal' value now returned properly for GET
  /katello/api/consumer/ (thomasmckay@redhat.com)
- 786200 - Removed Machine Type column from Red Hat Provider table. Left it in
  the Organizations / Subscriptions since it shows the bonus pools created as
  Virtual (thomasmckay@redhat.com)
- 754526 - RBAC rules were preventing unset of default env
  (thomasmckay@redhat.com)
- 758441: add expand/collapse support to sync product repos
  (shughes@redhat.com)
- Automatic commit of package [katello] release [0.1.210-1].
  (lzap+git@redhat.com)
- binding - consumer must exist (lzap+git@redhat.com)
- binding - implementing security rule (lzap+git@redhat.com)
- errors - better error handling of 404 for CLI (lzap+git@redhat.com)
- binding - adding enabled_repos controller action (lzap+git@redhat.com)
- Promotions Errata - Moves errata in promotions to be loaded via
  elasticsearch. (ehelms@redhat.com)
- Automatic commit of package [katello] release [0.1.209-1].
  (tstrachota@redhat.com)
- 744047 - fixes in spec tests (tstrachota@redhat.com)
- 744047 - generating metadata after promotion (tstrachota@redhat.com)
- Automatic commit of package [katello] release [0.1.208-1].
  (lzap+git@redhat.com)
- 753318: add headers to sync schedule lists (shughes@redhat.com)
- 786160 - password reset - resolve error when saving task status
  (bbuckingham@redhat.com)
- Automatic commit of package [katello] release [0.1.207-1].
  (lzap+git@redhat.com)
- Merge branch 'promotion-search' (ehelms@redhat.com)
- Merge branch 'master' into promotion-search (ehelms@redhat.com)
- 757817-Added code to show Activation Keys page if user has AK read privileges
  (paji@redhat.com)
- Promotion Search: Fixes for broken unit tests related to adding
  index_packages during promotion. (ehelms@redhat.com)
- 782959,747827,782239 - i18n issues creating pulp users & repos were fixed
  (paji@redhat.com)
- activation keys - fix missing navigation for Available Subscriptions
  (bbuckingham@redhat.com)
- Promotion Search - Fixes issue with tupane slider showing up partially inside
  the left side tree. (ehelms@redhat.com)
- providers - fix broken arrow for products and repos (bbuckingham@redhat.com)
- update to translation strings (shughes@redhat.com)
- Added "Environment" to Initial environment page on new Org.
  (jrist@redhat.com)
- 748060 - fix bbq on promotions page (bbuckingham@redhat.com)
- Promotion Search - Changes to init search widget state on load properly.
  (ehelms@redhat.com)
- Promotion Search - Re-factors search enabling on sliding tree to be more
  stand alone and decoupled.  Fixes issues with search widget not closing
  properly on tab changes. (ehelms@redhat.com)
- 757094 - Product should be readable even it has no enabled repos
  (inecas@redhat.com)
- Promotion Search - Adds proper checks when there is no next environment for
  listing promotable packages. (ehelms@redhat.com)
- Automatic commit of package [katello] release [0.1.206-1].
  (lzap+git@redhat.com)
- 785703 - fixing user creation code (lzap+git@redhat.com)
- Automatic commit of package [katello] release [0.1.205-1].
  (lzap+git@redhat.com)
- 785703 - increasing logging for seed script fix (lzap+git@redhat.com)
- Automatic commit of package [katello] release [0.1.204-1].
  (lzap+git@redhat.com)
- Revert "Make default logging level be warn" (lzap+git@redhat.com)
- Automatic commit of package [katello] release [0.1.203-1].
  (lzap+git@redhat.com)
- 785703 - increasing logging for seed script (lzap+git@redhat.com)
- Automatic commit of package [katello] release [0.1.202-1].
  (lzap+git@redhat.com)
- changesets - fixed validations It was not checking whether the distribution's
  repo has been promoted. Validations for other content is also simplified by
  this commit. (tstrachota@redhat.com)
- 783402 - unique constraint for templates in changeset (tstrachota@redhat.com)
- debugging - replacing most info logs with debug (lzap+git@redhat.com)
- Promotion Search - Initial work to enable package search on the promotions
  page with proper calculations. (ehelms@redhat.com)
- katello-debug was having an issue with symlinks (bkearney@redhat.com)
- Automatic commit of package [katello] release [0.1.201-1].
  (mmccune@redhat.com)
- Make default logging level be warn (bkearney@redhat.com)
- Removing accounts.js (jrist@redhat.com)
- Automatic commit of package [katello] release [0.1.200-1].
  (mbacovsk@redhat.com)
- rename-locker- renamed locker in javascript (mbacovsk@redhat.com)
- 785168 - Do not remove dots from pulp ids (lzap+git@redhat.com)
- nicer errors for CLI and RHSM when service is down (lzap+git@redhat.com)
- 769954 - org and repo names in custom repo content label (inecas@redhat.com)
- Automatic commit of package [katello] release [0.1.199-1].
  (tstrachota@redhat.com)
- filters - rename Locker -> Library (tstrachota@redhat.com)
- filters - spec tests (tstrachota@redhat.com)
- filters - orchestration (tstrachota@redhat.com)
- filters - filters can be stored only for locker repos (tstrachota@redhat.com)
- filters - repo promotion uses filters from both repo and its product
  (tstrachota@redhat.com)
- filters - cli for listing filters of a repo (tstrachota@redhat.com)
- filters - api for setting and listing filters in repos
  (tstrachota@redhat.com)
- filters - migration for repository-filter association (tstrachota@redhat.com)
- filters - empty api for assigning filters to repositories
  (tstrachota@redhat.com)
- typos and spelling fix (alikins@redhat.com)
- adding more logging to the warden plugin (lzap+git@redhat.com)
- 761194 - promotions - fix disappearing second level nav
  (bbuckingham@redhat.com)
- 767479 - system packages - fix the count and remove 'more' link when all
  loaded (bbuckingham@redhat.com)
- Automatic commit of package [katello] release [0.1.198-1].
  (mmccune@redhat.com)
- dashboard errata - minor update to address change in pulp response
  (bbuckingham@redhat.com)
- Promotino->Promotion (jrist@redhat.com)
- fix plural for content providers (shughes@redhat.com)
- 784904 - a user with register permission can upload systems packages
  (thomasmckay@redhat.com)
- 784666 - ensure host is configured on Katello start-up (inecas@redhat.com)
- Automatic commit of package [katello] release [0.1.197-1].
  (shughes@redhat.com)
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
- Automatic commit of package [katello] release [0.1.196-1].
  (tstrachota@redhat.com)
- 784563 - deleting repos outside the Locker disabled (tstrachota@redhat.com)
- 771333 - fix password reset (bbuckingham@redhat.com)
- update to translation i18n strings (shughes@redhat.com)
- 782562 - Adding force checkbox to manifest upload to make it force update
  (jomara@redhat.com)
- packages - fix broken test (bbuckingham@redhat.com)
- 784319 - Fixes issue with Default Organization not being set on user
  creation. (ehelms@redhat.com)
- 740931 - fix for role description stretchign too much (paji@redhat.com)
- 756518 - Fix to ensure that global permissions have all_tags automatically
  set to true (paji@redhat.com)
- removed an unused method (paji@redhat.com)
- 773690 - Fixes added packages in system template being hidden and not able to
  be scrolled to. (ehelms@redhat.com)
- 783329 - fix indexing of pkgs for elastic search and use in system templates
  UI (bbuckingham@redhat.com)
- 745955 - Fixes issue where creating a new system template and then clicking
  Package Groups resulted in being return to list of templates.
  (ehelms@redhat.com)
- 754724 - Now when viewing a promoting changeset's details all action buttons
  will be disabled. (ehelms@redhat.com)
- 784009 - ESX hypervisors don't show up in Web UI systems + On Details tab the
  System Type will be listed as "Hypervisor" + Software tab will display
  "Hypervisors do not have software products" + Packages tab will display
  "Hypervisors do not have packages" + Software tab will display "Hypervisors
  do not have errata" (thomasmckay@redhat.com)
- perms - commenting some skip_before_filters (lzap+git@redhat.com)
- Automatic commit of package [katello] release [0.1.195-1].
  (mbacovsk@redhat.com)
- 782775 - Unify unsubscription in RHSM and Katello CLI (mbacovsk@redhat.com)
- Automatic commit of package [katello] release [0.1.194-1].
  (mmccune@redhat.com)
- 761576 - adding back in the password matching field I took out
  (mmccune@redhat.com)
- 768484 - Removed  the User suicide option (paji@redhat.com)
- 783338-Fix to i18nize the panel headers in a 2 pane (paji@redhat.com)
- 761291 - Adds remove organization link to current organization but makes it
  unclickable with tooltip explaining to user why. (ehelms@redhat.com)
- 749026 - Hides New Changeset button when there is no next environment.
  (ehelms@redhat.com)
- 784123 - Fix for i18ning multiselect widget (paji@redhat.com)
- 781272 - Fixed the system template page to not show Add for Read only user
  (paji@redhat.com)
- Fixes broken save on other entities using tupane layout. (ehelms@redhat.com)
- 750123 - Fixes issue with user creation not updating counts in left hand
  list. (ehelms@redhat.com)
- Automatic commit of package [katello] release [0.1.193-1].
  (mmccune@redhat.com)
- Merge branch 'master' into BZ-771757 (thomasmckay@redhat.com)
- 771757 - added flag to api/systems_controller.rb and updated spec tests
  (thomasmckay@redhat.com)
- Fixes issue where Administration tab was increasing in size when opening a
  Role in tupane. (ehelms@redhat.com)
- 747641 - Fixes typo where system template notification indicated successful
  sync plan creation. (ehelms@redhat.com)
- Merge branch 'master' into BZ-771757 (thomasmckay@redhat.com)
- 771757 - page refreshes on toggle checkbox and callback triggered just once
  (thomasmckay@redhat.com)
- 784046-Made the org controller env partial work on new users page
  (paji@redhat.com)
- 773664 - Issue where packages on system templates were not loading more
  packages and user could only see first 25. (ehelms@redhat.com)
- 771757 - candlepin called properly with saved user preference
  (thomasmckay@redhat.com)
- Automatic commit of package [katello] release [0.1.192-1].
  (lzap+git@redhat.com)
- selinux - adding requirement for the main package (lzap+git@redhat.com)
- Automatic commit of package [katello] release [0.1.191-1].
  (lzap+git@redhat.com)
- adding comment to the katello spec (lzap+git@redhat.com)
- Revert "adding first cut of our SELinux policy" (lzap+git@redhat.com)
- Automatic commit of package [katello] release [0.1.190-1].
  (lzap+git@redhat.com)
- adding first cut of our SELinux policy (alikins@redhat.com)
- Automatic commit of package [katello] release [0.1.189-1].
  (mmccune@redhat.com)
- Fix for problem on sync management page from when I moved the actions above
  the table. (jrist@redhat.com)
- 783188 - some missed references to scoped_search and inlining utils
  (mmccune@redhat.com)
- Moved sync management actions to top of table. (jrist@redhat.com)
- Automatic commit of package [katello] release [0.1.188-1].
  (mmccune@redhat.com)
- 783188 - removing scoped_search from our codebase (mmccune@redhat.com)
- 771757 - toggle and callbacks added; still work to be done
  (thomasmckay@redhat.com)
- 781460-Fixed an env security acess violiation issue (paji@redhat.com)
- Modified env.name usages to env.display_name in some places in the UI to deal
  with i18n (paji@redhat.com)
- Made the repo controller log the complete  trace on error (paji@redhat.com)
- 782518 - providers - removed org from resource to fix search history
  (bbuckingham@redhat.com)
- 760703 - promotion of empty products now not possible (lzap+git@redhat.com)
- 771164 - Fixes issue where packages list could be set to nil when attempting
  to load more packages for a system. (ehelms@redhat.com)
- 757775 - allowing rhsm to register systems (lzap+git@redhat.com)
- Automatic commit of package [katello] release [0.1.187-1].
  (lzap+git@redhat.com)
- fix for listing available tags of KTEnvironment (tstrachota@redhat.com)
- Automatic commit of package [katello] release [0.1.186-1].
  (lzap+git@redhat.com)
- perms - fake /api/packages/ path for rhsm (lzap+git@redhat.com)
- Fix to a previous commit related to user default env permissions
  (paji@redhat.com)
- Minor edits to i18n some strings (paji@redhat.com)
- Pushing a missed i18n string (paji@redhat.com)
- 783328,783320,773603-Fixed environments : user permissions issues
  (paji@redhat.com)
- 783323 - i18ned resource types names (paji@redhat.com)
- 754616 - Attempted fix for menu hover jiggle.  - Moved up the third level nav
  1 px.  - Tweaked the hoverIntent settings a tiny bit. (jrist@redhat.com)
- 782883 - Updated branding_helper.rb to include headpin strings
  (thomasmckay@redhat.com)
- 782883 - AppConfig.katello? available, headpin strings added
  (thomasmckay@redhat.com)
- 769619 - Fix for repo enable/disable behavior. (jrist@redhat.com)
- Automatic commit of package [katello] release [0.1.185-1].
  (lzap+git@redhat.com)
- Bumping candlepin version to 0.5.10 (jomara@redhat.com)
- 773686 - Fixes issue with system template package add input box becoming
  unusable after multiple package adds. (ehelms@redhat.com)
- perms - fixing unit tests after route rename (lzap+git@redhat.com)
- perms - moving /errata/id under /repositories API (lzap+git@redhat.com)
- perms - moving /packages/id under /repositories API (lzap+git@redhat.com)
- 761667 - JSON error message from candlepin parsed correctly
  (thomasmckay@redhat.com)
- Automatic commit of package [katello] release [0.1.184-1].
  (inecas@redhat.com)
- 773454 - system templates - temporary fix for adding packages to template
  (bbuckingham@redhat.com)
- manifest-import - correct content-type header (inecas@redhat.com)
- katello-agent-cli - adoption to latest changes in pulp-0.0.258-1
  (inecas@redhat.com)
- 782232-Made the candlepin urls use url encoded values for params
  (paji@redhat.com)
- 771411 - distributions - update resource and add perms
  (bbuckingham@redhat.com)
- 755942 remove sync complete message for non synced products
  (shughes@redhat.com)
- Fixed some unit test issues that got generated with my previous commit
  (paji@redhat.com)
- Automatic commit of package [katello] release [0.1.183-1].
  (mmccune@redhat.com)
- 761576 - removing CSS and jquery plugins for simplePassMeter
  (mmccune@redhat.com)
- 761576 - removing the password strength meter (mmccune@redhat.com)
- Moves javascript to bottom of html page and removes redundant i18n partials
  to the base katello layout. (ehelms@redhat.com)
- 771957-Made the org deletion code a little better (paji@redhat.com)
- Automatic commit of package [katello] release [0.1.182-1].
  (inecas@redhat.com)
- host-guest - improvement of API when no host is present for a guest
  (inecas@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (bbuckingham@redhat.com)
- Bug 781585 - As a user, I want to set my locale on the User Details page.
  https://bugzilla.redhat.com/show_bug.cgi?id=781585 + Minor clean up based
  upon code review (thomasmckay@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (bbuckingham@redhat.com)
- host-guest - fix error in the model when no host is present for guest
  (inecas@redhat.com)
- dashboard errata - fix to handle error case when there are no readable repos
  (bbuckingham@redhat.com)
- Merge branch 'master' into dashboard-errata (bbuckingham@redhat.com)
- dashboard errata - miscellaneous fixes (bbuckingham@redhat.com)
- gpg-cli - remove unused code (inecas@redhat.com)
- Automatic commit of package [katello] release [0.1.181-1].
  (inecas@redhat.com)
- gpg-cli - fix repo update permissions (inecas@redhat.com)
- gpg-cli - fix failing tests (inecas@redhat.com)
- gpg-cli - fix providing content of GPG key for a repo (inecas@redhat.com)
- vsphere - show host/guests in CLI system info (inecas@redhat.com)
- vsphere - fix indexing of hypervisor (inecas@redhat.com)
- gpg-cli - show products and repos assigned to GPG (inecas@redhat.com)
- gpg-cli - Allow to update only custom product/repo (inecas@redhat.com)
- gpg-cli - API and CLI for GPG - repo/product manipulation (inecas@redhat.com)
- gpg-cli - protect GPG API resources (inecas@redhat.com)
- gpg-cli - CLI support for modifying GPG <-> product/repo association
  (inecas@redhat.com)
- gpg-cli - use immutable value gpgurl in CP (inecas@redhat.com)
- gpg-cli - CRUD for GPG keys through CLI/API (inecas@redhat.com)
- gpg-cli - support for port in host for gpg key path (inecas@redhat.com)
- Fix failing test - deterministic RH repo name format (inecas@redhat.com)
- Automatic commit of package [katello] release [0.1.180-1].
  (thomasmckay@redhat.com)
- remove duplicate Korean entry in zanata (shughes@redhat.com)
- 749805 - httpd - katello.conf - update to remove unnecessary / in path
  (bbuckingham@redhat.com)
- i18n - System auto-heal and candlepin glue. (jrist@redhat.com)
- i18n - Filter placeholders. (jrist@redhat.com)
- i18n - System initial registration strings. (jrist@redhat.com)
- i18n - Sync plan. (jrist@redhat.com)
- Fix for width and hover on one_panel arrow. (jrist@redhat.com)
- Fix for width and hover on one_panel. (jrist@redhat.com)
- i18n - Panel error js. (jrist@redhat.com)
- i18n - Package filters strings. (jrist@redhat.com)
- Fix for +New arrow on hover when selected. (jrist@redhat.com)
- i18n - Error: on 500 page. (jrist@redhat.com)
- Dashboard Errata: Adds new tipsy with support for closing all sticky click
  tooltips via event trigger. (ehelms@redhat.com)
- Russian special num/char locale (shughes@redhat.com)
- Korean special num/char locale (shughes@redhat.com)
- i18n - "Search..." placeholder text in search box for search form on tupane.
  (jrist@redhat.com)
- italian special num/char locale (shughes@redhat.com)
- adding Hindi special char/num locale (shughes@redhat.com)
- spanish special num/char locale (shughes@redhat.com)
- german special num/char locale (shughes@redhat.com)
- adding Bengali char/num locale (shughes@redhat.com)
- api perms review - distributions (lzap+git@redhat.com)
- Automatic commit of package [katello] release [0.1.179-1].
  (tstrachota@redhat.com)
- scheduled sync - listing sync plan names in 'product list'
  (tstrachota@redhat.com)
- scheduled sync - fixes in spec tests (tstrachota@redhat.com)
- scheduled sync - plan_id in products can be null (tstrachota@redhat.com)
- scheduled sync - time format of non-recurring sync plans
  (tstrachota@redhat.com)
- cheduled sync - fix for orchestration Adds posibility to unset
  synchronization schedule for pulp repos. (tstrachota@redhat.com)
- scheduled sync - api for setting/removing sync plans from products
  (tstrachota@redhat.com)
- tpl repos - support for repo promotions in templates (tstrachota@redhat.com)
- tpl repos - support for repositories in template import/export
  (tstrachota@redhat.com)
- tpl repos - api for adding repos to templates (tstrachota@redhat.com)
- 773733 - adding delayed_jobs to the ping check (jsherril@redhat.com)
- Bug 781585 - fixed ActiveRecord translated error messages by modifying
  config/locale for regional dialects (thomasmckay@redhat.com)
- Missed an i18n of a string "Filter". (jrist@redhat.com)
- 772169 - fixing sort issue on promotions mixing templates and products
  (jsherril@redhat.com)
- 768296 - fixing issue where changeset history page threw error if full
  product was not included (jsherril@redhat.com)
- Merge branch 'master' into i18n (shughes@redhat.com)
- 750354 - activation key - do not highlight to change template when there are
  none (bbuckingham@redhat.com)
- Bug 781585 - corrected list of locale choices in app_config and katello.yml
  (thomasmckay@redhat.com)
- adding regional chinese locales (shughes@redhat.com)
- restructure po files for fast gettext (shughes@redhat.com)
- update to zanata mappings for regional locales (shughes@redhat.com)
- Dashboard Errata: Refactors the errata tooltip into re-usable widget.
  (ehelms@redhat.com)
- Bug 781585 - escaped all 'localized' variables in haml to avoid issue w/
  translations that contain ' (like french) (thomasmckay@redhat.com)
- remove pt-PT locale (shughes@redhat.com)
- Fixing "Display" i18n on Dashboard filter. (jrist@redhat.com)
- Merge branch 'konnichiwa' of ssh://git.fedorahosted.org/git/katello into i18n
  (shughes@redhat.com)
- make parsing locale strings more robust (shughes@redhat.com)
- adding promoted by user to search index for changesets (jsherril@redhat.com)
- dashboard - errata - do not include available errata where there are no
  systems (bbuckingham@redhat.com)
- Updated the menu items to use translated names (paji@redhat.com)
- 755522 - adding user that promoted a changeset to the changeset history page
  (jsherril@redhat.com)
- modify http accept lang regex (shughes@redhat.com)
- 748022 - Places cancel button to the right of the indicator text when
  selecting all resource types creating a permission. (ehelms@redhat.com)
- dashboard - errata - add info icon for viewing errata details
  (bbuckingham@redhat.com)
- Merge branch 'master' into dashboard-errata (bbuckingham@redhat.com)
- Bug 781585 - languages listed in zanata.xml now set as defaults, and
  katello.yml updated w/ comment for customizing (thomasmckay@redhat.com)
- Bug 781585 - pull locales from katello.yml, if present, or use internally
  defined (thomasmckay@redhat.com)
- Merge branch 'master' into konnichiwa (thomasmckay@redhat.com)
- Bug 781585 - partial progress allowing locale setting in ui
  (thomasmckay@redhat.com)
- fixing errata unit tests - were failing 'sometimes' (lzap+git@redhat.com)
- api perms review - marking some filters (lzap+git@redhat.com)
- api perms review - removing filters (lzap+git@redhat.com)
- api perms review - users (lzap+git@redhat.com)
- api perms review - uebercert (lzap+git@redhat.com)
- 771469 - Changes tupane panel hash identifier from being i18ned.
  (ehelms@redhat.com)
- Merge branch 'sys-errata' (ehelms@redhat.com)
- System Errata: Unit test fixes. (ehelms@redhat.com)
- adding Telugu locale strings (shughes@redhat.com)
- adding Tamil locale strings (shughes@redhat.com)
- adding Russian locale strings (shughes@redhat.com)
- Merge branch 'master' into sys-errata (ehelms@redhat.com)
- System Errata: Changes to make tipsy tooltip disappear when scrolling the
  errata table. (ehelms@redhat.com)
- adding Punjabi locale strings (shughes@redhat.com)
- adding Oriya locale strings (shughes@redhat.com)
- adding Marathi locale strings (shughes@redhat.com)
- adding Korean locale strings (shughes@redhat.com)
- adding Hindi locale strings (shughes@redhat.com)
- adding Gujarati locale strings (shughes@redhat.com)
- adding Bengali strings; updating existing locale strings (shughes@redhat.com)
- correct tamil locale configs (shughes@redhat.com)
- update zanata local supported list (shughes@redhat.com)
- api perms review - removing unused templates/index (lzap+git@redhat.com)
- api perms review - templates (lzap+git@redhat.com)
- api perms review - templates_content (lzap+git@redhat.com)
- adding it locale strings (shughes@redhat.com)
- adding es locale strings (shughes@redhat.com)
- adding de locale strings (shughes@redhat.com)
- Automatic commit of package [katello] release [0.1.178-1].
  (lzap+git@redhat.com)
- api perms review - tasks (lzap+git@redhat.com)
- 771957 - Fixed an org deletion failure issue (paji@redhat.com)
- 755522 - fixing issue where adding filters to a product in the UI did not
  actually take effect in pulp (jsherril@redhat.com)
- adding elasticsearch to ping api (jsherril@redhat.com)
- disabling fade in for sync page (jsherril@redhat.com)
- 773137 - Made the  system search stuff adhre to permissions logic
  (paji@redhat.com)
- 746913 fix sync plan time, incorrectly using date var (shughes@redhat.com)
- removing obsolete strings (shughes@redhat.com)
- removing scoped search  from existing models (jsherril@redhat.com)
- Automatic commit of package [katello] release [0.1.177-1].
  (jomara@redhat.com)
- Fix for sync_management_controller if error_details was empty.
  (jrist@redhat.com)
- api perms review - sync (lzap+git@redhat.com)
- System Errata: Pushes initial item load to ajax call. (ehelms@redhat.com)
- api perms review - subscriptions (lzap+git@redhat.com)
- disabling memory status in production mode (lzap+git@redhat.com)
- api perms review - repositories (lzap+git@redhat.com)
- making shared messages a bit shorter (lzap+git@redhat.com)
- System Errata: Adds scroll pane and sets maximum size on errata details
  hover. (ehelms@redhat.com)
- Fixed some navigation file that were executing non existent variables
  (paji@redhat.com)
- General fix to move all render_navigation to render-menu so that the
  navigation rules will be adhered to in the UI (paji@redhat.com)
- dashboard - errata - remove some unneeded code (bbuckingham@redhat.com)
- dashboard - updating to support displaying of real errata
  (bbuckingham@redhat.com)
- dashboard - errata - fix expander arrow after filter change
  (bbuckingham@redhat.com)
- fixing previously fixed obscure spec test for all cases (jsherril@redhat.com)
- 740584 - Fix for buttons within jQuery UI Dialog. (jrist@redhat.com)
- fixing obscure unit test for some people (jsherril@redhat.com)
- fixing sporatic spec test failure for some users (jsherril@redhat.com)
- fixing elastic search total counts, as well as fixing count order and
  results_count going to NaN in ui (jsherril@redhat.com)
- fixing issue where display_attributes was not available during testing
  (jsherril@redhat.com)
- 773425 fix loading of translation strings in po format (shughes@redhat.com)
- Fixes to bubble up sync errors. (jrist@redhat.com)
- Fixed on showing 'no environments' message instead of hiding tab in user
  details (paji@redhat.com)
- 768477-Fix to make environments menu not show up when user does not have a
  current org (paji@redhat.com)
- System Errata: Changes for errata to show up properly in system events.
  (ehelms@redhat.com)
- 773314: correct syntax issue causing premature exception to be thrown
  (shughes@redhat.com)
- Merge branch 'master' into sys-errata (ehelms@redhat.com)
- sql is now logged to test_sql.log for testing env (lzap+git@redhat.com)
- nicer debug logging for permissions (lzap+git@redhat.com)
- api perms review - puppetclasses (lzap+git@redhat.com)
- api perms review - products (lzap+git@redhat.com)
- api perms review - ping (lzap+git@redhat.com)
- api perms review - permissions (lzap+git@redhat.com)
- api perms review - organizations (lzap+git@redhat.com)
- api perms review - environments (lzap+git@redhat.com)
- Automatic commit of package [katello] release [0.1.175-1].
  (tstrachota@redhat.com)
- 751874 - removed index action from route /api/repositories/
  (tstrachota@redhat.com)
- 755105 - dep. calc. selects only latest versions of packages
  (tstrachota@redhat.com)
- 755105 - dep. calc. takes the full dependency tree into account + filters out
  already promoted packages (tstrachota@redhat.com)
- 750110 fix checkbox offset from repo name labels (shughes@redhat.com)
- 765995 fix notification messages when orgs created with supplied envs
  (shughes@redhat.com)
- repository - add scope to support retrieving all readable repositories
  (bbuckingham@redhat.com)
- adding attribute auto complete for roles (jsherril@redhat.com)
- adding auto complete attributes for user (jsherril@redhat.com)
- 773310 - fixing search favorites creation (jsherril@redhat.com)
- adding attribute list for activation keys (jsherril@redhat.com)
- adding sample facts to system auto complete (jsherril@redhat.com)
- adding system attributes for auto complete (jsherril@redhat.com)
- adding attribute list for changesets (jsherril@redhat.com)
- adding auto complete attributes for sync plans (jsherril@redhat.com)
- adding auto complete attributes for gpg keys (jsherril@redhat.com)
- adding attribute list for filters (jsherril@redhat.com)
- fixing missing indexed attributes (jsherril@redhat.com)
- adding initial support for attributes list in search drop down
  (jsherril@redhat.com)
- Fixes for clearing search and hitting enter key to submit.
  (ehelms@redhat.com)
- 745619 disable sync when no repos are selected (shughes@redhat.com)
- 768477-Fixed a dashboard page issue were an undefined method error was
  showing up (paji@redhat.com)
- Added tasks to render package groups in the system events page
  (paji@redhat.com)
- spec stub for candlepin events (thomasmckay@redhat.com)
- fixed failing spec tests (thomasmckay@redhat.com)
- Bug 772701 - add candlepin system events to events listing
  https://bugzilla.redhat.com/show_bug.cgi?id=772701 + Moved Candlepin task
  creation to system.rb:refresh_for_system() (thomasmckay@redhat.com)
- Bug 772701 - add candlepin system events to events listing
  https://bugzilla.redhat.com/show_bug.cgi?id=772701 + Some minor clean up for
  Candlepin event display (thomasmckay@redhat.com)
- Bug 772701 - add candlepin system events to events listing
  https://bugzilla.redhat.com/show_bug.cgi?id=772701 + Initial implementation
  works. Piggy-backs on pulp tasks too much + Candlepin events are lazy-loaded
  in view controller #index; need to move to system model
  (thomasmckay@redhat.com)
- Forgot to add the migration script (paji@redhat.com)
- Added a locking mechanism for roles that were created by katello
  (paji@redhat.com)
- Automatic commit of package [katello] release [0.1.174-1].
  (mmccune@redhat.com)
- 744006 - Fixes issue with consistency in selecting all resource types.
  (ehelms@redhat.com)
- Fixes issues with progressbar styling. (ehelms@redhat.com)
- update to i18n strings (shughes@redhat.com)
- System Errata: Fixes for unit tests. (ehelms@redhat.com)
- Automatic commit of package [katello] release [0.1.173-1].
  (inecas@redhat.com)
- katello-agent - fix task refreshing (inecas@redhat.com)
- fixing self roles showing up in the UI (jsherril@redhat.com)
- System Errata: Adds new version of tipsy plugin. (ehelms@redhat.com)
- System Errata: Adds reference url to errata information and cleans up
  description. (ehelms@redhat.com)
- Automatic commit of package [katello] release [0.1.172-1].
  (inecas@redhat.com)
- 770418 - Fixed the read every thing role to only include the read permissions
  (paji@redhat.com)
- fixing default notices sort (jsherril@redhat.com)
- spec test fix (jsherril@redhat.com)
- System Errata: Adds info tooltip to display more detailed information about a
  given errata. (ehelms@redhat.com)
- migrating notices to es (jsherril@redhat.com)
- replacing some missed search_fors in a few controllers (jsherril@redhat.com)
- 746628 fix sync schedule to handle empty plans/product selections in
  controller (shughes@redhat.com)
- Updated the verbs in the permissions page (paji@redhat.com)
- Corrected a downcasing issue on roles search (paji@redhat.com)
- Automatic commit of package [katello] release [0.1.171-1].
  (tstrachota@redhat.com)
- 769267 - fixed template promotion Repositories were searched by pulp id
  instead of AR id in package promotion. (tstrachota@redhat.com)
- Temporary fix for jenkins errors (paji@redhat.com)
- Fixed another unit test (paji@redhat.com)
- Fixed a bunch of unit tests and made Pulp::Task.find always accept an array
  of ids and return an array of statuses (paji@redhat.com)
- Made the pulp task code now be able to retrieve multiple tasks in one call
  (paji@redhat.com)
- Bug 761667 - Invalid data for new system name displays JSON error message
  https://bugzilla.redhat.com/show_bug.cgi?id=761667 + Parse displayMessage out
  of error to display in notice (thomasmckay@redhat.com)
- disable tire logging by default (jsherril@redhat.com)
- 761645 - Fix for selecting left list items with ctrl-click. Added a color to
  make it a bit more intuitive as well. (jrist@redhat.com)
- Fixed the searhc sort order issue in the events search history page
  (paji@redhat.com)
- Fixed a couple of search issue related to matching all and sorting
  (paji@redhat.com)
- Automatic commit of package [katello] release [0.1.170-1].
  (mmccune@redhat.com)
- System Errata: Adds updated loading of errata with better indication of
  result counts. (ehelms@redhat.com)
- updated translation strings (shughes@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (thomasmckay@redhat.com)
- System Errata: Navigation fixes (ehelms@redhat.com)
- Bug 768953 - Creating a new system from the webui fails to display
  Environment ribbon correctly
  https://bugzilla.redhat.com/show_bug.cgi?id=768953 + The environment
  selector, because only one can exist on the page at a time, has some control
  code around it to detect whether the "all" systems page is being viewed or
  the per-environment page. Fixed now. (thomasmckay@redhat.com)
- Automatic commit of package [katello] release [0.1.169-1].
  (tstrachota@redhat.com)
- 755105 - dependency calculation rejects already promoted packages
  (tstrachota@redhat.com)
- 755105 - listing filenames instead of names of dependent packages
  (tstrachota@redhat.com)
- changesets api - fix in getting environment for permissions
  (tstrachota@redhat.com)
- changesets - dep resolve returns complete json from pulp not only resolved
  packages (tstrachota@redhat.com)
- changesets - api for calculating dependencies (tstrachota@redhat.com)
-  fixing unit tests (jsherril@redhat.com)
- migrating roles to elastic search (jsherril@redhat.com)
- fixing error message for missing name to not reference pulp_id
  (jsherril@redhat.com)
- migrating filters tupane to use indexed search (jsherril@redhat.com)
- fixing panel behavior for gpg key and sync plans (jsherril@redhat.com)
- migrating sync plans to be indexed (jsherril@redhat.com)
- migrating gpg keys to search server (jsherril@redhat.com)
- Merge branch 'master' into sys-errata (ehelms@redhat.com)
- Automatic commit of package [katello] release [0.1.168-1].
  (inecas@redhat.com)
- 771911 - keep facts on system update (inecas@redhat.com)
- Automatic commit of package [katello] release [0.1.167-1].
  (mmccune@redhat.com)
- Fixed some broken oauth url logic (paji@redhat.com)
- Renamed menu General to Details to conform with other pages (paji@redhat.com)
- Merge branch 'master' into event-history (paji@redhat.com)
- Updated the navs to use SystemInfo as the default landing page when you click
  ona systenm (paji@redhat.com)
- Fix for products and repositories created without a gpg key.
  (ehelms@redhat.com)
- Re-comments out view code that is not currently functional that got enabled
  from previous bug fix 761277. (ehelms@redhat.com)
- Bug 771735 - error visiting logged in user's admin page
  https://bugzilla.redhat.com/show_bug.cgi?id=771735 + For a user unable to
  read any users the users page was not reachable (thomasmckay@redhat.com)
- Fixed some merge conflicts (paji@redhat.com)
- fixed some unit tests (paji@redhat.com)
- 760805 - Fix for the upload button - made it a link so that it didn't look
  different due to styling issues.  Also now it floats properly.
  (jrist@redhat.com)
- Merge branch 'master' into sys-left-update (thomasmckay@redhat.com)
- changed result of broken test (thomasmckay@redhat.com)
- Added code to render 'no events' message (paji@redhat.com)
- internationalize date of subscriptions (thomasmckay@redhat.com)
- Made the task status search index use the standard search instead of snowball
  for '*' query to work (paji@redhat.com)
- BZ#759144 - removed time portion of 'subcriptions are current until' display
  (thomasmckay@redhat.com)
- 761277 - When creating or editing a product or repository, if there are no
  gpg keys for the current organization a message is displayed stating such
  instead of a blank dropdown. (ehelms@redhat.com)
- Added code to set a deafult query prefix (paji@redhat.com)
- Automatic commit of package [katello] release [0.1.166-1].
  (tstrachota@redhat.com)
- Right hand pane title properly updating now (thomasmckay@redhat.com)
- scheduled sync - cli for creating sync plans (tstrachota@redhat.com)
- scheduled sync - cli for deleting sync plans (tstrachota@redhat.com)
- scheduled sync - api for sync plans CRUD (tstrachota@redhat.com)
- fixed some merge conflicts (paji@redhat.com)
- Mods on the Task Status search page to include the erros or failure key words
  in status (paji@redhat.com)
- Works! Newly noticed problem, though, is that on refresh the left value is
  set as the right title (to make sure that a name change updates on the
  right). In systems, though, I had added the status icon which is showing up
  too now. panel.js needs fixing. (thomasmckay@redhat.com)
- Fix to display slightly better messages on event details and event lists
  page. (paji@redhat.com)
- 766797 - Fixes issue with environment selector showing without mouse being
  inside container. (ehelms@redhat.com)
- left side updating but with wrong html :) (thomasmckay@redhat.com)
- 768012 - precalculate path substitutions before creating repos
  (inecas@redhat.com)
- 768047 - notices - update to enable usage in controller or model
  (bbuckingham@redhat.com)
- spec test fix (jsherril@redhat.com)
- migrating to new argument format for render_panel_direct
  (jsherril@redhat.com)
- fixing changeset spec tests (jsherril@redhat.com)
- migrating changesets to the search server (jsherril@redhat.com)
- unit test addition (jsherril@redhat.com)
- making activation key be indexed and searched via index (jsherril@redhat.com)
- fixing system template left hand side breadcrumb styling
  (jsherril@redhat.com)
- Removing console calls (paji@redhat.com)
- 753253 - When creating or deleting an entity with a tupane page view, the
  total count is now updated properly. (ehelms@redhat.com)
- Automatic commit of package [katello] release [0.1.165-1].
  (shughes@redhat.com)
- Merge branch 'master' into event-history (paji@redhat.com)
- 766977 fixing org box dropdown mouse sensitivity (shughes@redhat.com)
- Merge branch 'master' into event-history (paji@redhat.com)
- Add elastic search to the debug collection (bkearney@redhat.com)
- Fixed some merge conflicts (paji@redhat.com)
- 750117 - Fixes issue with duplicate search results being returned that
  stemmed from pressing enter within the search field too many times.
  (ehelms@redhat.com)
- Removed unused katello_task_status object (paji@redhat.com)
- Updated the reindex queries to ignore indexing PulpSyncStatus and
  PulpTaskStats files since they are both using TaskStatus's index
  (paji@redhat.com)
- translated strings from zanata (shughes@redhat.com)
- Updated some i18n strings (paji@redhat.com)
- Updated some js routes (paji@redhat.com)
- Fixed merge conflicts (paji@redhat.com)
- Made the search for task type use the snowball analyzer to search
  (paji@redhat.com)
- Rewrote a line to make the intent of the method clearer (paji@redhat.com)
- 752177 - Adds clearing of search hash when search input is cleared manually
  or via Clear from dropdown. (ehelms@redhat.com)
- 769905 remove yum 3.2.29 requirements from katello (shughes@redhat.com)
- Automatic commit of package [katello] release [0.1.164-1].
  (thomasmckay@redhat.com)
- virt-who-vsphere - fix failing specs (inecas@redhat.com)
- virt-who-vsphere - disable pulp actions (inecas@redhat.com)
- virt-who-vsphere - create hypervisors on virt-who vsphere call
  (inecas@redhat.com)
- virt-who-vsphere - support for STI in indexed model (inecas@redhat.com)
- update to l10n strings (shughes@redhat.com)
- Automatic commit of package [katello] release [0.1.163-1].
  (inecas@redhat.com)
- 771363 - Pulp on RHEL requires yum >= 3.2.29-21 for promoting
  (inecas@redhat.com)
- 771363 - calc_dependencies_for_product returns always hash
  (inecas@redhat.com)
- 771363 - let AcitveRecord serialize error result in async operation
  (inecas@redhat.com)
- Merge branch 'master' into sys-left-update (thomasmckay@redhat.com)
- Automatic commit of package [katello] release [0.1.162-1].
  (tstrachota@redhat.com)
- organizations api - removed forgotten command 'debugger'
  (tstrachota@redhat.com)
- permissions - api unit tests (tstrachota@redhat.com)
- fixed warnings from gpg keys controller unit test Constant changed to a
  variable to avoid 'constant already defined' warning. (tstrachota@redhat.com)
- roles api - enhanced spec tests (tstrachota@redhat.com)
- permissions - new command 'permission delete' (tstrachota@redhat.com)
- permissions - new command 'permission create' (tstrachota@redhat.com)
- permissions - adding tags, verbs and type to json exports permanently
  (tstrachota@redhat.com)
- permissions - api for creating permissions (tstrachota@redhat.com)
- fixing small issue with reindex where reindex would be attempted with empty
  collection resulting in an error (jsherril@redhat.com)
- unit test fixes (jsherril@redhat.com)
- adding environment names to organization object (jsherril@redhat.com)
- making organization indexable and searchable via index (jsherril@redhat.com)
- Fixed some messages to make rake get text happy (paji@redhat.com)
- Bug 769896 - Organizations / Subscriptions error "undefined method 'each' for
  nil:NilClass https://bugzilla.redhat.com/show_bug.cgi?id=769896
  https://bugzilla.redhat.com/show_bug.cgi?id=769898 + This problem arose from
  an additional class, MarketingProduct, that extended   Product. The
  lazy_accessor.rb methods could not handle this which caused   the attributes
  to go missing. The fix is to check a class's parent for the   lazy_attributes
  method and add it to the list of attributes. (This is done   recursively up
  the hierarchy until a class stops responding to that method.)
  (thomasmckay@redhat.com)
- removing Gemfile.lock and adding to .gitignore. (mmccune@redhat.com)
- Automatic commit of package [katello] release [0.1.161-1].
  (thomasmckay@redhat.com)
- controllers - adding missing copyright headers (bbuckingham@redhat.com)
- fix broken tests resulting from RAILS / katello name collision
  (bbuckingham@redhat.com)
- Add a bit more logging (bkearney@redhat.com)
- katello-debug should preserve time stamps (bkearney@redhat.com)
- Added code to display  better event details. (paji@redhat.com)
- added 'uuid' and 'description' to searchable System attributes
  (thomasmckay@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (bkearney@redhat.com)
- Add package list (bkearney@redhat.com)
- First cut at a katello-debug (bkearney@redhat.com)
- using username for sorting instead of login which is a pulp attribute
  (jsherril@redhat.com)
- adding reindex rake task (jsherril@redhat.com)
- Added facility to enable a model to use the index of another model - useful
  for subsclasses (paji@redhat.com)
- api perms review - distributions refactor tests (lzap+git@redhat.com)
- Automatic commit of package [katello] release [0.1.160-1].
  (lzap+git@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (bbuckingham@redhat.com)
- moving /distributions API into /repositories path (lzap+git@redhat.com)
- Merge branch 'master' into templates-repo (bbuckingham@redhat.com)
- disabling auto-complete on tupane pages (jsherril@redhat.com)
- Merge branch 'master' into event-history (paji@redhat.com)
- Automatic commit of package [katello] release [0.1.159-1].
  (thomasmckay@redhat.com)
- Automatic commit of package [katello] release [0.1.158-1].
  (thomasmckay@redhat.com)
- api perms review - distributions ui perms (lzap+git@redhat.com)
- Revert "api perms review - changesets" (lzap+git@redhat.com)
- api perms review - changesets (lzap+git@redhat.com)
- Automatic commit of package [katello] release [0.1.157-1].
  (lzap+git@redhat.com)
- api perms review - activation keys (lzap+git@redhat.com)
- 751033 - adding subscriptions to activation key exception
  (lzap+git@redhat.com)
- perms - changesets permission review (lzap+git@redhat.com)
- Automatic commit of package [katello] release [0.1.156-1].
  (lzap+git@redhat.com)
- api perms - changesets unittests (lzap+git@redhat.com)
- api perms - changesets (lzap+git@redhat.com)
- permission coverage rake spec improvement (lzap+git@redhat.com)
- system templates - fix packages, groups and repos to be consistent w/
  promotions (bbuckingham@redhat.com)
- Merge branch 'master' into event-history (paji@redhat.com)
- Added some model changes and made search work (paji@redhat.com)
- system templates - fix label on template tree for repos
  (bbuckingham@redhat.com)
- 768047 - promotions - let user know if promotion fails
  (bbuckingham@redhat.com)
- 754609 - Sync status on dashboard now rounded percent. (jrist@redhat.com)
- Automatic commit of package [katello] release [0.1.155-1].
  (inecas@redhat.com)
- Merge branch 'master' into event-history (paji@redhat.com)
- Made some changes for system events page to deal with 'no events'
  (paji@redhat.com)
- Added a comment, fixed a typo (paji@redhat.com)
- Made the tupane header take the system id in the delete call. Was getting a
  route not found before (paji@redhat.com)
- Fix for key on panel actions helptip. (jrist@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (bkearney@redhat.com)
- 743073: Disable having rails servce static content (bkearney@redhat.com)
- Adding a helptip to panel actions. (jrist@redhat.com)
- System Errata: Adds on load status check and setting for visible errata.
  (ehelms@redhat.com)
- Making selected menu  on third level nav same as hover. (jrist@redhat.com)
- User Notifications page now a bit cleaner.   - moved deletion to top and
  changed to link, added .deletable which makes it red.   - moved helptip to
  above heading and search (still not happy with it) (jrist@redhat.com)
- Merge branch 'master' into sys-errata (ehelms@redhat.com)
- Fixed some merge conflicts (paji@redhat.com)
- Merge branch 'kt-agent-cli' (inecas@redhat.com)
- kt-agent-cli - rspec examples for system task messages (inecas@redhat.com)
- Automatic commit of package [katello] release [0.1.154-1].
  (mmccune@redhat.com)
- removing indexing for changesets, as its not needed currently
  (jsherril@redhat.com)
- System Errata: Connects UI to real errata install with status updates.
  (ehelms@redhat.com)
- Merge branch 'master' into event-history (paji@redhat.com)
- Updated the routes regex to discard api and regenerated the routes
  (paji@redhat.com)
- Updated the routes regex to discard api and regenerated the routes
  (paji@redhat.com)
- Fixed a merge conflict goof up (paji@redhat.com)
- kt-agent-cli - controller API unit tests for katello-agent
  (inecas@redhat.com)
- Fixed a bunch of merge conflicts on master merge (paji@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (jsherril@redhat.com)
- Automatic commit of package [katello] release [0.1.153-1].
  (jsherril@redhat.com)
- make sure that katello prefix is part of the gpg url (ohadlevy@redhat.com)
- fixing routes.js (jsherril@redhat.com)
- Merge branch 'master' into search (jsherril@redhat.com)
- Automatic commit of package [katello] release [0.1.152-1].
  (thomasmckay@redhat.com)
- kt-agent-cli - API and CLI for system task status (inecas@redhat.com)
- Automatic commit of package [katello] release [0.1.151-1].
  (lzap+git@redhat.com)
- System Errata: Adds periodic status check for errata being installed.
  (ehelms@redhat.com)
- Added code to list the page size (paji@redhat.com)
- System Errata: Adds functionality for sending errata ids from the UI down to
  the controller and showing status. (ehelms@redhat.com)
- Added ability to parse through more events when needed (paji@redhat.com)
- Added code to have the most recently updated event show up at the top
  (paji@redhat.com)
- Added messages for package groups in the model (paji@redhat.com)
- Updated date created to date (paji@redhat.com)
- Updated the rendereding of the event history page with new messages
  (paji@redhat.com)
- 768118 - System detail pane now has "Remove System" (jrist@redhat.com)
- Merge branch 'master' into search (jsherril@redhat.com)
- Bug 769372 - Second import subscriptions do not show up
  https://bugzilla.redhat.com/show_bug.cgi?id=769372 + Problem was in
  providers_controller just getting the first subscription to check provider
  against; all subscriptions should have been checked. (thomasmckay@redhat.com)
- System Errata: Adds model and glue layer changes for installing errata based
  on a set of errata ids. (ehelms@redhat.com)
- system templates - fix specs broken by addition of repo
  (bbuckingham@redhat.com)
- system template - updates to tdl for handling templates containing individual
  repos (bbuckingham@redhat.com)
- System Errata: Adds status text display. (ehelms@redhat.com)
- reverting to old package behavior (jsherril@redhat.com)
- Don't use :id => false for not HABTM tables (inecas@redhat.com)
- work in progress (thomasmckay@redhat.com)
- kt-agent-cli - CLI support for remote installation (inecas@redhat.com)
- Automatic commit of package [katello] release [0.1.150-1].
  (tstrachota@redhat.com)
- permissions - api for listing and deleting permissions
  (tstrachota@redhat.com)
- user roles - api for listing available verbs (tstrachota@redhat.com)
- users - fix for api listing self roles of users (tstrachota@redhat.com)
- user roles - api for assigning to and unassigning from roles
  (tstrachota@redhat.com)
- Automatic commit of package [katello] release [0.1.149-1].
  (lzap+git@redhat.com)
- Added more enhancements to System Events history + details page
  (paji@redhat.com)
- system template - update to allow adding individual repos to template
  (bbuckingham@redhat.com)
- unit test fix (jsherril@redhat.com)
- fixing broken unit tests
- ignoring tire if running tests
- Search: Adds button disabling on unsearchable content within sliding tree.
  (ehelms@redhat.com)
- System Errata: Replaces product with title from errata. (ehelms@redhat.com)
- Automatic commit of package [katello] release [0.1.148-1].
  (lzap+git@redhat.com)
- Revert "765888 - Error during promotion" (lzap+git@redhat.com)
- ak - fixing unit tests (lzap+git@redhat.com)
- ak - subscribing according products (lzap+git@redhat.com)
- Bug 768388 - Perpetual spinner cursor upon changing a user's org.
  https://bugzilla.redhat.com/show_bug.cgi?id=768388 + Incorrectly loading
  env_select.js twice which was causing javascript errors   and these resulted
  in spinner not clearing (thomasmckay@redhat.com)
- Changes organizations tupane subnavigation to be consistent with others.
  (ehelms@redhat.com)
- System Errata: Changes to remove fake data and hook real system errata for UI
  viewing. (ehelms@redhat.com)
- making filters more flexible within application controller
  (jsherril@redhat.com)
- fixing provider search to not show redhat provider (jsherril@redhat.com)
- adding elasticsearch plugin log to logrotate for katello
  (jsherril@redhat.com)
- changing system templates auto complete to use elastic search
  (jsherril@redhat.com)
- adding package search for promotions (jsherril@redhat.com)
- Automatic commit of package [katello] release [0.1.147-1].
  (thomasmckay@redhat.com)
- 767798: Pass in cp-consumer instead of cp-user for system calls which are
  proxied to candlepin (bkearney@redhat.com)
- Automatic commit of package [katello] release [0.1.146-1].
  (thomasmckay@redhat.com)
- Added GPG key distribution support (ohadlevy@redhat.com)
- 746339 - scope system name uniqueness by env (inecas@redhat.com)
- Updated the system event history page to automatically refresh on pending
  events (paji@redhat.com)
- Updated task status to show the right information for pending tasks
  (paji@redhat.com)
- Updated system events to accept a bunch of task status ids return status info
  appropriately (paji@redhat.com)
- Merge branch 'search' of ssh://git.fedorahosted.org/git/katello into search
  (paji@redhat.com)
- Added a way to delete the search indices when the DB was reset
  (paji@redhat.com)
- auto_search_complete - allow controller to provide object for permissions
  check (bbuckingham@redhat.com)
- Search: Adds search on sliding tree to bbq. (ehelms@redhat.com)
- Add missing Copyright headers. (bbuckingham@redhat.com)
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
- Added permission to list the readable repositories in an environment
  (paji@redhat.com)
- corrected wrong method to shift over text which resulted in odd looking
  mouse-over effects (thomasmckay@redhat.com)
- fixing ordering for systems (jsherril@redhat.com)
- Bug 759609, 765991 - Verbs do not appear when selecting Permission For All
  https://bugzilla.redhat.com/show_bug.cgi?id=759609
  https://bugzilla.redhat.com/show_bug.cgi?id=765991   + The existing
  description of what "+ All" means was not being displayed properly. This has
  been corrected.   + TODO: There are likely larger workflow issues surrounding
  this part of the UI that need attention. (thomasmckay@redhat.com)
- converting to not use a generic katello index for each model and fixing sort
  on systems and provider (jsherril@redhat.com)
- Bug 761710 - Registration fails if Organization has multiple environments
  https://bugzilla.redhat.com/show_bug.cgi?id=761710   + Comment from code...
  # Some subscription-managers will call /users/$user/owners to retrieve the
  orgs that a user belongs to.       # Then, If there is just one org, that
  will be passed to the POST /api/consumers as the owner. To handle       #
  this scenario, if the org passed in matches the user's default org, use the
  default env. If not use       # the single env of the org or throw an error
  if more than one. (thomasmckay@redhat.com)
- removing sqlite default configuration from katello.yml (lzap+git@redhat.com)
- adding debug options to the katello.yml (lzap+git@redhat.com)
- Merge branch 'master' into search (mmccune@redhat.com)
- 768191 - adding elasticsearch to our specfile (mmccune@redhat.com)
- Bug 731993 - System name is overlapping on "LASTCHECKIN" text in left pane of
  Systems list https://bugzilla.redhat.com/show_bug.cgi?id=731993 + Added
  ellipsis to name + Also added system status color icon, shortened height of
  rows, and changed the data displayed to OS, ARCH, and IP. (Note that this
  list of systems is due for an overhaul so the changes are cosmetic for the
  short term until that happens.) (thomasmckay@redhat.com)
- + Bug 749795 - new system button should be hidden for non-edit users
  https://bugzilla.redhat.com/show_bug.cgi?id=749795   Both the "New System"
  and "Remove System" now honor permissions and   are only displayed when
  appropriate. (thomasmckay@redhat.com)
- More updates to the event history page.. (paji@redhat.com)
- test (jsherril@redhat.com)
- test (jsherril@redhat.com)
- adding initial system searching (jsherril@redhat.com)
- product/repo saving for providers (jsherril@redhat.com)
- Automatic commit of package [katello] release [0.1.145-1].
  (tstrachota@redhat.com)
- adding provider searching (jsherril@redhat.com)
- 767271 - logging for delayed jobs enabled in all environments
  (tstrachota@redhat.com)
- Refactors single javascript include from tupane_layout to reduce number of
  network calls when loading tupane data. (ehelms@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (mmccune@redhat.com)
- 767812 - compress our javascript and CSS (mmccune@redhat.com)
- fenced env_select.env_changed_callback when creating new user and choosing
  default org (thomasmckay@redhat.com)
- Updated system events page to be more inline with the mock and also added
  some magic in SystemTask to DRY out the js (paji@redhat.com)
- Updated the javascript routes so that ignores /api routes (paji@redhat.com)
- Updated jsroutes to ignore /api urls, since reducing the number of urls
  callable from java script would help with perf and api calls are very rarely
  used. (paji@redhat.com)
- Automatic commit of package [katello] release [0.1.144-1].
  (inecas@redhat.com)
- 753804 - fix for duplicite product name exception (inecas@redhat.com)
- 741656 - fix query on resource type for search (bbuckingham@redhat.com)
- fixing typos in the seeds script (lzap+git@redhat.com)
- Automatic commit of package [katello] release [0.1.143-1].
  (shughes@redhat.com)
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
- Fixed a magic arrow addition error in the fourth level menu (paji@redhat.com)
- system packages - minor change to status text (bbuckingham@redhat.com)
- Automatic commit of package [katello] release [0.1.142-1].
  (inecas@redhat.com)
- System Errata: Adds outstanding and applied errata filtering.
  (ehelms@redhat.com)
- Adds a header under the subnav in tupane. (ehelms@redhat.com)
- Fix db:seed script not being able to create admin user (inecas@redhat.com)
- 753804 - handling marketing products (inecas@redhat.com)
- Fix handling of 404 from Pulp repositories API (inecas@redhat.com)
- committing czech rails locales (lzap+git@redhat.com)
- controller support for indexed (jsherril@redhat.com)
- Automatic commit of package [katello] release [0.1.141-1].
  (lzap+git@redhat.com)
- marking all katello packages as noarch again (lzap+git@redhat.com)
- 766933 - katello.yml is world readable including db uname/password
  (lzap+git@redhat.com)
- 766939 - security_token.rb should be regenerated on each install
  (lzap+git@redhat.com)
- making seed script idempotent (lzap+git@redhat.com)
- Automatic commit of package [katello] release [0.1.140-1].
  (inecas@redhat.com)
- reimport-manifest - save content into repo groupid on import
  (inecas@redhat.com)
- Automatic commit of package [katello] release [0.1.139-1].
  (tstrachota@redhat.com)
- async tasks - raising exception when a task fails while waiting until it
  finishes (tstrachota@redhat.com)
- Squashed commit of the following: (jrist@redhat.com)
- Very minor change for border missing on some ui-widget-content items.
  (jrist@redhat.com)
- Minor tweak to the event history view to show an event task list
  (paji@redhat.com)
- details status for system events (shughes@redhat.com)
- subpanel logic for system event details (shughes@redhat.com)
- system packages - do not show checkboxes to read-only user
  (bbuckingham@redhat.com)
- system packages - i18n 'no pkgs' text, do not display footer when there are
  no pkgs (bbuckingham@redhat.com)
- system packages - generate validation error if action already in progress
  (bbuckingham@redhat.com)
- Added skeletons for system event js (paji@redhat.com)
- System Packages: Removes validation associated with package group.
  (ehelms@redhat.com)
- System PackageS: Adds server side validation of user entered packages list
  format and package names based on Fedora guidelines. (ehelms@redhat.com)
- System Packages: Adds client side validation of user entered packages format.
  (ehelms@redhat.com)
- system packages - rspecs for ui controller on pkg actions
  (bbuckingham@redhat.com)
- 758620 - promotion - fix ability to promote a distro (bbuckingham@redhat.com)
- db call for system event details (shughes@redhat.com)
- Automatic commit of package [katello] release [0.1.138-1].
  (lzap+git@redhat.com)
- 760290 - read only role has now permissions (lzap+git@redhat.com)
- Automatic commit of package [katello] release [0.1.137-1].
  (tstrachota@redhat.com)
- product api - fix for permission problem when listing repos Api was returning
  permission exception when all product repositories were disabled.
  (tstrachota@redhat.com)
- sync api - spec test for not cancelling objects that aren't being
  synchronized (tstrachota@redhat.com)
- sync api - correct message when cancel is called on object that is not being
  synced (tstrachota@redhat.com)
- Added a spec controller for system events page (paji@redhat.com)
- Forgot to add a file in the previous commit (paji@redhat.com)
- Made the Task status table always hold a user, needed for auditing purposes
  (paji@redhat.com)
- Quick fix to ensure that its always the events page that shows up for systems
  (paji@redhat.com)
- fixed merge issues (paji@redhat.com)
- Updates on the landing page for system events (paji@redhat.com)
- Added code to enable rules on thrid level nav (paji@redhat.com)
- placeholder for event details (shughes@redhat.com)
- search - initial full text search additions (jsherril@redhat.com)
- Gemfile Update - adding Tire to gemfile (jsherril@redhat.com)
- Initial commit related to System Event pages (paji@redhat.com)
- Automatic commit of package [katello] release [0.1.136-1].
  (inecas@redhat.com)
- 758219 - make labels for custom content unique (inecas@redhat.com)
- spec test fix for create system (TODO: add default env tests)
  (thomasmckay@redhat.com)
- Merge branch 'master' into BZ-761726 (thomasmckay@redhat.com)
- BZ-761710 (thomasmckay@redhat.com)
- fixed another rescue handler (thomasmckay@redhat.com)
- Automatic commit of package [katello] release [0.1.135-1].
  (thomasmckay@redhat.com)
- fix css issues with some ellipsis (shughes@redhat.com)
- Automatic commit of package [katello] release [0.1.134-1].
  (thomasmckay@redhat.com)
- Automatic commit of package [katello] release [0.1.133-1].
  (mmccune@redhat.com)
- System Navigation: Changes individual system subnav to have nested details
  drop down menu. (ehelms@redhat.com)
- Merge branch 'master' into sys-packages (bbuckingham@redhat.com)
- packages - update so that loading System->Packages shows actions in progress
  (bbuckingham@redhat.com)
- Automatic commit of package [katello] release [0.1.132-1].
  (inecas@redhat.com)
- reimport-manifest - don't delete untracked products when importing
  (inecas@redhat.com)
- reimport-manifest - don't manipulate CP content on promotion
  (inecas@redhat.com)
- reimport-manifest - repos relative paths conform with content url
  (inecas@redhat.com)
- reimport-manifest - support for force option while manifest import
  (inecas@redhat.com)
- + Bug 754526 - Cannot unset a user's default env
  https://bugzilla.redhat.com/show_bug.cgi?id=754526   Choosing "No Default
  Organization" works now + Bug 754855 - User cannot change default system
  environment on their own   https://bugzilla.redhat.com/show_bug.cgi?id=754855
  User editing own account now allows editing of default env + Bug 760563 -
  User cannot see their roles & permissions
  https://bugzilla.redhat.com/show_bug.cgi?id=760563   User editing their own
  account can see (but not modify) their roles + Bug 760635 - Creating new user
  with "No Default Organization" is awkward/broken.
  https://bugzilla.redhat.com/show_bug.cgi?id=760635   Save button on
  Environments tab now properly enables/disables based upon   current choice
  vs. current default. (thomasmckay@redhat.com)
- finished (thomasmckay@redhat.com)
- user link working (thomasmckay@redhat.com)
- correctly limiting results and opening it in right pane
  (thomasmckay@redhat.com)
- id and only flags used in users query (thomasmckay@redhat.com)
- twiddling bits (thomasmckay@redhat.com)
- Merge branch 'master' into sys-packages (bbuckingham@redhat.com)
- puppet - removing unnecessary sysvinit initdb (lzap+git@redhat.com)
- puppet - renaming initdb_done to db_seed_done (lzap+git@redhat.com)
- Automatic commit of package [katello] release [0.1.131-1].
  (tstrachota@redhat.com)
- activation keys - spec test for creating activation keys in Locker env
  (tstrachota@redhat.com)
- 755919 - validation in activation key model, can't be created for Locker env
  (tstrachota@redhat.com)
- packages - update so that status polling is only done when needed
  (bbuckingham@redhat.com)
- Merge branch 'master' into sys-packages (mmccune@redhat.com)
- packages - ui fixes - disable links while scheduling action...etc
  (bbuckingham@redhat.com)
- System Errata: Changes to API call to retrieve errata available to a system.
  (ehelms@redhat.com)
- System Errata: Adds load more functionality to view. (ehelms@redhat.com)
- System Errata: Adds select all checkbox in the errata table.
  (ehelms@redhat.com)
- System Errata: Adds filtering of system errata by type. (ehelms@redhat.com)
- System Errata: Adds index and items actions with fake errata data population.
  (ehelms@redhat.com)
- System Errata: Adds the rest of the view skeleton, fake controller data and
  helpers for the view. (ehelms@redhat.com)
- Adds import of _icons.scss and moves errata icons from dashboard to icons
  scss file. (ehelms@redhat.com)
- Intoduces icons.scss to hold css class definitions for icons.  This is in
  contrast to _sprites.scss which is used to define the location of an icon or
  image within a sprite file. (ehelms@redhat.com)
- System Errata: Adds initial view for system errata. (ehelms@redhat.com)
- System Errata: Add initial routes and navigation for system errata.
  (ehelms@redhat.com)
- Automatic commit of package [katello] release [0.1.130-1].
  (shughes@redhat.com)
- bump version to fix tags (shughes@redhat.com)
- Automatic commit of package [katello] release [0.1.129-1].
  (shughes@redhat.com)
- packages - enhance add/remove pkg/groups behavior (bbuckingham@redhat.com)
- user roles - spec test for roles api (tstrachota@redhat.com)
- user roles - new api controller (tstrachota@redhat.com)
- fix long name breadcrumb trails in roles (shughes@redhat.com)
- Fix for jrist being an idiot and putting in some bad code.`
  (jrist@redhat.com)
- Automatic commit of package [katello] release [0.1.128-1].
  (mmccune@redhat.com)
- Revert "Revert "759533 - proper path for distributions"" (mmccune@redhat.com)
- 754670 - updated API paths (mmccune@redhat.com)
- packages - ui changes to show status changes on package actions
  (bbuckingham@redhat.com)
- routes.js - update (bbuckingham@redhat.com)
- Refactored a little to get the model a little cleaner (paji@redhat.com)
- Automatic commit of package [katello] release [0.1.127-1].
  (thomasmckay@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (pkilambi@localhost.localdomain)
- 753132 - fixing the synchronize now disable button logic. Instead of
  disabling the button based on the click shuges suggestion remove the disable
  logic and keep the button active (pkilambi@localhost.localdomain)
- Automatic commit of package [katello] release [0.1.126-1].
  (shughes@redhat.com)
- break out branding from app controller (shughes@redhat.com)
- task model - minor changes for package/group status (bbuckingham@redhat.com)
- Automatic commit of package [katello] release [0.1.125-1].
  (lzap+git@redhat.com)
- Revert "759533 - proper path for distributions" (lzap+git@redhat.com)
- packages - update ui to show that action is in progress on pkg or group
  (bbuckingham@redhat.com)
- Automatic commit of package [katello] release [0.1.124-1].
  (tstrachota@redhat.com)
- spec tests - test for the new changeset content controller
  (tstrachota@redhat.com)
- changesets api - parameter 'name' for adding errata renamed to 'erratum_id'
  (tstrachota@redhat.com)
- spec tests - fixes in tests for changeset model and api controller
  (tstrachota@redhat.com)
- changeset cli - reflects new api (tstrachota@redhat.com)
- environments - added field 'parent_id' to json exports
  (tstrachota@redhat.com)
- changesets - new controller for changeset content (tstrachota@redhat.com)
- distribution promotion - displaying distribution list in changeset info
  (tstrachota@redhat.com)
- distribution promotion - update changeset api controller for adding
  distributions (tstrachota@redhat.com)
- Initial commit of the Status model update. (paji@redhat.com)
- 758710 - taking out the version check.  People ignore it (mmccune@redhat.com)
- Org debug certificate turndown thingy :) (jrist@redhat.com)
- ellipsis support for promoted repos, products and errata (shughes@redhat.com)
- adding ellipsis to promotion system templates (shughes@redhat.com)
- add padding for link details ellipsis (shughes@redhat.com)
- + Bug 749537 - Unhandled or improperly handled exception, Name has already
  been taken   https://bugzilla.redhat.com/show_bug.cgi?id=749537   Return json
  for subscription-manager, including for failed authentication
  (thomasmckay@redhat.com)
- packages - example of how model might be used... (bbuckingham@redhat.com)
- packages - initial placeholder for retrieving status of pending actions
  (bbuckingham@redhat.com)
- Automatic commit of package [katello] release [0.1.123-1].
  (mmccune@redhat.com)
- 759533 - proper path for distributions (mmccune@redhat.com)
- Small refactor on the loading of debu cert based of lzap's suggestion
  (paji@redhat.com)
- Merge branch 'master' into sys-packages (bbuckingham@redhat.com)
- + Bug 759552 - dashboard subscriptions portlet does not show hand-made
  systems   https://bugzilla.redhat.com/show_bug.cgi?id=759552   Systems that
  are hand-created (eg. through "New System" button) are by definition green.
  To account for this, simply take the total count and subtract the red and
  yellow counts. (thomasmckay@redhat.com)
- + Bug 752057 - mutli-entitle chooser in system/subscriptions has double
  spinner   https://bugzilla.redhat.com/show_bug.cgi?id=752057   Changed
  number_field_tag to text_field_tag to avoid double spinners appearing   on
  chrome browser. + Minor clean up to subscription tables when none present
  (thomasmckay@redhat.com)
- Automatic commit of package [katello] release [0.1.122-1].
  (lzap+git@redhat.com)
- adding 4th column to the list_permissions (lzap+git@redhat.com)
- adding rake list_permissions task (lzap+git@redhat.com)
- Automatic commit of package [katello] release [0.1.121-1].
  (thomasmckay@redhat.com)
- uebercerts - fixing unit test (lzap+git@redhat.com)
- generate_uebercert -> ubercert in the cli (lzap+git@redhat.com)
- Added code to allow one to download debug certificates from the UI . Aka
  ueber certificates (paji@redhat.com)
- + Bug 747980 - In Katello / Headpin Web UI MachineType is not displayed under
  Current Subscriptions   https://bugzilla.redhat.com/show_bug.cgi?id=747980
  Machine Type column added to both Red Hat Providers and Organization /
  Subscriptions. Will display Virtual, Physical, or blank (for any). + Added
  Contract, Support Level, Arch, Begins, and Expires columns to Red Hat
  Providers to match Organization / Subscriptions + Removed non-functional
  Trend column from Organization / Subscriptions + Bug 756159 - After
  subscribing to RH product, ui shows duplicate product with "0 of -1" consumed
  https://bugzilla.redhat.com/show_bug.cgi?id=756159   Changed -1 to Unlimited
  in Red Hat Providers and Organization / Subscriptions
  (thomasmckay@redhat.com)
- Automatic commit of package [katello] release [0.1.120-1].
  (mmccune@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (mmccune@redhat.com)
- removing console.log that breaks Firefox 3.6 (mmccune@redhat.com)
- Bug 759246 - system general tab list of guest systems on host can be too long
  https://bugzilla.redhat.com/show_bug.cgi?id=759246 + Moved Guest & Host info
  to bottom of system/general tab to allow the list of hosts to grow to any
  length w/o impacting visibility of other info (thomasmckay@redhat.com)
- Bug 754955 - #<AbstractController::DoubleRenderError: while registering a
  system from UI https://bugzilla.redhat.com/show_bug.cgi?id=754955 + was an
  extra call to 'render' being hit in flow of SystemsController#create
  (thomasmckay@redhat.com)
- BZ#758439 https://bugzilla.redhat.com/show_bug.cgi?id=758439 + Dashboard
  widget now reflects the proper number of systems: Red=false/invalid,
  Yellow=partial, Green=true/valid + Corrected logic in determining overall
  color of an individual system on System/Subscription tab + Corrected logic in
  determining color of installed products on System/Software tab
  (thomasmckay@redhat.com)
- Automatic commit of package [katello] release [0.1.119-1].
  (thomasmckay@redhat.com)
- Merge branch 'org-async' (jsherril@redhat.com)
- fix permissions js to handle long names (shughes@redhat.com)
- changing api to use async org deletion and fixing unit tests
  (jsherril@redhat.com)
- add support for ellipsis on org tab (shughes@redhat.com)
- Automatic commit of package [katello] release [0.1.118-1].
  (mmccune@redhat.com)
- org-deletion - making the org page not show in-progress orgs being deleted
  (jsherril@redhat.com)
- Merge branch 'master' into org-history (thomasmckay@redhat.com)
- working version of org history (thomasmckay@redhat.com)
- org deletion - making sure org delayed job is not attached to object being
  deleted (jsherril@redhat.com)
- putting the border around progress bar back in (shughes@redhat.com)
- Merge branch 'master' into org-history (thomasmckay@redhat.com)
- crude events (limited to 50 displayed) (thomasmckay@redhat.com)
- i18n - extracting strings (lzap+git@redhat.com)
- i18n - errors (lzap+git@redhat.com)
- i18n - system template (lzap+git@redhat.com)
- adding commented URL to the Gemfile (lzap+git@redhat.com)
- 757913 - remove ellipsys support for this page.  unecessary
  (mmccune@el6.pdx.redhat.com)
- org events tab ready to be populated (thomasmckay@redhat.com)
- argh! found and removed explicit call to navigation in controller
  (thomasmckay@redhat.com)
- changed back to :general (thomasmckay@redhat.com)
- trying (and failing) to get navigation working for orgs
  (thomasmckay@redhat.com)
- making org deletion asyncronous (jsherril@redhat.com)
- Automatic commit of package [katello] release [0.1.117-1].
  (shughes@redhat.com)
- fix user tab so editable fields wrap (shughes@redhat.com)
- packages - model - some changes to support actions (bbuckingham@redhat.com)
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
- Automatic commit of package [katello] release [0.1.116-1].
  (lzap+git@redhat.com)
- adding template to the system info cli call (lzap+git@redhat.com)
- more info when RecordInvalid is thrown (lzap+git@redhat.com)
- Org Deletion - ensuring things are cleaned up properly during org deletion
  (jsherril@redhat.com)
- GPG Keys: Adds gpg key helptip. (ehelms@redhat.com)
- Merge branch 'master' into gpg (ehelms@redhat.com)
- GPG Keys: Adds uploading gpg key during edit and attempts to fix issues with
  Firefox and gpg key ajax upload. (ehelms@redhat.com)
- GPG key: Adds uploading key on creating new key from the UI.
  (ehelms@redhat.com)
- GPG Keys: Adds dialog for setting GPG key of product for all underlying
  repositories. (ehelms@redhat.com)
- Routing error page doesn't need user credentials (inecas@redhat.com)
- Automatic commit of package [katello] release [0.1.115-1].
  (lzap+git@redhat.com)
- tdl validations - backend and cli (lzap+git@redhat.com)
- tdl validation - model code (lzap+git@redhat.com)
- Automatic commit of package [katello] release [0.1.114-1].
  (lzap+git@redhat.com)
- Revert "Automatic commit of package [katello] release [0.1.114-1]."
  (lzap+git@redhat.com)
- Automatic commit of package [katello] release [0.1.114-1].
  (lzap+git@redhat.com)
- 757094 - use arel structure instead of the array for repos
  (inecas@redhat.com)
- Automatic commit of package [katello] release [0.1.113-1].
  (lzap+git@redhat.com)
- fixing typo (space) (lzap+git@redhat.com)
- 755730 - exported RHEL templates mapping (lzap+git@redhat.com)
- rh providers - restriction in adding products to rh providers via api
  (tstrachota@redhat.com)
- bug - better error message when making unauthetincated call
  (lzap+git@redhat.com)
- repo block - fixes in spec tests (tstrachota@redhat.com)
- repo blacklist - flag for displaying enabled repos via api
  (tstrachota@redhat.com)
- repo blacklist - product api lists always all products
  (tstrachota@redhat.com)
- repo blacklist - flag for displaying disabled products via api
  (tstrachota@redhat.com)
- repo blacklist - enable api blocked for custom repositories
  (tstrachota@redhat.com)
- repo blacklist - api for enabling/disabling repos (tstrachota@redhat.com)
- packages - add support for package update and update all packages
  (bbuckingham@redhat.com)
- packages - make pkg/group install/remove scheduling actions synchronous
  (bbuckingham@redhat.com)
- password_reset - fix i18n for emails (bbuckingham@redhat.com)
- changing some translation strings upon request (lzap+git@redhat.com)
- Automatic commit of package [katello] release [0.1.112-1].
  (lzap+git@redhat.com)
- fixed failing spec tests all caused by new parameter in
  Candlepin::Consumer#update (tstrachota@redhat.com)
- template export - spec tests for disabled export form a Locker
  (tstrachota@redhat.com)
- template export - disabled exporting templates from Locker envs
  (tstrachota@redhat.com)
- Added some gpg key controller tests (paji@redhat.com)
- added some unit tests to deal with gpg keys (paji@redhat.com)
- Merge branch 'master' into sys-autoheal (thomasmckay@redhat.com)
- moved auto-heal down next to current subs (thomasmckay@redhat.com)
- packages - more updates based on new mockup (bbuckingham@redhat.com)
- packages - updates to ui based on new mockup (bbuckingham@redhat.com)
- routes - update for system_packages_controller (bbuckingham@redhat.com)
- packages - update the UI controller to use backend APIs for pkg/group
  install/uninstall (bbuckingham@redhat.com)
- packages - backend changes to support package and package group
  install/uninstall (bbuckingham@redhat.com)
- Automatic commit of package [katello] release [0.1.110-1].
  (shughes@redhat.com)
- Revert "fix sync disabled submit button to not sync when disabled"
  (shughes@redhat.com)
- 747032 - Fixed a bugby error in the dashboard whenever you had more than one
  synced products (paji@redhat.com)
- Automatic commit of package [katello] release [0.1.109-1].
  (shughes@redhat.com)
- fix sync disabled submit button to not sync when disabled
  (shughes@redhat.com)
- 754215 - Small temporary fix for max height on CS Trees. (jrist@redhat.com)
- Automatic commit of package [katello] release [0.1.108-1].
  (shughes@swarm.(none))
- Pie chart updates now functions with actual data. (jrist@redhat.com)
- Fix for pie chart on dashboard page. (jrist@redhat.com)
- Fixed a permission check to only load syncplans belonging to a specific org
  as opposed to syncplnas belongign to all org (paji@redhat.com)
- Automatic commit of package [katello] release [0.1.107-1].
  (shughes@redhat.com)
- removing duplicated method (jsherril@redhat.com)
- incorporate redhat-logos rpm for system engine installs (shughes@redhat.com)
- 754442 - handle error status codes from CDN (inecas@redhat.com)
- 754207 - fixing issue where badly formed cdn_proxy would throw a non-sensical
  error, and we would attempt to parse a nil host (jsherril@redhat.com)
- minor verbage change to label: Host Type to System Type
  (thomasmckay@redhat.com)
- Automatic commit of package [katello] release [0.1.106-1].
  (bbuckingham@redhat.com)
- async job - fix for broken promotions (bbuckingham@redhat.com)
- Automatic commit of package [katello] release [0.1.105-1].
  (lzap+git@redhat.com)
- 754430 - Product promotion fails as katello-jobs doesn't start
  (lzap+git@redhat.com)
- system templates - adding support for adding a distribution to a system
  template in the ui (jsherril@redhat.com)
- added compliant until date (thomasmckay@redhat.com)
- display a system's subscription status and colored icon
  (thomasmckay@redhat.com)
- display dashboard system status (thomasmckay@redhat.com)
- system templates - fixing issue where distributions were not browsable on a
  newly created template without refreshing (jsherril@redhat.com)
- Moved the super admin method to authorization_helper_methods.rb from
  login_helper_methods.rb for more consistency (paji@redhat.com)
- Added a reset_repo_gpgs method to reset the gpg keys of the sub product
  (paji@redhat.com)
- GPG Keys: Adds UI code to check for setting all underlying repositories with
  products GPG key on edit. (ehelms@redhat.com)
- GPG Keys: Adds view, action and route for viewing the products and
  repositories a GPG key is associated with from the details pane of a key.
  (ehelms@redhat.com)
- GPG Key: Adds key association to products on create and update views.
  (ehelms@redhat.com)
- GPG Key: Adds association of GPG key when creating repository.
  (ehelms@redhat.com)
- GPG Key: Adds ability to edit a repository and change the GPG key.
  (ehelms@redhat.com)
- Automatic commit of package [katello] release [0.1.111-1].
  (shughes@redhat.com)
- Added some methods to do permission checks on repos (paji@redhat.com)
- Added some methods to do permission checks on products (paji@redhat.com)
- 755048 - handle multiple ks trees for a template (inecas@redhat.com)
- Automatic commit of package [katello] release [0.1.110-1].
  (shughes@redhat.com)
- Revert "fix sync disabled submit button to not sync when disabled"
  (shughes@redhat.com)
- 747032 - Fixed a bugby error in the dashboard whenever you had more than one
  synced products (paji@redhat.com)
- GPG keys: Modifies edit box for pasting key and removes upload.
  (ehelms@redhat.com)
- Automatic commit of package [katello] release [0.1.109-1].
  (shughes@redhat.com)
- GPG keys: Adds edit support for name and pasted gpg key. (ehelms@redhat.com)
- Adding products and repositories helpers (paji@redhat.com)
- GPG Keys: Adds functional GPG new key view. (ehelms@redhat.com)
- fix sync disabled submit button to not sync when disabled
  (shughes@redhat.com)
- GPG Keys: Adds update to controller. (ehelms@redhat.com)
- 754215 - Small temporary fix for max height on CS Trees. (jrist@redhat.com)
- Added code for repo controller to accept gpg (paji@redhat.com)
- Updated some controller methods to deal with associating gpg keys on
  products/repos (paji@redhat.com)
- Automatic commit of package [katello] release [0.1.108-1].
  (shughes@swarm.(none))
- positioned auto-heal button; comment-removed the Socket and Guest Requirement
  (since were hard-code data populated) (thomasmckay@redhat.com)
- fixed missing call to 'render' at end of #update (thomasmckay@redhat.com)
- use PUT instead of POST (thomasmckay@redhat.com)
- Pie chart updates now functions with actual data. (jrist@redhat.com)
- Fix for pie chart on dashboard page. (jrist@redhat.com)
- autoheal checkbox on system; toggling not working (thomasmckay@redhat.com)
- Added a menu entry for the GPG stuff (paji@redhat.com)
- GPG Keys: Updated jsroutes for GPG keys. (ehelms@redhat.com)
- GPG Keys: Fixes for create with permissions. (ehelms@redhat.com)
- GPG Keys: Adds create controller actions to handle both pasted GPG keys and
  uploaded GPG keys. (ehelms@redhat.com)
- GPG Keys: Adds code for handling non-CRUD controller actions.
  (ehelms@redhat.com)
- GPG Keys: Adds basic routes. (ehelms@redhat.com)
- GPG Keys: Adds javascript scaffolding and activation of 2pane AJAX for GPG
  Keys. (ehelms@redhat.com)
- GPG Keys: Initial view scaffolding. (ehelms@redhat.com)
- GPG Keys: Fixes issues with Rails naming conventions. (ehelms@redhat.com)
- GPG Keys: Adds basic controller and helper shell. Adds suite of unit tests
  for TDD. (ehelms@redhat.com)
- Fixed a permission check to only load syncplans belonging to a specific org
  as opposed to syncplnas belongign to all org (paji@redhat.com)
- Added some permission checking, scoped and searching on names
  (paji@redhat.com)
- Automatic commit of package [katello] release [0.1.107-1].
  (shughes@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (jsherril@redhat.com)
- removing duplicated method (jsherril@redhat.com)
- incorporate redhat-logos rpm for system engine installs (shughes@redhat.com)
- Adding a product association to gpg keys (paji@redhat.com)
- 754442 - handle error status codes from CDN (inecas@redhat.com)
- 754207 - fixing issue where badly formed cdn_proxy would throw a non-sensical
  error, and we would attempt to parse a nil host (jsherril@redhat.com)
- Renamed Gpg to GpgKey (paji@redhat.com)
- Merge branch 'master' into sys-status (thomasmckay@redhat.com)
- minor verbage change to label: Host Type to System Type
  (thomasmckay@redhat.com)
- Automatic commit of package [katello] release [0.1.106-1].
  (bbuckingham@redhat.com)
- async job - fix for broken promotions (bbuckingham@redhat.com)
- Automatic commit of package [katello] release [0.1.105-1].
  (lzap+git@redhat.com)
- 754430 - Product promotion fails as katello-jobs doesn't start
  (lzap+git@redhat.com)
- system templates - adding support for adding a distribution to a system
  template in the ui (jsherril@redhat.com)
- Merge branch 'master' into sys-packages (bbuckingham@redhat.com)
- Initial commit of the Gpg Model mappings + Migration scripts
  (paji@redhat.com)
- Fixed a unit test failure (paji@redhat.com)
- Small fix to get the redhat enablement working in FF 3.6 (paji@redhat.com)
- Fix to make the product.readable call only  out RH products that do not have
  any repositories enabled (paji@redhat.com)
- Added a message asking the user to enable repos after manifest was uploaded
  (paji@redhat.com)
- 751407 - root_controller doesn't require user authorization
  (tstrachota@redhat.com)
- Merge branch 'master' into sys-status (thomasmckay@redhat.com)
- Merge branch 'master' into sync-improve (paji@redhat.com)
- Made Product.readable call now adhere to  repo enablement constructs
  (paji@redhat.com)
- Small fix to improve the permission debug message (paji@redhat.com)
- Merge branch 'master' into sys-status (thomasmckay@redhat.com)
- bug - RAILS_ENV was ignored for thin (lzap+git@redhat.com)
- Automatic commit of package [katello] release [0.1.104-1].
  (shughes@redhat.com)
- Reverting look.scss to previous contents. (jrist@redhat.com)
- tdl-repos - use repo name for name attribute (inecas@redhat.com)
- Merge branch 'master' into password_reset (bbuckingham@redhat.com)
- password reset - add server to logins email, ignore errors on requests for
  email (bbuckingham@redhat.com)
- cdn-proxy - accept url as well as host for cdn proxy (inecas@redhat.com)
- cdn-proxy - let proxy to be configured when calling CDN (inecas@redhat.com)
- Merge branch 'master' into sys-status (thomasmckay@redhat.com)
- added compliant until date (thomasmckay@redhat.com)
- 752863 - katello service will return "OK" on error (lzap+git@redhat.com)
- Rename of look.scss to _look.scss to reflect the fact that it's an import.
  Fixed the text-shadow deprecation error we were seeing on compass compile.
  (jrist@redhat.com)
- Automatic commit of package [katello] release [0.1.103-1].
  (shughes@redhat.com)
- fix up branding file pulls (shughes@redhat.com)
- display a system's subscription status and colored icon
  (thomasmckay@redhat.com)
- user edit - add 'save' text to form... lost in merge (bbuckingham@redhat.com)
- Merge branch 'master' into password_reset (bbuckingham@redhat.com)
- Small fix to import_history, changes to styling for tabs on rh providers
  page. (jrist@redhat.com)
- Merge branch 'master' into sys-status (thomasmckay@redhat.com)
- Moving the upload top right. (jrist@redhat.com)
- rescue exceptions retrieving a system's guests and host
  (thomasmckay@redhat.com)
- 750120 - search - fix error on org search (bbuckingham@redhat.com)
- display dashboard system status (thomasmckay@redhat.com)
- scoped_search - updating to gem version 2.3.6 (bbuckingham@redhat.com)
- fix brand processing of source files (shughes@redhat.com)
- Automatic commit of package [katello] release [0.1.102-1].
  (lzap+git@redhat.com)
- 753329 - distros - fix to support distros containing space in the id
  (bbuckingham@redhat.com)
- Merge branch 'master' into sys-host-guest (thomasmckay@redhat.com)
- TODO: Unsure how to test this after making :host, :guests use lazy_accessor
  (thomasmckay@redhat.com)
- 749258 - new state 'failed' for changesets (tstrachota@redhat.com)
- Merge branch 'master' into sys-host-guest (thomasmckay@redhat.com)
- fixed save button on edit user password (thomasmckay@redhat.com)
- guests of a host cleanly displayed (thomasmckay@redhat.com)
- adding rootpw tag to the TDL export (lzap+git@redhat.com)
- packages - comment out portions initially unsupported
  (bbuckingham@redhat.com)
- Merge branch 'master' into sys-host-guest (thomasmckay@redhat.com)
- Merge branch 'master' into optional-orgenv (thomasmckay@redhat.com)
- corrected test for creating user w/o env (thomasmckay@redhat.com)
- manifest import - fixes in orchestration - content remained created in locker
  env - fixed infinite recursive call of set_repos (tstrachota@redhat.com)
- packages - enable/disable buttons based on status of checkboxes
  (bbuckingham@redhat.com)
- packages - add the table filter back in... (bbuckingham@redhat.com)
- + both new user and modifying a user's environment now work + TODO: probably
  need to wordsmith form labels (thomasmckay@redhat.com)
- packages - minor changes to get sort/more working with new layout
  (bbuckingham@redhat.com)
- packages - add package groups to the UI (bbuckingham@redhat.com)
- Moved the redhat provider haml to a more appropriate location
  (paji@redhat.com)
- user#create updated for optional default env (thomasmckay@redhat.com)
- + don't require an initial environment for new org + new user default org/env
  choice box allows none (controller not updated yet) (thomasmckay@redhat.com)
- Updated some permissions on the redhat providers page (paji@redhat.com)
- Update to get the redhat providers repo enablement code to work.
  (paji@redhat.com)
- color shade products for sync status (shughes@redhat.com)
- installed-products - API supports consumer installedProducts
  (inecas@redhat.com)
- adding migration for removal of releaes version (jsherril@redhat.com)
- sync management - making sync page use major/minor versions that was added
  (jsherril@redhat.com)
- clean up of branch merge defaultorgenv (thomasmckay@redhat.com)
- correctly pass default env during user create and update
  (thomasmckay@redhat.com)
- comment and whitespace cleanup (thomasmckay@redhat.com)
- updated rspec tests for new default org and environment
  (thomasmckay@redhat.com)
- minor clean-up (thomasmckay@redhat.com)
- Security enhancements for default org and environment (tsmart@redhat.com)
- Updating KAtello to work with older subscription managers (5.7) that expect
  displayMessage in the return JSON (tsmart@redhat.com)
- User environment edit page no longer clicks a link in order to refresh the
  page after a successful update, but rather fills in the new data via AJAX
  (tsmart@redhat.com)
- Fixing a display message when creating an organization (tsmart@redhat.com)
- Not allowing a superadmin to create a user if the org does not ahave any
  environments from which to choose (tsmart@redhat.com)
- Now older subscription managers can register against Katello without
  providing an org or environment (tsmart@redhat.com)
- You can now change the default environment for a user on the
  Administration/Users/Environments tab (tsmart@redhat.com)
- updating config file secret (tsmart@redhat.com)
- Adding missing file (tsmart@redhat.com)
- Middle of ajax environments_partial call (tsmart@redhat.com)
- Moved the user new JS to the callback in user.js instead of a separate file
  for easier debugging. (tsmart@redhat.com)
- Saving a default permission whever a new user is created, although the
  details will likely change (tsmart@redhat.com)
- packages - ui - chgs to allow request to add packages and more
  (bbuckingham@redhat.com)
- Now when you create an org you MUST specify a default environment. If you do
  not the org you created will be destroyed and you will be given proper error
  messages. I added a feature to pass a prepend string to the error in case
  there are two items you are trying to create on the page. It would have been
  easier to just prepend it at the time of message creation, but that would
  have affected every page. Perhaps we can revisit this in the future
  (tsmart@redhat.com)
- In the middle of stuff (tsmart@redhat.com)
- Merge branch 'master' into sync-improve (jsherril@redhat.com)
- sync mangement - getting rid of major version (jsherril@redhat.com)
- begin to display guests/host for a system (thomasmckay@redhat.com)
- sync management - fixing repository cancel (jsherril@redhat.com)
- packages - remove debugger statement from controller... oops... :(
  (bbuckingham@redhat.com)
- packages - ui chgs to send request on update/remove, add actions for each
  (bbuckingham@redhat.com)
- major-minor - fix down migration (inecas@redhat.com)
- major-minor - Parsing releasever and saving result to db (inecas@redhat.com)
- white-space (inecas@redhat.com)
- fixing repo spec tests (jsherril@redhat.com)
- Automatic commit of package [katello] release [0.1.101-1].
  (shughes@redhat.com)
- disable sync KBlimit (shughes@redhat.com)
- packages - updating structure of system_packages.js to use the var/return
  structure (bbuckingham@redhat.com)
- sync management - fixing button disabling (jsherril@redhat.com)
- sync management - fix for syncing multiple repos (jsherril@redhat.com)
- packages - pulling system package in to a separate system_packages_controller
  (bbuckingham@redhat.com)
- repos - orchestration fix, 'del_content' was not returning true when there
  was nothing to delete (tstrachota@redhat.com)
- 746339 - System Validates on the uniqueness of name (lzap+git@redhat.com)
- repos - orchestration fix, deleting a repo was not deleting the product
  content (tstrachota@redhat.com)
- Automatic commit of package [katello] release [0.1.100-1].
  (shughes@redhat.com)
- disable sync button if no repos are selected (shughes@redhat.com)
- packages - update view to begin to look like new mockup
  (bbuckingham@redhat.com)
- sync management - fixing cancel sync (jsherril@redhat.com)
- merge conflict (jsherril@redhat.com)
- virt-who - support host-guests systems relationship (inecas@redhat.com)
- virt-who - support uploading the guestIds to Candlepin (inecas@redhat.com)
- sync management - adding show only syncing button (jsherril@redhat.com)
- js cleanup for progress bars (shughes@redhat.com)
- sync api - fix for listing status of promoted repos A condition that ensures
  synchronization of repos only in the Locker was too restrictive and affected
  also other actions. (tstrachota@redhat.com)
- For now automatically including all the repos in the repos call
  (paji@redhat.com)
- Merge branch 'sync-improve' of ssh://git.fedorahosted.org/git/katello into
  sync-improve (paji@redhat.com)
- Initial commit on an updated repo data model to handle things like whitelists
  for rh (paji@redhat.com)
- password reset - updates from code inspection (bbuckingham@redhat.com)
- handle product status progress when 100 percent (shughes@redhat.com)
- smooth out repo progress bar for recent completed syncs (shughes@redhat.com)
- ubercharged progress bar for previous completed syncs (shughes@redhat.com)
- fix missing array return of pulp sync status (shughes@redhat.com)
- sync management - fixing repo progress and adding product progress
  (jsherril@redhat.com)
- Merge branch 'master' into password_reset (bbuckingham@redhat.com)
- 741961 - Removed traces of the anonymous user since he is no longer needed
  (paji@redhat.com)
- sync management - somre more fixes (jsherril@redhat.com)
- password reset - fixes for issues found in production install
  (bbuckingham@redhat.com)
- repo api - fix in spec tests for listing products (tstrachota@redhat.com)
- repos api - filtering by name in listing repos of a product
  (tstrachota@redhat.com)
- sync management - getting sync status showing up correct
  (jsherril@redhat.com)
- katello.spec - adding mailers to be included in rpm (bbuckingham@redhat.com)
- password reset - fix issue w/ redirect to login after reset
  (bbuckingham@redhat.com)
- Merge branch 'master' into repo-remodel (paji@redhat.com)
- fixing some merge issues (jsherril@redhat.com)
- installler - minor update to setting of email in seeds.rb
  (bbuckingham@redhat.com)
- Merge branch 'master' into password_reset (bbuckingham@redhat.com)
- API - add status route for api to return the current version
  (inecas@redhat.com)
- include treetable.js in custom providers (thomasmckay@redhat.com)
- user spec tests - fix for pulp orchestration (tstrachota@redhat.com)
- Updated Gemfile.lock (inecas@redhat.com)
- 751844 - Fix for max height on right_tree sliding_container.
  (jrist@redhat.com)
- password reset - adding specs for new controller (bbuckingham@redhat.com)
- Merge branch 'master' into repo-remodel (paji@redhat.com)
- support sync status 1-call to server (shughes@redhat.com)
- Refactored look and katello a little bit because of an order of operations
  error.` (jrist@redhat.com)
- sync management - dont start periodical updater until we have added all the
  initial syncing repos (jsherril@redhat.com)
- Pulling out the header and maincontent and putting into a new SCSS file,
  look.scss for purposes of future ability to change subtle look and feel
  easily. (jrist@redhat.com)
- Switched the 3rd level nav to hoverIntent. (jrist@redhat.com)
- sync management - a couple of periodical updater fixes (jsherril@redhat.com)
- removing unneeded view (jsherril@redhat.com)
- sync management - lots of javascript changes, a lot of stuff still broken
  (jsherril@redhat.com)
- branding changes (shughes@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (mmccune@redhat.com)
- Automatic commit of package [katello] release [0.1.99-1].
  (mmccune@redhat.com)
- misc rel-eng updates based on new RPMs from Fedora (mmccune@redhat.com)
- Merge branch 'master' into password_reset (bbuckingham@redhat.com)
- cli - add email address to 'user' as a required attribute
  (bbuckingham@redhat.com)
- sync management - some page/js modifications (jsherril@redhat.com)
- removed display of bundled products (thomasmckay@redhat.com)
- grouping by stacking_id now (thomasmckay@redhat.com)
- now group by subscription productId (thomasmckay@redhat.com)
- grouping by product name (which isn't right but treetable is working mostly
  (thomasmckay@redhat.com)
- show expansion with bundled products in a subscription
  (thomasmckay@redhat.com)
- changesets - added unique constraint on repos (tstrachota@redhat.com)
- sync management - moving repos preopulation to a central place
  (jsherril@redhat.com)
- password reset - replace flash w/ notices, add config options to
  katello.yml...ec (bbuckingham@redhat.com)
- Fixed distributions related spec tests (paji@redhat.com)
- Fixed sync related spec tests (paji@redhat.com)
- Fixed repo related spec tests (paji@redhat.com)
- Fixed packages test (paji@redhat.com)
- Fixed errata spec tests (paji@redhat.com)
- Merge branch 'master' into repo-remodel (paji@redhat.com)
- Fixed some repo related unit tests (paji@redhat.com)
- Removed the ChangesetRepo table + object and made it connect to the
  Repository model directly (paji@redhat.com)
- sync management =  javascript improvements (jsherril@redhat.com)
- sync mgmnt - fixing sync call (jsherril@redhat.com)
- sync management - adding sorting for repos and categories
  (jsherril@redhat.com)
- sync management - custom products showing up correctly now
  (jsherril@redhat.com)
- password reset - update so that emails are sent asynchronously
  (bbuckingham@redhat.com)
- sync management - making table expand by major version/ minor version/arch
  (jsherril@redhat.com)
- we require chunky_png to build, need this as a BR (mmccune@redhat.com)
- Merge branch 'master' into repo-remodel (paji@redhat.com)
- 751375 - Katello ping - undefined method `pulp_oauth_header'
  (lzap+git@redhat.com)
- bug - when debug print fails do not stop processing (lzap+git@redhat.com)
- ak cli - adding ak to the system api (lzap+git@redhat.com)
- set initial state of 'Remove System(s)' to disabled (thomasmckay@redhat.com)
- repo - using pulp id instead of AR id in pulp api calls
  (tstrachota@redhat.com)
- distributions api - fix for listing (tstrachota@redhat.com)
- final tweak to padding (thomasmckay@redhat.com)
- updated columns in history (thomasmckay@redhat.com)
- cleaned up tabs css and js into own files (thomasmckay@redhat.com)
- moderately good looking tabs (thomasmckay@redhat.com)
- stub return of import history (thomasmckay@redhat.com)
- refresh page on failed import to update displayed history
  (thomasmckay@redhat.com)
- fixed javascript errors due to bbq and incorrect includes in
  redhat_provider.html.haml (thomasmckay@redhat.com)
- mocked up in jquery tabs (thomasmckay@redhat.com)
- 751116 - can not list subscriptions (tstrachota@redhat.com)
- Fixed some package group related tests (paji@redhat.com)
- Fixed errata based cli tests (paji@redhat.com)
- Some fixes involving issues with cli-system-test (paji@redhat.com)
- use new pulp sync status, history task objects (shughes@redhat.com)
- password reset - misc fixes (bbuckingham@redhat.com)
- caching repo data and sync status to reduce sync management load time to ~40s
  (jsherril@redhat.com)
- adding ability to preload lazy accessors (jsherril@redhat.com)
- password reset - add ability to send user login based on email
  (bbuckingham@redhat.com)
- + Removed include of providers.js from redhat_provider since it was not
  needed and causing errors. + Moved bbq to common assets to make available
  everywhere (thomasmckay@redhat.com)
- repos - adding release version attribute and importing (jsherril@redhat.com)
- fixing typos (mmccune@redhat.com)
- password reset - chgs to support the actual password reset
  (bbuckingham@redhat.com)
- Merge branch 'master' into repo-remodel (paji@redhat.com)
- Fixed environment based spec tests (paji@redhat.com)
- password reset - chgs to dev env to configure sendmail
  (bbuckingham@redhat.com)
- Cherry picking a simple naming commit for the systems index page
  (tsmart@redhat.com)
- password reset - initial commit w/ logic for resetting user password
  (bbuckingham@redhat.com)
- Automatic commit of package [katello] release [0.1.98-1].
  (lzap+git@redhat.com)
- 702052 - db fields length limit review (lzap+git@redhat.com)
- Merge branch 'master' into repo-remodel (paji@redhat.com)
- unit test fix (jsherril@redhat.com)
- filters - some styling improvements, as well as some permission fixes
  (jsherril@redhat.com)
- adding katello-job logrotate script (lzap+git@redhat.com)
- Merge branch 'master' into repo-remodel (paji@redhat.com)
- removed spacing to deal with a warning (paji@redhat.com)
- Fixed the Systemtemplate spec tests (paji@redhat.com)
- Fixed errata tests (paji@redhat.com)
- Users specs - fixes for req'd email address and new tests
  (bbuckingham@redhat.com)
- Fixed sync related spec tests (paji@redhat.com)
- Fixed distribution spec tests (paji@redhat.com)
- Fixed Rep  related spec tests (paji@redhat.com)
- Fixed changeset tests (paji@redhat.com)
- Users - add email address (model/controller/view) (bbuckingham@redhat.com)
- fixed product spec tests that came up after master merge (paji@redhat.com)
- moving simplify_changeset out of application controller (jsherril@redhat.com)
- fixed more merge conflicts (paji@redhat.com)
- Merge branch 'breakup-puppet' (bkearney@redhat.com)
- Remove trailing spaces (bkearney@redhat.com)
- filter - fixing issue where you could add a repo even if one wasnt selected
  (jsherril@redhat.com)
- improving package filter chosen styling (jsherril@redhat.com)
- converting chosen css to scss (jsherril@redhat.com)
- filters - fixing javascript load issue (jsherril@redhat.com)
- fixing initial_action for panel after merge (jsherril@redhat.com)
- improving error reporting for the API calls (lzap+git@redhat.com)
- 731670 - improving error reporting when deleting users (lzap+git@redhat.com)
- 750246 - promote content of product to different environments
  (tstrachota@redhat.com)
- repo promotion - fix for failure when promoting a repo for second time
  (tstrachota@redhat.com)
- Promotions - fix ajax scrolling for promotions, errata and pkgs
  (bbuckingham@redhat.com)
- repo promotion - fix for creating content (after wrong rebase)
  (tstrachota@redhat.com)
- repo promotion - fix in spec tests (tstrachota@redhat.com)
- cp content - content type taken from the provider's type
  (tstrachota@redhat.com)
- fix for promoting repos - changeset was passing wrong parameters - repo
  promotion refactored, removed parameter for content (it is now created inside
  the repo object) (tstrachota@redhat.com)
- better error messages for template validations (lzap+git@redhat.com)
- adding some delays in the PulpTaskStatus (lzap+git@redhat.com)
- parameter -m no longer an option in katello-jobs (lzap+git@redhat.com)
- adding migration to the reset-dbs script (lzap+git@redhat.com)
- templates - spec test fix (tstrachota@redhat.com)
- templates - promoting parent templates (tstrachota@redhat.com)
- Fixed a bunch of merge conflicts (paji@redhat.com)
- More unit test fixes on the system templates stuff (paji@redhat.com)
- Fixed a good chunk of the product + repo seoc tests (paji@redhat.com)
- distros - removing tdl validation (lzap+git@redhat.com)
- distros - adding distribution tdl unit tests (lzap+git@redhat.com)
- distros - adding package groups to TDL (lzap+git@redhat.com)
- distros - adding name-version-url-arch to TDL export (lzap+git@redhat.com)
- distros - adding distributions unit tests (lzap+git@redhat.com)
- distros - adding import/export unit tests (lzap+git@redhat.com)
- distros - adding importing (lzap+git@redhat.com)
- distros - adding exporting (lzap+git@redhat.com)
- distros - adding templ. distribution validator (lzap+git@redhat.com)
- adding new configuration value debug_rest (lzap+git@redhat.com)
- distros - adding cli portion for adding/removing distros
  (lzap+git@redhat.com)
- distros - marking find_template as private method (lzap+git@redhat.com)
- distros - adding system template handling code (lzap+git@redhat.com)
- distros - adding system_template_distribution table (lzap+git@redhat.com)
- distros - adding family, variant, version in CLI (lzap+git@redhat.com)
- Merge branch 'filters-ui' (jsherril@redhat.com)
- filters - unit test fix and addition (jsherril@redhat.com)
- filters - adapting for  new panel ajax code (jsherril@redhat.com)
- fxiing merge conflict (jsherril@redhat.com)
- templates - spec test for checking revision numbers after promotion
  (tstrachota@redhat.com)
- templates - fix for increased revision numbers after promotion
  (tstrachota@redhat.com)
- filters - adding spec test for ui controller (jsherril@redhat.com)
- updated TDL schema + corresponding changes in template export & tests
  (dmitri@redhat.com)
- Merge branch 'master' into repo-remodel (paji@redhat.com)
- fixed some unit tests (paji@redhat.com)
- Automatic commit of package [katello] release [0.1.97-1].
  (shughes@redhat.com)
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
- filters - fixing a few issues, such as empty package list message not going
  away/coming back (jsherril@redhat.com)
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
- filters - fixing empty message not appearing and dissappearing as needed
  (jsherril@redhat.com)
- filters - a couple more filters fixes (jsherril@redhat.com)
- filters - removing repos from select repos select box when they are selected
  (jsherril@redhat.com)
- filters - a few ui related fixes (jsherril@redhat.com)
- filters - package imporovements (jsherril@redhat.com)
- filters - some page changes as well as adding revert filter to products and
  repos (jsherril@redhat.com)
- Fixed the repo destroy (paji@redhat.com)
- Master merge + fixed conflicts (paji@redhat.com)
- filters - making products and repos add incrementally instead of re-rendering
  the entire product list (jsherril@redhat.com)
- Adding the env products model (paji@redhat.com)
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
- Fixed merge conflicts related to master merge (paji@redhat.com)
- Merge branch 'master' into tdl-download (mmccune@redhat.com)
- adding dialog and download buttons for template download from env
  (mmccune@redhat.com)
- filters - hooking up add/remove packages to the backend, as well as a few
  javascript fixes (jsherril@redhat.com)
- Moves some widget css into separate scss files. (ehelms@redhat.com)
- Added code to check for repo name conflicts before insert (paji@redhat.com)
- Merge branch 'master' into tupane (ehelms@redhat.com)
- Tupane - Fixes for spec tests. (ehelms@redhat.com)
- errata_filter - add stub to resolve error w/ test in promotions controller
  (bbuckingham@redhat.com)
- Merge branch 'filters' into filters-ui (jsherril@redhat.com)
- filters - hooking up product and repos to backend (jsherril@redhat.com)
- filters - improving adding removing of products and repos
  (jsherril@redhat.com)
- Updated repo code to work with promotions (paji@redhat.com)
- Added some error reporting for glue errors (paji@redhat.com)
- delayed-job - log errors backtrace in log file (inecas@redhat.com)
- Glue::Pulp::Repo.find is now replaced by Repository.find_by_pulp_id now that
  we have the repository data model. (paji@redhat.com)
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
- Fixed a sync alert issue related to the new repo model (paji@redhat.com)
- Merge branch 'master' into distros (bbuckingham@redhat.com)
- Merge branch 'master' into errata_filter (bbuckingham@redhat.com)
- package filters - adding javascript product and repository adding
  (jsherril@redhat.com)
- Got the repo delete functionality working (paji@redhat.com)
- Tupane - Systems - Fixing search for creation and editing for System CRUD.
  (ehelms@redhat.com)
- Merge branch 'master' into repo-remodel (paji@redhat.com)
- Promotions - mark distributions as promoted, if they have already been
  (bbuckingham@redhat.com)
- Tupane - Fixes for unit tests after merging in master. (ehelms@redhat.com)
- Promotions - add distributions to changeset history... fix expander/collapse
  image in js (bbuckingham@redhat.com)
- fixing nil bug found on the code review - fix (lzap+git@redhat.com)
- Merge branch 'master' into tupane (ehelms@redhat.com)
- fixing nil bug found on the code review (lzap+git@redhat.com)
- added filters controller spec (dmitri@redhat.com)
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
- fixed the delete script for this model (paji@redhat.com)
- Got the sync pages to work with the new repo model (paji@redhat.com)
- Got the repo view to render the source url correctly (paji@redhat.com)
- Modified the code to get repo delete call working (paji@redhat.com)
- Updated the environment model to do a proper list products call
  (paji@redhat.com)
- Merge branch 'master' into repo-remodel (paji@redhat.com)
- Fixed an accidental remove in katello.js from commit
  ec6ce7a262af3b9c349fb98c1d58ad774206dffb (paji@redhat.com)
- Promotions - distributions - spec test updates (bbuckingham@redhat.com)
- Promotions - distributions - changes to allow for promotion
  (bbuckingham@redhat.com)
- Tupane - Search - Spec test fixes for ajaxification of search.
  (ehelms@redhat.com)
- referenced proper ::Product class... again (thomasmckay@redhat.com)
- referenced proper ::Product class (thomasmckay@redhat.com)
- Merge branch 'master' into repo-remodel (paji@redhat.com)
- Removed some wasted  comments (paji@redhat.com)
- Automatic commit of package [katello] release [0.1.96-1].
  (shughes@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (bkearney@redhat.com)
- Allow headpin and katello-common to install together (bkearney@redhat.com)
- Promotions - distributions - additional changes to properly support changeset
  operations (bbuckingham@redhat.com)
- Tupane - Adds notice on edit when edited item no longer meets search
  criteria. (ehelms@redhat.com)
- Small fix for browse/upload overlap. (jrist@redhat.com)
- pools - one more unit test (lzap+git@redhat.com)
- pools - list of available unit test (lzap+git@redhat.com)
- filters controller spec (dmitri@redhat.com)
- Promotions - distributions - add/remove/view on changeset
  (bbuckingham@redhat.com)
- tdl-repos-references - validate TDL in unit tests against xsd
  (inecas@redhat.com)
- tdl-repos-references - tdl repos references direct to pulp repo
  (inecas@redhat.com)
- Added environment mappings to the repo object and got product.repos search
  working (paji@redhat.com)
- templates - fix for cloning to an environment (tstrachota@redhat.com)
- Initial commit of the repo remodeling where the repository is created in
  katello (paji@redhat.com)
- Promotions - distros - ui chg to allow adding to changeset
  (bbuckingham@redhat.com)
- Systems - minor change to view to address warning during render...
  (bbuckingham@redhat.com)
- Promotions - distributions - make list in ui consistent w/ products list
  (bbuckingham@redhat.com)
- Minor fix for potential overlap of Upload button on Redhat Provider page.
  (jrist@redhat.com)
- Errata - update so that 'severity' will have an accessor
  (bbuckingham@redhat.com)
- Errata - filter - fix the severity values (bbuckingham@redhat.com)
- cli-akeys-pools - show pools in activation key details (inecas@redhat.com)
- cli-akeys-pools - set allocated to 1 (inecas@redhat.com)
- cli-akeys-pools - refactor spec tests (inecas@redhat.com)
- cli-akeys-pools - remove subscriptions from a activation kay
  (inecas@redhat.com)
- cli-akeys-pools - add subscription to a key through CLI (inecas@redhat.com)
- merge conflict (jsherril@redhat.com)
- 747805 - Fix for not being able to create an environment when subpanel div
  was "in the way" via z-index and layering. (jrist@redhat.com)
- adding/removal of packages from filters supports rollbacks now
  (dmitri@redhat.com)
- added support for updating of package lists of filters (dmitri@redhat.com)
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
- Fixing tests for System create (tsmart@redhat.com)
- Promotions - errata - update show to omit 'self' and include available links
  provided in errata (bbuckingham@redhat.com)
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
- Promotions - errata - update format of title for breadcrumb and errata
  details (bbuckingham@redhat.com)
- filters - a few package auto complete fixes (jsherril@redhat.com)
- filters - adding auto complete for packages, and moving locker package search
  to central place from system templates controller (jsherril@redhat.com)
- Tweaks to System/Subscriptions based on feedback:    + Fix date CSS padding
  + "Available" to "Quantity" in Available table    + Remove "Total" column in
  Available table    + Add "SLA" to Available table (thomasmckay@redhat.com)
- Errata Filters - UI - updates to integrate w/ backend errata filters
  (bbuckingham@redhat.com)
- moving some javascript i18n to a common area for autocomplete
  (jsherril@redhat.com)
- spliting out the auto complete javascript object to its own file for reuse
  (jsherril@redhat.com)
- filters - adding the ui part of package adding and removing, not hooked up to
  the backend since it doesnt work yet (jsherril@redhat.com)
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
- tupane - adding support for expanding to actions other than :edit
  (jsherril@redhat.com)
- Tupane - Search - Adds special notification if newly created object does not
  meet search criteria. (ehelms@redhat.com)
- Very minor padding issue on .dash (jrist@redhat.com)
- Tupane - Refactors items controller function to be less repetitive.
  (ehelms@redhat.com)
- filters - making filters use name instead of pulp_id, and adding remove
  (jsherril@redhat.com)
- Fix for flot/canvas on IE. (jrist@redhat.com)
- Tupane - Fixes changeset history page that requires extra attribute when
  searching for environment. (ehelms@redhat.com)
- errata-filters - filter all errata for a product (inecas@redhat.com)
- errata-filters - use only Pulp::Repo.errata for filtering (inecas@redhat.com)
- merge conflict (jsherril@redhat.com)
- BZ#747343 https://bugzilla.redhat.com/show_bug.cgi?id=747343 In fix to show
  subscriptions w/o products, the provider was not being checked.
  (thomasmckay@redhat.com)
- filters - adding initial edit code (jsherril@redhat.com)
- fixing issue where provider description was marked with the incorrect class
  (jsherril@redhat.com)
- Tupane - Adds number of total items and current items in list to left side
  list in UI. (ehelms@redhat.com)
- Tupane - Adds message specific settings to notices and adds special notice to
  organization creation for new objects that don't meet search criteria.
  (ehelms@redhat.com)
- forgot to commit migration for filter-product join table (dmitri@redhat.com)
- added support for filter create/list/show/delete operations in katello cli
  (dmitri@redhat.com)
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
- filters - adding creation of package filters in the ui (jsherril@redhat.com)
- Errata Filters - ui - initial changes to promotions breadcrumb
  (bbuckingham@redhat.com)
- more filter-related tests (dmitri@redhat.com)
- filters - initial package filtering ui (jsherril@redhat.com)
- merge conflict (jsherril@redhat.com)
- support for addition/removal of filters to already promoted products
  (dmitri@redhat.com)
- fixing gemfile url (jsherril@redhat.com)
- Automatic commit of package [katello] release [0.1.95-1].
  (lzap+git@redhat.com)
- switching to XML vs JSON for template download (mmccune@redhat.com)
- Tupane - Search - Fixes for autocomplete drop down and left list not sizing
  properly on search. (ehelms@redhat.com)
- Tupane - Search - Converts fancyqueries to use new ajax search.
  (ehelms@redhat.com)
- Tupane - Search - Removes scoped search standard jquery autocompletion widget
  and replaces it with similar one fitted for Katello's needs.
  (ehelms@redhat.com)
- Merge branch 'master' into filters-ui (jsherril@redhat.com)
- Errata - packages - list based on name-[epoch:]-version-release.arch
  (bbuckingham@redhat.com)
- tupane - adding support for actions to be disabled if nothing is selected
  (jsherril@redhat.com)
- Tupane - Search - Re-factors extended scroll to use new search parameters.
  (ehelms@redhat.com)
- 745617 fix for product sync selection745617 fix for product sync
  selection745617 fix for product sync selection745617 fix for product sync
  selection745617 fix for product sync selection745617 fix for product sync
  selection745617 fix for product sync selection (shughes@redhat.com)
- tdl - fixing one more unit test (lzap+git@redhat.com)
- tdl - fixing unit tests (lzap+git@redhat.com)
- tdl - modifying /export to return TDL format (lzap+git@redhat.com)
- tdl - refactoring export_string to export_as_json (lzap+git@redhat.com)
- reset dbs script now correctly load variables (lzap+git@redhat.com)
- 744067 - Promotions - Errata UI - clean up format on Details tab
  (bbuckingham@redhat.com)
- fixed a few issues in filters controller (dmitri@redhat.com)
- Automatic commit of package [katello] release [0.1.94-1].
  (lzap+git@redhat.com)
- adding db:truncate rake task (lzap+git@redhat.com)
- application of filters during promotion (dmitri@redhat.com)
- tests around persisting of filter-product association (dmitri@redhat.com)
- templates - spec tests for revisions (tstrachota@redhat.com)
- templates - fix for increasing revision numbers after update
  (tstrachota@redhat.com)
- fixes #745245 Filter on provider page fails with postgres error
  (abenari@redhat.com)
- Fixed a unit test (paji@redhat.com)
- 740979 - Gave provider read access for users with org sync permission
  (paji@redhat.com)
- 744067 - Promotions - Errata UI - clean up format on Packages tab
  (bbuckingham@redhat.com)
- 741416 - organizations ui - list orgs using same sort order as on roles pg
  (bbuckingham@redhat.com)
- Automatic commit of package [katello] release [0.1.93-1].
  (shughes@redhat.com)
- bump up scoped_search version to 2.3.4 (shughes@redhat.com)
- Search - Converts search to an ajax operation to refresh and update left side
  list. (ehelms@redhat.com)
- 745315 -changing application controller to not include all helpers in all
  controllers, this stops helper methods with the same name from overwriding
  each other (jsherril@redhat.com)
- 740969 - Fixed a bug where tab was being inserted. Tab is invalid for names
  (paji@redhat.com)
- 720432 - Moves the small x that closes the filter on sliding tree widgets to
  be directly to the right of the filter. (ehelms@redhat.com)
- 745279 - UI - fix deletion of repo (bbuckingham@redhat.com)
- fixed a few issues around association of filters with repos
  (dmitri@redhat.com)
- 739588-Made the systems update call raise the error message the correct way
  (paji@redhat.com)
- 735975 - Fix for user delete link showing up for self roles page
  (paji@redhat.com)
- Added code to fix a menu highlighting issue (paji@redhat.com)
- 743415 - removing uneeded files (mmccune@redhat.com)
- Fixes issue with navigationg graphic showing up on roles page tupanel.
  (ehelms@redhat.com)
- Merge branch 'master' into tupane (ehelms@redhat.com)
- Tupane - Changes pages to use new action to register with panel in
  javascript. (ehelms@redhat.com)
- update to translations (shughes@redhat.com)
- 744285 - bulletproof the spec test for repo_id (inecas@redhat.com)
- Fix for accidentaly faling tests (inecas@redhat.com)
- adding new zanata translation file (shughes@redhat.com)
- added support for associating of filters with products (dmitri@redhat.com)
- search - fix system save and notices search (bbuckingham@redhat.com)
- 744285 - Change format of repo id (inecas@redhat.com)
- Fixed a bunch of unit tests (paji@redhat.com)
- Fixed progress bar and spacing on sync management page. (jrist@redhat.com)
- Tupane - Moves list javascript object to new namespace. Moves newly created
  objects to top of the left hand list. (ehelms@redhat.com)
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
- Tupane - Converts the rest of ajax loading left hand list object creations to
  new style that respects search parameters. (ehelms@redhat.com)
- removing z-index on helptip open icon so it does not hover over 3rd level
  navigation menu (jsherril@redhat.com)
- Moved the help tip on the redhat providers page show up at the right spot
  (paji@redhat.com)
- adding bulk delete system spec test (jsherril@redhat.com)
- reduce number of sync threads (shughes@redhat.com)
- tupane actions - adding icon to system bulk remove (jsherril@redhat.com)
- search - several fixes for issues on auto-complete (bbuckingham@redhat.com)
- tupane actions - moving KT.panel action functions to KT.panel.actions
  (jsherril@redhat.com)
- Fixed the refresh of the number of items to happen automatically without
  being called. (jrist@redhat.com)
- System removal refresh of items number.. (jrist@redhat.com)
- Tupane - ActivationKeys - Changes Activation Keys to use creation format that
  respects search filters. (ehelms@redhat.com)
- tests - adding system template package group test for the ui controller
  (jsherril@redhat.com)
- Tupane - Role - Cleanup of role creation with addition of description field.
  Moves role creation in UI to new form to respect search parameters.
  (ehelms@redhat.com)
- 744191 - prevent some changes on red hat provider (inecas@redhat.com)
- 744191 - Prevent deleting Red Hat provider (inecas@redhat.com)
- Tupane - Modifies left hand list to obey search parameters and adds the
  ability to specify a create action on the page for automatic handling of
  creation of new objects with respect to the search parameters.
  (ehelms@redhat.com)
- Automatic commit of package [katello] release [0.1.92-1].
  (lzap+git@redhat.com)
- Installation does not pull in katello-cli (jpazdziora@redhat.com)
- system templates - removign uneeded route (jsherril@redhat.com)
- Revert "added ruport-related gems to Gemfile" (dmitri@redhat.com)
- jslint - fix warnings reported during build (bbuckingham@redhat.com)
- templates - fix in spec tests for exporting/importing (tstrachota@redhat.com)
- fixed a misspelled method name (dmitri@redhat.com)
- templates - fix for cloning to next environment - added nvres to export - fix
  for importing package groups (tstrachota@redhat.com)
- re-created reports functionality after botched merge (dmitri@redhat.com)
- added ruport-related gems to Gemfile (dmitri@redhat.com)
- applying filters to products step 1 (dmitri@redhat.com)
- JsRoutes - Fix for rake task to generate javascript routes.
  (ehelms@redhat.com)
- two pane system actions - adding remove action for bulk systems
  (jsherril@redhat.com)
- system templates - package groups auto complete working (jsherril@redhat.com)
- system templates - hooked up comps groups with backend with the exception of
  auto complete (jsherril@redhat.com)
- Automatic commit of package [katello] release [0.1.91-1].
  (bbuckingham@redhat.com)
- scoped_search - Gemfile updates to support scoped_search 2.3.4
  (bbuckingham@redhat.com)
- 741656 - roles - search - chgs for search by perm type and verbs
  (bbuckingham@redhat.com)
- Switch of arch and support level on subscriptions page. (jrist@redhat.com)
- Tupane - Converts Content Management tab to use left list ajax loading.
  (ehelms@redhat.com)
- Tupane - Converts Organizations tab to ajax list loading. (ehelms@redhat.com)
- Tupane - Converts Administration tab to ajax list loading.
  (ehelms@redhat.com)
- Merge branch 'master' into tupane (ehelms@redhat.com)
- Tupane - Converts systems tab items to use new ajax loading in left hand
  list. (ehelms@redhat.com)
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
- Merge branch 'master' into comps (jsherril@redhat.com)
- Automatic commit of package [katello] release [0.1.90-1].
  (lzap+git@redhat.com)
- fix for katello-reset-dbs - pgsql support for initdb - typo
  (lzap+git@redhat.com)
- fix for katello-reset-dbs - pgsql support for initdb (lzap+git@redhat.com)
- 731203 - updates to support ellipsis in header of tupane layout
  (bbuckingham@redhat.com)
- sms - introducing subscriptions controller (lzap+git@redhat.com)
- sms - refactoring subscription -> subscriptions path (lzap+git@redhat.com)
- sms - moving subscriptions list action into the backend (lzap+git@redhat.com)
- sms - moving unsubscribe action into the backend (lzap+git@redhat.com)
- fields residing in pulp are now present in the output of index
  (dmitri@redhat.com)
- create/delete operations for filters are working now (dmitri@redhat.com)
- Merge branch 'master' into tdl-download (mmccune@redhat.com)
- first hack to try and get the sub-edit panel to pop up (mmccune@redhat.com)
- dashboard - one last css vertical spacing issue fix (jsherril@redhat.com)
- making css for navigation require a little space in the subnav if there are
  no subnav elements (jsherril@redhat.com)
- dashboard - fixing issue where user with no orgs would recieve an error upon
  login (jsherril@redhat.com)
- panel - minor update to escape special characters in id
  (bbuckingham@redhat.com)
- dashboard - more dashboard css fixes (jsherril@redhat.com)
- 741669 - fixing issue where user with no org could not access their own user
  details page (jsherril@redhat.com)
- dashboard - adding ui tweaks from uxd (jsherril@redhat.com)
- Automatic commit of package [katello] release [0.1.89-1].
  (shughes@redhat.com)
- adding reporting gems deps (shughes@redhat.com)
- Automatic commit of package [katello] release [0.1.88-1].
  (shughes@redhat.com)
- adding yum fix until 3.2.29 hits zstream/pulp (shughes@redhat.com)
- provider - search changes resulting from split of Custom and Red Hat
  providers (bbuckingham@redhat.com)
- 715369 - use ellipsis on search favorites/history w/ long names
  (bbuckingham@redhat.com)
- repo - default value for content type when creating new repo
  (tstrachota@redhat.com)
- sms - useless comment (lzap+git@redhat.com)
- first cut of filters used during promotion of content from Locker
  (dmitri@redhat.com)
- templates - removed old way of promoting templates directly
  (tstrachota@redhat.com)
- import-stage-manifest - set content type for created repo (inecas@redhat.com)
- dashboard - fixing issue where promotions ellipsis was not configured
  correctly (jsherril@redhat.com)
- dashboard - updating subscription status scss as per request
  (jsherril@redhat.com)
- Automatic commit of package [katello] release [0.1.87-1].
  (shughes@redhat.com)
- adding redhat-uep.pem to katello ca (shughes@redhat.com)
- dashboard - prevent a divide by zero (jsherril@redhat.com)
- import-stage-manifest - fix relative path for imported repos
  (inecas@redhat.com)
- Do not call reset-oauth in %%post, candlepin and pulp are not installed at
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
- Tupane - Initial commit of changes to loading of left hand list on tupane
  pages via ajax. (ehelms@redhat.com)
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
- Tupanel - Updates to tupanel slide out for smoother sliding up and down
  elongated lists.  Fix for extended scroll causing slide out panel to overrun
  footer. (ehelms@redhat.com)
- Merge branch 'master' into akeys (bbuckingham@redhat.com)
- Automatic commit of package [katello] release [0.1.86-1].
  (lzap+git@redhat.com)
- Merge branch 'master' into providers (paji@redhat.com)
- Added some rendering on products and repos page to explicity differentiate
  the 2 (paji@redhat.com)
- dashboard - removing system list and expanding height of big_widget and
  small_widget (jsherril@redhat.com)
- Updated katello-js to work with multiple third level navs (paji@redhat.com)
- a-keys - fix view specs (bbuckingham@redhat.com)
- 740921 - When editing a permission verbs and tags that were part of the
  permission will now show up as selected already. (ehelms@redhat.com)
- Roles UI - Fix for edit role slide up container not working after previous
  changes to the way the action bar works. (ehelms@redhat.com)
- tupane - fixing extended scroll spinner showing up on most pages
  (jsherril@redhat.com)
- panel - rendering generic rows more efficiently (jsherril@redhat.com)
- 740365 - fixing issue with systems sorting and extended scroll, where limits
  were being placed before teh sorting happened (jsherril@redhat.com)
- a-keys - fix controller specs (bbuckingham@redhat.com)
- Fixes for Roles UI action bar edit breaking after trying to edit more than 1.
  (ehelms@redhat.com)
- a-keys - mods to handle nil env on akey create (bbuckingham@redhat.com)
- 737138 - Adds action bar buttons on roles pages to tab index and adds enter
  button press handlers to activate actions. (ehelms@redhat.com)
- 733722 - When hitting enter after editing an input will cause the next button
  to click. (ehelms@redhat.com)
- 741399 - Fixes for Global permissions to hide 'On' field for all resource
  types. (ehelms@redhat.com)
- Tupane - Changes for consistency of tupane css. (ehelms@redhat.com)
- 741422 - Roles UI - Fixes issue with sliding tree expanding in height instead
  of overflowing container. (ehelms@redhat.com)
- Row/grouping coloring for products and repos. (jrist@redhat.com)
- Alternating family rows in Activation Keys by way of Ruby's handy cycle
  method. (jrist@redhat.com)
- a-keys - (TO BE REVERTED) temporary commit to duplicate subscriptions
  (bbuckingham@redhat.com)
- a-keys - some refactor/cleanup of js to use KT namespace
  (bbuckingham@redhat.com)
- Fixed a unit test failure (paji@redhat.com)
- Got pretty much the providers functionality done with this (paji@redhat.com)
- a-keys - js fix so that clearing filter does not leave children shown
  (bbuckingham@redhat.com)
- Initial commit related to the provider page redesign (paji@redhat.com)
- sms - cli system subscribe command (lzap+git@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (bkearney@redhat.com)
- a-keys - css updates for subscriptions (bbuckingham@redhat.com)
- Commiting a bunch of unit fixes (paji@redhat.com)
- Made organization create a default redhat provider on its inception
  (paji@redhat.com)
- Updated dashboard systems snippet. fixed a couple of bugs w.r.t ellipsis
  (paji@redhat.com)
- a-keys - change the text used to request update to template
  (bbuckingham@redhat.com)
- a-keys - update scss to remove some of the table css used by akey
  subscriptions (bbuckingham@redhat.com)
- system templates - adding  addition and removal of package groups in the web
  ui, still does not save to server (jsherril@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (bkearney@redhat.com)
- Dashboard - lighter hr color, and shorter big_widgets. (jrist@redhat.com)
- Merge branch 'master' into akeys (bbuckingham@redhat.com)
- system templates - properly listing package groups respecting page size
  limits (jsherril@redhat.com)
- a-keys - init env_select when edit pane is initialized
  (bbuckingham@redhat.com)
- a-keys - add cancel button to general tab (bbuckingham@redhat.com)
- 740936 - Roles UI - Fixes issue with back button disappearing, container
  border not surrounding actior bar and with wrong containers being displayed
  for permission create. (ehelms@redhat.com)
- system templates - adding real package groups to system templates page
  (jsherril@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (bkearney@redhat.com)
- BZ 741357: fixed a spelling mistake in katello-jobs.init (dmitri@redhat.com)
- Revert "BZ 741357: fixed a spelling mistake in katello-jobs.init"
  (dmitri@redhat.com)
- BZ 741357: fixed a spelling mistake in katello-jobs.init (dmitri@redhat.com)
- Merge branch 'master' into search (bbuckingham@redhat.com)
- 741444/741648/739981/739655 - update *.js.haml to use the new KT namespace
  for javascript (bbuckingham@redhat.com)
- Added some modifications for the dashboard systems overview widget to include
  the product name (paji@redhat.com)
- Merge branch 'master' into tdl-download (mmccune@redhat.com)
- add a spec test to the new download (mmccune@redhat.com)
- Adding system template download button. (mmccune@redhat.com)
- Updated the dashboard systems view to be more consistent and show an icon if
  entitlements are valid (paji@redhat.com)
- Moved methods from the systems_help to application so that the time
  formatting can be conisistent across all helpers (paji@redhat.com)
- a-keys - subscriptions - updates to support listing by product
  (bbuckingham@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (bkearney@redhat.com)
- system templates - adding initial ui framework for package groups in system
  templates (jsherril@redhat.com)
- system templates - adding initial comps listing for products (with fake data)
  (jsherril@redhat.com)
- Lighter color footer version. (jrist@redhat.com)
- Tupane - Fixes typo from earlier change related to tupane closing not
  scrolling back up to top. (ehelms@redhat.com)
- Merge branch 'dashboard' (jsherril@redhat.com)
- dashboard - making subscription widget load with the page
  (jsherril@redhat.com)
- Added some better error handling and removed katello_error.haml as we can do
  the same with katello.haml (paji@redhat.com)
- dashboard - fixing issue where errata would not expand properly when loaded
  via async, also moved jscroll initalization to a more central place
  (jsherril@redhat.com)
- dashboard - fixing issue where scrollbar would not initialize for ajax loaded
  widgets (jsherril@redhat.com)
- dashboard - removing console.logs (jsherril@redhat.com)
- dashboard - making all widgets load asyncronously (jsherril@redhat.com)
- Merge branch 'dashboard' of ssh://git.fedorahosted.org/git/katello into
  dashboard (jrist@redhat.com)
- Changes to the dashboard layout. (jrist@redhat.com)
- dashboard - adding errata widget with fake data (jsherril@redhat.com)
- Dashboard gear icon in button. (jrist@redhat.com)
- a-keys - update to disable the Add/Remove button after click
  (bbuckingham@redhat.com)
- 739654 - Tupane - Fixes issue with tupane jumping to top of page upon being
  closed. (ehelms@redhat.com)
- katello-all -- a meta-package to pull in all components for Katello.
  (jpazdziora@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (bkearney@redhat.com)
- Stroke 0 on dashboard pie graph. (jrist@redhat.com)
- a-keys - subscriptions - update to include type (virtual/physical)
  (bbuckingham@redhat.com)
- 736090 - Tupane - Fixes for tupane drifting into footer. (ehelms@redhat.com)
- 736828 - Promotions - Fixes packages tupane to close whenever the breadcrumb
  is navigated away from the packages list. (ehelms@redhat.com)
- Automatic commit of package [katello] release [0.1.85-1].
  (shughes@redhat.com)
- remove capistrano from our deps (shughes@redhat.com)
- a-keys - applied subs - add link to add subs (bbuckingham@redhat.com)
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
- Overlay for graph on sub status for dasyboard.  Fix for a few small bad haml
  and js things. (jrist@redhat.com)
- a-keys - initial changes for applied subscriptions page
  (bbuckingham@redhat.com)
- Fixed a var name goofup (paji@redhat.com)
- a-keys - initial changes for available subscriptions page
  (bbuckingham@redhat.com)
- Tupanel - Fixes issue with tupanel ajax data being inserted twice into DOM.
  (ehelms@redhat.com)
- Tupanel - Fixes smoothness issue between normal tupane and sliding tree.
  (ehelms@redhat.com)
- Tupanel - Fixes for resizing and height setting.  Fixes for subpanel.
  (ehelms@redhat.com)
- Merge branch 'master' into dashboard (paji@redhat.com)
- Merge branch 'master' into tupanel (ehelms@redhat.com)
- Tupanel - Changes to tupanel for look and feel and consistency.
  (ehelms@redhat.com)
- dashboard - adding owner infor object to katello and having the dashboard use
  it for total systems (jsherril@redhat.com)
- dashboard - fixing color values to work properly in firefox
  (jsherril@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (bkearney@redhat.com)
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
- Updated some scss styling to lengthen the scroll (paji@redhat.com)
- Added a message to show empty systems (paji@redhat.com)
- Added  some styling on the systems snippet (paji@redhat.com)
- dashboard - adding subscription widget for dashboard with fake data
  (jsherril@redhat.com)
- adding in mod_ssl requirement. previously this was beeing indirectly pulled
  in by pulp but katello should require it as well. (shughes@redhat.com)
- Merge branch 'master' into akeys (bbuckingham@redhat.com)
- bump down rack-test. 0.5.7 is only needed. (shughes@redhat.com)
- Added the ellipsis widget (paji@redhat.com)
- glue - caching teh sync status object in repos to reduce overhead
  (jsherril@redhat.com)
- Merge branch 'master' into routesjs (ehelms@redhat.com)
- dashboard - a few visual fixes (jsherril@redhat.com)
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
- Fixed some merge conflicts (paji@redhat.com)
- Initial cut of the systems snippet on the dashboard (paji@redhat.com)
- JsRoutes - Adds the base functionality to use and generate the Rails routes
  in Javascript. (ehelms@redhat.com)
- Adds js-routes gem as a development gem. (ehelms@redhat.com)
- Tupane - A slew of changes to how the tupane slideout works with regards to
  positioning. (ehelms@redhat.com)
- dashboard - adding sync dashboard widget (jsherril@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (bkearney@redhat.com)
- bump down tzinfo version. actionpack/activerecord only need > 3.23
  (shughes@redhat.com)
- Automatic commit of package [katello] release [0.1.84-1].
  (lzap+git@redhat.com)
- asub - adding unit tests (lzap+git@redhat.com)
- asub - ak subscribes to pool which starts most recently (lzap+git@redhat.com)
- asub - renaming KTSubscription to KTPool (lzap+git@redhat.com)
- a-keys - new/edit - updates to highlight the need to change template, on env
  change... (bbuckingham@redhat.com)
- a-keys - edit - fix broken 'save' (bbuckingham@redhat.com)
- a-keys - subscriptions - add applied/available placeholders for view and
  controller (bbuckingham@redhat.com)
- Tupanel - Cleanup and fixes for making the tupanel slide out panel stop at
  the bottom. (ehelms@redhat.com)
- Merge branch 'master' into rails309 (shughes@redhat.com)
- a-keys - add Applied and Available subscriptions to navigation
  (bbuckingham@redhat.com)
- dashboard - making helper function names more consistent
  (jsherril@redhat.com)
- dashboard - fixing changeset link and fixing icon links on promotions
  (jsherril@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (bkearney@redhat.com)
- a-keys - new/edit - disable save buttons while retrieving template/product
  info (bbuckingham@redhat.com)
- adding dep for rails 3.0.10 (shughes@redhat.com)
- new deps for rails 3.0.10 (shughes@redhat.com)
- a-keys - new - update to set env to the first available
  (bbuckingham@redhat.com)
- 740389 - include repoid and remove unused security checks
  (mmccune@redhat.com)
- Made the current_organization failure check to also log the exception trace
  (paji@redhat.com)
- a-keys - remove the edit_environment action (bbuckingham@redhat.com)
- a-keys - edit - update to list products in the env selected
  (bbuckingham@redhat.com)
- Merge branch 'master' into dashboard (paji@redhat.com)
- Merge branch 'master' into rails309 (shughes@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (bkearney@redhat.com)
- bumping candlepin to the latest rev (mmccune@redhat.com)
- Promoted content enabled by default (inecas@redhat.com)
- a-keys - update new key ui to use environment selector
  (bbuckingham@redhat.com)
- a-keys - update setting of env and system template on general tab...
  (bbuckingham@redhat.com)
- fixed a bug with parsing of oauth provider parameters (dmitri@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (bkearney@redhat.com)
- Merge branch 'master' into dashboard (paji@redhat.com)
- Hid the select all/none button if the user doesnt have any syncable
  products.. (paji@redhat.com)
- More roles controller spec fixes (paji@redhat.com)
- Roles - Fixes for spec tests that made assumptions that don't hold true on
  postgres. (ehelms@redhat.com)
- dashboard - mostly got promotions pane on dashboard working
  (jsherril@redhat.com)
- Added some comments for app controller (paji@redhat.com)
- Merge branch 'master' into dashboard (jsherril@redhat.com)
- Roles UI - Updates to edit permission workflow as a result of changes to add
  permission workflow. (ehelms@redhat.com)
- dashboard - got notices dashboard widget in place (jsherril@redhat.com)
- Roles Spec - Adds unit tests to cover CRUD on permissions.
  (ehelms@redhat.com)
- Roles UI - Fixes to permission add workflow for edge cases.
  (ehelms@redhat.com)
- Roles UI - Modifies role add permission workflow to add a progress bar and
  move the name and description to the bottom of the workflow.
  (ehelms@redhat.com)
- Added some padding for perm denied message (paji@redhat.com)
- Updated the config file to illustrate the use of allow_roles_logging..
  (paji@redhat.com)
- forgot to evalute the exception correctly (paji@redhat.com)
- Added ordering for roles based on names (paji@redhat.com)
- Added a config entry allow_roles_logging for roles logs to be printed on the
  output log. This was becasue roles check was cluttering the console window.
  (paji@redhat.com)
- Made the rails error messages log a nice stack trace (paji@redhat.com)
- packagegroups-templates - better validation messages (inecas@redhat.com)
- packagegroups-templates - fix for notification message (inecas@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (bkearney@redhat.com)
- More user-friendly validation failed message in CLI (inecas@redhat.com)
- removing an unused migration (dmitri@redhat.com)
- Disable unstable spec test (inecas@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (dmitri@redhat.com)
- regin dep issue workaround enabled for EL6 now (lzap+git@redhat.com)
- removed access control from UebercertsController (dmitri@redhat.com)
- Automatic commit of package [katello] release [0.1.83-1].
  (lzap+git@redhat.com)
- Updates on the promotion controller page to deal with weird permission models
  (paji@redhat.com)
- move the SSL fix into the rpm files (bkearney@redhat.com)
- 732444 - make sure we uppercase before we sort so it is case indifferent
  (mmccune@redhat.com)
- fixed an accidental typo (paji@redhat.com)
- Updated the promotions page nav and rules to work correctly (paji@redhat.com)
- Updated the handling of the 500 error to deal with null org cases
  (paji@redhat.com)
- 734526 - improving error messages for promotions to include changeset names.
  (jsherril@redhat.com)
- 733270 - fix failing unit tests (inecas@redhat.com)
- 733270 - validate uniquenss of system name (inecas@redhat.com)
- 734882 - format RestClient error message only for katello-cli agent
  (inecas@redhat.com)
- 734882 - User-Agent header in katello-cli and custom error messages
  (inecas@redhat.com)
- Merge branch 'uebercert' (dmitri@redhat.com)
- updates routes to support uebercert operations (dmitri@redhat.com)
- fixed a few issues with uebercert controller specs (dmitri@redhat.com)
- katello now uses cp's uebercert generation/retrieval (dmitri@redhat.com)
- changed candlepin url in Candlepin::Consumer integration tests
  (dmitri@redhat.com)
- removing unecessary debug line that was causing JS errors
  (mmccune@redhat.com)
- notices - change to fix broken tests (bbuckingham@redhat.com)
- Additional work on the dashboard L&F.  Still need gear in dropbutton and
  content in dashboard boxes. (jrist@redhat.com)
- notices - making default polling inverval 120s (when omitted from conf)
  (bbuckingham@redhat.com)
- Changes to the dashboard UI headers. (jrist@redhat.com)
- notices - change to support closing previous failure notices on a success
  (bbuckingham@redhat.com)
- activation keys - fixing new env selector for activation keys
  (jsherril@redhat.com)
- Dashboard initial layout. Added new icons to the action-icons.png as well as
  the chart overlay for the pie chart for subscriptions. (jrist@redhat.com)
- fixing poor coding around enabling create due to permission that had creeped
  into multiple controllers (jsherril@redhat.com)
- 739200 - moving system template new button to the top left instead of on the
  bottom action bar (jsherril@redhat.com)
- system templates - updating page to ensure list items are vertical centered,
  required due to some changes by ehelms (jsherril@redhat.com)
- javascript - some fixes for the new panel object (jsherril@redhat.com)
- merging in env-selector (jsherril@redhat.com)
- env-select - adding more javascript documentation and improving spacing
  calculations (jsherril@redhat.com)
- Fix proxy to candlepin due to change RAILS_RELATIVE_URL_ROOT
  (inecas@redhat.com)
- env-select - fixing a few spacing issues as well as having selected item be
  expanded more so than others (jsherril@redhat.com)
- 738762 - SSLVerifyClient for apache+thin (inecas@redhat.com)
- env select - corrected env select widget to work with the expanding nodes
  (jsherril@redhat.com)
- 722439 - adding version to the footer (mmccune@redhat.com)
- notices - adding controller_name and action_name to notices
  (bbuckingham@redhat.com)
- search - modifications to support service prefix (e.g. /katello)
  (bbuckingham@redhat.com)
- Roles UI - Fix for broken role editing on the UI. (ehelms@redhat.com)
- env select - fixing up the new environment selector and ditching the old
  jbreadcrumb (jsherril@redhat.com)
- Two other small changes to fix the hidden features of subscribe and
  unsubscribe. (jrist@redhat.com)
- Fix for .hidden not working :) (jrist@redhat.com)
- Roles UI - Fixes broken add permission workflow. (ehelms@redhat.com)
- Fixes a number of look and feel issues related to sliding tree items and
  clicking list items. (ehelms@redhat.com)
- Changes multiselect to have add from list on the left and add to list on the
  right. Moves multiselect widget css to its own file. (ehelms@redhat.com)
- Fixes for changes to panel javascript due to rebase. (ehelms@redhat.com)
- Fixes for editing a permission when setting the all tags or all verbs.
  (ehelms@redhat.com)
- A refactor of panel in preparation for changes to address a series of bugs
  related to making the slide out panel of tupane more robust.
  (ehelms@redhat.com)
- Roles UI - Adds back missing css for blue box around roles widget.
  (ehelms@redhat.com)
- CSS cleanup focused on organizing colors and adding more variable
  definitions. (ehelms@redhat.com)
- Automatic commit of package [katello] release [0.1.82-1].
  (lzap+git@redhat.com)
- removing two unnecessarry macros in spec file (lzap+git@redhat.com)
- correcting workaround for BZ 714167 (undeclared dependencies) in spec
  (lzap+git@redhat.com)
- adding copyright and modeline to our spec files (lzap+git@redhat.com)
- correcting indentatin (Jan Pazdziora) (lzap+git@redhat.com)
- packagegroups - add pacakge groups and categories to JSON (inecas@redhat.com)
- pacakgegroups - refactor template exports to meet Ruby conventions
  (inecas@redhat.com)
- packagegroups - add to string export of template (inecas@redhat.com)
- packagegroups - support for group and categories in temp import
  (inecas@redhat.com)
- adding two configuration values debug_pulp_proxy (lzap+git@redhat.com)
- Merge branch 'master' into search (bbuckingham@redhat.com)
- promotions - fixing error where you could not add a product
  (jsherril@redhat.com)
- search - add completer_scope to role model (bbuckingham@redhat.com)
- Fixed some unit tests... (paji@redhat.com)
- 734460 - Fix to have the roles UI complain on bad role names
  (paji@redhat.com)
- search - systems - update to properly handle autocomplete
  (bbuckingham@redhat.com)
- initial breadcrumb revamp (jsherril@redhat.com)
- Fix to get tags.formatted to work with the new changes (paji@redhat.com)
- search - initial commit to address auto-complete support w/ perms
  (bbuckingham@redhat.com)
- Fixed several broken tests in postgres (paji@redhat.com)
- Removed 'tags' table for we could just deal with that using unique tag ids.
  To avoid the dreaded "explicit cast" exception when joining tags to entity
  ids table in postgres (example - Environments), we need tags to be integers.
  All our tags at the present time are integers anyway so this seems an easy
  enough change. (paji@redhat.com)
- refactor - remove debug message to stdout (inecas@redhat.com)
- fixed a few issues with repo creation on manifest import test
  (dmitri@redhat.com)
- added support for preserving of repo metadata during import of manifests
  (dmitri@redhat.com)
- 738200 - use action_name instead of params[:action] (inecas@redhat.com)
- templates api - route for listing templates in an environment
  (tstrachota@redhat.com)
- Automatic commit of package [katello] release [0.1.81-1].
  (bbuckingham@redhat.com)
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
- gemfile mods for rails 3.0.9 (shughes@redhat.com)
- Merge branch 'master' into template-ui (jsherril@redhat.com)
- system templates - making sure that all ui elements are looked up again in
  each function in case they are redrawn (jsherril@redhat.com)
- system templates - making jslint happy, and looking up elements that may have
  been redrawn (jsherril@redhat.com)
- system templates - a few javascript fixes for product removal
  (jsherril@redhat.com)
- Automatic commit of package [katello] release [0.1.80-1].
  (lzap+git@redhat.com)
- error text now include 'Warning' not to confuse users (lzap+git@redhat.com)
- initscript - removing temporary sleep (lzap+git@redhat.com)
- initscript - removing pid removal (lzap+git@redhat.com)
- 736716 - product api was returning 2 ids per product (tstrachota@redhat.com)
- 736438 - implement permission check for list_owners (lzap+git@redhat.com)
- 736438 - move list_owners from orgs to users controller (lzap+git@redhat.com)
- Updated katello.js to keep jslint happy (paji@redhat.com)
- Updated katello.js to keep jslint happy (paji@redhat.com)
- Updated katello.js to keep jslint happy (paji@redhat.com)
- Code changes to make jslint happy (paji@redhat.com)
- Fixed some system template conflict handling issues (paji@redhat.com)
- system templates - adding permission for system templates
  (jsherril@redhat.com)
- app server - updates to use thin Rack handler vs script/thin
  (bbuckingham@redhat.com)
- system templates - fixing things that broke due to master merge
  (jsherril@redhat.com)
- merge fix (jsherril@redhat.com)
- system templates - fixing issue with firefox showing a longer form than
  chrome causing the add button to go to another line (jsherril@redhat.com)
- Added a 'details' page for system templates promotion (paji@redhat.com)
- script/rails - adding back in... needed to run rails console
  (bbuckingham@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (mmccune@redhat.com)
- renaming the 2 providers to something more useful (mmccune@redhat.com)
- Changeset History - Fix for new URL scheme on changeset history page.
  (ehelms@redhat.com)
- Roles UI - Adds selected color border to roles slide out widget and removes
  arrow from left list on roles page only. (ehelms@redhat.com)
- changeset history - adding bbq support for cs history, and making bbq work
  properly on this page for panel (jsherril@redhat.com)
- Automatic commit of package [katello] release [0.1.79-1].
  (bbuckingham@redhat.com)
- fixed a bunch of issues during uebercert generation (dmitri@redhat.com)
- first cut at supporting ueber certs (dmitri@redhat.com)
- Merge branch 'master' into thin (mmccune@redhat.com)
- Added a system templates details page needed for promotion (paji@redhat.com)
- Automatic commit of package [katello] release [0.1.78-1].
  (bbuckingham@redhat.com)
- scoped_search - bumping version to 2.3.3 (bbuckingham@redhat.com)
- 735747 - fixing issue where creating a permission with create verb would
  result in an error (jsherril@redhat.com)
- Quick fix on promotions javascript to get the add/remove properly showing up
  (paji@redhat.com)
- Changes from using controller_name (a pre-defined rails function) to using
  controller_display_name for use in setting model object ids in views.
  (ehelms@redhat.com)
- Merge branch 'master' into thin (mmccune@redhat.com)
- 734899 - fixing issue where changeset history would default to locker
  (jsherril@redhat.com)
- changeset history - adding indentation to content items (jsherril@redhat.com)
- Added some auth rules for changeset updating (paji@redhat.com)
- 736440 - Failures based on authorization return valid json
  (tstrachota@redhat.com)
- adding system templates to changeset history and fixing spacing issues with
  accordion (jsherril@redhat.com)
- default newrelic profiling to false in dev mode (shughes@redhat.com)
- Merge branch 'oauth_provider' (dmitri@redhat.com)
- added support for katello api acting as a 2-legged oauth provider
  (dmitri@redhat.com)
- Automatic commit of package [katello] release [0.1.77-1].
  (lzap+git@redhat.com)
- puppet - adding initdb 'run twice' check (lzap+git@redhat.com)
- Got the add remove working on system templates (paji@redhat.com)
- system templates - fixing action bar buttons from not changing name properly
  (jsherril@redhat.com)
- Added code to show 'empty' templates (paji@redhat.com)
-  fixing merge conflict (jsherril@redhat.com)
- system templates - adapting the system templates tow ork with the new action
  bar api (jsherril@redhat.com)
- moving new thin and httpd conf files to match existing config locations
  (mmccune@redhat.com)
- Fixed errors that crept up in a previous commit (paji@redhat.com)
- Fixed the simplyfy_changeset to have an init :system_templates
  (paji@redhat.com)
- Simplify the stop command and make sure status works (mmccune@redhat.com)
- 731158: add ajax call to update sync duration (shughes@redhat.com)
- sync-status removing finish_time from ui (shughes@redhat.com)
- sync status - add sync duration calculations (shughes@redhat.com)
- sync status - update title per QE request (shughes@redhat.com)
- 731158: remove 'not synced' status and leave blank (shughes@redhat.com)
- Made got the add/remove system templates functionality somewhat working
  (paji@redhat.com)
- fixing merge conflicts (jsherril@redhat.com)
- system templates - adding additional tests (jsherril@redhat.com)
- 734196 - Disabled add and remove buttons in roles sliding tree after they
  have been clicked to prevent multiple server calls. (ehelms@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (ehelms@redhat.com)
- 725842 - Fix for Search: fancyqueries dropdown - alignment (jrist@redhat.com)
- Merge branch 'master' into roles-ui (ehelms@redhat.com)
- Role - Disabled the resizing on the roles ui sliding tree.
  (ehelms@redhat.com)
- Fix for when system has no packages - should not see list or filter.
  (jrist@redhat.com)
- system templates - adding help tip (jsherril@redhat.com)
- Fix for systems with no packages. (jrist@redhat.com)
- system templates - adding & removing from content pane now works as well as
  saving product changes within the template (jsherril@redhat.com)
- 736148 - update code to properly cancel a sync and render it in UI
  (mmccune@redhat.com)
- system templates - adding working auto complete box for products
  (jsherril@redhat.com)
- Role - Changes to display of full access label on organizations in roles ui
  list when a permission granting full access is removed. (ehelms@redhat.com)
- 731158: misc improvements to sync status page (shughes@redhat.com)
- JS - fix image paths in javascript (bbuckingham@redhat.com)
- system-templates - making the auto complete box more abstract so products can
  still use it, as well as adding product rendering (jsherril@redhat.com)
- Promotions packages - replace hardcoded path w/ helper
  (bbuckingham@redhat.com)
- 736384 - workaround for perm. denied (unit test) (lzap+git@redhat.com)
- Role - Look and feel fixes for displaying of no current permissions message.
  (ehelms@redhat.com)
- 734448 - Fix for Broken 'logout' link at web page's footer o    modified:
  src/app/views/layouts/_footer.haml (jrist@redhat.com)
- Package sort asc and desc via header.  Ajax refresh and indicators.
  (jrist@redhat.com)
- 736384 - workaround for perm. denied for rhsm registration
  (lzap+git@redhat.com)
- katello.init - update thin start so that log/pid files are owned by katello
  (bbuckingham@redhat.com)
- Roles - Adds text to empty permissions list instructing user what to do next
  for global and organizational permissions. (ehelms@redhat.com)
- system templates - adding missing view (jsherril@redhat.com)
- breaking out packge actions to their own js object (jsherril@redhat.com)
- Merge branch 'master' into roles-ui (ehelms@redhat.com)
- 736251 - use content name for repo id when importing manifest
  (inecas@redhat.com)
- templates - it is possible to create/edit only templates in the locker -
  added checks into template controller - spec tests fixed according to changes
  (tstrachota@redhat.com)
- Views - updates to support /katello prefix (bbuckingham@redhat.com)
- Initial cut of the system templates promotion page - Add/remove changeset
  functionality TBD (paji@redhat.com)
- Views/JS - updates to support /katello prefix (bbuckingham@redhat.com)
- system template - add warning when browsing away from an unsaved changeset
  (jsherril@redhat.com)
- system template - fixing issue where clicking add when default search text
  was there would attempt to add a package (jsherril@redhat.com)
- system templates - added save dialog for moving away from a template when it
  was modified (jsherril@redhat.com)
- sliding tree - making it so that links to invalid breadcrumb entries redirect
  to teh default tab (jsherril@redhat.com)
- Merge branch 'master' into thin (bbuckingham@redhat.com)
- Packages offset loading via "More..." now working with registered system.
  (jrist@redhat.com)
- 734026 - removing uneeded debug line that caused syncs to fail
  (mmccune@redhat.com)
- system templates - got floating box to work with scrolling properly and list
  to have internal scrolling instead of making the box bigger
  (jsherril@redhat.com)
- system templates - adding package add/remove on left hand content panel, and
  only showing package names (jsherril@redhat.com)
- system template - only show 20 packages in auto complete drop down
  (jsherril@redhat.com)
- packagegroups - refactor: move menthods to Glue::Pulp::Repo
  (inecas@redhat.com)
- Merge branch 'master' into sub (shughes@redhat.com)
- app server - update apache katello.conf to use candlepin cert
  (bbuckingham@redhat.com)
- View warning - address view warning on Org->Subscriptions (Object#id vs
  Object#object_id) (bbuckingham@redhat.com)
- View warnings - address view warnings resulting from incorrect usage of
  form_tag (bbuckingham@redhat.com)
- app server - changes to support /katello prefix in base path
  (bbuckingham@redhat.com)
- app server - removing init.d/thin (bbuckingham@redhat.com)
- product - removed org name from product name (tstrachota@redhat.com)
- katello.spec - add thin.yml to files (bbuckingham@redhat.com)
- katello.spec - remove thin/thin.conf (bbuckingham@redhat.com)
- Api for listing package groups and categories (inecas@redhat.com)
- promotion.js - uncomment line accidentally committed (bbuckingham@redhat.com)
- Automatic commit of package [katello] release [0.1.76-1].
  (lzap+git@redhat.com)
- app server - setting relative paths on fonts/images in css & js
  (bbuckingham@redhat.com)
- Adding changeset to system templates connection (paji@redhat.com)
- adding saving indicator and moving tree_loading css to be a class instead of
  an id (jsherril@redhat.com)
- Fixing error with spinner on pane. (jrist@redhat.com)
- adding package validation before adding (jsherril@redhat.com)
- Refresh of subs page. (jrist@redhat.com)
- Views - update to use image_tag helper (bbuckingham@redhat.com)
- Area to re-render subs. (jrist@redhat.com)
- 730358 - repo discovery now uses asynchronous tasks - the route has been
  changed to /organizations/ID/repositories/discovery/ (tstrachota@redhat.com)
- adding autocomplete for packages on system template page
  (jsherril@redhat.com)
- unsubscribe support for sub pools (shughes@redhat.com)
- making save functionality work to actually save template packages
  (jsherril@redhat.com)
- Merge branch 'subway' of ssh://git.fedorahosted.org/git/katello into subway
  (jrist@redhat.com)
- Fix for avail_subs vs. consumed_subs. (jrist@redhat.com)
- move sys pools and avail pools to private methods, reuse (shughes@redhat.com)
- 735359 - Don't create content in CP when creating a repo. (inecas@redhat.com)
- Adds class requirement 'filterable' on sliding lists that should be
  filterable by search box. (ehelms@redhat.com)
- Update to permission detail view to display verbs and tags in a cleaner way.
  (ehelms@redhat.com)
- Adds step indicators on permission create.  Adds more validation handling for
  blank name. (ehelms@redhat.com)
- initial subscription consumption, sunny day (shughes@redhat.com)
- Fixes to permission add and edit flow for consistency. (ehelms@redhat.com)
- More subscriptions work. Rounded top box with shadow and borders.  Fixed some
  other stuff with spinner. (jrist@redhat.com)
- Updated subscription spinner to have useful info. (jrist@redhat.com)
- More work on subscriptions page. (jrist@redhat.com)
- Small change for wrong sub.poolId. (jrist@redhat.com)
- Added a spinner to subscriptions. (jrist@redhat.com)
- added client side adding of packages to system templates
  (jsherril@redhat.com)
- fix error on not grabbing latest subscription pools (shughes@redhat.com)
- Fixed views for subscriptions. (jrist@redhat.com)
- Merge branch 'subway' of ssh://git.fedorahosted.org/git/katello into subway
  (jrist@redhat.com)
- Fixed a non i18n string. (jrist@redhat.com)
- support mvc better for subscriptions availability and consumption
  (shughes@redhat.com)
- Fixed a couple of errors that occured due to wrong sql in postgres
  (paji@redhat.com)
- Role editing commit that adds workflow functionality.  This also provides
  updated and edits to the create permission workflow. (ehelms@redhat.com)
- adding search and sorting to templates page (jsherril@redhat.com)
- moving system templates to a sliding tree and to the content section
  (jsherril@redhat.com)
- Modifies sliding tree action bar to require an identifier for the toggled
  item and a dictionary with the container and setup function to be called.
  This was in order to re-use the same HTML container for two different
  actions. (ehelms@redhat.com)
- change date format for sub expires (shughes@redhat.com)
- app server - removing script/rails ... developers will instead use
  script/thin start (bbuckingham@redhat.com)
- changing to DateTime to Date for expires sub (shughes@redhat.com)
- Wires up edit permission button and adds summary for viewing an individual
  permission. (ehelms@redhat.com)
- Apache - first pass update to katello.conf to add SSL
  (bbuckingham@redhat.com)
- thin - removing etc/thin/thin.yml (bbuckingham@redhat.com)
- Switches from ROLES object to KT.roles object. (ehelms@redhat.com)
- added consumed value for pool of subs (shughes@redhat.com)
- reset-dbs - katello-jobs are restarted now (lzap+git@redhat.com)
- Changes roles and permission success and error notices to include the name of
  the role/permission and fit the format of other pages. (ehelms@redhat.com)
- Validate uniqueness of repo name within a product scope (inecas@redhat.com)
- products - cp name now join of <org_name>-<product_name> used to be
  <provider_name>-<product_name> (tstrachota@redhat.com)
- sync - comparing strings instead of symbols in sync_status fix for AR
  returning symbols (tstrachota@redhat.com)
- sync - fix for sync_status failing when there were no syncable subitems
  (repos for product, products for providers) (tstrachota@redhat.com)
- sync - change in product&provider sync_status logic (tstrachota@redhat.com)
- provider sync status - cli + api (tstrachota@redhat.com)
- sync - spec tests for cancel and index actions (tstrachota@redhat.com)
- Subscriptions page changes to include consumed and non-consumed.
  (jrist@redhat.com)
- Subscriptions page coming along. (jrist@redhat.com)
- forgot to add this config file (mmccune@redhat.com)
- adding new 'thin' startup script (mmccune@redhat.com)
- remove debugger line (shughes@redhat.com)
- add expires to subscriptions (shughes@redhat.com)
- moving thin into a katello config (mmccune@redhat.com)
- Subscriptions page.  Mostly mocked up (no css yet). (jrist@redhat.com)
- making sure sliding tree does not double render on page load
  (jsherril@redhat.com)
- Fixes for editing name of changeset on changeset history page.
  (ehelms@redhat.com)
- Further re-work of HTML and JS model naming convention.  Changes the behavior
  of setting the HTML id for each model type by introducing a simple
  controller_name function that returns the controller name to be used for
  tupane, edit, delete and list items. (ehelms@redhat.com)
- Adds KT javascript global object for all other modules to attach to. Moves
  helptip and common to be attached to KT. (ehelms@redhat.com)
- Changes to Users page to fit new HTML model id convention.
  (ehelms@redhat.com)
- Changes Content Management page items to use new HTML model id convention.
  (ehelms@redhat.com)
- Changes to Systems page for HTML and JS model id. (ehelms@redhat.com)
- Changes Organizations section to use of new HTML model id convention.
  (ehelms@redhat.com)
- Changes to model id's in views. (ehelms@redhat.com)
- 734851 - service katello start - Permission denied (lzap+git@redhat.com)
- Refactor providers - remove unused routes (inecas@redhat.com)
- Automatic commit of package [katello] release [0.1.75-1].
  (lzap+git@redhat.com)
- 734833 - service katello-jobs stop shows non-absolute home (ArgumentError)
  (lzap+git@redhat.com)
- Refactor repo path generator (inecas@redhat.com)
- Merge branch 'repo-path' (inecas@redhat.com)
- Fix failing repo spec (inecas@redhat.com)
- Pulp repo for Locker products consistent with other envs (inecas@redhat.com)
- 734755 - Service katello-jobs status shows no file or directory
  (lzap+git@redhat.com)
- ueber cert - adding cli support (lzap+git@redhat.com)
- Refactor generating repo id when cloning (inecas@redhat.com)
- Change CP content url to product/repo (inecas@redhat.com)
- Scope system by readable permissions (inecas@redhat.com)
- Scope users by readable permissions (inecas@redhat.com)
- Scope products by readability scope (inecas@redhat.com)
- Refactor - move providers from OrganziationController (inecas@redhat.com)
- Fix scope error - readable repositories (inecas@redhat.com)
- Remove unused code: OrganizationController#providers (inecas@redhat.com)
- Authorization rules - fix for systmes auth check (inecas@redhat.com)
- More specific test case pro changeset permissions (inecas@redhat.com)
- Scope products for environment by readable providers (inecas@redhat.com)
- Fix bug in permissions (inecas@redhat.com)
- Scope orgranizations list in API by the readable permissions
  (inecas@redhat.com)
- Fix failing spec (inecas@redhat.com)
- Authorization rules for API actions (inecas@redhat.com)
- Integrate authorization rules to API controllers (inecas@redhat.com)
- Automatic commit of package [katello] release [0.1.74-1]. (paji@redhat.com)
- Fixed more bugs related to the katello.yml and spec (paji@redhat.com)
- Automatic commit of package [katello] release [0.1.73-1]. (paji@redhat.com)
- Fixed the db directory link (paji@redhat.com)
- Updated some spacing issues (paji@redhat.com)
- cleaning up subscriptions logic (shughes@redhat.com)
- add in subscription qty for systems (shughes@redhat.com)
- Automatic commit of package [katello] release [0.1.72-1]. (paji@redhat.com)
- Updated spec to not include database yml in etc katello and instead for the
  user to user /etc/katello/katello.yml for db info (paji@redhat.com)
- only allowing modification of a system template in locker within system
  templates controller (jsherril@redhat.com)
- adding spec tests for system_templates controller (jsherril@redhat.com)
- Merge remote-tracking branch 'origin/master' into repo-path
  (inecas@redhat.com)
- Fixed an accidental goof up in the systems controllers test (paji@redhat.com)
- made a more comprehensive test matrix for systems (paji@redhat.com)
- first pass at having Katello use thin and apache together
  (mmccune@redhat.com)
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
- fixing row height on system templates (jsherril@redhat.com)
- adding initial system template CRUD (jsherril@redhat.com)
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
- Automatic commit of package [katello] release [0.1.71-1].
  (jsherril@redhat.com)
- fixing a couple issues with promotions (jsherril@redhat.com)
- Small change to subscriptions page, uploading of assets for new subscriptions
  page. (jrist@redhat.com)
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
- Automatic commit of package [katello] release [0.1.70-1].
  (lzap+git@redhat.com)
- fixing miscommited database.yml (lzap+git@redhat.com)
- Role - Changes to javascript permission lockdown. (ehelms@redhat.com)
- Role - Adds tab order to permission widget input and some look and feel
  changes. (ehelms@redhat.com)
- Role - Makes permission name unique with a role and an organization.
  (ehelms@redhat.com)
- Role - Adds disable to Done button to prevent multiple clicks.
  (ehelms@redhat.com)
- Roles - updating role ui to use the new permissions model
  (bbuckingham@redhat.com)
- adding kill_pg_connection rake task (lzap+git@redhat.com)
- cli tests - removing assumeyes option (lzap+git@redhat.com)
- a workaround for candlepin issue: gpgUrl for content must exist, as it is
  used during entitlement certificate generation (dmitri@redhat.com)
- no need to specify content id for promoted repositories, as candlepin will
  assign it (dmitri@redhat.com)
- Format of CP content url: /org/env/productName/repoName (inecas@redhat.com)
- Automatic commit of package [katello] release [0.1.69-1].
  (lzap+git@redhat.com)
- 731670 - prevent user from deleting himself (lzap+git@redhat.com)
- 731670 - reformatting rescue block (lzap+git@redhat.com)
- Re-factor of Roles-UI javascript for performance. (ehelms@redhat.com)
- Modified the super admin before destroy query to use the new way to do super
  admins (paji@redhat.com)
- Re-factoring and fixes for setting summary on roles ui. (ehelms@redhat.com)
- ignore case for url validation (shughes@redhat.com)
- add in spec tests for invalid/valid file urls (shughes@redhat.com)
- support file based urls for validation (shughes@redhat.com)
- Adds better form and flow rest on permission widget. (ehelms@redhat.com)
- Fixes for wrong verbs showing up initially in permission widget.  Fix for
  non-display of tags on global permissions. (ehelms@redhat.com)
- Changes filter to input box.  Adds fixes for validation during permission
  creation. (ehelms@redhat.com)
- spec fixes (jsherril@redhat.com)
- merging changeset promotion status to master (jsherril@redhat.com)
- Users - fix issue where user update would remove user's roles
  (bbuckingham@redhat.com)
- Automatic commit of package [katello] release [0.1.68-1].
  (lzap+git@redhat.com)
- init script - fixing schema.rb permissions check (lzap+git@redhat.com)
- katello-jobs - suppressing error message for status info
  (lzap+git@redhat.com)
- Automatic commit of package [katello] release [0.1.67-1].
  (lzap+git@redhat.com)
- reset script - adding -f (force) option (lzap+git@redhat.com)
- reset script - missing candlepin restart string (lzap+git@redhat.com)
- Navigation related changes to hide different resources (paji@redhat.com)
- Fixing the initial summary on roles-ui page. (jrist@redhat.com)
- `Merge branch 'roles-ui' of ssh://git.fedorahosted.org/git/katello into
  roles-ui (jrist@redhat.com)
- Sliding tree summaries. (jrist@redhat.com)
- Role - Adds client side validation to permission widget steps.
  (ehelms@redhat.com)
- Adds enhancements to add/remove of users and permissions. (ehelms@redhat.com)
- hiding the promotion progress bar and replacing it with just text, also
  stopping the fade out upon completion (jsherril@redhat.com)
- fixing issue with promotions where if the repo didnt exist in the next env it
  would fail (jsherril@redhat.com)
- fixed a broken Api::SyncController test (dmitri@redhat.com)
- Automatic commit of package [katello] release [0.1.66-1].
  (lzap+git@redhat.com)
- katello-job - init.d script has proper name now (lzap+git@redhat.com)
- katello-job - temp files now in /var/lib/katello/tmp (lzap+git@redhat.com)
- katello-job - improving RAILS_ENV setting (lzap+git@redhat.com)
- adding Api::SyncController specs that I forgot to add earlier
  (dmitri@redhat.com)
- Automatic commit of package [katello] release [0.1.65-1].
  (lzap+git@redhat.com)
- katello-job - adding new init script for delayed_job (lzap+git@redhat.com)
- 731810 Deleteing a provider renders an server side error (inecas@redhat.com)
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
- spec tests for Glue::Pulp::Repo (tstrachota@redhat.com)
- merge of repo#get_{env,product,org} functionality (tstrachota@redhat.com)
- repo sync - check for syncing only repos in locker (tstrachota@redhat.com)
- fix bug with viewing systems with nil environments (shughes@redhat.com)
- 3rd level nav bumped up to 2nd level for systems (shughes@redhat.com)
- remove 3rd level nav from systems page (shughes@redhat.com)
- making promotions controller rules more readable (jsherril@redhat.com)
- updated routes to support changes in rhsm related to explicit specification
  of owners (dmitri@redhat.com)
- Subscriptions - fix accidental commit... :( (bbuckingham@redhat.com)
- having the systems environment page default to an environment the user can
  actually read (jsherril@redhat.com)
- Activation Keys - fix API rspec tests (inecas@redhat.com)
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
- Fix running rspec tests - move corrupted tests to pending (inecas@redhat.com)
- Api::SyncController, with tests now (dmitri@redhat.com)
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
- Automatic commit of package [katello] release [0.1.64-1].
  (mmccune@redhat.com)
- change sync plans to use org syncable permission (shughes@redhat.com)
- add sync resource to orgs (shughes@redhat.com)
- fix sync plan create/edit access (shughes@redhat.com)
- adjust sync plan to use provider readable access (shughes@redhat.com)
- remove sync plan resource type (shughes@redhat.com)
- remove sync plan permission on model (shughes@redhat.com)
- fixing hard coded IP address (mmccune@redhat.com)
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
- Changeset History - improve grid usage on edit view (bbuckingham@redhat.com)
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
- Merge branch 'master' into kstree (bbuckingham@redhat.com)
- Added some permission checking code on the save of a permission so that the
  perms with invalid resource types or verbs don;t get created
  (paji@redhat.com)
- Role - Adds validation to prevent blank name on permissions.
  (ehelms@redhat.com)
- Role - Fixes typo (ehelms@redhat.com)
- Role - Refactor to move generic actionbar code into sliding tree and add
  roles namespace to role_edit module. (ehelms@redhat.com)
- Merge branch 'master' into a-keys (bbuckingham@redhat.com)
- unit test fixes and adding some (jsherril@redhat.com)
- Activation Keys - update system template to support "No Template" option when
  one is not assigned or being selected (bbuckingham@redhat.com)
- BZ 730766 - products that exist in the target environment are now being
  synced during changeset promotion (dmitri@redhat.com)
- adding validator for permissions (jsherril@redhat.com)
- Notices - fix to enable login/logout notices to appear
  (bbuckingham@redhat.com)
- fix for verb check where symbol and string were not comparing correctly
  (jsherril@redhat.com)
- 730738 - fix notification on invalid login attempt (bbuckingham@redhat.com)
- User Session - fix haml warning (bbuckingham@redhat.com)
- BZ 722576 - it is possible to create two repositories with the same name for
  different products now. (dmitri@redhat.com)
- http error codes are now being populated in exceptions returned from
  HttpResource (dmitri@redhat.com)
- removing roles_user HABTM - class_name is not necessary (lzap+git@redhat.com)
- fixing unit tests for the HABTM change (lzap+git@redhat.com)
- Merge branch 'bz_705872' (lzap+git@redhat.com)
- removing roles_user HABTM (lzap+git@redhat.com)
- katello completion - update of changeset command (tstrachota@redhat.com)
- katello completion - update of product commands (tstrachota@redhat.com)
- new route /api/changesets/ for show, destroy, update and promote
  (tstrachota@redhat.com)
- Made resource type called 'All' instead of using nil for 'all' so that one
  can now check if user has permissions to all in a more transparent manner
  (paji@redhat.com)
- Merge branch 'master' into a-keys (bbuckingham@redhat.com)
- Notices - update js to check for existence of xhr in response
  (bbuckingham@redhat.com)
- making system environments work with env selector and permissions
  (jsherril@redhat.com)
- Role - Adds 'all' types selection to UI and allows creation of full access
  permissions on organizations. (ehelms@redhat.com)
- 719932 - fix invalid comment (bbuckingham@redhat.com)
- 719932 - subscription upload - fix endless spinner and error handling
  (bbuckingham@redhat.com)
- adapting promotions to use the env_selector with auth (jsherril@redhat.com)
- Distributions - fix error in distributions partial (bbuckingham@redhat.com)
- switching to a simpler string substitution that wont blow up on nil
  (mmccune@redhat.com)
- Merge branch 'roles-ui' of ssh://git.fedorahosted.org/git/katello into roles-
  ui (jrist@redhat.com)
- Org switcher with box shadow. (jrist@redhat.com)
- switching to a simpler string substitution that wont blow up on nil
  (mmccune@redhat.com)
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
- spec tests for promotions (tstrachota@redhat.com)
- 705872 - last superadmin should not be deletable (lzap+git@redhat.com)
- 723226 - Output of the provider commands use id instead of name
  (inecas@redhat.com)
- Automatic commit of package [katello] release [0.1.63-1].
  (lzap+git@redhat.com)
- 714167 - undeclared dependencies (regin & multimap) (lzap+git@redhat.com)
- Revert "714167 - broken dependencies is F14" (lzap+git@redhat.com)
- 725495 - katello service should return a valid result (lzap+git@redhat.com)
- Automatic commit of package [katello] release [0.1.62-1].
  (lzap+git@redhat.com)
- 714167 - broken dependencies is F14 (lzap+git@redhat.com)
- CLI - show last sync status in repo info and status (inecas@redhat.com)
- Import manifest for custom provider - friendly error message
  (inecas@redhat.com)
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
- Systems->Packages - convert to use common filtertable
  (bbuckingham@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (adprice@redhat.com)
- Distributions - add filter table to file list... made filter table generic
  for reuse (bbuckingham@redhat.com)
- Role - Adds Global permission adding and fixes to getting permission details
  with bbq hash rendering. (ehelms@redhat.com)
- better code coverage for changeset api controller (tstrachota@redhat.com)
- adding the correct route for package profile update (adprice@redhat.com)
- new (better?) logo (adprice@redhat.com)
- adding sysvinit script permission check for schema.rb (lzap+git@redhat.com)
- allowing users to override rake setup denial (lzap+git@redhat.com)
- Merge branch 'master' into kstree (bbuckingham@redhat.com)
- Moved jquery.ui.tablefilter.js into the jquery/plugins dir to conform with
  convention. (jrist@redhat.com)
- Working packages scrollExpand (morePackages). (jrist@redhat.com)
- Semi-working packages page. (jrist@redhat.com)
- System Packages scrolling work. (jrist@redhat.com)
- Currently not working packages scrolling. (jrist@redhat.com)
- System Packages - filter. (jrist@redhat.com)
- Role - Fix for creating new role.  Cleans up role.js (ehelms@redhat.com)
- Tupane - Removes previous custom_panel variable from tupane options and moves
  the logic into the role_edit.js file for overiding a single panel. New
  callbacks added to tupane javascript panel object. (ehelms@redhat.com)
- Role - Moved i18n for role edit to index page to only load once.  Added
  display of global permissions in list. Added heading for add permission
  widget.  Added basic global permission add widget. (ehelms@redhat.com)
- Role - Adds bbq hash clearing on panel close. (ehelms@redhat.com)
- fix for broken changeset controller spec tests (tstrachota@redhat.com)
- now logging both stdout and stderr in the initdb.log (lzap+git@redhat.com)
- forcing users not to run rake setup in prod mode (lzap+git@redhat.com)
- fixing more unit tests (jsherril@redhat.com)
- changeset cli - both environment id and name are displayed in lisitng and
  info (tstrachota@redhat.com)
- fox for repo repo promotion (tstrachota@redhat.com)
- fixed spec tests after changes in validation of changesets
  (tstrachota@redhat.com)
- fixed typo in model changeset_erratum (tstrachota@redhat.com)
- changesets - can't add packs/errata from repo that has not been promoted yet
  (tstrachota@redhat.com)
- changesets - fix for packages and errata removal (tstrachota@redhat.com)
- Automatic commit of package [katello] release [0.1.61-1].
  (lzap+git@redhat.com)
- rpm in /usr/share/katello - introducing KATELLO_DATA_DIR
  (lzap+git@redhat.com)
- Automatic commit of package [katello] release [0.1.60-1].
  (lzap+git@redhat.com)
- katello rpm now installs to /usr/share/katello (lzap+git@redhat.com)
- Update the permissions query to effectively deal with organization resource
  vs any other resource type (paji@redhat.com)
- Distributions - adding controller/view specs for distro list and view
  (bbuckingham@redhat.com)
- Merge branch 'master' into kstree (mmccune@redhat.com)
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
- fixing cancel sync DELETE action call (shughes@redhat.com)
- blocking off UI elements based on read/write perms for changeset history
  (jsherril@redhat.com)
- fixing permission http methods (jsherril@redhat.com)
- Role - Adds permission removal from Organization. (ehelms@redhat.com)
- Role - Adds pop-up panel close on breadcrumb change. (ehelms@redhat.com)
- fixing issue where environments would not show tags (jsherril@redhat.com)
- Role - Adds the ability to add and remove users from a role.
  (ehelms@redhat.com)
- Activation Keys - subscriptions - use pool id vs pool subscription id
  (bbuckingham@redhat.com)
- spec test for user allowed orgs perms (shughes@redhat.com)
- Activation Keys - UI associate user creating the key with the key
  (bbuckingham@redhat.com)
- _sprites.scss - fix errors on merge (bbuckingham@redhat.com)
- fixed api for listing products (tstrachota@redhat.com)
- changesets - products required by packages/errata/repos are no longer being
  promoted (tstrachota@redhat.com)
- changeset validations - can't add items from product that has not been
  promoted yet (tstrachota@redhat.com)
- A-Keys - test for consuming subscriptions form akeys (inecas@redhat.com)
- A-Keys - consume subscriptions when registering system with akey
  (inecas@redhat.com)
- A-Keys - create association to system (inecas@redhat.com)
- A-Keys - register system with activation keys - backend (inecas@redhat.com)
- Merge branch 'origin/master' into a-keys (inecas@redhat.com)
- adding support for distributions (kickstart trees) in changesets
  (mmccune@redhat.com)
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
- 727627 - Fix for not being able to go to Sync page. (jrist@redhat.com)
- locking down sync plans according to roles (jsherril@redhat.com)
- adding back accounts controller since it is a valid stub
  (jsherril@redhat.com)
- removing unused controllers (jsherril@redhat.com)
- hiding UI widets for systems based on roles (jsherril@redhat.com)
- removing consumers controller (jsherril@redhat.com)
- fix for org selection of allowed orgs (shughes@redhat.com)
- spec tests for org selector (shughes@redhat.com)
- Distribution - fix spacing (bbuckingham@redhat.com)
- Distributions - add basic distro list and view to Promotions
  (bbuckingham@redhat.com)
- blocking UI widgets for organizations based on roles (jsherril@redhat.com)
- route for org selector (shughes@redhat.com)
- stubbing out user sesson spec tests for org selector (shughes@redhat.com)
- ability to select org (shughes@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (adprice@redhat.com)
- final solution for better RestClient exception messages (lzap+git@redhat.com)
- only relevant logs are rotated now (lzap+git@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (bkearney@redhat.com)
- Have the rake task emit wiki markup as well (bkearney@redhat.com)
- Automatic commit of package [katello] release [0.1.59-1].
  (lzap+git@redhat.com)
- improving katello-reset-dbs script (lzap+git@redhat.com)
- Fixes for failing activation_keys and organization tests. (jrist@redhat.com)
- hiding select UI widgets based on roles in users controller
  (jsherril@redhat.com)
- Grid_16 wrap on subnav for systems. (jrist@redhat.com)
- Oops, had a >>>>HEAD still. (jrist@redhat.com)
- Additional work on confirm boxes. (jrist@redhat.com)
- Confirm override on environments, products, repositories, providers, and
  organizations. (jrist@redhat.com)
- Working alert override. (jrist@redhat.com)
- Merged in changes from refactor of confirm. (jrist@redhat.com)
- Added code to return all details about a resource type as opposed to just the
  name for the roles perms pages (paji@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (bkearney@redhat.com)
- Add in a new rake task to generate the API (bkearney@redhat.com)
- renaming couple of old updatable methods to editable (jsherril@redhat.com)
- adding ability to get the list of available organizations for a user
  (jsherril@redhat.com)
- Merge branch 'master' into kstree (bbuckingham@redhat.com)
- walling off access to UI bits in providers management (jsherril@redhat.com)
- Distributions - add empty distribution selection to Promotions
  (bbuckingham@redhat.com)
- A-Keys - Subscription: Fix for error when attempting to display subscriptions
  with allocated quantities. (ehelms@redhat.com)
- Automatic commit of package [katello] release [0.1.58-1].
  (lzap+git@redhat.com)
- solution to bundle install issues (lzap+git@redhat.com)
- Revert "spec - adding regin dep as workaround for BZ 714167"
  (lzap+git@redhat.com)
- Revert "spec - adding workaround for BZ 714167 (F15)" (lzap+git@redhat.com)
- Revert "spec - introducing bundle install in %%build section"
  (lzap+git@redhat.com)
- initial commit of reset-dbs script (lzap+git@redhat.com)
- A-keys - store user with the activation key (inecas@redhat.com)
- fixing repo sync (lzap+git@redhat.com)
- fixing operations controller rules (jsherril@redhat.com)
- fixing user controller roles (jsherril@redhat.com)
- some roles controller fixes for rules (jsherril@redhat.com)
- fixing rules controller rules (jsherril@redhat.com)
- fixing a few more controllers (jsherril@redhat.com)
- improving REST exception messages (lzap+git@redhat.com)
- fixing more katello-cli tests (lzap+git@redhat.com)
- fixing rules for subscriptions controller (jsherril@redhat.com)
- Made the roles controller deal with the new model based rules
  (paji@redhat.com)
- Made permission model deal with 'no-tag' verbs (paji@redhat.com)
- fixing sync mgmnt controller rules (jsherril@redhat.com)
- custom partial for tupane system show calls (shughes@redhat.com)
- adding better rules for provider, products, and repositories
  (jsherril@redhat.com)
- Merge branch 'master' into a-keys (bbuckingham@redhat.com)
- 720442: fixing system refresh on name update (shughes@redhat.com)
- Activation Keys - adding specs for the edit env partial
  (bbuckingham@redhat.com)
- Activation Keys - adding the edit env partial (bbuckingham@redhat.com)
- Activation Keys - adding some specs for system templates
  (bbuckingham@redhat.com)
- 726402: fix for nil object on sys env page (shughes@redhat.com)
- fixing organization and environmental rules (jsherril@redhat.com)
- getting promotions and changesets working with new role structure, fixing
  user referencing (jsherril@redhat.com)
- added option to update system's location via python client
  (adprice@redhat.com)
- 729110: fix for product sync status visual updates (shughes@redhat.com)
- making editable updatable (jsherril@redhat.com)
- adding system rules (jsherril@redhat.com)
- Activation Keys - fix tests broken by intro of system templates
  (bbuckingham@redhat.com)
- Activation Keys - remove debugger from the controller
  (bbuckingham@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (adprice@redhat.com)
- Upgrading check to Candlepin 0.4.10-1 (lzap+git@redhat.com)
- removing commented code from api systems controller spec (adprice@redhat.com)
- Activation Keys - remove prefix from env path (bbuckingham@redhat.com)
- Merge branch 'master' into consumers (adprice@redhat.com)
- Activation Keys - system template support on crud (bbuckingham@redhat.com)
- adding rules to subscription page (jsherril@redhat.com)
- removing with indifferent access, since authorize now handles this
  (jsherril@redhat.com)
- adding environment rule enforcement (jsherril@redhat.com)
- adding rules to the promotions controller (jsherril@redhat.com)
- adding operations rules for role enforcement (jsherril@redhat.com)
- adding roles enforcement for the changesets controller (jsherril@redhat.com)
- changing to different url validation. can now be used outside of model layer.
  (adprice@redhat.com)
- Merge branch 'master' into roles-ui (ehelms@redhat.com)
- A-Keys - CLI: system register (inecas@redhat.com)
- using org instead of org_id for rules (jsherril@redhat.com)
- adding rules for sync management and modifying the sync management javascript
  to send product ids (jsherril@redhat.com)
- Fixed some rules for org_controller and added rules for users and roles pages
  (paji@redhat.com)
- making provider permission rules more generic (jsherril@redhat.com)
- Activation Key - Subscription (ehelms@redhat.com)
- spec tests for repositories controller (shughes@redhat.com)
- Activation Key - Subscription (ehelms@redhat.com)
- Activation Key - Subscription (ehelms@redhat.com)
- Merge branch 'master' into consumers (adprice@redhat.com)
- 728295: check for valid urls for yum repos (shughes@redhat.com)
- moving subscriptions and subscriptions update to different actions, and
  adding permission rules for providers, products, and repositories controllers
  (jsherril@redhat.com)
- adding spec tests for api systems_controller (upload packages, view packages,
  update a system) (adprice@redhat.com)
- Activation Keys - Subscriptions (ehelms@redhat.com)
- added functionality to api systems controller in :index, :update, and
  :package_profile (adprice@redhat.com)
- support for checking missing url protocols (shughes@redhat.com)
- changing pulp consumer update messages to show old name (adprice@redhat.com)
- improve protocol match on reg ex url validation (shughes@redhat.com)
- removing a debugger statement (adprice@redhat.com)
- fixing broken orchestration in pulp consumer (adprice@redhat.com)
- spec test for katello url helper (shughes@redhat.com)
- fix url helper to match correct length port numbers (shughes@redhat.com)
- url helper validator (http, https, ftp, ipv4) (shughes@redhat.com)
- Revert "fix routing problem for POST /organizations/:organzation_id/systems"
  (inecas@redhat.com)
- fix routing problem for POST /organizations/:organzation_id/systems (=)
- pretty_routes now prints some message to the stdout (lzap+git@redhat.com)
- Automatic commit of package [katello] release [0.1.57-1].
  (lzap+git@redhat.com)
- spec - adding workaround for BZ 714167 (F15) (lzap+git@redhat.com)
- spec - adding regin dep as workaround for BZ 714167 (lzap+git@redhat.com)
- added systems packages routes and update to systems (adprice@redhat.com)
- Automatic commit of package [katello] release [0.1.56-1].
  (lzap+git@redhat.com)
- spec - introducing bundle install in %%build section (lzap+git@redhat.com)
- Cleaned up the notices to authorize based with out a user perm. Don;t see a
  case for auth on notices. (paji@redhat.com)
- Made the app controller accept a rules manifest from each controller before
  authorizing (paji@redhat.com)
- Activation Keys - Subscription (ehelms@redhat.com)
- Initial commit on the the org controllers authorization (paji@redhat.com)
- Activation Keys - Subscriptions (ehelms@redhat.com)
- Removed the use of superadmin flag since its a permission now
  (paji@redhat.com)
- two spec fixes (jsherril@redhat.com)
- Merge branch 'system_errata' (dmitri@redhat.com)
- added a test for Api::SystemsController#errata call (dmitri@redhat.com)
- listing of errata by system is functional now (dmitri@redhat.com)
- Roles cleanup + unit tests cleanup (paji@redhat.com)
- A-Keys - Subscriptions (ehelms@redhat.com)
- added a script to make rake routes output prettier (adprice@redhat.com)
- a few promotion fixes, waiting on syncing was n ot working, client side
  updater was caching (jsherril@redhat.com)
- Activation Keys - update grid in partials to use the extra space
  (bbuckingham@redhat.com)
- Merge branch 'master' into a-keys (bbuckingham@redhat.com)
- Views - update grid in various partial to account for panel size change
  (bbuckingham@redhat.com)
- Providers - fix error on inline edit for Products and Repos
  (bbuckingham@redhat.com)
- Optimized the permission check query from the Users side (paji@redhat.com)
- fixed pulp consumer package profile upload and added consumer update to pulp
  resource (adprice@redhat.com)
- fixing promotion backend to sync the cloned repo and not the repo that you
  are promoting (jsherril@redhat.com)
- Updated database.yml so that one could now update katello.yml for db info
  (paji@redhat.com)
- Activation Keys - initial commit to add system template to UI
  (bbuckingham@redhat.com)
- changing notice on promotion (jsherril@redhat.com)
- fixing issue where promotion could cause a db lock error, fixed by not
  modifying the outside of itself (jsherril@redhat.com)
- fixing issue where promoted changeset was not removed from the
  changeset_breadcrumb (jsherril@redhat.com)
- Promotion - Adjusts alignment of changesets in the list when progress and
  locked. (ehelms@redhat.com)
- Merge branch 'master' into consumers (adprice@redhat.com)
- Promotions - Changes to alignment in changesets when being promoted and
  locked. (ehelms@redhat.com)
- Promtoions - Fixes issue with title not appearing on a changeset being
  promoted. Changes from redirect on promote of a changeset to return user to
  list of changesets to see progress. (ehelms@redhat.com)
- fixing types of changesets shown on the promotions page (jsherril@redhat.com)
- removing unused systems action - list systems (lzap+git@redhat.com)
- 726760 - Notices: Fixes issue with promotion notice appearing on every page.
  Fixes issue with synchronous notices not being marked as viewed.
  (ehelms@redhat.com)
- Tupane - Fixes issue with main panel header word-wrapping on long titles.
  (ehelms@redhat.com)
- 727358 - Tupane: Fixes issue with tupane subpanel header text word-wrapping.
  (ehelms@redhat.com)
- Improved the allowed_to method to make use of rails scoping features
  (paji@redhat.com)
- Removed a duplicated unit test (paji@redhat.com)
- Fixed the role file to more elegantly handle the allowed_to and not
  allowed_to cases (paji@redhat.com)
- Updated the permissions model to deal with nil orgs and nil resource types
  (paji@redhat.com)
- removed rogue debugger statement (ehelms@redhat.com)
- Promotions - Progress polling for a finished changeset now ceases upon
  promotion reaching 100%%. (ehelms@redhat.com)
- Fixes issue with lock icon showing up when progress. Fixes issue with looking
  for progress as a number - should receive string. (ehelms@redhat.com)
- adding some non-accurate progress incrementing to changesets
  (jsherril@redhat.com)
- Promotions - Updated to submit progress information from real data off of
  changest task status. (ehelms@redhat.com)
- getting async job working with promotions (jsherril@redhat.com)
- Added basic progress spec test. Added route for getting progress along with
  stubbed controller action to return progress for a changeset.
  (ehelms@redhat.com)
- 2Panel - Makes font resizing occur only on three column panels.
  (ehelms@redhat.com)
- matching F15 gem versions for tzinfo and i18n (mmccune@redhat.com)
- Adds new callback when rendering is done for changeset lists that adds locks
  and progress bars as needed on changeset list load. (ehelms@redhat.com)
- Adds javascript functionality to set a progress bar on a changeset, update it
  and remove it. Adds javascript functionality to add and remove locked status
  icons from changests. (ehelms@redhat.com)
- changing the home directory of katello to /usr/lib64/katello after recent
  spec file changes (jsherril@redhat.com)
- adding changeset dependencies to be stored upon promotion time
  (jsherril@redhat.com)
- Merge branch 'master' into consumers (adprice@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (adprice@redhat.com)
- adding to systems_controller spec tests and other small changes.
  (adprice@redhat.com)
- fixing find_organization in api/systems_controller. (adprice@redhat.com)
- Automatic commit of package [katello] release [0.1.55-1].
  (lzap+git@redhat.com)
- spec - rpmlint cleanup (lzap+git@redhat.com)
- making changeset history show items by product (jsherril@redhat.com)
- adding descripiton to changeset history page (jsherril@redhat.com)
- 726768 - jnotify - close notice on x click and update to fade quicker on
  close (bbuckingham@redhat.com)
- 2panel - Adds default left panel sizing depending on number of columns for
  left panel in 2 panel views.  Adds option to 2panel for default width to be
  customizably set using left_panel_width option. (ehelms@redhat.com)
- Changes sizing of provider new page to not cause horizntal scroll bar at
  minimum width. (ehelms@redhat.com)
- added action in api systems controller to get full package list for a
  specific system. (adprice@redhat.com)
- fixed pulp-proxy-controller to be correct http action (adprice@redhat.com)
- Merge branch 'master' into system_errata (dmitri@redhat.com)
- fixed reporting of progress during repo synchronization in UI
  (dmitri@redhat.com)
- fixed an issue with Api::ActivationKeysController#index when list of all keys
  for an environment was being retrieved (dmitri@redhat.com)
- Added api support for activation keys (dmitri@redhat.com)
- Refactor - Converts all remaining javascript inclusions to new style of
  inclusion that places scripts in the head. (ehelms@redhat.com)
- Adds resize event listener to scroll-pane to account for any element in a
  tupane panel that increases the size of the panel and thus leads to needing a
  scroll pane reinitialization. (ehelms@redhat.com)
- Edits to enlarge tupane to take advantage of more screen real estate.
  Changeset package selection now highlights to match the rest of the
  promotions page highlighting. (ehelms@redhat.com)
- General UI - disable hover on Locker when Locker not clickable
  (bbuckingham@redhat.com)
- api error reporting - final solution (lzap+git@redhat.com)
- Revert "introducing application error exception for API"
  (lzap+git@redhat.com)
- Revert "ApiError - fixing unit tests" (lzap+git@redhat.com)
- ApiError - fixing unit tests (lzap+git@redhat.com)
- introducing application error exception for API (lzap+git@redhat.com)
- fixing depcheck helper script (lzap+git@redhat.com)
- Initial commit on Updated Roles UI functionality (paji@redhat.com)
- Adds scroll pane support for roles page when clicking add permission button.
  (ehelms@redhat.com)
- removal of jasmine and addition of webrat, nokogiri (shughes@redhat.com)
- Activation Keys - enabled specs that required webrat matchers
  (bbuckingham@redhat.com)
- spec_helper - update to support using webrat (bbuckingham@redhat.com)
- adding description for changeset creation (jsherril@redhat.com)
- Tupane - Fixes for tupane fixed position scrolling to allow proper behavior
  when window resolution is below the minimum 960px. (ehelms@redhat.com)
- remove jasmine from deps (shughes@redhat.com)
- adding dev testing gems (shughes@redhat.com)
- added Api::ActivationController spec (dmitri@redhat.com)
- added activation keys api controller (dmitri@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (bbuckingham@redhat.com)
- fixing merge issues with changeset dependencies (jsherril@redhat.com)
- initial dependency spec test (jsherril@redhat.com)
- adding changeset dependency resolving take 2 (jsherril@redhat.com)
- Merge branch 'master' into a-keys (bbuckingham@redhat.com)
- making changeset dep. solving work on product level instead of across the
  entire environment (jsherril@redhat.com)
- adding description to Changeset object, and allowing editing of the
  description (jsherril@redhat.com)
- adding icons and fixing some spacing with changeset controls
  (jsherril@redhat.com)
- updated control bar for changesets, including edit (jsherril@redhat.com)
- Automatic commit of package [katello] release [0.1.54-1].
  (lzap+git@redhat.com)
- spec - logging level can be now specified in the sysconfig
  (lzap+git@redhat.com)
- bug 726030 - Webrick wont start with the -d (daemon) option
  (lzap+git@redhat.com)
- spec - service start forces you to run initdb first (lzap+git@redhat.com)
- adding a warning message in the sysconfig comment setting
  (lzap+git@redhat.com)
- Merge branch 'pack-profile' (adprice@redhat.com)
- production.rb now symlinked to /etc/katello/environment.rb
  (lzap+git@redhat.com)
- 725793 - Permission denied stylesheets/fancyqueries.css (lzap+git@redhat.com)
- 725901 - Permission errors in RPM (lzap+git@redhat.com)
- 720421 - Promotions Page: Adds fade in of items that meet search criteria
  that have previously been hidden due to previously not meeting a given search
  criteria. (ehelms@redhat.com)
- ignore zanta cache files (shughes@redhat.com)
- Fix for a-keys row height. (jrist@redhat.com)
- Merge branch 'master' into pack-profile (adprice@redhat.com)
- added pulp-consumer creation in system registration, uploading pulp-consumer
  package-profile via api, tests (adprice@redhat.com)
- Automatic commit of package [katello] release [0.1.53-1].
  (shughes@redhat.com)
- modifying initd directory using fedora recommendation,
  https://fedoraproject.org/wiki/Packaging/RPMMacros (shughes@redhat.com)
- Merge branch 'master' into a-keys (bbuckingham@redhat.com)
- Automatic commit of package [katello] release [0.1.52-1].
  (mmccune@redhat.com)
- Darker default body text. #1a1a1a (jrist@redhat.com)
- Merge branch 'a-keys' of ssh://git.fedorahosted.org/git/katello into a-keys
  (ehelms@redhat.com)
- Fixes issue where when a jeditable field was clicked on, and expanded the
  contents of a panel beyond visible no scroll bar would previously appear.
  This change involved a slight re-factor to jeditable helpers to trim down and
  re-factor commonality.  Also, this change involved edits to the jeditable
  plugin itself, thus as of this commit jquery.jeditable is no longer in sync
  with the original repository. (ehelms@redhat.com)
- move akeys tests to systems (shughes@redhat.com)
- qunit akeys html container (shughes@redhat.com)
- Removing screen.scss. (jrist@redhat.com)
- comment for why we git ignore lc_messages dir (shughes@redhat.com)
- remove fuzzy translations so they can be used with gettext:pack
  (shughes@redhat.com)
- Stroke_cl should be $stroke_color (jrist@redhat.com)
- Fix for other colors in screen.scss - we should remove this.
  (jrist@redhat.com)
- Fix for $lightgrey issue. (jrist@redhat.com)
- Activation Keys - removing unused js (bbuckingham@redhat.com)
- new locale strings (shughes@redhat.com)
- 725684 - Katello-cli does not accept any parameter with space in it
  (lzap+git@redhat.com)
- 719736 - Enforced the  cant delete current org restriction on the controller
  side (paji@redhat.com)
- 719736 - Added a restriction to not be able to delete the users current
  organization to prevent org switching anomalies (paji@redhat.com)
- Quick fix to make sure repo ids with - dont get translated to _
  (paji@redhat.com)
- Made pulp repo ids replace space with _ (paji@redhat.com)
- Fixed a bug that occured on create enviornment (paji@redhat.com)
- Fix for compass being initialized twice.  No need to initialize it with the
  newer version since it has a Railtie initializer. (jrist@redhat.com)
- Tupane - Edits to make tupane panel and subpanel sizing better, especially
  when resizing a window and when the left hand panel is at its minimum height.
  (ehelms@redhat.com)
- 711857 - Made add_env controller code  use cp key for org name, so that its
  consistent with the rest of UI (paji@redhat.com)
- 720047 - Changes repo URL editable type to textarea to help with long URL
  names. (ehelms@redhat.com)
- Fixes bug that was causing Provider creation to make two ajax requests.
  (ehelms@redhat.com)
- Adjusts the filter box on the promotions page for firefox and chrome
  rendering. (ehelms@redhat.com)
- Merge branch 'master' into a-keys (bbuckingham@redhat.com)
- 715398 - Search - remove unnecessary call to errors (bbuckingham@redhat.com)
- 715398 - Search - do not allow saving of an invalid search
  (bbuckingham@redhat.com)
- added support for listing errata by system (dmitri@redhat.com)
- Bumping some gems and fixing the scss as part of that. (jrist@redhat.com)
- Automatic commit of package [katello] release [0.1.51-1].
  (shughes@redhat.com)
- upgrade to compas-960-plugin 0.10.4 (shughes@redhat.com)
- upgrade to compas 0.11.5 (shughes@redhat.com)
- upgrade to haml 3.1.2 (shughes@redhat.com)
- spec - fixing katello.org url (lzap+git@redhat.com)
- Upgrades jQuery to 1.6.2. Changes Qunit tests to reflect jQuery version
  change and placement of files from Refactor. (ehelms@redhat.com)
- Activation Keys - add environment to search (bbuckingham@redhat.com)
- Fixes height issue with subpanel when left panel is at its minimum height.
  Fixes issue with subpanel close button closing both main and subpanel.
  (ehelms@redhat.com)
- Merge branch 'a-keys' of ssh://git.fedorahosted.org/git/katello into a-keys
  (bbuckingham@redhat.com)
- Activation Keys - update to use new tupane layout + spec impacts
  (bbuckingham@redhat.com)
- Automatic commit of package [katello] release [0.1.50-1].
  (shughes@redhat.com)
- Simple-navigation 3.3.4 fixes.  Also fake-systems needed bundle exec before
  rails runner. (jrist@redhat.com)
- Merge branch 'master' into pack-profile (adprice@redhat.com)
- Merge branch 'master' into a-keys (bbuckingham@redhat.com)
- adding new simple-navigation deps to lock (shughes@redhat.com)
- bumping simple navigation to 3.3.4 (shughes@redhat.com)
- adding new simple-navigation 3.3.4 (shughes@redhat.com)
- increased priority of candlepin consumer creation to go before pulp
  (adprice@redhat.com)
- test for multiple subscriptions assignement to keys (shughes@redhat.com)
- Activation Keys - make it more obvious that user should select env :)
  (bbuckingham@redhat.com)
- Merge branch 'master' into refactor (eric.d.helms@gmail.com)
- fixed a failing Api::ProductsController spec (dmitri@redhat.com)
- Activation Keys - adding some additional specs (e.g. for default env)
  (bbuckingham@redhat.com)
- Activation Keys - removing empty spec (bbuckingham@redhat.com)
- fixed several failing tests in katello-cli-simple-test suite
  (dmitri@redhat.com)
- Activation Keys - removing checkNotices from update_subscriptions
  (bbuckingham@redhat.com)
- Activation Keys - add Remove link to the subscriptions tab
  (bbuckingham@redhat.com)
- Merge branch 'master' into a-keys (bbuckingham@redhat.com)
- Acttivatino Keys - Adding support for default environment
  (bbuckingham@redhat.com)
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
- spec test for successful subscription updates (shughes@redhat.com)
- spec test for invalid activation key subscription update (shughes@redhat.com)
- correctly name spec description (shughes@redhat.com)
- spec model for multiple akey subscription assigment (shughes@redhat.com)
- akey subscription update sync action (shughes@redhat.com)
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
- ajax call to update akey subscriptions (shughes@redhat.com)
- akey subscription update action (shughes@redhat.com)
- fix route for akey subscription updates (shughes@redhat.com)
- Merge branch 'master' into refactor (ehelms@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (ehelms@redhat.com)
- refactor akey subscription list (shughes@redhat.com)
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
- bi direction test for akeys/subscriptions (shughes@redhat.com)
- models for activation key subscription mapping (shughes@redhat.com)
- Merge branch 'master' into refactor (ehelms@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (ehelms@redhat.com)
- CSS Refactor - Changes the tupane subpanel to conform with the new tupane
  layout and changes environment, product and repo creation to fit new layout.
  (ehelms@redhat.com)
- CSS Refactor - Changes tupane sizing to work with window resize and sets a
  min height. (ehelms@redhat.com)
- Merge branch 'master' into pack-profile (adprice@redhat.com)
- update 32x32 icon. add physical/virtual system icons. (jimmac@gmail.com)
- renaming/adding some candlepin and pulp consumer methods.
  (adprice@redhat.com)
- CSS Refactor - Changes to changeset history page to use tupane layout.
  (ehelms@redhat.com)
- CSS Refactor - Changes promotions page partials that use tupane to use new
  layout. (ehelms@redhat.com)
- Activation Keys - fix failed specs (bbuckingham@redhat.com)
- CSS Refactor - Changes sync plans page to new tupane layout.
  (ehelms@redhat.com)
- Activation Keys - adding helptip text to panel and general pane
  (bbuckingham@redhat.com)
- CSS Refactor - Converts providers page to use tupane layout.
  (ehelms@redhat.com)
- proxy controller changes (adprice@redhat.com)
- CSS Refactor - Modifies users and roles pages to use new tupane layout.
  (ehelms@redhat.com)
- CSS Refactor - Converts organization tupane partials to use new layout.
  (ehelms@redhat.com)
- Merge branch 'master' into a-keys (bbuckingham@redhat.com)
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
- Activation Keys - ugh.. clean up validation previous commit
  (bbuckingham@redhat.com)
- Activation Keys - update so key name is unique within an org
  (bbuckingham@redhat.com)
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
- Activation Key - fix akey create (bbuckingham@redhat.com)
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
- Activation Keys - initial specs for views (bbuckingham@redhat.com)
- Activation Keys - update edit view to improve testability
  (bbuckingham@redhat.com)
- fixed template promotions when performed through api (dmitri@redhat.com)
- 721327 - more correcting gem versions to match (mmccune@redhat.com)
- Activation Keys - update _new partial to eliminate warning during render
  (bbuckingham@redhat.com)
- Activation Keys - removing unused _form partial (bbuckingham@redhat.com)
- multiselect support for akey subscriptions (shughes@redhat.com)
- 721327 - cleaning up mail version numbers to match what is in Fedora
  (mmccune@redhat.com)
- Merge branch 'master' into a-keys (bbuckingham@redhat.com)
- Activation Keys - update to ensure error notice is generated on before_filter
  error (bbuckingham@redhat.com)
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
- Automatic commit of package [katello] release [0.1.49-2].
  (eric.d.helms@gmail.com)
- adding in activation key mapping to subscriptions (shughes@redhat.com)
- add jquery multiselect to akey subscription associations (shughes@redhat.com)
- views for activation key association to subscriptions (shughes@redhat.com)
- added product synchronization (async) (dmitri@redhat.com)
- Updates to use version 0.11.5 or greater of Compass. (eric.d.helms@gmail.com)
- Adds padding to empty changeset text. (eric.d.helms@gmail.com)
- Merge branch 'tasks' (dmitri@redhat.com)
- 720412 - changing promotions helptip to say that a changeset needs to be
  created, as well as hiding add buttons if a piece of content cannot be added
  instead of disabling it (jsherril@redhat.com)
- Merge branch 'master' into refactor (eric.d.helms@gmail.com)
- initdb does not print unnecessary info anymore (lzap+git@redhat.com)
- ignoring ping.rb in code coverage (lzap+git@redhat.com)
- do not install .gitkeep files (msuchy@redhat.com)
- setting failure threshold to code coverage to 60 %% (lzap+git@redhat.com)
- adding failure threshold to code doverage (lzap+git@redhat.com)
- Navigation - remove Groups from Systems subnav (bbuckingham@redhat.com)
- Activation Keys - controller specs for initial crud support
  (bbuckingham@redhat.com)
- 720414 - fixing issue where hitting enter while on the new changeset name box
  would result in a form submitting (jsherril@redhat.com)
- added specs for TaskStatus model and controller (dmitri@redhat.com)
- adding activation key routes for handling subscription paths
  (shughes@redhat.com)
- removed Glue::Pulp::Sync (dmitri@redhat.com)
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
- Activation Keys - fix the _edit view post adding subnav
  (bbuckingham@redhat.com)
- Activation Keys - adding the forgotten views... (bbuckingham@redhat.com)
- Activation Keys - added subnav for subscriptions (bbuckingham@redhat.com)
- Merge branch 'master' into a-keys (bbuckingham@redhat.com)
- auto_complete_search - move routes in to collection blocks
  (bbuckingham@redhat.com)
- initial akey model spec tests (shughes@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (mmccune@redhat.com)
- adding spec test (mmccune@redhat.com)
- hopefully done changing 'locker' to 'Locker' (adprice@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (ehelms@redhat.com)
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
- Activation Keys - update index to request based on current org and fix model
  error (bbuckingham@redhat.com)
- Activation Keys - model - org and env associations (bbuckingham@redhat.com)
- Merge branch 'master' into a-keys (bbuckingham@redhat.com)
- added optional functionality for org and environment inclusion in template
  viewing (adprice@redhat.com)
- 720003 - moves page load notifications inside document ready function to
  properly display across browsers (ehelms@redhat.com)
- Sync Plans - refactor editable to remove duplication (bbuckingham@redhat.com)
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
- Systems - refactor editabl to remove duplication (bbuckingham@redhat.com)
- Environment - refactor editable to remove duplication
  (bbuckingham@redhat.com)
- spec - moving syntax checks to external script (CI) (lzap+git@redhat.com)
- users - better logging during authentication (lzap+git@redhat.com)
- users - updating bash completion (lzap+git@redhat.com)
- users - adding support for users CRUD in CLI (lzap+git@redhat.com)
- api auth code stores user/pass with auth_ prefix (lzap+git@redhat.com)
- Organization - refactor editable to remove duplication
  (bbuckingham@redhat.com)
- Providers - refactor editable to remove duplication (bbuckingham@redhat.com)
- Merge branch 'master' into a-keys (bbuckingham@redhat.com)
- Merge branch 'master' of ssh://git.fedorahosted.org/git/katello
  (ehelms@redhat.com)
- Added missing loginpage css file. (ehelms@redhat.com)
- add daemons gem dep for delayed job (shughes@redhat.com)
- Merge branch 'master' into a-keys (bbuckingham@redhat.com)
- Adds section in head of katello.yml for including extra javascripts from a
  template view.  This is intended to move included javascripts out of the
  body. (ehelms@redhat.com)
- Activation Keys - first commit - initial support for CRUD
  (bbuckingham@redhat.com)
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
- Automatic commit of package [katello] release [0.1.49-1].
  (lzap+git@redhat.com)
- fixing db/schema.rb symlink in the spec (lzap+git@redhat.com)
- adding environment support to initdb script (lzap+git@redhat.com)
- remove commented debugger in header (shughes@redhat.com)
- 715421: fix for product size after successful repo(s) sync
  (shughes@redhat.com)
- ownergeddon - fixing unit tests (lzap+git@redhat.com)
- ownergeddon - organization is needed for systems now (lzap+git@redhat.com)
- db/schema.rb now symlinked into /var/lib/katello (lzap+git@redhat.com)
- new initscript 'initdb' command (lzap+git@redhat.com)
- ownergeddon - bumping version to 0.4.4 for candlepin (lzap+git@redhat.com)
- ownergeddon - improving error message (lzap+git@redhat.com)
- ownergeddon - support for explicit org (lzap+git@redhat.com)
- ownergeddon - user now created using new API (lzap+git@redhat.com)
- ownergeddon - user refactoring (lzap+git@redhat.com)
- ownergeddon - introducing CPUser entity (lzap+git@redhat.com)
- ownergeddon - refactoring name_to_key (lzap+git@redhat.com)
- ownergeddon - whitespace (lzap+git@redhat.com)
- adding page reloading as the changeset changes (jsherril@redhat.com)
- fixed tests that contained failing environment creation (adprice@redhat.com)
- spec test for empty changesetuser on index view (shughes@redhat.com)
- Merge branch 'master' into env_tests (adprice@redhat.com)
- Merge branch 'master' into promotions (jrist@redhat.com)
- fixed failing environment creation test (dmitri@redhat.com)
- fixing bug with ChangesetUser (jsherril@redhat.com)
- Merge branch 'promotions' of ssh://git.fedorahosted.org/git/katello into
  promotions (ehelms@redhat.com)
- making changsets be stored client side, lots still broken
  (jsherril@redhat.com)
- Small change for padding around helptip. (jrist@redhat.com)
- adding controller logic and spec test for changesetuser destroy
  (shughes@redhat.com)
- adding find or create spec test for changeset model (shughes@redhat.com)
- Fixes to create and delete changesets properly with associated test fixes.
  (ehelms@redhat.com)
- Removed previous default name setting in kp_environment changeset creation
  and moved it into the changeset model. (ehelms@redhat.com)
- 6692 & 6691: removed hardcoded admin user, as well as usernames and passwords
  from katello config file (dmitri@redhat.com)
- 707274 (adprice@redhat.com)
- Added create and delete, tests for each and corresponding routes.
  (ehelms@redhat.com)
- Changed to use id(passed in via locals) instead of the @id(instance
  variable). (ehelms@redhat.com)
- Adds validations to changeset name to conform with Katello standards, provide
  uniqueness across environments and create a default name for the changeset
  auto-generated when an environment is created. (ehelms@redhat.com)
- Added coded related to listing system's packages (paji@redhat.com)
- local var changes for changeset spec (shughes@redhat.com)
- initial changeset model spec (shughes@redhat.com)
- Stylesheets import cleanup to remove redundancies. (ehelms@redhat.com)
- fixing issue where promotions would throw an error if next environment did
  not exist (jsherril@redhat.com)
- Refactored systems page css to extend basic block and modify only specific
  attributes. (ehelms@redhat.com)
- Merge branch 'master' into promotions (jrist@redhat.com)
- adding initial changeset revamp (jsherril@redhat.com)
- Re-factored creating custom rows in lists to be a true/false option that when
  true attempts to call render_rows.  Any page implementing custom rows in a
  list view should provide a render_rows function in the helper to handle it.
  (ehelms@redhat.com)
- Added toggle all to sync management page. (jrist@redhat.com)
- Removal of schedule reboot and uptime from systems detail.
  (ehelms@redhat.com)
- Adds to the custom system list display to show additional details within a
  system information block.  Follows the three column convention placing
  details in a particular column. (ehelms@redhat.com)
- Added new css class to lists that are supposed to be ajax scrollable to
  provide better support across variations of ajax scroll usage.
  (ehelms@redhat.com)
- initial schema for tracking changeset users (shughes@redhat.com)
- Merge branch 'master' into systems (ehelms@redhat.com)
- Change to fix empty columns in the left panel from being displayed without
  width and causing column misalignment. (ehelms@redhat.com)
- Merge branch 'master' into systems (ehelms@redhat.com)
- Changes system list to display registered and last checkin date as main
  column headers.  Switches from standard column rendering to use custom column
  rendering function via custom_columns in the systems helper module.
  (ehelms@redhat.com)
- Adds new option to the two panel display, :custom_columns, whereby a function
  name can be passed that will do the work of rendering the columns in the left
  side of the panel.  This is for cases when column data needs custom
  manipulation or data rows need a customized look and feel past the standard
  table look and feel. (ehelms@redhat.com)
- Made an initializer change so that cp_type is handled right (paji@redhat.com)
- pulling out the slidingtree and putting it into a form that is reusable on
  the same page (jsherril@redhat.com)
- Updated a test to create tmp dir unless it exists (paji@redhat.com)
- Fixed the provider_spec to actually test if the subscriptions called the
  right thing in candlepin (paji@redhat.com)
- fixing sql error to hopefully work with postgresql (jsherril@redhat.com)
- adding missing permission for sync_schedules (jsherril@redhat.com)
- using a better authenication checking query with some more tests
  (jsherril@redhat.com)
- migrating anonymous_role to not user ar_ (jsherril@redhat.com)
- a couple more roles fixes (jsherril@redhat.com)
- changing roles to not populate nil resource types or nil tags
  (jsherril@redhat.com)
- Added spec tests for notices_controller. (eric.d.helms@gmail.com)
- adding missing operations resource_type to seeds (jsherril@redhat.com)
- changing the roles subsystem to use the same types/verbs for active record
  and controller access (jsherril@redhat.com)
- removing old roles that were adding errant types to the database
  (jsherril@redhat.com)
- fixing odd sudden broken path link, possibly due to rails upgrade
  (jsherril@redhat.com)
- adding back subscriptions to provider filter (shughes@redhat.com)
- Automatic commit of package [katello] release [0.1.48-1].
  (jsherril@redhat.com)
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
- Automatic commit of package [katello] release [0.1.47-1].
  (jsherril@redhat.com)
- Added roles_controller spec tests. (ehelms@redhat.com)
- fix - manifest imports Orchestration was trying to create products in
  candlepin, when they were already present. (tstrachota@redhat.com)
- Updated the subsystems to include updated candlepin version (paji@redhat.com)
- initial commit (katello-devel@redhat.com)

* Fri Apr 26 2013 Justin Sherrill <jsherril@redhat.com> 1.3.22-1
- Added validators for package and package group rules (paji@redhat.com)
- Fixes #2077 - Since the JSRoutes paths mimic the rails path API in order to
  put a hash parameter, the anchor option needs to be used.
- runcible - updating spec and bundler.d to use runcible 0.4.3
- pulp - updates to address issues in copy/associate of large repos
  (bbuckingham@redhat.com)
- Promotions - Fixing issue with promotions being uncentered and the New
  Changeset button not working.
- Fixed filters cli to now associate partial products from cvd
  (paji@redhat.com)

* Tue Apr 23 2013 Justin Sherrill <jsherril@redhat.com> 1.3.21-1
- Implementation for add/remove filter rules via cli (paji@redhat.com)
- Allowing content views to be deleted from CLI
- content views - minor PR feedback on #1990
- content views - fix test that failed when running entire suite
- content views - ui - add the ability to delete a content view
  (bbuckingham@redhat.com)
- content views - refactor 'refresh' to content views controller
  (bbuckingham@redhat.com)
- Making notification count update when a notice is generated.
- Allowing any HTTP verb to access logout.
- Setting the active menu tab based on location. (walden@redhat.com)
- Experimental Menu - Updating copyright and test files.
- Experimental Menu - Adding missing folder to the spec.
- Menu - Adds support for Experimental UI section which includes the new
  navigation structure in it's current state. (ehelms@redhat.com)
- 952249 - Validating overlapping content in component views
  (daviddavis@redhat.com)
- Moving before_destroy callbacks because of rails/rails#3458
- 953983 - Fixing path to spinner.gif
- Worked on limiting content views on system edit page
- Updated js-routes to work with Rails 3.2
- Made repo clear contents also clear the search indices (paji@redhat.com)
-  953655-Added a search field needed by the content filter 'publish' call
- Querying filters with filter_id rather than filter_name
  (daviddavis@redhat.com)
- fixing re-creation of sync even notifier (jsherril@redhat.com)

* Mon Apr 22 2013 Justin Sherrill <jsherril@redhat.com> 1.3.20-1
- 1956 - adding unprotected checkbox to auto-discovery

* Wed Apr 17 2013 Justin Sherrill <jsherril@redhat.com> 1.3.19-1
- issue 1998 - add a test to check setting of env + content view
  (bbuckingham@redhat.com)
- issue 1998 - client cannot register to a content view
  (bbuckingham@redhat.com)
- 950539 - Adding content view option to package/errata list
- asset-pipeline - fix for multiselect on various pages
  (bbuckingham@redhat.com)
- 927598 - Remove system template section of promotion page

* Tue Apr 16 2013 Justin Sherrill <jsherril@redhat.com> 1.3.18-1
- temporarily disabling errata dashboard widget (jsherril@redhat.com)
- issue 1955 - ui - open filter after create (bbuckingham@redhat.com)
- Asset Pipeline - Fixing mis-included asset edit_helpers.
- issue 1935 - fix promotion failure after view refresh
  (bbuckingham@redhat.com)
- #1963 - return true for index_content so job doesnt fail
- providers - ui - fix alignment of Add Product button (bbuckingham@redhat.com)
- product - ui - change label assignment notice to be message
  (bbuckingham@redhat.com)
- Worked on the content view options for system and changeset
- Updating issues that came out of errata dates being real dates instead of
  strings
- Asset Pipeline - Fixing issue with loading the treeTable jquery plugin since
  we don't precompile anything from an engine directly.
- Asset Pipeline - Fixing issue with missing gpp_keys JS manifest, bad
  reference to stylesheet inclusion syntax on systems group page and missing
  timpickr CSS.
- update katello-debug to the pulp-v2 configuration file location
- more upgrade fixes
- initial pulpv2 upgrade steps

* Fri Apr 12 2013 Justin Sherrill <jsherril@redhat.com> 1.3.17-1
- Spec - Updating spec to set RAILS_ENV=production on asset compile.
  (ehelms@redhat.com)
- fixing env selector positioning on a few pages (jsherril@redhat.com)
- changesets - fix to include alchemy sortElement (bbuckingham@redhat.com)

* Fri Apr 12 2013 Justin Sherrill <jsherril@redhat.com> 1.3.16-1
- content views - minor chgs to views for asset pipeline
  (bbuckingham@redhat.com)
- content view - fix issue w/ deleting filters and filter rules
  (bbuckingham@redhat.com)
- 947859 - Created a way to remove views from keys (daviddavis@redhat.com)

* Fri Apr 12 2013 Justin Sherrill <jsherril@redhat.com> 1.3.15-1
- Merge pull request #1934 from witlessbird/puppet-seeding
  (witlessbird@gmail.com)
- Merge pull request #1941 from ehelms/asset-pipeline-fixes
  (ericdhelms@gmail.com)
- Merge pull request #1922 from parthaa/date-work (parthaa@gmail.com)
- Merge pull request #1939 from jlsherrill/build_fix (jlsherrill@gmail.com)
- Fixing build for RHEL 6 (jsherril@redhat.com)
- Merge pull request #1904 from daviddavis/pluck_tables (daviddavis@redhat.com)
- Merge pull request #1918 from bbuckingham/content_views-linking
  (bbuckingham@redhat.com)
- Merge pull request #1936 from bbuckingham/fork-content-filters
  (bbuckingham@redhat.com)
- content views - update crosslinking to use hash vs string
  (bbuckingham@redhat.com)
- content views - a crosslinking from view to content search
  (bbuckingham@redhat.com)
- Asset Pipeline - Fixes for bad paths to some image and icon assets.
  (ehelms@redhat.com)
- filter rules - minor change from PR review (bbuckingham@redhat.com)
- content view - ui - allow user to specify version info for pkg filter rule
  (bbuckingham@redhat.com)
- Removed some unnecessary comments (paji@redhat.com)
- Code to get cvd refresh working with filters (paji@redhat.com)
- Follow Fedora guidelines when obsoleting subpackage (inecas@redhat.com)
- Remove Foreman specific code - cli (inecas@redhat.com)
- Remove Foreman specific code - rails (inecas@redhat.com)
- Merge pull request #1913 from thomasmckay/delayedjob-spec
  (thomasmckay@redhat.com)
- Merge pull request #1917 from daviddavis/temp_1365706716
  (daviddavis@redhat.com)
- Merge pull request #1907 from ehelms/asset-pipeline (ericdhelms@gmail.com)
- 947869 - Allowing users to create composite definitions from CLI
  (daviddavis@redhat.com)
- fixed an issue with seeds.rb when it wasn't assigning default values
  (dmitri@appliedlogic.ca)
- Rails32 - Fixing copyright years. (ehelms@redhat.com)
- Fixed a malformed url to keep jenkins happy (paji@redhat.com)
- Added more test cases (paji@redhat.com)
- Added tests for the validator (paji@redhat.com)
- Fixed a bunch of unit tests (paji@redhat.com)
- Added a space as requested in the PR (paji@redhat.com)
- Added code to deal with time zone issues (paji@redhat.com)
- Made the errata rule use real dates instead of string (paji@redhat.com)
- Merge pull request #1882 from parthaa/filters-to-master (parthaa@gmail.com)
- Modified a couple of pluck calls to fix a unit test (paji@redhat.com)
- Merge branch 'master' into filters-to-master (paji@redhat.com)
- Fixed some unit tests (paji@redhat.com)
- Changed Hash#index to Hash#key to remove some warnings (paji@redhat.com)
- replacing 'and' with '&&' (komidore64@gmail.com)
- Merge branch 'master' of github.com:Katello/katello into asset-pipeline
  (ehelms@redhat.com)
- Merge pull request #1906 from daviddavis/temp_1365624433
  (daviddavis@redhat.com)
- Merge branch 'master' into filters-to-master (paji@redhat.com)
- Rails32 - Setting Alchemy Gem version and addressing Ruby code styling
  comments. (ehelms@redhat.com)
- delayedjob-spec - set version for gem delayed_job_active_record delayedjob-
  spec - corrected syntax (thomasmckay@redhat.com)
- Merge pull request #1894 from thomasmckay/manifest-refresh
  (thomasmckay@redhat.com)
- 929106 - Displaying user friendly task not found error
  (daviddavis@redhat.com)
- Adding in table names to pluck to be safe (daviddavis@redhat.com)
- Merge pull request #1911 from daviddavis/temp_1365675606
  (daviddavis@redhat.com)
- Merge pull request #1901 from jlsherrill/logging (jlsherrill@gmail.com)
- Fixing package of content_search classes (daviddavis@redhat.com)
- Removed some white spacing issues (paji@redhat.com)
- Made some changes as suggested in PR 1882 (paji@redhat.com)
- Merge pull request #1903 from jlsherrill/test_fix (jlsherrill@gmail.com)
- fixing trailing whitespace (jsherril@redhat.com)
- fixing intermittent test failures (jsherril@redhat.com)
- Merge pull request #1902 from thomasmckay/delayedjob-gemfile
  (thomasmckay@redhat.com)
- delayedjob-gemfile - lock to lower version of delayed_job_active_record
  (thomasmckay@redhat.com)
- Merge pull request #1851 from jlsherrill/issue_1850 (jlsherrill@gmail.com)
- default logging changes (jsherril@redhat.com)
- Merge pull request #1898 from daviddavis/fix_pluck (daviddavis@redhat.com)
- spec fixes (jsherril@redhat.com)
- Merge pull request #1840 from jlsherrill/content_search
  (jlsherrill@gmail.com)
- Fixing pluck call (daviddavis@redhat.com)
- pull request fixes (jsherril@redhat.com)
- Merge pull request #1893 from daviddavis/fix_cv_readonly_error
  (daviddavis@redhat.com)
- Rails32 - Adds missing declarations to new javascript assets.
  (ehelms@redhat.com)
- Rails32 - Updating spec to move assets:precompile to be after touching the
  config file. (ehelms@redhat.com)
- manifest-refresh - changes related to refreshing manifest manifest-refresh -
  updates to distributors manifest-refresh - pylint cleaning
  (thomasmckay@redhat.com)
- Addressed some of the issues suggested in PR 1882 (paji@redhat.com)
- Removing backport of pluck (daviddavis@redhat.com)
- adding ability to enable http publishing on a per-repo basis
  (jsherril@redhat.com)
- Content Views: fixing promote readonly error (daviddavis@redhat.com)
- Merge branch 'master' of https://github.com/Katello/katello into issue_1850
  (jsherril@redhat.com)
- Rails32 - Changing URL of images in stylesheets and moving section
  stylesheets out of sections/ directory to make references to image urls more
  uniform.  Includes spec updates for packages required to perform assets
  pipeline. (ehelms@redhat.com)
- System groups: allow users to update systems via CLI (daviddavis@redhat.com)
- Merge pull request #1889 from ehelms/delayed_jobs_fix (ericdhelms@gmail.com)
- Fixing delayed_job breakages due to upgrade (daviddavis@redhat.com)
- Merge pull request #1749 from iNecas/headpin-abstract-model
  (inecas@redhat.com)
- Merge pull request #1883 from ehelms/removing-todos (ericdhelms@gmail.com)
- delayed jobs use active_record as backend (msuchy@redhat.com)
- Merge branch 'master' of github.com:Katello/katello into asset-pipeline
  (ehelms@redhat.com)
- Delayed Jobs - Fixes an issue with the update to delayed jobs 3.0 where
  to_yaml was being called on the target of AsyncOperation and not the
  AsyncOperation itself. (ehelms@redhat.com)
- Comps - Adding delayed_job_active_record needed to properly hook up the
  active_record backend to delayed_job > 3.0. (ehelms@redhat.com)
- Fixed a typo (paji@redhat.com)
- fixing rubygem(foreman-katello-engine) requires (jsherril@redhat.com)
- Removed an unnecessary requires (paji@redhat.com)
- Updated copyright notice (paji@redhat.com)
- Added some documentation for the diff_hash_params method (paji@redhat.com)
- Made some fixes as suggested in the PR (paji@redhat.com)
- Corrected a typo from rebase time (paji@redhat.com)
- Reverted back an old commit since use_pulp is always false in tests
  (paji@redhat.com)
- Changed katello to use_pulp since runcible only makes sense if you are using
  pulp (paji@redhat.com)
- Fixed a test to make travis happy (paji@redhat.com)
- Temporary fix to make travis point real errors (paji@redhat.com)
- Added some validation for parameters in the various models (paji@redhat.com)
- Fixed another unit test (paji@redhat.com)
- Added some unit test fixes to work with the new model (paji@redhat.com)
- Broke up gigantic filter rules class into 3 smaller more manageable classes
  (paji@redhat.com)
- Fixed some unit tests (paji@redhat.com)
- Refactored some code for better organization (paji@redhat.com)
- Removed trailing space (paji@redhat.com)
- Fixed some parens issues (paji@redhat.com)
- Fixed a couple of unit tests to aid with the publish process
  (paji@redhat.com)
- Made the publish handle empty errata ids in rules (paji@redhat.com)
- Made the publish handle empty package rules (paji@redhat.com)
- Added severity params to errata (paji@redhat.com)
- Forgot to move a method used by generate_clause method (paji@redhat.com)
- Made some mods as suggested in PR 1826 (paji@redhat.com)
- Changed the cvd to use elastics search format for package and package group
  filters (paji@redhat.com)
- Added a default search field param to enable one to choose diff defaults
  (paji@redhat.com)
- Made some modifications for PackageGroupSearch (paji@redhat.com)
- Added code to intergrate the package group to the cvd publish
  (paji@redhat.com)
- Added infrastructure for package groups index and search (paji@redhat.com)
- Moved the index_package and errata calls to a single method (paji@redhat.com)
- Removed unused comments (paji@redhat.com)
- Fixed a couple of unit tests to make travis happy (paji@redhat.com)
- Added tests for the errata and package_group publishes (paji@redhat.com)
- Added version compare facility for package rules (paji@redhat.com)
- Code to incorporate filters while publishing CVD (paji@redhat.com)
- Merge pull request #1868 from bbuckingham/fork-system_groups
  (bbuckingham@redhat.com)
- Merge branch 'master' into master-to-filters (paji@redhat.com)
- Merge pull request #1872 from daviddavis/rails32_deprecations
  (daviddavis@redhat.com)
- Merge pull request #1847 from bbuckingham/fork-content-filters
  (bbuckingham@redhat.com)
- remove empty line to make someone happy... (bbuckingham@redhat.com)
- Fixing Rails 3.2 deprecations (daviddavis@redhat.com)
- Rails32 - Cleaning up TODOs from the 3.0-3.2 bridge. (ehelms@redhat.com)
- Merge pull request #1862 from jlsherrill/copyright (jlsherrill@gmail.com)
- Merge pull request #1871 from xsuchy/pull-req-Gemfile32 (miroslav@suchy.cz)
- Merge pull request #1866 from komidore64/more_custom_info
  (komidore64@gmail.com)
- content views - minor updates based on PR 1847 comments
  (bbuckingham@redhat.com)
- merge conflict (jsherril@redhat.com)
- lower rails requirement and use ~> operator (msuchy@redhat.com)
- mv Gemfile32 Gemfile; rm Gemfile; And remove conditions for Fedora 16 and 17
  (msuchy@redhat.com)
- comment could not be on line with requires (msuchy@redhat.com)
- Merge pull request #1854 from daviddavis/rm_18_code (miroslav@suchy.cz)
- Fix dependency on a JavaScript engine (inecas@redhat.com)
- Rails32 - Updating to fence off minitest task in production.
  (ehelms@redhat.com)
- Rails32 - Fixing a few asset url paths. (ehelms@redhat.com)
- Merge pull request #1863 from jlsherrill/translations (miroslav@suchy.cz)
- Merge pull request #1855 from lzap/turn-on-scl (miroslav@suchy.cz)
- Rails32 - Removing compass compile from Travis. (ehelms@redhat.com)
- Rails32 - Committing some fixes for missing assets and bad paths.
  (ehelms@redhat.com)
- Rails32 - Removes Alchemy as a submodule. (ehelms@redhat.com)
- Rails32 - Moves javascript to asset pipeline, adjusts views to account for
  new manifest files. (ehelms@redhat.com)
- system groups - add test for handling edit on selected systems
  (bbuckingham@redhat.com)
- Rails32 - Converting views over to use the Alchemy engine views.
  (ehelms@redhat.com)
- system groups - allow user to change env/view for selected systems
  (bbuckingham@redhat.com)
- Rails32 - removing public/stylesheets (ehelms@redhat.com)
- Rails32 - Moves images and stylesheets to the assets pipeline.
  (ehelms@redhat.com)
- apply_to_all for default_info (komidore64@gmail.com)
- Merge pull request #1846 from komidore64/default_info (komidore64@gmail.com)
- Translations - Update .po and .pot files for katello. (jsherril@redhat.com)
- Translations - Download translations from Transifex for katello.
  (jsherril@redhat.com)
- copyright update (jsherril@redhat.com)
- happy tests (komidore64@gmail.com)
- content views - fix tests failing after adding a render of js partial
  (bbuckingham@redhat.com)
- Merge remote-tracking branch 'upstream/master' into content-filters
  (daviddavis@redhat.com)
- Merge pull request #1843 from daviddavis/cv_cli_copy (daviddavis@redhat.com)
- Content Views: allow definitions to be cloned from CLI
  (daviddavis@redhat.com)
- Removing Ruby 1.8 specific code (daviddavis@redhat.com)
- enabling SCL for katello (lzap+git@redhat.com)
- content views - after filter rule created, open the rule for edit
  (bbuckingham@redhat.com)
- fixes #1850 - auto-publish to http and https (jsherril@redhat.com)
- using lambda to render content search hover, so extra cells arent rendered
  (jsherril@redhat.com)
- trimming fields requested in package search for speed (jsherril@redhat.com)
- jeditable datepicker - allow the user to clear the date
  (bbuckingham@redhat.com)
- content views - changing from has_key to blank on several hash checks
  (bbuckingham@redhat.com)
- content_views - test fix (bbuckingham@redhat.com)
- content views - minor change to address a jeditable initialize issue
  (bbuckingham@redhat.com)
- press enter when either custom_info field is in focus to submit the creation.
  (komidore64@gmail.com)
- cli now correctly allows you to add custom_info without including a value
  (komidore64@gmail.com)
- content views - add 'summary' info to filter rule list
  (bbuckingham@redhat.com)
- fixing unpromoted library repos not showing up in
  content_view#all_version_library_instances (jsherril@redhat.com)
- minitest fix (jsherril@redhat.com)
- Merge pull request #1842 from jlsherrill/jserror (jlsherrill@gmail.com)
- Merge pull request #1838 from witlessbird/fix-readonlyrecord-exception
  (witlessbird@gmail.com)
- Merge pull request #1731 from witlessbird/session-timeout
  (witlessbird@gmail.com)
- content views - update the include/exlude to be similar to new mockups
  (bbuckingham@redhat.com)
- #1798 - fixing javascript error on promotions page (jsherril@redhat.com)
- removed trailing spaces (dmitri@appliedlogic.ca)
- content views - minimize js initialization and fix for jeditable js error
  (bbuckingham@redhat.com)
- content views - ui - hide the filter tabs until they are initialized
  (bbuckingham@redhat.com)
- merge conflict fix (jsherril@redhat.com)
- Merge remote-tracking branch 'upstream/master' into fork-content-
  filters_merge (bbuckingham@redhat.com)
- Merge pull request #1831 from jlsherrill/content_search_spec
  (jlsherrill@gmail.com)
- removing uneeded dir entry from spec (jsherril@redhat.com)
- adding back correct repo hover links (jsherril@redhat.com)
- Merge pull request #1837 from bbuckingham/fork-content_view_groups
  (bbuckingham@redhat.com)
- spec fixes (jsherril@redhat.com)
- lots of small content search/content view fixes (jsherril@redhat.com)
- index content view repositories after promotion (jsherril@redhat.com)
- adding candlepin environment.all for easier debugging (jsherril@redhat.com)
- system groups - address style comments from pull request 1837 review
  (bbuckingham@redhat.com)
- fixed a ActiveRecord::ReadOnlyRecord error occuring during the migration when
  rails 3.2 is used and there's existing data in the db.
  (dmitri@appliedlogic.ca)
- fixed test/lib/url_constrained_cookie_store_test.rb that was failing on rails
  3.2 (dmitri@appliedlogic.ca)
- Merge pull request #1834 from komidore64/default_info (komidore64@gmail.com)
- system groups - ui - allow user to change env/view for systems in a group
  (bbuckingham@redhat.com)
- activation keys - test fix (bbuckingham@redhat.com)
- ctivation keys / systems - mv i18n.update_view to _common_i18n partial
  (bbuckingham@redhat.com)
- activation keys / systems - minor refactor to allow for reuse on system
  groups (bbuckingham@redhat.com)
- system groups - update system's list to include env and view
  (bbuckingham@redhat.com)
- Merge pull request #1836 from iNecas/bz/903388 (inecas@redhat.com)
- 903388 - fix service-wait script (inecas@redhat.com)
- Merge pull request #1833 from komidore64/headpin-menu-fix
  (komidore64@gmail.com)
- session timeout is now working under Rails 3.0.x (dmitri@appliedlogic.ca)
- updated to work with Rails > 3.2 (dmitri@appliedlogic.ca)
- fixed failing test (dmitri@appliedlogic.ca)
- fixes based on comments in the PR (dmitri@appliedlogic.ca)
- moved tests to a more visible spot in the test suite (dmitri@appliedlogic.ca)
- removed a trailing space (dmitri@appliedlogic.ca)
- added comment in session_store initializer pointing to environment-specific
  initializers instead. (dmitri@appliedlogic.ca)
- added a comment re: Katello::UrlConstrainedCookieStore#call origins
  (dmitri@appliedlogic.ca)
- support for selective (based on url accessed) expiration of cookies
  (dmitri@appliedlogic.ca)
- set a 1 hour expiration on the http session (dmitri@redhat.com)
- Merge pull request #1810 from xsuchy/pull-req-old-changelog
  (miroslav@suchy.cz)
- custom_info in the UI is now using the API (komidore64@gmail.com)
- fixing content view comparison and making it faster (jsherril@redhat.com)
- synchronization page was not correctly fenced in headpin mode
  (komidore64@gmail.com)
- Content views: fixing api doc and perms in several places
  (daviddavis@redhat.com)
- making header height allow 3 lines instead of 2 for view-repo comparison
  (jsherril@redhat.com)
- adding content search models to spec file (jsherril@redhat.com)
- Merge pull request #1820 from daviddavis/filters-cli (daviddavis@redhat.com)
- Merge pull request #1824 from thomasmckay/manifest-async
  (thomasmckay@redhat.com)
- Content view: Addressed feedback for filters (daviddavis@redhat.com)
- Merge pull request #1828 from iNecas/katello-configure-foreman-engine
  (inecas@redhat.com)
- Merge pull request #1814 from bbuckingham/fork-content-filters
  (bbuckingham@redhat.com)
- a few fixes for content search (jsherril@redhat.com)
- Merge pull request #1823 from komidore64/default_info (komidore64@gmail.com)
- katello-configure - install and set up foreman-katello-engine
  (inecas@redhat.com)
- content search - fixing packages & errata search for content views
  (jsherril@redhat.com)
- Content views: backing up filters with definition archives
  (daviddavis@redhat.com)
- content views - fix test failing in rails32 (bbuckingham@redhat.com)
- Merge pull request #1822 from daviddavis/1819 (daviddavis@redhat.com)
- default info in the UI for systems (komidore64@gmail.com)
- fixing CV, product, & repo intersection and difference searches
  (jsherril@redhat.com)
- content views - ui - address test failures during rails32 and ruby193
  (bbuckingham@redhat.com)
- manifest-async - db:migrate (thomasmckay@redhat.com)
- manifest-async - switch to async job on server for CLI/api manifest import
  (thomasmckay@redhat.com)
- adding blankness validation for organization default info
  (komidore64@gmail.com)
- adding api routes to routes.js (komidore64@gmail.com)
- fixing some funky indentation, formatting, and whitespace
  (komidore64@gmail.com)
- content views - ui tests - chgs to address issues when running all
  (bbuckingham@redhat.com)
- Fixed bad check for undefined in javascript. Fixes #1819
  (daviddavis@redhat.com)
- conflict fix (jsherril@redhat.com)
- content views - ui - add permission tests for filters and filter rules
  controllers (bbuckingham@redhat.com)
- content views - ui - adding tests for filters and filter rules controllers
  (bbuckingham@redhat.com)
- Fixing places that call RAILS_ROOT (daviddavis@redhat.com)
- Added code to associate product/repos to a filter (paji@redhat.com)
- Merged content_view_definition_base with filters (daviddavis@redhat.com)
- Merge pull request #1811 from bbuckingham/fork-content_views_bugs
  (bbuckingham@redhat.com)
- content views - fix a test and update a test (bbuckingham@redhat.com)
- Merge remote-tracking branch 'upstream/master' into content-filters
  (daviddavis@redhat.com)
- Merge pull request #1808 from daviddavis/rm_test_helper
  (daviddavis@redhat.com)
- Merge pull request #1801 from daviddavis/cv_copy (daviddavis@redhat.com)
- content views - fix couple of bugs affecting publish/refresh/promote/consume
  (bbuckingham@redhat.com)
- remove old changelog entries (msuchy@redhat.com)
- Spec - Removing the simplecov development task from the production RPM.
  (ehelms@redhat.com)
- Remove unused file (daviddavis@redhat.com)
- Merge pull request #1805 from ehelms/spec-update (ericdhelms@gmail.com)
- Spec - Adding requires on Apache 2.4.4 on Fedora 18. (ehelms@redhat.com)
- Content views: archiving content defintions (daviddavis@redhat.com)
- Merge pull request #1784 from iNecas/foreman-katello-plugin-support
  (inecas@redhat.com)
- Merge pull request #1780 from komidore64/default_info_dupe
  (thomasmckay@redhat.com)
- cassette update (jsherril@redhat.com)
- bumping runcible requirement (jsherril@redhat.com)
- asdf (jsherril@redhat.com)
- jeditable - update to trim datepicker content and reset data on options
  (bbuckingham@redhat.com)
- content views - addressing PR 1794 comments (bbuckingham@redhat.com)
- content views - filters - ui - changes for filter rules (pkg, pkg group and
  errata) (bbuckingham@redhat.com)
- jeditable - minor refactoring and addition of multiselect type
  (bbuckingham@redhat.com)
- jeditable - move date/time picker to helper (bbuckingham@redhat.com)
- content views - update ui-tabs-panel to handle overflow
  (bbuckingham@redhat.com)
- content_views - filters - ui - add support for package rule and misc chgs
  (bbuckingham@redhat.com)
- content views - filters - ui - add ability to associate prod/repos w/ filter
  (bbuckingham@redhat.com)
- content views - filters - ui - add ability to create/view/delete rules
  (bbuckingham@redhat.com)
- content views - filters - ui - add ability to create/view/delete filters
  (bbuckingham@redhat.com)
- panel - allow user to specify url after subpanel submit
  (bbuckingham@redhat.com)
- Fixing output from rpm ruport check (daviddavis@redhat.com)
- removing file not meant to have been checked in (jsherril@redhat.com)
- Merge pull request #1773 from jlsherrill/default_view_change
  (jlsherrill@gmail.com)
- conflict fix (jsherril@redhat.com)
- product and repo search now all include views (jsherril@redhat.com)
- test fixes (jsherril@redhat.com)
- fixture update... yet... again (jsherril@redhat.com)
- adding addition ktenvironment tests (jsherril@redhat.com)
- Commented out tests that would be worked on later (paji@redhat.com)
- Merge pull request #1778 from lzap/i18n-cleanup (lzap@redhat.com)
- Include candlepin info about pools in activation keys details
  (inecas@redhat.com)
- i18n - modifying SPEC file to genreate MO files (lzap+git@redhat.com)
- Make oauth working (inecas@redhat.com)
- Merge pull request #1774 from daviddavis/norpm (daviddavis@redhat.com)
- Merge pull request #1775 from daviddavis/rm_system_templates
  (daviddavis@redhat.com)
- Merge pull request #1766 from lzap/resource-perm-removal (lzap@redhat.com)
- vcr update... again (jsherril@redhat.com)
- test fix (jsherril@redhat.com)
- merge conflict fix (jsherril@redhat.com)
- test fixes (jsherril@redhat.com)
- fixing mode (jsherril@redhat.com)
- Fixed based on suggestions from PR 1751 (paji@redhat.com)
- Content views: fixed double included (daviddavis@redhat.com)
- Silencing 'rpm not found' errors (daviddavis@redhat.com)
- super happy tests (komidore64@gmail.com)
- Updated apipie examples (daviddavis@redhat.com)
- adding oddly missing migration (jsherril@redhat.com)
- fixing space issues (jsherril@redhat.com)
- content search - adding views to repo search (jsherril@redhat.com)
- 923112 - Katello Nightly : Add,Apply.Remove default custom info keynames for
  subscriptions that are set at the organization level failed via Cli
- Removing system template code (daviddavis@redhat.com)
- making tests happy (komidore64@gmail.com)
- Merge branch 'default_view_change' of github.com:jlsherrill/katello into
  content_search (jsherril@redhat.com)
- fixing methods that were moved (jsherril@redhat.com)
- merge conflict fix (jsherril@redhat.com)
- Merge branch 'default_view_change' of github.com:jlsherrill/katello into
  content_search (jsherril@redhat.com)
- test fixes (jsherril@redhat.com)
- 896147 - Notify user of keyname presence when adding default_system_info to
  an org (komidore64@gmail.com)
- i18n - enabling mo for katello fast_gettext (lzap+git@redhat.com)
- Merge pull request #1771 from ehelms/rails32-fixes (ericdhelms@gmail.com)
- i18n - adding locale/Makefile for MO generation (lzap+git@redhat.com)
- renaming gettext app domain from app to katello (lzap+git@redhat.com)
- content views - migrating default content view structure
  (jsherril@redhat.com)
- fixes #1761 (komidore64@gmail.com)
- one more fix to temp disable SCL (lzap+git@redhat.com)
- removing dead code - ResourcePermissions (lzap+git@redhat.com)
- disabling scl for rhel6 temporary (lzap+git@redhat.com)
- Merge pull request #1742 from iNecas/nowrap-nav (inecas@redhat.com)
- Merge pull request #1762 from thomasmckay/busted-new-org
  (thomasmckay@redhat.com)
- Merge pull request #1763 from lzap/scl-katello (lzap@redhat.com)
- busted-new-org - accidental removal of opening new org panel
  (thomasmckay@redhat.com)
- spec - enabling scl for rhel6 - fixing F18 (lzap@redhat.com)
- Merge pull request #1755 from thomasmckay/relax-org-name
  (thomasmckay@redhat.com)
- relax-org-name - only block <, >, and / in org names (thomasmckay@redhat.com)
- content views - initial work to show CVs on product search
  (jsherril@redhat.com)
- Merge pull request #1760 from lzap/scl-katello (miroslav@suchy.cz)
- Merge pull request #1759 from daviddavis/font404 (daviddavis@redhat.com)
- spec - enabling scl for rhel6 - fixing F18 (lzap@redhat.com)
- 915289 - Fixing missing fonts (daviddavis@redhat.com)
- spec - enabling scl for rhel6 (lzap+git@redhat.com)
- spec - sorting, cleaning and indenting (lzap+git@redhat.com)
- Do not use two %%s in translation string (msuchy@redhat.com)
- Rails32 - Adding password except to json output of compute resource.
  (ehelms@redhat.com)
- Rails32 - Adding two calls to retrieve a content view version to prevent an
  ActiveRecord:ReadOnly error from being thrown. (ehelms@redhat.com)
- Rails32 - Updates use of ActiveSupport::Concern to remove deprecation
  warnings around use of InstanceMethods. (ehelms@redhat.com)
- Rails32 - Fixes glue layer tests that needed to reload EnvironmentProducts.
  (ehelms@redhat.com)
- Rails32 - Adds conditionals to use a set BUNDLE_GEMFILE environment variable
  or punt back to the basic Gemfile.  This is needed for testing both stacks on
  Travis and in the future any separate Gemfiles. (ehelms@redhat.com)
- Merge branch 'master', remote-tracking branch 'katello' into rails32-fixes
  (ehelms@redhat.com)
- Rails32 - Attempting to fix json error output. (ehelms@redhat.com)
- Merge pull request #1753 from ehelms/minor-ui-fixes (ericdhelms@gmail.com)
- Content Search: filtering views by search mode (daviddavis@redhat.com)
- Content Search: fixes to existing code (daviddavis@redhat.com)
- Content Search: showing cv filter for package search (daviddavis@redhat.com)
- Content Search: tweaked product row in cv comparison (daviddavis@redhat.com)
- Content search: fixed search modes for cv comparison (daviddavis@redhat.com)
- Content Search: not displaying total packages per product on cv comparison
  (daviddavis@redhat.com)
- Content Search: moving files to app/lib (daviddavis@redhat.com)
- Content search: Fixing product_repos method name (daviddavis@redhat.com)
- Content search: added pagination to content view comparison
  (daviddavis@redhat.com)
- Content search: fixed link and removed duplicate code (daviddavis@redhat.com)
- Content Search: Fixed metadata row in view comparison (daviddavis@redhat.com)
- Content Search: refactored code by creating module namespaces
  (daviddavis@redhat.com)
- Content Search: Refactored content view comparison (daviddavis@redhat.com)
- Content Search: created a content view comparison (daviddavis@redhat.com)
- Worked on content view search (daviddavis@redhat.com)
- Merge pull request #1743 from iNecas/default-content-view-dependent-destroy
  (inecas@redhat.com)
- Removed an unused method and fixed a validation issue with filters
  (paji@redhat.com)
- Fixed a couple of previously commented tests (paji@redhat.com)
- Rails32 - Changes simple_crud_controller tests to turn data into json using
  as_json similar to the controllers themselves. (ehelms@redhat.com)
- Rails32 - Switching to be_json matcher for some tests. (ehelms@redhat.com)
- Merge pull request #1704 from thomasmckay/906859-import-messages
  (thomasmckay@redhat.com)
- Rails32 - Adding check for secure token and Rails 32. (ehelms@redhat.com)
- Move abstract model to katello-common package (inecas@redhat.com)
- Destroy default content view on cascade when deleting environment
  (inecas@redhat.com)
- merging all .gitignores into one (lzap+git@redhat.com)
- Small test fix with the hope that it'll make travis happy (paji@redhat.com)
- Made some modifications on the unit test as suggested in PR 1746
  (paji@redhat.com)
- Removing commented code (paji@redhat.com)
- Added tests to check the new age params (paji@redhat.com)
- Merge pull request #1744 from daviddavis/removing_more_gems
  (daviddavis@redhat.com)
- Changed filter rule parameter conventions (paji@redhat.com)
- Created optional gem group for profiling gems (daviddavis@redhat.com)
- Merge branch 'master' into master-to-content (paji@redhat.com)
- Merge branch 'content-filters' into master-to-content (paji@redhat.com)
- Created a newrelic option in the configuration (daviddavis@redhat.com)
- Merge pull request #1717 from pitr-ch/bug/#1711 (kontakt@pitr.ch)
- Merge pull request #1724 from komidore64/dumb-warning (komidore64@gmail.com)
- getting rid of that pesky deprecated message (komidore64@gmail.com)
- Removing logical-insight (daviddavis@redhat.com)
- Removed comment about webrat (daviddavis@redhat.com)
- fix headpin build #1711 (pchalupa@redhat.com)
- Merge pull request #1729 from pitr-ch/story/sso (daviddavis@redhat.com)
- disconnected - adding i18n and refactoring (lzap+git@redhat.com)
- fix travis tests (pchalupa@redhat.com)
- Never warp navigation items (inecas@redhat.com)
- Commented out a couple of tests who would be acted upon later
  (paji@redhat.com)
- Renamed the repos method to applicable_repos based on suggestions in PR 1725
  (paji@redhat.com)
- Added code address remove/validation logic as recommended in pr 1725
  (paji@redhat.com)
- Rails32 - Fixing some unit tests that broke under Rails32.
  (ehelms@redhat.com)
- added a warning to comments around 'require 'glue'' in lib/glue/queue.rb
  (dmitri@appliedlogic.ca)
- force loading of glue module before defining of any other modules in Glue
  namespace (dmitri@appliedlogic.ca)
- Rails32 - Updating Travis to actually run against the 3.2 gemfile and adding
  missing logging gem. (ehelms@redhat.com)
- LookNFeel - Minor style updates to the shell. (ehelms@redhat.com)
- Merge branch 'master' into master-to-content (paji@redhat.com)
- Fixed some typos in my previous (paji@redhat.com)
- Made a couple changes related to the comments in PR 1725 (paji@redhat.com)
- Merge pull request #1716 from komidore64/custom-info (komidore64@gmail.com)
- remove katello.template.yml (pchalupa@redhat.com)
- Merge pull request #1697 from bbuckingham/fork-content_views_dashboard
  (bbuckingham@redhat.com)
- Merge pull request #1710 from lzap/debug-iptableas (lzap@redhat.com)
- Merge pull request #1722 from daviddavis/1721 (daviddavis@redhat.com)
- Minor tweak to repository object to just return product_id (paji@redhat.com)
- Added unit tests to check for the association (paji@redhat.com)
- Merge pull request #1723 from ehelms/issue-1658 (ericdhelms@gmail.com)
- Added filter association to products (paji@redhat.com)
- Fixes #1658 - Removes all user notifications regarding login due to
  redundancy and adds a helptip style message on the dashboard for users
  without access to any organizations to let them know what their next steps
  are. (ehelms@redhat.com)
- Merge pull request #1719 from omaciel/standardlabelnotif
  (omaciel@ogmaciel.com)
- Showing invalid label as error not exception. Fixes #1721
  (daviddavis@redhat.com)
- Merge pull request #1688 from daviddavis/flv (daviddavis@redhat.com)
- Standardizing notification message for re-using Labels. Fixes #1718
  (ogmaciel@gnome.org)
- large refactor of organization level default system info keys
  (komidore64@gmail.com)
- Merge pull request #1715 from ehelms/system-index-elasticsearch
  (ericdhelms@gmail.com)
- API - Updating API sytems controller spec tests. (ehelms@redhat.com)
- Merge pull request #1681 from jlsherrill/delete_changeset_test
  (jlsherrill@gmail.com)
- fixing unit tests (jsherril@redhat.com)
- Switch assert equals ordering as suggested int he PR comments
  (paji@redhat.com)
- Aligned the values in the yml to match other ymls (paji@redhat.com)
- Fixed the repository sets controller test (paji@redhat.com)
- Moved the base tests to fixtures instead of FactoryGirl as recommended
  (paji@redhat.com)
- API - Updating documentation and cleaning whitesapce. (ehelms@redhat.com)
- API - Moves the Elasticsearch items query to be a class and changes Systems
  index API to it's use.  Adds a paged and page_size option for the UI to use
  and maintain the current standard of returning all results for API calls.
  (ehelms@redhat.com)
- Merge branch 'master', remote-tracking branch 'origin' into
  delete_changeset_test (jsherril@redhat.com)
- Made the asserts clearer based on the suggestions provided inPR 1713
  (paji@redhat.com)
- removed white spaces (paji@redhat.com)
- Added tests related to filter_controller
- API - Moving Systems index API controller to using Elasticsearch.
  (ehelms@redhat.com)
- Removing a trailing white space (paji@redhat.com)
- Addded minitests  for filter model (paji@redhat.com)
- Merge pull request #1709 from thomasmckay/headpin-travis
  (thomasmckay@redhat.com)
- adding headpin tests to travis (komidore64@gmail.com)
- Updated copyright years (paji@redhat.com)
- Merge pull request #1689 from ehelms/api-session-auth (ericdhelms@gmail.com)
- Merge pull request #1703 from pitr-ch/story/sso (kontakt@pitr.ch)
- adding iptables -L output to the katello-debug (lzap+git@redhat.com)
- move Configuration to Katello namespace (pchalupa@redhat.com)
- separate reusable parts of katello configuration (pchalupa@redhat.com)
- Removed trailing spaces (paji@redhat.com)
- Removed some trailing spaces in both py and rb files (paji@redhat.com)
- removed unnecessary to_json calls as suggested in PR 1708 (paji@redhat.com)
- Filter model tweaks based on PR suggestions (paji@redhat.com)
- Label validator unit tests (daviddavis@redhat.com)
- Merge pull request #1701 from lzap/system-name-length-917033
  (lzap@redhat.com)
- Intial commit of filters functionality (paji@redhat.com)
- Fixing schema.rb (daviddavis@redhat.com)
- 906859-import-messages - cleaned up error messages for both import and delete
  manifest (thomasmckay@redhat.com)
- Setup simplecov in katello (daviddavis@redhat.com)
- 917033 - setting maximum length for system name to 250 (lzap+git@redhat.com)
- Merge branch 'master' into tdd/lib_reorganization (pchalupa@redhat.com)
- content views - haml for dashboard portlet (bbuckingham@redhat.com)
- content views - add a portlet to the dashboard for content views
  (bbuckingham@redhat.com)
- content views - support retrieving 'readable' versions
  (bbuckingham@redhat.com)
- Fixing undefined method index errors (daviddavis@redhat.com)
- Merge pull request #1685 from lzap/dis2 (lzap@redhat.com)
- Merge pull request #1693 from ares/feature/logging (ares@igloonet.cz)
- Add logging as build dependency (mhulan@redhat.com)
- Merge pull request #1653 from ares/feature/logging (ares@igloonet.cz)
- Authentication - Enables session based authentication to the API controllers.
  (ehelms@redhat.com)
- Merge pull request #1686 from pitr-ch/tdd/foreman-timeouts (kontakt@pitr.ch)
- packaging fix (pchalupa@redhat.com)
- Merge branch 'master' into tdd/lib_reorganization (pchalupa@redhat.com)
- Merge pull request #1659 from bbuckingham/fork_composite_views
  (bbuckingham@redhat.com)
- Merge pull request #1680 from bbuckingham/fork_content_view_tests
  (bbuckingham@redhat.com)
- Merge pull request #1678 from daviddavis/cs_refactor (daviddavis@redhat.com)
- Fixed label validator (daviddavis@redhat.com)
- Merge pull request #1674 from ares/tdd/remove_spec_warnings
  (ares@igloonet.cz)
- Merge pull request #1675 from ares/tdd/ping_test_fix (ares@igloonet.cz)
- Merge branch 'master' into tdd/lib_reorganization (pchalupa@redhat.com)
- Moved shared content view and product code out (daviddavis@redhat.com)
- fix missing timeout option passing to foreman_api (pchalupa@redhat.com)
- lib/util cleanup (pchalupa@redhat.com)
- Merge pull request #1669 from pitr-ch/tdd/remove_old_fixme (kontakt@pitr.ch)
- Organize lib files (pchalupa@redhat.com)
- Merge pull request #1673 from ares/tdd/system_templates_specs
  (ares@igloonet.cz)
- diconnected - pulp v2 initial support (lzap+git@redhat.com)
- Removed unnecessary require (mhulan@redhat.com)
- log each test's name (pchalupa@redhat.com)
- add support for tailing external log files (pchalupa@redhat.com)
- Better stubbing to fix specs (ares@igloonet.cz)
- Fix for TaskStatus callback (ares@igloonet.cz)
- New log files structure (ares@igloonet.cz)
- Be more tolerant about log path (ares@igloonet.cz)
- Changes of default values (ares@igloonet.cz)
- Fix for Ruby 1.8 (ares@igloonet.cz)
- Add logging dependency (ares@igloonet.cz)
- simplify #configure_children_loggers method (pchalupa@redhat.com)
- add YARD log support (pchalupa@redhat.com)
- pull out configuration post_process down same as validation definition
  (pchalupa@redhat.com)
- do not align logger names (pchalupa@redhat.com)
- Changed default settings (ares@igloonet.cz)
- Fix specs with new logging gem (ares@igloonet.cz)
- Logging configuration validation (ares@igloonet.cz)
- Move logging configuration to defaults (ares@igloonet.cz)
- Configuration cleanup (ares@igloonet.cz)
- Multiline log messages indentation (ares@igloonet.cz)
- use same format for stdout appender as for development.log
  (pchalupa@redhat.com)
- add missing log_trace option in common.logging (pchalupa@redhat.com)
- Test coverage for logging (ares@igloonet.cz)
- Inline console logging support (ares@igloonet.cz)
- Support for custom log file path (ares@igloonet.cz)
- Remove logrotate configuration not needed anymore (ares@igloonet.cz)
- Support for log trace (ares@igloonet.cz)
- Syslog support (ares@igloonet.cz)
- New logging configuration (ares@igloonet.cz)
- Use logging gem for all logs (ares@igloonet.cz)
- Merge pull request #1670 from iNecas/refactor (inecas@redhat.com)
- Merge pull request #1657 from jlsherrill/pulp_perf (jlsherrill@gmail.com)
- fixture update (jsherril@redhat.com)
- test fix (jsherril@redhat.com)
- vcr cassette update (jsherril@redhat.com)
- test fix (jsherril@redhat.com)
- content views - add some spec tests for content view & definition controllers
  (bbuckingham@redhat.com)
- content views - fix the permission checked when destroying a definition
  (bbuckingham@redhat.com)
- adding deletion changeset tests (jsherril@redhat.com)
- Merge pull request #1677 from thomasmckay/db-seeds-headpin-fence
  (thomasmckay@redhat.com)
- Refactored product content search (daviddavis@redhat.com)
- Started refactoring content search with content view search
  (daviddavis@redhat.com)
- db-seeds-headpin-fence - fence pulp call (thomasmckay@redhat.com)
- Merge pull request #1676 from bbuckingham/fix_routes (bbuckingham@redhat.com)
- Merge branch 'master' of https://github.com/Katello/katello into pulp_perf
  (jsherril@redhat.com)
- minitest test fix (jsherril@redhat.com)
- routes.js - regenerating (bbuckingham@redhat.com)
- Fix ping spec (mhulan@redhat.com)
- Remove expectations on nil warnings (mhulan@redhat.com)
- Refactored system template specs (mhulan@redhat.com)
- Merge pull request #1666 from jlsherrill/set_id_to_set_name
  (jlsherrill@gmail.com)
- Use snake_case instead of camelCase for method names (inecas@redhat.com)
- Local variables snake_case instead of CamelCase (inecas@redhat.com)
- Non action method in controller should be private (inecas@redhat.com)
- Merge pull request #1665 from bbuckingham/sort_promotion_paths
  (bbuckingham@redhat.com)
- remove old FIXME (pchalupa@redhat.com)
- Fixes #1656 - Sets a minimum width on the body to reflect that hard width set
  on the content section. (ehelms@redhat.com)
- content views - fix changeset.add_content_view test (bbuckingham@redhat.com)
- Merge pull request #1652 from witlessbird/default_view_creation
  (witlessbird@gmail.com)
- allowing the use of repo set name for enable disable (jsherril@redhat.com)
- content view - refactor add_content_view logic in controller to model
  (bbuckingham@redhat.com)
- Merge pull request #1660 from daviddavis/act_key_create_fix
  (daviddavis@redhat.com)
- env paths - sort paths by env name (bbuckingham@redhat.com)
- updated test fixtures after merge (dmitri@redhat.com)
- Merge pull request #1663 from bbuckingham/fixes_1661 (bbuckingham@redhat.com)
- updated db/schema.rb; removed default_content_view_id column from
  environments table (dmitri@redhat.com)
- reduced the number of saves during default_content_view creation.
  KTEnvironment is now being saved only once. (dmitri@redhat.com)
- Merge pull request #1621 from daviddavis/cv_system_pgs
  (daviddavis@redhat.com)
- Merge pull request #1647 from thomasmckay/distributors-minitest
  (thomasmckay@redhat.com)
- distributors-minitest - systems and distributors testing
  (thomasmckay@redhat.com)
- Fixes #1661 - add request_type to notices retrieved using client polling
  (bbuckingham@redhat.com)
- custominfo-tupane-fix - fixed tupane layout for custominfo
  (thomasmckay@redhat.com)
- Setting initial_action to fix create (daviddavis@redhat.com)
- content views - ui - composite view promotion - help users with component
  views (bbuckingham@redhat.com)
- Merge pull request #1654 from jlsherrill/bz909472 (jlsherrill@gmail.com)
- using bulk_load_size config option for determining bulk loads
  (jsherril@redhat.com)
- Merge pull request #1651 from jlsherrill/fast_import (mmccune@gmail.com)
- Merge remote-tracking branch 'upstream/master' into fork_composite_views
  (bbuckingham@redhat.com)
- 909472 - not allowing <, >, & /  in usernames (jsherril@redhat.com)
- fixing string detected as improperly formatted (jsherril@redhat.com)
- Merge pull request #1627 from jlsherrill/fast_import (jlsherrill@gmail.com)
- Merge pull request #1648 from daviddavis/rs (miroslav@suchy.cz)
- Merge pull request #1644 from iNecas/apipie-dry (inecas@redhat.com)
- test fixes (jsherril@redhat.com)
- fast import - removing product.import_logger (jsherril@redhat.com)
- Checking db/schema.rb into version control (daviddavis@redhat.com)
- spect test fix (jsherril@redhat.com)
- Merge pull request #1640 from tstrachota/comp_res_fix (tstrachota@redhat.com)
- Merge pull request #1645 from daviddavis/ff (daviddavis@redhat.com)
- Fixing fencing issues in headpin (daviddavis@redhat.com)
- DRY common apipie param descriptions into param groups (inecas@redhat.com)
- content views - address PR 1641 comments (bbuckingham@redhat.com)
- Merge pull request #1594 from xsuchy/pull-req-bz886718 (miroslav@suchy.cz)
- Fixed typo in activation_key comment (daviddavis@redhat.com)
- Merge pull request #1633 from iNecas/912698 (inecas@redhat.com)
- fast import - isloating logic to find content on a product
  (jsherril@redhat.com)
- addressing pull request comment (jsherril@redhat.com)
- content views - tests - few minor changes for composite definitions
  (bbuckingham@redhat.com)
- content views - promote - minor change to handle when there is no definition
  (bbuckingham@redhat.com)
- content views - fix a few broken tests (bbuckingham@redhat.com)
- Merge branch 'master' of https://github.com/Katello/katello into fast_import2
  (jsherril@redhat.com)
- 912698 - ak subscribe:  take the number of sockets in pool into account
  (inecas@redhat.com)
- content views - fix few bugs in view publish/refresh/promote
  (bbuckingham@redhat.com)
- comp resources - fixed system tests (tstrachota@redhat.com)
- Merge pull request #1638 from bbuckingham/fork_content_views_fix_query-2
  (bbuckingham@redhat.com)
- pulp peformance enhancements (jsherril@redhat.com)
- content views - fix query that failed on older postresql
  (bbuckingham@redhat.com)
- Merge pull request #1634 from lzap/i18n-merge-fix (bbuckingham@redhat.com)
- Merge pull request #1626 from daviddavis/cv_content_search
  (daviddavis@redhat.com)
- Merge pull request #1624 from daviddavis/1620 (daviddavis@redhat.com)
- Content views: worked on content view search (daviddavis@redhat.com)
- test fix (jsherril@redhat.com)
- test fix (jsherril@redhat.com)
- i18n - fixing merge issue introduced by 2cee9ef0d7ee53 (lzap+git@redhat.com)
- spec fix (jsherril@redhat.com)
- moving Product#repos from pulp glue to normal model, as nothing is pulp
  related (jsherril@redhat.com)
- Merge pull request #1610 from daviddavis/1592 (daviddavis@redhat.com)
- Merge pull request #1632 from witlessbird/environment_factory
  (witlessbird@gmail.com)
- Merge pull request #1631 from witlessbird/content_view_orchestration
  (witlessbird@gmail.com)
- a smal refactoring to generate more complete environment+dependencies tree
  (dmitri@redhat.com)
- a fix in content_view_environemnt: the order of callbacks is important
  (dmitri@redhat.com)
- Loading pulp gem group (jomara@redhat.com)
- content views - ui - composite definitions - help user resolve content
  conflicts (bbuckingham@redhat.com)
- whitespace fix (jsherril@redhat.com)
- Resolving headpin installation issues (jomara@redhat.com)
- spec fixes (jsherril@redhat.com)
- fast import - removing refresh_products from ui provider
  (jsherril@redhat.com)
- fast import - adding tool tip and better messaging if no manifest was
  imported (jsherril@redhat.com)
- spec test fix (jsherril@redhat.com)
- fast import - adding tests for repository set manipulation
  (jsherril@redhat.com)
- Content views: fixing content_view_definition api controller test
  (daviddavis@redhat.com)
- content views - initial support to promote composite views
  (bbuckingham@redhat.com)
- Merge pull request #1614 from ehelms/menu-updates (ericdhelms@gmail.com)
- Content views: updating list on system new page (daviddavis@redhat.com)
- Merge pull request #1611 from daviddavis/test_fix (daviddavis@redhat.com)
- Fixing #1620 by defining url_content_views_proc (daviddavis@redhat.com)
- fast import - adding spec tests and api for disable (jsherril@redhat.com)
- Merge pull request #1600 from xsuchy/pull-req-tomcat (miroslav@suchy.cz)
- merge conflict (jsherril@redhat.com)
- content views - do not list composite definitions in content list
  (bbuckingham@redhat.com)
- content views - extend the definition.repos to support composite definitions
  (bbuckingham@redhat.com)
- Content views: fixing breaking test (daviddavis@redhat.com)
- f18 - skip api pie for fedora 18 (lzap+git@redhat.com)
- Content views: addressing feedback from #1592 (daviddavis@redhat.com)
- f18 - making apipie happy during build phase (lzap+git@redhat.com)
- Merge pull request #1605 from lzap/jruby-fix (lzap@redhat.com)
- Merge pull request #1535 from iNecas/log-not-found-message
  (inecas@redhat.com)
- Merge pull request #1568 from pitr-ch/bug/781206-missing-notifications
  (kontakt@pitr.ch)
- Merge pull request #1580 from pitr-ch/story/configuration (kontakt@pitr.ch)
- Merge pull request #1604 from lzap/f18-build (lzap@redhat.com)
- rails32 - not need version constraints anymore on compass
  (lzap+git@redhat.com)
- Merge pull request #1609 from bbuckingham/fork_content_view_migrations
  (daviddavis@redhat.com)
- content views - remove trailing whitespace on comment...
  (bbuckingham@redhat.com)
- content views - migration - associate env with version
  (bbuckingham@redhat.com)
- content views - fix migration that maps repos to view versions
  (bbuckingham@redhat.com)
- new ui for repo(set) enabling (jsherril@redhat.com)
- Merge pull request #1607 from daviddavis/fix_jenkins_cv
  (daviddavis@redhat.com)
- Merge pull request #1603 from ehelms/compass-rails-32 (ericdhelms@gmail.com)
- Rewriting test to hopefully fix jenkins error (daviddavis@redhat.com)
- Merge pull request #1592 from Katello/content_views (bbuckingham@redhat.com)
- jruby - rpm installation is not supported on jruby yet (lzap+git@redhat.com)
- Merge pull request #1601 from xsuchy/pull-req-tu_shim2 (lzap@redhat.com)
- Content views: changed how exception was being raised (daviddavis@redhat.com)
- Content views: fixing minitest test (daviddavis@redhat.com)
- Merge pull request #1602 from xsuchy/pull-req-Gemfile56
  (bbuckingham@redhat.com)
- Merge pull request #1554 from thomasmckay/distributors
  (thomasmckay@redhat.com)
- s/Gemfile.32/Gemfile32/ (msuchy@redhat.com)
- initial repo set UI work (jsherril@redhat.com)
- distributors - updated tupane changes from master (thomasmckay@redhat.com)
- do not require minitest_tu_shim (msuchy@redhat.com)
- distributors - clean up based upon pull-request feedback (code format, etc.)
  (thomasmckay@redhat.com)
- distributors - 'rake jsroutes' after rebase from master
  (thomasmckay@redhat.com)
- distributors - UI (thomasmckay@redhat.com)
- rename katello-defaults.yml to katello_defaults.yml (pchalupa@redhat.com)
- changing secrets 'shhhh' to 'katello' (pchalupa@redhat.com)
- we need tomcat in %%post section (msuchy@redhat.com)
- use Gemfile.32 for Fedora 18+ (msuchy@redhat.com)
- Merge pull request #1565 from jlsherrill/bz910094 (jlsherrill@gmail.com)
- Merge remote-tracking branch 'upstream/master' into content_views
  (bbuckingham@redhat.com)
- Merge remote-tracking branch 'upstream/master' into content_views
  (bbuckingham@redhat.com)
- Content views: fixed call to ChangesetContentException
  (daviddavis@redhat.com)
- Content views: removing 1.9 method sort_by! (daviddavis@redhat.com)
- Content views: fixing indentation in api cvd controller
  (daviddavis@redhat.com)
- Content views: updating copyright years (daviddavis@redhat.com)
- Content views: addressing feedback from PR #1592 (daviddavis@redhat.com)
- Merge branch 'master' of https://github.com/Katello/katello into fast_import
  (jsherril@redhat.com)
- Merge pull request #1591 from komidore64/custom-info (komidore64@gmail.com)
- fixing le test (komidore64@gmail.com)
- Merge branch 'master' of https://github.com/Katello/katello into fast_import
  (jsherril@redhat.com)
- 886718 - allow better translation of one string (msuchy@redhat.com)
- Merge pull request #1555 from ehelms/rails32-30-bridge (ericdhelms@gmail.com)
- Menu - Fixes issue where menu updates did not correctly update API
  controller. (ehelms@redhat.com)
- Conflicts:      src/app/controllers/roles_controller.rb (jrist@redhat.com)
- content views - Rails32 - move tupane_layout declarations to views
  (bbuckingham@redhat.com)
- Merge remote-tracking branch 'upstream/master' into content_views
  (bbuckingham@redhat.com)
- Rails32 - Adds compass-rails for Compass 0.12 on Fedora 18 and updates
  configuration file for compass for both version of compass 0.11.5 and 0.12.
  (ehelms@redhat.com)
- Merge pull request #1528 from xsuchy/pull-req-msg (miroslav@suchy.cz)
- Merge pull request #1575 from jlsherrill/bz868917 (jlsherrill@gmail.com)
- Refactoring edit action in activation_keys controller (daviddavis@redhat.com)
- Rails32 - Setting haml declaration in 32 Gemfile to be consistent with
  regular Gemfile.  Re-factoring accessible_environments for readability.
  (ehelms@redhat.com)
- Rails32 - Fixing accessible_environments to properly generate an array when
  making the list unique. (ehelms@redhat.com)
- Rails32 - Removing clone and adding dup on self. (ehelms@redhat.com)
- Rails32 - Small test fix following a rebase. (ehelms@redhat.com)
- Rails32 - Whitespace cleanup. (ehelms@redhat.com)
- Rails32 - Adds a slew of updates required to get spec tests passing.
  (ehelms@redhat.com)
- Rails32 - Adds a separate gemfile to specify Rails3.2 for Travis testing.
  (ehelms@redhat.com)
- Rails32 - Updates tests that rely on loading fixtures in before and after
  suites to load them properly in both 3.2 and 3.0 (ehelms@redhat.com)
- Rails32 - ActiveRecord models now take two arguments on intialize. This
  updates each model that overrides initialize and calls superto conditionally
  call super with 1 or 2 arguments depending on the Rails version.
  (ehelms@redhat.com)
- Rails32 - Adding missing options parameter to initialize method.
  (ehelms@redhat.com)
- Rails32 - Explicitly casting sync_date to a time object since in 3.2 all
  parameters are treated as strings and not cast. (ehelms@redhat.com)
- Rails32 - Adds conditional to grab appropriate association owner since they
  diverge between 3.2 and 3.0. (ehelms@redhat.com)
- Rails32 - Adds needed options parameter for initialize methods.
  (ehelms@redhat.com)
- Rails32 - Putting submodule back to original hash. (ehelms@redhat.com)
- Rails32 - Adding bridge file to contain functionality not present in 3.2 but
  needed by 3.0 to allow temporary running on both stacks. (ehelms@redhat.com)
- Rails32 - Updating location of json custom matcher for spec testing.
  (ehelms@redhat.com)
- Removes completely deprecated and unused debug_rjs option.
  (ehelms@redhat.com)
- Removes validation covered by added indexes that further breaks in Rails 3.2
  (ehelms@redhat.com)
- Spec test fixes to allow passing in Rails 3.2 (ehelms@redhat.com)
- Fixes matching on array's that can result in occassional random order.
  (ehelms@redhat.com)
- Removes validation that is enforced by the database after index changes. This
  is also to prevent errors in Rails 3.2. (ehelms@redhat.com)
- Moves all tupane_layout declarations to the views.  Note that this is also
  required to have tupane views rendering properly in Rails 3.2.
  (ehelms@redhat.com)
- Changes class_inheritable_attribute to class_attribute since the former is
  deprecated in 3.1+. (ehelms@redhat.com)
- fixing some indentation to look nicer (jsherril@redhat.com)
- Added in some missing licenses (daviddavis@redhat.com)
- cleaning up create method, thanks to @daviddavis 's suggestion!
  (komidore64@gmail.com)
- Merge pull request #1572 from jlsherrill/bz852849 (jlsherrill@gmail.com)
- Merge pull request #1578 from jlsherrill/bz909961 (jlsherrill@gmail.com)
- Merge pull request #1587 from daviddavis/cv_fencing (daviddavis@redhat.com)
- little bit of code clean-up for custom info (komidore64@gmail.com)
- content views - 1 more test fix (bbuckingham@redhat.com)
- Content views: added more fencing to UI (daviddavis@redhat.com)
- adding custom info into system's UI page (komidore64@gmail.com)
- content views - update tests for composite definitions
  (bbuckingham@redhat.com)
- Merge pull request #1570 from ehelms/bug-814167 (ericdhelms@gmail.com)
- Merge pull request #1574 from ehelms/bug-864189 (ericdhelms@gmail.com)
- Merge pull request #1577 from ehelms/bug-904194 (ericdhelms@gmail.com)
- Merge pull request #1576 from ehelms/bug-867300 (ericdhelms@gmail.com)
- content views - address comments on PR 1549 (bbuckingham@redhat.com)
- content views - composite - disable publish/refresh on invalid definition
  (bbuckingham@redhat.com)
- Merge pull request #1581 from xsuchy/pull-req-factory_girl_rails
  (miroslav@suchy.cz)
- Merge pull request #1566 from daviddavis/ufg (miroslav@suchy.cz)
- Merge remote-tracking branch 'upstream/master' into fork_content_views_merge
  (bbuckingham@redhat.com)
- Merge pull request #1582 from ehelms/gemfile-update (bbuckingham@redhat.com)
- enable more checks (msuchy@redhat.com)
- ko - (pofilter) newlines: Different line endings (msuchy@redhat.com)
- mr - (pofilter) newlines: Different line endings (msuchy@redhat.com)
- or - (pofilter) newlines: Different line endings (msuchy@redhat.com)
- ta - (pofilter) newlines: Different line endings (msuchy@redhat.com)
- te - (pofilter) long: The translation is much longer than the original
  (msuchy@redhat.com)
- de - (pofilter) variables: Added variables: %%s (msuchy@redhat.com)
- es - (pofilter) variables: Do not translate: %%s (msuchy@redhat.com)
- hi - (pofilter) variables: Do not translate: %%s (msuchy@redhat.com)
- kn - (pofilter) variables: Do not translate: %%s (msuchy@redhat.com)
- ko - (pofilter) variables: Do not translate: %%s (msuchy@redhat.com)
- pa - (pofilter) variables: Do not translate: %%s (msuchy@redhat.com)
- ta - (pofilter) variables: Do not translate: %%s (msuchy@redhat.com)
- pofilter always return 0, fail if there is some error output
  (msuchy@redhat.com)
- Merge pull request #1436 from thomasmckay/901714-subfilters
  (thomasmckay@redhat.com)
- Gemfile - Setting haml version to be more restrictive due to new release of
  haml gem on Rubygems. (ehelms@redhat.com)
- zh_CN - (pofilter) variables: Added variables: %%s (msuchy@redhat.com)
- check po files for errors using pofilter (msuchy@redhat.com)
- check localization files for corectness (msuchy@redhat.com)
- Set factory_girl_rails to 1.4.0 per repos (daviddavis@redhat.com)
- Merge pull request #1548 from daviddavis/cv_act_key_field
  (daviddavis@redhat.com)
- Merge pull request #1579 from ares/feature/better_locale_parsing
  (ares@igloonet.cz)
- add factory_girl_rails to requirements of katello-devel (msuchy@redhat.com)
- Merge branch 'master' into story/configuration (pchalupa@redhat.com)
- documentation update (pchalupa@redhat.com)
- leave app_mode option in katello.yml (pchalupa@redhat.com)
- Merge pull request #1559 from ares/bug/883003-system_groups_validation
  (ares@igloonet.cz)
- Small fix for invalid locale input (ares@igloonet.cz)
- Changeset - Missing render tupane_layout call in view. (ehelms@redhat.com)
- 909961 - fixing cs errata add/remove from ui (jsherril@redhat.com)
- Merge pull request #1558 from bbuckingham/fork_content_views_jslint
  (daviddavis@redhat.com)
- 904194 - Changes to reference products by label instead of name since
  multiple products with the same name can exist and cause issues when
  attempting to promote a system template. (ehelms@redhat.com)
- 867300 - Moves the activation key attach button to the top left corner of the
  available subscriptions table on the activation key edit. (ehelms@redhat.com)
- 868917 - fixing terminology of comparison on content search
  (jsherril@redhat.com)
- fixing model scoping (jsherril@redhat.com)
- 864189 - Fixes issue where hovering over a top level tab and then moving to
  another top level tab would result in a flash of the menu and an improper
  display of the menu. (ehelms@redhat.com)
- 867304 - sorting first environment in paths for env selector
  (jsherril@redhat.com)
- Content views: updating content views and products on activation key page
  (daviddavis@redhat.com)
- 852849 - fixing redirect of expired sessoin (jsherril@redhat.com)
- 814167 - Changes the rendering location of the remove button on system
  templates sliding tree to be centered with text. (ehelms@redhat.com)
- Merge pull request #1564 from ehelms/bug-770690 (ericdhelms@gmail.com)
- 910094 - fixing creation of repos with internationalized names
  (jsherril@redhat.com)
- 770690 - Adds helptip to debug certificate download to explain what the debug
  certificate is used for. (ehelms@redhat.com)
- fixing route (jsherril@redhat.com)
- Pulp agent changed recently the format of the remote action report
  (inecas@redhat.com)
- add missing notification when repo discovery fails (pchalupa@redhat.com)
- replace Notify with #notify in controller (pchalupa@redhat.com)
- Condition cleanup (ares@igloonet.cz)
- 883003 - SystemGroup validation (ares@igloonet.cz)
- Merge pull request #1552 from
  ares/bug/844389-repository_deletion_and_creation (ares@igloonet.cz)
- allowing repo set enabling to be async (jsherril@redhat.com)
- 901714-subfilters - disabling busted spec, moving to minitest
  (thomasmckay@redhat.com)
- content views - address jslint warnings (bbuckingham@redhat.com)
- content views - rename nav Views to Content View Definitions
  (bbuckingham@redhat.com)
- content views - update nav to ensure unique ids (bbuckingham@redhat.com)
- Whitespace - Fixing whitespace. (ehelms@redhat.com)
- content views : fix nav to use Katello.config vs AppConfig
  (bbuckingham@redhat.com)
- spec fixes (jsherril@redhat.com)
- Merge pull request #1485 from ehelms/test-updates (ericdhelms@gmail.com)
- 901714-subfilters - subscription filters 901714 & 901715 fixed
  (thomasmckay@redhat.com)
- adding api for repository set enabling & listing (jsherril@redhat.com)
- adding content set disabling to model layer (jsherril@redhat.com)
- 844389 - Revert of content deletion checking removal (ares@igloonet.cz)
- Fixing errors on content_views (daviddavis@redhat.com)
- initial model changes to support faster imports (jsherril@redhat.com)
- Merge branch 'master' into story/configuration (pchalupa@redhat.com)
- add default values to configuration (pchalupa@redhat.com)
- Merge pull request #1544 from ares/bug/851331-provider_organization_id_format
  (ares@igloonet.cz)
- Merge pull request #1537 from
  ares/bug/844389-repository_deletion_and_creation (ares@igloonet.cz)
- 851331 - Add organization label attribute (ares@igloonet.cz)
- 844389 - unsuccessful repo deletion rollbacking (ares@igloonet.cz)
- 841013 - Allow same name distributions in changeset (ares@igloonet.cz)
- Merge pull request #1513 from daviddavis/cv_unique (daviddavis@redhat.com)
- content views - only associate cp_environment with content_view_environment
  (bbuckingham@redhat.com)
- content views - simplify environments for rhsm (bbuckingham@redhat.com)
- content view - fix content_view_version_environment to properly access view
  name (bbuckingham@redhat.com)
- content views - fix few tests broken when adding content view env
  (bbuckingham@redhat.com)
- content views - handle case where system create contains numeric id for env
  (bbuckingham@redhat.com)
- content views - consumer - see views as envs and allow registration to view
  (bbuckingham@redhat.com)
- content views - adding initial support for cv environments w/ candlepin
  support (bbuckingham@redhat.com)
- content views - fix product repo selector behavior for deleting a repo
  (bbuckingham@redhat.com)
- Merge remote-tracking branch 'upstream/master' into fork_content_views
  (bbuckingham@redhat.com)
- Merge pull request #1532 from lzap/test-script (lzap@redhat.com)
- Merge pull request #1503 from lzap/jruby (lzap@redhat.com)
- Merge pull request #1545 from jlsherrill/minitest-fix (jlsherrill@gmail.com)
- switching to <= for minitest (jsherril@redhat.com)
- forcing a lower version of minitest (jsherril@redhat.com)
- Merge pull request #1534 from daviddavis/es_move (daviddavis@redhat.com)
- spec fix (jsherril@redhat.com)
- fixing a couple issues with errata and packages (jsherril@redhat.com)
- Merge remote-tracking branch 'upstream/master' into fork_content_views_merge
  (bbuckingham@redhat.com)
- Log exception message for RecordNotFound exception (inecas@redhat.com)
- Merge pull request #1530 from pitr-ch/quick-fix/remove-bundler-patch
  (kontakt@pitr.ch)
- Moving elastisearch methods to module (daviddavis@redhat.com)
- Merge branch 'master' into story/configuration (pchalupa@redhat.com)
- Merge pull request #1229 from iNecas/apipie-headpin (inecas@redhat.com)
- Reduced API documentation for Headpin mode (inecas@redhat.com)
- Merge pull request #1511 from witlessbird/param_rules_error
  (witlessbird@gmail.com)
- Merge pull request #1430 from pitr-ch/story/yard (kontakt@pitr.ch)
- 908012 - fixing katello-check for pulp v1 (lzap+git@redhat.com)
- move exception_paranoia option form application.rb to katello.yml
  (pchalupa@redhat.com)
- Merge pull request #1522 from xsuchy/pull-req-sam-trans (miroslav@suchy.cz)
- remove bundler patch preferring rpms over gems (pchalupa@redhat.com)
- Merge branch 'master' into story/yard (pchalupa@redhat.com)
- Fixed more merge conflicts (paji@redhat.com)
- Fixed some merge conflicts Conflicts:   src/public/javascripts/routes.js
  (paji@redhat.com)
- bumping runcible requirement (jsherril@redhat.com)
- Content views: added view search to content search (daviddavis@redhat.com)
- Merge pull request #1520 from tstrachota/log_msg_fix (lzap@redhat.com)
- fix for typos in auth log messages (tstrachota@redhat.com)
- merge translation from SAM (msuchy@redhat.com)
- Translations - Download translations from Transifex for katello.
  (msuchy@redhat.com)
- build fix: replaced string evaluation with substitution in
  OwnRolePresenceValidator error message (dmitri@redhat.com)
- Merge pull request #1481 from witlessbird/default_environment
  (witlessbird@gmail.com)
- moved OwnRolePresenceValidator into a dedicated class and into lib/validators
  (dmitri@redhat.com)
- fixing jenkins runcible module issue (jsherril@redhat.com)
- Content views: making names unique (daviddavis@redhat.com)
- Fixed some merge conflicts (paji@redhat.com)
- Merge pull request #1510 from ehelms/runcible-logging (jlsherrill@gmail.com)
- Runcible - Updates logging configuration for Runcible so that all requests to
  Pulp will be logged at debug log level and if the log level is set to error,
  only exceptions thrown by Pulp will be logged. (ehelms@redhat.com)
- refactoring of handling of http errors (dmitri@redhat.com)
- replaced a 400 error with 422 (unprocessable entity) on param_rule check
  failure (dmitri@redhat.com)
- Removed the github reference in gemfile since ruby-gems is open
  (paji@redhat.com)
- Revert "Removed the github reference in gemfile since ruby-gems is open"
  (paji@redhat.com)
- Removed the github reference in gemfile since ruby-gems is open
  (paji@redhat.com)
- Changed the gemfile + spec to use new runcible (paji@redhat.com)
- Fixed an unintended insert (paji@redhat.com)
- Fixed a typo (paji@redhat.com)
- Updated katello code base to work with Runcible 0.3.2 (paji@redhat.com)
- Updated gemfile to use runcible 0.3.2 (paji@redhat.com)
- Merge pull request #1453 from jhadvig/system_group_errata
  (j.hadvig@gmail.com)
- Merge pull request #1507 from jlsherrill/runcible-version
  (jlsherrill@gmail.com)
- requiring specific runcible version (jsherril@redhat.com)
- renamed User#find_by_default_environment to User#with_default_environment
  (dmitri@redhat.com)
- removed strayed logging in users_controller (dmitri@redhat.com)
- refactoring of default system registration permission and user own role code
  in User model (dmitri@redhat.com)
- Merge pull request #1495 from iNecas/pulp-ping-fix (inecas@redhat.com)
- kt form builder - support for label help icon (tstrachota@redhat.com)
- hw models - ui pages (tstrachota@redhat.com)
- hw models - model and api (tstrachota@redhat.com)
- foreman model - support for different resource name in foreman
  (tstrachota@redhat.com)
- abstract model - parse attributes properly on create (tstrachota@redhat.com)
- Using OPTIONS method on Pulp API to find out it's running (inecas@redhat.com)
- jruby - get jdbc running with bundler_ext (lzap+git@redhat.com)
- jruby - checking devel gems disabled for jruby (lzap+git@redhat.com)
- jruby - enabling threadsafe and fixing manifest upload (lzap+git@redhat.com)
- Content views: various fixes to UI and CLI (daviddavis@redhat.com)
- Merge pull request #1499 from jlsherrill/1.9fix (jlsherrill@gmail.com)
- Merge pull request #1498 from thomasmckay/jsroutes-update
  (thomasmckay@redhat.com)
- fixing ruby 1.9 error (jsherril@redhat.com)
- updated routes.js, fixed typo array_with_total (thomasmckay@redhat.com)
- Merge pull request #1480 from ehelms/pulpv2 (ericdhelms@gmail.com)
- Merge branch 'master' into v2-cv (paji@redhat.com)
- Merge branch 'content_views' into v2-cv (paji@redhat.com)
- Fixed a small error in default content view publish (paji@redhat.com)
- Revert "Fixed a small error in default content view publish"
  (paji@redhat.com)
- White-spaces fixes in Gemfiles (inecas@redhat.com)
- Merge pull request #1492 from jlsherrill/redhat-promotion-fix
  (jlsherrill@gmail.com)
- create a distributor for disabled repos (jsherril@redhat.com)
- Merge pull request #1469 from daviddavis/jsroutefix (daviddavis@redhat.com)
- Minitest - Adds flag to allow running Pulp glue tests against live Pulp
  without recording new cassettes.  This can be useful to test your Pulp setup
  and functionality without accidentally generating a set of new cassettes.
  (ehelms@redhat.com)
- Fixed a small error in default content view publish (paji@redhat.com)
- Merge branch 'master' into v2-cv (paji@redhat.com)
- Merge pull request #1479 from ares/bug/790064-manifest_import_error_handling
  (ares@igloonet.cz)
- fix YARD Documentation link (pchalupa@redhat.com)
- Content views: fixed a couple UI content view bugs
- Merge branch 'master' into story/yard (pchalupa@redhat.com)
- document workaround if running yard in reload mode fails
  (pchalupa@redhat.com)
- Fix setting environment without usage RAILS_ENV (inecas@redhat.com)
- Merge branch 'master' into v2-cv (paji@redhat.com)
- Fix to get Promotions controller test to work (paji@redhat.com)
- Fixed an accidental typo in the cv spec file (paji@redhat.com)
- Fixed some files missed in previous merges (paji@redhat.com)
- Fixed some unit tests (paji@redhat.com)
- PulpV2 - Clean-up of authorization modules to use ActiveSupport::Concern for
  clarity and consistency. (ehelms@redhat.com)
- 790064 - Fix for manifest import in headpin mode (ares@igloonet.cz)
- Removed trailing whitespaces (paji@redhat.com)
- Merge branch 'pulpv2' into v2-cv (paji@redhat.com)
- Fixed more conflicts (paji@redhat.com)
- Missed commits (paji@redhat.com)
- Fixed some merge conflicts (paji@redhat.com)
- Merge pull request #1470 from daviddavis/cv_fixjsroutes
  (daviddavis@redhat.com)
- Merge pull request #1420 from bbuckingham/fork_content_views_composite
  (bbuckingham@redhat.com)
- Regenerating content view js routes (daviddavis@redhat.com)
- Locking down js-routes to 0.6.x due to code breakages (daviddavis@redhat.com)
- Locking down js-routes to 0.6.x due to code breakages (daviddavis@redhat.com)
- content views - update to handle deletion of repo from a definition
  (bbuckingham@redhat.com)
- Merge pull request #1422 from daviddavis/cv_sys_search
  (daviddavis@redhat.com)
- Merge pull request #1413 from daviddavis/cv_key_ui (daviddavis@redhat.com)
- remove dependencies on yard-activerecord and railroady (pchalupa@redhat.com)
- Merge branch 'master' into story/yard (pchalupa@redhat.com)
- 858877 Allow selection of all listem items when applying packages to a system
  group (j.hadvig@gmail.com)
- remove svg files from git repository (pchalupa@redhat.com)
- add missing type notation in @option tags (pchalupa@redhat.com)
- update yard documentation guide (pchalupa@redhat.com)
- add how to document guide (pchalupa@redhat.com)
- Content views: added content_view to system search (daviddavis@redhat.com)
- content views - resolve issues with promotion, publish..etc
  (bbuckingham@redhat.com)
- Merge pull request #1402 from bbuckingham/fork_content_views_composite
  (bbuckingham@redhat.com)
- Content views: showing content view in left pane of key layout
  (daviddavis@redhat.com)
- Content views: worked on activation two pane (daviddavis@redhat.com)
- Content views: UI for edit/update activation key content views
  (daviddavis@redhat.com)
- fix katello.spec (pchalupa@redhat.com)
- fix some documentation formatting errors (pchalupa@redhat.com)
- set Markdown as default markup (pchalupa@redhat.com)
- make inline code block noticeable (pchalupa@redhat.com)
- add model and controller graphs (pchalupa@redhat.com)
- fix yard doc reloading, render only one documentation (:single_library
  option) (pchalupa@redhat.com)
- Content views: create/edit content views for systems (daviddavis@redhat.com)
- Merge pull request #1394 from daviddavis/cv_gitignore (daviddavis@redhat.com)
- content views - ui - component views may not have same repo
  (bbuckingham@redhat.com)
- content views - ui - create/update composite view definition
  (bbuckingham@redhat.com)
- make yardoc server embedding configurable (pchalupa@redhat.com)
- Merge branch 'pulpv2' into another-v2-to-cv (paji@redhat.com)
- Pulling in the gitignore from master (daviddavis@redhat.com)
- Merge pull request #1388 from parthaa/v2-to-cv (parthaa@gmail.com)
- Regenerated VCR files. (paji@redhat.com)
- update readme (pchalupa@redhat.com)
- add yard-activerecord plugin (pchalupa@redhat.com)
- embed YARD documentation server into Katello server in development
  (pchalupa@redhat.com)
- Merge pull request #1386 from daviddavis/param_rules (daviddavis@redhat.com)
- Merge pull request #1380 from daviddavis/cv_publish_async
  (daviddavis@redhat.com)
- add foreman integration documentation (pchalupa@redhat.com)
- Merging branch pulpv2 to content_views (paji@redhat.com)
- Content views: locking down params in api controllers (daviddavis@redhat.com)
- Content views: supporting async publishing (daviddavis@redhat.com)
- Content views: added in_environment scope to ContentView
  (daviddavis@redhat.com)
- Content views: some things I found preparing for the demo
  (daviddavis@redhat.com)
- Content views: added CLI for systems with content views
  (daviddavis@redhat.com)
- Content views: added some system/key functionality (daviddavis@redhat.com)
- Merge pull request #1368 from bbuckingham/fork_content_views_deletion
  (bbuckingham@redhat.com)
- content views - fix on test for definition deletion (bbuckingham@redhat.com)
- content_views - update has_promoted_views to perform single query
  (bbuckingham@redhat.com)
- content views - api - do not allow deletion of definition w/ promoted views
  (bbuckingham@redhat.com)
- content views - ui - do not allow deletion of definition w/ promoted views
  (bbuckingham@redhat.com)
- content views - fix permission on default_label action
  (bbuckingham@redhat.com)
- Content views: content view can be set on keys in CLI (daviddavis@redhat.com)
- Fixing bundle install for content_views branch (daviddavis@redhat.com)
- content views - simply the retrieval of library version
  (bbuckingham@redhat.com)
- content_views - remove unused publishing methods from content_view.rb
  (bbuckingham@redhat.com)
- content views - updates to support retry on refresh/publish failure
  (bbuckingham@redhat.com)
- content views - if task is nil, publish failed (bbuckingham@redhat.com)
- content views - update sortElement asset to pull from alchemy vs converge-ui
  (bbuckingham@redhat.com)
- content views - adding the 'filters' placeholder back in to routes/controller
  (bbuckingham@redhat.com)
- content views - adding in some spec tests for definition cloning
  (bbuckingham@redhat.com)
- content views - fix permission on ContentViewDefinition.creatable?
  (bbuckingham@redhat.com)
- content views - update ui controller to use correct rules for actions
  (bbuckingham@redhat.com)
- content views - ui - add support for cloning an existing definition
  (bbuckingham@redhat.com)
- content views - copy form - give name input focus (bbuckingham@redhat.com)
- content views - add notices for the start/end of publish/refresh
  (bbuckingham@redhat.com)
- content view - handle case where task is nil (bbuckingham@redhat.com)
- Merge pull request #1321 from parthaa/merge-to-cv (daviddavis@redhat.com)
- Couple of fixes to make travis happy (paji@redhat.com)
- Regenerated the vcr files to make travis happy (paji@redhat.com)
- Fixed a test to make travis happy (paji@redhat.com)
- Removing filters from the content view branch (paji@redhat.com)
- content views - fix test failure after async publish chgs
  (bbuckingham@redhat.com)
- Merge branch 'pulpv2' into merge-to-cv (paji@redhat.com)
- content view - refactor out retrieving the task_status associated w/ publish
  (bbuckingham@redhat.com)
- content views - support publish as 'async' in UI (includes backend chgs)
  (bbuckingham@redhat.com)
- content views - UI - views, handle case where there is no task
  (bbuckingham@redhat.com)
- Merge pull request #1317 from daviddavis/cv_cli_ref (daviddavis@redhat.com)
- Content views: fixed broken refresh tests (daviddavis@redhat.com)
- Content views: handling new refresh code from CLI/API (daviddavis@redhat.com)
- Merge pull request #1269 from daviddavis/cv_test_fixed
  (daviddavis@redhat.com)
- Merge pull request #1263 from bbuckingham/fork_content_views
  (daviddavis@redhat.com)
- Content views: fixing tests due to == returning false (daviddavis@redhat.com)
- Content views: api refresh test (daviddavis@redhat.com)
- Content views: refreshing views from the CLI (daviddavis@redhat.com)
- Content views: temporarily fix breaking tests (daviddavis@redhat.com)
- Merge pull request #1262 from daviddavis/cv_act_key (daviddavis@redhat.com)
- content views - shorten length of couple of lines (bbuckingham@redhat.com)
- content views - support refresh as 'async' in UI (includes backend chgs)
  (bbuckingham@redhat.com)
- Merge pull request #1251 from daviddavis/cv_tests (daviddavis@redhat.com)
- Content views: activation key without cv test (daviddavis@redhat.com)
- Content views: added activation key and validation (daviddavis@redhat.com)
- content views - update views treetable to reinitialize on content change
  (bbuckingham@redhat.com)
- content views - address 2 minor comments from PR review
  (bbuckingham@redhat.com)
- content views - ui - refresh - update views pane after refresh
  (bbuckingham@redhat.com)
- content views - initial ui changes to support view refresh
  (bbuckingham@redhat.com)
- content views - initial model changes to support view refresh
  (bbuckingham@redhat.com)
- content views - updates to views pane to better support multiple versions
  (bbuckingham@redhat.com)
- Content views: Added tests for new arguments (daviddavis@redhat.com)
- Merge pull request #1241 from daviddavis/cvd_args (daviddavis@redhat.com)
- Content views: fixed tests and feedback for def args (daviddavis@redhat.com)
- Merge pull request #1225 from daviddavis/cv_args (daviddavis@redhat.com)
- Merge pull request #1214 from daviddavis/cv_demotion (daviddavis@redhat.com)
- Content views: added id and name to cli definition commands
  (daviddavis@redhat.com)
- Content views: removing old test (daviddavis@redhat.com)
- Content views: added id and name to cv arguments (daviddavis@redhat.com)
- Merge pull request #1211 from daviddavis/cv_env (daviddavis@redhat.com)
- Merge pull request #1203 from bbuckingham/fork_content_views
  (daviddavis@redhat.com)
- content views - fix for specs failing in ruby 1.9.3 (bbuckingham@redhat.com)
- Content views: worked on changeset deletion of views (daviddavis@redhat.com)
- Content views: showing repo info in cli (daviddavis@redhat.com)
- content views - spec fixes based on changes to support default content views
  (bbuckingham@redhat.com)
- Content views: changesets can have views in CLI (daviddavis@redhat.com)
- content views - update product.repos to handle default content view
  (bbuckingham@redhat.com)
- Content views: remove checking for promotion (daviddavis@redhat.com)
- Content views: tweaks and fixes for promotion (daviddavis@redhat.com)
- Content views: renamed content views controller test (daviddavis@redhat.com)
- content views - update changesets content tree to retrieve repos from default
  view (bbuckingham@redhat.com)
- content views - add content view to changeset history
  (bbuckingham@redhat.com)
- Merge pull request #1175 from bbuckingham/fork_content_views
  (bbuckingham@redhat.com)
- Merge pull request #1174 from daviddavis/cv_promote (daviddavis@redhat.com)
- Content views: removed promotion code out of api controller
  (daviddavis@redhat.com)
- Content views: reworking generate_repos (daviddavis@redhat.com)
- Content views: updated content view api tests (daviddavis@redhat.com)
- Content views: handling async view promotion (daviddavis@redhat.com)
- Content views: creating changeset during promotion shortcut
  (daviddavis@redhat.com)
- content views - on changesets page, allow user to see view details
  (bbuckingham@redhat.com)
- Merge pull request #1172 from bbuckingham/fork_content_views
  (parthaa@gmail.com)
- Content views: versions are dependent destroy (daviddavis@redhat.com)
- Content views: added cli promote command (daviddavis@redhat.com)
- Content views: added promote action to cv api (daviddavis@redhat.com)
- Added some support code for minitest controller specs (daviddavis@redhat.com)
- content views - update UI to allow for changesets containing content views
  (bbuckingham@redhat.com)
- content views - add scopes to content_view_version (bbuckingham@redhat.com)
- content view - update changeset to allow deleting content view
  (bbuckingham@redhat.com)
- Content views: fixed bug with content view repos getting published
  (daviddavis@redhat.com)
- content views - ui - initial code for the view definition -> Views pane
  (bbuckingham@redhat.com)
- Merge pull request #1143 from bbuckingham/fork_content_views-2
  (bbuckingham@redhat.com)
- Merge pull request #1130 from daviddavis/cv_random_fixes
  (daviddavis@redhat.com)
- content views - minor cleanup (bbuckingham@redhat.com)
- Merge pull request #1144 from daviddavis/cv_act_key (daviddavis@redhat.com)
- Content views: fixed bug in definition api controller (daviddavis@redhat.com)
- content views - ui - initial code for the view definition -> content pane
  (bbuckingham@redhat.com)
- content views - ui - add the skeleton to support views, content, filter panes
  (bbuckingham@redhat.com)
- Content views: couple of small fixes (daviddavis@redhat.com)
- Content views: cli info and list work (daviddavis@redhat.com)
- Content views: re-enabled info cli commands (daviddavis@redhat.com)
- Content views: fixing api controller specs (daviddavis@redhat.com)
- Content views: worked on api controllers and perms (daviddavis@redhat.com)
- Fixed js routes (daviddavis@redhat.com)
- Merge remote-tracking branch 'upstream/pulpv2' into content_views
  (daviddavis@redhat.com)
- merge conflict (jsherril@redhat.com)
- content views - update routes.js (bbuckingham@redhat.com)
- minitest fix (jsherril@redhat.com)
- spect fix (jsherril@redhat.com)
- spec fixes (jsherril@redhat.com)
- spec fixes (jsherril@redhat.com)
- spec fixes (jsherril@redhat.com)
- spec fixes (jsherril@redhat.com)
- addressing PR comments (jsherril@redhat.com)
- spec fixes (jsherril@redhat.com)
- one last clone_id fix (jsherril@redhat.com)
- cassette updates (jsherril@redhat.com)
- fixing some more spects (jsherril@redhat.com)
- spec fixes (jsherril@redhat.com)
- merge conflict (jsherril@redhat.com)
- content views - migrating to using CV version (jsherril@redhat.com)
- Merge pull request #1080 from daviddavis/cv_test_fixes (jlsherrill@gmail.com)
- Content views: fixing auth test (daviddavis@redhat.com)
- Content views: remove ruby-debug (daviddavis@redhat.com)
- Content views: fixed authorization bug (daviddavis@redhat.com)
- Content views: fixed content view def test (daviddavis@redhat.com)
- Merge remote-tracking branch 'upstream/pulpv2' into content_views
  (daviddavis@redhat.com)
- Merge pull request #1073 from bbuckingham/fork_content_views
  (bbuckingham@redhat.com)
- content views - shorting nav label to use Views (bbuckingham@redhat.com)
- Merge pull request #1060 from bbuckingham/fork_content_views
  (bbuckingham@redhat.com)
- content view - allow publishing to views by giving name/lable/description
  (jsherril@redhat.com)
- removing relative path function that is no longer needed
  (jsherril@redhat.com)
- content views - ui - initial CRUD support for name/label/description
  (bbuckingham@redhat.com)
- Content views: content view permissions and tests (daviddavis@redhat.com)
- Merge branch 'content_views' of https://github.com/Katello/katello into
  content_views (jsherril@redhat.com)
- content view - lots of changes to support repos (jsherril@redhat.com)
- Content views: fixed definition auth bugs (daviddavis@redhat.com)
- Content views: created publish permission (daviddavis@redhat.com)
- content views - making view deletion support repos (jsherril@redhat.com)
- content views - allow publication of content views definitions with repos
  (jsherril@redhat.com)
- Content views: definitions habtm repos (daviddavis@redhat.com)
- Merge branch 'pulpv2' into content_views (daviddavis@redhat.com)
- Content views: fixing route (daviddavis@redhat.com)
- Content views: Fixed bad merge in organization (daviddavis@redhat.com)
- content views - adding support for view deletion (jsherril@redhat.com)
- content views - adding content view promotion
- Fixed all the minitest tests (daviddavis@redhat.com)
- Pulp v2 - Fixing bad require in test (daviddavis@redhat.com)
- Content views: created auth for definitions (daviddavis@redhat.com)
- Content views: validation for composite content defs (daviddavis@redhat.com)
- Content views: added api specs (daviddavis@redhat.com)
- Content views: created add_view and remove_view (daviddavis@redhat.com)
- Content views: added env argument to list (daviddavis@redhat.com)
- Content views: removed erroneous api actions (daviddavis@redhat.com)
- Merged together duplicate factories (daviddavis@redhat.com)
- Content views: changesets check for invalid views (daviddavis@redhat.com)
- Content views: views can be added to changesets (daviddavis@redhat.com)
- Content views: created changeset association (daviddavis@redhat.com)
- Content views: fixed product :bug: with cp_id (daviddavis@redhat.com)
- Content views: added repo cli commands (daviddavis@redhat.com)
- Content views: Added repository association to def (daviddavis@redhat.com)
- Content views: Refactored composite/component (daviddavis@redhat.com)
- Content views: Added add_product for cli (daviddavis@redhat.com)
- Content views: fixed update cli command (daviddavis@redhat.com)
- Content views: added destroy to api controller/cli (daviddavis@redhat.com)
- Content views: fixed view -> product relationship (daviddavis@redhat.com)
- Content views: Worked on labels and cli (daviddavis@redhat.com)
- Content views: setup associations (daviddavis@redhat.com)
- Content views: initial setup of models (daviddavis@redhat.com)
- Pulpv2 - Switching FG to version from Fedora repos (daviddavis@redhat.com)

* Wed Jan 30 2013 Justin Sherrill <jsherril@redhat.com> 1.3.14-1
- bumping required runcible version (jsherril@redhat.com)
- require pulp-selinux (jsherril@redhat.com)
- 832134 - making description search more consistent (jsherril@redhat.com)
- 820382 - adding env_id to promoted cs link on dashboard (jsherril@redhat.com)

* Wed Jan 30 2013 Justin Sherrill <jsherril@redhat.com> 1.3.13-1
- changing default config template port for post_sync_url (jsherril@redhat.com)
- removing pulpv2 prefix from pulpv2 branch (jsherril@redhat.com)
- adding post sync url to config template (jsherril@redhat.com)
- PulpV2 - Fixes broken test by stubbing Runcible method. (ehelms@redhat.com)
- running db:migrate && db:seed as different rake commands
  (jsherril@redhat.com)
- 790064 - Manifest import error handling (ares@igloonet.cz)
- 790064 - Refactoring of unreadeable methods (ares@igloonet.cz)

* Mon Jan 28 2013 Justin Sherrill <jsherril@redhat.com> 1.3.12.pulpv2-1
- fixing changelog (jsherril@redhat.com)
- merge conflict (jsherril@redhat.com)
- Merge pull request #1466 from daviddavis/apispecfix (daviddavis@redhat.com)
- Automatic commit of package [katello] release [1.3.5-1].
  (jsherril@redhat.com)
- fixing compass version (jsherril@redhat.com)
- Reverting locale changes to api specs (daviddavis@redhat.com)

* Fri Jan 25 2013 Justin Sherrill <jsherril@redhat.com> 1.3.11.pulpv2-1
- fixing pulp url in config template (jsherril@redhat.com)
- fix whitespace (jsherril@redhat.com)
- change ruby-linter to print out all errors (jsherril@redhat.com)
- adding use_elasticsearch to config template (jsherril@redhat.com)
- merge fix (jsherril@redhat.com)
- updating ES glue to use Ext::IndexedModel (jsherril@redhat.com)
- merge conflict (jsherril@redhat.com)
- more spec fixes (jsherril@redhat.com)
- fixing minitests and most specs (jsherril@redhat.com)

* Fri Jan 25 2013 Justin Sherrill <jsherril@redhat.com> 1.3.5-1
- fixing compass version (jsherril@redhat.com)
- added lib/resources/abstract_model dir and its contents to the .spec file
  (dmitri@redhat.com)
- orgs - new scope for finding by name or label (tstrachota@redhat.com)
- 895212 - correct org search (tstrachota@redhat.com)
- fixes building of foreman glue rpm (dmitri@redhat.com)
- removed redundant dir inclusion in headpin (dmitri@redhat.com)
- fix for a broken .spec: now includes files in models/ext dir during the build
  (dmitri@redhat.com)
- 887095 - fixing API breakage (lzap+git@redhat.com)
- 887095 - Fixing test and feedback (daviddavis@redhat.com)
- 903000 - Fix for missing params checking on System Templates
  (jrist@redhat.com)
- bumping version of therubyracer (lzap+git@redhat.com)
- avoid problematic ZenTest-4.8.4 (lzap+git@redhat.com)
- Revert "fix building on F18" (lzap+git@redhat.com)
- Revert "Fix F16,EL6 after fixing F18" (lzap+git@redhat.com)
- Revert "correctly compare version" (lzap+git@redhat.com)
- Revert "do not fail if you use bundler" (lzap+git@redhat.com)
- Revert "workaround BZ 901540" (lzap+git@redhat.com)
- Revert "do not use ZenTest 4.8.4" (lzap+git@redhat.com)
- fixed a syntax error under 1.8.7 (dmitri@redhat.com)
- moved most of the modules in app/models to either models/ext or lib/
  directories (dmitri@redhat.com)
- Revert "Fixing Travis for Ruby 1.9" (lzap+git@redhat.com)
- renamed 'CustomPermissions' into 'PermissionTagCleanup' (dmitri@redhat.com)
- fix for BZ 860452: custom tags are now being deleted when associated entity
  is deleted (dmitri@redhat.com)
- uuid - now works with Rails 3.2 (lzap+git@redhat.com)
- Fixed wrong param format (mbacovsk@redhat.com)
- 896074 - fixing remove deletion permissions (lzap+git@redhat.com)
- smart proxies - listing available features in cli info
  (tstrachota@redhat.com)
- 887095 - cli locale was not set properly (lzap+git@redhat.com)
- Fixing Travis for Ruby 1.9 (daviddavis@redhat.com)
- do not use ZenTest 4.8.4 (msuchy@redhat.com)
- workaround BZ 901540 (msuchy@redhat.com)
- do not fail if you use bundler (msuchy@redhat.com)
- correctly compare version (msuchy@redhat.com)
- Fix F16,EL6 after fixing F18 (msuchy@redhat.com)
- fix building on F18 (msuchy@redhat.com)
- 901657 - Adds standard name validator to role names to prevent HTML
  injection. (ehelms@redhat.com)
- 867991 - fixing tab index on env and activation key new pages
  (jsherril@redhat.com)
- 795003 - Adds a word wrap to edit text fields so that long names, such as the
  CDN URL being long. (ehelms@redhat.com)
- 902948 - fixing errata icons in content search (jsherril@redhat.com)
- 858008 - Adds event trigger and bind to close action bar when sliding tree
  items are clicked. (ehelms@redhat.com)
- CVE-2012-3503 - setting umask for /etc/katello/secret-token
  (jomara@redhat.com)
- 852885 - Fixing spinner image (daviddavis@redhat.com)
- 860471 - Fix for flicker - extra .tipsify call. (jrist@redhat.com)
- rails 3.2 removed ActiveSupport::SecureRandom in favor of SecureRandom
  (msuchy@redhat.com)
- fixing test runs for jenkins and travis (komidore64@gmail.com)
- bundler_ext - renaming namespace (lzap+git@redhat.com)
- Smart proxies UI (mbacovsk@redhat.com)
- foreman_api gem version bumped up to 0.0.10 (tstrachota@redhat.com)
- comp. res. - api, model for each provider (tstrachota@redhat.com)
- simple crud controller - support for custom as_json options
  (tstrachota@redhat.com)
- abstract model - support for instantiating subclasses (tstrachota@redhat.com)
- abstract model - setting resources made consistent (tstrachota@redhat.com)
- architectures - fixed removing all OSs on update (tstrachota@redhat.com)
- subnets - required attributes in model (tstrachota@redhat.com)
- foreman integration ui fixes (tstrachota@redhat.com)
- requiring 'thumbslug_url' in configuration for headpin only
  (komidore64@gmail.com)
- adding thumbslug to headpin's ping function and tests, etc
  (komidore64@gmail.com)
- Fixing the reset-oauth script to also do ../config/katello.yml if it exists.
  (jrist@redhat.com)
- 820404- Renamed the debug cert button as suggested in the bz
  (paji@redhat.com)
- Code review comments lead to discovery of dead code. The import_status and
  export_status files do not appear tied to any controller and they are only
  referenced by a route which is also not tied to a controller
  (bkearney@redhat.com)
- 868045: Missed translating string when there are no products for a system
  (bkearney@redhat.com)

* Fri Jan 25 2013 Justin Sherrill <jsherril@redhat.com>
- fixing compass version (jsherril@redhat.com)
- added lib/resources/abstract_model dir and its contents to the .spec file
  (dmitri@redhat.com)
- orgs - new scope for finding by name or label (tstrachota@redhat.com)
- 895212 - correct org search (tstrachota@redhat.com)
- fixes building of foreman glue rpm (dmitri@redhat.com)
- removed redundant dir inclusion in headpin (dmitri@redhat.com)
- fix for a broken .spec: now includes files in models/ext dir during the build
  (dmitri@redhat.com)
- 887095 - fixing API breakage (lzap+git@redhat.com)
- fixing some merge conflict broken-ness (jsherril@redhat.com)
- merge conflict (jsherril@redhat.com)
- 887095 - Fixing test and feedback (daviddavis@redhat.com)
- 903000 - Fix for missing params checking on System Templates
  (jrist@redhat.com)
- bumping version of therubyracer (lzap+git@redhat.com)
- exclude test.rake for main rpm (jsherril@redhat.com)
- avoid problematic ZenTest-4.8.4 (lzap+git@redhat.com)
- Revert "fix building on F18" (lzap+git@redhat.com)
- Revert "Fix F16,EL6 after fixing F18" (lzap+git@redhat.com)
- Revert "correctly compare version" (lzap+git@redhat.com)
- Revert "do not fail if you use bundler" (lzap+git@redhat.com)
- Revert "workaround BZ 901540" (lzap+git@redhat.com)
- Revert "do not use ZenTest 4.8.4" (lzap+git@redhat.com)
- fixed a syntax error under 1.8.7 (dmitri@redhat.com)
- moved most of the modules in app/models to either models/ext or lib/
  directories (dmitri@redhat.com)
- Revert "Fixing Travis for Ruby 1.9" (lzap+git@redhat.com)
- renamed 'CustomPermissions' into 'PermissionTagCleanup' (dmitri@redhat.com)
- fix for BZ 860452: custom tags are now being deleted when associated entity
  is deleted (dmitri@redhat.com)
- uuid - now works with Rails 3.2 (lzap+git@redhat.com)
  (martin.bacovsky@gmail.com)
- Fixed wrong param format (mbacovsk@redhat.com)
  (bryan.kearney@gmail.com)
- 896074 - fixing remove deletion permissions (lzap+git@redhat.com)
- smart proxies - listing available features in cli info
  (tstrachota@redhat.com)
- 887095 - cli locale was not set properly (lzap+git@redhat.com)
- Fixing Travis for Ruby 1.9 (daviddavis@redhat.com)
- do not use ZenTest 4.8.4 (msuchy@redhat.com)
- workaround BZ 901540 (msuchy@redhat.com)
- do not fail if you use bundler (msuchy@redhat.com)
- correctly compare version (msuchy@redhat.com)
- Fix F16,EL6 after fixing F18 (msuchy@redhat.com)
- fix building on F18 (msuchy@redhat.com)
- 901657 - Adds standard name validator to role names to prevent HTML
  injection. (ehelms@redhat.com)
- 867991 - fixing tab index on env and activation key new pages
  (jsherril@redhat.com)
- 795003 - Adds a word wrap to edit text fields so that long names, such as the
  CDN URL being long. (ehelms@redhat.com)
- 902948 - fixing errata icons in content search (jsherril@redhat.com)
- 858008 - Adds event trigger and bind to close action bar when sliding tree
  items are clicked. (ehelms@redhat.com)
- CVE-2012-3503 - setting umask for /etc/katello/secret-token
  (jomara@redhat.com)
- 852885 - Fixing spinner image (daviddavis@redhat.com)
- 860471 - Fix for flicker - extra .tipsify call. (jrist@redhat.com)
- rails 3.2 removed ActiveSupport::SecureRandom in favor of SecureRandom
  (msuchy@redhat.com)
- fixing test runs for jenkins and travis (komidore64@gmail.com)
- bundler_ext - renaming namespace (lzap+git@redhat.com)
- Smart proxies UI (mbacovsk@redhat.com)
- foreman_api gem version bumped up to 0.0.10 (tstrachota@redhat.com)
- comp. res. - api, model for each provider (tstrachota@redhat.com)
- simple crud controller - support for custom as_json options
  (tstrachota@redhat.com)
- abstract model - support for instantiating subclasses (tstrachota@redhat.com)
- abstract model - setting resources made consistent (tstrachota@redhat.com)
- architectures - fixed removing all OSs on update (tstrachota@redhat.com)
- subnets - required attributes in model (tstrachota@redhat.com)
- foreman integration ui fixes (tstrachota@redhat.com)
- requiring 'thumbslug_url' in configuration for headpin only
  (komidore64@gmail.com)
- Automatic commit of package [katello] release [1.3.3-1].
  (jsherril@redhat.com)
- Translations - Update .po and .pot files for katello. (jsherril@redhat.com)
- Translations - New translations from Transifex for katello.
  (jsherril@redhat.com)
- Translations - Download translations from Transifex for katello.
  (jsherril@redhat.com)
- Setting the min_messages level to warning (daviddavis@redhat.com)
- Repository feed validation moved to validator (mhulan@redhat.com)
- Code cleanup (mhulan@redhat.com)
- Move all validators to one place (mhulan@redhat.com)
- 820392 - repository hostname validation (mhulan@redhat.com)
- emails - add default From to login/password emails (bbuckingham@redhat.com)
- adding thumbslug to headpin's ping function and tests, etc
  (komidore64@gmail.com)
- 882311 - hide and check organizations being deleted (lzap+git@redhat.com)
- 882311 - remove scope-based organization hiding when deleting it
  (lzap+git@redhat.com)
- Fixing the reset-oauth script to also do ../config/katello.yml if it exists.
  (jrist@redhat.com)
- fix missing assets when running in development (pchalupa@redhat.com)
- Automatic commit of package [katello] release [1.3.2-1].
  (lzap+git@redhat.com)
- Fix post install scriptlet (inecas@redhat.com)
- add missing documentation (pchalupa@redhat.com)
- fix error message, missing space (pchalupa@redhat.com)
- rails-i18n - upstream checker script (lzap+git@redhat.com)
- rails-i18n - pulling yml files from upstream (lzap+git@redhat.com)
- rails-i18n - adding update script (lzap+git@redhat.com)
- 891926 - katello refuses to restart (lzap+git@redhat.com)
- Locking rails version to fix bundle install (daviddavis@redhat.com)
- 879094 - fixing %%post error in spec (jomara@redhat.com)
- Moving tomcat group add to katello-shared to %%post (jomara@redhat.com)
- 879094 - a few updates to katello & katello-selinux spec based on comments
  (jomara@redhat.com)
- renaming katello_shared -> katello-shared (jomara@redhat.com)
- 879094 - CVE-2012-5561 - fix permissions on /etc/katello/secure
  (jomara@redhat.com)
- Allowing for local gem groups (daviddavis@redhat.com)
- 868090 - [ru_RU] L10n:Content Management - Repositories: Untranslated string
  in Products and Repositories tab (komidore64@gmail.com)
- changing 'empty?' to 'blank?' (komidore64@gmail.com)
- Removing Gemfile.lock files since they are out of date
  (daviddavis@redhat.com)
- 880515 - [ALL_LANG][headpin CLI] Redundant brackets in the message of
  'Couldn't find organization '??' ()' for system report module with invalid
  --org name. (komidore64@gmail.com)
- fixing reset issue (jsherril@redhat.com)
- Adding tests to check menu item keys for uniqueness (daviddavis@redhat.com)
- fix typo occured -> occurred (msuchy@redhat.com)
- 843421 - add parens to existing code (bbuckingham@redhat.com)
- Make the :key fields of all the Setup menu items unique across all the
  navigation. (jweiss@redhat.com)
- merge pt_BR from SAM (msuchy@redhat.com)
- add accidentally deleted pt_BR (msuchy@redhat.com)
- Removing README and updating spec file (daviddavis@redhat.com)
- fixing ru/app.po (msuchy@redhat.com)
- forward port translation from SAM (msuchy@redhat.com)
- Add back katello specific readme. (jweiss@redhat.com)
- Remove README that was generated by Ruby on Rails. (jweiss@redhat.com)
- ignore obsoletes and fuzzy warnings (msuchy@redhat.com)
- Bug 799356 - systems that have been deleted that are still calling back to
  server generate stack trace (pchalupa@redhat.com)
- logging - orchestration log - unit test fix (lzap+git@redhat.com)
- removing console.log (jsherril@redhat.com)
- 751159 - downloading a modified system template would present warning
  (jsherril@redhat.com)
- 820404- Renamed the debug cert button as suggested in the bz
  (paji@redhat.com)
- 831362 - systems - disable/enable system group widget on actions panel
  (bbuckingham@redhat.com)
- 869371-ram - able to set RAM during new system creation in UI
  (thomasmckay@redhat.com)
- 848566 - fixing verbage of system group limit (jsherril@redhat.com)
- 848553 - tupane - remove 'do_not_open' on copy (bbuckingham@redhat.com)
- user searches containing empty display attributes are no longer being saved
  in the history (dmitri@redhat.com)
- 858743 - Stop redirect after login to ajax notices path
  (daviddavis@redhat.com)
- 842745 - Fixed rspec test (daviddavis@redhat.com)
- 844708 - update panel action confirmation dialog to close on 'yes' click
  (bbuckingham@redhat.com)
- 842745 - Showing update message on package group update
  (daviddavis@redhat.com)
- adding thumbslug to headpin's ping function and tests, etc
  (komidore64@gmail.com)
- Fixing the reset-oauth script to also do ../config/katello.yml if it exists.
  (jrist@redhat.com)
- 820404- Renamed the debug cert button as suggested in the bz
  (paji@redhat.com)
- Code review comments lead to discovery of dead code. The import_status and
  export_status files do not appear tied to any controller and they are only
  referenced by a route which is also not tied to a controller
  (bkearney@redhat.com)
- 878891-actkey-alignment - put act keys into table (thomasmckay@redhat.com)
- 873665 - getting rid of last find_by_username admin calls
  (lzap+git@redhat.com)
- 808461 - prevent from creating a repo in rh providers (lzap+git@redhat.com)
- 875225 - Binding favicon refresh to hash change (daviddavis@redhat.com)
- 888019 - fixing issue where only 10 repos would appear on content search
  (jsherril@redhat.com)
- 843421 - systems - include summary when removing system groups using bulk
  action (bbuckingham@redhat.com)
- Fix for not loading system template detail (mhulan@redhat.com)
- Fixing a non-deterministic text failure (jomara@redhat.com)
- 848571 - fixing verbage on content search (jsherril@redhat.com)
- 882248 - making environment name editable (jomara@redhat.com)
- 806096 fix - display checkboxes to readonly users (mhulan@redhat.com)
- 868045: Missed translating string when there are no products for a system
  (bkearney@redhat.com)
- 781287 fix - update notification counter (mhulan@redhat.com)
- Fixes few typos (ares@igloonet.cz)
- 835902 fixes notification for GPG key upload (ares@igloonet.cz)
- logging - orchestration log rotating (lzap+git@redhat.com)
- logging - orchestration logger and uuid request tracking
  (lzap+git@redhat.com)
- Fixes 790216 running changesets concurently (ares@igloonet.cz)
- 885261 - org deletion unit test correction (lzap+git@redhat.com)
- 885261 - make data repair script to work from any dir (lzap+git@redhat.com)
- 885261 - org deletion should remove rh provider (lzap+git@redhat.com)
- better error messages (pchalupa@redhat.com)
- 858726 - Sets the compare repos button to disable if there are 0 or 1 repos
  enabled on content search. (ehelms@redhat.com)
- 817858 - Permission edits now show tags when appropriate. (ehelms@redhat.com)
- 791345 - Deletes errant tick mark that was appearing after list updates on
  the sync plan page. (ehelms@redhat.com)
- 843566 - Sets the chosen dropdown in Content Search to not display a filter
  mechanism. (ehelms@redhat.com)
- 855945 - Content search now displays the Library if there are no
  environments. (ehelms@redhat.com)
- 871093 - Fix to show tags when "+ All" verbs is selected. (ehelms@redhat.com)
- 845062 - Fixes typo with errata search icon tooltip. (ehelms@redhat.com)
- 772199 - Adds a tool tip to explain that GPG keys are optional for products
  and repositories. (ehelms@redhat.com)
- 839394 - Changes wording on sync management page when no repositories are
  enabled to cross-link to custom repos and red hat provider link.
  (ehelms@redhat.com)
- 857061 - System template actions on the right pane will now close whenever
  the new system template button is clicked. (ehelms@redhat.com)
- fix 1.9 incompatibility (pchalupa@redhat.com)
- fix rpm build process (pchalupa@redhat.com)
- fix packaging and katello-configure (pchalupa@redhat.com)
- setup bundler before Application definition (pchalupa@redhat.com)
- remove ENV from config.ru (pchalupa@redhat.com)
- add better definitions of configuration validation (pchalupa@redhat.com)
- remove deprecated ApiConfig (pchalupa@redhat.com)
- make sure katello_config is loadable stand-alone (pchalupa@redhat.com)
- sort available locales (pchalupa@redhat.com)
- clean up configuration (pchalupa@redhat.com)

* Wed Jan 23 2013 Justin Sherrill <jsherril@redhat.com> 1.3.10.pulpv2-1
- requiring pulp rpm package in the correct place (jsherril@redhat.com)
- Skipping Zentest 4.8.4 due to bad gemspec (msuchy@redhat.com)
- Streaming files instead of loading them entirely into mem
  (daviddavis@redhat.com)
- Fixed whitespace (daviddavis@redhat.com)
- Added a lint check for ruby code (daviddavis@redhat.com)

* Tue Jan 22 2013 Justin Sherrill <jsherril@redhat.com> 1.3.9_pulpv2-1
- spec file changes for build (jsherril@redhat.com)
- removing lib/resources/pulp.rb from spec (jsherril@redhat.com)
- Fixing trailing whitespace (daviddavis@redhat.com)

* Tue Jan 22 2013 Justin Sherrill <jsherril@redhat.com> 1.3.8_pulpv2-1
- adding rubygem-hooks to spec requires (jsherril@redhat.com)
- fixing bundler_ext changes (jsherril@redhat.com)

* Mon Jan 21 2013 Justin Sherrill <jsherril@redhat.com> 1.3.7_pulpv2-1
- revert of requiring compass < 0.12 (jsherril@redhat.com)
- fixing use of reserved javascript word (jsherril@redhat.com)

* Mon Jan 21 2013 Justin Sherrill <jsherril@redhat.com> 1.3.6_pulpv2-1
- fixing rpm build for pulpv2 (jsherril@redhat.com)

* Mon Jan 21 2013 Justin Sherrill <jsherril@redhat.com> 1.3.5_pulpv2-1
- removing old converge-ui build code (jsherril@redhat.com)
- 868045: Missed translating string when there are no products for a system
  (bkearney@redhat.com)

* Tue Jan 15 2013 Justin Sherrill <jsherril@redhat.com> 1.3.3-1
- Translations - Update .po and .pot files for katello. (jsherril@redhat.com)
- Translations - New translations from Transifex for katello.
  (jsherril@redhat.com)
- Translations - Download translations from Transifex for katello.
  (jsherril@redhat.com)
- Setting the min_messages level to warning (daviddavis@redhat.com)
- Repository feed validation moved to validator (mhulan@redhat.com)
- Code cleanup (mhulan@redhat.com)
- Move all validators to one place (mhulan@redhat.com)
- 820392 - repository hostname validation (mhulan@redhat.com)
- emails - add default From to login/password emails (bbuckingham@redhat.com)
- 882311 - hide and check organizations being deleted (lzap+git@redhat.com)
- 882311 - remove scope-based organization hiding when deleting it
  (lzap+git@redhat.com)
- fix missing assets when running in development (pchalupa@redhat.com)
- 868090 - [ru_RU] L10n:Content Management - Repositories: Untranslated string
  in Products and Repositories tab (komidore64@gmail.com)
- 880515 - [ALL_LANG][headpin CLI] Redundant brackets in the message of
  'Couldn't find organization '??' ()' for system report module with invalid
  --org name. (komidore64@gmail.com)
- 808461 - prevent from creating a repo in rh providers (lzap+git@redhat.com)

* Tue Jan 08 2013 Lukas Zapletal <lzap+git@redhat.com> 1.3.2-1
- Merge pull request #1307 from thomasmckay/869371-ram
- Merge pull request #1294 from thomasmckay/878891-actkey-alignment
- Merge pull request #1366 from pitr-ch/story/configuration
- Merge pull request #1364 from lzap/locale-update
- Fix post install scriptlet
- add missing documentation
- fix error message, missing space
- rails-i18n - upstream checker script
- rails-i18n - pulling yml files from upstream
- rails-i18n - adding update script
- Merge pull request #1356 from daviddavis/lock_rails
- 891926 - katello refuses to restart
- Locking rails version to fix bundle install
- Merge pull request #1347 from daviddavis/0
- Merge pull request #1343 from daviddavis/rm_gemfiles
- 879094 - fixing %%post error in spec
- Moving tomcat group add to katello-shared to %%post
- 879094 - a few updates to katello & katello-selinux spec based on comments
- renaming katello_shared -> katello-shared
- 879094 - CVE-2012-5561 - fix permissions on /etc/katello/secure
- Allowing for local gem groups
- Removing Gemfile.lock files since they are out of date
- Merge pull request #1327 from daviddavis/unique_keys
- Merge pull request #1315 from xsuchy/pull-req-ignore
- Merge pull request #1280 from pitr-ch/bug/799356-stack-trace-in-production
- Merge pull request #1271 from lzap/orch-logging
- logging - orchestration log - review
- Merge pull request #1328 from xsuchy/pull-req-typo
- fixing reset issue
- Merge pull request #1259 from lzap/org-delete-885261
- Merge pull request #1324 from daviddavis/README
- Adding tests to check menu item keys for uniqueness
- fix typo occured -> occurred
- Merge pull request #1326 from weissjeffm/menu-keys2
- Merge pull request #1288 from bbuckingham/fork-843421
- 843421 - add parens to existing code
- Merge pull request #1303 from ehelms/843566
- Merge pull request #1298 from ehelms/bug-871093
- Merge pull request #1313 from ehelms/817858
- Make the :key fields of all the Setup menu items unique across all the
  navigation.
- Merge pull request #1323 from xsuchy/pull-req-sam-translations
- Merge pull request #1284 from ares/bug/fix_for_system_templates_ui
- Merge pull request #1316 from
  ares/bugs/790216-concurrent_changeset_promotions
- merge pt_BR from SAM
- add accidentally deleted pt_BR
- Removing README and updating spec file
- fixing ru/app.po
- forward port translation from SAM
- Merge pull request #1274 from
  ares/bug/781287-allow_notifications_for_pw_change
- Merge pull request #1273 from ares/bug/835902_notifications_for_iframe_upload
- Merge pull request #1320 from weissjeffm/remove-readme
- Merge pull request #1305 from ehelms/858726
- Add back katello specific readme.
- Remove README that was generated by Ruby on Rails.
- Merge pull request #1295 from daviddavis/pg_update
- Merge pull request #1299 from bbuckingham/fork-844708
- Merge pull request #1304 from bbuckingham/fork-848553
- Merge pull request #1311 from bbuckingham/fork-831362
- Merge pull request #1296 from ehelms/bug-845062
- Merge pull request #1290 from ehelms/bug-772199
- Merge pull request #1302 from witlessbird/832148
- ignore obsoletes and fuzzy warnings
- Bug 799356 - systems that have been deleted that are still calling back to
  server generate stack trace
- Merge pull request #1292 from lzap/squash-admins-873665
- Merge pull request #1289 from daviddavis/favicon_bind_fix
- logging - orchestration log - unit test fix
- Merge pull request #1279 from ares/bug/806096-display_repos_to_readonly_user
- Merge pull request #1306 from jlsherrill/bugday
- Merge pull request #1301 from ehelms/855945
- removing console.log
- Merge pull request #1309 from ehelms/791345
- 751159 - downloading a modified system template would present warning
- 831362 - systems - disable/enable system group widget on actions panel
- 869371-ram - able to set RAM during new system creation in UI
- 848566 - fixing verbage of system group limit
- 848553 - tupane - remove 'do_not_open' on copy
- user searches containing empty display attributes are no longer being saved
  in the history
- 858743 - Stop redirect after login to ajax notices path
- 842745 - Fixed rspec test
- Merge pull request #1285 from ehelms/bug-857061
- 844708 - update panel action confirmation dialog to close on 'yes' click
- 842745 - Showing update message on package group update
- 878891-actkey-alignment - put act keys into table
- 873665 - getting rid of last find_by_username admin calls
- 875225 - Binding favicon refresh to hash change
- 888019 - fixing issue where only 10 repos would appear on content search
- 843421 - systems - include summary when removing system groups using bulk
  action
- Merge pull request #1281 from jsomara/882248
- Merge pull request #1282 from ehelms/bug-839934
- Fix for not loading system template detail
- Fixing a non-deterministic text failure
- 848571 - fixing verbage on content search
- Merge pull request #1277 from daviddavis/favicon_fix
- 882248 - making environment name editable
- 806096 fix - display checkboxes to readonly users
- 875225 - Refreshing favicon to ensure its presence
- 784326 fix for mixed locale for admin
- 781287 fix - update notification counter
- Fixes few typos
- 835902 fixes notification for GPG key upload
- logging - orchestration log rotating
- logging - orchestration logger and uuid request tracking
- Fixes 790216 running changesets concurently
- 885261 - org deletion unit test correction
- 885261 - make data repair script to work from any dir
- 885261 - org deletion should remove rh provider
- better error messages
- 858726 - Sets the compare repos button to disable if there are 0 or 1 repos
  enabled on content search.
- 817858 - Permission edits now show tags when appropriate.
- 791345 - Deletes errant tick mark that was appearing after list updates on
  the sync plan page.
- 843566 - Sets the chosen dropdown in Content Search to not display a filter
  mechanism.
- 855945 - Content search now displays the Library if there are no
  environments.
- 871093 - Fix to show tags when "+ All" verbs is selected.
- 845062 - Fixes typo with errata search icon tooltip.
- 772199 - Adds a tool tip to explain that GPG keys are optional for products
  and repositories.
- 839394 - Changes wording on sync management page when no repositories are
  enabled to cross-link to custom repos and red hat provider link.
- 857061 - System template actions on the right pane will now close whenever
  the new system template button is clicked.
- fix 1.9 incompatibility
- fix rpm build process
- fix packaging and katello-configure
- setup bundler before Application definition
- remove ENV from config.ru
- add better definitions of configuration validation
- remove deprecated ApiConfig
- make sure katello_config is loadable stand-alone
- sort available locales
- clean up configuration

* Tue Dec 18 2012 Miroslav Suchý <msuchy@redhat.com> 1.3.1-1
- remove requires rubygem(execjs) and rubygem(multi_json) (msuchy@redhat.com)
- Removing OR for pipeor (jomara@redhat.com)
- Consumer.get was returning a 410 and surfacing that instead of continuing to
  delete the deletion record (jomara@redhat.com)
- 878191 - allowing non-consumer access to deletion record remove
  (jomara@redhat.com)
- Setting haml-rails to 0.3.4 to fix error (daviddavis@redhat.com)
- Use maruku instead of redcarpet for markdown -> html (inecas@redhat.com)
- 881616 - showing UNLIMITED instead of -1 on activation keys edit
  (jomara@redhat.com)
- apipie - fix in loading nested controllers (tstrachota@redhat.com)
- smart proxies - api controller (tstrachota@redhat.com)
- katello-jobs-locale - corrected missing method call
  extract_locale_from_accept_language_header (thomasmckay@redhat.com)
- 877894-i18n - remove N_ to allow match w/ translation
  (thomasmckay@redhat.com)
- Upstream alchemy hash for i18n. (jrist@redhat.com)
- Fixes a few i18n issues:  - i18n forced to browser locale on login page  -
  fixes a few items via alchemy for login page i18n. (jrist@redhat.com)
- Ruby19 - Fixes issue with array symbols appearing in UI when running on Ruby
  1.9+. (ehelms@redhat.com)
- Minor simplification of the content_for(:content) block (jrist@redhat.com)
- Reverting a critical missing space and indenting for readability.
  (jrist@redhat.com)
- Enhancement for former fix for 864565 (ares@igloonet.cz)
- Fixes 855433 bug - display GPG keys repositories (ares@igloonet.cz)
- Ordering of user_session caused interstitial to not load due to string
  change. (jrist@redhat.com)
- Add elasticsearch package to ping information (daviddavis@redhat.com)
- 880113 - special validation for pool ids searching with ? (jomara@redhat.com)
- ja-validation - updated ja.yml file from https://github.com/svenfuchs/rails-
  i18n (thomasmckay@redhat.com)
- katello-jobs-locale - set user's locale (thomasmckay@redhat.com)
- 860301: Updated specs for reset notice fixes (daviddavis@redhat.com)
- 860301: Showing notices for username and password resets
  (daviddavis@redhat.com)
- Use spaces instead of tabs (ares@igloonet.cz)
- Spec refactoring (ares@igloonet.cz)
- delayed_jobs - fix for passing bundler ext environment variables
  (tstrachota@redhat.com)
- Fixes 878156 bug with GPG key updating (ares@igloonet.cz)
- cli - packaged completion script (tstrachota@redhat.com)
- cli - python based shell completion (tstrachota@redhat.com)
- bundler.d - not need to require ci plugin (lzap+git@redhat.com)
- bundler.d - correcting permissions for development mode (lzap+git@redhat.com)
- ping - correcting return code for ping controller (lzap+git@redhat.com)
- 880710 - api systems controller - query org by name or label
  (bbuckingham@redhat.com)
- architectures ui - architectures tied to operating systems - new model for
  operating systems - helper for operating system multiselect
  (tstrachota@redhat.com)
- abstract model - dsl for setting resource name (tstrachota@redhat.com)
- abstract model - processing apipie exceptions (tstrachota@redhat.com)
- architectures ui - basic crud actions (tstrachota@redhat.com)
- Bumping package versions for 1.3. (ehelms@redhat.com)
- 880710 - api - updates to use org id or label when retrieving org
  (bbuckingham@redhat.com)

* Thu Dec 06 2012 Eric D Helms <ehelms@redhat.com> 1.2.2-1
- Spec - Adds line to dynamically determine installation directory of Alchemy.
  (ehelms@redhat.com)
- Spec - Updates to new alchemy inclusion location in spec. (ehelms@redhat.com)
- bundler.d - adding new packages to the comp files (lzap+git@redhat.com)
- bundler.d - moving ci group into build and dev only file
  (lzap+git@redhat.com)
- Alchemy - Submodule hash update. (ehelms@redhat.com)
- String - Fixes malformed i18n string. (ehelms@redhat.com)
- Alchemy - Spec file updates for Alchemy. (ehelms@redhat.com)
- Alchemy - Updates for pathing related to the codebase change in Alchemy.
  (ehelms@redhat.com)
- Minor fixes for content_search and about page. (jrist@redhat.com)
- bundler.d - not distributing build gem group (lzap+git@redhat.com)
- Fix build_pxe_default call (inecas@redhat.com)
- Updating to lower case url.  Removing comment from previous test.
  (jrist@redhat.com)
- Fixing the password reset edit method and associated test. (jrist@redhat.com)
- 883949-portugese - change config mapping or portugese locale
  (thomasmckay@redhat.com)
- 883949-chinese - change config mapping for chinese locale
  (thomasmckay@redhat.com)
- bundler.d - changes for build time (apipie) (lzap+git@redhat.com)
- bundler.d - pull request review fixes (lzap+git@redhat.com)
- bundler.d - applying changes for the spec (lzap+git@redhat.com)
- bundler.d - copying only some gems from test into dev (lzap+git@redhat.com)
- bundler.d - adding support for jruby (lzap+git@redhat.com)
- bundler.d - adding test group in development env (lzap+git@redhat.com)
- bundler.d - introcuding dynamic loading of gems (lzap+git@redhat.com)
- bunndler.d - cleaning Gemfile (lzap+git@redhat.com)
- Password and Username Reset fixed. (jrist@redhat.com)
- Fix for missing images on fancyqueries dropdown. (jrist@redhat.com)
- Update git submodule to UI-Alchemy (alchemy), small fix for dashboard.
  (jrist@redhat.com)
- Locking ci_reporter version due to errors in jekins (daviddavis@redhat.com)
- Added missing word 'find' in filters searching message. (ogmaciel@gnome.org)
- 876896, 876911, 878355, 878750, 874502, 874510 - Fixed panel-name/new-link
  overlap (komidore64@gmail.com)
- only restart foreman if it is installed (mmccune@redhat.com)
- Lock therubyracer to beta version to fix jenkins (daviddavis@redhat.com)
- fixing foreman fencing that facilitated a failure (komidore64@gmail.com)
- i18n-fixes - updating missing localizations, including time format
  (thomasmckay@redhat.com)
- Bash Completion - Updates bash completion with current command and sub-
  command sets. (ehelms@redhat.com)
- including foreman as a service to start/stop with Katello
  (mmccune@redhat.com)
- 877947-clear-es - added index clean up after import and after delete manifest
  (thomasmckay@redhat.com)
- Added a check for anything besides html and json response for user#new
  (jrist@redhat.com)
- 868872 - do not distribute katello-reset-dbs (msuchy@redhat.com)
- Change menu keys so that no menu items end up having same html 'id'
  attribute. (jweiss@redhat.com)
- 876869 - Adjusting overflow and ellipsis for Roles page. (jrist@redhat.com)
- Fixes Bug 882294 - HTML element being rendered unescaped in promotions help
  tip. (ogmaciel@gnome.org)
- Fixes the width of the application to 1152px. Fixes the login.
  (jrist@redhat.com)
- Move foreman UI to glue foreman (mbacovsk@redhat.com)
- Provide the headers for when pinging Foreman (inecas@redhat.com)
- Having TravisCI test our Gemfile.locks (daviddavis@redhat.com)
- 878693 - [RFE] Selecting multiple systems does not give me any action
  (komidore64@gmail.com)
- 880116 - pool was referencing a non-existant instance variable
  (jomara@redhat.com)
- allow beta of therubyracer (msuchy@redhat.com)
- remove fix for Apipie v0.0.12 and switch to v0.0.13 (pchalupa@redhat.com)
- bundler_ext development - correcting path for dev mode (lzap+git@redhat.com)
- Revert "Foreman environment orchestration" (mbacovsk@redhat.com)
- Added Foreman stuff to katello-debug (mbacovsk@redhat.com)
- fixing build issue caused by 56de39ba17b446a2e511c4cbf57728a548581cf4
  (komidore64@gmail.com)
- check-gettext - correct count of malformed strings (inecas@redhat.com)
- 878341 - [ja_JP][SAM Web GUI] Default environment name 'Library' should not
  be localized. (komidore64@gmail.com)
- 880905 - certain locales were not escaped properly (jomara@redhat.com)
- Setting gem versions based on katello-devel-all.rpm (daviddavis@redhat.com)
- updating comment for pdf-reader requirement (jsherril@redhat.com)
- Foreman environment orchestration (mbacovsk@redhat.com)
- Updated F17 Gemfile.lock (daviddavis@redhat.com)
- requiring specific older version of pdf-reader (jsherril@redhat.com)
- Fixed small typo s/Subscriptons/Subscriptions. (ogmaciel@gnome.org)
- 866972 - katello-debug needs to take headpin into consideration
  (komidore64@gmail.com)
- Ensure that the name and label is unique across all all orgs
  (bkearney@redhat.com)
- update gems jshintrb and therubyracer (msuchy@redhat.com)
- fix unit tests when foreman is disabled (pchalupa@redhat.com)
- bundler_ext - development mode support
- new foreman_api version in gemfile (tstrachota@redhat.com)
- subnets - change data hash sent to foreman (tstrachota@redhat.com)
- abstract model - fix for indexed models not being deleted
  (tstrachota@redhat.com)
- abstract model - separate module for indexed model (tstrachota@redhat.com)
- subnet ui - workaround for bug in chosen (tstrachota@redhat.com)
- foreman ui - helpers for resource select boxes (tstrachota@redhat.com)
- foreman ui - refactoring (tstrachota@redhat.com)
- subnets - elastic search indexing (tstrachota@redhat.com)
- domain ui - controller and es indexing (tstrachota@redhat.com)
- abstract model - support for callbacks (tstrachota@redhat.com)
- forman menu - new setup menu (tstrachota@redhat.com)
- subnets ui - select boxes for domains and smart proxies
  (tstrachota@redhat.com)
- smart proxies - new model (tstrachota@redhat.com)
- subnets ui - basic CRUD actions (tstrachota@redhat.com)
- subnets - model and api controller (tstrachota@redhat.com)
- bundler_ext - require also :foreman until all require is merged
  (lzap+git@redhat.com)
- require bundler_ext - especially in buildtime (msuchy@redhat.com)
- Gemfile - Adds comment marking dependency. (ehelms@redhat.com)
- add rubygem-jshintrb (msuchy@redhat.com)
- add rubygem-libv8 to katello-devel-jshintrb (msuchy@redhat.com)
- add parallel_tests to devel dependecies (msuchy@redhat.com)
- Gemfile - Adds explicit require in development,test for sexp_processor due to
  not being pulled in as a dependency of ruby_parser in development.
  (ehelms@redhat.com)
- 875185 - fixing enabled redhat repos page (jsherril@redhat.com)
- add foreman ping support (lzap+git@redhat.com)
- Additional color overrides, fixes for many small things throughout.
  (jrist@redhat.com)
- introducing bundler_ext rubygem (lzap+git@redhat.com)
- fixing env check to look for true (jsherril@redhat.com)
- enabling debugger gem group by default (jsherril@redhat.com)
- 873038 - Entering an env name of "Library" when creating an organization does
  not give clear error message (komidore64@gmail.com)
- 875609-hypervisor - allow hypervisors to successfully register and list in
  katello (thomasmckay@redhat.com)
- 874280 - terminology changes for consistency across subman, candlepin, etc
  (jomara@redhat.com)
- Translations - Update .po and .pot files for katello. (ehelms@redhat.com)
- Translations - New translations from Transifex for katello.
  (ehelms@redhat.com)
- Translations - Download translations from Transifex for katello.
  (ehelms@redhat.com)
- 877473-fencing - force use_foreman and use_pulp off for headpin
  (thomasmckay@redhat.com)
- changed deployment checking (komidore64@gmail.com)
- force devboost to be on in development mode. (mmccune@redhat.com)
- fix monkey patch when RSpec::Version is undefined (pchalupa@redhat.com)
- fix warning text (pchalupa@redhat.com)
- ui - helper method for rendering editables (tstrachota@redhat.com)
- 874391-mandel - async job behind deleting manifest (thomasmckay@redhat.com)
- 866972 - katello-debug needs to take headpin into consideration
  (komidore64@gmail.com)
- make bundler happy (msuchy@redhat.com)
- katello-upgrade redesign (lzap+git@redhat.com)
- Rspec - Fixes broken Rspec test. (ehelms@redhat.com)
- Rspec - Fixes issue with referencing Rspec version caused by newest version
  to fix unit test runs. (ehelms@redhat.com)
- Gemfile - Fixes reference to Ruport git. (ehelms@redhat.com)
- switched to a more succinct way to open a binary file (dmitri@redhat.com)
- Setting therubyracer version (daviddavis@redhat.com)
- fixed a few issues dicovered when running under 1.9.3 (dmitri@redhat.com)
- Revert "Revert "Fixed katello.spec for Ruport"" (msuchy@redhat.com)
- Revert "Revert "Fixed Gemfile for Ruport"" (msuchy@redhat.com)
- Revert "Revert "Fixing Ruport depend. on Prawn"" (msuchy@redhat.com)
- Revert "Revert "Fixing Gemfile depend."" (msuchy@redhat.com)
- Revert "Revert "Fixing Ruport dependencies"" (msuchy@redhat.com)
- Revert "Revert "Prawn gemfile and spec dependencies"" (msuchy@redhat.com)
- Revert "Revert "Prawn integration for PDF generation"" (msuchy@redhat.com)
- fixing a regression i caused on one of my own bugs. (komidore64@gmail.com)
- 874185 - make sure we don't try and process labels when env is nil
  (mmccune@redhat.com)
- 874510, 874502 (komidore64@gmail.com)
- 845620 - [RFE] Improve messaging around results of setting the yStream
  (komidore64@gmail.com)
- 873680 - disallowing blank socket count in system creation
  (jomara@redhat.com)
- 853445 - correctly determine the affected repos after deletion
  (inecas@redhat.com)
- 874185 - fix the add_repository_library_id migration (inecas@redhat.com)
- Remove accidentally added file (inecas@redhat.com)
- Wiped out an unused file (paji@redhat.com)
- subsfilter - fixes BZ 859038 where the subscription filtering chooser would
  grab focus when the panel opens (thomasmckay@redhat.com)
- 873809-js-error - removing oboslete red hat provider code and references
  (two-pane subscriptions replaced) (thomasmckay@redhat.com)
- katello-configure - support reset data for the foreman (inecas@redhat.com)
- Get back Gemfile.lock symlink (inecas@redhat.com)
- 864936 - products - labelize name on create entry (bbuckingham@redhat.com)
- 873302 - Environments do not populate when adding a new user without full
  admin (komidore64@gmail.com)
- Fixed the permissions to access the RH Subscriptions page (paji@redhat.com)
- fix version comparison (pchalupa@redhat.com)
- More color changes to derive from $primary and $kprimary (jrist@redhat.com)
- 864936 - small but important chg to fix manifest imports
  (bbuckingham@redhat.com)
- 864936 - api/cli - generate an error label provided is already in use
  (bbuckingham@redhat.com)
- 872686 - create a Role with single-character name fails
  (komidore64@gmail.com)
- 864936 - update product labels to ensure uniqueness (bbuckingham@redhat.com)
- 872096 - correcting typo in a comment (lzap+git@redhat.com)
- fix missing constant error when fast_gettext gem have older version
  (pchalupa@redhat.com)
- 871086 - Changes to respond with template validation errors as bad requests
  instead of internal server errors. (ehelms@redhat.com)
- 872305 - scope product certificate search by organization (inecas@redhat.com)
- 866359 - API: /consumers/{id}/entitlements returns incorrect data and
  Content-Type header (komidore64@gmail.com)
- forgot to change branding helper to use release_short method
  (jomara@redhat.com)
- Moving some configuration options into branding helper (jomara@redhat.com)
- Adding more infoz to about page & footer (jomara@redhat.com)
- 750660 - System packages list doesn't allow you to search for a package
  installed on the system (j.hadvig@gmail.com)
- puppet race condition in foreman (lzap+git@redhat.com)
- 871822 - str != str (jomara@redhat.com)
- remove deprecation warning (pchalupa@redhat.com)
- sync spec with Gemfile (msuchy@redhat.com)
- 872096 - review of katello rpm-delivered conf files (lzap+git@redhat.com)
- 871822 - nil check for mem_mb (jomara@redhat.com)
- 871822 - Moving factname for memtotal; now in kB by default
  (jomara@redhat.com)
- allowing organizations (and also anything else that uses
  katello_name_format_validator) to have a name that is one character in
  length. (komidore64@gmail.com)
- Added OS-specific Gemfile.lock files (daviddavis@redhat.com)
- fixing a regression in headpin due to ascii username restrictions in katello.
  (komidore64@gmail.com)
- Added fonts symlink. (jrist@redhat.com)
- 869380-confirm-delete - add confirmation message before deleting manifest
  (thomasmckay@redhat.com)
- More fixes for integrating converge-ui (jrist@redhat.com)
- abstract model - spec tests (tstrachota@redhat.com)
- abstract model - update_attributes (tstrachota@redhat.com)
- abstract model - validation error reporting (tstrachota@redhat.com)
- abstract model - support for naming and to_key Both needed by form_for.
  (tstrachota@redhat.com)
- 813291 - [RFE] Username cannot contain characters other than alpha
  numerals,'_', '-', can not resume after failure (komidore64@gmail.com)
- wrapping headpin only gems to the if statement (lzap+git@redhat.com)
- Ruby 1.9.3 - Adds relative path to lib files to fix unittest failures on
  1.9.3 (ehelms@redhat.com)
- 870456 - existing orgs do not get default value for system_info_keys in
  database (komidore64@gmail.com)
- moving .bundle/config out of RPM to configure (lzap+git@redhat.com)
- Rspec - Fixes broken test that was a result of mis-configured mocks.
  (ehelms@redhat.com)
- Travis - Updates travis config to change directory properly for bundle
  install. (ehelms@redhat.com)
- 870362 - Adding conversion method for memory str -> mb (jomara@redhat.com)
- fixing jammit dep version for sam (lzap+git@redhat.com)
- 861513 - Fixes issue with failed sync's not generating proper notifications.
  (ehelms@redhat.com)
- headpin-dashboard - adjust size of notices portlet when in headpin mode to
  match system status (thomasmckay@redhat.com)
- 868916 - wait for elasticsearch and start httpd during upgrade
  (lzap+git@redhat.com)
- headpin-foreman - return reverted foreman fencing (thomasmckay@redhat.com)
- Revert "Prawn integration for PDF generation" (jomara@redhat.com)
- Revert "Prawn gemfile and spec dependencies" (jomara@redhat.com)
- Revert "Fixing Ruport dependencies" (jomara@redhat.com)
- Revert "Fixing Gemfile depend." (jomara@redhat.com)
- Revert "Fixing Ruport depend. on Prawn" (jomara@redhat.com)
- Revert "Fixed Gemfile for Ruport" (jomara@redhat.com)
- Revert "Fixed katello.spec for Ruport" (jomara@redhat.com)
- 866995 - additional fix for ping controller (lzap+git@redhat.com)
- 869938 - avoiding cronjob root mail folder flooding (lzap+git@redhat.com)
- removing foreman dependency from katello-common (lzap+git@redhat.com)
- adding more strict versions in the Gemfile (lzap+git@redhat.com)
- Revert "headpin-system-groups - adding system groups to headpin"
  (jomara@redhat.com)
- Revert "headpin-system-groups - fence pulp hooks in system model"
  (jomara@redhat.com)
- 817946 - API not accessible from browser (komidore64@gmail.com)
- headpin-system-groups - fence pulp hooks in system model
  (thomasmckay@redhat.com)
- 835321 - Fixing the user name validation (j.hadvig@gmail.com)
- 835586 - restricting usernames to ASCII only. (mmccune@redhat.com)
- introducing debugging group in the Gemfile (lzap+git@redhat.com)
- remove fuzzy warnings (pchalupa@redhat.com)
- update supported rspec versions in monkeypatch (pchalupa@redhat.com)
- add missing tests for foreman integration (pchalupa@redhat.com)
- 869006: Fixing variable name change for RAM support from previous pull
  request (jomara@redhat.com)
- localizing "NOT-SPECIFIED" string in models/custom_info.rb
  (komidore64@gmail.com)
- 865472 - system groups - fix auto-complete on add of systems to groups
  (bbuckingham@redhat.com)
- 818903 - Name of the pdf generated for headpin system report command should
  be modified (komidore64@gmail.com)
- RAM entitlements (jomara@redhat.com)
- 862997 - On content search page, during repository comparison, clicking the
  show more button will now properly load more data for packages and errata.
  (ehelms@redhat.com)
- Gemfile for 1.8 and 1.9 Ruby (lzap+git@redhat.com)
- Properly setting label in before validate method (daviddavis@redhat.com)
- trying to fix tests for automation (komidore64@gmail.com)
- headpin-system-groups - adding system groups to headpin
  (thomasmckay@redhat.com)
- correctly address owner attribute (msuchy@redhat.com)
- these aren't needed during testing and are unrelated to the spec test
  (mmccune@redhat.com)
- changing to correct 'find' method (komidore64@gmail.com)
- fixing busted tests due to elastic search indexing (komidore64@gmail.com)
- adding custom info to elastic search on systems (komidore64@gmail.com)
- default custom info for systems by org (komidore64@gmail.com)
- custom info rework (work it!) (komidore64@gmail.com)
- switching to parallel_tests for our jenkins job and removing yard run
  (mmccune@redhat.com)
- Setting label on the backend if blank (daviddavis@redhat.com)
- fix failing system tests (pchalupa@redhat.com)
- 866995: Fix the status API so that it is exposed correctly for rhsm.
  (bkearney@redhat.com)
- Add foreman_api as a build requirement (inecas@redhat.com)
- Add Foreman integration code to rpm spec (inecas@redhat.com)
- removed a rescue used for debugging (dmitri@redhat.com)
- a bunch of fixes to get katello running on ruby 1.9.3 (dmitri@redhat.com)
- do not send plain password to Foreman in user foreman glue
  (pchalupa@redhat.com)
- utilize Foreman search ability in rake db:seed (pchalupa@redhat.com)
- raise errors on Foreman Katello DB inconsistency (pchalupa@redhat.com)
- manifests - cleaned error message, removed unused var
  (thomasmckay@redhat.com)
- manifests - Added delete manifest while in headpin mode (not enabled in
  katello) manifests - fixed 857949
  https://bugzilla.redhat.com/show_bug.cgi?id=857949 (thomasmckay@redhat.com)
- 855267 - CLI - changesets - update controller to use before_filter for
  product (bbuckingham@redhat.com)
- fix missing parameter (pchalupa@redhat.com)
- move missing foreman user creation out of migration to upgrade script
  (pchalupa@redhat.com)
- update katello.spec to correspond with Gemfile dependencies
  (pchalupa@redhat.com)
- reuse User foreman orchestration disablement in tests (pchalupa@redhat.com)
- add missing copyright notices (pchalupa@redhat.com)
- fix broken unit tests from 71a2926 (pchalupa@redhat.com)
- update apipie and foreman_api dependencies in Gemfile (pchalupa@redhat.com)
- raise error when parsing of response fails (pchalupa@redhat.com)
- add Resources::Foreman.options method to be able to access option hash
  (pchalupa@redhat.com)
- change AbstractModel to correspond with unified apipie resource method
  signatures (pchalupa@redhat.com)
- add migration for creating missing users in foreman (pchalupa@redhat.com)
- fix failing test (pchalupa@redhat.com)
- improve foreman api controllers (pchalupa@redhat.com)
- add method for parsing attributes from response (pchalupa@redhat.com)
- fix rake db:seed with foreman orchestration on (pchalupa@redhat.com)
- fix errors introduced by adding AbstractModel (pchalupa@redhat.com)
- add Resources::AbstractModel (pchalupa@redhat.com)
- add foreman user orchestration tests (pchalupa@redhat.com)
- Rescue foreman model exceptions (pajkycz@gmail.com)
- Architectures API fix (pajkycz@gmail.com)
- Fix destroy foreman user (pajkycz@gmail.com)
- katello - add spec for Resources::ForemanModel (pchalupa@redhat.com)
- katello - fix foreman architetures, make sure actions won't fail silently
  (pchalupa@redhat.com)
- Foreman Config Templates improvements (pajkycz@gmail.com)
- apidoc - added docs for config_templates (mbacovsk@redhat.com)
- apidoc -  added docs for domains (mbacovsk@redhat.com)
- Config templates CLI - print template kind (pajkycz@gmail.com)
- Foreman domains added to CLI client (pajkycz@gmail.com)
- apidoc - added api doc for architectures (mbacovsk@redhat.com)
- Foreman's Config Templates added to CLI client. (pajkycz@gmail.com)
- Foreman config templates added, foreman model small changes
  (pajkycz@gmail.com)
- katello - remove password_confirmation from foreman user model
  (pchalupa@redhat.com)
- Fixed packaging of foreman stuff (mbacovsk@redhat.com)
- architectures - add conditional exposure of foreman api proxy
  (mbacovsk@redhat.com)
- make user orchestration to use Foreman::User (pchalupa@redhat.com)
- foreman model polishing (pchalupa@redhat.com)
- Foreman models: Architecture, Domain (pajkycz@gmail.com)
- katello - foreman user mapping (pchalupa@redhat.com)
- remove old foreman code (pchalupa@redhat.com)
- architectures - code cleanup (mbacovsk@redhat.com)
- Fixed katello config file template (mbacovsk@redhat.com)
- Fixed problem with storing resource class in class var (mbacovsk@redhat.com)
- US22811 - added architecture controller proxy (mbacovsk@redhat.com)

* Wed Oct 17 2012 Ivan Necas <inecas@redhat.com> 1.2.1-1
- skip symlinks during gettext check (msuchy@redhat.com)
- Moved trigger from body to document element. (gstoecke@redhat.com)
- Moved binding of notice display event to document ready callback due to
  different code path execution during login notifications.
  (gstoecke@redhat.com)
- Fixed the moving of the a.cancel_sync element (j.hadvig@gmail.com)
- adding parallel_tests gem so our unit tests can use multiple CPUs
  (mmccune@redhat.com)
- 860952 - update Pool::find to not treat response as an array
  (bbuckingham@redhat.com)
- do not call pulp service script, call qpidd and mongodb directly
  (msuchy@redhat.com)
  (lzap+git@redhat.com)
- package katello-common should own /etc/katello (msuchy@redhat.com)
- package katello-common should own /usr/share/katello (msuchy@redhat.com)
- package katello-common should own /usr/share/katello/lib (msuchy@redhat.com)
- package katello should own /usr/share/katello/lib/resources
  (msuchy@redhat.com)
- package katello should own /usr/share/katello/lib/monkeys (msuchy@redhat.com)
- package katello should own /usr/share/katello/app/models/glue
  (msuchy@redhat.com)
- package katello (and headpin) should own /usr/share/katello/app/models and
  /usr/share/katello/app (msuchy@redhat.com)
- katello-common should own directory /usr/share/katello/db (msuchy@redhat.com)
- fixing - uninitialized constant Candlepin (lzap+git@redhat.com)
- 862753 - fixing typo in template deletion (lzap+git@redhat.com)
- gettext - fix syntax (inecas@redhat.com)
- 860952 - do not call with_indifferent_access on Array (msuchy@redhat.com)
  (witlessbird@gmail.com)
- Added about link to Administer menu (daviddavis@redhat.com)
- gettext - move the check to the start of RPM build phase (inecas@redhat.com)
- fix for broken content update call and additional tests (dmitri@redhat.com)
- A slew of changes around content updates. (dmitri@redhat.com)
  (komidore64@gmail.com)
- fixed failing db migrations (komidore64@gmail.com)
- 859963 - Fixed bad css character (daviddavis@redhat.com)
- gettext - add a checking script to find if there are note malformed gettext
  stings (inecas@redhat.com)
- Fix missing should in gpg controller spec (daviddavis@redhat.com)
- Fixed gpg keys controller rspec (daviddavis@redhat.com)
  (thomasmckay@redhat.com)
- Fixed katello.spec for Ruport (j.hadvig@gmail.com)
- gettext - get rid of all malformed interpolations in gettext strings
  (inecas@redhat.com)
- gettext - use named substitution in gettext with more variables
  (inecas@redhat.com)
- Fixed Gemfile for Ruport (j.hadvig@gmail.com)
- 864654 - katello-headpin-all correction (jomara@redhat.com)
- Fix handling of validation_errors in notices.js (daviddavis@redhat.com)
- 847002, 864216 - Fixes content search row rendering issue in IE8, product
  color row in IE8 and the path selector not being set to the proper location
  in IE8. (ehelms@redhat.com)
- 859329 - Fixed errors when editing gpg key (daviddavis@redhat.com)
- Incorporated code review suggestions. (gstoecke@redhat.com)
- Fencing SYNCHRONIZATION link on admin dropdown in headpin mode
  (jomara@redhat.com)
- 864565 - Removing duplicate repos from gpgkey show (daviddavis@redhat.com)
- 864362-autocomplete - rescue bad searches in auto-complete fields
  (thomasmckay@redhat.com)
- Fixing Ruport depend. on Prawn (jhadvig@redhat.com)
- Fixing Gemfile depend. (jhadvig@redhat.com)
- Fixing Ruport dependencies (jhadvig@redhat.com)
- Prawn gemfile and spec dependencies (jhadvig@redhat.com)
- Prawn integration for PDF generation (j.hadvig@gmail.com)
- fixing 'pt_BR' translations (msuchy@redhat.com)
- merge katello.katello translation from CFSE (msuchy@redhat.com)
- Merge branch 'master' of github.com:Katello/katello into 847002
  (jrist@redhat.com)
- 847002 - Fixes rendering issue in IE9 for nested content search results.
  (ehelms@redhat.com)
- Update to notice storage mechanism for automation testing framework.
  (gstoecke@redhat.com)
- Merge branch 'master' into notices (gstoecke@redhat.com)
- 847002 - Fix for IE9 Changeset Environment Selector (jrist@redhat.com)
- updating to allow use of local var from PR comment (mmccune@redhat.com)
- switching our schema config names to match production and relaxing reset
  (mmccune@redhat.com)
- 825858 - use organizations.label instead of cp_key (inecas@redhat.com)
- 859442 - systems - update query for adding system groups to system
  (bbuckingham@redhat.com)
  (bbuckingham@redhat.com)
- 825858 - implementing proxy permissions (lzap+git@redhat.com)
- 825858 - proxies permissions - removing comments (lzap+git@redhat.com)
- fix for BZ 824581: gpg keys are now being updated (dmitri@redhat.com)
- 862824 - load search results using where() manually (jsherril@redhat.com)
- 859877 - ipaddr does not show up for old subman version (jomara@redhat.com)
- Merge branch 'master' into notices (gstoecke@redhat.com)
- Added tracking of notices for use in test automation framework.
  (gstoecke@redhat.com)
- requiring new minitest gems (jsherril@redhat.com)
- 835586 - force the encoding in the header to be UTF8 so Pulp can decode
  (mmccune@redhat.com)
  (thomasmckay@redhat.com)
- self. calling a private method (jomara@redhat.com)
- self.installed_products != self.installedProducts (jomara@redhat.com)
  (daviddavis@redhat.com)
- Defensively checking installed product names; (jomara@redhat.com)
- Show foreman packages on about page (daviddavis@redhat.com)
- reverting accidental override (msuchy@redhat.com)
  (thomasmckay@redhat.com)
  (thomasmckay@redhat.com)
- Removing ANY SYSTEM FACT: from system search list (jomara@redhat.com)
- Resetting locale to English before each test (daviddavis@redhat.com)
- Fixed rspec translation missing failures (daviddavis@redhat.com)
- Making systems searchable on installed products (jomara@redhat.com)
- ignore fuzzy and obsolete translations (msuchy@redhat.com)
- Fixed broken label rspec tests (davidd@scimedsolutions.com)
- Make string more translator friendly (msuchy@redhat.com)
- add missing apostroph (msuchy@redhat.com)
- unify string "Removed repository" (msuchy@redhat.com)
- unify string "Couldn't find user role" (msuchy@redhat.com)
- unify string "Couldn't find user" (msuchy@redhat.com)
- unify string "Couldn't find template" (msuchy@redhat.com)
- unify string "Couldn't find system group" (msuchy@redhat.com)
- unify string "Couldn't find system" (msuchy@redhat.com)
- unify string "Couldn't find repository" (msuchy@redhat.com)
- unify string "Couldn't find product with id" (msuchy@redhat.com)
- unify string "Couldn't find organization" (msuchy@redhat.com)
- unify string "Couldn't find environment" (msuchy@redhat.com)
- unify string "Couldn't find changeset" (msuchy@redhat.com)
- unify string "Couldn't find activation key" (msuchy@redhat.com)
- unify string "Added repository" (msuchy@redhat.com)
- unify string "Added distribution" (msuchy@redhat.com)
  (bbuckingham@redhat.com)
- 803702 - switch back to searching in the API by name and not label
  (mmccune@redhat.com)
- 824581 - Fixing bug resulting from bad fix (davidd@scimedsolutions.com)
- 808581 - Stack traces logged to production.log for user-level validation
  errors (pchalupa@redhat.com)
  ch/bug/857230-mouse_over_errata_item_displays_error (kontakt@pitr.ch)
- 860251 - update the location of favicon.png (inecas@redhat.com)
- fix for BZ852352: changeset type is now being pre-selected depending on user
  selection of 'Deletion from' or 'Promotion to' (dmitri@redhat.com)
- 767297 - Removed OS information (davidd@scimedsolutions.com)
- rails-dev-boost - removing whitespace (mmccune@redhat.com)
- rails-dev-boost - moving to own group and adding RPM requires
  (mmccune@redhat.com)
- BZ 835875: removed a commented-out line of code (dmitri@redhat.com)
- 859415 - object labels - modify ui to assign a default label, if not
  specified (bbuckingham@redhat.com)
- 858360 - Making katello-upgrade START services after upgrade is complete
  (jomara@redhat.com)
- rails-dev-boost - adding rails-dev-boost gem (mmccune@redhat.com)
- 859409 - Fix for focus on org switcher drop down. (jrist@redhat.com)
- 859604 - Fixed search results total bug (davidd@scimedsolutions.com)
- 859784 - Missing template error (davidd@scimedsolutions.com)
- 857576 - Added api filter update test (davidd@scimedsolutions.com)
- fix for BZ 857031: notifications are being shown now when a system gets added
  to/removed from a group (dmitri@redhat.com)
- 857576 - Package filter name can be edited by cli
  (davidd@scimedsolutions.com)
- fixed an inadvertent spec test change (thomasmckay@redhat.com)
- fix for BZ 860702: show systems belonging to system groups and those not in
  any on 'Systems' screen (dmitri@redhat.com)
  (thomasmckay@redhat.com)
- introducing katello-utils with katello-disconnected script
  (lzap+git@redhat.com)
- 767297 - Worked on about page and added spec (davidd@scimedsolutions.com)
- 860421 - Not verifying ldap roles for auth-less API calls (jomara@redhat.com)
- 767297 - Create an about page (davidd@scimedsolutions.com)
- release-version - display message when no available release version choices
  or an error occurred fetching them (thomasmckay@redhat.com)
- 824581 - Fixed bug where gpgkey wasn't getting set
  (davidd@scimedsolutions.com)
- Fixed code formating issue in migration (davidd@scimedsolutions.com)
- 832141 - Searching a system via 'By Environments' sub-tab doesn't save the
  recent search in history (pajkycz@gmail.com)
- 857230 - Mouse over errata item displays error in UI Content Search
  (pchalupa@redhat.com)
- it is now impossible to delete a provider if one (or more) of its
  repositories or products has been promoted (dmitri@redhat.com)
- 845041 - UI - Exact Errata search in content search does not return result
  (pajkycz@gmail.com)
- Hide 'new changeset' button when it should not be used (pajkycz@gmail.com)
- 856227 - set the height of the tabel row in the products_table to 32px
  (j.hadvig@gmail.com)
- 848438 - Content search auto-complete should enable the 'Add' button after
  typing full content name. (pajkycz@gmail.com)
- List of sync plans added (pajkycz@gmail.com)
- Always use environment when requesting repo (pajkycz@gmail.com)
- 806383 - [RFE] As the SE administrator I want to see all active and scheduled
  sync tasks for all organizations in one place (pajkycz@gmail.com)

* Mon Oct 15 2012 Lukas Zapletal <lzap+git@redhat.com> 1.1.15-1
- Added about link to Administer menu

* Fri Oct 12 2012 Lukas Zapletal <lzap+git@redhat.com> 1.1.14-1
- Merge pull request #845 from xsuchy/pull-req-rpm
- package katello-common should own /etc/katello
- package katello-common should own /usr/share/katello
- package katello-common should own /usr/share/katello/lib
- package katello should own /usr/share/katello/lib/resources
- package katello should own /usr/share/katello/lib/monkeys
- package katello should own /usr/share/katello/app/models/glue
- package katello (and headpin) should own /usr/share/katello/app/models and
  /usr/share/katello/app
- katello-common should own directory /usr/share/katello/db
- Merge pull request #842 from lzap/new-cli-test
- fixing - uninitialized constant Candlepin
- 862753 - fixing typo in template deletion
- 860952 - do not call with_indifferent_access on Array
- Merge pull request #836 from witlessbird/content-updates
- Merge pull request #825 from jhadvig/prawn_integration
- fix for broken content update call and additional tests
- A slew of changes around content updates.
- Merge pull request #830 from daviddavis/859963
- Merge pull request #832 from komidore64/busted_migration
  (komidore64@gmail.com)
- fixed failing db migrations (komidore64@gmail.com)
- 859963 - Fixed bad css character
- Fix missing should in gpg controller spec
- Fixed gpg keys controller rspec
- Merge pull request #819 from thomasmckay/864362-autocomplete
- Merge pull request #823 from daviddavis/859329
- Fixed katello.spec for Ruport
- Fixed Gemfile for Ruport
- Merge pull request #826 from jsomara/864654
- 864654 - katello-headpin-all correction
- Fix handling of validation_errors in notices.js
- Merge pull request #821 from knowncitizen/847002
- Merge pull request #814 from ehelms/bug-847002
- 847002, 864216 - Fixes content search row rendering issue in IE8, product
  color row in IE8 and the path selector not being set to the proper location
  in IE8.
- 859329 - Fixed errors when editing gpg key
- Merge pull request #801 from gstoeckel/notices
- Incorporated code review suggestions.
- Merge pull request #822 from jsomara/navfence
- Fencing SYNCHRONIZATION link on admin dropdown in headpin mode
- 864565 - Removing duplicate repos from gpgkey show
- 864362-autocomplete - rescue bad searches in auto-complete fields
- Fixing Ruport depend. on Prawn
- Fixing Gemfile depend.
- Fixing Ruport dependencies
- Prawn gemfile and spec dependencies
- Prawn integration for PDF generation
- fixing 'pt_BR' translations
- merge katello.katello translation from CFSE
- Merge branch 'master' of github.com:Katello/katello into 847002
- 847002 - Fixes rendering issue in IE9 for nested content search results.
- Update to notice storage mechanism for automation testing framework.
- Merge branch 'master' into notices
- 847002 - Fix for IE9 Changeset Environment Selector
- updating to allow use of local var from PR comment
- switching our schema config names to match production and relaxing reset
- 825858 - use organizations.label instead of cp_key
- 859442 - systems - update query for adding system groups to system
- Merge pull request #799 from mccun934/835586-encoding-fix
- Merge pull request #805 from witlessbird/824581
- Merge pull request #646 from Pajk/hide_new_changeset_button
- Merge pull request #802 from jsomara/859877
- Merge pull request #804 from jlsherrill/862824
- Merge pull request #734 from daviddavis/code-format
- 825858 - implementing proxy permissions
- 825858 - proxies permissions - removing comments
- fix for BZ 824581: gpg keys are now being updated
- 862824 - load search results using where() manually
- 859877 - ipaddr does not show up for old subman version
- Merge branch 'master' into notices
- Added tracking of notices for use in test automation framework.
- requiring new minitest gems
- 835586 - force the encoding in the header to be UTF8 so Pulp can decode
- Merge pull request #560 from Pajk/806383
- Merge pull request #794 from jsomara/esinstalledproductfix
- self. calling a private method
- self.installed_products != self.installedProducts
- Merge pull request #793 from jsomara/esinstalledproductfix
- Defensively checking installed product names;
- Show foreman packages on about page
- reverting accidental override
- Merge pull request #767 from witlessbird/852352
- Merge pull request #772 from xsuchy/pull-req-transdup2
- Merge pull request #777 from jsomara/installedproducts
- Merge pull request #785 from jsomara/anysystemfact
- Merge pull request #748 from pitr-ch/bug/808581-Stack_traces_in_log
- Removing ANY SYSTEM FACT: from system search list
- Resetting locale to English before each test
- Fixed rspec translation missing failures
- Making systems searchable on installed products
- Merge pull request #774 from xsuchy/pull-req-fuzzy
- ignore fuzzy and obsolete translations
- Fixed broken label rspec tests
- Make string more translator friendly
- add missing apostroph
- unify string "Removed repository"
- unify string "Couldn't find user role"
- unify string "Couldn't find user"
- unify string "Couldn't find template"
- unify string "Couldn't find system group"
- unify string "Couldn't find system"
- unify string "Couldn't find repository"
- unify string "Couldn't find product with id"
- unify string "Couldn't find organization"
- unify string "Couldn't find environment"
- unify string "Couldn't find changeset"
- unify string "Couldn't find activation key"
- unify string "Added repository"
- unify string "Added distribution"
- Merge pull request #622 from Pajk/848438
- Merge pull request #770 from mccun934/803702-org-label-3
- 803702 - switch back to searching in the API by name and not label
- 824581 - Fixing bug resulting from bad fix
- 808581 - Stack traces logged to production.log for user-level validation
  errors
- Merge pull request #702 from witlessbird/835875
- Merge pull request #729 from daviddavis/bz824581
- Merge pull request #720 from pitr-
  ch/bug/857230-mouse_over_errata_item_displays_error
- 860251 - update the location of favicon.png
- Merge pull request #759 from bbuckingham/fork-859415
- fix for BZ852352: changeset type is now being pre-selected depending on user
  selection of 'Deletion from' or 'Promotion to'
- Merge pull request #738 from daviddavis/about
- Merge pull request #756 from knowncitizen/859409
- 767297 - Removed OS information
- Merge pull request #757 from mccun934/add-dev-boost
- rails-dev-boost - removing whitespace
- rails-dev-boost - moving to own group and adding RPM requires
- BZ 835875: removed a commented-out line of code
- 859415 - object labels - modify ui to assign a default label, if not
  specified
- rails-dev-boost - adding rails-dev-boost gem
- 859409 - Fix for focus on org switcher drop down.
- 767297 - Worked on about page and added spec
- 767297 - Create an about page
- 824581 - Fixed bug where gpgkey wasn't getting set
- Fixed code formating issue in migration
- 857230 - Mouse over errata item displays error in UI Content Search
- it is now impossible to delete a provider if one (or more) of its
  repositories or products has been promoted
- Hide 'new changeset' button when it should not be used
- 848438 - Content search auto-complete should enable the 'Add' button after
  typing full content name.
- List of sync plans added
- Always use environment when requesting repo
- 806383 - [RFE] As the SE administrator I want to see all active and scheduled
  sync tasks for all organizations in one place

* Thu Sep 27 2012 Miroslav Suchý <msuchy@redhat.com> 1.1.13-1
- 858360 - Making katello-upgrade START services after upgrade is complete
  (jomara@redhat.com)
- 859604 - Fixed search results total bug (davidd@scimedsolutions.com)
- 859784 - Missing template error (davidd@scimedsolutions.com)
- 857576 - Added api filter update test (davidd@scimedsolutions.com)
- fix for BZ 857031: notifications are being shown now when a system gets added
  to/removed from a group (dmitri@redhat.com)
- 857576 - Package filter name can be edited by cli
  (davidd@scimedsolutions.com)
- fixed an inadvertent spec test change (thomasmckay@redhat.com)
- fix for BZ 860702: show systems belonging to system groups and those not in
  any on 'Systems' screen (dmitri@redhat.com)
- introducing katello-utils with katello-disconnected script
  (lzap+git@redhat.com)
- 860421 - Not verifying ldap roles for auth-less API calls (jomara@redhat.com)
- release-version - display message when no available release version choices
  or an error occurred fetching them (thomasmckay@redhat.com)
- Revert "workaround for bz 854263" (msuchy@redhat.com)
- requires ruby(abi) and ruby (the command) (msuchy@redhat.com)
- 858802 - Allowing associated keys to be deleted (davidd@scimedsolutions.com)
- altering custom info index and shortening the name (komidore64@gmail.com)
- remove forgotten conflict indicators (msuchy@redhat.com)
- 858011, 854697 - object-labels - needed to use org label on del_owners (vs
  cp_key) (bbuckingham@redhat.com)
- fixing ko .po file (msuchy@redhat.com)
- fix plurals form in pt_BR (msuchy@redhat.com)
- fixing es .po file (msuchy@redhat.com)
- fixing es .po file (msuchy@redhat.com)
- fix pt_BR .po file (msuchy@redhat.com)
- Take advantage of the new katello-service script to stop/start all required
  services. (ogmaciel@gnome.org)
- Removed goferd from backup script as it is never installed in the server,
  only in the clients that subscribe to it. (ogmaciel@gnome.org)
- 857842 - get all the packages, fixes earlier syntax error
  (mmccune@redhat.com)
- BZ 821345: product name now appears instead of a '#' (dmitri@redhat.com)
- 857895 - adding "registered date" to system lists to help distinguish between
  same-named systems (thomasmckay@redhat.com)
- build-fix - don't use model classes on require time (inecas@redhat.com)
- 858678 - removing extra systems index (lzap+git@redhat.com)
- refresh translations string for katello (msuchy@redhat.com)
- making a method in the custom_info_controller private (komidore64@gmail.com)
- BZ 858682: fixed status messages on syncs that didn't fail (yet) but didn't
  complete successfully either (dmitri@redhat.com)
- 829437 - fix error notification in GPG file upload form (inecas@redhat.com)
- 842838 - fixing x icon not showing up on content search (jsherril@redhat.com)
- 857539 - Clicking the "contract" arrow in the org selector on the main UI
  does not contract the picker (pajkycz@gmail.com)
- Javascript error if selecting Org in Changeset history detail page
  (pajkycz@gmail.com)
- 857720 - Javascript error if selecting Org in Providers page
  (pajkycz@gmail.com)
- 857499 - Fix for user with no orgs or perms. (jrist@redhat.com)
- Update the env, prod migrations to use labelize (paji@redhat.com)
- Fixed the labelize call to deal with i18n characters (paji@redhat.com)
- fixing spec tests for custom_info (komidore64@gmail.com)
- 843529 - minor update per pull request comment - use if/else vs unless
  (bbuckingham@redhat.com)
- CustomInfo for Systems (komidore64@gmail.com)
- object labels - moving the default_label action to the application controller
  (bbuckingham@redhat.com)
- object labels - update ui for setting label values based upon server query
  (bbuckingham@redhat.com)
- object labels - by default, assign label by 'labelizing' the object name
  (bbuckingham@redhat.com)
- 854801-autoheal - word change (thomasmckay@redhat.com)
- Prevent resubmission on the interstitial screen (davidd@scimedsolutions.com)
- converge-ui - updating hash (bbuckingham@redhat.com)
- Rakefile could not be in -devel package as katello-configure call db:migrate
  and seed_with_logging rake tasks (msuchy@redhat.com)
- fixed an issue when it was impossible to remove a repository that had no
  promoted content (dmitri@redhat.com)
- 759122 - system software tab More... button displaying when no more
  (pajkycz@gmail.com)
- object-labels - adding CLI and API calls to support object labeling
  (mmccune@redhat.com)
- 858193-automation - fencing javascript error point (thomasmckay@redhat.com)
- 854278 - fixing search validation calls to appropriately search for user
  names (jomara@redhat.com)
- Fixed organization rspec test (davidd@scimedsolutions.com)
- 843529 - fix spec test on system group events (bbuckingham@redhat.com)
- 843529 - system group tasks - better way for handling nil job
  (bbuckingham@redhat.com)
- return back Gemfile (msuchy@redhat.com)
- katello-service - now hard-depends on katello-wait (lzap+git@redhat.com)
- 843529 - system group tasks - handling when systems are removed
  (bbuckingham@redhat.com)
- Fixed some broken unit tests (paji@redhat.com)
- Revert "regenerating localization strings for rails app"
  (komidore64@gmail.com)
- Fixed provider_spec.rb tests (davidd@scimedsolutions.com)
- regenerating localization strings for rails app (komidore64@gmail.com)
- add two strings to localization (komidore64@gmail.com)
- 857727 - issue where uploading key left UI in bad state (jsherril@redhat.com)
- katello-service - reformatting mixed tabs and spaces (lzap+git@redhat.com)
- katello-service - make use of service-wait (lzap+git@redhat.com)
- 820634 - Katello String Updates (komidore64@gmail.com)
- apidoc - added API documentation filters, sync (bz#852388)
  (mbacovsk@redhat.com)
- Fixed package listing generation in katello-debug (bz#857842)
  (mbacovsk@redhat.com)
- do not require rubygem-pdf-writer (msuchy@redhat.com)
- create new subpackages -devel-all and -devel-* (msuchy@redhat.com)
- update katello localization strings (msuchy@redhat.com)
- object labels - spec changes for the additions of label to repository..etc
  (bbuckingham@redhat.com)
- object labels - update env controller to support retrieving env by label
  (bbuckingham@redhat.com)
- object labels - update to use product and repo label (bbuckingham@redhat.com)
- object labels - update activation key edit helptip to reflect use of label
  (bbuckingham@redhat.com)
- object labels - add read-only label to edit panes for org, env, prod, repo
  (bbuckingham@redhat.com)
- object labels - update to use environment label for candlepin environments
  (bbuckingham@redhat.com)
- 852912 - fixing subscribe/unsubscribe for non-english locale 857550 - fixing
  environment loading on clean installs (jomara@redhat.com)
- 852119 - Fixed default environment bug (davidd@scimedsolutions.com)
- headpin needs RAILS_RELATIVE_URL_ROOT variable (msuchy@redhat.com)
- Fixing user spec tests that were breaking (davidd@scimedsolutions.com)
- katello-jobs - fix status exit code (inecas@redhat.com)
- apidoc - added docs for system groups (#852388) (mbacovsk@redhat.com)
- Fix rpm update from version without converge-ui (inecas@redhat.com)
- main code expect that RETVAL is set after kstatus() finish
  (msuchy@redhat.com)
- apidoc - systems_controller fix ruby 1.9 compatibility (inecas@redhat.com)
- 855406 - pass correctly environment variables which ruby needs
  (msuchy@redhat.com)
- apidoc - Sync Plans, Tasks, System Packages (pajkycz@gmail.com)
- apidoc - fix rake apipie:static when postgresql not running
  (inecas@redhat.com)
- Fixed all the product related tests (paji@redhat.com)
- Partial commit on product create (paji@redhat.com)
- Misc unit test fixes (paji@redhat.com)
- Fixed unit tests related to system groups (paji@redhat.com)
- object-label - organization - rename column cp_key to label
  (bbucking@dhcp231-20.rdu.redhat.com)
- Added code to create product and repos with labels (paji@redhat.com)
- apidoc - systems controller (inecas@redhat.com)
- Fixed all KTEnvironment.create unit tests to take the label (paji@redhat.com)
- Fixed all organizatio.create related unit tests (paji@redhat.com)
- Improved the message in the katello label validator (paji@redhat.com)
- Made the label columns non null (paji@redhat.com)
- Added indexes to the migration script to enforce uniqueness constraints
  (paji@redhat.com)
- Added code to get the initial org + env create working in the UI
  (paji@redhat.com)
- Initial commit to setup the models and migrations for object-labels
  (paji@redhat.com)
- PulpIntegrationTests - Updates for tests that were having incosistent run
  times between live and recorded data versions. (ehelms@redhat.com)
- PulpIntegrationTests - Adds removal of pulp integration tests test runner
  script from spec. (ehelms@redhat.com)
- PulpIntegrationTests - Adds require for rails gem. (ehelms@redhat.com)
- PulpIntegrationTests - Removes unused rake task and reference to rake task
  from spec. (ehelms@redhat.com)
- PulpIntegrationTests - Updates to fix errors between running live tests and
  running tests against recorded data. (ehelms@redhat.com)
- PulpIntegrationTests - Adds tests for uncovered actions and updates for a
  successful test suite beginning to end. (ehelms@redhat.com)
- PulpIntegrationTests - A ton of re-factoring and added test cases.
  (ehelms@redhat.com)
- PulpIntegrationTests - Adds Consumer tests and a local repository for usage
  in testing. (ehelms@redhat.com)
- PulpIntegrationTests - Adds a number of tests for filters, packages, package
  groups, tasks, and errata. (ehelms@redhat.com)
- PulpIntegrationTests - Updates to repository tests. (ehelms@redhat.com)
- PulpIntegrationTests - Slew of repository related tests. (ehelms@redhat.com)
- PulpIntegrationTests - Adds integration tests for pulp users.
  (ehelms@redhat.com)
- PulpIntegrationTests - Initial integration test setup using VCR and minitest
  to test basic Pulp Ping. (ehelms@redhat.com)

* Wed Sep 12 2012 Ivan Necas <inecas@redhat.com> 1.1.12-1
- subsfilter - Correctly update UI when subscription checkboxes toggled
  (thomasmckay@redhat.com)
- Org switcher "tipsy" fix and IE8 final fixes. (jrist@redhat.com)
- 853229 - blank sync plan date gives incorrect error (jsherril@redhat.com)
- Let errata types options be selectable (mbacovsk@redhat.com)
- APIDOC - templates, templates_content (pajkycz@gmail.com)
- APIDOC - providers, subscriptions (pajkycz@gmail.com)
- 856303 - fencing system permission checks (jomara@redhat.com)
- 854697 - manifest import - if first import fails, rollback (unimport it)
  (bbuckingham@redhat.com)
- 809259 - activation key - cli permissions changes (continued)
  (bbuckingham@redhat.com)
- 809259 - activation key - cli permissions changes (bbuckingham@redhat.com)
- Fixed #842271 - filtering the "bugfix" errata in CLI doesn't work
  (mbacovsk@redhat.com)
- Initial commit on updated indexing appropriate stuff (paji@redhat.com)
- 843064 - Content Search - Products: Not required unless searching for
  Products itself, it's misleading when searching for Repos, Packages and
  Errata (pajkycz@gmail.com)

* Wed Sep 12 2012 Miroslav Suchý <msuchy@redhat.com> 1.1.11-1
- 856220 - adding time to puppet log (lzap+git@redhat.com)
- Fix for removing user's default org. (jrist@redhat.com)
- Fix for initial suggestion from @parthaa with new suggestion.
  (jrist@redhat.com)
- removed referebce to package autocomplete widget from content search page
  (dmitri@redhat.com)
- fix for BZ 843059: removed autocomplete on packages (dmitri@redhat.com)
- BZ 835875: a couple of small fixes based on pull comments (dmitri@redhat.com)
- Updating some permissions stuff and the save based on comments in the Pull
  Request. (jrist@redhat.com)
- preserve enviroment variable, especiall RAILS_ENV (msuchy@redhat.com)
- 856220 - improving service-wait wrapper script (lzap+git@redhat.com)
- Test fix for changeset creation without env (pajkycz@gmail.com)
- fixes for BZ 835875: no longer possible to delete a repository if it's been
  promoted. (dmitri@redhat.com)
- 853056 - fix regression for registering with activation keys
  (inecas@redhat.com)
- fix dependecies on Fedora17+ (msuchy@redhat.com)
- 852320 - undefined method `library?' for nil:NilClass (NoMethodError) when
  creating a changeset without an environment (pajkycz@gmail.com)
- 839575 - [CLI] Adding a system to system group using incorrect uuid should
  raise an error instead of success (pajkycz@gmail.com)
- Fixing the org serialization, tipsifying, some suggested tweaks.
  (jrist@redhat.com)
- 754738 - do not override variables in other procedures (msuchy@redhat.com)
- 754738 - do not override status() from /etc/rc.d/init.d/functions
  (msuchy@redhat.com)
- 754738 - fix name of monitor pid file (msuchy@redhat.com)
- 754738 - if program is already running, print failure, but return 0
  (msuchy@redhat.com)
- 754738 - if we fail in stopping delayed_jobs, kill it. One by one.
  (msuchy@redhat.com)
- 75473 - correctly solve status for all processes of delayed_jobs
  (msuchy@redhat.com)
- 754738 - log even output of service stop (msuchy@redhat.com)
- use runuser instead of su (msuchy@redhat.com)
- 75473 - do not delete nor truncate log (msuchy@redhat.com)
- 754738 - properly return when katello is not configured (msuchy@redhat.com)
- 854278 - After adding certain objects to katello one will see a warning, ''
  did not meet the current search criteria and is not being shown
  (komidore64@gmail.com)
- 786226 - List of product repositories not sorted alphabetically
  (pajkycz@gmail.com)
- 852460 - System Groups left pane list does not use ellipsis
  (pajkycz@gmail.com)
- 855184 - Using --add_package gives undefined method `empty?' for nil:NilClass
  error (pajkycz@gmail.com)
- Final org switcher and interstitial changes for default organization.
  (jrist@redhat.com)
- Changes to accomodate the System Registration Defaults (jrist@redhat.com)
- 840735 - headpin create environment returned error :There was an error
  retrieving that row:Not Found (komidore64@gmail.com)
- 841121 -  Long description returns PG error (pajkycz@gmail.com)
- 811136 - Rendering error in production.log while editing the org's
  description (pajkycz@gmail.com)
- 841121 - Long description while creating system group returns PG error
  (pajkycz@gmail.com)
- Truncate Notice text to max 1024 characters. (pajkycz@gmail.com)
- 841300 - Zoom out on 2-Pane page causes rendering error (pajkycz@gmail.com)
- 843529 - cleanup task_statuses and job_tasks on system deletion
  (bbuckingham@redhat.com)
- Updates ConvergeUI to the latest. (ehelms@redhat.com)
- gather up all packages for katello-debug (mmccune@redhat.com)
- Stupid default setting for user set_org (jrist@redhat.com)
- Minor accidental fix for extra char. (jrist@redhat.com)
- Initial workings of new default org stuff. (jrist@redhat.com)
- 834013 - return releaseVer as part of consumer json (thomasmckay@redhat.com)
- 846719 - Removes footer links entirely. (ehelms@redhat.com)

* Thu Sep 06 2012 Ivan Necas <inecas@redhat.com> 1.1.10-1
- 852631 - system group - update model to raise exception when no groups exist
  (bbuckingham@redhat.com)
- 854573, 852167 - Fixes missing icons issue which also resolves an alignment
  issue on the content search page. (ehelms@redhat.com)
- linkback - make app prefix link helper (thomasmckay@redhat.com)
- workaround for bz 854263 (msuchy@redhat.com)
- 758651 - check if thin port is free before starting thin (msuchy@redhat.com)
- Merge pull request #543 from bbuckingham/fork-841289 (lzap@redhat.com)
- 853056 - system register without environment is working again
  (lzap+git@redhat.com)
- 853056 - improve 404 generic error message (lzap+git@redhat.com)
- job without task should not exists, this is error (msuchy@redhat.com)
- 851142 - CLI: changeset update shows strange error (pajkycz@gmail.com)
- fix for BZ 821345 (dmitri@redhat.com)
- link back to source of manifest in import history (thomasmckay@redhat.com)
- Updating Converge-UI (mbacovsk@redhat.com)
- 746765 - systems can be referenced by uuid (lzap+git@redhat.com)
- 746765 - removing system unique name constraint (lzap+git@redhat.com)
- 831664 - Repository sync failures not displaying detailed error in Notices
  (pchalupa@redhat.com)
- 841289 - perform cleanup on failed registration with activation key
  (bbuckingham@redhat.com)
- katello - disable bundler patch by default, fix broken condition
  (pchalupa@redhat.com)
- katello - add bundler patch to prefer rpm-gems (pchalupa@redhat.com)

* Fri Aug 31 2012 Miroslav Suchý <msuchy@redhat.com> 1.1.9-1
- Do not insert spaces before changesets description (pajkycz@gmail.com)
- 847858-actkeypool - fixed spec test failure (thomasmckay@redhat.com)
- Updating converge-ui (jomara@redhat.com)
- 847858 - only remove act keys when resource not found error
  (thomasmckay@redhat.com)
- 847115 - Extend scroll bug on content tab, with > 50 subscriptions only the
  first 50 will populate. (pajkycz@gmail.com)
- Added some unit to test the perm fixes (paji@redhat.com)
- 843462 - system group search indexing should not include pulp content
  (bbuckingham@redhat.com)
- Added permissions for content delete (paji@redhat.com)
- 841857 - fixing LDAP logins in katello mode (jomara@redhat.com)
- 842569 - system groups - fix for TypeError on status of errata install
  (bbuckingham@redhat.com)
- 811556 - Displaced 'save' button while editing the changeset description
  under "changeset history" tab (pajkycz@gmail.com)

* Wed Aug 29 2012 Ivan Necas <inecas@redhat.com> 1.1.8-1
- subsfilter - reset the cycle of table row colors to avoid having first row of
  bottom table having same shading as the table header (ie. always start with
  light color row) (thomasmckay@redhat.com)
- subsfilter - removed second spinner when updating filtered subscriptions
  (thomasmckay@redhat.com)
- Available subscriptions on systems page now allow filtering matching what is
  available in subscription-manager-gui (thomasmckay@redhat.com)
- Content Search - Adds new data fields "data_type" and "value" to make testing
  easier. (ehelms@redhat.com)
- cdn-var-substitutor - isolate the logic to separate class (inecas@redhat.com)
- 845613 - fix display of subscription status and rows (thomasmckay@redhat.com)
- 845668 - removing console.log usage from js, which cause FF3.6 failures
  (bbuckingham@redhat.com)
- Moved service-wait link target to katello-common (mbacovsk@redhat.com)
- 846321: Support creating permissions for all tags from the API and the cli
  (bkearney@redhat.com)
- 845995: Add local and server side checks for passing in bad group names and
  ids (bkearney@redhat.com)
- content-deletion - update content tree after product deletion
  (bbuckingham@redhat.com)
- 846251: Do not specify the attribute name for uniqueness validation
  (bkearney@redhat.com)
- content-deletion - update so that clicking on undefined changeset category
  doesnothing (bbuckingham@redhat.com)
- 844806 - katello incorrectly prevents products with the same name in an
  organization (adprice@redhat.com)
- 844806 - katello incorrectly prevents products with the same name in an
  organization (adprice@redhat.com)
- 849224 - thin now listens only on localhost (lzap+git@redhat.com)
- katello - remove lists of rescue Exception usage (pchalupa@redhat.com)
- katello - remove 'rescue Exception' (pchalupa@redhat.com)

* Thu Aug 23 2012 Mike McCune <mmccune@redhat.com> 1.1.7-1
- 846251: Do not specify the attribute name for uniqueness validation
  (bkearney@redhat.com)
- 850745 - secret_token is not generated properly (CVE-2012-3503)
  (lzap+git@redhat.com)
- katello-all - installs foreman as well (inecas@redhat.com)
- 805127 - require candlepin-selinux (msuchy@redhat.com)
- fix build errors (msuchy@redhat.com)
- fix build errors on F17 (msuchy@redhat.com)

* Tue Aug 21 2012 Miroslav Suchý <msuchy@redhat.com> 1.1.6-1
- remove Gemfile.lock after all packages are installed (msuchy@redhat.com)
- content deletion - unit test fix (mmccune@redhat.com)
- content-deletion - update product deletion to allow for re-promotion
  (bbuckingham@redhat.com)
- content-deletion - cleanup a few ui text strings (bbuckingham@redhat.com)
- Changeset#remove_package! fix (pajkycz@gmail.com)
- changesets content api test fix (pajkycz@gmail.com)
- apidoc - removed duplicite api doc entry (mbacovsk@redhat.com)
- converge-ui - accidentally downgraded during previous merge... :(
  (bbuckingham@redhat.com)
- Real. Fix. (Thx mmccne) for the user_sessions_controller (jrist@redhat.com)
- Fix for user_sessions_controller.rb spec test failure. (jrist@redhat.com)
- content deletion - putting commented code back in (mmccune@redhat.com)
- content deletion - adding support for product deletion (mmccune@redhat.com)
- content deletion - adding support for product deletion (mmccune@redhat.com)
- Removed misleading/unused code in the deletion_changesets (paji@redhat.com)
- api docs - fix loading environment in build phase (inecas@redhat.com)
- api docs - show trace when API docs build fails (inecas@redhat.com)
- Fix 1.9 compatibility issue in the ContentSearchController
  (inecas@redhat.com)
- api docs - fix wrong syntax for param description (inecas@redhat.com)
- api docs - fix building for f17 - ruby 1.8 vs. 1.9 difference
  (inecas@redhat.com)
- Commented out unused parent template logic (paji@redhat.com)
- content-deletion - fix issue w/ deletion tree not loading on last env
  (bbuckingham@redhat.com)
- changesets - fix notice type on successful promotion/deletion
  (bbuckingham@redhat.com)
- Added system template deletion feature (paji@redhat.com)
- apidoc - docs for role_ldap_groups_controller (mbacovsk@redhat.com)
- api docs - don't require redcarpet if cache is turned on (inecas@redhat.com)
- content-deletion - convert action titles to tipsy for consistency
  (bbuckingham@redhat.com)
- content-deletion - update helptip to include both deletion and promotion
  (bbuckingham@redhat.com)
- content-deletion - add a tipsy to the 'Added' item in content tree
  (bbuckingham@redhat.com)
- content-deletion - add custom confirms for changeset deletion
  (bbuckingham@redhat.com)
- content-deletion - add title attribute to the changeset action bar
  (bbuckingham@redhat.com)
- content-deletion - update the content tree to use 'Added (Undo)' vs 'Remove'
  (bbuckingham@redhat.com)
- content-deletion - update the content tree to use 'Added (Undo)' vs 'Remove'
  (bbuckingham@redhat.com)
- changing message to "Insufficient Subscriptions are Attached to This System"
  (adprice@redhat.com)
- 845611 - Subscriptions are not current message is confusing for system with
  insufficient subscriptions (adprice@redhat.com)
- content-deletion - remove the changeset type from the sliding tree listing
  (bbuckingham@redhat.com)
- content-deletion - load changeset sliding tree based on changeset hash
  (bbuckingham@redhat.com)
- Quick fix to a bug introduced in the package deletion and promotion
  (paji@redhat.com)
- 843904 - Systems page: user will see System Group and Errata elements along
  with install button and other. (adprice@redhat.com)
- content-deletion - fix some references to accessing current chgset breadcrumb
  (bbuckingham@redhat.com)
- changesets - fix the locked icon image on changeset list
  (bbuckingham@redhat.com)
- content-deletion - initial chgs to support 2 changeset trees
  (deletion/promotion) (bbuckingham@redhat.com)
- Validation of locale during update handled by model. (ogmaciel@gnome.org)
- Allow user to update his/her own localevia cli. Also, output the default
  locale when using the info parameter. (ogmaciel@gnome.org)
- Added --default_locale to CLI for user creation. (ogmaciel@gnome.org)
- Fixed more spec tests (paji@redhat.com)
- Fixed broken spec tests that occurred after master merge (paji@redhat.com)
- Removed unused methods in the pulp and reporb (paji@redhat.com)
- Moved the add+remove repo packages method to orchestration layer
  (paji@redhat.com)
- content-deletion - add a promotion/deletion banner to the changeset tree
  (bbuckingham@redhat.com)
- Speeded up package deletion and promotion by using a differnt call in pulp
- Revert "update converge ui" (mmccune@redhat.com)
- update converge ui (mmccune@redhat.com)
- content deletion - taking out unecessary fields from the JSON
  (mmccune@redhat.com)
- Updating the converge-ui version (paji@redhat.com)
- content-deletion - update repo deletion to disable or remove based on env
  (bbuckingham@redhat.com)
- content-deletion - updates to handle last env in path
  (bbuckingham@redhat.com)
- Fixes for some of API issues (pajkycz@gmail.com)
- content deletion - proper deletion support in the CLI (mmccune@redhat.com)
- content-deletion - minor changes to changeset history
  (bbuckingham@redhat.com)
- content-deletion - add changeset type to changeset listing (changesets pg)
  (bbuckingham@redhat.com)
- content-deletion - update specs to account for the promote vs apply name
  change (bbuckingham@redhat.com)
- content-deletion - change cs promote status text to apply (to be generic)
  (bbuckingham@redhat.com)
- content-deletion - update cs create to default to promotion
  (bbuckingham@redhat.com)
- content-deletion - add backend support for deleting repos
  (bbuckingham@redhat.com)
- content-deletion - add backend support for deleting distributions
  (bbuckingham@redhat.com)
- content-deletion - add backend support for deleting errata
  (bbuckingham@redhat.com)
- Adding a missing 'deleted' state to indicate succesfu completion of delete
  (paji@redhat.com)
- Made the promotion UI use the 'apply' method generated by the model
  (paji@redhat.com)
- Added methods to generate repo metadata when packages are deleted
  (paji@redhat.com)
- Made the delete packages call use packages object (paji@redhat.com)
- Made the deletion changeset more bare bones . Trying to just get package
  delete workign at this point (paji@redhat.com)
- content deletion - adding back in the CLI promote and apply
  (mmccune@redhat.com)
- content-deletion - update how changesets are listed when page loaded
  (bbuckingham@redhat.com)
- content-deletion - skip dependency resolution for deletion changesets
  (bbuckingham@redhat.com)
- content-deletion - first mods to integrate js w/ controller (apply/status)
  (bbuckingham@redhat.com)
- Added the deleting state (paji@redhat.com)
- Fixed a compile glitch (paji@redhat.com)
- content-deletion - fix promotion... accidental regression for env handling
  (bbuckingham@redhat.com)
- content-deletion - minor changes to allow creation of changeset in UI
  (bbuckingham@redhat.com)
- INitial work on remove packages (paji@redhat.com)
- Fixed some unit tests. (paji@redhat.com)
- fixed a typo (paji@redhat.com)
- Adding a new changeset model for Content Deletion (paji@redhat.com)
- content-deletion - set the ui action button to promote/delete based on cs
  type (bbuckingham@redhat.com)
- content-deletion - update navigation for changesets (bbuckingham@redhat.com)
- content-deletion - only allow promotion changesets when in Library
  (bbuckingham@redhat.com)
- content-deletion - fix specs broken on previous commit
  (bbuckingham@redhat.com)
- content-deletion - associate proper env with changeset upon creation
  (bbuckingham@redhat.com)
- content-deletion - fix broken spec (bbuckingham@redhat.com)
- content-deletion - changeset history - show changeset type
  (bbuckingham@redhat.com)
- content-deletion - show cs type on promotions cs edit details pane
  (bbuckingham@redhat.com)
- content-deletion - initial ui chgs for add/remove to deletion changeset
  (bbuckingham@redhat.com)
- promotions - bug - promoted repo can be promoted over and over
  (bbuckingham@redhat.com)
- promotions - fix bugs with removing packages from a changeset
  (bbuckingham@redhat.com)
- content-deletion - remove 'promotion' from several display text items
  (bbuckingham@redhat.com)
- content-deletion - update ui to support defining an action type on changeset
  (bbuckingham@redhat.com)
- Forgot to undo one part (paji@redhat.com)
- Made some modifications on the initial model based on comments
  (paji@redhat.com)
- Added action type to  changeset to accomadate content deletion
  (paji@redhat.com)

* Thu Aug 16 2012 Lukas Zapletal <lzap+git@redhat.com> 1.1.5-1
- Icon fix for content search: selector_icon-black
- Switching oauth warden strategy to use request.headers
- Converge-UI update for spinner fadeOut.
- 838115 - Spinner fixes and org selection updates.
- 841228, 844414 - Fix for logging in and not having an org.
- Revert "fixed a small typo."
- api docs - documentation of API
- 830713 - fix monkey patch for ruby 1.9
- removed an extraneous logging to js console
- modified updating of system's environment on system edit page to piggyback on
  jeditable events.
- support for updating of system information screen-wide on system edit
- save button in path_selector is now being disabled after clicking
- various changes per code review
- Support for editing of system environment via web ui
- Org interstitial and switcher cleanup. 843853 and 841686 were fixed.
- fixed a small typo.
- Fix overriding the Rails.env in jshint.rake
- 815802 - Description on package filter does not save properly
- move service-wait to katello-common

* Tue Aug 07 2012 Miroslav Suchý <msuchy@redhat.com> 1.1.4-1
- 842858 - Fixes path issue to locked icon when viewing available changesets on
  the promotion page. (ehelms@redhat.com)
- Content search - make positioning more custom (jsherril@redhat.com)
- 844678 - don't use multi-entitlements on custom products (inecas@redhat.com)
- CS - fixing vert align on view tipsy (jsherril@redhat.com)
- CS - fixing error on repo search with selected product (jsherril@redhat.com)
- Correcting grammar on user notification for deleted environment / User. ->
  self. (jomara@redhat.com)
- fixing bad merge conflict resolution (jsherril@redhat.com)
- 820634 - Katello String Updates (adprice@redhat.com)
- CS - fixing issue where select env before search threw error
  (jsherril@redhat.com)
- Committed the wrong converge ui hash or something, EHELMS (jomara@redhat.com)
- 820634 - Katello String Updates (adprice@redhat.com)
- CS - making search button change text depending on context
  (jsherril@redhat.com)
- 840969 - making KT environment deletes ALSO remove the "default environment"
  relationship to any applicable users. It also notifies the users when they
  log in (jomara@redhat.com)
- 820634 - Katello String Updates (adprice@redhat.com)
- 820634 - Katello String Updates (adprice@redhat.com)
- 820634 - Katello String Updates (adprice@redhat.com)
- 820634 - Katello String Updates (adprice@redhat.com)
- 820634 - Katello String Updates (adprice@redhat.com)
- 821929 - Typo: You -> Your (adprice@redhat.com)
- CS - auto complete enhancements (jsherril@redhat.com)
- CS - fixing repo compare title (jsherril@redhat.com)
- CS - fixing caching not working properly (jsherril@redhat.com)
- little test fix (adprice@redhat.com)
- fixing broken tests due to commit 3bf7ccfbe0f6a82a8d7a7d3108ab9c1358ecb657
  (adprice@redhat.com)
- 803757 - Systems: Users should not be able to enter anything other than
  positive integers for sockets (adprice@redhat.com)
- 844458 - GET of unknown user returns 500 (pajkycz@gmail.com)
- 842003 - fixing error on search when no errata existed (jsherril@redhat.com)
- fixing old env selector issue caused by new path selector
  (jsherril@redhat.com)
- CS - Sort environments on repo comparison according to promotion path
  (jsherril@redhat.com)
- CS - adding tipsy for view selector and changing terminology
  (jsherril@redhat.com)
- Merge branch 'master' of github.com:Katello/katello into content-browser
  (jsherril@redhat.com)
- CS - Adding repo search help (jsherril@redhat.com)

* Sat Aug 04 2012 Miroslav Suchý <msuchy@redhat.com> 1.1.3-1
- CS - Adds missing variablization of color. (ehelms@redhat.com)
- CS - A number of minor updates. (ehelms@redhat.com)
- Introduce +load_remote_data+ method to lazy_attributes (inecas@redhat.com)
- New Role form rewritten (pajkycz@gmail.com)
- adding test for commit 6ed001305416785dab12a94c99f11f93332a3a4a
  (adprice@redhat.com)
- 841984 - Creating new user displays confusing/misleading notification
  (adprice@redhat.com)
- CS - Adds removal of metadata row whenever all elements have been loaded.
  (ehelms@redhat.com)
- CS - Turn more colors into variables. Fixes issue with label appearing
  uncentered.  Adds disabling and tooltip to compare repos button.
  (ehelms@redhat.com)
- Include css for activation_keys/system_groups. (pajkycz@gmail.com)
- CS - Adds permission check for managing environments on environment selector.
  Adds direct link to current organization if link is present.
  (ehelms@redhat.com)
- Check if systems/keys are readable by user. (pajkycz@gmail.com)
- Move activation key to system events section (pajkycz@gmail.com)
- CS - Addition of ellipsis names of column headers with regards to showing
  both the repository name and environment name on repo compare.
  (ehelms@redhat.com)
- CS - Adds Manage Organizations link to the environment selector.
  (ehelms@redhat.com)
- CS - Moves the comparison grid JS into the widgets section.
  (ehelms@redhat.com)
- CS - Updates path selector footer to allow for arbitrary content.
  (ehelms@redhat.com)
- CS - Updates to the way package names are displayed. (ehelms@redhat.com)
- CS - Updates for taller rows to accomodate larger repository names. Adds
  tooltipping to ellipsied names. (ehelms@redhat.com)
- CS - Fixes checkbox showing through env selector, remove auto complete icon
  and button sliding under input box. (ehelms@redhat.com)
- CS - Styling updates. (ehelms@redhat.com)
- Fencing system groups from activation keys nav (pajkycz@gmail.com)
- Activation key - show list of registered systems (pajkycz@gmail.com)

* Thu Aug 02 2012 Tom McKay <thomasmckay@redhat.com> 1.1.2-1
- Merge pull request #411 from thomasmckay/crosslink (thomasmckay@redhat.com)
- Merge pull request #415 from Pajk/765989 (thomasmckay@redhat.com)
- 765989 - Read Only account shows unused checkbox on System / Subscription
  page (pajkycz@gmail.com)
- crosslink - updated attribute for multi-entitlement pool
  (thomasmckay@redhat.com)

* Thu Aug 02 2012 Miroslav Suchý <msuchy@redhat.com> 1.1.1-1
- buildroot and %%clean section is not needed (msuchy@redhat.com)
- 844796 - For async manifest import, there were double-render errors while the
  progress was being checked from javascript. In addition, notices were not
  being displayed after a very quick manifest import. (thomasmckay@redhat.com)
- build katello-headpin and katello-headpin-all from the same src.rpm as
  katello (msuchy@redhat.com)
- rb19 - encoding fix turned off for 1.9 (lzap+git@redhat.com)
- rb19 - removing exact versions from Gemfile (lzap+git@redhat.com)
- rb19 - and one more UTF8 encoding fix (lzap+git@redhat.com)
- puppet - better wait code for mongod (lzap+git@redhat.com)
- Bumping package versions for 1.1. (msuchy@redhat.com)
- puppet - moving lib/util into common subpackage (lzap+git@redhat.com)
- crosslink - links from system and activation key subscriptions
  (thomasmckay@redhat.com)

* Tue Jul 31 2012 Miroslav Suchý <msuchy@redhat.com> 1.0.1-1
- bump up version to 1.0 (msuchy@redhat.com)

* Mon Jul 30 2012 Miroslav Suchý <msuchy@redhat.com> 0.2.56-1
- spec - fixing invalid perms for /var/log/katello (lzap+git@redhat.com)

* Mon Jul 30 2012 Miroslav Suchý <msuchy@redhat.com> 0.2.55-1
- Merge pull request #389 from lzap/quick_certs_fix (miroslav@suchy.cz)
- puppet - improving katello-debug script (lzap+git@redhat.com)

* Mon Jul 30 2012 Miroslav Suchý <msuchy@redhat.com> 0.2.54-1
- replace character by html entity (msuchy@redhat.com)

* Sun Jul 29 2012 Miroslav Suchý <msuchy@redhat.com> 0.2.53-1
- CS - using newer errata icon classes (jsherril@redhat.com)
- making 'Id' be i18n'd (jsherril@redhat.com)
- point Source0 to fedorahosted.org where tar.gz are stored (msuchy@redhat.com)
- converge ui update (jsherril@redhat.com)
- spec test fix (jsherril@redhat.com)
- CS - fixing various issues with cache not being properly saved/loaded
  (jsherril@redhat.com)
- CS - fix issue with drop-downs not being updated properly
  (jsherril@redhat.com)
- CS - Add errata details tipsy to other errata lists (jsherril@redhat.com)
- CS - handle case when errata has no packages (jsherril@redhat.com)
- CS - fixing a couple of issues (jsherril@redhat.com)
- CS - fixing issue where environments were not properly remembered
  (jsherril@redhat.com)
- CS - adding errata details using ajax tipsy (jsherril@redhat.com)

* Fri Jul 27 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.52-1
- require recent converge-ui
- 840609 - fencing SYSTEM GROUPS from activation keys nav
- puppet - adding mongod to the service-wait script
- puppet - adding service-wait wrapper script
- puppet - introducing temp answer file for dangerous options
- puppet - not changing seeds.rb anymore with puppet
- puppet - moving config_value function to rails context
- puppet - removing log dir mangling

* Fri Jul 27 2012 Miroslav Suchý <msuchy@redhat.com> 0.2.51-1
- fix typo in repo files (msuchy@redhat.com)
- Fixes active button state increasing the size of the button awkwardly.
  (ehelms@redhat.com)
- Updates the submodule hash to point to 0.8.3-1 of ConvergeUI.
  (ehelms@redhat.com)
- Updates to make integration of converge-ui's newest changes cleaner and
  remove repetition of CSS styling in the browser. (ehelms@redhat.com)
- Adds override on header for thick border to the left and right of tabs.
  (ehelms@redhat.com)
- Fixes for updates from ConvergeUI. (ehelms@redhat.com)

* Wed Jul 25 2012 Miroslav Suchý <msuchy@redhat.com> 0.2.50-1
- unit test fix (jsherril@redhat.com)
- More tweaks + a spec test (jomara@redhat.com)
- fixing issue where repos only in library would show up (jsherril@redhat.com)
- Style changes as per pull request comments (jomara@redhat.com)
- Adding fresh copy of katello.spec due to bad merge (jsherril@redhat.com)
- master merge conflict (jsherril@redhat.com)
- 840531 - Fixes issue with inability to individually promote packages attached
  to a system template or changeset that have more than a single dash in the
  name. (ehelms@redhat.com)
- fixing mistaken name change (jsherril@redhat.com)
- 841691 - Moving interface display to DETAILS page and removing it from system
  list (jomara@redhat.com)
- put spec on pair with Gemfile (msuchy@redhat.com)
- CS - properly handling search error (jsherril@redhat.com)
- merge conflict (jsherril@redhat.com)
- CS - changing collect{} ids on active record queries to use pluck
  (jsherril@redhat.com)
- Adding pluck support to active record, new feature backported from 3.1
  (jsherril@redhat.com)
- CS - greatly condensing bbq for environments (jsherril@redhat.com)
- CS - fixing initially selected environment (jsherril@redhat.com)
- CS - fixing consistency with page_size arguments (jsherril@redhat.com)
- CS - a few suggested fixes (jsherril@redhat.com)
- Added a way to return 'empty search results', an array with 'total' attribute
  (paji@redhat.com)
- CS - implementing roles based access controls (jsherril@redhat.com)
- Fixed an issue where the rescue in Packages and Errata search was catching
  non bad query exceptions (paji@redhat.com)
- Added unit tests to test differnt actions in content search (paji@redhat.com)
- 841000 - fixing product autocomplete issues (jsherril@redhat.com)
- CS - adding shared/unique modes to the repo search (jsherril@redhat.com)
- CS - adding all/unique/shared selector to product search
  (jsherril@redhat.com)
- CS - adding mode switcher to repo comparison (jsherril@redhat.com)

* Tue Jul 24 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.49-1
- rake - make rake compatible with 0.8.7
- need a sudo in front of the cat so it can read the pass file

* Mon Jul 23 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.48-1
- gemfile - decreasing thin 1.2.11 requirement to 1.2.8
- Fixed some unit test breakages caused by commit
  f06bf0c5383dffef7ee2aea6597aaa06c4964ab9
- Fencing more system groups code for systems page
- system groups - fix query on systems -> system groups pane
- master merge conflict fix
- system groups - updates to validation of max_systems
- system groups - API accepts max_systems and CLI unit tests
- 839265 - system - generate proper error if user attempts to add groups w/o
  providing any
- system groups - close copy widget when switching objects or panes
- Make third level navigation in panel sticky
- master merge conflict
- reverting to the same hash as I had originally
- spec test fix
- CS - Changes sliding aspect of grid to be more inuitive to a user's
  experience such that clicking to slide right reveals more columns to the
  right.
- content browser - fixing migration script to properly propogate
- system groups - removing local modifications not intended for upstream
- system groups - unit tests and error conditions
- content browser - fixing migration to migrate clone.library_instance_id
  properly
- Added server side code for Repo Compare Shared/Unique
- Removes test data from code that prevents production asset compiling.
- CS - Minor styling updates and a fix for packages with the same ID showing up
  only once in the grid.
- group copy cli and API first pass
- CS - Fixes issue with data export for returning to results.
- content  browser - adding search mode selector
- CS - Styling updates for browse box.
- content browser - fixing metadata ro wmissing
- content browser - preparing for mode selector and other fixes
- CS - Update to how columns are handled to produce logical pathing order
  across browsers.
- CS - Styling updates to environment selector widget.
- merge conflict
- content browser - adding show/hide support for compare button
- Initial stab at the server side interaction of shared vs unique
- content browser - intitial comparison wiring
- CS - Proper hash from master merge.
- CS - Changes for repository comparison checkboxes supplying column and row
  id.
- content browser - manually switching to results mode on search to fix some
  oddities
- content browser - making content selector show selected value
- content browser - fixing issue with more rows showing up when not needed
- content browser - fixing issue with more rows on repo contents
- content browser - fixing issue where packages and errata were not including a
  parent_row
- content browser - fixing merge conflict and making all data returned as a
  hash
- CS - Fixes for empty space when last column is visible and another column is
  removed from the visible set.
- CS - Fixes messed up errata column headers.
- content browser - adding more rows support for repo errata & packages
- CS - Adds count updates on metadata row.
- CS - Adds spinner and disabled load more link.
- CS - Updates to load extra data above the load more row instead of underneath
  it.
- CS - Adjusts spinner location and look.
- CS - Adds display of repository name when viewing repo details.
- content browser - making package ids not analyzed in elastic search
- content browser - some small performance improvements, adding hover on
  products
- content browser - adding tipsy for search help
- adding a library_instance_id to the repository object
- CS - Rows nested deeper than 2 levels will now be collapsed on initial draw.
- CS - Cleanup for loading screen.
- content browser - content selector and more rows wiring
- jsroutes update
- CS - RE-factor of how child rows are handled to support loading of more rows
  in a cleaner manor.
- CS - Adds initial support paginated loading of data via "show more" row.
- content browser - improving user experience of selecting environments
- initial untested pagination
- CS - Cleanup around row collapse.
- CS - Adds ability to enable checkboxes on individual cells.
- content browser - making path selector not reserve checkbox space
- CS - Adds ability to set a title in the details view, and specify a details
  content selector.
- content browser - fixing package/errata search issues
- content browser - changing position of path selector
- content browser - fixing nonenabled repos showing up
- content browser - a few fixes
- content browser - fixing 2 issues with grid caching
- content browser - hooking up back button
- CS - Adds support for allowing columns to span multiple column widths.
- CS - Adds back to results button and associated generic event upon click.
- content browser - fixing error when no errata exist
- fixing path selector not maintaining selected environments
- content browser - adding errata search
- fixing issue with rows having odd characters in their names
- fixing merge conflict
- removing console.log statement
- merge conflcit
- CS - Updates to deep copy exported object states from the grid.
- Added server side bindings for cs compare packages and errata calls
- content browser - adding initial search caching support
- CS - Exposes export/import functionality to instantiated grid objects.
- CS - Adds seperated data layer for import/export of states.
- fixing converge-ui hash
- merge conflict
- content browser - initial subgrid support initially just packages
- routes update
- jsroutes update
- merge conflict
- Added serverside code for package and repo contents
- content browser - initial pkg pagination support
- content browser - fixing some mistaken text labels
- content browser - adding initial package pagination
- content browser - adding library id to search index for respositories
- CS - Fixes nesting collapse for multiple children.
- content browser - having package search return packages
- merge conflict
- CS - Clean-up and refactoring.
- CS - Adds basic footer to grid component.
- CS - Makes environment selector a more generic feature of the grid.
- CS - Adds loading screen for switching grid data.
- CS - Updates to styling and adding hover states to sliding arrows.
- CS - Adds generic row nesting with colllapse functionality attached to parent
  rows.
- CS - Adds hover support and custom display data for cells.
- CS - Adjustments to sliding states of arrows.  Addition of new environment
  selector icon.
- initial package search
- jsroutes update
- Added some initial permissions stubs for search controller
- Added code to render the product and repo search results in a new json
  structure
- content browser - adding autocomplete for packages
- CS - Fix for hiding column.
- CS - Updates to add first level row nesting support.
- CS - Additional styling and addition of on hover state for scrolling.
- Updated stylings and added icons for content search.
- CS - Fixes up spacing for grids and cells.  Adds left and right sliding of
  content area with column headers.
- CS - Applying some base styling.
- content browse - some style fixes
- content-browser - initial selection of library environment
- path selector - making path selector adjust horizontally based on available
  space
- Updates as a result of merging master and updating converge-ui.
- Updates to git left and right arrows showing up only when more than 3
  environments are present.
- Adds structure and functionality for scrolling environments left and right in
  the column headers.
- CS - Adds the structure and building blocks for allowing environments to be
  scrolled left to right when they overflow the header.
- CS - Setting of margins and general spacings for grid and browse boxes.
- Added smarts to only do the search call if necessary in content_search
- Added bbq support for environments in the content_search page
- content browser - adding product information for repos
- content-browser - initial repo search
- js routes update
- content-browser - making browse box support search & autocomplete
- Added a landing point for Content Search page under Content Management
- content browser - adding bbq to main search
- CFB - Wires up basic product search results to grid view to allow viewing of
  products and marking with an 'x' which environments currently visible a
  product is in.
- CFB - Fix to set the line height in path selector and not inherit from parent
  elements.
- CFB - Adds some basic styling for cells and support for adding rows with new
  column paradigm.
- CFB - Changes the way columns are added to the grid structure and wires up
  the environment selector to add/remove columns.
- CFB - Adds support for adding new rows and new columns.
- CFB - Wires up basic row/column adding within grid view.
- content browser - product autocomplete and autocomplete list support
- Added product search + Autocomplete for the content browser
- content browser - changing return value of products
- content browser - adding browse box logic, and initial search logic
- updated js routes
- environment selector - making return data ordered, and fixing returned name
- fixing missing pixel
- changing env selector to use a label instead of an anchor
- minor path selector improvements and additional interface functions
- environment selector - more improvements to selector
- CFB - Adds selection and input elements for browse box as basic layout - no
  functionality.
- environment selector - add first environment linkage for selection
- adding selectability to the path selector
- CFB - Adds basic layouts for browse box and grid.
- initial new environment selector
- Initial content search boilerplate

* Wed Jul 18 2012 Miroslav Suchý <msuchy@redhat.com> 0.2.47-1
- fixing build issue (msuchy@redhat.com)
- a2x require /usr/bin/getopt (msuchy@redhat.com)

* Wed Jul 18 2012 Miroslav Suchý <msuchy@redhat.com> 0.2.46-1
- do not copy files which we do not need/want (msuchy@redhat.com)
- introduce katello-service for managing katello services (msuchy@redhat.com)
- system groups - move the listing of groups by updates needed to the model
  (bbuckingham@redhat.com)
- system group - fix accidental change on file header (bbuckingham@redhat.com)
- system groups - update dashboard to account for critical/warning/up-to-date
  (bbuckingham@redhat.com)
- Removing the global after/do for role spec (jomara@redhat.com)
- 840625 - Post 'import manifest' subscriptions return row:NotFound
  (pajkycz@gmail.com)
- system groups - add portlet to the dashboard for groups
  (bbuckingham@redhat.com)
- system groups - fix js syntax error (bbuckingham@redhat.com)
- from petr; improving config setting in role test for ldap (jomara@redhat.com)
- 840600 - Post creating new environment in headpin, webui returns row:NotFound
  error (pajkycz@gmail.com)
- katello - action profiling (pchalupa@redhat.com)
- Fixing some ldap config issues that were polluting unrelated tests
  (jomara@redhat.com)
- katello - make jshintrb optional (pchalupa@redhat.com)
- null_activeBlockId - fixed case where active block was not known
  (thomasmckay@redhat.com)
- katello - corrections after pull request review (pchalupa@redhat.com)
- %%defattr is not needed since rpm 4.4 (msuchy@redhat.com)
- 808437 - [RFE] Don't make notifications for CLI actions performed (and pop
  them up in UI) (pchalupa@redhat.com)
- katello - notifications cleanup (pchalupa@redhat.com)
- katello - remove unused methods (pchalupa@redhat.com)

* Mon Jul 16 2012 Lukas Zapletal <lzap+git@redhat.com> 0.2.45-1
- system_details - added display of environment to left list and details page
- productid - fixed html for System / Subscriptions
- ldap provided by ldap_fluff. Adds support for FreeIPA & Active Directory
- Adds fencing around jshint for development environment only.
- 811564_subs_match - change default user preference to 'false' for 'match
  subscriptions to system'
- 839005 - removed 'force' from upload manifest in UI
- bonus_rename - changed Bonus From to Virt Guest From in System Details page
- system groups - fix css for handling separator between copy and remove links
- system groups - close 'copy' form when panel is closed
- actkey_section - activation_keys_controller returning incorrect section_id
- Merge remote-tracking branch 'upstream/master' into fork-group_remove_lock
- Adds removal of two development tasks from spec file.
- system groups - removing 'locked' feature from the javascript
- system groups - remove initialization of variable to undefined
- system groups - updating packages table header based on UXD input
- system groups - include system count on panel for create and copy
- system group - update pkgs controller notices to use %%s vs named params
- subs-tupane - two pane subscriptions view
- system groups - update notices to use %%s vs named params
- 837136 - fixing promotions packages sometimes not loading
- Fix for broken GPG Keys unit test.
- system groups - removing the 'locked' feature from system groups UI/API/CLI
- Updated hash for login fix.
- Fix for spinner issues on login page.
- system groups - copy - add spec tests
- revert - accidental commit to development.rb
- system groups - ui - add the ability to create a group based on copy of an
  existing group
- Katello-debug should pull in httpd logs and conf files
- JSHint - Adds support for running JSHint in development via a rake task.
- Updated hash for converge-ui to include pull request.
- panelpage - rename BBQ from 'action' to 'panelpage'
- panelpage - clean up var declaration
- panelpage - maintain which tab of panel was last visible
- Removed duplicate .versionining declaration.
- Fixed menu for organizations in administer, tweak on org switcher.
- Updated hash for lastest converge-ui.
- Org switcher interstitial post-login.
- errata module - moving it from controllers to lib
- systems - update packages pane to support accessing task details on
  completion
- systems - fix specs due to uuid to id change for actions
- system - update the packages UI to use task id vs uuid
- system groups - update packages pane to support accessing job details
- system groups - update errata pane to support accessing job details
- system groups - api/cli - add ability to list errata by group
- Additional params for the condition to check if manage orgs ability.
- Added perm for org editablity.
- Org switcher interstitial working minus scrolling in the switcher itself. :(
- Changes to login to accomodate org switcher interstitial.
- Redirect working.
- Working on interstitial for Orgs!
- Removing orgs from top level menu.
- Org switcher movement and Administer button movement.
- Check for current user.
- Org Switcher initial changes.

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
