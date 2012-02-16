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
ENVIRONMENTS = ["DEV", "TEST", "STAGE", "PROD"]

def randomString():
    # The characters to make up the random password
    chars = string.ascii_letters + string.digits
    return "".join(random.choice(chars) for x in range(random.randint(8, 16)))     

def create_data(numorgs, numsystems, numproviders, numproducts, numrepos, singleorg):
    # Setup connection to Katello
    admin = AdminCLI()
    admin.setup_parser()
    admin.opts, admin.args = admin.parser.parse_args([])
    admin.setup_server()
    admin._username = "admin"
    admin._password = "admin"
    org_names = []
    if (singleorg):
        # If we pass in a single org name 
        # we just load all the data into that.
        org_names.append(singleorg)
    else:
        # Otherwise just create fake orgs
        orgapi = OrganizationAPI()
        print "Creating [%s] Orgs" % numorgs 
        for i in range(numorgs):
            name = "Org-%s"  % randomString()
            org_names.append(name)
            print "[%s] Creating org with name [%s]" % (i, name)
            orgapi.create(name, "description")
        
    # create envs
    envapi = EnvironmentAPI()

    for i in range(len(org_names)):
        print "[%s] Creating DEV/TEST/STAGE in org: [%s]" % (i, org_names[i])
        libraryId = get_environment(org_names[i], "Library")["id"]
        print "Library ID: %s" % libraryId
        envids = [libraryId]
        for x in range(len(ENVIRONMENTS)):
            existing_env = get_environment(org_names[i], ENVIRONMENTS[x])
            if not existing_env:
                e = envapi.create(org_names[i], ENVIRONMENTS[x], "Desc", envids[x])
                envids.append(e["id"])
            else:
                envids.append(existing_env["id"])

    ## create providers, products and repos
    print "Creating [%s] providers in each org" % numproviders 
    for i in range(len(org_names)):
        for y in range(numproviders):
            provider_name = "Provider-%s" % randomString()
            print "[%s] Creating Provider with name: [%s] in org: [%s] and products + repos" % (y, provider_name, org_names[i])
            providerapi = ProviderAPI()
            provider = providerapi.create(provider_name, org_names[i], "Desc", "Custom", None)
            print "  Creating [%s] Products in each provider" % numproducts 
            for z in range(numproducts):
                product_name = "P-%s" % randomString()
                print "  [%s] Creating product with name: [%s]" % (z, product_name)
                productapi = ProductAPI()
                product = productapi.create(provider["id"], product_name, "Desc", None)
                print "    Creating [%s] Products in each product" % numproducts 
                for x in range(numrepos):
                    repo_name = "Repo-%s" % randomString()
                    print "    [%s] Creating repo with name: [%s]" % (x, repo_name)
                    repoapi = RepoAPI()
                    url = "http://repos.example.com/%s" % repo_name
                    repoapi.create(org_names[i], product["id"], repo_name, url, None, True)
    ## Create systems
    print "Creating [%s] Systems in each org and assigning to random envs" % numsystems 
    for i in range(len(org_names)):
        systemapi = SystemAPI()
        for x in range(numsystems):
            system_name = "System-%s" % randomString()
            randenv = random.choice(ENVIRONMENTS)
            print "Registering system: [%s] in environment: [%s]" % (system_name, randenv)
            system = systemapi.register(system_name, org_names[i], randenv, [], 'system')
            print "[%s] Created system: %s" % (x, system["name"])
        
    
if __name__ == '__main__':
 
    parser = OptionParser("usage: %prog [options]")
    parser.add_option('--numorgs',  dest='numorgs',  type="int")
    parser.add_option('--numsystems',  dest='numsystems', type="int", default=1)
    parser.add_option('--numproviders',  dest='numproviders', type="int", default=1)
    parser.add_option('--numproducts',  dest='numproducts', type="int", default=1)
    parser.add_option('--numrepos',  dest='numrepos', type="int", default=1)
    parser.add_option('--numthreads',  dest='numthreads', type="int", default=1)
    parser.add_option('--singleorg',  dest='singleorg', help="name of singular org to fill", default=None)
    (options, args) = parser.parse_args(sys.argv[1:])
    
    if (options.numorgs and options.singleorg):
        sys.exit("ERROR: You specified --numorgs and --singleorg which contradict each other, please pick only one.")
    elif not options.numorgs and not options.singleorg:
        options.numorgs = 1
    
    threads = []
    for i in range(options.numthreads):
        print "Starting thread: [%s] for a data load" % i
        # numorgs, numsystems, numproviders, numproducts, numrepos, singleorg):
        p = Process(target=create_data, args=(options.numorgs, options.numsystems, \
          options.numproviders, options.numproducts, options.numrepos, options.singleorg,))
        p.start()
        threads.append(p)
    for p in threads:
        p.join()
