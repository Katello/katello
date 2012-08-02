Name:     ###NAME###
Version:  ###VERSION###
Release:  ###RELEASE###
Summary:  A dummy package of ###NAME###
License:  GPLv2

Group:          Internet/Applications
URL:            http://tstrachota.fedorapeople.org
Source:         ###NAME###.tar.gz

###REQUIRES###

BuildArch: noarch

%description
%{summary}

%prep
if [ ! -d "%{buildroot}/" ]; then
   mkdir %{buildroot}/
fi
tar -xzvf %{_sourcedir}/###NAME###.tar.gz -C %{buildroot}/

%post
date +"Package install time: %T %m-%d-%Y" >> /###NAME###.txt

%files
/###NAME###.txt
