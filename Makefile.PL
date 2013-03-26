#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install 1.02;
use Module::Install::Catalyst; # Complain loudly if you don't have
                               # Catalyst::Devel installed or haven't said
                               # 'make dist' to create a standalone tarball.

name 'Spoilerific';
all_from 'lib/Spoilerific.pm';

requires 'Catalyst::Runtime' => '5.90019';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'Moose';
requires 'namespace::autoclean';
requires 'Config::General'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats
test_requires 'Test::More' => '0.88';

requires 'Catalyst::Authentication::Credential::Twitter' => '1.0.0';

requires 'FindBin::libs';
requires 'Catalyst::Plugin::Session::PerUser' => '0.05';
requires 'DBIx::Class::Helpers' => '2.016005';
requires 'DBIx::Class' => '0.08208';
requires 'Readonly' => '1.03';

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
