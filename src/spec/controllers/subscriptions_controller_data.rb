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

module SubscriptionsControllerData
  def candlepin_owner_imports action
    case action
      when :manifest_upload_failure
        s = '
[
  {
    "created": "2012-05-30T14:52:45.648+0000",
    "updated": "2012-05-30T14:52:45.648+0000",
    "id": "ff8080813798feb601379915b4d0006b",
    "status": "FAILURE",
    "statusMessage": "ACME_Corporation file did not import successfully."
  },
  {
    "created": "2012-05-29T14:45:13.522+0000",
    "updated": "2012-05-29T14:45:13.522+0000",
    "id": "ff8080813798feb60137990eceb20026",
    "status": "SUCCESS",
    "statusMessage": "ACME_Corporation file imported successfully."
  }
]
'
      when :manifest_upload_success
        s = '
[
  {
    "created": "2012-05-30T14:52:45.648+0000",
    "updated": "2012-05-30T14:52:45.648+0000",
    "id": "ff8080813798feb601379915b4d0006b",
    "status": "SUCCESS",
    "statusMessage": "ACME_Corporation file imported successfully."
  },
  {
    "created": "2012-05-29T14:45:13.522+0000",
    "updated": "2012-05-29T14:45:13.522+0000",
    "id": "ff8080813798feb60137990eceb20026",
    "status": "FAILURE",
    "statusMessage": "ACME_Corporation file did not import successfully."
  }
]
'
      else
        s = ''
    end

    r = JSON.parse(s).collect {|s| s.with_indifferent_access}
    Resources::Candlepin::Owner.stub!(:imports).and_return(r)
  end

  def candlepin_owner_pools action
    case action
      when three_pools
        s = '
[
  {
    "created": "2012-05-29T14:52:45.483+0000",
    "updated": "2012-05-29T14:52:45.483+0000",
    "id": "ff8080813798feb601379915b42b004d",
    "owner": {
      "id": "ff8080813798feb6013798ff20d50001",
      "key": "ACME_Corporation",
      "displayName": "ACME_Corporation",
      "href": "/owners/ACME_Corporation"
    },
    "activeSubscription": true,
    "subscriptionId": "ff8080813798feb601379915b2820048",
    "subscriptionSubKey": "master",
    "sourceEntitlement": null,
    "quantity": 2,
    "startDate": "2012-05-01T04:00:00.000+0000",
    "endDate": "2013-05-01T03:59:59.000+0000",
    "productId": "RH1149049",
    "providedProducts": [
      {
        "created": "2012-05-29T14:52:45.484+0000",
        "updated": "2012-05-29T14:52:45.484+0000",
        "id": "ff8080813798feb601379915b42c0059",
        "productId": "83",
        "productName": "Red Hat Enterprise Linux High Availability (for RHEL Server)"
      }
    ],
    "attributes": [

    ],
    "productAttributes": [
      {
        "created": "2012-05-29T14:52:45.484+0000",
        "updated": "2012-05-29T14:52:45.484+0000",
        "id": "ff8080813798feb601379915b42c004e",
        "name": "support_type",
        "value": "L1-L3",
        "productId": "RH1149049"
      },
      {
        "created": "2012-05-29T14:52:45.484+0000",
        "updated": "2012-05-29T14:52:45.484+0000",
        "id": "ff8080813798feb601379915b42c004f",
        "name": "sockets",
        "value": "8",
        "productId": "RH1149049"
      },
      {
        "created": "2012-05-29T14:52:45.484+0000",
        "updated": "2012-05-29T14:52:45.484+0000",
        "id": "ff8080813798feb601379915b42c0050",
        "name": "type",
        "value": "MKT",
        "productId": "RH1149049"
      },
      {
        "created": "2012-05-29T14:52:45.484+0000",
        "updated": "2012-05-29T14:52:45.484+0000",
        "id": "ff8080813798feb601379915b42c0051",
        "name": "name",
        "value": "High-Availability (8 sockets)",
        "productId": "RH1149049"
      },
      {
        "created": "2012-05-29T14:52:45.484+0000",
        "updated": "2012-05-29T14:52:45.484+0000",
        "id": "ff8080813798feb601379915b42c0052",
        "name": "product_family",
        "value": "Red Hat Applications",
        "productId": "RH1149049"
      },
      {
        "created": "2012-05-29T14:52:45.484+0000",
        "updated": "2012-05-29T14:52:45.484+0000",
        "id": "ff8080813798feb601379915b42c0053",
        "name": "option_code",
        "value": "16",
        "productId": "RH1149049"
      },
      {
        "created": "2012-05-29T14:52:45.484+0000",
        "updated": "2012-05-29T14:52:45.484+0000",
        "id": "ff8080813798feb601379915b42c0056",
        "name": "variant",
        "value": "High availability",
        "productId": "RH1149049"
      },
      {
        "created": "2012-05-29T14:52:45.484+0000",
        "updated": "2012-05-29T14:52:45.484+0000",
        "id": "ff8080813798feb601379915b42c0055",
        "name": "virt_limit",
        "value": "unlimited",
        "productId": "RH1149049"
      },
      {
        "created": "2012-05-29T14:52:45.484+0000",
        "updated": "2012-05-29T14:52:45.484+0000",
        "id": "ff8080813798feb601379915b42c0054",
        "name": "arch",
        "value": "x86_64,x86",
        "productId": "RH1149049"
      },
      {
        "created": "2012-05-29T14:52:45.484+0000",
        "updated": "2012-05-29T14:52:45.484+0000",
        "id": "ff8080813798feb601379915b42c0057",
        "name": "description",
        "value": "Red Hat Applications",
        "productId": "RH1149049"
      },
      {
        "created": "2012-05-29T14:52:45.484+0000",
        "updated": "2012-05-29T14:52:45.484+0000",
        "id": "ff8080813798feb601379915b42c0058",
        "name": "subtype",
        "value": "Layered",
        "productId": "RH1149049"
      }
    ],
    "restrictedToUsername": null,
    "contractNumber": "3020000",
    "accountNumber": "1580789",
    "consumed": 0,
    "exported": 0,
    "productName": "High-Availability (8 sockets)",
    "href": "/pools/ff8080813798feb601379915b42b004d"
  },
  {
    "created": "2012-06-11T18:22:10.660+0000",
    "updated": "2012-06-11T18:22:10.660+0000",
    "id": "ff808081379e16c80137dcc81ae4000e",
    "owner": {
      "id": "ff8080813798feb6013798ff20d50001",
      "key": "ACME_Corporation",
      "displayName": "ACME_Corporation",
      "href": "/owners/ACME_Corporation"
    },
    "activeSubscription": true,
    "subscriptionId": "ff808081379e16c80137dcc81982000d",
    "subscriptionSubKey": "master",
    "sourceEntitlement": null,
    "quantity": -1,
    "startDate": "2012-06-11T00:00:00.000+0000",
    "endDate": "2042-06-04T00:00:00.000+0000",
    "productId": "1339438930179",
    "providedProducts": [

    ],
    "attributes": [

    ],
    "productAttributes": [

    ],
    "restrictedToUsername": null,
    "contractNumber": "",
    "accountNumber": "",
    "consumed": 0,
    "exported": 0,
    "productName": "product",
    "href": "/pools/ff808081379e16c80137dcc81ae4000e"
  },
  {
    "created": "2012-06-13T17:35:32.568+0000",
    "updated": "2012-06-13T17:35:32.568+0000",
    "id": "ff808081379e16c80137e6ea20d80011",
    "owner": {
      "id": "ff8080813798feb6013798ff20d50001",
      "key": "ACME_Corporation",
      "displayName": "ACME_Corporation",
      "href": "/owners/ACME_Corporation"
    },
    "activeSubscription": true,
    "subscriptionId": "ff8080813798feb601379915b2670046",
    "subscriptionSubKey": null,
    "sourceEntitlement": {
      "id": "ff808081379e16c80137e6ea20cd0010",
      "href": "/entitlements/ff808081379e16c80137e6ea20cd0010"
    },
    "quantity": -1,
    "startDate": "2012-05-01T04:00:00.000+0000",
    "endDate": "2013-05-01T03:59:59.000+0000",
    "productId": "RH1316844",
    "providedProducts": [
      {
        "created": "2012-06-13T17:35:32.569+0000",
        "updated": "2012-06-13T17:35:32.569+0000",
        "id": "ff808081379e16c80137e6ea20d90022",
        "productId": "90",
        "productName": "Red Hat Enterprise Linux Resilient Storage (for RHEL Server)"
      },
      {
        "created": "2012-06-13T17:35:32.569+0000",
        "updated": "2012-06-13T17:35:32.569+0000",
        "id": "ff808081379e16c80137e6ea20d90023",
        "productId": "83",
        "productName": "Red Hat Enterprise Linux High Availability (for RHEL Server)"
      }
    ],
    "attributes": [
      {
        "created": "2012-06-13T17:35:32.568+0000",
        "updated": "2012-06-13T17:35:32.568+0000",
        "id": "ff808081379e16c80137e6ea20d80012",
        "name": "requires_host",
        "value": "5a493e20-01cc-466f-b1a5-0bf55431d13b"
      },
      {
        "created": "2012-06-13T17:35:32.568+0000",
        "updated": "2012-06-13T17:35:32.568+0000",
        "id": "ff808081379e16c80137e6ea20d80013",
        "name": "requires_consumer_type",
        "value": "system"
      },
      {
        "created": "2012-06-13T17:35:32.568+0000",
        "updated": "2012-06-13T17:35:32.568+0000",
        "id": "ff808081379e16c80137e6ea20d80014",
        "name": "source_pool_id",
        "value": "ff8080813798feb601379915b44a005b"
      },
      {
        "created": "2012-06-13T17:35:32.568+0000",
        "updated": "2012-06-13T17:35:32.568+0000",
        "id": "ff808081379e16c80137e6ea20d80015",
        "name": "virt_only",
        "value": "true"
      },
      {
        "created": "2012-06-13T17:35:32.568+0000",
        "updated": "2012-06-13T17:35:32.568+0000",
        "id": "ff808081379e16c80137e6ea20d80016",
        "name": "pool_derived",
        "value": "true"
      }
    ],
    "productAttributes": [
      {
        "created": "2012-06-13T17:35:32.568+0000",
        "updated": "2012-06-13T17:35:32.568+0000",
        "id": "ff808081379e16c80137e6ea20d80017",
        "name": "support_type",
        "value": "L1-L3",
        "productId": "RH1316844"
      },
      {
        "created": "2012-06-13T17:35:32.568+0000",
        "updated": "2012-06-13T17:35:32.568+0000",
        "id": "ff808081379e16c80137e6ea20d80018",
        "name": "sockets",
        "value": "8",
        "productId": "RH1316844"
      },
      {
        "created": "2012-06-13T17:35:32.569+0000",
        "updated": "2012-06-13T17:35:32.569+0000",
        "id": "ff808081379e16c80137e6ea20d9001a",
        "name": "variant",
        "value": "Resilient Storage",
        "productId": "RH1316844"
      },
      {
        "created": "2012-06-13T17:35:32.568+0000",
        "updated": "2012-06-13T17:35:32.568+0000",
        "id": "ff808081379e16c80137e6ea20d90019",
        "name": "type",
        "value": "MKT",
        "productId": "RH1316844"
      },
      {
        "created": "2012-06-13T17:35:32.569+0000",
        "updated": "2012-06-13T17:35:32.569+0000",
        "id": "ff808081379e16c80137e6ea20d9001b",
        "name": "option_code",
        "value": "21",
        "productId": "RH1316844"
      },
      {
        "created": "2012-06-13T17:35:32.569+0000",
        "updated": "2012-06-13T17:35:32.569+0000",
        "id": "ff808081379e16c80137e6ea20d9001c",
        "name": "product_family",
        "value": "Red Hat Applications",
        "productId": "RH1316844"
      },
      {
        "created": "2012-06-13T17:35:32.569+0000",
        "updated": "2012-06-13T17:35:32.569+0000",
        "id": "ff808081379e16c80137e6ea20d9001d",
        "name": "name",
        "value": "Resilient Storage (8 sockets)",
        "productId": "RH1316844"
      },
      {
        "created": "2012-06-13T17:35:32.569+0000",
        "updated": "2012-06-13T17:35:32.569+0000",
        "id": "ff808081379e16c80137e6ea20d9001f",
        "name": "virt_limit",
        "value": "unlimited",
        "productId": "RH1316844"
      },
      {
        "created": "2012-06-13T17:35:32.569+0000",
        "updated": "2012-06-13T17:35:32.569+0000",
        "id": "ff808081379e16c80137e6ea20d9001e",
        "name": "arch",
        "value": "x86_64,x86",
        "productId": "RH1316844"
      },
      {
        "created": "2012-06-13T17:35:32.569+0000",
        "updated": "2012-06-13T17:35:32.569+0000",
        "id": "ff808081379e16c80137e6ea20d90020",
        "name": "description",
        "value": "Red Hat Applications",
        "productId": "RH1316844"
      },
      {
        "created": "2012-06-13T17:35:32.569+0000",
        "updated": "2012-06-13T17:35:32.569+0000",
        "id": "ff808081379e16c80137e6ea20d90021",
        "name": "subtype",
        "value": "Layered",
        "productId": "RH1316844"
      }
    ],
    "restrictedToUsername": null,
    "contractNumber": "3020001",
    "accountNumber": "1580789",
    "consumed": 0,
    "exported": 0,
    "productName": "Resilient Storage (8 sockets)",
    "href": "/pools/ff808081379e16c80137e6ea20d80011"
  },
  {
    "created": "2012-05-29T14:52:45.514+0000",
    "updated": "2012-06-13T17:35:32.569+0000",
    "id": "ff8080813798feb601379915b44a005b",
    "owner": {
      "id": "ff8080813798feb6013798ff20d50001",
      "key": "ACME_Corporation",
      "displayName": "ACME_Corporation",
      "href": "/owners/ACME_Corporation"
    },
    "activeSubscription": true,
    "subscriptionId": "ff8080813798feb601379915b2670046",
    "subscriptionSubKey": "master",
    "sourceEntitlement": null,
    "quantity": 2,
    "startDate": "2012-05-01T04:00:00.000+0000",
    "endDate": "2013-05-01T03:59:59.000+0000",
    "productId": "RH1316844",
    "providedProducts": [
      {
        "created": "2012-05-29T14:52:45.515+0000",
        "updated": "2012-05-29T14:52:45.515+0000",
        "id": "ff8080813798feb601379915b44b0067",
        "productId": "90",
        "productName": "Red Hat Enterprise Linux Resilient Storage (for RHEL Server)"
      },
      {
        "created": "2012-05-29T14:52:45.515+0000",
        "updated": "2012-05-29T14:52:45.515+0000",
        "id": "ff8080813798feb601379915b44b0068",
        "productId": "83",
        "productName": "Red Hat Enterprise Linux High Availability (for RHEL Server)"
      }
    ],
    "attributes": [

    ],
    "productAttributes": [
      {
        "created": "2012-05-29T14:52:45.514+0000",
        "updated": "2012-05-29T14:52:45.514+0000",
        "id": "ff8080813798feb601379915b44a005c",
        "name": "support_type",
        "value": "L1-L3",
        "productId": "RH1316844"
      },
      {
        "created": "2012-05-29T14:52:45.514+0000",
        "updated": "2012-05-29T14:52:45.514+0000",
        "id": "ff8080813798feb601379915b44a005d",
        "name": "sockets",
        "value": "8",
        "productId": "RH1316844"
      },
      {
        "created": "2012-05-29T14:52:45.515+0000",
        "updated": "2012-05-29T14:52:45.515+0000",
        "id": "ff8080813798feb601379915b44b005f",
        "name": "variant",
        "value": "Resilient Storage",
        "productId": "RH1316844"
      },
      {
        "created": "2012-05-29T14:52:45.514+0000",
        "updated": "2012-05-29T14:52:45.514+0000",
        "id": "ff8080813798feb601379915b44a005e",
        "name": "type",
        "value": "MKT",
        "productId": "RH1316844"
      },
      {
        "created": "2012-05-29T14:52:45.515+0000",
        "updated": "2012-05-29T14:52:45.515+0000",
        "id": "ff8080813798feb601379915b44b0060",
        "name": "option_code",
        "value": "21",
        "productId": "RH1316844"
      },
      {
        "created": "2012-05-29T14:52:45.515+0000",
        "updated": "2012-05-29T14:52:45.515+0000",
        "id": "ff8080813798feb601379915b44b0061",
        "name": "product_family",
        "value": "Red Hat Applications",
        "productId": "RH1316844"
      },
      {
        "created": "2012-05-29T14:52:45.515+0000",
        "updated": "2012-05-29T14:52:45.515+0000",
        "id": "ff8080813798feb601379915b44b0062",
        "name": "name",
        "value": "Resilient Storage (8 sockets)",
        "productId": "RH1316844"
      },
      {
        "created": "2012-05-29T14:52:45.515+0000",
        "updated": "2012-05-29T14:52:45.515+0000",
        "id": "ff8080813798feb601379915b44b0064",
        "name": "virt_limit",
        "value": "unlimited",
        "productId": "RH1316844"
      },
      {
        "created": "2012-05-29T14:52:45.515+0000",
        "updated": "2012-05-29T14:52:45.515+0000",
        "id": "ff8080813798feb601379915b44b0063",
        "name": "arch",
        "value": "x86_64,x86",
        "productId": "RH1316844"
      },
      {
        "created": "2012-05-29T14:52:45.515+0000",
        "updated": "2012-05-29T14:52:45.515+0000",
        "id": "ff8080813798feb601379915b44b0065",
        "name": "description",
        "value": "Red Hat Applications",
        "productId": "RH1316844"
      },
      {
        "created": "2012-05-29T14:52:45.515+0000",
        "updated": "2012-05-29T14:52:45.515+0000",
        "id": "ff8080813798feb601379915b44b0066",
        "name": "subtype",
        "value": "Layered",
        "productId": "RH1316844"
      }
    ],
    "restrictedToUsername": null,
    "contractNumber": "3020001",
    "accountNumber": "1580789",
    "consumed": 1,
    "exported": 0,
    "productName": "Resilient Storage (8 sockets)",
    "href": "/pools/ff8080813798feb601379915b44a005b"
  }
]
'
      else
        s = ''
    end

    r = JSON.parse(s).collect {|s| s.with_indifferent_access}
    Resources::Candlepin::Owner.stub!(:imports).and_return(r)
  end
end
