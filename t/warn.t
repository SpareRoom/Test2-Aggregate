use Test2::Tools::Basic;
use Test2::Aggregate;

plan(5);

Test2::Aggregate::run_tests(
    dirs          => ['aggregate'],
    lists         => ['aggregate/aggregate.lst'],
    test_warnings => 1
);
