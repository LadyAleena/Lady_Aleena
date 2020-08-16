#!/usr/bin/perl
# This is the index for Role playing - Locations - Afma.
use strict;
use warnings FATAL => qw( all );

use CGI::Carp qw(fatalsToBrowser);
use CGI::Simple;
use HTML::Entities qw(encode_entities);

use lib '../../../files/lib';
use Page::Base     qw(page);
use Page::Menu     qw(file_menu);
use Page::Story    qw(story);
use Page::Line     qw(line);
use HTML::Elements qw(list anchor img);
use Util::Convert  qw(searchify);
use Util::Data     qw(file_directory file_list);
use Util::Sort     qw(article_sort);

my $cgi        = CGI::Simple->new;
my $page       = $cgi->param('page') ? encode_entities($cgi->param('page'),'/<>"') : undef;
my $pages_dir  = file_directory('Role_playing/Locations/Afma', 'text');
my @pages_list = file_list($pages_dir, { 'type' => 'f', 'uppercase' => 1, 'sort' => 'article' });
my @pages      = map  { $_ =~ s/\.txt//; $_ =~ s/_/ /g; $_ } @pages_list;
my $heading    = q(Afma);
my $page_file  = "$pages_dir/index.txt";
if ( $page && grep { $_ eq $page } @pages ) {
  $heading     = $page eq 'Aleena' ? 'Aleena, the Overpower of Afa and Afma' : $page;
  $page_file   = "$pages_dir/$page.txt";
  $page_file   =~ s/ /_/g;
}
open(my $page_fh, '<', $page_file) || die "Can't open $page_file. $!";

my $magic;
$magic->{'pages'} = sub {
  my $file_menu = file_menu('page', \@pages, $page);
  list(4, 'u', $file_menu);
};
$magic->{'flag'} = sub {
  line(6, img({ 'src' => '../../../files/images/flag.jpg', 'alt' => 'Aleenia flag', 'class' => 'right' }))
};

page(
  'heading' => $heading,
  'selected' => $page,
  'code' => sub {
    story($page_fh, { 'doc magic' => $magic, 'line magic' => $magic });
  }
);
