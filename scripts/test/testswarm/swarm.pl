#!/usr/bin/perl

use JSON;
use Data::Dumper;

my $SWARM = "http://localhost";
my %SUITES = (katello => 'http://katello-ci.usersys.redhat.com:3000/javascripts/test/',
              sync => 'http://katello-ci.usersys.redhat.com:3000/javascripts/test/sync.html',
              notices => 'http://katello-ci.usersys.redhat.com:3000/javascripts/test/notices.html'
             );
my $jobname = 'katello-js-' . $ARGV[0];

my %props = (
             "state" => "addjob",
             "output" => "dump",
             "user" => "katello",
             "max" => "5",
             "job_name" => $ARGV[0],
             "browsers" => "popularbetamobile",
             "auth" => "8481b32104b1ad6dc814c8c5912e6b4d0f2e5970"
            );

my $query = "";

foreach my $prop ( keys %props ) {
        $query .= ($query ? "&" : "") . $prop . "=" . clean($props{$prop});
}

foreach my $suite ( sort keys %SUITES ) {
        $query .= "&suites[]=" . clean($suite) .
                  "&urls[]=" . clean($SUITES{$suite});
}
# add job to swarm server
my $job = `curl --connect-timeout 10 -d "$query" $SWARM`;
$job =~ s/\D//g;
print "JOB ID is $job\n";

# wait on all client runs
while ( my $q = runs_queued($job) ) {
  print "$q client runs still queued...\n";
  sleep(5);
} 

my $runs = runs_completed($job);
junit($runs, $jobname);

sub junit {
  use XML::Writer;
  use IO::File;
  my $runs = shift;
  my $jname = shift;
  my $workspace = $ENV{'WORKSPACE'} . "/$jname.xml";

  my $jXML = new IO::File(">$workspace");
  my $writer = new XML::Writer(OUTPUT => $jXML, DATA_MODE => 1, DATA_INDENT => 2);
  $writer->xmlDecl('UTF-8');
  $writer->startTag("testsuites", "name" => $jname);

  for (@$runs) {
     $writer->startTag("testsuite", "name" => $_->{'agent'} . '.' . $_->{'os'}, 
                       "tests" => $_->{'total'}, "failures" => $_->{'fail'});
     for (@{$_->{'results'}}) {
       $writer->startTag("testcase", "name" => $_->{'name'} );
       my $failed = $_->{'failed'};
       if ($failed > 0) {
         $writer->emptyTag("failure", "message" =>"$failed cases");
       }
       $writer->endTag("testcase");
     }
     $writer->endTag("testsuite");
  }
  $writer->endTag("testsuites");
}

sub clean {
  my $str = shift;
  $str =~ s/([^A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg;
  $str;
}

sub runs_queued {
  my $job = shift;
  my $dbh = SwarmDB->connect;
  my $query = <<EOQ;
              SELECT COUNT(*) FROM run_useragent ru
              JOIN runs r on ru.run_id = r.id
              WHERE 1=1 
              AND   ru.useragent_id IN
                    (SELECT useragent_id FROM clients c
                     WHERE DATE_ADD(c.updated, INTERVAL 1 minute) > NOW())
              AND ru.status < 2
              AND r.job_id = ?
EOQ
  my $sth = $dbh->prepare($query);
  $sth->execute($job);
  my($num) = $sth->fetchrow_array();
  return $num;
}

sub runs_completed {
  my $job = shift;
  my $dbh = SwarmDB->connect;
  my $query = <<EOQ;
              SELECT r.id AS run, 
                     c.id AS client,
                     c.os AS os,
                     ua.name AS agent,
                     rc.total AS total,
                     rc.fail AS fail
              FROM run_client rc
              JOIN runs r ON rc.run_id=r.id
              JOIN clients c ON rc.client_id=c.id
              JOIN useragents ua ON c.useragent_id=ua.id
              WHERE 1=1 
              AND rc.status=2 
              AND r.job_id = ?
EOQ
  my $sth = $dbh->prepare($query);
  $sth->execute($job);
  my @results;
  while ( my($run, $client, $os, $agent, $total, $fail) = $sth->fetchrow_array() ) {
    my $result = results($run, $client);
    my $json =  decode_json($result);
    $agent=~ s/\s//g;
    my $data = { os => $os, agent => $agent, total => $total, fail => $fail, results => $json};
    #map { $data->{$_} = $json->[0]->{$_} } keys %{$json->[0]}; #merge hashes
    push (@results, $data);
  }
  return \@results
}

sub results {
  my $run = shift;
  my $client = shift;

  my $dbh = SwarmDB->connect;
  my $query = <<EOQ;
              SELECT results 
              FROM run_client 
              WHERE 1=1
              AND run_id = ?
              AND client_id = ?
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute($run, $client);
  my ($stuff) = $sth->fetchrow_array();
  return $stuff;
}

package SwarmDB;
use DBI;

my $dsn = "DBI:mysql:host=localhost;database=testswarm";

  sub connect {
    return (DBI->connect ('dbi:mysql:host=localhost;database=testswarm', 'root', 'katello', {PrintError => 0, RaiseError => 1}));
  } 
