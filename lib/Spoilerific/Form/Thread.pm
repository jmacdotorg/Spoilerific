package Spoilerific::Form::Thread;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';

has_field 'subject' => ( type => 'Text',
                         required => 1,
                       );

has_field 'hashtag' => ( type => 'Text',
                         required => 1,
                         apply => [ {
                            check => qr/^#?[\w\d]+$/,
                            message => 'This has to be a legal Twitter hashtag: no '
                                       . 'spaces, and no punctuation marks.',
                         } ],
                       );

has_field 'continue' => ( type => 'Submit',
                          value => 'Continue',
                        );

1;
