#!/usr/bin/python

import datetime
import time
import optparse
import string
import logging
import threading
import sys
import os
import random
from optparse import OptionParser

from multiprocessing import Process
from multiprocessing import Pool


import katello.client.core.repo
from katello.client.core.repo import Create
from katello.client.cli.admin import AdminCLI
from katello.client.api.utils import get_organization, get_product, get_repo, get_environment
from katello.client.api.repo import RepoAPI
from katello.client.api.organization import OrganizationAPI
from katello.client.api.environment import EnvironmentAPI
from katello.client.api.provider import ProviderAPI
from katello.client.api.product import ProductAPI
from katello.client.api.user import UserAPI
from katello.client.api.system import SystemAPI


def randomString():
    # The characters to make up the random password
    chars = string.ascii_letters + string.digits
    return "".join(random.choice(chars) for x in range(random.randint(8, 16)))     

# Defaults that eventually can get set by CLI args
NUM_ORGS = 5
NUM_SYSTEMS = 5
NUM_PROVIDERS = 5
NUM_PRODUCTS = 5
NUM_REPOS = 5
ENVIRONMENTS = ["DEV", "TEST", "STAGE", "PROD"]

def randomString():
    # The characters to make up the random password
    chars = string.ascii_letters + string.digits
    return "".join(random.choice(chars) for x in range(random.randint(8, 16)))     

def create_data():
    # Setup connection to Katello
    admin = AdminCLI()
    admin.setup_parser()
    admin.opts, admin.args = admin.parser.parse_args([])
    admin.setup_server()
    admin._username = "admin"
    admin._password = "admin"
    org_names = []
    orgapi = OrganizationAPI()
    print "Creating [%s] Orgs" % NUM_ORGS 
    for i in range(NUM_ORGS):
        name = "Org-%s"  % randomString()
        org_names.append(name)
        print "[%s] Creating org with name [%s]" % (i, name)
        orgapi.create(name, "description")
        
    # create envs
    envapi = EnvironmentAPI()

    for i in range(NUM_ORGS):
        print "[%s] Creating DEV/TEST/STAGE in org: [%s]" % (i, org_names[i])
        lockerId = get_environment(org_names[i], "Locker")["id"]
        dev = envapi.create(org_names[i], ENVIRONMENTS[0], "Desc", lockerId)
        test = envapi.create(org_names[i], ENVIRONMENTS[1], "Desc", dev["id"])
        stage = envapi.create(org_names[i], ENVIRONMENTS[2], "Desc", test["id"])
        prod = envapi.create(org_names[i], ENVIRONMENTS[3], "Desc", stage["id"])

    ## create providers, products and repos
    print "Creating [%s] providers in each org" % NUM_PROVIDERS 
    for i in range(NUM_ORGS):
        for y in range(NUM_PROVIDERS):
            provider_name = "Provider-%s" % randomString()
            print "[%s] Creating Provider with name: [%s] in org: [%s] and products + repos" % (y, provider_name, org_names[i])
            providerapi = ProviderAPI()
            provider = providerapi.create(provider_name, org_names[i], "Desc", "Custom", None)
            print "  Creating [%s] Products in each provider" % NUM_PRODUCTS 
            for z in range(NUM_PRODUCTS):
                product_name = "P-%s" % randomString()
                print "  [%s] Creating product with name: [%s]" % (z, product_name)
                productapi = ProductAPI()
                product = productapi.create(provider["id"], product_name, "Desc")
                print "    Creating [%s] Products in each product" % NUM_REPOS 
                for x in range(NUM_REPOS):
                    repo_name = "Repo-%s" % randomString()
                    print "    [%s] Creating repo with name: [%s]" % (x, repo_name)
                    repoapi = RepoAPI()
                    url = "http://repos.example.com/%s" % repo_name
                    repoapi.create(product["cp_id"], repo_name, url)
    ## Create systems
    print "Creating [%s] Systems in each org and assigning to random envs" % NUM_SYSTEMS 
    for i in range(NUM_ORGS):
        systemapi = SystemAPI()
        for i in range(NUM_SYSTEMS):
            system_name = "System-%s" % randomString()
            system = systemapi.register(system_name, org_names[i], random.choice(ENVIRONMENTS), [], 'system')
            print "[%s] Created system: %s" % (i, system["name"])
        
    
if __name__ == '__main__':
 
    parser = OptionParser("usage: %prog [options]")
    parser.add_option('--numorgs',  dest='numorgs',  type="int", default=10)
    parser.add_option('--numsystems',  dest='numsystems', type="int", default=10)
    parser.add_option('--numproviders',  dest='numproviders', type="int", default=5)
    parser.add_option('--numproducts',  dest='numproducts', type="int", default=5)
    parser.add_option('--numrepos',  dest='numrepos', type="int", default=5)
    parser.add_option('--numthreads',  dest='numthreads', type="int", default=1)
    (options, args) = parser.parse_args(sys.argv[1:])
    
    NUM_ORGS = options.numorgs
    NUM_SYSTEMS = options.numsystems
    NUM_PROVIDERS = options.numproviders
    NUM_PRODUCTS = options.numproducts 
    NUM_REPOS = options.numrepos
    num_threads = options.numthreads
    
    threads = []
    for i in range(options.numthreads):
        print "Starting thread: [%s] for a data load" % i
        p = Process(target=create_data)
        p.start()
        threads.append(p)
    for p in threads:
        p.join()
#    for i in range(options.numthreads):
#        print "Starting thread: [%s] for a data load" % i
#        dl = DataLoad()
#        threads.append(dl)
#        dl.start()
    
#    while len(threads) > 0:
#        try:
#            threads = [t.join(1) for t in threads if t is not None and t.isAlive()]
#        except KeyboardInterrupt:
#            print "Exiting."
#            sys.exit(0)
