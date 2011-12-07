    adding export generation script for test purposes.
    
    These scripts can be used to setup a candlepin instance as a fake
    'upstream' server with the proper products and entitlements that can be
    then used to generate a manifest export.  Do *NOT* do this to your 
    Candlepin instance used for Katello.  This is used to simulate the 
    upstream entitlement server at Red Hat so you need to set it up on 
    a separate host.
    
    1) setup-candlepin-products.rb : This script sets up candlepin with fake
    products that can then be exported
    
    2) generate-export-zip.rb : This generates the export zip that can be
    imported into Katello.
    
    You also need to sync content to this server that matches the products
    that are generated in the above scripts using Pulp.  You need to examine
    the above scripts to see the structure expected.  Also note that the
    above scripts expect a git checkout in a subdir ./candlepin/ from this
    directory.  Ideally you could symlink to this cwd or just copy them
    elsewhere to a dir above a candlepin git checkout.

    You also need to edit the scripts to point at your candlepin server, note 
    the example.com hostnames.

