module Katello
  module OrchestrationHelper
    CERT = <<~HERECERT.freeze
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
    HERECERT

    KEY = <<~HEREKEY.freeze
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
    HEREKEY

    def disable_activation_key_orchestration
      Resources::Candlepin::ActivationKey.stubs(:create).returns(:id => '123')
    end

    def disable_product_orchestration
      Resources::Candlepin::Product.stubs(:add_content).returns(true)
      Resources::Candlepin::Product.stubs(:delete_content).returns(true)
      Resources::Candlepin::Product.stubs(:create).returns(:id => '1')
      Resources::Candlepin::Product.stubs(:create_unlimited_subscription).returns(true)
      Resources::Candlepin::Product.stubs(:pools).returns([])
      Resources::Candlepin::Product.stubs(:delete_subscriptions).returns(nil)

      Resources::Candlepin::Content.stubs(:create).returns(:id => '123', :type => 'yum')
      Resources::Candlepin::Content.stubs(:update).returns(:id => '123', :type => 'yum')

      # pulp orchestration
      Resources::Candlepin::Product.stubs(:certificate).returns("")
      Resources::Candlepin::Product.stubs(:key).returns("")
      Resources::Candlepin::Product.stubs(:product_certificate).returns({})
      Resources::Candlepin::Product.stubs(:destroy).returns(true)
    end

    def disable_pools_orchestration
      Resources::Candlepin::Pool.stubs(:find).returns({})
    end

    def disable_org_orchestration
      Resources::Candlepin::Owner.stubs(:create).returns({})
      Resources::Candlepin::Owner.stubs(:create_user).returns(true)
      Resources::Candlepin::Owner.stubs(:destroy).returns(true)
      Resources::Candlepin::Owner.stubs(:get_ueber_cert).returns(:cert => CERT, :key => KEY)
      Organization.any_instance.stubs(:ensure_not_in_transaction!)
      disable_foreman_tasks_hooks_execution(Organization)
      disable_env_orchestration # env is orchestrated with org - we disable this as well
    end

    def disable_env_orchestration
      disable_foreman_tasks_hooks(KTEnvironment)
      Resources::Candlepin::Environment.stubs(:create).returns({})
      Resources::Candlepin::Environment.stubs(:destroy).returns({})
      Resources::Candlepin::Environment.stubs(:find).returns(:environmentContent => [])
      Resources::Candlepin::Environment.stubs(:add_content).returns({})
      Resources::Candlepin::Environment.stubs(:delete_content).returns({})
    end

    def disable_user_orchestration(_options = {})
      disable_foreman_tasks_hooks(User)
    end

    def disable_foreman_tasks_hooks(model)
      model.any_instance.stubs(create_action: nil, update_action: nil, destroy_action: nil)
    end

    # Don't go into run/finalize phase of the hooked execution plan
    def disable_foreman_tasks_hooks_execution(model)
      model.any_instance.stubs(execute_planned_action: nil)
    end

    def disable_repo_orchestration
      Resources::Candlepin::Content.stubs(:create).returns(:id => '123', :type => 'yum')
      Resources::Candlepin::Content.stubs(:update).returns(:id => '123', :type => 'yum')
      Resources::Candlepin::Content.stubs(:get).returns(:id => '123', :type => 'yum')

      Repository.instance_eval do
        define_method(:index_packages) do
          #do nothing
        end
        define_method(:index_errata) do
          #do nothing
        end
        define_method(:lookup_checksum_type) do
          #do nothing
        end
      end
    end

    def disable_cdn
      Resources::CDN::CdnResource.stubs(:ca_file => "#{Katello::Engine.root}/config/candlepin-ca.crt")
      OpenSSL::X509::Certificate.stubs(:new).returns(&:to_s)
      OpenSSL::PKey::RSA.stubs(:new).returns(&:to_s)
    end

    def method_stub(name, return_data)
      item = stub
      item.stubs(name.to_sym).returns(return_data)
      item
    end
  end
end
