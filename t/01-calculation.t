use Test::More tests => 3;
use Math::Function::Interpolator;

my $interpolator = Math::Function::Interpolator->new(
    points => {1=>2,2=>3,3=>4,4=>5,5=>6}
);

is  ( $interpolator->linear(1.5), 2.5, 'Linear Interpolation');
is  ( $interpolator->quadratic(2.3), 3.3, 'Quadratic Interpolation');
is  ( $interpolator->cubic(4.5), 5.5, 'Cubic Interpolation');


