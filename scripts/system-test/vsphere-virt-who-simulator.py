#!/usr/bin/env python
# usage:
# vsphere-virt-who-simulator.py -o ACME_Corporation -e Dev host1:guest1,guest2 host3:guest3,guest4

from rhsm.connection import UEPConnection
from optparse import OptionParser

parser = OptionParser()

parser.add_option("-o", "--org", default="ACME_Corporation")
parser.add_option("-e", "--env", default="Dev")

[options, args] = parser.parse_args()

conn = UEPConnection(cert_file="/etc/pki/consumer/cert.pem",key_file="/etc/pki/consumer/key.pem", insecure=True)

# takes array in format ["host1:guest1,guest2","host2:guest3,guest4"]
# returns dict {"host1": ["guest1","guest2"], "host2": ["guest3","guest4"]}
mapping = dict([[host, guests.split(",")] for
		[host, guests] in [arg.split(":")
		for arg in args]])

print conn.hypervisorCheckIn(options.org, options.env, mapping) 
