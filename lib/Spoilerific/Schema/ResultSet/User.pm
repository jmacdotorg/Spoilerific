package Spoilerific::Schema::ResultSet::User;

use warnings;
use strict;

use base qw(DBIx::Class::ResultSet);


sub auto_create {
	my $self = shift;
	my ( $twitter_user_info, $c ) = @_;

	my $user = $self->create( {
		twitter_user_id => $twitter_user_info->{ twitter_user_id },
	} );

	return $user;
}

1;
