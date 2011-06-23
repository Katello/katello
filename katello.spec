%define ruby_sitelib %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")
%define gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)

%global homedir %{_prefix}/lib/%{name}
%global datadir %{_sharedstatedir}/%{name}
%global confdir extras/fedora

Name:       katello		
Version:	0.1.48
Release:	1%{?dist}
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
Requires:       rubygem(haml)
Requires:       rubygem(haml-rails)
Requires:       rubygem(json)
Requires:       rubygem(rest-client)
Requires:       rubygem(jammit)
Requires:       rubygem(rails_warden)
Requires:       rubygem(net-ldap)
Requires:       rubygem(compass)
Requires:       rubygem(compass-960-plugin)
Requires:       rubygem(capistrano)
Requires:       rubygem(oauth)
Requires:       rubygem(i18n_data) >= 0.2.6
Requires:       rubygem(gettext_i18n_rails)
Requires:       rubygem(simple-navigation) >= 3.1.0
Requires(pre):  shadow-utils
Requires(preun): chkconfig
Requires(preun): initscripts
Requires(post): chkconfig
Requires(postun): initscripts 
Requires: rubygem(sqlite3) 
Requires:       rubygem(pg)
Requires:       rubygem(scoped_search)
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
