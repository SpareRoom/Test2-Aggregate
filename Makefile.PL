use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

# Optional except for cpancover, cpantesters etc.
my $extra_test =
  ( $ENV{EXTENDED_TESTING} || $ENV{AUTOMATED_TESTING} )
  ? 'requires'
  : 'recommends';

my %WriteMakefileArgs = (
    NAME               => 'Test2::Aggregate',
    AUTHOR             => q{Dimitrios Kechagias <dkechag@cpan.org>},
    VERSION_FROM       => 'lib/Test2/Aggregate.pm',
    ABSTRACT_FROM      => 'lib/Test2/Aggregate.pm',
    LICENSE            => 'perl_5',
    MIN_PERL_VERSION   => '5.008',
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => '0',
    },
    TEST_REQUIRES => {
        'Test::Output' => '0',
        'Test2::V0'    => '0'
    },
    PREREQ_PM => {
        'Path::Tiny' => '0',
        'Test2::V0'  => '0'
    },
    META_MERGE => {
        "meta-spec" => { version => 2 },
        prereqs => {
            test => {
                $extra_test => {
                    'Test2::Plugin::BailOnFail' => '0',
                    'Sub::Override'             => '0'
                }
            },
            runtime => {
                suggests => {
                    'Test2::Plugin::BailOnFail' => '0',
                    'Sub::Override'             => '0'
                }
            }
        },
        resources => {
            repository => {
                type => 'git',
                url => 'git://github.com/SpareRoom/Test2-Aggregate.git',
                web => 'https://github.com/SpareRoom/Test2-Aggregate',
            }
        }
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Test2-Aggregate-*' },
);

# Compatibility with old versions of ExtUtils::MakeMaker
unless (eval { ExtUtils::MakeMaker->VERSION('6.64'); 1 }) {
    my $test_requires = delete $WriteMakefileArgs{TEST_REQUIRES} || {};
    @{$WriteMakefileArgs{PREREQ_PM}}{keys %$test_requires} = values %$test_requires;
}

unless (eval { ExtUtils::MakeMaker->VERSION('6.55_03'); 1 }) {
    my $build_requires = delete $WriteMakefileArgs{BUILD_REQUIRES} || {};
    @{$WriteMakefileArgs{PREREQ_PM}}{keys %$build_requires} = values %$build_requires;
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
    unless eval { ExtUtils::MakeMaker->VERSION('6.52'); 1 };
delete $WriteMakefileArgs{MIN_PERL_VERSION}
    unless eval { ExtUtils::MakeMaker->VERSION('6.48'); 1 };
delete $WriteMakefileArgs{LICENSE}
    unless eval { ExtUtils::MakeMaker->VERSION('6.31'); 1 };

WriteMakefile(%WriteMakefileArgs);
