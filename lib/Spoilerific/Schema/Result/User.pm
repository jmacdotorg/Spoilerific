use utf8;
package Spoilerific::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Spoilerific::Schema::Result::User

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<user>

=cut

__PACKAGE__->table("user");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 twitter_user_id

  data_type: 'char'
  is_nullable: 1
  size: 32

=head2 twitter_user

  data_type: 'char'
  is_nullable: 1
  size: 32

=head2 twitter_access_token

  data_type: 'char'
  is_nullable: 1
  size: 128

=head2 twitter_access_token_secret

  data_type: 'char'
  is_nullable: 1
  size: 128

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "twitter_user_id",
  { data_type => "char", is_nullable => 1, size => 32 },
  "twitter_user",
  { data_type => "char", is_nullable => 1, size => 32 },
  "twitter_access_token",
  { data_type => "char", is_nullable => 1, size => 128 },
  "twitter_access_token_secret",
  { data_type => "char", is_nullable => 1, size => 128 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 posts

Type: has_many

Related object: L<Spoilerific::Schema::Result::Post>

=cut

__PACKAGE__->has_many(
  "posts",
  "Spoilerific::Schema::Result::Post",
  { "foreign.poster" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 threads

Type: has_many

Related object: L<Spoilerific::Schema::Result::Thread>

=cut

__PACKAGE__->has_many(
  "threads",
  "Spoilerific::Schema::Result::Thread",
  { "foreign.creator" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-02-03 11:57:00
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:VkugykRO5VA7ggzCWjB5Gw

use Net::Twitter;
use MooseX::ClassAttribute;

class_has 'consumer_key' => (
    is => 'rw',
    isa => 'Str',
);

class_has 'consumer_secret' => (
    is => 'rw',
    isa => 'Str',
);

# twitter_ua: a Net::Twitter object representing a live Twitter connection for this user.
has 'twitter_ua' => (
    isa     => 'Net::Twitter',
    is      => 'ro',
    lazy    => 1,
    builder => '_build_twitter_ua',
);

sub auto_update {
	my $self = shift;
	my ( $twitter_info, $c ) = @_;
    # ...and then do nothing. Feel free to expand this later.
}

sub _build_twitter_ua {
    my $self = shift;

    my $nt = Net::Twitter->new(
        legacy => 0,
        source => 'api',
        consumer_key => __PACKAGE__->consumer_key,
        consumer_secret => __PACKAGE__->consumer_secret,
        access_token => $self->twitter_access_token,
        access_token_secret => $self->twitter_access_token_secret,
    );

    return $nt;
}

__PACKAGE__->meta->make_immutable;
1;
