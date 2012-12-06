#!/usr/bin/python
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

import csv
import os
import sys
import json
import time
from katello.swexport.config import Config
from katello.client.utils.csv_reader import CSVReader
from collections import defaultdict
from okaara.cli import Command
import xmlrpclib


class ExportBaseCommand(Command):

    def __init__(self, name, description ):
        Command.__init__(self, name, description, self.export)

        self.create_option('--server', 'Server to extract from',
            aliases=['-s'], required=False,
            default=Config.values.server.url)
        self.create_option('--username', 'Username to access the server ',
            aliases=['-u'], required=False,
            default=Config.values.server.username)
        self.create_option('--password', 'Password for the user',
            aliases=['-p'], required=False,
            default=Config.values.server.password)
        self.create_option('--directory',
            'Where to store output files. If not provided, go to std out',
            aliases=['-d'], required=False,
            default=Config.values.export.directory)
        self.create_option('--format', 'Output format (csv or json)',
            aliases=['-f'], required=False,
            default=Config.values.export.outputformat)
        self.create_option('--org-mapping-file',
            'file which provides a mpping between a satellite org id and an org name',
            required=False,
            default=Config.values.mapping.orgs)

        #self.options = None
        self.stats = defaultdict(int)
        self.errors = []
        self.notes = []
        self.client = None
        self.key = None
        self.org_mappings = {}

    def export(self, **kwargs):
        self.options = kwargs

        start = time.clock()
        self._setup_org_mappings()
        self._pre_export()

        try:
            self.client = xmlrpclib.Server(self.options['server'], verbose=0)
            self.key = self.client.auth.login(self.options['username'], self.options['password'])
        except xmlrpclib.Error, e:
            self._add_error("Can not connect to to the Satellite Server: %s" % e.get_message())
            self._dump_stats()
            sys.exit(-1)
        except Exception, e:
            self._add_error("Can not connect to to the Satellite Server: %s" % e.get_message())
            self._dump_stats()
            sys.exit(-1)

        data = self._get_data()
        headers = self._get_headers()
        self._post_export()
        self._add_stat("time (secs)", (time.clock()-start))

        self._dump_data(data, headers)
        self._dump_stats()

    def _setup_org_mappings(self):
        if os.path.exists(self.options['org-mapping-file']):
            org_file = CSVReader(self.options['org-mapping-file'])
            for row in org_file:
                if len(row) == 3:
                    self.org_mappings[row['id']] = (row['name'], row['label'])
                else:
                    self._add_error("Skipping row in org mapping file: %s" % str(row))

    def _pre_export(self):
        pass

    def _post_export(self):
        pass

    def _get_data(self):
        pass

    @property
    def _get_headers(self):
        pass

    @property
    def _output_filename(self):
        pass

    def _translate_org_label(self, org_id):
        new_org = org_id
        if len(self.org_mappings) > 0:
            if str(org_id) in self.org_mappings.keys():
                new_org = self.org_mappings[str(org_id)][1]
            else:
                self._add_note("No Mapping for Org with id %s" % (org_id))
        return new_org

    def _translate_org_name(self, org_id):
        new_org = org_id
        if len(self.org_mappings) > 0:
            if str(org_id) in self.org_mappings.keys():
                new_org = self.org_mappings[str(org_id)][0]
            else:
                self._add_note("No Name Mapping for Org with id %s" % (org_id))
        return new_org

    def _setup_output_file(self, filename):
        if self.options['directory']:
        # Create the output directory
            output_dir = self.options['directory']
            if not os.path.exists(output_dir):
                os.makedirs(output_dir)
            return open(output_dir + "/" + filename, 'w')
        else:
            return sys.stdout

    def _add_stat(self, stat_name, stat_count = 1):
        self.stats[stat_name] += stat_count

    def _add_error(self, string):
        self._add_stat("errors")
        self.errors.append(string)

    def _add_note(self, string):
        self.notes.append(string)

    def _dump_data(self, data_list, keys):
        output_file = self._setup_output_file(self._output_filename())
        if self.options['format'] == 'csv':
            writer = csv.writer(output_file)
            writer.writerow(keys)
            for data in data_list:
                line_data = []
                for key in keys:
                    value = data[key]
                    if type(value) is list:
                        line_data.append(",".join(value))
                    else:
                        line_data.append(value)
                writer.writerow(line_data)
        else:
            json.dump(data_list, output_file)
            output_file.write("\n")

    def _dump_stats(self):
        stats_file = self._setup_output_file(self._output_filename() + "-stats")
        stats_file.write("Stats\n")
        stats_file.write("-----\n")
        for stat in self.stats.keys():
            stats_file.write("%s -> %s\n" % (stat, self.stats[stat]))

        if len(self.errors) > 0:
            stats_file.write("\nErrors\n")
            stats_file.write("------\n")
            for err in self.errors:
                stats_file.write(err + "\n")

        if len(self.notes) > 0:
            stats_file.write("\nNotes\n")
            stats_file.write("-----\n")
            for note in self.notes:
                stats_file.write(note + "\n")

def is_true(item):
    return str(item) in ['T', 't', 'True', 'TRUE', 'true', '1', 'Y', \
        'y', 'YES', 'yes', 'on']

