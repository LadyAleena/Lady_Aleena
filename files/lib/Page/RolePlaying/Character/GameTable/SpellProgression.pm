package Page::RolePlaying::Character::GameTable::SpellProgression;
use v5.8.8;
use strict;
use warnings;
use Exporter qw(import);
our @EXPORT_OK = qw(spell_progression spell_progression_table_rows);

use List::Util qw(max);

use Page::Data qw(make_hash);
use Page::File qw(file_directory);
use Page::RolePlaying::Character::Class qw(convert_class class_level);

# part of the Character Building table suite.

# my @classes = qw(wizard priest paladin ranger bard theopsyelementalist);

sub spell_progression {
  my ($class, $opt) = @_;

  my $spell_progression;
  if (ref($class) eq 'ARRAY') {
    for (@{$class}) {
      $spell_progression->{$_} = spell_progression($_, $opt);
    }
  }
  else {
    $class = convert_class($class, 'SpellProgression');
    my $level = $opt->{'level'} ? $opt->{'level'} : class_level($class, $opt->{'experience'});
    my $directory = file_directory('Role_playing/Classes/Spell_progression');
    my $file = "$directory/$class.txt";

    if (-f $file) {
      my $spell_progression_table = make_hash( 'file' => $file, 'headings' => ['level',1..9] );
      my $max_available_level = max(keys %$spell_progression_table);
      if ($level > $max_available_level) {
        $level = $max_available_level;
        $spell_progression_table->{$level}{'note'} = "I only have spell progression up to level $level.";
      }
      $spell_progression = $spell_progression_table->{$level};
    }
  }

  return $spell_progression ? $spell_progression : undef;
}

sub spell_progression_table_rows {
  my %opt = @_;
  my $name    = $opt{'name'};
  my $classes = $opt{'classes'};

  my $spell_progression = spell_progression($classes, { 'experience' => $opt{'experience'} });
  my @classes = grep( defined( $$spell_progression{$_} ), @$classes );

  my @headings = ('Level', map( ucfirst, @classes ));
  my @data_rows;
  for my $level (1..9) {
    my @spells = map(defined $$spell_progression{$_}{$level} ? $$spell_progression{$_}{$level} : '', @classes);
    push @data_rows, [$level,@spells] if grep(length,@spells);
  }

  my @rows = (
    [ 'header', [\@headings] ],
    [ 'whead', \@data_rows ]
  );
  my $colspan = scalar(@classes) + 1;
  if ($opt{'spellbook'}) {
    my $spellbook = $opt{'spellbook'};
    push @rows, [ 'header', [[['Spellbook', { 'colspan' => $colspan }]]] ];
    push @rows, [ 'data', [[[$spellbook, { 'colspan' => $colspan }]]] ];
  }

  return \@rows;
}

# This module is free software; you can redistribute it and/or modify it under the same terms as Perl itself. See https://dev.perl.org/licenses/artistic.html.
# Copyright © 2020, Lady Aleena (aleena@cpan.org). All rights reserved.

1;