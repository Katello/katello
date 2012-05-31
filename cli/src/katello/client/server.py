# -*- coding: utf-8 -*-
#
# Copyright © 2011 Red Hat, Inc.
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
import httplib
import locale
import os
import urllib
import mimetypes
from gettext import gettext as _

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
    assert isinstance(server, Server)
    active_server = server

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


class Server(object):
    """
    Base server class.
    @ivar host: host name of the katello server
    @ivar port: port the katello server is listening on (443)
    @ivar protocol: protocol the katello server is using (http, https)
    @ivar path_prefix: mount point of the katello api (/katello/api)
    @ivar headers: dictionary of http headers to send in requests
    """

    def __init__(self, host, port=80, protocol='http', path_prefix=''):
        assert protocol in ('http', 'https')

        self.host = host
        self.port = port
        self.protocol = protocol
        self.path_prefix = path_prefix
        self.headers = {}

    # credentials setters -----------------------------------------------------

    def set_basic_auth_credentials(self, username, password):
        """
        Set username and password credentials for http basic auth
        @type username: str
        @param username: username
        @type password: str
        @param password: password
        """
        raise NotImplementedError('base server class method called')

    def set_ssl_credentials(self, certfile, keyfile):
        """
        Set ssl certificate and public key credentials
        @type certfile: str
        @param certfile: absolute path to the certificate file
        @type keyfile: str
        @param keyfile: absolute path to the public key file
        @raise RuntimeError: if either of the files cannot be found or read
        """
        raise NotImplementedError('base server class method called')

    def set_kerberos_auth(self):
        """
        Set kerberos authentication
        """
        raise NotImplementedError('base server class method called')


    # request methods ---------------------------------------------------------

    def DELETE(self, path, body=None):
        """
        Send a DELETE request to the katello server.
        @type path: str
        @param path: path of the resource to delete
        @rtype: (int, dict or None or str)
        @return: tuple of the http response status and the response body
        @raise ServerRequestError: if the request fails
        """
        raise NotImplementedError('base server class method called')

    def GET(self, path, queries=()):
        """
        Send a GET request to the katello server.
        @type path: str
        @param path: path of the resource to get
        @type queries: dict or iterable of tuple pairs
        @param queries: dictionary of iterable of key, value pairs to send as
                        query parameters in the request
        @rtype: (int, dict or None or str)
        @return: tuple of the http response status and the response body
        @raise ServerRequestError: if the request fails
        """
        raise NotImplementedError('base server class method called')

    def HEAD(self, path):
        """
        Send a HEAD request to the katello server.
        @type path: str
        @param path: path of the resource to check
        @rtype: (int, dict or None or str)
        @return: tuple of the http response status and the response body
        @raise ServerRequestError: if the request fails
        """
        raise NotImplementedError('base server class method called')

    def POST(self, path, body=None, multipart=False):
        """
        Send a POST request to the katello server.
        @type path: str
        @param path: path of the resource to post to
        @type body: dict or None
        @param body: (optional) dictionary for json encoding of post parameters
        @type multipart: boolean
        @param multipart: set True for multipart posts
        @rtype: (int, dict or None or str)
        @return: tuple of the http response status and the response body
        @raise ServerRequestError: if the request fails
        """
        raise NotImplementedError('base server class method called')

    def PUT(self, path, body, multipart=False):
        """
        Send a PUT request to the katello server.
        @type path: str
        @param path: path of the resource to put
        @type body: dict
        @param body: dictionary for json encoding of resource
        @type multipart: boolean
        @param multipart: set True for multipart puts
        @rtype: (int, dict or None or str)
        @return: tuple of the http response status and the response body
        @raise ServerRequestError: if the request fails
        """
        raise NotImplementedError('base server class method called')


# katello server class -----------------------------------------------------------

class KatelloServer(Server):
    """
    Katello server connection class.
    """

    #---------------------------------------------------------------------------
    def __init__(self, host, port=443, protocol='https', path_prefix='/katello/api'):
        super(KatelloServer, self).__init__(host, port, protocol, path_prefix)

        default_headers = {'Accept': 'application/json',
                           'content-type': 'application/json',
                           'User-Agent': 'katello-cli/0.1'}
        self.headers.update(default_headers)

        default_locale = locale.getdefaultlocale()[0]
        if default_locale:
            accept_lang = default_locale.lower().replace('_', '-')
            self.headers.update( { 'Accept-Language': accept_lang } )

        self._log = getLogger('katello')

        self.__certfile = None
        self.__keyfile = None

        self.set_basic_auth_credentials("admin", "admin")

    # protected server connection methods -------------------------------------

    def _http_connection(self):
        return httplib.HTTPConnection(self.host, self.port)

    def _https_connection(self):
        # make sure that passed in username and password overrides cert/key auth
        if None in (self.__certfile, self.__keyfile) or \
                'Authorization' in self.headers:
            return httplib.HTTPSConnection(self.host, self.port)
        ssl_context = SSL.Context('sslv3')
        ssl_context.load_cert(self.__certfile, self.__keyfile)
        self._log.debug('making connection with: %s, %s' %
            (self.__certfile, self.__keyfile))
        return httpslib.HTTPSConnection(self.host,
                                        self.port,
                                        ssl_context=ssl_context)

    def _connect(self):
        # make an appropriate connection to the server and cache it
        if self.protocol == 'http':
            return self._http_connection()
        else:
            return self._https_connection()

    # protected request utilities ---------------------------------------------

    def _build_url(self, path, queries={}):
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


    def _request(self, method, path, queries={}, body=None, multipart=False, customHeaders={}):
        # make a request to the server and return the response
        connection = self._connect()
        url = self._build_url(path, queries)

        content_type, body = self._prepare_body(body, multipart)

        self.headers['content-type']   = content_type
        self.headers['content-length'] = str(len(body) if body else 0)

        self._log.debug('sending %s request to %s' % (method, url))

        connection.request(method, url, body=body, headers=dict(self.headers.items() + customHeaders.items()))
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


    def _process_response(self, response):
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
        except:
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
                if key == None:
                    name = str(subKey)
                else:
                    name = str(key)+'['+str(subKey)+']'
                result.extend(self._flatten_to_multipart(name, value))
            return result

        elif isinstance(data, (list, tuple)):
            #flatten lists and tuples
            result = []
            for value in data:
                if key == None:
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

        BOUNDARY = '----------BOUNDARY_$'
        CRLF = '\r\n'
        L = []

        for (key, value) in fields:
            if isinstance(value, (file)):
                filename = value.name
                content  = value.read()

                L.append('--' + BOUNDARY)
                L.append('Content-Disposition: form-data; name="%s"; filename="%s"' % (str(key), str(filename)))
                L.append('Content-Type: %s' % self._get_content_type(filename))
                L.append('')
                L.append(content)

            else:
                L.append('--' + BOUNDARY)
                L.append('Content-Disposition: form-data; name="%s"' % str(key))
                L.append('')
                L.append(value)
        L.append('--' + BOUNDARY + '--')
        L.append('')

        body = CRLF.join(L)
        content_type = 'multipart/form-data; boundary=%s' % BOUNDARY
        return content_type, body


    def _get_content_type(self, filename):
        """
        Guess content type from file name
        @type filename: string
        @param filename: name of the file to gues type from
        @rtype: string
        @return: http content type
        """
        return mimetypes.guess_type(filename)[0] or 'application/octet-stream'


    # credentials setters -----------------------------------------------------

    def set_basic_auth_credentials(self, username, password):
        raw = ':'.join((username, password))
        encoded = base64.encodestring(raw)[:-1]
        self.headers['Authorization'] = 'Basic ' + encoded

    def set_ssl_credentials(self, certfile, keyfile):
        if not os.access(certfile, os.R_OK):
            raise RuntimeError(_('certificate file %s does not exist or cannot be read')
                               % certfile)
        if not os.access(keyfile, os.R_OK):
            raise RuntimeError(_('key file %s does not exist or cannot be read')
                               % keyfile)
        self.__certfile = certfile
        self.__keyfile = keyfile

    def set_kerberos_auth(self):
        _, ctx = kerberos.authGSSClientInit("HTTP@" + self.host, gssflags=kerberos.GSS_C_DELEG_FLAG|kerberos.GSS_C_MUTUAL_FLAG|kerberos.GSS_C_SEQUENCE_FLAG)
        kerberos.authGSSClientStep(ctx, '')
        self.__tgt = kerberos.authGSSClientResponse(ctx)

        if self.__tgt:
            self.headers['Authorization'] = 'Negotiate %s' % self.__tgt
        else:
            raise RuntimeError(_("Couldn't authenticate via kerberos"))


    # request methods ---------------------------------------------------------

    def DELETE(self, path, body=None):
        return self._request('DELETE', path, body=body)

    def GET(self, path, queries={}, customHeaders={}):
        return self._request('GET', path, queries, customHeaders=customHeaders)

    def HEAD(self, path):
        return self._request('HEAD', path)

    def POST(self, path, body=None, multipart=False, customHeaders={}):
        return self._request('POST', path, body=body, multipart=multipart, customHeaders=customHeaders)

    def PUT(self, path, body, multipart=False, customHeaders={}):
        return self._request('PUT', path, body=body, multipart=multipart, customHeaders=customHeaders)
