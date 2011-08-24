Using the puppet scripts
========================
This has been tested on Fedora 15 only. YMMV may vary on other osses. Please use the following steps:

1) Install a minimal Fedora.
2) Install wget and puppet
3) Copy the attached puppet scripts to the machine.
4) Execute the following:

puppet candlepin.pp
puppet pulp-fedora.pp
puppet katello.pp

Known issues:

candlepin.pp
------------
cpsetup will sometimes fail. To fix this, run /usr/share/cpsetup.

katello.pp
----------
The oauth may fail on pulp. For this, you need to run /usr/share/katello/scripts/reset-oauth. Then, restart pulp-server and tomcat6 services. Then you run service katello initdb.
