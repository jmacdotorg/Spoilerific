package Spoilerific::View::HTML;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    render_die => 1,
);

=head1 NAME

Spoilerific::View::HTML - TT View for Spoilerific

=head1 DESCRIPTION

TT View for Spoilerific.

=head1 SEE ALSO

L<Spoilerific>

=head1 AUTHOR

Jason McIntosh

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
