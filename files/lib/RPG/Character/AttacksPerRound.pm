package RPG::Character::AttacksPerRound;
use strict;
use warnings;
use Exporter qw(import);
our @EXPORT_OK = qw(attacks_per_round);

use POSIX qw(floor);

use RPG::Character::Class qw(convert_class class_level);

my %classes;
$classes{'warrior'}      = 6;
$classes{'chaos warden'} = 8;

sub attacks_per_round {
  my ($class, $opt) = @_;
  $class = convert_class($class,'AttacksPerRound');
  my $level = $opt->{'level'} ? $opt->{'level'} : class_level($class, $opt->{'experience'});

  $class = 'warrior' if $class =~ /(?:fighter|paladin|ranger)/;

  my $attacks = 1;
  if ($classes{$class}) {
    my $mod = .5 * floor($level / $classes{$class});
    $attacks += $mod;

    if ($attacks != int($attacks)) {
      $attacks *= 2;
      $attacks .= '/2';
    }
  }

  return $attacks;
}

=pod

=encoding utf8

=head1 NAME

B<RPG::Character::AttacksPerRound> returns the amount of attacks characters can make in combat. Most classes receive only 1 attack per round with only B<warriors> and B<chaos wardens> (a new class of my creation) receiving more as they advance in level.

=head1 DESCRIPTION

To use this module to return the slots needed, use the following. C<attacks_per_round> is exported by default.

  use RPG::Character::AttacksPerRound;

=head2 Getting attacks per level

To get the number of attacks per round a character has, you will need the character's class and level or experience.

  my $attacks_per_round = attacks_per_round($class, { 'level' => $level });
  my $attacks_per_round = attacks_per_round($class, { 'experience' => $xp });

C<attacks_per_round> will return C<1> for any class other than C<warrior> or C<chaos warden> because that is all your character gets. If you see a fraction returned, it means you get the first number of attacks every two rounds.

=head1 NOTE

Rules used for C<AttacksPerRound> for B<warriors> levels 13 and below are standard, however the levels beyond it are house rules and not in any book.

=head1 AUTHOR

Lady Aleena

=head1 LICENCE AND COPYRIGHT

This module is free software; you can redistribute it and/or modify it under the same terms as Perl itself. See L<perlartistic>.

Copyright © 2020, Lady Aleena C<<aleena@cpan.org>>. All rights reserved.

=cut

1;