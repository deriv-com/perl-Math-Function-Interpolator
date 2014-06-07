use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Math::Function::Interpolator',
    AUTHOR           => q{Binary.com <perl@binary.com>},
    VERSION_FROM     => 'lib/Math/Function/Interpolator.pm',
    ABSTRACT_FROM    => 'lib/Math/Function/Interpolator.pm',
    LICENSE          => 'Artistic_2_0',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More'            => 0,
        'Moose'                 => 0,
        'Moose::Role'           => 0,
        'MooseX::Traits'        => 0,
        'Module::Runtime'       => 0,
        'Module::Pluggable'     => 0,
        'Carp'                  => 0,
        'List::MoreUtils'       => 0,
        'List::Util'            => 0,
        'Math::Cephes::Matrix'  => 0,
        'POSIX'                 => 0,
        'Try::Tiny'             => 0,
        'Number::Closest::XS'   => 0,
        'Scalar::Util'          => 0,
    },
    PREREQ_PM => {
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Math-Function-Interpolator-*' },
);
