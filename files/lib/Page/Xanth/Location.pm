package Page::Xanth::Location;
use v5.10.0;
use strict;
use warnings;
use Exporter qw(import);

use Page::File qw(file_directory);
use Page::HTML qw(anchor);
use Page::Xanth::Util qw(get_article);
use Fancy::Open qw(fancy_open);
use Fancy::Join::Defined     qw(join_defined);
use Fancy::Join::Grammatical qw(grammatical_join);
use Util::Convert qw(textify idify searchify);

our $VERSION   = "1.0";
our @EXPORT_OK = qw(section_link location_link get_locations);

my $X_dir = file_directory('Fandom/Xanth');

my @moons_list = fancy_open("$X_dir/moons.txt");
my $moon_list = join('|', @moons_list);

my @worlds_list = fancy_open("$X_dir/worlds.txt");
my $world_list = join('|', @worlds_list);

sub section_link {
  my ($main, $section) = @_;

  my $text    = textify(join(', ', reverse split(/, /,$section)));
  my $id      = idify($section);
  my $link    = anchor($text, { href => "Characters.pl?location=$main#$id" });
  my $article = $main ne 'Mundania' ? get_article($section) : undef;
  my $section_text = join_defined(' ', ($article, $link));

  return $section_text;
}

sub location_link {
  my ($main, $section) = @_;

  my $text    = textify($main);
  my $search  = searchify($main);
  my $link    = anchor($text, { href => "Characters.pl?location=$search" });
  my $article = $main ne 'Mundania' ? get_article($main) : undef;
  my $main_text    = join_defined(' ', ($article, $link));
  my $section_text = $section ? section_link($search, $section) : undef;
  my $prep         = $main =~ /^($moon_list)$/ ? 'on' : 'in';
  my $place_text   = join_defined(" $prep ", ($section_text, $main_text));

  return $place_text;
}

sub get_locations {
  my $in_places = shift;
  my @out_places;
  for ( my $place_no = 0; $place_no < @$in_places; $place_no++ ) {
    my $curr_place = $in_places->[$place_no];
    my $next_place = $in_places->[$place_no + 1];
    if ($next_place && $curr_place->[0] eq $next_place->[0] && $curr_place->[1] ) {
      push @out_places, section_link($curr_place->[0], $curr_place->[1]);
    }
    else {
      push @out_places, location_link($curr_place->[0], $curr_place->[1]);
    }
  }
  my $place_text = grammatical_join('then', @out_places);
  return $place_text;
}

# Version 1.0
# Depends on Page::File, Page::HTML, Page::Xanth::Util, Util::Convert, Fancy::Join, Fancy::Open, and Exporter
# This module is free software; you can redistribute it and/or modify it under the same terms as Perl itself. See https://dev.perl.org/licenses/artistic.html.
# Copyright © 2020, Lady Aleena (aleena@cpan.org). All rights reserved.

1;