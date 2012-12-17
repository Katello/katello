#!/usr/bin/python
#
# Katello Shell
# Copyright (c) 2012 Red Hat, Inc.
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
#

import os
import sys
import json
import re
import codecs
from mako.template import Template
from optparse import OptionParser
from python_inflector.inflector import Inflector, English

class MethodDocGenerator(object):

    def __params_doc(self, params, index_prefix=None):
        doc = []
        for param in params:
            doc += self.__single_param_doc(param, index_prefix)
        return doc

    def __single_param_doc(self, param, index_prefix=None):
        prefix = index_prefix if index_prefix else ""

        doc = []
        str_index = prefix +"['"+ param.name() +"']"
        doc += [":type  data"+ str_index +": "+ param.expected_type()]
        doc += [":param data"+ str_index +": "+ param.description()]
        if param.inner_params():
            doc += self.__params_doc(param.inner_params(), str_index)
        return doc

    def generate(self, method, indent=""):
        doc = [method.description(), ""]
        doc += self.__params_doc(method.params())
        return indent + ("\n"+indent).join(doc).strip()


class Param(object):

    def __init__(self, json_str):
        self.json = json_str

    def name(self):
        return self.json['name']

    def expected_type(self):
        return self.json['expected_type']

    def description(self):
        return self.json['description']

    def required(self):
        return (self.json['required'] == True)

    def help(self):
        desc = self.json['description']
        if self.required():
            desc += ' (required)'
        return desc

    def inner_params(self):
        return [ Param(p) for p in self.json.get('params', []) ]


class Method(object):

    PATH_PARAM_RE = r":([^/]+)"

    def __init__(self, json_str, resource_name=""):
        self.json = json_str
        self.__resource_name = resource_name

    def __json_url(self):
        return self.json['apis'][0]['api_url']

    def __get_path_params(self):
        return re.findall(self.PATH_PARAM_RE, self.__json_url())

    def path(self):
        url = re.sub(self.PATH_PARAM_RE, "%s", self.__json_url())
        url = '"'+ url +'"'
        if self.__get_path_params():
            url += ' % ('+ ', '.join(self.__get_path_params()) +')'
        return url

    def arguments(self):
        args = ["self"]
        args += self.__get_path_params()
        if self.accepts_data():
            args += [self.data_var_name()]
        return args

    def data_var_name(self):
        if self.http_method() == 'GET':
            return 'queries'
        else:
            return 'data'

    def data_keys(self):
        return (p.name() for p in self.params())

    def accepts_data(self):
        return len(self.json['params']) > 0

    def name(self, safe=False, title=False):
        if self.json['name'].lower() == 'index':
            name = 'list'
        else:
            name = self.json['name']
        if title:
            name = name.title()
        return name.replace(" ", "") if safe else name

    def description(self):
        desc = self.json['full_description']
        if not desc:
            desc = self.name() +" "+ self.__resource_name
        return desc

    def http_method(self):
        return self.json['apis'][0]['http_method']

    def __params(self):
        return [ Param(p) for p in self.json.get('params', []) ]

    def __unnest_params(self, params):
        if self.__can_unnest(params):
            params = params[0].inner_params()
        return params

    @classmethod
    def __can_unnest(cls, params):
        return (len(params) == 1 and params[0].expected_type() == 'hash')

    def param_nest(self):
        if not self.__can_unnest(self.__params()):
            return None
        else:
            return self.__params()[0]

    def params(self, required=False):
        params = self.__unnest_params(self.__params())
        if required:
            params = [p for p in params if p.required()]
        return params


class Resource(object):

    def __init__(self, json_str):
        self.json = json_str
        self.inflector = Inflector(English)

    def get_method(self, name):
        name_dict = dict((m["name"], m) for m in self.json.get('methods', []))
        return Method(name_dict[name], self.name())

    def has_method(self, name):
        return name in [m['name'] for m in self.json.get('methods', [])]

    def methods(self):
        return [Method(m, self.name()) for m in self.json.get('methods', [])]

    def name(self, safe=False, title=False):
        name = self.inflector.singularize(self.json['name']).lower()
        if title:
            name = name.title()
        return name.replace(" ", "") if safe else name





def load_json(filename):
    if filename:
        with open(filename, 'r') as f:
            content = f.read()
    else:
        content = sys.stdin.read()
    return json.loads(content)


def generate_action(resource, method_name):
    mytemplate = Template(filename='./templates/action.py')
    print mytemplate.render_unicode(resource=resource, method=resource.get_method(method_name))

def generate_command(resource):
    mytemplate = Template(filename='./templates/command.py')
    print mytemplate.render_unicode(resource=resource, name=resource.name())

def generate_binding(resource):
    mytemplate = Template(filename='./templates/api.py')
    print mytemplate.render_unicode(resource=resource, doc=MethodDocGenerator())

def generate_main(resource):
    mytemplate = Template(filename='./templates/main.py')
    print mytemplate.render_unicode(resource=resource, name=resource.name(safe=True))


def generate():
    parser = OptionParser()
    parser.add_option("--binding", "--api", action="store_true", help="generate python api bindings")
    parser.add_option("--command", action="store_true", help="generate cli command frame")
    parser.add_option("--action", action="store_true", help="generate cli action for a method")
    parser.add_option("--main", action="store_true", help="generate code for wiring commands and actions into cli")
    parser.add_option("-r", "--resource")
    parser.add_option("-m", "--method")
    parser.add_option("-i", "--input", help="input file with json apipie documentation export")
    opts, dummy = parser.parse_args(sys.argv[1:])

    j = load_json(getattr(opts, 'input'))
    try:
        resource_json = j['docs']['resources'][getattr(opts, 'resource')]
    except KeyError:
        print >> sys.stderr, "Invalid resource. Choose one of: "+ ", ".join(j['docs']['resources'].keys())
        exit(1)
    resource = Resource(resource_json)

    if getattr(opts, 'binding'):
        generate_binding(resource)
    elif getattr(opts, 'command'):
        generate_command(resource)
    elif getattr(opts, 'action'):
        method_name =  getattr(opts, 'method')
        if not resource.has_method(method_name):
            print >> sys.stderr, \
                "Invalid method. Choose one of: " + \
                ", ".join([m['name'] for m in resource.json.get('methods', [])])
            exit(1)
        generate_action(resource, getattr(opts, 'method'))
    elif getattr(opts, 'main'):
        generate_main(resource)
    else:
        print >> sys.stderr, "You have to choose some action"





if __name__ == "__main__":
    # Change encoding of output streams when no encoding is forced via $PYTHONIOENCODING
    # or setting in lib/python{version}/site-packages
    if sys.getdefaultencoding() == 'ascii':
        writer_class = codecs.getwriter('utf-8')
        if sys.stdout.encoding == None:
            sys.stdout = writer_class(sys.stdout)
        if sys.stderr.encoding == None:
            sys.stderr = writer_class(sys.stderr)

    generate()
    sys.exit(os.EX_OK)

