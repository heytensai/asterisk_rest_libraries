#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Copyright (C) 2013 Digium, Inc.
# All Rights Reserved.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# @Package: AsteriskPl::AsteriskRESTAPI
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

use LWP::UserAgent;
use JSON;

package AsteriskPl::AsteriskRESTAPI;
use strict;
use warnings;

sub new {
	# Handle HTTP requests to Asterisk
	my ($class, %self) = @_;
	die ("Can't call Asterisk REST API without api_url.")
		if !$self{'api_url'};
	if ($self{'api_url'} !~ /https*:\/\/.+\/ari\/*/i) {
		die sprintf("api_url value is invalid: %s\n", $self{'api_url'});
	}
	$self{'ua'} = LWP::UserAgent->new();
	bless \%self, $class;
	return \%self;
}

sub call {
	# Call an Asterisk API method, return a hash of the following structure:
	#
	# {
	#	'success' : 1, # or False
	#	'response' : jsonObject, # or None
	#	'error' : null, # or string
	# }
	#
	# success indicates the success or failure of the Asterisk API call.
	# response is a dictionary constructed by json.dumps(json_string)
	# error is a message.
	#
	# If the API call is successful but Asterisk returns invalid JSON, error
	# will be "Invalid JSON." and response will be the unchanged content
	# of the response.

	my $self = shift;
	my $params = shift;
	my $result = {
		'success' => 0,
		'response' => undef,
		'error' => undef,
	};

	die ("Can't call Asterisk REST API without HTTP method.")
		if !$params->{'http_method'};
	die ("Can't call Asterisk REST API without resource path.")
		if !$params->{'http_method'};


	if ($params->{'object_id'}) {
		if (ref $params->{'object_id'} eq 'ARRAY'){
			foreach my $p (@{$params->{'object_id'}}){
				$params->{'path'} =~ s/\%s/$p/i;
			}
		}
		else{
			$params->{'path'} =~ s/\%s/$params->{'object_id'}/ig;
		}
	}
	my $uri = $self->{'api_url'} . $params->{'path'};
	my $response;
	print "uri is $uri\n";
	if ($params->{'http_method'} eq 'GET') {
		my $param_string = make_param_string($params->{'parameters'});
		$uri = sprintf("$uri%s", $param_string);
		$response = $self->{'ua'}->get($uri);
	} elsif ($params->{'http_method'} eq 'POST') {
		# workaround for https://issues.asterisk.org/jira/browse/ASTERISK-22685
		if (1){
			my $paramString = make_param_string($params->{'parameters'});
			$uri = sprintf("$uri%s", make_param_string($params->{'parameters'}));
			$response = $self->{'ua'}->post($uri);
		}
		else{
			$response = $self->{'ua'}->post($uri, $params->{'parameters'});
		}
	} elsif ($params->{'http_method'} eq 'DELETE') {
		my $paramString = make_param_string($params->{'parameters'});
		$uri = sprintf("$uri%s", make_param_string($params->{'parameters'}));
		$response = $self->{'ua'}->delete($uri);
	} elsif ($params->{'http_method'} eq 'PUT') {
		$response = $self->{'ua'}->put($uri, $params->{'parameters'});
	}

	print "response is ", $response->status_line, "\n";
	if ($response->content =~ /connection refused/i) {
		print "Can't contact server.\n";
		return $result;
	}

	if ($response->code =~ m/^4/ or $response->code =~ m/^3/ or $response->code =~ m/^5/) {
		print "Server error.\n";
		$result->{'error'} = $response->status_line;
		$result->{'success'} = 0;
		return $result;
	}

	$result->{'success'} = 1;

	if ($response->content) {
		if (eval { JSON::XS::decode_json($response->content); 1; } ) {
			$result->{'response'} = JSON::XS::decode_json($response->content);
			$result->{'success'} = 1;
		} else {
			print "\tINVALID JSON\n";
			$result->{'error'} = "INVALID JSON";
			$result->{'success'} = 0;
			print $response->content, "\n";
		}
	}

	return $result;
}

sub make_param_string($) {
	# Turn key/value and key/list pairs into an HTTP URL parameter string.
	# var1=value1&var2=value2,value3,value4
	my $params = shift;
	my $strings = [];
	foreach my $name (keys %$params) {
		# Skip ref HASH -- We won't know how to name these.
		my $ref = ref $params->{$name};
		if (!$ref){
			push @$strings, join('=', $name, $params->{$name});
		} elsif ($ref eq 'ARRAY') {
			push @$strings, join('=', $name, join(',', @{$params->{$name}}));
		} elsif ($ref eq 'SCALAR') {
			push @$strings, join('=', $name, ${$params->{$name}});
		}
	}
	if (@$strings) {
		return '?' . join('&', @$strings);
	} else {
		return '';
	}
}

1;
