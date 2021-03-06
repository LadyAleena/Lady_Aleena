#!/usr/bin/perl
use strict;
use warnings FATAL => qw( all );

use CGI::Carp   qw(fatalsToBrowser);
use FindBin qw($Bin);
use List::Util  qw(sum min max);
use URI::Encode qw(uri_encode);

use lib "$Bin/files/lib";
use Page::File qw(file_list);
use Page::HTML qw(html head body heading paragraph list table anchor);
use Page::Menu qw(base_menu);
use Page::Path qw(base_path);
use Page::Link::Color qw(link_color);
use Page::Number::Pretty qw(pretty_number);

my $root_path = base_path('path');
my $root_link = base_path('link');

my @visible_files;
my %extensions;
my %file_sizes;
my $file_sizes_sum;
sub recurse {
  my ($directory, $visible) = @_;
  my @files = file_list($directory);

  for (@files) {
    my $new_visible = ($visible == 1 && $_ =~ /^(\p{uppercase}|index)/);
    my $full = "$directory/$_";
    if (-f $full) {
      if ($new_visible == 1) {
        (my $link = $full) =~ s/$root_path/$root_link/;
        push @visible_files, qq(https:$link);
      }
      my $extension = (split(/\./,$_))[-1];
      ++$extensions{$extension};
      my $file_size = -s $full;
      my $file = $full;
         $file =~ s/$root_path\///;
      $file_sizes{$file}{'bytes'} = $file_size;
      $file_sizes{$file}{'kilobytes'} = $file_size/1024;
      $file_sizes{$file}{'megabytes'} = ($file_size/1024)/1024;
      $file_sizes_sum += $file_size;
    }
    if (-d $full && !/^\./) {
      recurse($full, $new_visible);
    }
  }
}

recurse($root_path, 1);
my $extensions_sum   = sum(values %extensions);
my $extensions_types = keys %extensions;
my $file_sizes_total = keys %file_sizes;

my @ext_rows;
for my $key (sort keys %extensions) {
  my $value = $extensions{$key};
  my $color = link_color($key);
  push @ext_rows, [[$key, { 'style' => "$color" }],[$value, { 'class' => 'right' }]];
}

my @ext_end_rows;
push @ext_end_rows, ['Total files',[$extensions_sum,   { 'class' => 'right' }]];
push @ext_end_rows, ['Total types',[$extensions_types, { 'class' => 'right' }]];

my @size_rows;
for my $key (sort { $file_sizes{$b}{bytes} <=> $file_sizes{$a}{bytes} || $a cmp $b } keys %file_sizes) {
  my $bytes  = $file_sizes{$key}{bytes};
  my $kbytes = $file_sizes{$key}{kilobytes};
  my $mbytes = $file_sizes{$key}{megabytes};
  my $color  = link_color($key);
  my $link   = uri_encode($key);
     $key    =~ s!&!&amp;!g;
  push @size_rows, [anchor($key, { 'href' => $link, 'style' => $color }),
               map { [pretty_number($_, 5), { 'class' => 'right' }] } ($bytes,$kbytes,$mbytes)
              ];
}
my @tfoot_rows;
my $sum_bytes  =   $file_sizes_sum;
my $sum_kbytes =   $file_sizes_sum/1024;
my $sum_mbytes =  ($file_sizes_sum/1024)/1024;
my $avg_bytes  =   $file_sizes_sum/$file_sizes_total;
my $avg_kbytes =  ($file_sizes_sum/$file_sizes_total)/1024;
my $avg_mbytes = (($file_sizes_sum/$file_sizes_total)/1024)/1024;
push @tfoot_rows, ['Totals',   map { [pretty_number($_, 5), { 'class' => 'right' }] } ($sum_bytes,$sum_kbytes,$sum_mbytes)];
push @tfoot_rows, ['Averages', map { [pretty_number($_, 5), { 'class' => 'right' }] } ($avg_bytes,$avg_kbytes,$avg_mbytes)];

html(0, {
  'head' => {
    title => "Lady Aleena's file list",
    meta  => [
      {'charset' => 'utf-8'},
    ],
    style => ['
      body { font: normal 9pt arial, roboto, sans-serif; }

      a { text-decoration: none; }

      .left   { text-align: left; }
      .right  { text-align: right; }
      .center { text-align: center; }
      .updated::after { content: " updated"; vertical-align: unset; color: #000; }

      ul { padding-left:1em; }
      ul.main { -moz-column-count:4; -webkit-column-count:4; column-count:4; }
      ul.visi { -moz-column-count:3; -webkit-column-count:3; column-count:3; }
      ul ul { -moz-column-count:1; -webkit-column-count:1; column-count:1; }
      ul, ul ul ul ul, ul ul ul ul ul ul ul { list-style-type:disc; }
      ul ul, ul ul ul ul ul, ul ul ul ul ul ul ul ul { list-style-type:circle; }
      ul ul ul, ul ul ul ul ul ul, ul ul ul ul ul ul ul ul ul { list-style-type:square; }

      table { border-collapse: collapse; }
      tr:hover { background-color: #eee; }
      th.row_header { text-align:left; }
      th, td { border: 1px solid #ddd; }
      thead th { background:#eee9; }
      tfoot th { background:#eee9; }
      tbody th { background:#eee1; }
      tr:hover th { background-color: #eee; }
      ', { type => 'text/css' }
    ]
  },
  'body' => [
    sub {
      table(3, { 'rows' => [['header', [['Ext','Count']]], ['data', \@ext_rows], ['whead', \@ext_end_rows]], 'style' => 'float:right' });
      list(3,'u', base_menu( $root_path, { 'tab' => 2, 'color' => 1, 'full' => 1 } ), { 'class' => 'main' });
      heading(3, 2, 'Files by size');
      table(4, {
        'thead' => {
          'rows' => [['header', [[qw(File bytes kilobytes megabytes)]]]]
        },
        'tfoot' => {
          'rows' => [['whead', \@tfoot_rows]]
        },
        'rows' => [['whead', \@size_rows]],
      });
      heading(3, 2, 'Visible files');
      list(4, 'u', [sort @visible_files], { 'class' => 'visi' });
    }, { 'heading' => [1, "Lady Aleena's file list"] }
  ]
});

# open(my $file, '>', 'sitemap.txt') || die "Can't open sitemap.txt $!";
# print $file join("\n",sort @visible_files);