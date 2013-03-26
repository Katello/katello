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

# REMOVEME - commented out until Foreman is SCL ready
# (search for REMOVEME strings down the file)
%if "%{?scl}" == "ruby193x"
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
Version:        1.3.14
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
Requires:        %{name}-glue-foreman
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
Requires:       %{?scl_prefix}rubygems
Requires:       %{?scl_prefix}rubygem(rails) >= 3.0.10
Requires:       %{?scl_prefix}rubygem(haml) >= 3.1.2
Requires:       %{?scl_prefix}rubygem(haml-rails)
Requires:       %{?scl_prefix}rubygem(json)
Requires:       %{?scl_prefix}rubygem(rest-client)
Requires:       %{?scl_prefix}rubygem(jammit)
Requires:       %{?scl_prefix}rubygem(rails_warden)
Requires:       %{?scl_prefix}rubygem(net-ldap)
Requires:       %{?scl_prefix}rubygem(compass)
Requires:       %{?scl_prefix}rubygem(compass-960-plugin) >= 0.10.4
Requires:       %{?scl_prefix}rubygem(oauth)
Requires:       %{?scl_prefix}rubygem(i18n_data) >= 0.2.6
Requires:       %{?scl_prefix}rubygem(gettext_i18n_rails)
Requires:       %{?scl_prefix}rubygem(simple-navigation) >= 3.3.4
Requires:       %{?scl_prefix}rubygem(pg)
Requires:       %{?scl_prefix}rubygem(delayed_job) >= 2.1.4
Requires:       %{?scl_prefix}rubygem(acts_as_reportable) >= 1.1.1
Requires:       %{?scl_prefix}rubygem(ruport) >= 1.7.0
Requires:       %{?scl_prefix}rubygem(prawn)
Requires:       %{?scl_prefix}rubygem(daemons) >= 1.1.4
Requires:       %{?scl_prefix}rubygem(uuidtools)
Requires:       %{?scl_prefix}rubygem(hooks)
Requires:       %{?scl_prefix}rubygem(thin)
Requires:       %{?scl_prefix}rubygem(fssm)
Requires:       %{?scl_prefix}rubygem(sass)
Requires:       %{?scl_prefix}rubygem(chunky_png)
Requires:       %{?scl_prefix}rubygem(tire) >= 0.3.0
Requires:       %{?scl_prefix}rubygem(tire) < 0.4
Requires:       %{?scl_prefix}rubygem(ldap_fluff)
Requires:       %{?scl_prefix}rubygem(foreman_api) >= 0.0.7
Requires:       %{?scl_prefix}rubygem(anemone)
Requires:       %{?scl_prefix}rubygem(apipie-rails) >= 0.0.18
Requires:       %{?scl_prefix}rubygem(logging) >= 1.8.0
Requires:       %{?scl_prefix}rubygem(bundler_ext)
Requires:       lsof

%if 0%{?rhel} == 6
Requires:       redhat-logos >= 60.0.14
%endif

# REMOVEME - uncomment following line instead the next for SCL
#%if 0%{?fedora} && 0%{?fedora} < 17
%if 0%{?rhel} == 6 || (0%{?fedora} && 0%{?fedora} < 17)
Requires: %{?scl_prefix}ruby(abi) = 1.8
%else
Requires: %{?scl_prefix}ruby(abi) = 1.9.1
%endif
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
# TODO we will remove jammit soon
BuildRequires:  rubygem(jammit)
BuildRequires:  %{?scl_prefix}rubygem(chunky_png)
BuildRequires:  %{?scl_prefix}rubygem(fssm) >= 0.2.7
BuildRequires:  %{?scl_prefix}rubygem(compass)
BuildRequires:  %{?scl_prefix}rubygem(compass-960-plugin) >= 0.10.4
BuildRequires:  %{?scl_prefix}rubygem(bundler_ext)
BuildRequires:  %{?scl_prefix}rubygem(logging) >= 1.8.0
BuildRequires:  %{?scl_prefix}rubygem(alchemy) >= 1.0.0
BuildRequires:  asciidoc
BuildRequires:  /usr/bin/getopt
BuildRequires:  java >= 0:1.6.0
BuildRequires:  gettext
BuildRequires:  translate-toolkit

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
BuildRequires:       %{?scl_prefix}rubygem(delayed_job) >= 2.1.4
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
BuildRequires:       %{?scl_prefix}rubygem(foreman_api)

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
Requires:       foreman
Requires:       foreman-postgresql
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
Requires:        %{?scl_prefix}rubygem(runcible) >= 0.4.1

%description glue-pulp
Katello connection classes for the Pulp backend

%package glue-foreman
BuildArch:      noarch
Summary:         Katello connection classes for the Foreman backend
Requires:        %{name}-common
# dependencies from bundler.d/foreman.rb
Requires:        %{?scl_prefix}rubygem(foreman_api) >= 0.0.18

%description glue-foreman
Katello connection classes for the Foreman backend

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
%if 0%{?fedora} > 16
Requires:        rubygem(simplecov)
%else
Requires:        rubygem(rcov) >= 0.9.9
%endif

%description devel-coverage
Rake tasks and dependecies for Katello developers, which enables
code coverage for tests.

%package devel-debugging
Summary:         Katello devel support (debugging)
BuildArch:       noarch
Requires:        %{name} = %{version}-%{release}
# dependencies from bundler.d/debugging.rb
%if 0%{?fedora} > 16
Requires:        rubygem(ruby-debug19)
%else
Requires:        rubygem(ruby-debug)
%endif

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

#copy alchemy
ALCHEMY_DIR=$(rpm -ql %{?scl_prefix}rubygem-alchemy | grep -o '/.*/vendor' | sed 's/vendor$//' | head -n1)
cp -R $ALCHEMY_DIR* ./vendor/alchemy

#use Bundler_ext instead of Bundler
%if 0%{?fedora} > 17
  mv Gemfile32 Gemfile.in
  rm Gemfile
%else
  mv Gemfile Gemfile.in
  rm Gemfile32
%endif

#pull in branding if present
if [ -d branding ] ; then
  cp -r branding/* .
fi

%if ! 0%{?fastbuild:1}
    #compile SASS files
    echo Compiling SASS files...
    touch config/katello.yml
# REMOVEME - commented out until Foreman is SCL ready
#%{?scl:scl enable %{scl} "}
    compass compile
#%{?scl:"}
    rm config/katello.yml

    #generate Rails JS/CSS/... assets
    echo Generating Rails assets...
    LC_ALL="en_US.UTF-8" jammit --config config/assets.yml -f
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
# REMOVEME - commented out until Foreman is SCL ready
#%{?scl:scl enable %{scl} "}
    rake apipie:static apipie:cache --trace
#%{?scl:"}

    # API doc for Headpin mode
    echo "common:" > config/katello.yml
    echo "  app_mode: headpin" >> config/katello.yml
# REMOVEME - commented out until Foreman is SCL ready
#%{?scl:scl enable %{scl} "}
    rake apipie:static apipie:cache OUT=doc/headpin-apidoc --trace
#%{?scl:"}
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
rm -f %{buildroot}%{homedir}/public/stylesheets/.gitkeep
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
%exclude %{homedir}/app/controllers/api/foreman
%exclude %{homedir}/app/controllers/foreman
%{homedir}/app/helpers
%{homedir}/app/mailers
%dir %{homedir}/app/models
%{homedir}/app/models/*.rb
%{homedir}/app/models/authorization/*.rb
%{homedir}/app/models/candlepin
%{homedir}/app/models/ext
%{homedir}/app/models/roles_permissions
%{homedir}/app/stylesheets
%{homedir}/app/views
%exclude %{homedir}/app/views/foreman
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
%dir %{homedir}/app/lib/resources
%{homedir}/app/lib/resources/cdn.rb
%{homedir}/app/lib/resources/abstract_model.rb
%dir %{homedir}/app/lib/resources/abstract_model
%{homedir}/app/lib/resources/abstract_model/indexed_model.rb
%{homedir}/lib/tasks
%exclude %{homedir}/lib/tasks/rcov.rake
%exclude %{homedir}/lib/tasks/yard.rake
%exclude %{homedir}/lib/tasks/hudson.rake
%exclude %{homedir}/lib/tasks/jsroutes.rake
%exclude %{homedir}/lib/tasks/jshint.rake
%exclude %{homedir}/lib/tasks/test.rake
%exclude %{homedir}/script/pulp_integration_tests
%{homedir}/locale
%{homedir}/public
%dir %attr(775, katello, katello) %{homedir}/public/stylesheets/compiled
%if ! 0%{?nodoc:1}
%exclude %{homedir}/public/apipie-cache
%endif
%{homedir}/script
%exclude %{homedir}/script/service-wait
%{homedir}/spec
%{homedir}/tmp
%{homedir}/vendor
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

%files glue-foreman
%{homedir}/bundler.d/foreman.rb
%{homedir}/app/lib/resources/foreman.rb
%{homedir}/app/lib/resources/foreman_model.rb
%{homedir}/app/models/foreman
%{homedir}/app/models/glue/foreman
%{homedir}/app/controllers/api/foreman
%{homedir}/app/controllers/foreman
%{homedir}/app/views/foreman

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
%exclude %{homedir}/app/models/foreman
%exclude %{homedir}/app/controllers/api/foreman
%exclude %{homedir}/app/controllers/foreman
%exclude %{homedir}/app/views/foreman
%exclude %{homedir}/lib/tasks/test.rake
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
%{homedir}/lib/katello/
%exclude %{homedir}/lib/README
%{homedir}/app/lib/*.rb
%exclude %{homedir}/app/lib/README
%{homedir}/lib/monkeys
%{homedir}/app/lib/navigation
%{homedir}/app/lib/notifications
%{homedir}/app/lib/resources
%{homedir}/app/lib/validators
%exclude %{homedir}/app/lib/resources/candlepin.rb
%exclude %{homedir}/app/lib/resources/abstract_model.rb
%exclude %{homedir}/app/lib/resources/foreman_model.rb
%exclude %{homedir}/app/lib/resources/foreman.rb
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
%{homedir}/bundler.d/development_boost.rb
%{homedir}/lib/tasks/yard.rake
%{homedir}/lib/tasks/hudson.rake
%{homedir}/lib/tasks/jsroutes.rake

%files devel-profiling
%{homedir}/bundler.d/optional.rb

%files devel-test
%{homedir}/bundler.d/test.rb
%{homedir}/lib/tasks/test.rake
%{homedir}/script/pulp_integration_tests

%files devel-checking
%{homedir}/bundler.d/checking.rb
%{homedir}/lib/tasks/jshint.rake

%files devel-coverage
%{homedir}/bundler.d/coverage.rb
%{homedir}/lib/tasks/rcov.rake

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
- Fixed a couple of errors that occurred due to wrong sql in postgres
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

