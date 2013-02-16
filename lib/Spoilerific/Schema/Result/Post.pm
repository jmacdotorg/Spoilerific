use utf8;
package Spoilerific::Schema::Result::Post;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Spoilerific::Schema::Result::Post

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

=head1 TABLE: C<post>

=cut

__PACKAGE__->table("post");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 body_plaintext

  data_type: 'char'
  is_nullable: 1
  size: 140

=head2 body_ciphertext

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 1
  size: 140

=head2 full_plaintext

  data_type: 'char'
  is_nullable: 1
  size: 140

=head2 full_ciphertext

  data_type: 'char'
  is_nullable: 1
  size: 140

=head2 tweet_id

  data_type: 'char'
  is_nullable: 1
  size: 32

=head2 timestamp

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 poster

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 thread

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 in_reply_to

  data_type: 'char'
  is_nullable: 1
  size: 32

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "body_plaintext",
  { data_type => "char", is_nullable => 1, size => 140 },
  "body_ciphertext",
  { data_type => "char", default_value => "", is_nullable => 1, size => 140 },
  "full_plaintext",
  { data_type => "char", is_nullable => 1, size => 140 },
  "full_ciphertext",
  { data_type => "char", is_nullable => 1, size => 140 },
  "tweet_id",
  { data_type => "char", is_nullable => 1, size => 32 },
  "timestamp",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "poster",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "thread",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "in_reply_to",
  { data_type => "char", is_nullable => 1, size => 32 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 poster

Type: belongs_to

Related object: L<Spoilerific::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "poster",
  "Spoilerific::Schema::Result::User",
  { id => "poster" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 thread

Type: belongs_to

Related object: L<Spoilerific::Schema::Result::Thread>

=cut

__PACKAGE__->belongs_to(
  "thread",
  "Spoilerific::Schema::Result::Thread",
  { id => "thread" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-02-13 18:24:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:OW7F2rCGylHmWQhrdb3gHg

use Readonly;
Readonly my $POST_MAXLENGTH => 140;
Readonly my $SPOILERTAG => '#spoilerific';

use MooseX::ClassAttribute;
use Net::Twitter;
use DateTime;

# url_length: Maximum length of shortened URLs, according to Twitter.
class_has 'url_length' => (
    is => 'ro',
    lazy => 1,
    builder => '_fetch_url_length',
);

class_has 'url_base' => (
    is => 'rw',
    default => 'http://localhost',
);

has 'twitter_url' => (
    is => 'rw',
    isa => 'Maybe[Str]',
    lazy => 1,
    builder => '_build_twitter_url',
);

after 'tweet_id' => sub {
    my $self = shift;

    if ( @_ ) {
        # The ID was just set, so update this post's twitter URL.
        $self->twitter_url( $self->_build_twitter_url );
    }
};

sub _build_twitter_url {
    my $self = shift;

    if ( $self->tweet_id ) {
        return sprintf 'http://twitter.com/%s/status/%s',
                       $self->poster->twitter_user,
                       $self->tweet_id,
                       ;
    }
    else {
        return undef;
    }
}

sub _fetch_url_length {
    my $self = shift;
    my $nt = Net::Twitter->new( legacy => 0 );
    my $twitter_config = $nt->get_configuration;
    return $twitter_config->{ short_url_length };
}

around body_plaintext => sub {
    my ( $orig, $self ) = ( shift, shift );

    if ( @_ ) {
        my $body_plaintext = $_[0];

        my $body_ciphertext = '';

        while ( $body_plaintext =~ /(\s*)(\S+)(\s*)/g ) {
            my $pre_space = $1;
            my $word = $2;
            my $post_space = $3;
            unless ( ($word =~ /^#/) or ($word =~ /^@/) ) {
                $word =~ tr/n-za-mN-ZA-M/a-zA-Z/;
            }
            $body_ciphertext .= "$pre_space$word$post_space";
        }

        $self->body_ciphertext( $body_ciphertext );

        $self->full_plaintext( $self->_fill( $body_plaintext ) );
        $self->full_ciphertext( $self->_fill( $body_ciphertext ) );
    }

    $self->$orig(@_);

};

sub _fill {
    my $self = shift;
    my ( $bodytext ) = @_;

    my $hashtag_length = length($self->thread->hashtag) + 1;
    my $spoilertag_length = length($SPOILERTAG) + 1;

    if ( $self->_is_first_post ) {
        $bodytext = $self->thread->subject . ": $bodytext";
    }

    if ( length_plus_url($bodytext) + $spoilertag_length <= $POST_MAXLENGTH ) {
        $bodytext .= " $SPOILERTAG";
    }

    if ( length_plus_url($bodytext) + $hashtag_length <= $POST_MAXLENGTH ) {
        # Don't redundantly add the thread hashtag if the poster's manually added it.
        my $thread_hashtag = $self->thread->hashtag;
        unless ( $bodytext =~ /$thread_hashtag/ ) {
            $bodytext .= q{ } . $thread_hashtag;
        }
    }

    # All posts must end with space + linkback.
    my $linkback_url = __PACKAGE__->url_base
                       . '/thread/'
                       . $self->thread->id
                       . '#'
                       . $self->id
                       ;
    $bodytext .= " $linkback_url";

    return $bodytext;

}

sub _is_first_post {
    my $self = shift;

    if (not $self->thread->posts > 1 ) {
        return 1;
    }
    else {
        return 0;
    }
}

# post: Actually post this message to Twitter. All attributes had better be filled out
#       by now.
sub post_to_twitter {
    my $self = shift;

    # Have the user object knit up an authenticated Twitter connection, and hand it over.
    my $nt = $self->poster->twitter_ua;

    # Make the post (which might be a reply).
    my $update_params_ref = { status => $self->full_ciphertext };
    if ( $self->in_reply_to ) {
        $update_params_ref->{ in_reply_to_status_id } = $self->in_reply_to;
    }
    my $retval = $nt->update( $update_params_ref );

    if ( ref $retval and ( ref $retval eq 'HASH' ) and $retval->{ id } ) {
        # Post succeeded. Save this post's Twitter ID.
        $self->tweet_id( $retval->{ id } );
        my $now = DateTime->now;
        $self->timestamp( $now );
        $self->update;
    }
    else {
        # Post failed I guess.
        # Let the lack of a tweet ID in the DB carry this information to
        # interested parties.
    }
}

sub length_plus_url {
    my ( $bodytext ) = @_;
    return length($bodytext) + 1 + __PACKAGE__->url_length;
}

__PACKAGE__->meta->make_immutable;
1;
