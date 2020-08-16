package Page::Xanth::Novel;
use v5.10.0;
use strict;
use warnings;
use Exporter qw(import);

use Lingua::EN::Inflect qw(NUMWORDS ORD);

use Page::Xanth::PageLinks qw(character_link timeline_link);
use Fancy::Open    qw(fancy_open);
use Fancy::Join    qw(join_defined);
use HTML::Elements qw(anchor);
use Util::Convert  qw(textify idify searchify);
use Util::Data     qw(data_file make_hash);

our $VERSION   = "1.0";
our @EXPORT_OK = qw(novel_link style_novel get_novels novel_nav novel_intro char_intro_novel current_year);

my @book_list = fancy_open(data_file('Fandom/Xanth', 'books.txt'));

my $novel_headings = [qw(Title main published year abbr)];
my $novels = make_hash(
  'file' => ['Fandom/Xanth', 'novels.txt'],
  'headings' => $novel_headings,
);

# Begin creating links and styles for books

sub novel_link {
  my $in = shift;

  my $search = searchify($in);
  my $class  = $in ne 'Other source' ? 'title' : undef;
  my $link   = anchor($in, { href => "Characters.pl?novel=$search", class => $class });

  return $link;
}

## Styles the books by character type in each novel

sub style_novel {
  my $in = shift;

  my $novel;
  if ($in =~ s/^M//) {
    $novel = "<b>".novel_link($book_list[$in])."</b>";
  }
  elsif ($in =~ s/^m//) {
    $novel = "<small>".novel_link($book_list[$in])."</small>";
  }
  else {
    $novel = novel_link($book_list[$in]);
  }

  return $novel;
}

sub get_novels {
  my $in = shift;

  my @novels = map { style_novel($_) } @$in;
  my $text   = "<strong>Novels:</strong> ".join(', ', @novels);

  return $text;
}

# End links and styles for books
# Start novel navigation.

sub previous_novel {
  my $number = shift;

  my $previous = $number > 1 ? $book_list[$number - 1] : undef;
  my $link     = $previous ? "&larr; ".novel_link($previous) : undef;

  return $link;
}

sub next_novel {
  my $number = shift;

  my $next     = $number < scalar @book_list ? $book_list[$number + 1] : undef;
  my $link     = $next ? novel_link($next)." &rarr;" : undef;

  return $link;
}

sub novel_nav {
  my $number = shift;

  my $previous = previous_novel($number);
  my $next     = next_novel($number);
  my $back     = anchor('Novels', { href => "Characters.pl#Novels" });
  my $nav      = join_defined(' &bull; ', ($previous, $back, $next));

  return $nav;
}

# End novel navigation.
# Start novel introduction.

sub novel_intro {
  my ($in_novel, $number) = @_;

  my $place  = NUMWORDS(ORD($number));
  my $novel  = $novels->{$in_novel};
  my $p_year = $novel->{published} ? $novel->{published} : undef;
  my $x_year = $novel->{year} ? timeline_link($novel->{year}) : '';
  my $main   = $novel->{main} ? character_link($novel->{main})." is the main character." : '';
  my $text   = "<b><i>$in_novel</i></b> ($p_year) is the $place novel in the Xanth series and starts in Xanthian year $x_year. $main";

  return $text;
}

# End novel introduction.
# Begin introduction type and novel for a character

sub char_intro_novel {
  my ($novel, $type, $novel_count) = @_;
  my $intro_novel  = novel_link($novel);
  my $intro_verb  = $type && $type eq 'mentioned' ? 'mentioned' : 'introduced';
  my $intro_type  = $novel_count > 1 ? "first $intro_verb" : $intro_verb;
     $intro_novel .= $type && $type eq 'major' ? ' as a major character' : '';
  my $intro_text  = "$intro_type in $intro_novel.";
  return $intro_text;
}

# End introduction type and novel for a character
# Begin getting the current Xanthian year

sub current_year {
  my $last_novel   = $book_list[-1];
  my $current_year = $novels->{$last_novel}->{year};
  return $current_year;
}

# End getting the current Xanthian year

=pod

=encoding utf8

=head1 VERSION

This document describes Page::Xanth::Novel version 1.0.

=head1 DEPENDENCIES

Page::Xanth::Novel depends on L<Fancy::Open>, L<Fancy::Join>, HTML::Elements, Util::Convert, Util::Data, Page::Xanth::Util, Page::Xanth::PageLinks, L<Lingua::EN::Inflect>, and L<Exporter>.

=head1 AUTHOR

Lady Aleena

=head1 LICENSE AND COPYRIGHT

This module is free software; you can redistribute it and/or modify it under the same terms as Perl itself. See L<perlartistic>.

Copyright © 2020, Lady Aleena C<<aleena@cpan.org>>. All rights reserved.

=cut

1;