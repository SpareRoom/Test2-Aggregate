# use Test2::Tools::Basic;
use Test2::V0;
use Test2::Aggregate;

plan(6);

my $root = (grep {/^\.$/i} @INC) ? undef : './';

Test2::Aggregate::run_tests(
    dirs          => ['xt/aggregate'],
    lists         => ['xt/aggregate/aggregate.lst'],
    root          => $root,
    test_warnings => 1
);

is(
    warnings {
        Test2::Aggregate::run_tests(
            dirs => ['xt/aggregate'],
            root => '/xx'
        )
    },
    [],
    'No warnings for invalid root.'
);

