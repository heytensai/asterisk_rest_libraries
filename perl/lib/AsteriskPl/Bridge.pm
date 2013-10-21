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


package AsteriskPl::Bridge;
use strict;
use warnings;

sub new {
	# Definition of Bridge object
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
	# Return the Bridge object's id.
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

sub get_bridges {
	# Active bridges; List active bridges
	my $self = shift;

	my $params = {};
	my $result = $self->{'api'}->call({
		'path' => '/bridges',
		'http_method' => 'GET'
	});
	if (!defined $result || !defined $result->{'success'} || $result->{success} eq 0){
		return 0;
	}
	return $result->{'response'};
}

sub new_bridge {
	# Active bridges; Create a new bridge
	my $self = shift;
	my $type = shift;

	my $params = { 'type' => $type };
	my $result = $self->{'api'}->call({
		'path' => '/bridges',
		'http_method' => 'POST',
		'parameters' => $params
	});
	if (!defined $result || !defined $result->{'success'} || $result->{success} eq 0){
		return 0;
	}

	$self->{id} = $result->{id};
	$self->{bridge_type} = $result->{bridge_type};
	$self->{bridge_class} = $result->{bridge_class};
	$self->{technology} = $result->{technology};

	return $self;
}

sub get_bridge {
	# Individual bridge; Get bridge details
	my $self = shift;
	my $id = shift;

	my $result = $self->{'api'}->call({
		'path' => '/bridges/%s',
		'http_method' => 'GET',
		'object_id' => $id
	});
	if (!defined $result || !defined $result->{'success'} || $result->{success} eq 0){
		return 0;
	}
	my $resp = $result->{response};

	$self->{id} = $resp->{id};
	$self->{bridge_type} = $resp->{bridge_type};
	$self->{bridge_class} = $resp->{bridge_class};
	$self->{technology} = $resp->{technology};

	return $self;
}

sub delete_bridge {
	# Individual bridge; Delete bridge
	my $self = shift;

	my $result = $self->{'api'}->call({
		'path' => '/bridges/%s',
		'http_method' => 'DELETE',
		'object_id' => $self->{'id'}
	});
	if (!defined $result || !defined $result->{'success'} || $result->{success} eq 0){
		return 0;
	}
	return 1;
}

sub add_channel_to_bridge {
	# Add a channel to a bridge
	my $self = shift;
	my $channels = shift;
	my $role = shift;

	if (ref $channels ne 'ARRAY'){
		return 0;
	}

	my @ch;
	foreach my $ch (@{$channels}){
		my $id;
		if (ref $ch){
			$id = $ch->{'id'};
		}
		else{
			$id = $ch;
		}
		push @ch, $id,
	}
	my $params = {
		'channel' => \@ch,
		#'role' => $role,
	};

	my $result = $self->{'api'}->call({
		'path' => '/bridges/%s/addChannel',
		'http_method' => 'POST',
		'parameters' => $params,
		'object_id' => $self->{'id'}
	});
	return $result;
}

sub remove_channel_from_bridge {
	# Remove a channel from a bridge
	my $self = shift;
	my $channels = shift;

	if (ref $channels ne 'ARRAY'){
		return 0;
	}

	my @ch;
	foreach my $ch (@{$channels}){
		my $id;
		if (ref $ch){
			$id = $ch->{'id'};
		}
		else{
			$id = $ch;
		}
		push @ch, $id,
	}
	my $params = {
		'channel' => \@ch,
	};

	my $result = $self->{'api'}->call({
		'path' => '/bridges/%s/removeChannel',
		'http_method' => 'POST',
		'parameters' => $params,
		'object_id' => $self->{'id'}
	});
	if (!defined $result || !defined $result->{'success'} || $result->{success} eq 0){
		return 0;
	}
	return 1;
}

sub record_bridge {
	# Record audio to/from a bridge; Start a recording
	my $self = shift;

	my $params = {};
	my $is_success = $self->{'api'}->call({
		'path' => '/bridges/%s/record',
		'http_method' => 'POST',
		'parameters' => $params,
		'object_id' => $self->{'object_id'}
	});
	$is_success = 1;
	return $is_success;
}

sub play {
	# Play audio to a bridge
	my $self = shift;
	my $playback = shift;

	if (!$playback || !defined !$playback->{id}){
		return 0;
	}

	my $result = $self->{'api'}->call({
		'path' => '/bridges/%s/play',
		'http_method' => 'POST',
		'object_id' => $self->{'id'},
		'parameters' => { 'playbackId' => $playback->{id} },
	});
	if (!defined $result || !defined $result->{'success'} || $result->{success} eq 0){
		return 0;
	}
	return 1;
}

sub moh {
	# plays moh into a bridge
	my $self = shift;
	my $moh_class = shift;

	my %parameters;
	if ($moh_class){
		$parameters{'mohClass'} = $moh_class;
	}

	my $result = $self->{'api'}->call({
		'path' => '/bridges/%s/moh',
		'http_method' => 'POST',
		'object_id' => $self->{'id'},
		'parameters' => \%parameters,
	});
	if (!defined $result || !defined $result->{'success'} || $result->{success} eq 0){
		return 0;
	}
	return 1;
}

sub moh_stop {
	# stops moh previously started by Bridge::moh
	my $self = shift;

	my $result = $self->{'api'}->call({
		'path' => '/bridges/%s/moh',
		'http_method' => 'DELETE',
		'object_id' => $self->{'id'},
	});
	if (!defined $result || !defined $result->{'success'} || $result->{success} eq 0){
		return 0;
	}
	return 1;
}

1;
