package Test2::Aggregate::Helper;

use strict;
use warnings;

use Carp;
use Path::Tiny;

=head1 NAME

Test2::Aggregate::Helper - Common functions for Test2::Aggregate helper scripts

=head1 SYNOPSIS

See L<agg> and L<aggit> helper scripts.

=cut

our $VERSION = '0.01';

sub setup_options {
    my $opt = shift;

    $opt->{test_bundle} ||= $opt->{prove} ? 'Test::More' : 'Test2::V0';
    $opt->{stats_output}  = $opt->{pass_output} if $opt->{pass_output};
    $opt->{out} =~ s/\.t$// if $opt->{out};
    delete $opt->{event_timeout} if $opt->{prove};
    $opt->{exclude_pattern} = _create_exclude_pattern($opt)
        if $opt->{exclude_regex} || $opt->{exclude_list};
    $opt->{include_pattern} = _create_include_pattern($opt)
        if $opt->{include_regex};

    if ($opt->{root}) {
        $opt->{absolute} = undef;
        croak "Specified --root does not exist" unless -e $opt->{root};
        foreach (@ARGV) {
            my $path = path($opt->{root}, $_);
            croak "$path doesn't exist" unless -e $path;
        }
    } elsif (!$opt->{absolute}) {
        $opt->{root} = "./";
        $opt->{relative_root} = 1;
    }

    unless ($opt->{prove}) {
        eval "use Test2::Harness";
        $opt->{prove} = 1 if $@;
    }
}

sub create_command {
    my $opt       = shift;
    my $file      = shift;
    my $args_only = shift;

    my $cmd  = $opt->{prove} ? 'prove' : 'yath';
    my @args = ($file);
    unshift @args, '-v'                            if $opt->{verbose};
    unshift @args, "-I" . $opt->{include}          if $opt->{include};
    unshift @args, "--et " . $opt->{event_timeout} if $opt->{event_timeout};
    unshift @args, 'test' unless $opt->{prove} || $args_only;

    return @args if $args_only;
    return $cmd, @args;
}

sub generate_code {
    my $opt  = shift;
    my $code = _test_bundle_use($opt->{test_bundle})
        . "\nuse Test2::Aggregate;\n\nTest2::Aggregate::run_tests(\n";
    for (qw/test_warnings reverse shuffle sort dry_run bail_on_fail relative_root/) {
        $code .= "\t$_ => 1,\n" if $opt->{$_};
    }
    for (qw/stats_output root/) {
       $code .= "\t$_ => " . _quote_perl_string($opt->{$_}) . ",\n" if $opt->{$_};
    }
    $code .= "\texclude => " . _quote_perl_string($opt->{exclude_pattern}) . ",\n"
        if $opt->{exclude_pattern};
    $code .= "\tinclude => " . _quote_perl_string($opt->{include_pattern}) . ",\n"
        if $opt->{include_pattern};
    $code .= "\tpass_only => 1,\n" if $opt->{pass_output};
    $code .= $opt->{lists} ? "\tlists" : "\tdirs";
    $code .= " => [\n";
    $code .= join(",\n", map {_quote_perl_string($_)} _absolute_paths($opt, @_));
    $code .= "\n\t]\n);\n\ndone_testing();\n";
    return $code;
}

sub _test_bundle_use {
    my @modules = split /,/, shift;
    my $str     = '';
    $str .= "use $_;\n" for @modules;
    return $str;
}

sub _absolute_paths {
    my $opt    = shift;
    my $t_file = $opt->{file}->parent->absolute;
    my @norm;
    foreach my $path (@_) {
        unless (substr($path, 0, 1) eq '/') {
            if ($opt->{relative_root}) {
                my $abs = path($opt->{root}, $path)->absolute;
                $path = $abs->relative($t_file);
            } elsif ($opt->{absolute}) {
                $path = path($opt->{root}, $path);
            }
        }
        push @norm, $path;
    }

    return @norm;
}

sub _create_exclude_pattern {
    my ($opt) = @_;
    my @parts;

    if ($opt->{exclude_regex}) {
        eval { qr/$opt->{exclude_regex}/ };
        croak "Invalid --exclude_regex '$opt->{exclude_regex}': $@" if $@;
        push @parts, "(?:$opt->{exclude_regex})";
    }

    if ($opt->{exclude_list}) {
        croak "Specified --exclude_list does not exist" unless -e $opt->{exclude_list};
        my @list = split /\r?\n/, path($opt->{exclude_list})->slurp_utf8;
        foreach my $line (@list) {
            next if $line =~ /^\s*(?:#|$)/;
            $line =~ s/^\s+|\s+$//g;
            next unless length $line;

            push @parts, '^' . quotemeta($line) . '$';

            my $norm = _normalize_test_path($line);
            push @parts, '^' . quotemeta($norm) . '$' if $norm ne $line;
        }
    }

    return join('|', @parts);
}

sub _create_include_pattern {
    my ($opt) = @_;

    eval { qr/$opt->{include_regex}/ };
    croak "Invalid --include_regex '$opt->{include_regex}': $@" if $@;

    return "(?:$opt->{include_regex})";
}

sub _normalize_test_path {
    my ($test) = @_;
    $test =~ s#^\./##;
    return $test;
}

sub _quote_perl_string {
    my ($value) = @_;
    $value = "$value";
    $value =~ s/\\/\\\\/g;
    $value =~ s/'/\\'/g;
    return "'$value'";
}

1;
