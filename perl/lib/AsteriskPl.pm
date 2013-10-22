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

package AsteriskPl;
use strict;
use warnings;

use LWP::Simple;
use JSON;
use AsteriskPl::AsteriskRESTAPI;
use AsteriskPl::Asterisk;
use AsteriskPl::Bridge;
use AsteriskPl::Channel;
use AsteriskPl::Endpoint;
use AsteriskPl::Recording;

sub new {
	# Initiate new AsteriskPl instance.
	# Takes optional string api_url (e.g. https://user:password@server:port/ari)
	# Raise requests.exceptions

	my ($class, %self) = @_;

	$self{'api'} = AsteriskPl::AsteriskRESTAPI->new(
		'api_url' => $self{'api_url'}
	);
	$self{'asterisk'} = AsteriskPl::Asterisk->new('api' => $self{'api'});
	bless \%self, $class;
	return \%self;
}

sub get_asterisk_info {
	# Return hash of Asterisk system information
	my $self = shift;
	return $self->{'asterisk'}->get_asterisk_info();
}

sub get_endpoints {
	# Return a list of all Endpoints from Asterisk.
	my $self = shift;
	my $tech = shift;

	my $path;
	if (defined $tech){
		$path = "/endpoints/%s";
	}
	else{
		$path = '/endpoints';
	}

	my $response = $self->{'api'}->call({
		'path' => $path,
		'http_method' => 'GET',
		'object_id' => $tech,
	});

	if (!defined $response || !defined $response->{success} || $response->{success} eq 0){
		return [];
	}

	my @result_list;
	foreach my $x (@{$response->{'response'}}) {
		my $chan = AsteriskPl::Endpoint->new('api' => $self->{'api'}, %{$x});
		push @result_list, $chan;
	}
	return \@result_list;
}

sub get_channels {
	my $self = shift;
	# Return a list of all Channels from Asterisk.
	my $response = $self->{'api'}->call({
		'path' => '/channels',
		'http_method' => 'GET'
	});

	if (!defined $response || !defined $response->{success} || $response->{success} eq 0){
		return [];
	}

	my @result_list;
	foreach my $x (@{$response->{'response'}}) {
		my $chan = AsteriskPl::Channel->new('api' => $self->{'api'}, %{$x});
		push @result_list, $chan;
	}
	return \@result_list;
}

sub get_bridges {
	my $self = shift;
	# Return a list of all Bridges from Asterisk.
	my $response = $self->{'api'}->call({
		'path' => '/bridges',
		'http_method' => 'GET'
	});

	if (!defined $response || !defined $response->{success} || $response->{success} eq 0){
		return [];
	}

	my @result_list;
	foreach my $x (@{$response->{'response'}}) {
		my $chan = AsteriskPl::Bridge->new('api' => $self->{'api'}, %{$x});
		push @result_list, $chan;
	}
	return \@result_list;
}

sub get_recordings {
	my $self = shift;
	# Return a list of all Recordings from Asterisk.
	my $response = $self->{'api'}->call({
		'path' => '/recordings',
		'http_method' => 'GET'
	});
	# Temporary until method is implemented
	my $result_list = [
		AsteriskPl::Recording->new('api' => $self->{'api'}),
		AsteriskPl::Recording->new('api' => $self->{'api'}),
	];
	#$result_list = [];
	#foreach my $x (@{$response->{'recordings'}}) {
	#	$x->{'api'} = $self->{'api'};
	#	push @$result_list =
	#		AsteriskPl::Recording->new('api' => $self->{'api'}),
	#}
	return $result_list;
}

sub get_endpoint {
	# Return Endpoint specified by object_id.
	my $self = shift;
	my $object_id = shift;
	my $response = $self->{'api'}->call({
		'path' => '/endpoints',
		'http_method' => 'GET',
		'object_id' => $object_id,
	});

	# Temporary until method is implemented
	#$response->{'endpoint'}->{'api'} = $self->{'api'};
	#$result = AsteriskPl::Endpoint->new($response->{'endpoint'});
	my $result = AsteriskPl::Endpoint->new('api' => $self->{'api'});
	return $result;
}

sub get_channel {
	# Return Channel specified by object_id.
	my $self = shift;
	my $object_id = shift;

	my $result = AsteriskPl::Channel->new('api' => $self->{'api'});
	if ($result->get_channel($object_id) eq 0){
		return undef;
	}
	return $result;
}

sub get_bridge {
	# Return Bridge specified by object_id.
	my $self = shift;
	my $object_id = shift;

	my $result = AsteriskPl::Bridge->new('api' => $self->{'api'});
	$result->get_bridge($object_id);
	return $result;
}

sub get_recording {
	# Return Recording specified by object_id.
	my $self = shift;
	my $object_id = shift;
	my $response = $self->{'api'}->call({
		'path' => '/recordings',
		'http_method' => 'GET',
		'object_id' => $object_id,
	});

	# Temporary until method is implemented
	#$response->{'recording'}->{'api'} = $self->{'api'};
	#$result = AsteriskPl::Recording->new($response->{'recording'});
	my $result = AsteriskPl::Recording->new('api' => $self->{'api'});
	return $result;
}

sub create_channel {
	# In Asterisk, originate a channel. Return the Channel.
	my $self = shift;
	my $params = shift;
	my $result = $self->{'api'}->call({
		'path' => '/channels',
		'http_method' => 'POST',
		'parameters' => $params,
	});
	# Temporary until method is implemented
	$result = AsteriskPl::Channel->new('api' => $self->{'api'});
	return $result
}

sub create_bridge() {
	#In Asterisk, bridge two or more channels. Return the Bridge.
	my $self = shift;
	my $params = shift;
	my $result = AsteriskPl::Bridge->new('api' => $self->{'api'});
	$result->new_bridge($params->{'type'});
	return $result
}

sub add_event_handler() {
	# Add a general event handler for Stasis events.
	# For object-specific events, use the object's add_event_handler instead.
	my $self = shift;
	my $event_name = shift;
	my $handler = shift;
	return 1
}

sub remove_event_handler() {
	# Add a general event handler for Stasis events.
	# For object-specific events, use the object's add_event_handler instead.
	my $self = shift;
	my $event_name = shift;
	my $handler = shift;
	return 1
}

1;
