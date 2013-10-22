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


package AsteriskPl::Endpoint;
use strict;
use warnings;

sub new {
	# Definition of Endpoint object
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
	# Return the Endpoint object's id.
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

sub get_endpoints {
	# Asterisk endpoints; List available endoints
	my $self = shift;

	my $params = {};
	my $is_success = $self->{'api'}->call({
		'path' => '/endpoints',
		'http_method' => 'GET'
	});
	$is_success = 1;
	return $is_success;
}

sub get_endpoint {
	# Single endpoint; Details for an endpoint
	my $self = shift;
	my $tech = shift;
	my $resource = shift;

	my $ids = [$tech, $resource];

	my $result = $self->{'api'}->call({
		'path' => '/endpoints/%s/%s',
		'http_method' => 'GET',
		'object_id' => $ids,
	});
	if (!defined $result || !defined $result->{'success'} || $result->{success} eq 0){
		return 0;
	}
	my $resp = $result->{'response'};

	$self->{'resource'} = $resp->{'resource'};
	$self->{'technology'} = $resp->{'technology'};
	$self->{'state'} = $resp->{'state'};
	# TODO: channels

	return $self;
}
1;
