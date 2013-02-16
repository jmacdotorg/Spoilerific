use utf8;
package Spoilerific::Schema::Result::Thread;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Spoilerific::Schema::Result::Thread

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

=head1 TABLE: C<thread>

=cut

__PACKAGE__->table("thread");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 subject

  data_type: 'char'
  is_nullable: 1
  size: 128

=head2 hashtag

  data_type: 'char'
  is_nullable: 1
  size: 128

=head2 creator

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "subject",
  { data_type => "char", is_nullable => 1, size => 128 },
  "hashtag",
  { data_type => "char", is_nullable => 1, size => 128 },
  "creator",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 creator

Type: belongs_to

Related object: L<Spoilerific::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "creator",
  "Spoilerific::Schema::Result::User",
  { id => "creator" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 posts

Type: has_many

Related object: L<Spoilerific::Schema::Result::Post>

=cut

__PACKAGE__->has_many(
  "posts",
  "Spoilerific::Schema::Result::Post",
  { "foreign.thread" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-02-03 11:57:00
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:OoGc2o+APQoddMt8ZW+dZw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
