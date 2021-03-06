package Random::Body::Function;
use v5.10.0;
use strict;
use warnings;
use Exporter qw(import);

use Fancy::Rand qw(fancy_rand tiny_rand);
use Fancy::Join::Grammatical qw(grammatical_join);

our $VERSION   = '1.000';
our @EXPORT_OK = qw(random_body_function random_body_functions);

my %body_functions = (
  'sleep' => [
    'hardly ever wakes up',
    'needs to sleep twice as often',
    'needs to sleep half as often',
    'does not need to sleep',
    'is an insomniac',
    'is a narcoleptic',
    'must hibernate in the winter',
    'must estivate in the summer',
    'is unable to remember the past after sleeping'
  ],
  'bathe' => [
    'can not stop bathing',
    'needs to bathe twice as often',
    'needs to bathe half as often',
    'does not need to bathe',
    'bathes only in frigid water',
    'bathes only in boiling water',
    'is hairless after bathing'
  ],
  'eat' => [
    'can not stop eating',
    'needs to eat twice as much food',
    'needs to eat half as much food',
    'does not need to eat food',
    'is carnivorous',
    'is herbivorous',
    'is lethargic after eating any amount of food'
  ],
  'drink' => [
    'can not stop drinking',
    'needs to drink twice as much liquid',
    'needs to drink half as much liquid',
    'does not need to drink liquids',
    'is an alcoholic',
    'can not get drunk',
    'is intoxicated after injesting any liquid'
  ],
  'other' => [
    'can not stop sneezing',
    'can not stop crying',
    'breaks into song',
    'runs in circles'
  ]
);

sub random_body_function {
  my ($user_function, $user_additions) = @_;

  my $body_function;
  if (ref($user_function)) {
    my @functions;
    for my $function (@$user_function) {
      my $functioning = $function eq 'bathe' ? 'bathing' : $function.'ing';
      push @functions, fancy_rand(\%body_functions, $function, { caller => 'random_body_function', additions => [map("is ${_}active after $functioning", qw(hypo hyper))] });
    }
    $body_function = grammatical_join('and', @functions);
  }
  else {
    $body_function = fancy_rand(\%body_functions, $user_function, { caller => 'random_body_function', additions => $user_additions ? $user_additions : undef });
  }

  return $body_function;
}

sub random_body_functions {
  my @body_functions = (
    ['sleep'],
    ['bathe'],
    ['eat'],
    ['drink'],
    ['sleep','bathe'],
    ['sleep','eat'],
    ['sleep','drink'],
    ['bathe','eat'],
    ['bathe','drink'],
    ['eat','drink'],
    ['sleep','bathe','eat'],
    ['sleep','bathe','drink'],
    ['sleep','eat','drink'],
    ['bathe','eat','drink'],
    ['sleep','bathe','eat','drink']
  );
  my $functions = random_body_function(tiny_rand(@body_functions));

  return $functions;
}

=pod

=encoding utf8

=head1 NAME

B<Random::Body::Function> selects random body functions.

=head1 VERSION

This document describes Random::Body::Function version 1.000.

=head1 SYNOPSIS

  use Random::Body::Function qw(random_body_function random_body_functions);

=head1 DEPENDENCIES

Random::Body::Function depends on L<Fancy::Rand>, L<Fancy::Join::Grammatical>, and L<Exporter>.

=head1 AUTHOR

Lady Aleena

=head1 LICENSE AND COPYRIGHT

This module is free software; you can redistribute it and/or modify it under the same terms as Perl itself. See L<perlartistic>.

Copyright © 2020, Lady Aleena C<<aleena@cpan.org>>. All rights reserved.

=cut

1;