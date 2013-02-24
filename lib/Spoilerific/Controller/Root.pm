package Spoilerific::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=head1 NAME

Spoilerific::Controller::Root - Root Controller for Spoilerific

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my $twitter_search_string = $c->uri_for( '/thread' );
    $twitter_search_string =~ s{^https?://}{};

    $c->stash->{ twitter_search_string } = $twitter_search_string;

    $c->stash->{ template } = 'root.tt';
}

sub about :Path('about') :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{ template } = 'about/about.tt';
}

sub privacy :Path('about/privacy') :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{ template } = 'about/privacy.tt';
}

sub contact :Path('about/contact') :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{ template } = 'about/contact.tt';
}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {
    my ( $self, $c ) = @_;

    # Work around apparent funny business WRT
    # Catalyst::Authentication::Credential::Twitter.
    $c->get_auth_realm('twitter')->credential->twitter_user( undef );
}

=head1 AUTHOR

Jason McIntosh

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
