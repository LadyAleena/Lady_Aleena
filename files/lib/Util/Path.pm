package Util::Path;
use strict;
use warnings;
use Exporter qw(import);
our @EXPORT_OK = qw(base_path);

my $server = $ENV{SERVER_NAME} ? $ENV{SERVER_NAME} : 'localhost';
my $http   = $ENV{HTTPS} && $ENV{HTTPS} eq 'on' ? 'https' : 'http';

my %hosts = (
  'localhost' => {
    'path' => '/home/me/site',
    'link' => "//localhost",
  },
  'local.doc.www' => {
    'path' => '/home/me/Documents/www',
    'link' => "//local.doc.www",
  },
  'local.site' => {
    'path' => '/home/me/site',
    'link' => "//local.site",
  },
  'fantasy.xecu.net' => {
    'path' => '/www/fantasy/public_html',
    'link' => "//fantasy.xecu.net",
  }
);

my $root_path = $hosts{$server}{'path'};

for my $host (values %hosts) {
  $host->{$_}        = "$root_path/files/$_" for qw(data text);
  $host->{'imagesd'} = "$root_path/files/images";
  $host->{$_}        = $host->{'link'}."/files/$_" for qw(audio css images);
}

sub base_path {
  my ($host_key) = @_;
  return $hosts{$server}{$host_key};
}

1;