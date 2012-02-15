#!/usr/bin/ruby

require  "./candlepin/candlepin/client/ruby/candlepin_api"
#require  "./client/ruby/candlepin_api"
require 'pp'

ADMIN_USERNAME = "admin"
ADMIN_PASSWORD = "admin"
HOST = "somecandlepinhost.example.com"
PORT = 8443

def random_string prefix=nil
  prefix ||= "rand"
  return "#{prefix}-#{rand(100000)}"
end

cp = Candlepin.new(ADMIN_USERNAME, ADMIN_PASSWORD, nil, nil, HOST, PORT)

cp.create_owner('admin')
owner = cp.get_owner('admin')
end_date = Date.new(2025, 5, 29)

# RHUI
rhui_mkt = cp.create_product("rhui", "RHUI")
rhui_svc = cp.create_product("1", "RHUI SVC")

rhui_content = cp.create_content("RHUI x86 Content", 1, "rhui-x86-content", "yum",
  "redhat", {:content_url => "/content/dist/rhel/rhui/server/5Server/i386/rhui/1.2/os/"})
rhui_x86_64_content = cp.create_content("RHUI x86_64 Content", 2, "rhui-x86_64-content", "yum",
  "redhat", {:content_url => "/content/dist/rhel/rhui/server/5Server/x86_64/rhui/1.2/os/"})

cp.add_content_to_product(rhui_svc['id'], rhui_content['id'])
cp.add_content_to_product(rhui_svc['id'], rhui_x86_64_content['id'])

cp.create_subscription(owner['key'], rhui_mkt['id'], 500000, [rhui_svc['id']], '', '1000', nil, end_date)


# Fedora 14
fedora14_mkt = cp.create_product("fedora14", "Fedora 14")
fedora14_svc = cp.create_product("10", "Fedora 14 SVC")

fedora14_content = cp.create_content("Fedora 14 x86 Content", 10, "fedora14-x86-content", "yum",
  "fedora", {:content_url => "/pub/fedora/linux/releases/14/Fedora/i386/os/"})
fedora14_x86_64_content = cp.create_content("Fedora 14 x86_64 Content", 11, "fedora14-x86_64-content", "yum",
  "fedora", {:content_url => "/pub/fedora/linux/releases/14/Fedora/x86_64/os/"})

cp.add_content_to_product(fedora14_svc['id'], fedora14_content['id'])
cp.add_content_to_product(fedora14_svc['id'], fedora14_x86_64_content['id'])

cp.create_subscription(owner['key'], fedora14_mkt['id'], 500000, [fedora14_svc['id']], '', '6700', nil, end_date)



# RHEL 6
rhel6_mkt = cp.create_product("rhel6-server", "Red Hat Enterprise Linux 6 Server")
rhel6_svc = cp.create_product("20", "Red Hat Enterprise Linux 6 Server SVC")

rhel6_content = cp.create_content("RHEL 6 x86 Content", 20, "rhel6-x86-content", "yum",
  "redhat", {:content_url => "/content/dist/rhel/rhui/server-6/releases/6Server/i386/os"})
rhel6_x86_64_content = cp.create_content("RHEL 6 x86_64 Content", 21, "rhel6-x86_64-content", "yum",
  "redhat", {:content_url => "/content/dist/rhel/rhui/server-6/releases/6Server/x86_64/os"})

cp.add_content_to_product(rhel6_svc['id'], rhel6_content['id'])
cp.add_content_to_product(rhel6_svc['id'], rhel6_x86_64_content['id'])

cp.create_subscription(owner['key'], rhel6_mkt['id'], 500000, [rhel6_svc['id']], '', '5400', nil, end_date)

cp.refresh_pools(owner['key'])
