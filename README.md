nagios-googleapps
=================

a simple nagios plugins that checks the google apps services status from the dashboard

The initial version is heavily borrowed from here:
http://gurucollege.net/technology/nagios-check-plugin-for-google-app-dashboard/

## Requirements
Required perl modules:
- Nagios::Plugin;
- JSON::PP.


## Usage
usage: ./check_googleapps.pl -s|--service $service [ -w|--warning -h|--help ]

where:
- $service is the service name (as taken from the status dashboard: http://www.google.com/appsstatus)

The --warning switch can be used if you'd like the plug-in to give you warning instead of critical when services are unavailable.

## Todo
- Implement -h