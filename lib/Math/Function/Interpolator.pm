package Math::Function::Interpolator;

use 5.006;
use strict;
use warnings FATAL => 'all';

use Moo;
with qw(MooX::Traits);

use Carp qw(confess);
use Scalar::Util qw(looks_like_number);

use Number::Closest::XS qw(find_closest_numbers_around);
use List::MoreUtils qw(pairwise indexes);
use List::Util qw(min max);

use Module::Runtime;
use Module::Pluggable
  sub_name    => 'interpolate_methods',
  search_path => ['Math::Function::Interpolator'],
;

=head1 NAME

Math::Function::Interpolator - Interpolation made easy

=head1 VERSION

Version 0.05

=head1 SYNOPSIS

    use Math::Function::Interpolator;

    my $interpolator = Math::Function::Interpolator->new(
        points => {1=>2,2=>3,3=>4}
    );

    $interpolator->linear(2.5);

    $interpolator->quadratic(2.5);

    $interpolator->cubic(2.5);

=head1 DESCRIPTION

Math::Function::Interpolator helps you to do the interpolation calculation with linear, quadratic and cubic methods.

=head1 FIELDS

=head2 points (REQUIRED)

HashRef of points for interpolations

=cut

our $VERSION = '0.05';

# Automatically load all interpolate methods
has 'interpolate_classes' => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        my @modules = $self->interpolate_methods();
        foreach my $module (@modules) {
            Module::Runtime::require_module($module);
        }
        return 1;
    }
);

has points => (
    is       => 'ro',
    isa      => sub {
        die "Points $_[0] shold be hash" unless ref $_[0] eq 'HASH';
    },
    required => 1,
);

=head1 METHODS

=head2 BUILDARGS

BUILDARGS

=cut

sub BUILDARGS {    ## no critic (Subroutines::RequireArgUnpacking)
    my $self = shift;
    my %args = ref( $_[0] ) ? %{ $_[0] } : @_;

    # We can't interpolate properly on undef values so make sure we know
    # they are missing by removing them entirely.
    my $points = $args{points};
    $args{points} = {
        map { $_ => $points->{$_} }
        grep { defined $points->{$_} } keys %$points
    };

    return \%args;
}

=head2 linear

This method do the linear interpolation. It solves for point_y linearly given point_x and an array of points.

=cut

sub linear {
    my ( $self, $x ) = @_;
    confess "point_x must be numeric" if !looks_like_number($x);
    $self->interpolate_classes();
    return Math::Function::Interpolator->with_traits(
        'Math::Function::Interpolator::Linear')->new( interpolate => $self )
      ->do_calculation($x);
}

=head2 quadratic

This method do the quadratic interpolation. It solves the interpolated_y value given point_x with 3 data points.

=cut

sub quadratic {
    my ( $self, $x ) = @_;
    confess "point_x must be numeric" if !looks_like_number($x);
    $self->interpolate_classes();
    return Math::Function::Interpolator->with_traits(
        'Math::Function::Interpolator::Quadratic')->new( interpolate => $self )
      ->do_calculation($x);
}

=head2 cubic

This method do the cubic interpolation. It solves the interpolated_y given point_x and a minimum of 5 data points.

=cut

sub cubic {
    my ( $self, $x ) = @_;
    confess "point_x must be numeric" if !looks_like_number($x);
    $self->interpolate_classes();
    return Math::Function::Interpolator->with_traits(
        'Math::Function::Interpolator::Cubic')->new( interpolate => $self )
      ->do_calculation($x);
}

=head2 closest_three_points

 Returns the the closest three points to the sought point.
 The third point is chosen based on the point which is closer to mid point

=cut

sub closest_three_points {
    my ( $self, $sought, $all_points ) = @_;

    my @ap = sort { $a <=> $b } @{$all_points};
    my $length = scalar @ap;

    my ( $first, $second ) =
      @{ find_closest_numbers_around( $sought, $all_points, 2 ) };
    my @indexes = indexes { $first == $_ or $second == $_ } @ap;
    my $third_index =
      ( max(@indexes) < $length - 2 ) ? max(@indexes) + 1 : min(@indexes) - 1;
    my @sorted = sort { $a <=> $b } ( $first, $second, $ap[$third_index] );

    return @sorted;
}

=head1 AUTHOR

Binary.com, C<< <perl at binary.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-math-function-interpolator at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Math-Function-Interpolator>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Math::Function::Interpolator


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Math-Function-Interpolator>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Math-Function-Interpolator>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Math-Function-Interpolator>

=item * Search CPAN

L<http://search.cpan.org/dist/Math-Function-Interpolator/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2014 Binary.com.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1;    # End of Math::Function::Interpolator
