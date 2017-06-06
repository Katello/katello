#!/usr/bin/env python

from optparse import OptionParser
import sys
import random
import string
import urlparse
from multiprocessing import Process, BoundedSemaphore, Manager
from multiprocessing import Pool

try:
    from katello.client import server
    from katello.client.server import BasicAuthentication, SSLAuthentication
    from katello.client.api.system import SystemAPI
    from katello.client.api.environment import EnvironmentAPI
    from katello.client.api.organization import OrganizationAPI
except ImportError, e:
    sys.stderr.write('[Error] %s\n, katello-cli-common package is Required\n' % e)
    sys.exit(-1)

def random_string():
    """
    Generates a random *alphanumeric* string between 4 and 6 characters
    in length.
    """
    chars = string.ascii_letters + string.digits
    return "".join(random.choice(chars) for x in range(random.randint(4, 6)))

def parse_url(url):
    """
    Parse the url passed in to obtain host, protocol, port, and path.
    :param url: string
    """
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
        sys.stderr.write('[Error] Supported protocols are https or http\n')
        sys.exit(-1)

    return(proto,host,path,port)

def get_env_id(org, env):
    """
    Returns the envid based on environment name, passed.
    :param org: string
    :param env: string
    """
    envapi = EnvironmentAPI()

    return envapi.environment_by_name(org, env)['id']

def process_environment(org, env):
    """
    Returns the envid.
    :param org: string
    :param env: string
    """
    envapi = EnvironmentAPI()
    try:
        envid = get_env_id(org, env)
    except Exception, e:
        try:
            lockerid = get_env_id(org, "Library")
            envapi.create(org, env, "Test Environment", lockerid)
            envid = get_env_id(org, env)
        except Exception, e:
            sys.stderr.write('[Error] Failed to find and create requested environment.\n%s\n' % e)
            sys.exit(-1)
    return envid

def get_pool_ids(org):
    """
    Will return a list of pool ids available to a given org.
    :param org: string
    """
    pool_ids = []
    orgapi = OrganizationAPI()
    pools = orgapi.pools(org)
    for i in pools:
        pool_ids.append(i['id'])
    return pool_ids

def auto_subscribe(org, system, pool_ids, randomize):
    """
    Will subscribe a system to an available pool.
    Returns json for created system.
    :param org: string
    :param system: string
    """
    sysapi = SystemAPI()
    
    system_uuid = sysapi.systems_by_org(org, {'name': system})[0]['uuid']
    
    if randomize:
        pool_id = random.choice(pool_ids)
    else:
        pools = sysapi.available_pools(system_uuid)
        pool_id = pools['pools'][0]['poolId']
                
    if opts.debug:
        print "===== Will attempt to subscribe %s to %s" % (system, pool_id)

    return sysapi.subscribe(system_uuid, pool_id, 1)

def create_subscribed_systems(org, envid, pool_ids, randomize, sem):
    """
    Registers a system, name is random into org and environment specified.
    :param org: string
    :param envid: string
    """
    sysapi = SystemAPI()
    counter = 1
    
        
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

    sem.acquire()
    while counter < 1000:
        try:
            auto_subscribe(org, name, pool_ids, randomize)
            print "===== %s Subscribed" % name
            break
        except server.ServerRequestError, e:
            if opts.debug:
                sys.stderr.write("[Error] %s \n" % (e[1]['displayMessage']))
            if randomize:
                if opts.debug:
                    print "Trying to find a suitable subscription, will try %s more times\n" % (1000-counter) 
                counter+=1
    sem.release()

if __name__ == '__main__':
    """
    Parse the command line, create n number of randomly defined systems
    using threads.
    """
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
    p.add_option('-r', '--random', action='store_true', dest='randomize',
                 help='Will randomly select and attempt subscription', default=False)
    p.add_option('-d', '--debug', action='store_true', dest='debug', 
                 help='Enable Debug', default=False)

    (opts, args) = p.parse_args()

    proto, host, path, port = parse_url(opts.url)
    s = server.KatelloServer(host, port, proto, path)
    s.set_auth_method(BasicAuthentication(opts.username, opts.password))
    server.set_active_server(s)

    if opts.randomize:
        print """
        ====================================================
        You have opted to allow the program to randomly 
        select a subscription from all available.  This 
        can increase run time as the application will 
        have to work harder to find a suitable subscription.
        ====================================================
        """
    try:
        envid = process_environment(opts.org, opts.env)
        pool_ids = get_pool_ids(opts.org)
    except Exception, e:
        sys.stderr.write("Error: An exception occurred %s" % e)

    manager = Manager()
    maxconnections = 4
    sem = manager.BoundedSemaphore(maxconnections) 
    pool = Pool(processes=maxconnections*2)


    for i in range(int(opts.maxsystems)):
        if opts.debug:
            print 'Starting thread: [%s] for loadig systems' % i
        pool.apply_async(create_subscribed_systems, args=(opts.org, envid, pool_ids, opts.randomize, sem))
    pool.close()
    pool.join()
