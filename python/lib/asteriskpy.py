"""
 Copyright (C) 2013 Digium, Inc.

 Erin Spiceland <espiceland@digium.com>

 See http://www.asterisk.org for more information about
 the Asterisk project. Please do not directly contact
 any of the maintainers of this project for assistance;
 the project provides a web site, mailing lists and IRC
 channels for your use.

 This program is free software, distributed under the terms
 detailed in the the LICENSE file at the top of the source tree.

"""
import sys
sys.path.append('python/lib')
from asterisk_rest_api import AsteriskRestAPI
from asterisk import Asterisk
from endpoint import Endpoint
from channel import Channel
from bridge import Bridge
from recording import Recording


class AsteriskPy:
    """
    Python library for the Asterisk REST API.
    """
    def __init__(self, api_url='http://localhost:8088/stasis'):
        """Initiate new AsteriskPy instance.

        Takes optional string api_url which points to the REST API base URL.
        Raise requests.exceptions

        """
        self._api_url = api_url
        self._api = AsteriskRestAPI(uri=self._api_url)
        self._asterisk = Asterisk(self._api)

    def get_info(self):
        """Return dict of Asterisk system information"""
        return self._asterisk.get_info()

    def get_endpoints(self):
        """Return a list of all Endpoints from Asterisk."""
        result = self._api.call('endpoints', http_method='GET')
        # Temporary until method is implemented
        result_list = [Endpoint(self._api), Endpoint(self._api)]
        #endpoints = [Endpoint(x) for x in result]
        return result_list

    def get_channels(self):
        """Return a list of all Channels from Asterisk."""
        result = self._api.call('channels', http_method='GET')
        # Temporary until method is implemented
        result_list = [Channel(self._api), Channel(self._api)]
        #channels = [Channel(x) for x in result]
        return result_list

    def get_bridges(self):
        """Return a list of all Bridges from Asterisk"""
        result = self._api.call('bridges', http_method='GET')
        # Temporary until method is implemented
        result_list = [Bridge(self._api), Bridge(self._api)]
        #bridges = [Bridge(x) for x in result]
        return result_list

    def get_recordings(self):
        """Return a list of all Recordings from Asterisk."""
        result = self._api.call('recordings', http_method='GET')
        # Temporary until method is implemented
        result_list = [Recording(self._api), Recording(self._api)]
        #recordings = [Recording(x) for x in result]
        return result_list

    def get_endpoint(self, object_id):
        """Return Endpoint specified by object_id."""
        result = self._api.call('endpoints', http_method='GET',
                                object_id=object_id)
        # Temporary until method is implemented
        result = Endpoint(self._api)
        #endpoint = Endpoint(result)
        return result

    def get_channel(self, object_id):
        """Return Channel specified by object_id."""
        result = self._api.call('channels', http_method='GET',
                                object_id=object_id)
        # Temporary until method is implemented
        result = Channel(self._api)
        #channel = Channel(result)
        return result

    def get_bridge(self, object_id):
        """Return Bridge specified by object_id."""
        result = self._api.call('bridges', http_method='GET',
                                object_id=object_id)
        # Temporary until method is implemented
        result = Bridge(self._api)
        #bridge = Bridge(result)
        return result

    def get_recording(self, object_id):
        """Return Recording specified by object_id."""
        result = self._api.call('recordings', http_method='GET',
                                object_id=object_id)
        # Temporary until method is implemented
        result = Recording(self._api)
        #recording = Recording(result)
        return result

    def create_channel(self, params):
        """In Asterisk, originate a channel. Return the Channel."""
        result = self._api.call('channels', http_method='POST',
                                parameters=params)
        # Temporary until method is implemented
        result = Channel(self._api)
        return result

    def create_bridge(self, params):
        """In Asterisk, bridge two or more channels. Return the Bridge."""
        result = self._api.call('bridges', http_method='POST',
                                parameters=params)
        # Temporary until method is implemented
        result = Bridge(self._api)
        return result

    def add_event_handler(self, event_name, handler):
        """Add a general event handler for Stasis events.
        For object-specific events, use the object's add_event_handler instead.
        """
        pass

    def remove_event_handler(self, event_name, handler):
        """Add a general event handler for Stasis events.
        For object-specific events, use the object's add_event_handler instead.
        """
        pass
