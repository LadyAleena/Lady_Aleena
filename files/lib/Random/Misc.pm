package Random::Misc;
use v5.10.0;
use strict;
use warnings;
use Exporter qw(import);

use Fancy::Rand qw(fancy_rand);

our $VERSION   = '1.000';
our @EXPORT_OK = qw(
  random_misc
  random_emotion
  random_game
  random_generation
  random_group
  random_mental_condition
  random_non
  random_parent
  random_relationship
  random_sexual_orientation
  random_shadow
  random_sign
  random_zstuff
);

my %misc = (
  'emotions'            => [qw(joy sorrow trust fear love hate indifference)],
  'games'               => [map("$_ game", ('board', 'card', 'role-playing', 'video'))],
  'groups'              => [qw(group band cabal tribe caravan army)],
  'mental conditions'   => [
                             map("${_}active", qw(hypo hyper)),
                             map("$_ psychosis", qw(hallucinatory delusional)),
                             'addiction', 'amnesia', 'anxiety', 'catatonia', 'dementia', 'fugue', 'manic', 'melancholy',
                             'obsessive-compulsive', 'panic', 'paranoia', 'schizophrenia', 'split personality'
                           ],
  'non'                 => ['', 'non-'],
  'relationships'       => [qw(single dating attached engaged married divorced widowed)],
  'sexual orientations' => [qw(heterosexual heteroflexible bisexual homoflexible homosexual pansexual polysexual asexual)],
  'shadows'             => [qw(umbra penumbra antumbra)],
  'signs'               => [qw(+ -)],
  'zstuffs'             => [qw(thing doodad doohickey gizmo widget thingamabob stuff)],
);

sub random_misc {
  my ($user_misc, $user_additions) = @_;
  my $misc = fancy_rand(\%misc, $user_misc, { caller => 'random_misc', additions => $user_additions ? $user_additions : undef });
  return $misc;
}

sub random_emotion            { my $user_addition = shift; random_misc('emotions'           , $user_addition) }
sub random_game               { my $user_addition = shift; random_misc('games'              , $user_addition) }
sub random_group              { my $user_addition = shift; random_misc('groups'             , $user_addition) }
sub random_mental_condition   { my $user_addition = shift; random_misc('mental condition'   , $user_addition) }
sub random_non                { my $user_addition = shift; random_misc('non'                , $user_addition) }
sub random_relationship       { my $user_addition = shift; random_misc('relationships'      , $user_addition) }
sub random_sexual_orientation { my $user_addition = shift; random_misc('sexual orientations', $user_addition) }
sub random_shadow             { my $user_addition = shift; random_misc('shadows'            , $user_addition) }
sub random_sign               { my $user_addition = shift; random_misc('signs'              , $user_addition) }
sub random_zstuff             { my $user_addition = shift; random_misc('zstuffs'            , $user_addition) }

=pod

=encoding utf8

=head1 NAME

B<Random::Misc> returns random miscellaneous things.

=head1 VERSION

This document describes Random::Misc version 1.000.

=head1 SYNOPSIS

  use Random::Misc qw(
    random_misc
    random_emotion
    random_game
    random_group
    random_non
    random_relationship
    random_sexual_orientation
    random_shadow
    random_sign
    random_zstuff
  );

  my $emotion            = random_emotion;            # returns a random emotion
  my $game               = random_game;               # returns a random type of game
  my $group              = random_group;              # returns a random group type
  my $non                = random_non;                # returns either an empty string or non
  my $relationship       = random_relationship;       # returns a random relationship status
  my $sexual_orientation = random_sexual_orientation; # returns a random sexual orientation
  my $shadow             = random_shadow;             # returns a random shadow
  my $sign               = random_sign;               # returns either a + or a -
  my $zstuff             = random_zstuff;             # returns random stuff

  print random_misc('help') # get random_misc options

=head1 DESCRIPTION

Random::Misc is a catch all for lists that can not be classified as anything else. All of the functions must be imported into your script.

It requires Perl version 5.10.0 or better.

=head2 random_misc

=head3 Options

=head4 nothing, all, or undef

  random_misc;
  random_misc();
  random_misc('all');
  random_misc(undef);

These options return any value in any list. You can read the options below to see all of the potential values.

=head4 emotions

  random_misc('emotions');

The C<emotions> option returns fear, hate, indifference, joy, love, sorrow, or trust.

=head4 games

  random_misc('games');

The C<games> option returns board game, card game, role-playing game, or video game.

=head4 groups

  random_misc('groups');

The C<groups> option returns group, band, cabal, tribe, caravan, or army.

=head4 mental condition

  random_misc('mental condition');

The C<mental condition> option returns hypoactive, hyperactive, hallucinatory psychosis, delusional psychosis, addiction, amnesia, anxiety, catatonia, dementia, fugue, manic, melancholy, obsessive-compulsive, panic, paranoia, schizophrenia, or split personality. See L</NOTES>.

=head4 non

  random_misc('non');

The C<non> option returns non- or a zero-width string. This was written to make something a non- or not.

=head4 relationships

  random_misc('relationships');

The C<relationships> option returns single, attached, dating, engaged, married, divorced, or widowed.

=head4 sexual orientations

  random_misc('sexual orientations');

The C<sexual orientations> option returns heterosexual, heteroflexible, bisexual, homoflexible, homosexual, pansexual, polysexual, or asexual.

=head4 shadows

  random_misc('shadows');

The C<shadows> option returns umbra, penumbra, or antumbra.

=head4 signs

  random_misc('signs');

The C<signs> option returns + or -.

=head4 zstuffs

  random_misc('zstuffs');

The C<zstuffs> option returns thing, doodad, doohickey, gizmo, widget, thingamabob, or stuff.

=head4 by keys

  random_misc('by keys');

The C<by keys> option will select a random key listed above.

=head4 keys

  random_misc('keys');

The C<keys> option will list all of the available keys in an array reference.

=head4 data

  random_misc('data');

The C<data> option will return the data used in a hash reference.

=head4 help or options

  random_misc('help');
  random_misc('options');

The C<help> or C<options> options will return a list of all of your options.

=head3 Adding items to a list

  my @additions = ('misc 1', 'misc 2');
  random_misc('<your option>', \@additions);

You can add items to the list by adding an array reference with the additional items as the second parameter.

=head2 Specific functions

The following functions are shortcuts to the some of the options above. You can add items to the list by adding an array reference with the additional items as the first parameter in the following functions. If you want to add additional emotions in C<random_emotions>, you would do the following:

  my @emotion_additions = ('agony', 'bliss');
  random_emotion(\@emotion_additions);

=head3 random_emotion

 random_emotion();

C<random_emotion> is the same using L</emotions> in C<random_misc>.

=head3 random_game

 random_game();

C<random_game> is the same using L</games> in C<random_misc>.

=head3 random_generation

 random_generation();

C<random_generation> is the same using L</generations> in C<random_misc>.

=head3 random_group

 random_group();

C<random_group> is the same using L</groups> in C<random_misc>.

=head3 random_mental_condition

 random_mental_condition();

C<random_mental_condition> is the same using L</mental condition> in C<random_misc>.

=head3 random_non

 random_non();

C<random_non> is the same using L</non> in C<random_misc>.

=head3 random_parent

 random_parent();

C<random_parent> is the same using L</parents> in C<random_misc>.

=head3 random_relationship

 random_relationship();

C<random_relationship> is the same using L</relationships> in C<random_misc>.

=head3 random_sexual_orientation

 random_sexual_orientation();

C<random_sexual_orientation> is the same using L</sexual orientations> in C<random_misc>.

=head3 random_shadow

 random_shadow();

C<random_shadow> is the same using L</shadows> in C<random_misc>.

=head3 random_sign

 random_sign();

C<random_sign> is the same using L</signs> in C<random_misc>.

=head3 random_zstuff

 random_zstuff();

C<random_zstuff> is the same using L</zstuffs> in C<random_misc>.

=head1 DEPENDENCIES

Random::Misc depends on L<Fancy::Rand> and L<Exporter>.

=head1 NOTES

Random::Misc will be very fluid between versions. Items will be added to the lists. New lists will be added. Current lists can be moved into their own modules for better grouping should other similar lists be found.

Please know this module is for fun. The list for random mental conditions is not making light of real disorders that affect so many people. I am aware of the toll mental disorders take on people and their families.

=head1 SEE ALSO

L<Random::Thing>

=head1 AUTHOR

Lady Aleena

=head1 LICENCE AND COPYRIGHT

This module is free software; you can redistribute it and/or modify it under the same terms as Perl itself. See L<perlartistic>.

Copyright © 2020, Lady Aleena C<<aleena@cpan.org>>. All rights reserved.

=cut

1;