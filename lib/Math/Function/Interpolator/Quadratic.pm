package Math::Function::Interpolator::Quadratic;

use 5.006;
use strict;
use warnings FATAL => 'all';

our $VERSION = '0.04';

use parent 'Math::Function::Interpolator';

use Carp qw(confess);
use Math::Cephes::Matrix qw(mat);
use Scalar::Util qw(looks_like_number);
use Try::Tiny;

=head1 NAME

Math::Function::Interpolator::Quadratic

=head1 SYNOPSIS

    use Math::Function::Interpolator::Quadratic;

    my $interpolator = Math::Function::Interpolator::Quadratic->new(
        points => {1=>2,2=>3,3=>4,4=>5,5=>6}
    );

    $interpolator->quadratic(2.5);

=head1 DESCRIPTION

Math::Function::Interpolator::Quadratic helps you to do the interpolation calculation with quadratic method.
It solves the interpolated_y given point_x and a minimum of 5 data points. 

=head1 FIELDS

=head2 points (REQUIRED)

HashRef of points for interpolations

=head1 METHODS

=head2 quadratic

quadratic

=cut

# Returns the interpolated_y value given point_x with 3 data points
sub quadratic {
    my ( $self, $x ) = @_;

    confess "sought_point[$x] must be a number" unless looks_like_number($x);
    my $ap = $self->points;
    return $ap->{$x} if defined $ap->{$x};    # no need to interpolate

    my @Xs = keys %$ap;
    confess "cannot interpolate with fewer than 3 data points"
      if scalar @Xs < 3;

    my @points = $self->closest_three_points( $x, \@Xs );

    # Three cofficient
    my $abc = mat( [ map { [ $_**2, $_, 1 ] } @points ] );

    my $y = [ map { $ap->{$_} } @points ];

    my $solution;
    try { $solution = $abc->simq($y) }
    catch { confess 'Insoluble matrix: ' . $_; };
    my ( $a, $b, $c ) = @$solution;

    return ( $a * ( $x**2 ) + $b * $x + $c );
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

1;    # End of Math::Function::Interpolator::Quadratic
