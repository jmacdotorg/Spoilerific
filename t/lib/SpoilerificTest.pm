package SpoilerificTest;
use strict;
use warnings;
use Carp qw( cluck );

$SIG{ __WARN__ } = sub { cluck shift };

use base qw( Exporter );
our @EXPORT    = qw( elt );
our @EXPORT_OK = qw( elt );

use FindBin;

$ENV{Spoilerific_SITE_CONFIG} = "$FindBin::Bin/conf/Spoilerific.conf";

use utf8;
use Carp qw(croak);
use English;
use File::Path qw(make_path remove_tree);

use Spoilerific::Schema;

# TO DO: get these from the config file?
my $db_dir    = "$FindBin::Bin/db";
my $db_file   = "$db_dir/Spoilerific.db";
my $dsn       = "dbi:SQLite:$db_file";

# XXX It's perhaps not ideal to read the config file, just to grab twitter keys, which
#     in turn are only for connecting to the Twitter API and testing the current length
#     of shortened URLs. But the alternative if just faking that API call, and I dunno
#     if that's much better...
use Config::Any;
my $config = Config::Any->load_files({
    files => [
        "$FindBin::Bin/conf/spoilerific.conf",
    ],
    use_ext => 1,
    flatten_to_hash => 1,
});

foreach ( qw/consumer_key consumer_secret access_token access_token_secret/ ) {
    my $config_key = 'TWITTER_' . uc( $_ );
    Spoilerific::Schema->$_( $config->{ "$FindBin::Bin/conf/spoilerific.conf" }->{ $config_key } );
}

sub init_schema {
    my $self = shift;
    my %args = @_;

    if (-e $db_file) {
        unlink $db_file
            or croak("Couldn't unlink $db_file: $OS_ERROR");
    }

    my $schema = Spoilerific::Schema->
        connect( $dsn, '', '', {
            sqlite_unicode => 1,
            on_connect_call => 'use_foreign_keys',
        });

    # The default dir for deploy is "./", which means that if you run
    # the tests from Spoilerific_HOME it tries to read Spoilerific.sql to get the
    # deployment statements rather than generating them for SQLite.
    # So we have to specify the dir here, even though it actually uses
    # the path in the $dsn to write the SQLite file...
    $schema->deploy( undef, $db_dir );

    $schema->populate(
        'User',
        [
            [qw/id twitter_user/],
            [1, 'AliceTester', ],
        ],
    );

    $schema->populate(
        'Thread',
        [
            [qw/id subject hashtag/],
            [1, 'Bucky the Numpire Slaver', '#BtNS'],
        ],
    );

    $schema->populate(
        'Post',
        [
            [qw/id poster thread body_plaintext timestamp/],
            [1, 1, 1,
                'Scotchtape kills Ruddigore! An unexpected allergy. #lol',
                '2010-01-01 00:00:00',
            ],
            [2, 1, 1,
                '#BtNS redundant hashtags ahoy!',
                '2010-01-01 00:00:01',
            ],
        ],
    );

    return $schema;
}

1;

__END__

=head1 NAME

SpoilerificTest

=head1 SYNOPSIS

    use lib qw(t/lib);
    use SpoilerificTest;
    use Test::More;

    my $schema = SpoilerificTest->init_schema;

=head1 DESCRIPTION

This module provides the basic utilities to write tests against
Spoilerific. Shamelessly stolen from DBICTest in the DBIx::Class test
suite. (Actually it's stolen from a consulting colleague of Jason's,
who stole it in turn from DBIC...)

=head1 METHODS

=head2 init_schema

    my $schema = SpoilerificTest->init_schema;

This method removes the test SQLite database in t/db/Spoilerific.db
and then creates a new database populated with default test data.

