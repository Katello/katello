#!/bin/perl

use strict;

# this script will compare the output of 'bundle install' to what we have in our katello 
# gem repos. purpose is to find which gems are ahead in the katello project and do not
# have matching rpm versions

# directory after running '$ bundle install --without test development --path /tmp/foo'
my $gemdir = '/tmp/foo/ruby/1.8/gems';
# location of katello-gems git repo
my $rpmdir = '/git/katello-gems';

# bundle gems 
opendir my($dh), $gemdir or die "can not open gem dir";
my @gems = grep { !/^\./ } readdir $dh;
closedir $dh;

my %bundle;
my %rpms;

for (@gems) {
  my ($name, $ver) = split /-(?!.*?-)/;
  $bundle{$name} = $ver;
}

# katello-gems rpms, builds on axiom
opendir $dh, $rpmdir or die "can not open rpm dir";
@gems = grep { !/^\./ && -d "$rpmdir/$_" } readdir $dh;
closedir $dh;

for (@gems) {
  
  opendir $dh, "$rpmdir/$_" or die "can not open $_";
  my ($gem) = grep { /\.gem/ } readdir $dh; 
  closedir $dh;
  next unless $gem;
  $gem =~ s/\.gem//i;
  my ($name, $ver) = split /-(?!.*?-)/, $gem;
  $rpms{$name} = $ver;
}

# walk the bundle gems and check if we have them in rpms
print "Comparing Katello gems to Katello rpm versions ...\n\n";
for (keys %bundle) {
 if ($rpms{$_}) {
   if ($rpms{$_} ne $bundle{$_}) {
     print "WARN: Kalapana $_ version $bundle{$_} does not match RPM version $rpms{$_}\n";
   }
 } else { print "ERROR: Katello $_ needs to be build. No rpm found\n"; }
}

print "\nSearching for stale Katello rpms ...\n\n";
for (keys %rpms) {
  unless  ($bundle{$_}) {
    print "WARN: $_ rpm was found but not in Kalapana bundle gem list\n";
  }  
}
