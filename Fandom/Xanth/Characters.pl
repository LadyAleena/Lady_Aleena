#!/usr/bin/perl
use strict;
use warnings FATAL => qw( all );

use CGI::Simple;
use CGI::Carp qw(fatalsToBrowser);
use FindBin qw($Bin);
use Lingua::EN::Inflect qw(PL_V NO);
use Lingua::EN::Inflexion qw(noun);
use List::SomeUtils qw(first_index);

use lib "$Bin/../../files/lib";
use Page::Base qw(page);
use Page::Data qw(make_hash);
use Page::File qw(file_directory);
use Page::HTML qw(section nav paragraph list details anchor);
use Page::Columns qw(number_of_columns);
use Page::Convert qw(idify);
use Page::CGI::Param qw(get_cgi_param);
use Page::List::Alpha qw(alpha_hash alpha_menu);
use Page::Number::Pretty   qw(commify);
use Page::Xanth::Character qw(get_open get_character);
use Page::Xanth::Location  qw(location_link get_locations get_moon);
use Page::Xanth::Novel     qw(novel_link novel_nav novel_intro current_year);
use Page::Xanth::PageLinks qw(character_link locations_page_link timeline_link);
use Page::Xanth::Species   qw(species_link get_species);
use Page::Xanth::Util      qw(gendering get_article);
use Fancy::Join::Grammatical qw(grammatical_join);
use Fancy::Open   qw(fancy_open);

# Begin importing data

my $X_dir = file_directory('Fandom/Xanth');
my $character_headings  = [qw(Name species+ gender places+ talent other book chapter)];
my $group_headings      = [qw(Name group title)];
my $date_headings       = [qw(Name birth death), 'cause of death', 'killer'];
my $suspension_headings = [qw(Name begin end), 'begin event', 'end event'];
my $reage_headings      = [qw(Name age year event)];
my $family_headings     = [qw(Name mother+ father+ sibling+ multisibling+ pibling+ nibling+ cousin+ ancestor+ descendant+ other+)];
my $partner_headings    = [qw(Name spouse+ widowed+ exspouse+ dating+ exdating+ lover+ exlover+)];
my $challenge_headings  = [qw(Name number querant)];
my $moon_headings       = [qw(moon after before), 'after between', 'before between', 'novel'];

my $characters   = make_hash( 'file' => "$X_dir/characters.txt",       'headings' => $character_headings );
my $see_char     = make_hash( 'file' => "$X_dir/see_character.txt" );
my $groups       = make_hash( 'file' => "$X_dir/groups.txt",           'headings' => $group_headings );
my $dates        = make_hash( 'file' => "$X_dir/dates.txt",            'headings' => $date_headings );
my $suspensions  = make_hash( 'file' => "$X_dir/dates-suspension.txt", 'headings' => $suspension_headings );
my $reages       = make_hash( 'file' => "$X_dir/dates-reage.txt",      'headings' => $reage_headings );
my $families     = make_hash( 'file' => "$X_dir/families.txt",         'headings' => $family_headings );
my $partners     = make_hash( 'file' => "$X_dir/partners.txt",         'headings' => $partner_headings );
my $challenges   = make_hash( 'file' => "$X_dir/challenges.txt",       'headings' => $challenge_headings );
my $moons        = make_hash( 'file' => "$X_dir/moons_data.txt",       'headings' => $moon_headings );
my @unnamed_list = fancy_open("$X_dir/unnamed.txt");
my @book_list    = fancy_open("$X_dir/books.txt");
my @gendered_species_list = fancy_open("$X_dir/gendered_species.txt");
my $gendered_species_text = grammatical_join('and', sort @gendered_species_list);

# End importing data
# Begin data crunching

my $species_lists;
my $location_lists;
my $novel_lists;

for my $key ( keys %$characters ) {
  my $character = $characters->{$key};
  my $name      = $character->{Name};

  # Begin munging the character.
  # Begin further splitting of the character's location(s).

  my $places = [map { [split(/, /, $_, 2)] } @{$character->{places}}];
  $character->{places} = $places;

  # End splitting the character's location(s).
  # Begin getting character's introductory novel.

  my @novels = split(/, /, $character->{book});
  my $first_book = $novels[0];
  my $first_type = $first_book =~ /^M/ ? 'major' : $first_book =~ /^m/ ? 'mentioned' : undef;
     $first_book =~ s/\D//g;
  $character->{intro}->{book} = $book_list[$first_book];
  $character->{intro}->{type} = $first_type;
  $character->{book} = \@novels;

  # End getting character's introductory novel.
  # Begin getting if character has a main entry.

  $character->{see} = $see_char->{$name} if $see_char->{$name};

  # End getting if character has a main entry.
  # If this is not the character's main entry, go to next character.

  next if $character->{see};

  # Begin getting the character's title and group, if any.

  if ($groups->{$name}) {
    $character->{title} = $groups->{$name}->{title} if $groups->{$name}->{title};
    $character->{group} = $groups->{$name}->{group} if $groups->{$name}->{group};
  }

  # End getting the character's title and group.
  # Begin getting the character's dates.

  if ($dates->{$key}) {
    $character->{dates}->{$_}          = $dates->{$key}->{$_}  for grep { !/Name/ } @$date_headings;
  }
  if ($suspensions->{$key}) {
    push @{$character->{dates}->{suspension}}, $suspensions->{$key};
  }
  if ($suspensions->{"$key 1"}) {
    push @{$character->{dates}->{suspension}}, $suspensions->{"$key 1"};
  }
  if ($reages->{$key}) {
    $character->{dates}->{reage}->{$_} = $reages->{$key}->{$_} for grep { !/Name/ } @$reage_headings;
  }

  # End getting the character's dates.
  # Begin getting the character's family.

  if ($families->{$name}) {
    for my $relation ( map { s/\+//; $_ } grep { !/Name/ } @$family_headings ) {
      if ( $families->{$name}->{$relation} ) {
        $character->{family}->{$relation} = $families->{$name}->{$relation};
      }
    }
    for my $parent_type (qw(mother father)) {
      my $parent = $character->{family}->{$parent_type} ? $character->{family}->{$parent_type} : undef;
      if ($parent) {
        for my $push_parent (@$parent) {
          if ($characters->{$push_parent}) {
            push @{$characters->{$push_parent}->{family}->{children}}, $name;
          }
        }
      }
    }
  }

  # Begin getting character's partners

  if ($partners->{$name}) {
    for my $relation ( map { s/\+//; $_ } grep { !/Name/ } @$partner_headings ) {
      if ( $partners->{$name}->{$relation} ) {
        $character->{family}->{$relation} = $partners->{$name}->{$relation};
      }
    }
  }

  # End getting character's partners
  # End getting character's family
  # Begin getting when character was a challenge

  if ($challenges->{$name}) {
    my $challenge = $challenges->{$name};
    $character->{challenge}->{number} = $challenge->{number};
    $character->{challenge}->{querant} = $challenge->{querant};
  }

  # End getting when character was a challenge
  # Begin populating the other lists of characters.
  # Being populating the novel lists.

  for my $book (@novels) {
    my $book_num = $book;
       $book_num =~ s/\D//g;
    if ($book =~ /M\d+/) {
      push @{$novel_lists->{$book_list[$book_num]}->{Major}}, $name;
    }
    elsif ($book =~ /m\d+/) {
      push @{$novel_lists->{$book_list[$book_num]}->{Mentioned}}, $name;
    }
    else {
      push @{$novel_lists->{$book_list[$book_num]}->{Minor}}, $name;
    }
  }

  # End populating the novel lists.
  # Begin populating the location lists.

  for my $place (@$places) {
    if ($place->[0] && $place->[1]) {
      push @{$location_lists->{$place->[0]}->{$place->[1]}}, $name;
    }
    else {
      push @{$location_lists->{$place->[0]}->{'main'}}, $name;
    }
  }

  # End populating the location lists.
  # Begin populating the species lists.

  for my $speci (@{$character->{species}}) {
    my ($base_species, $sub_species) = split(/, /, $speci);
    push @{$species_lists->{$base_species}}, $name;
  }

  # End populating the species lists.
  # End populating the other lists of characters.
  # End munging the character.
}

for my $unnamed (@unnamed_list) {
  for my $parent_type (qw(mother father)) {
    my $parent = $families->{$unnamed}->{$parent_type} ? $families->{$unnamed}->{$parent_type} : undef;
    if ($parent) {
      for my $push_parent (@$parent) {
        if ($characters->{$push_parent}) {
          push @{$characters->{$push_parent}->{family}->{children}}, $unnamed;
        }
      }
    }
  }
}

# End data crunching
# Begin outputting

my $cgi = CGI::Simple->new;
my $select_character = get_cgi_param($cgi, 'character');
my $select_alpha     = get_cgi_param($cgi, 'alpha');
my $select_novel     = get_cgi_param($cgi, 'novel');
my $select_location  = get_cgi_param($cgi, 'location');
my $select_species   = get_cgi_param($cgi, 'species');

my $browse_alpha = alpha_hash($characters, {article => 'no'});
sub alpha_with_rand_character {
  my @character_list = keys %$characters;
  my $rand_character = $character_list[rand @character_list];
  my $character_link = character_link($rand_character, 'Random character');
  my $alpha_menu = alpha_menu($browse_alpha, { 'param' => 'alpha', 'join' => ' | ', addition => "&nbsp;".$character_link });
  return $alpha_menu;
}

my $head = $select_character && $characters->{$select_character} && $groups->{$select_character}->{title} ? "$groups->{$select_character}->{title} $select_character" :
           $select_character && $characters->{$select_character}  ? "$select_character" :
           $select_alpha     && $browse_alpha->{uc $select_alpha} ? "Characters: ". uc $select_alpha :
           $select_novel     ? "<i>$select_novel</i> characters" :
           $select_location  ? "Characters from ".get_article($select_location, { full => 1}) :
           $select_species   ? ucfirst "$select_species characters" : 'Characters of Xanth';

page( 'heading' => [$head, { 'html' => 1 }], 'code' => sub {
  if ($select_character && $characters->{$select_character}) {
    my $character = $characters->{$select_character};
    my $character_text = get_character($character);
    section(3, sub {
      paragraph(4, @$_) for @$character_text;
    });
  }
  elsif ($select_alpha && $browse_alpha->{uc $select_alpha}) {
    my $alpha = $browse_alpha->{uc $select_alpha};
    my $list;
    for my $key ( sort keys %$alpha ) {
      my $character = $characters->{$key};
      my $text = get_open($character, { link => 'yes' });
      push @{$list}, $text;
    }
    section(3, sub {
      nav(4, "Xanth characters: ".alpha_with_rand_character, { 'class' => 'alpha_menu' });
      list(4, 'u', $list, { style => 'line-height: 1.5' });
    });
  }
  elsif ($select_novel) {
    my $number      = first_index { $_ eq $select_novel } @book_list;
    my $novel_nav   = novel_nav($number);
    my $novel_intro = novel_intro($select_novel, $number);

    section(3, sub {
      paragraph(4, $novel_intro) if ($select_novel ne 'Other source');
    });
    for my $type ('Major', 'Minor', 'Mentioned') {
      if ($novel_lists->{$select_novel}->{$type}) {
        my @characters = @{$novel_lists->{$select_novel}->{$type}};
        my $col  = number_of_columns(4, scalar @characters, 'yes');
        my $list = [map { character_link($_) } sort @characters];
        section(3, sub {
          list(4, 'u', $list, { class => $col });
        }, { heading => $select_novel ne 'Other source' ? [2, "$type characters"] : undef });
      }
    }
    section(3, sub {
      nav(4, $novel_nav, { class => 'alpha_menu', style => 'text-align:center' });
    });
  }
  elsif ($select_location) {
    my $locations = $location_lists->{$select_location};
    my $total_count;
    for my $key (keys %$locations) {
      my $location = $locations->{$key};
      $total_count += scalar(@{$location});

      my $list = [ map {
        my $species = get_species($characters->{$_}->{species}, $characters->{$_}->{gender});
        my $link    = character_link($_);
        "$link is $species."
      } sort @{$location} ];
      $locations->{$key} = $list;
    }

    my $plural_verb   = PL_V('is', $total_count);
    my $worded_count  = NO('character', $total_count, { words_below => 101, comma_every => 3 });
    my $location_link = locations_page_link($select_location);
    my $location_para = "There $plural_verb $worded_count from $location_link.";
    if ($moons->{$select_location}) {
      my $moon_line = get_moon($moons->{$select_location});
      $location_para .= " $moon_line";
    }
    section(3, sub {
      paragraph(4, $location_para);
    });

    if ($locations->{main}) {
      my $list = $locations->{main};
      my $col  = number_of_columns(3, scalar @{$list}, 'yes');
      section(3, sub {
        list(4, 'u', $list, { class => $col });
      });
    }
    for my $section ( sort grep { !/main/ } keys %$locations ) {
      my $text  = get_article($section, { full => 1 });
      my $id    = idify($section);
      my $list  = $locations->{$section};
      my $count = scalar @{$list};
      my $col   = number_of_columns(3, $count, 'yes');

      my $pl_verb       = PL_V('is', $count);
      my $pl_characters = NO('character', $count, { words_below => 101 });
      my $link  = locations_page_link($select_location, $section);

      section(3, sub {
        paragraph(4, "There $pl_verb $pl_characters from $link.");
        list(4, 'u', $list, { class => $col });
      }, { heading => [ 2, ucfirst $text, { id => $id } ] } );
    }
  }
  elsif ($select_species) {
    my $list = [ map {
      my $location = get_locations($characters->{$_}->{places});
      my $link     = character_link($_);
      "$link is from $location."
    } sort @{$species_lists->{$select_species}} ];
    my $count   = scalar @{$list};
    my $species = $count > 1 && $select_species !~ /folk$/ ? noun($select_species)->classical->plural :
                  $count > 1 && $select_species =~ /folk$/ ? $select_species :
                  noun($select_species)->indefinite;
    my $worded_count = noun($count)->cardinal;
    my $columns = number_of_columns(2, $count, 'yes');
    section(3, sub {
      paragraph(4, "There are $worded_count $species.") if $count > 1;
      paragraph(4, "This character is $species.") if $count == 1;
    });
    section(3, sub {
      list(4, 'u', $list, { class => $columns });
    });
  }
  else {
    my $character_count = commify(scalar(keys %$characters) - scalar(keys %$see_char));
    my $current_year  = timeline_link(current_year);
    my $show_list     = [map { novel_link($_) } @book_list];
    my $location_list = [map { ucfirst location_link($_) } sort keys %$location_lists];
    my $species_list  = [map { species_link($_, ucfirst $_) } sort { lc $a cmp lc $b } keys %$species_lists];

    section(3, sub {
      paragraph(4, qq(Welcome to Lady Aleena's list of <b>characters of <i>Xanth</i></b>. It covers all $character_count characters from <a href="http://www.hipiers.com/chartcnac.html"><i>Xanth</i> Character Database</a> by Douglas Harter. The year is $current_year in Xanth.));
      paragraph(4, qq(See the <a href="#Notes">notes</a> below.));
      nav(4, "Xanth characters: ".alpha_with_rand_character, { 'class' => 'alpha_menu' });
    });
    section(3, sub {
      paragraph(4, 'You can browse character lists by novel.');
      list(4, 'o', $show_list, { class => 'three', start => '0' });
    }, { heading => [2, 'Novels', { id => 'Novels' }] });
    section(3, sub {
      paragraph(4, 'You can browse character lists by location. Most characters are from Xanth, so the list for it is very long.');
      list(4, 'u', $location_list, { class => 'four' });
    }, { heading => [2, 'Locations', { id => 'Locations' }] });
    section(3, sub {
      paragraph(4, 'You can browse character lists by species. The majority of characters are human, so the list for them is very long.');
      list(4, 'u', $species_list, { class => 'five' });
    }, { heading => [2, 'Species', { id => 'Species' }] });
  }
  section(3, sub {
    details(4, sub {
      paragraph(4, qq(Human men and women will not have a species in their entries. Also, if the surname of the character is the character's species, it was dropped.::If the character is a child, it will be in the description. The child will more than likely be an adult by this time in the <i>Xanth</i> series.::Many species are single gender, so their entries will not mention it. The species are $gendered_species_text. Harpies and nymphs are usually female, and fauns are usually male; but there have been a few exceptions that are noted.::In some instances, I have made educated guesses on gender, species, and some birth years.), { separator => '::' });
    }, { 'summary' => 'Notes' });
    nav(4, "Xanth characters: ".alpha_with_rand_character, { 'class' => 'alpha_menu' });
  }, { heading => [2, 'Character notes', { id => 'Notes' }] });
});

# End outputting