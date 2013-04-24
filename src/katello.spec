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
Version:        1.4.1
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
Requires:       %{?scl_prefix}v8
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
Requires:       %{?scl_prefix}rubygem(rabl)
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
BuildRequires:  %{?scl_prefix}rubygem(minitest)
BuildRequires:  %{?scl_prefix}rubygem(minitest-rails)
BuildRequires:  %{?scl_prefix}rubygem(rabl)
BuildRequires:  %{?scl_prefix}rubygem(hooks)
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
Requires:       v8
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

#run source code tests
%{?scl:scl enable %scl "}
    touch config/katello.yml
    ruby -Itest test/source_code_test.rb
%{?scl:"}


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
%{homedir}/app/lib/api
%{homedir}/app/lib/api/constraints
%{homedir}/app/lib/api/v1
%{homedir}/app/lib/api/v2
%dir %{homedir}/app/lib/resources
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
%{homedir}/app/lib/api
%{homedir}/app/lib/api/constraints
%{homedir}/app/lib/api/v1
%{homedir}/app/lib/api/v2
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
* Fri Apr 12 2013 Justin Sherrill <jsherril@redhat.com> 1.4.1-1
- version bump to 1.4 (jsherril@redhat.com)

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
