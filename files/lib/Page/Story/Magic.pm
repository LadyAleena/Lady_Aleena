package Page::Story::Magic;
use v5.8.8;
use strict;
use warnings;
use Exporter qw(import);
our @EXPORT_OK = qw(program_magic pc_magic story_magic);

use File::Spec;

use Fancy::Open   qw(fancy_open);
use Page::Path    qw(base_path);
use Util::Convert qw(idify);
use Util::Data    qw(data_file make_hash);

sub program_magic {
  my $program_urls = make_hash( 'file' => ['Collections','programs.txt'] );
  my $program_links;
  for my $link (keys %$program_urls) {
    my $link_dest = $program_urls->{$link};
    $program_links->{$link} = qq(A<$link|href="http://$link_dest" target="ex_tab">);
  }

  return $program_links;
}

# End Program links
# Start Player character magic
# to be used on any story involving my player characters

sub pc_magic {
  my @pcs = fancy_open(data_file('Role_playing','player_characters_list.txt'));

  my $pc_links;
  for my $pc (@pcs) {
    my $root = base_path('path');
    my $id   = idify($pc);
    my $path = File::Spec->abs2rel("$root/Role_playing/Player_characters/index.pl#$id");
    $pc_links->{$pc} = qq(A<$pc|href="$path">);

    my ($first, $last) = split(' ', $pc, 2);
    $pc_links->{$first} = qq(A<$first|href="$path">);
  }

  return $pc_links;
}

# End Player character magic
# Bring the magic!

sub story_magic {
  my $magic = {
    %{&program_magic},
    %{&pc_magic}
  };
  return $magic;
}

=pod

=encoding utf8

=head1 AUTHOR

Lady Aleena

=head1 LICENSE AND COPYRIGHT

This module is free software; you can redistribute it and/or modify it under the same terms as Perl itself. See L<perlartistic>.

Copyright © 2020, Lady Aleena C<<aleena@cpan.org>>. All rights reserved.

=cut

1;