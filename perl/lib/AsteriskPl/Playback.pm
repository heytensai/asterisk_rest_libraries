#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Copyright (C) 2013 Digium, Inc.
# All Rights Reserved.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# @Package: AsteriskPl
# @Authors: Erin Spiceland <espiceland@digium.com>
#
# See http://www.asterisk.org for more information about
# the Asterisk project. Please do not directly contact
# any of the maintainers of this project for assistance;
# the project provides a web site, mailing lists and IRC
# channels for your use.
#
# This program is free software, distributed under the terms
# detailed in the the LICENSE file at the top of the source tree.
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


package AsteriskPl::Playback;
use strict;
use warnings;

sub new {
	# Definition of Playback object
	my ($class, %self) = @_;
	$self{'object_id'} = 1;
	if (ref $self{'api'} ne 'AsteriskPl::AsteriskRESTAPI') {
		die("Can't make new AsteriskPl::Asterisk instance with no "
			. "AsteriskPl::AsteriskRESTAPI instance.");
	}
	bless \%self, $class;
	return \%self;
}

sub get_id {
	# Return the Playback object's id.
	my $self = shift;
	return $self->{'object_id'}
}

sub add_event_handler {
	# Add an event handler for Stasis events on this object.
	# For general events, use Asterisk.add_event_handler instead.
	my $self = shift;
	my $event_name = shift;
	my $handler = shift;
}

sub remove_event_handler {
	# Remove an event handler for Stasis events on this object.
	# For general events, use Asterisk.remove_event_handler instead.
	my $self = shift;
	my $event_name = shift;
	my $handler = shift;
}

sub delete {
	# Individual Playback; Delete playback
	my $self = shift;

	my $result = $self->{'api'}->call({
		'path' => '/playback/%s',
		'http_method' => 'DELETE',
		'object_id' => $self->{'id'}
	});
	if (!defined $result || !defined $result->{'success'} || $result->{success} eq 0){
		return 0;
	}
	return 1;
}

sub get {
	# Individual playback; Get playback details
	my $self = shift;
	my $id = shift;

	my $result = $self->{'api'}->call({
		'path' => '/playback/%s',
		'http_method' => 'GET',
		'object_id' => $id
	});
	if (!defined $result || !defined $result->{'success'} || $result->{success} eq 0){
		return 0;
	}
	my $resp = $result->{response};

	$self->{id} = $resp->{id};
	$self->{media_uri} = $resp->{media_uri};
	$self->{target_uri} = $resp->{target_uri};
	$self->{language} = $resp->{language};
	$self->{state} = $resp->{state};

	return $self;
}

sub control {
	# Control playback
	my $self = shift;
	my $operation = shift;

	my $result = $self->{'api'}->call({
		'path' => '/playback/%s/control',
		'http_method' => 'POST',
		'object_id' => $self->{'id'},
		'parameters' => { 'operation' => $operation },
	});
	if (!defined $result || !defined $result->{'success'} || $result->{success} eq 0){
		return 0;
	}
	return 1;
}

1;
