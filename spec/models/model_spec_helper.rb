#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'helpers/repo_test_data'

module OrchestrationHelper

  CERT = <<EOCERT
-----BEGIN CERTIFICATE-----
MIIF7DCCBVWgAwIBAgIIB1AMflT0SrswDQYJKoZIhvcNAQEFBQAwRjElMCMGA1UE
Awwca2lsbGluZy10aW1lLmFwcGxpZWRsb2dpYy5jYTELMAkGA1UEBhMCVVMxEDAO
BgNVBAcMB1JhbGVpZ2gwIBcNMTExMDI4MTE0NjU3WhgPMjExMTEwMjgxMTQ2NTda
MCsxKTAnBgNVBAMTIDQwMjg4YWU5MzM0YTQ2NDgwMTMzNGE1YWIxOGIwMDIzMIIB
IjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAlkidXB/p2Vj5zGF9Uh3WxvD6
175G1JmA6kARy14ZlyEKVoWOIvnbhHWi6bVrxtLLEvLBXeX8uJHnP+I/bthBDMfR
3+yBBMrShnTKvTJz/pZk6HG0leEIM4P6y44oU1tWzv6YZrMMcUAXYQQXZ2sQox9x
6U36DIx04eQq5sXJSa63N4u83QDSAqu/bLPmxqAtJiQqQmWNXMIq3XRHF48enyQs
jkOfX5PTetnQ7v3BZfNi/kLRFbjNc50G8OBCmbkOxA8rn89mgzsXh5idW6hWGEAT
QuRF41XdSxovxYxX6s4o7D4proy3DJ0Pl8sOZ7E92i0bKFd0m/g+ycuhU7IhiQID
AQABo4IDdjCCA3IwEQYJYIZIAYb4QgEBBAQDAgWgMAsGA1UdDwQEAwIEsDB2BgNV
HSMEbzBtgBSeBpCjqSPJU+P8K0b/jJXah4Ihs6FKpEgwRjElMCMGA1UEAwwca2ls
bGluZy10aW1lLmFwcGxpZWRsb2dpYy5jYTELMAkGA1UEBhMCVVMxEDAOBgNVBAcM
B1JhbGVpZ2iCCQCGNM1iCrkwyzAdBgNVHQ4EFgQUuSfF3giYzykEkdAeFnxgY405
JHwwEwYDVR0lBAwwCgYIKwYBBQUHAwIwNAYQKwYBBAGSCAkBprTS6t4xAQQgDB5B
Q01FX0NvcnBvcmF0aW9uX3VlYmVyX3Byb2R1Y3QwFgYQKwYBBAGSCAkBprTS6t4x
AwQCDAAwFgYQKwYBBAGSCAkBprTS6t4xAgQCDAAwGQYQKwYBBAGSCAkCprTS6t9i
AQQFDAN5dW0wJAYRKwYBBAGSCAkCprTS6t9iAQEEDwwNdWViZXJfY29udGVudDAy
BhErBgEEAZIICQKmtNLq32IBAgQdDBsxMzE5ODAyNDE2OTQ1X3VlYmVyX2NvbnRl
bnQwHQYRKwYBBAGSCAkCprTS6t9iAQUECAwGQ3VzdG9tMCgGESsGAQQBkggJAqa0
0urfYgEGBBMMES9BQ01FX0NvcnBvcmF0aW9uMBcGESsGAQQBkggJAqa00urfYgEH
BAIMADAYBhErBgEEAZIICQKmtNLq32IBCAQDDAExMC4GCisGAQQBkggJBAEEIAwe
QUNNRV9Db3Jwb3JhdGlvbl91ZWJlcl9wcm9kdWN0MDAGCisGAQQBkggJBAIEIgwg
NDAyODhhZTkzMzRhNDY0ODAxMzM0YTVhYjA1NjAwMWYwHQYKKwYBBAGSCAkEAwQP
DA0xMzE5ODAyNDE2OTQ1MBEGCisGAQQBkggJBAUEAwwBMTAkBgorBgEEAZIICQQG
BBYMFDIwMTEtMTAtMjhUMTE6NDY6NTdaMCQGCisGAQQBkggJBAcEFgwUMjExMS0x
MC0yOFQxMTo0Njo1N1owEQYKKwYBBAGSCAkEDAQDDAEwMBEGCisGAQQBkggJBA4E
AwwBMDARBgorBgEEAZIICQQLBAMMATEwNAYKKwYBBAGSCAkFAQQmDCQ4NTQ5NWNm
MC0xMDVkLTRmMGQtYTE1My0xNTk0NWU3MzA5MjkwDQYJKoZIhvcNAQEFBQADgYEA
Psupe2mDhsluG7uy3dHNjUMER5YtZ3enrgVOyJZMMCLOnH8uprCdeS6sGsytucSD
hqAQBzKqeQEoRml1CIZHgB7Q5OmVN+FC0ftv+Iy/PccyIFdcJh87UAI+1UoT80kR
A5qqap7hk8CDz3HWi9/YGGU89EjLlFpSF5SPbFAWpA8=
-----END CERTIFICATE-----
EOCERT

  KEY = <<EOKEY
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAlkidXB/p2Vj5zGF9Uh3WxvD6175G1JmA6kARy14ZlyEKVoWO
IvnbhHWi6bVrxtLLEvLBXeX8uJHnP+I/bthBDMfR3+yBBMrShnTKvTJz/pZk6HG0
leEIM4P6y44oU1tWzv6YZrMMcUAXYQQXZ2sQox9x6U36DIx04eQq5sXJSa63N4u8
3QDSAqu/bLPmxqAtJiQqQmWNXMIq3XRHF48enyQsjkOfX5PTetnQ7v3BZfNi/kLR
FbjNc50G8OBCmbkOxA8rn89mgzsXh5idW6hWGEATQuRF41XdSxovxYxX6s4o7D4p
roy3DJ0Pl8sOZ7E92i0bKFd0m/g+ycuhU7IhiQIDAQABAoIBABkmne9FCAXv9h5W
Unrjs4Yn3lMs7P23kvOhNVkrrmy0gt5oC5me5zYL2e/zBM6JiKLrLaFhVCIviNwQ
KT2Lw5c3+c/X7N+4cfM+qI9xWihJUynznZ1Xw9+bPuXCLM2Gg8iwoyDM5lAtwbvi
y2frayVhpda9zhM7jnQfk257u2wxJ2Ib3lLH6q+jBBLpkvPLGbX0kKk10CjvwVH4
EeUm6xFtRBYqoleqgoApnun2rzWREDFvUvRXbT6/XwERbk8lie06NFczyE3yYUK9
JTB0DEG7tVUhRr94PTO2xrORpk8h27FJ3gWUPv9ilnm6CGV7m9MzDtX2suL2OMZ1
AZmPQWECgYEA1ezduITs0Kv4sxHrBzSzpnU+DHBLleenpGuhZWyN+ouZG8Arnbkp
pLbOEFQ/NPrN8vJ8G4SVg7QUkD4u6j9POjz/j6Gxca79x3b5sJ/1uwuWLn+HH9bw
VT8luTZ+m1v8k3EGB8vG7UZPEKG7d/+zseIpn7fz99ynBrUO/oVs+wsCgYEAs9dk
/1WBTGmcvcqwFrcgrkCH2kc2sLfENJ5rKLA2udJeT0cfFxHa6f0WatBj9aHZrfr7
czGqcKEtBVh+kgmoi3Qa9oV9YmVy69xgAAWcph43c/Yvf0kbGxf/zAYtEAF2xQXT
gPEY9fGWfsRhUtK0Ih+gGNMJd0sl/5Sx/cY4kjsCgYAyUh11og7ypwFBXh2i/Eqm
BT4rPt8IzA0rKAY3DWn4XY4OcQ3RdBTPohCm1qpnk/eOBmwbLPzeliWgKIBwqaPB
V0fmSWqsCzW3Dc1+NqJe9ULGfUkTvEOcSdZd0uvFL8YiCJwaiVypw7gleWXXvFZQ
qZqQ73x7+XNwqHZ2eHxCMQKBgBmpuvfUs8a7q2pJ6ibTqw4ylzBGyT8eehkoIhKE
UsrhgiO9+mnIWnzZaMGFSz5aAj4ZephNlgzMcyg4IJemWS7NOqvDEMlhwKx3nhti
sZ/i3/bkQpLfU8bh/daXawbFrrUex7e2r+EowFkGnPy8pIfaC3Z/ZvJm/t0h0uRr
zNbRAoGBAMTVtQPbco6EV38wYKFpZfMd0VZSGEGwZVlmkB1CQdeLluZxWjdzm+hv
rKH9OkgKEvwkf8zQjO/XSvuoac83uBEFgKXJwYLHPA3U20JrchKU7klLwzSsmrXA
5JP55pqMjeCZBj2fNkfWrcNPQVdxq25zggRbM6Bmsl0JylpTr3Mt
-----END RSA PRIVATE KEY-----
EOKEY


  def disable_product_orchestration
    Resources::Candlepin::Product.stub!(:get).and_return do
      [{ :productContent => [] }] #return a fresh hash, as add_repo modified it
    end
    Resources::Candlepin::Product.stub!(:add_content).and_return(true)
    Resources::Candlepin::Product.stub!(:delete_content).and_return(true)
    Resources::Candlepin::Product.stub!(:create).and_return({ :id => '1' })
    Resources::Candlepin::Product.stub!(:create_unlimited_subscription).and_return(true)
    Resources::Candlepin::Product.stub!(:pools).and_return([])
    Resources::Candlepin::Product.stub!(:delete_subscriptions).and_return(nil)

    Resources::Candlepin::Content.stub!(:create).and_return({ :id => '123', :type=>'yum' })
    Resources::Candlepin::Content.stub!(:update).and_return({ :id => '123', :type=>'yum' })

    # pulp orchestration
    Resources::Candlepin::Product.stub!(:certificate).and_return("")
    Resources::Candlepin::Product.stub!(:key).and_return("")

    if Katello.config.katello?
      Runcible::Extensions::Repository.stub!(:create_or_update_schedule).and_return(true)
      Runcible::Extensions::Repository.stub!(:remove_schedules).and_return(true)
    end
  end

  def disable_pools_orchestration
    Resources::Candlepin::Pool.stub!(:find).and_return({})
  end

  def disable_org_orchestration
    Resources::Candlepin::Owner.stub!(:create).and_return({})
    Resources::Candlepin::Owner.stub!(:create_user).and_return(true)
    Resources::Candlepin::Owner.stub!(:destroy).and_return(true)
    Resources::Candlepin::Owner.stub!(:get_ueber_cert).and_return({ :cert => CERT, :key => KEY })
    disable_env_orchestration # env is orchestrated with org - we disable this as well
  end

  def disable_env_orchestration
    Resources::Candlepin::Environment.stub!(:create).and_return({})
    Resources::Candlepin::Environment.stub!(:destroy).and_return({})
    Resources::Candlepin::Environment.stub!(:find).and_return({ :environmentContent => [] })
    Resources::Candlepin::Environment.stub!(:add_content).and_return({})
    Resources::Candlepin::Environment.stub!(:delete_content).and_return({})
  end

  def disable_system_orchestration
    Resources::Candlepin::Consumer.stub!(:get).and_return({})
  end

  def disable_user_orchestration(options = {})
    if Katello.config.katello?
      Runcible::Resources::User.stub!(:create).and_return({})
      Runcible::Resources::User.stub!(:delete).and_return(200)
      Runcible::Resources::Role.stub!(:add).and_return(true)
      Runcible::Resources::Role.stub!(:remove).and_return(true)
    end

  end


  def disable_consumer_group_orchestration
    Runcible::Extensions::ConsumerGroup.stub!(:create).and_return({})
    Runcible::Extensions::ConsumerGroup.stub!(:delete).and_return(200)
    Runcible::Extensions::ConsumerGroup.stub!(:retrieve).and_return({})
    Runcible::Extensions::ConsumerGroup.stub!(:add_consumers_by_id).and_return(200)
    Runcible::Extensions::ConsumerGroup.stub!(:remove_consumers_by_id).and_return(200)
  end

  def disable_repo_orchestration
    if Katello.config.katello?
      Runcible::Extensions::Repository.stub(:create).and_return({})
      Runcible::Extensions::Repository.stub(:sync_history).and_return([])
      Runcible::Resources::Task.stub!(:destroy).and_return({})

      Runcible::Extensions::Repository.stub(:packages).with(RepoTestData::REPO_ID).and_return(RepoTestData::REPO_PACKAGES)
      Runcible::Extensions::Repository.stub(:errata).with(RepoTestData::REPO_ID).and_return(RepoTestData::REPO_ERRATA)
      Runcible::Extensions::Repository.stub(:distributions).with(RepoTestData::REPO_ID).and_return(RepoTestData::REPO_DISTRIBUTIONS)
      Runcible::Extensions::Repository.stub(:find).with(RepoTestData::REPO_ID).and_return(RepoTestData::REPO_PROPERTIES)
      Runcible::Extensions::Repository.stub(:find).with(RepoTestData::CLONED_REPO_ID).and_return(RepoTestData::CLONED_PROPERTIES)
    end

    Resources::Candlepin::Content.stub!(:create).and_return({ :id => '123', :type=>'yum'})
    Resources::Candlepin::Content.stub!(:update).and_return({ :id => '123', :type=>'yum' })
    Resources::Candlepin::Content.stub!(:get).and_return({ :id => '123', :type=>'yum'})

    Repository.instance_eval do
      define_method(:index_packages) {
        #do nothing
      }
      define_method(:index_errata) {
        #do nothing
      }
    end
  end

  def disable_cdn
    Resources::CDN::CdnResource.stub(:ca_file => "#{Rails.root}/config/candlepin-ca.crt")
    OpenSSL::X509::Certificate.stub(:new).and_return(&:to_s)
    OpenSSL::PKey::RSA.stub(:new).and_return(&:to_s)
  end

end
