package Spoilerific::Schema::ResultSet::Thread;

use warnings;
use strict;

use base qw(DBIx::Class::ResultSet);

__PACKAGE__->load_components('Helper::ResultSet::Random');

1;
