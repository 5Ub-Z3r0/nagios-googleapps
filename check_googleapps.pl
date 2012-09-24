#!/usr/bin/perl

use JSON::PP;
use LWP::Simple;
use strict;
use warnings;
use Nagios::Plugin;
use File::Basename;
use constant GAPPS_JSON_URL => 'http://www.google.com/appsstatus/json/en';

my $VERSION	= '1.0';
my $PROGNAME	= basename($0);
my $JSON_stats;
my $JSON_object	= undef;
my %JSON_hash;
my $gApps_id    = undef;

my $np = Nagios::Plugin->new( 
    shortname => "Google Apps",  
    usage => "Usage: %s -s|--service=service [ -w|--warning " .
             "-h|--help ]",
    blurb => "Report the status of the Google Apps for Business Services"
);

# Parse arguments and process standard ones (e.g. usage, help, version)
$np->add_arg(
        spec => 'service|s=s',
        help => qq{-s, --service=STRING},
        required => 1,
);
$np->add_arg(
        spec => 'help|h+',
        help => qq{-h, --help},
);
$np->add_arg(
        spec => 'warning|w+',
        help => qq{-w, --warning},
);

$np->getopts;

$JSON_stats = get (GAPPS_JSON_URL) or $np->nagios_exit( UNKNOWN, "cannot reach Google Apps Status JSON" );

$JSON_stats =~ s/dashboard.jsonp\((.+)\)\;$/$1/g;
$JSON_object = new JSON::PP;
$JSON_stats = $JSON_object->allow_nonref->max_depth(2048)->decode($JSON_stats);

foreach (@{$JSON_stats->{services}}){
#  print "id: $_->{id}, name: $_->{name}\n";
  if ($_->{name} eq $np->opts->service){
    $gApps_id = $_->{id};
    last;
  }
}

$np->nagios_exit( UNKNOWN, "GoogleApps service \"".$np->opts->service ."\" does not exists" ) unless $gApps_id;

foreach (@{$JSON_object->{messages}}){
  unless ($_->{resolved} eq '1'){
    if ($_->{service} eq $gApps_id){
      #problem found
      if ($np->opts->warning){
        $np->nagios_exit ( WARNING, "GoogleApps service \"".$np->opts->service ."\" has an issue" );
      }else{
        $np->nagios_exit ( CRITICAL, "GoogleApps service \"".$np->opts->service ."\" has an issue" );
      }
    }
  }
}

#no issue
$np->nagios_exit ( OK, "GoogleApps service \"".$np->opts->service ."\" is running smoothly" );
exit;
