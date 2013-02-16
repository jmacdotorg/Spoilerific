package Spoilerific::Form::Thread;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';

has_field 'subject' => ( type => 'Text',
                         required => 1,
                       );

has_field 'hashtag' => ( type => 'Text',
                         required => 1,
                       );

has_field 'continue' => ( type => 'Submit',
                          value => 'Continue',
                        );

1;
