#!/usr/bin/env python

from optparse import OptionParser
import sys
import random
import string
import urlparse
from multiprocessing import Process, BoundedSemaphore, Manager
from multiprocessing import Pool
from katello.client import server
from katello.client.server import BasicAuthentication, SSLAuthentication
from katello.client.api.system import SystemAPI
from katello.client.api.environment import EnvironmentAPI
from katello.client.api.organization import OrganizationAPI

def random_string():
    """
    Generates a random *alphanumeric* string between 4 and 6 characters
    in length.
    """
    chars = string.ascii_letters + string.digits
    return "".join(random.choice(chars) for x in range(random.randint(4, 6)))

def parse_url(url):
    p_url = urlparse.urlparse(url)
    proto = p_url.scheme
    host = p_url.netloc
    path = p_url.path
    
    
    if proto == 'https':
        port = 443
    elif proto == 'http':
        port = 80
    elif ':' in host and (proto == 'https' or proto == 'http'):
        host, port = host.split(':')
    else:
        sys.stderr.write("[ERROR] Supported protocols are https or http\n")
        sys.exit(-1)

    return(proto,host,path,port)

def get_env_id(org, env):
    envapi = EnvironmentAPI()

    return envapi.environment_by_name(org, env)['id']

def auto_subscribe(org, system):
    sysapi = SystemAPI()
    orgapi = OrganizationAPI()
    
    system_uuid = sysapi.systems_by_org(org, {'name': system})[0]['uuid']
    
    pools = sysapi.available_pools(system_uuid)
    pool_id = pools['pools'][0]['poolId']
    
    if opts.debug:
        print "===== Will attempt to subscribe %s to %s" % (system, pool_id)

    return sysapi.subscribe(system_uuid, pool_id, 1)

def create_subscribed_systems(org, env, sem):

    sysapi = SystemAPI()
    envapi = EnvironmentAPI()
    
    try:
        sem.acquire()
        envid = get_env_id(org, env)
    except Exception, e:
        try:
            lockerid = get_env_id(org, "Library")
            envapi.create(org, env, "Test Environment", lockerid)
            envid = get_env_id(org, env)
        except Exception, e:
            sys.stderr.write("[Error] Failed to find and create requested environment.\n%s\n" % e)
            sys.exit(-1)
    finally:
        sem.release()
    
    if opts.debug:
        print "===== Environment ID: %s" % envid
    
    facts = {
              "distribution.name": "Red Hat Enterprise Linux Server",
              "uname.machine": "x86_64",
              "virt.is_guest": "false",
              "distribution.arch": "x86_64",
              "cpu.cpu_socket(s)" : "2"}
    
    name = "system%s" % random_string()
    print "===== Creating system: %s" % name
    try:
        sem.acquire()
        sysapi.register(name, org, envid, [], 'system', None, None, facts)
    except server.ServerRequestError, e:
        sys.stderr.write("%s\n" % e[1]['displayMessage'])
    finally:
        sem.release()
    
    try:
        sem.acquire()
        auto_subscribe(org, name)
        if opts.debug:
            print "===== Successfully subscribed %s" % name
    except server.ServerRequestError, e:
        sys.stderr.write("[Error] %s \n" % (e[1]['displayMessage']))
    finally:
        sem.release()

if __name__ == '__main__':
    p = OptionParser(usage="usage: %prog [options]", version="%prog 0.01")
    p.add_option('--url', dest='url', help='Fully qualified url for your katello server',
                 default='localhost')
    p.add_option('-u', '--user', dest='username',
            help='Username, default = admin', default='admin')
    p.add_option('-p', '--pass', dest='password',
            help='Password, default = admin', default='admin')
    p.add_option('-n', '--num', dest='maxsystems',
            help='The maximum number of systems to create, default = 1', default=1)
    p.add_option('-o', '--org', dest='org',
            help='Organization to use. Default = ACME_Corporation', default='ACME_Corporation')
    p.add_option('-e', '--env', dest='env',
            help='Environment to use. Default = DEV', default='DEV')
    p.add_option('-d', '--debug', action="store_true", dest='debug', 
                 help='Enable Debug', default=False)

    (opts, args) = p.parse_args()
    
    proto, host, path, port = parse_url(opts.url)
    s = server.KatelloServer(host, port, proto, path)
    s.set_auth_method(BasicAuthentication(opts.username, opts.password))
    server.set_active_server(s)
    
    manager = Manager()
    threads = []
    maxconnections = 4
    sem = manager.BoundedSemaphore(maxconnections)
    pool = Pool(processes=maxconnections*2)

    for i in range(int(opts.maxsystems)):
        if opts.debug:
            print 'Starting thread: [%s] for loadig systems' % i
        pool.apply_async(create_subscribed_systems, args=(opts.org, opts.env, sem))
    pool.close()
    pool.join()
    
