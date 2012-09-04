# -*- coding: utf-8 -*-
#
# Copyright © 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation.

import base64
import kerberos
from kerberos import GSSError
import httplib
import os
import urllib
import mimetypes

try:
    import json
except ImportError:
    import simplejson as json

from M2Crypto import SSL, httpslib

from katello.client.logutil import getLogger
from katello.client.utils.encoding import u_str

# current active server -------------------------------------------------------

active_server = None


def set_active_server(server):
    global active_server
    assert isinstance(server, KatelloServer)
    active_server = server

# authentication strategies ---------------------------------------------------

class AuthenticationStrategy(object):

    _log = getLogger('katello')

    @classmethod
    def _get_connection(cls, host, port, protocol):
        if protocol == "https":
            return httplib.HTTPSConnection(host, port)
        else:
            return httplib.HTTPConnection(host, port)

    @classmethod
    def set_headers(cls, headers):
        return headers

    def connect(self, host, port, protocol):
        return self._get_connection(host, port, protocol)

class NoAuthentication(AuthenticationStrategy):

    def connect(self, host, port, protocol):
        self._log.debug('making noauth %s connection' % protocol)
        return self._get_connection(host, port, protocol)

class BasicAuthentication(AuthenticationStrategy):

    def __init__(self, username, password):
        super(BasicAuthentication, self).__init__()
        self.__username = username
        self.__password = password

    def set_headers(self, headers):
        raw = ':'.join((self.__username, self.__password))
        encoded = base64.encodestring(raw)[:-1]
        headers['Authorization'] = 'Basic ' + encoded
        return headers

    def connect(self, host, port, protocol):
        self._log.debug('making basic %s connection with: %s, %s' % (protocol, self.__username, self.__password))
        return self._get_connection(host, port, protocol)


class SSLAuthentication(AuthenticationStrategy):

    def __init__(self, certfile, keyfile):
        super(SSLAuthentication, self).__init__()
        self.__certfile = certfile
        self.__keyfile = keyfile
        self.__check_cert_and_key()

    def __check_cert_and_key(self):
        if not os.access(self.__certfile, os.R_OK):
            raise RuntimeError(_('certificate file %s does not exist or cannot be read')
                               % self.__certfile)
        if not os.access(self.__keyfile, os.R_OK):
            raise RuntimeError(_('key file %s does not exist or cannot be read')
                               % self.__keyfile)

    def connect(self, host, port, protocol):
        if protocol != "https":
            raise RuntimeError(_("can't authenticate via certificate when not using https connection"))
        ssl_context = SSL.Context('sslv3')
        ssl_context.load_cert(self.__certfile, self.__keyfile)
        self._log.debug('making SSL connection with: %s, %s' % (self.__certfile, self.__keyfile))
        return httpslib.HTTPSConnection(host, port, ssl_context=ssl_context)


class KerberosAuthentication(AuthenticationStrategy):

    def __init__(self, host):
        super(KerberosAuthentication, self).__init__()
        self.__host = host

    def set_headers(self, headers):
        ctx = kerberos.authGSSClientInit("HTTP@" + self.__host, \
            gssflags=kerberos.GSS_C_DELEG_FLAG|kerberos.GSS_C_MUTUAL_FLAG|kerberos.GSS_C_SEQUENCE_FLAG)[1]
        kerberos.authGSSClientStep(ctx, '')
        tgt = kerberos.authGSSClientResponse(ctx)

        if tgt:
            headers['Authorization'] = 'Negotiate %s' % tgt
            return headers
        else:
            raise RuntimeError(_("Couldn't authenticate via kerberos"))


    def connect(self, host, port, protocol):
        self._log.debug('making %s https connection with' % protocol)
        self._get_connection(host, port, protocol)


# base server class -----------------------------------------------------------

class ServerRequestError(Exception):
    """
    Exception to indicate a less than favorable response from the server.
    The arguments are [0] the response status as an integer and
    [1] the response message as a dict, if we managed to decode from json,
    or a str if we didn't [2] potentially a traceback, if the server response
    was a python error, otherwise it will be None
    """
    pass


class Bytes(str):
    """
    Binary (non-json) PUT/POST request body wrapper.
    """
    pass


class KatelloServer(object):
    """
    Katello server connection class.

    @ivar host: host name of the katello server
    @ivar port: port the katello server is listening on (443)
    @ivar protocol: protocol the katello server is using (http, https)
    @ivar path_prefix: mount point of the katello api (/katello/api)
    @ivar headers: dictionary of http headers to send in requests
    """  
    auth_method = NoAuthentication()

    #---------------------------------------------------------------------------
    def __init__(self, host, port=443, protocol='https', path_prefix='/katello/api', accept_lang=None):
        assert protocol in ('http', 'https')

        self.host = host
        self.port = port
        self.protocol = protocol
        self.path_prefix = path_prefix
        self.headers = {}

        default_headers = {'Accept': 'application/json',
                           'content-type': 'application/json',
                           'User-Agent': 'katello-cli/0.1'}
        self.headers.update(default_headers)

        if accept_lang:
            self.headers.update( { 'Accept-Language': accept_lang } )

        self._log = getLogger('katello')

    # credentials setters -----------------------------------------------------
    def set_auth_method(self, auth_method):
        self.auth_method = auth_method

    # protected server connection methods -------------------------------------

    def _connect(self):
        # make an appropriate connection to the server and cache it
        return self.auth_method.connect(self.host, self.port, self.protocol)

    def _set_auth_headers(self):
        try:
            self.auth_method.set_headers(self.headers)
        except GSSError, e:
            #TODO
            raise Exception("Missing credentials and unable to authenticate using Kerberos", e)
            #raise KatelloError("Missing credentials and unable to authenticate using Kerberos", e)
        except Exception, e:
            #TODO
            raise Exception("Invalid credentials or unable to authenticate", e)
            #raise KatelloError("Invalid credentials or unable to authenticate", e)

    # protected request utilities ---------------------------------------------

    def _build_url(self, path, queries=None):
        if queries is None:
            queries = {}
        # build the request url from the path and queries dict or tuple
        if not path.startswith(self.path_prefix):
            path = '/'.join((self.path_prefix, path))

        # make sure the path is ascii and uses appropriate characters
        path = urllib.quote(path.encode('utf-8'))
        for key, value in queries.items():
            if isinstance(value, basestring):
                queries[key] = value.encode('utf-8')

        queries = urllib.urlencode(queries)
        if queries:
            path = '?'.join((path, queries))
        return path


    def _request(self, method, path, queries=None, body=None, multipart=False, custom_headers=None):
        if queries is None:
            queries = {}
        if custom_headers is None:
            custom_headers = {}
        # make a request to the server and return the response
        connection = self._connect()
        url = self._build_url(path, queries)

        content_type, body = self._prepare_body(body, multipart)

        self.headers['content-type']   = content_type
        self.headers['content-length'] = str(len(body) if body else 0)
        self._set_auth_headers()

        self._log.debug('sending %s request to %s' % (method, url))

        connection.request(method, url, body=body, headers=dict(self.headers.items() + custom_headers.items()))
        return self._process_response(connection.getresponse())



    def _prepare_body(self, body, multipart):
        """
        Encode body according to needs as json or multipart
        @type body: any
        @param body: data to encode
        @type multipart: boolean
        @param multipart: set True for multipart requests
        @rtype: (string, string)
        @return: tuple of the content type and the encoded body
        """
        content_type = 'application/json'

        if multipart:
            content_type, body = self._encode_multipart_formdata(body)
        elif not isinstance(body, (type(None), Bytes, file)):
            body = json.dumps(body)

        return (content_type, body)


    @classmethod
    def _process_response(cls, response):
        """
        Try to parse the response
        @type response: HTTPResponse
        @param response: http response
        @rtype: (int, string)
        @return: tuple of the response status and response body
        """
        response_body = response.read()
        try:
            response_body = json.loads(response_body, encoding='utf-8')
        except ValueError:
            content_type = response.getheader('content-type')
            if content_type and (content_type.startswith('text/') or content_type.startswith('application/json')):
                response_body = u_str(response_body)
            else:
                pass

        if response.status >= 300:
            # if the server has responded with a python traceback
            # try to split it out
            if isinstance(response_body, basestring) and not response_body.startswith('<html'): # pylint: disable=E1103
                response_body += "\n"
                message, traceback = response_body.split('\n', 1)
                raise ServerRequestError(response.status, message.strip(), traceback.strip())
            raise ServerRequestError(response.status, response_body, None)
        return (response.status, response_body, response.getheaders())


    def _flatten_to_multipart(self, key, data):
        """
        Encode data recursively as if they were sent by http form
        @type key: string
        @param key: name of the parent field (None for the first one)
        @type data: any
        @param data: data to encode
        @rtype: [(string, string)]
        @return: list of tuples of the field name and field value
        """

        if isinstance(data, (dict)):
            #flatten dictionaries
            result = []
            for (subKey, value) in data.items():
                if key is None:
                    name = str(subKey)
                else:
                    name = str(key)+'['+str(subKey)+']'
                result.extend(self._flatten_to_multipart(name, value))
            return result

        elif isinstance(data, (list, tuple)):
            #flatten lists and tuples
            result = []
            for value in data:
                if key is None:
                    name = str(key)
                else:
                    name = str(key)+'[]'
                result.extend(self._flatten_to_multipart(name, value))
            return result

        else:
            #flatten other datatypes
            return [(key, data)]



    def _encode_multipart_formdata(self, data):
        """
        Encode data for httplib request
        @type data: any
        @param data: data to encode for the request
        @rtype: (string, string)
        @return: tuple of the content type and encoded data
        """
        fields = self._flatten_to_multipart(None, data)

        boundary = '----------BOUNDARY_$'
        lines = []

        for (key, value) in fields:
            if isinstance(value, (file)):
                filename = value.name
                content  = value.read()

                lines.append('--' + boundary)
                lines.append('Content-Disposition: form-data; name="%s"; filename="%s"' % (str(key), str(filename)))
                lines.append('Content-Type: %s' % self._get_content_type(filename))
                lines.append('')
                lines.append(content)
            else:
                lines.append('--' + boundary)
                lines.append('Content-Disposition: form-data; name="%s"' % str(key))
                lines.append('')
                lines.append(value)
        lines.append('--' + boundary + '--')
        lines.append('')

        body = '\r\n'.join(lines)
        content_type = 'multipart/form-data; boundary=%s' % boundary
        return content_type, body


    @classmethod
    def _get_content_type(cls, filename):
        """
        Guess content type from file name
        @type filename: string
        @param filename: name of the file to gues type from
        @rtype: string
        @return: http content type
        """
        return mimetypes.guess_type(filename)[0] or 'application/octet-stream'


    # request methods ---------------------------------------------------------
    # pylint: disable=C0103
    def DELETE(self, path, body=None):
        """
        Send a DELETE request to the katello server.
        @type path: str
        @param path: path of the resource to delete
        @rtype: (int, dict or None or str)
        @return: tuple of the http response status and the response body
        @raise ServerRequestError: if the request fails
        """
        return self._request('DELETE', path, body=body)

    def GET(self, path, queries=None, custom_headers=None):
        """
        Send a GET request to the katello server.
        @type path: str
        @param path: path of the resource to get
        @type queries: dict or iterable of tuple pairs
        @param queries: dictionary of iterable of key, value pairs to send as
                        query parameters in the request
        @type custom_headers: dict or iterable of tuple pairs
        @param custom_headers: custom headers
        @rtype: (int, dict or None or str)
        @return: tuple of the http response status and the response body
        @raise ServerRequestError: if the request fails
        """
        return self._request('GET', path, queries, custom_headers=custom_headers)

    def HEAD(self, path):
        """
        Send a HEAD request to the katello server.
        @type path: str
        @param path: path of the resource to check
        @rtype: (int, dict or None or str)
        @return: tuple of the http response status and the response body
        @raise ServerRequestError: if the request fails
        """
        return self._request('HEAD', path)

    def POST(self, path, body=None, multipart=False, custom_headers=None):
        """
        Send a POST request to the katello server.
        @type path: str
        @param path: path of the resource to post to
        @type body: dict or None
        @param body: (optional) dictionary for json encoding of post parameters
        @type multipart: boolean
        @param multipart: set True for multipart posts
        @type custom_headers: dict or iterable of tuple pairs
        @param custom_headers: custom headers
        @rtype: (int, dict or None or str)
        @return: tuple of the http response status and the response body
        @raise ServerRequestError: if the request fails
        """
        return self._request('POST', path, body=body, multipart=multipart, custom_headers=custom_headers)

    def PUT(self, path, body, multipart=False, custom_headers=None):
        """
        Send a PUT request to the katello server.
        @type path: str
        @param path: path of the resource to put
        @type body: dict
        @param body: dictionary for json encoding of resource
        @type multipart: boolean
        @param multipart: set True for multipart puts
        @type custom_headers: dict or iterable of tuple pairs
        @param custom_headers: custom headers
        @rtype: (int, dict or None or str)
        @return: tuple of the http response status and the response body
        @raise ServerRequestError: if the request fails
        """
        return self._request('PUT', path, body=body, multipart=multipart, custom_headers=custom_headers)
