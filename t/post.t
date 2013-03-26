#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use Spoilerific::Schema::Result::Post;

use FindBin;
use lib (
    "$FindBin::Bin/lib",
    "$FindBin::Bin/../lib",
);
use SpoilerificTest;

use Readonly;
Readonly my $POST_URL => 'http://localhost/thread/2#3';

my $schema = SpoilerificTest->init_schema;

#my $post1 = $schema->resultset( 'Post' )->find( 1 );
my $new_thread = $schema->resultset( 'Thread' )->create( {
    subject => 'Foo',
    hashtag => '#foo',
} );
my $alice = $schema->resultset( 'User' )->find( 1 );
my $post1 = $schema->resultset( 'Post' )->create( {
    thread => $new_thread,
    poster => $alice,
} );

$post1->body_plaintext( q{LOST was bullshit all along! #omg} );

is( $post1->body_ciphertext,
    "YBFG jnf ohyyfuvg nyy nybat! #omg",
    'body_ciphertext was set when the plaintext was set.',
);

is( $post1->full_plaintext,
    "Foo: LOST was bullshit all along! #omg #foo #spoilerific $POST_URL",
    'full_plaintext was set when the plaintext was set.',
);

is( $post1->full_ciphertext,
    "Foo: YBFG jnf ohyyfuvg nyy nybat! #omg #foo #spoilerific $POST_URL",
    'full_ciphertext was set when the plaintext was set.',
);

$post1->body_plaintext( q{LOST was #foo all along! #omg} );

is( $post1->full_ciphertext,
    "Foo: YBFG jnf #foo nyy nybat! #omg #spoilerific $POST_URL",
    'Did not add a redundant subject tag.',
);

$post1->body_plaintext( q{LOST was bullshit all along!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!} );

is( $post1->full_plaintext,
    "LOST was bullshit all along!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! $POST_URL",
    'Did not add any tags to very long body text.',
);

$post1->body_plaintext( q{Testing many URLs. jmac.org jmac.org jmac.org jmac.org} );
is( $post1->full_ciphertext,
    "Grfgvat znal HEYf. jmac.org jmac.org jmac.org jmac.org #foo $POST_URL",
    'Did not add any decoration to body text containing many short URLs.'
);

done_testing();
