package Math::TotalBuilder;

our $VERSION = 0.02;

=head1 NAME

Math::TotalBuilder -- build a whole total out of valued pieces

=head1 SYNOPSIS

 use Math::TotalBuilder;

 my %lsd = ( pound => 240, shilling => 20, penny => 1 );

 # units for 952 pence
 my %tender = build(\%lsd, 952);

 # total value of 3, 21, 98
 my $wealth = total(\%lsd, { pound => 3, shilling => 21, penny => 98 });

 # best better representation of 18, 6, 40
 my %moolah = build(\%lsd,
   total (\%lsd, { pound => 18, shilling => 6, penny => 40 }));

=head1 DESCRIPTION

This module provides two subroutines, C<build> and C<total>, which can be used
to handle quantities of valued items.  These can be used to build the proper
tender to represent a quantity of money, to compose a mass from standard
weights, to convert a difference of seconds to a set of time units, or other
similar calculations.

=cut

use strict;

use base qw(Exporter);

our @EXPORT = qw(build total);

=head1 Subroutines

=over

=item C< build(\%pieces, $total) >

  my %nicetime = build (
    { days => 86400, hours => 3600, minutes => 60, seconds => 1 },
	39102
  );

This routine takes a hash of valued units and a total, and it returns the
quantity of each unit required to build that total.  If the total can't be
cleanly built, the routine will return a set that builds the nearest total it
can, without going over.  A special value, C<_remainder> will indicate by how
many units it fell short.

This module does not solve the knapsack problem, and hardly tries.  It may fail
to provide a solution for solveable instances, like this:

 my $difficult = build (
   { kroener => 30, talen => 7 },
   49
 ); 
 # yields { kroener => 1, talen => 2, _remainder => 5 }
 # not    { talen => 7 }

Future revisions may grow better.

=cut

sub build {
  my ($pieces, $total) = @_;

  return unless $total;

  my %result;

  for (sort { $pieces->{$b} <=> $pieces->{$a} } keys %$pieces) {
	next unless $pieces->{$_} <= $total;
	$result{$_} = int( $total / $pieces->{$_} );
	$total -= $result{$_} * $pieces->{$_};
  }

  $result{_remainder} = $total if $total;

  return %result;
}

=item C< total(\%pieces, \%set) >

 my $total = total(
   { ten => 10, five => 5, one => 1 },
   { ten =>  2, five => 6 }
 ); # returns 50

This routines returns the total value of the units in C<%set>, valued according
to the definition in %pieces.

=cut

sub total {
  my ($pieces, $set) = @_;
  my $total;
  for (keys %$set) {
	die "invalid unit type: $_" unless exists $pieces->{$_};
	$total += $set->{$_} * $pieces->{$_};
  }
  $total;
}

=back

=head1 NOTES

This module is hardly ready for use.  It needs much more error-handling.  The
sub names may be changed in the future to avoid conflict, since they're very
simple names, but probably not.  (If so, the current names will remain
exportable.)

=head1 TODO

=over

=item *

Use subrefs for ever-extending pieces.  (I<e.g.>, "powers of two")

=item *

Allow building a total from a given set of source units.  ("I have this many
units to try and build into this total.  Can I?")

=item * 

Allow for useful handling of pieces-sets with multiple pieces of the same
value: always use one, randomly distribute, etc.

=item * 

Allow use of bigfloats so that the smallest value need not be the base value.

=item *

Collect common units into a module.

=item *

Provide an option to try harder to build totals.

=back

=head1 AUTHOR

Ricardo SIGNES, C<< E<lt>rjbs@cpan.orgE<gt> >>

=head1 COPYRIGHT

This is free software, and can be distributed under the same terms as perl
itself.

=cut

"Here's your change.";
