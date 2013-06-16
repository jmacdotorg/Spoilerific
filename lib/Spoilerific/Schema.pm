use utf8;
package Spoilerific::Schema;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use Moose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-01-20 13:26:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ekp29mzXYVjw8zFWo7IiJA

use MooseX::ClassAttribute;

class_has 'consumer_key' => (
    is => 'rw',
    isa => 'Str',
);

class_has 'consumer_secret' => (
    is => 'rw',
    isa => 'Str',
);

class_has 'access_token' => (
    is => 'rw',
    isa => 'Str',
);

class_has 'access_token_secret' => (
    is => 'rw',
    isa => 'Str',
);

__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;
