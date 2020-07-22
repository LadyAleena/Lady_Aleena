package Util::MonthNumber;
use v5.8.8;
use strict;
use warnings FATAL => qw( all );
use Exporter qw(import);

our $VERSION   = '1.0';
our @EXPORT_OK = qw(month_number);

my %month_names = (
  'English'      => [qw(January February March April May June July August Spetember October November December)],
  'English abbr' => [qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Now Dec)],
  'Dutch'        => [qw(januari februari maart april mei juni juli augustus september oktober november december)],
  'French'       => [qw(janvier f�vrier mars avril mai juin juillet ao�t septembre octobre novembre d�cembre)],
  'German'       => [qw(Januar Februar M�rz April Mai Juni Juli August September Oktober November Dezember)],
  'Greek'        => [qw(Ianu�rios Fevru�rios M�rtios Apr�lios M�ios I�nios I�lios Avghustos Sept�mvrios Okt�vrios No�mvrios Thek�mvrios)],
  'Italian'      => [qw(gennaio febbraio marzo aprile maggio giugno luglio agosto settembre ottobre novembre dicembre)],
  'Spanish'      => [qw(enero febrero marzo abril mayo junio julio agosto septiembre octubre noviembre diciembre)],
);

my %months;
for my $language (keys %month_names) {
  my $number = 0;
  $months{lc $_} = ++$number for @{$month_names{$language}};
}

sub month_number {
  my $month = lc shift;
  return $months{$month};
}

=pod

=encoding utf8

=head1 Util::MonthNumber

B<Util::MonthNumber> returns the number for a month.

=head2 Version

This document describes Util::MonthNumber version 1.0.

=head2 Synopsis

  use Util::MonthNumber qw(month_number);

  my $month_number = month_number('July');
  # 7

=head2 Description

Util::MonthNumber returns the number of the month entered. The languages supported are English and the English abbreviations, Dutch, French, German, Greek, Italian, and Spanish.

=head2 Dependency

Util::MonthNumber depends on L<Exporter>.

=head2 Author

Lady Aleena

=cut

1;