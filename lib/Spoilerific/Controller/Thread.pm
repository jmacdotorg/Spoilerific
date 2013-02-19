package Spoilerific::Controller::Thread;
use Moose;
use namespace::autoclean;

use Spoilerific::Form::Thread;
use Spoilerific::Schema::Result::Post;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Spoilerific::Controller::Thread - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub get_thread :Chained('/') :PathPart('thread') :CaptureArgs(1) {
    my ( $self, $c, $thread_id ) = @_;

    my $thread = $c->model('SpoilerDB')->resultset('Thread')->find( $thread_id );
    $c->stash->{ thread } = $thread;

}

sub create :Local :Args(0) {
    my ( $self, $c ) = @_;

    # Can't do this if you're not logged in.
    unless ( $c->user ) {
        $c->res->redirect( $c->uri_for( '/' ) );
        return;
    }

    my $thread = $c->model( 'SpoilerDB' )->resultset('Thread')->new_result(
        { creator => $c->user->id }
    );
    $c->stash->{ thread } = $thread;

    return $self->_thread_form( $c );
}

sub detail :Chained('get_thread') :PathPart('') :Args(0) {
    my ( $self, $c ) = @_;
    my $thread = $c->stash->{ thread };

    # If the thread has no posts and the current user isn't its creator, then they have
    # no reason to be here. Punt them back to root.
    if ( ($thread->posts->count == 0)
         and not $self->_current_user_created_this_thread( $c ) ) {
         $c->res->redirect( $c->uri_for( '/' ) );
    }

    # Determine whether the user is cleared to see this thread unscrambled, and add to it.
    my $cleared = 0;
    # If they started the thread, then yes.
    # Otherwise, they'll need to have set the proper bit in their session via the 'clear'
    # action.
    if ( $self->_current_user_created_this_thread( $c ) ) {
        $cleared = 1;
    }
    else {
        $c->user_session->{ cleared_threads } ||= {};
        if ( $c->user_session->{ cleared_threads }->{ $thread->id } ) {
            $cleared = 1;
        }
    }
    $c->stash->{ current_user_has_cleared_this_thread } = $cleared;

    $c->stash->{ url_length } = Spoilerific::Schema::Result::Post->url_length;
    $c->stash->{ hashtag_length } = length $thread->hashtag;

}

sub preview :Chained('get_thread') :PathPart('preview') :Args(0) {
    my ( $self, $c ) = @_;
    my $thread = $c->stash->{ thread };

    my $post = $c->model( 'SpoilerDB' )->resultset('Post')->new_result(
        {
            thread => $thread->id,
            poster => $c->user->id,
            id     => '0',
        }
    );

    $self->_set_uri_base( $c );

    $post->body_plaintext( $c->req->parameters->{ body_plaintext } );
    $c->stash->{ post } = $post;

    $c->stash->{ current_view } = 'NoWrapper';
}

sub post :Chained('get_thread') :PathPart('post') :Args(0) {
    my ( $self, $c ) = @_;
    my $thread = $c->stash->{ thread };

    my $post = $c->model( 'SpoilerDB' )->resultset('Post')->create(
        {
            thread => $thread->id,
            poster => $c->user->id,
        }
    );

    $self->_set_uri_base( $c );

    $post->body_plaintext( $c->req->parameters->{ body_plaintext } );

    if ( my $in_reply_to = $c->req->parameters->{ in_reply_to } ) {
        $post->in_reply_to( $in_reply_to );
    }

    eval { $post->post_to_twitter; };

    if ( $post->tweet_id ) {
        $c->flash->{ post_succeeded } = 1;
        $post->update;
    }
    else {
        $post->delete;
        $c->flash->{ post_failed } = 1;
        $c->flash->{ post_error_message } = $@->twitter_error->{ error };
    }

    $c->res->redirect( $c->uri_for_action( '/thread/detail',
                                           [ $thread->id ],
                                         )
                     );
}

# spoil: The user calls this action to signal that they wish to display this thread
#        unencrypted. The fact that they get will get stored in their session.
sub spoil :Chained('get_thread') :PathPart('spoil') :Args(0) {
    my ( $self, $c ) = @_;
    my $thread = $c->stash->{ thread };

    $c->user_session->{ cleared_threads } ||= {};
    $c->user_session->{ cleared_threads }->{ $thread->id } = 1;

    $c->res->redirect( $c->uri_for_action( '/thread/detail',
                                           [ $thread->id ],
                                         )
                     );
}

sub _thread_form {
    my ( $self, $c ) = @_;

    my $form = Spoilerific::Form::Thread->new;
    $c->stash->{ form } = $form;
    if ( $form->process( item => $c->stash->{ thread },
                         params => $c->req->parameters,
       ) ) {
        $c->res->redirect(
            $c->uri_for_action( '/thread/detail', [ $c->stash->{ thread }->id ] )
        );
    }
    else {
        return;
    }
}

sub _current_user_created_this_thread {
    my ( $self, $c ) = @_;
    my $thread = $c->stash->{ thread };

    if ( $c->user and ( $thread->creator->id == $c->user->id ) ) {
        return 1;
    }
    else {
        return 0;
    }
}

sub _set_uri_base {
    my ( $self, $c ) = @_;

    # Inform the Post class of the the current URI base (minus trailing slash).
    my $base = $c->req->base;
    $base =~ s{/$}{};
    Spoilerific::Schema::Result::Post->url_base( $base );
}

=head1 AUTHOR

Jason McIntosh

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
