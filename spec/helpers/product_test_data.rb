module Katello
  module ProductTestData
    ORG_ID ||= "admin-org-37070".freeze
    PRODUCT_ID ||= '37070'.freeze
    PRODUCTS ||=
      [
        { 'productId' => 'product_1' },
        { 'productId' => 'product_2', 'providedProductIds' => ['p product 1', 'p product 2'] },
        { 'productId' => 'product_3', 'providedProductIds' => ['p product 1', 'p product 3'] },
        { 'productId' => 'product_4', 'providedProductIds' => ['p product 4', 'p product 3'] },
      ].freeze

    PRODUCT_NAME ||= "Load_Balancing".freeze

    SIMPLE_PRODUCT ||= {
      :name => ProductTestData::PRODUCT_NAME,
      :label => "product-foo",
      :id => ProductTestData::PRODUCT_ID,
      :cp_id => 1,
      :attrs => [],
      :multiplier => 1,
      :organization_id => 1,
    }.with_indifferent_access

    SIMPLE_PRODUCT_WITH_INVALID_NAME ||= HashWithIndifferentAccess.new(
      :name => 'This name is invalid',
      :label => "foo",
      :id => ProductTestData::PRODUCT_ID,
      :multiplier => 1,
      :attrs => []
    )

    PRODUCT_WITH_ATTRS ||= HashWithIndifferentAccess.new(
      :name => ProductTestData::PRODUCT_NAME,
      :label => "foo",
      :id => ProductTestData::PRODUCT_ID,
      :multiplier => 1,
      :attrs => [{
        "name" => "version",
        "value" => "1.0",
      },
                 {
                   "name" => "variant",
                   "value" => "ALL",
                 },
                 {
                   "name" => "arch",
                   "value" => "ALL",
                 },
                 {
                   "name" => "type",
                   "value" => "SVC",
                 },
                 {
                   "name" => "sockets",
                   "value" => 2,
                 }]
    )

    PRODUCT_WITH_CONTENT ||= HashWithIndifferentAccess.new(
      :name => ProductTestData::PRODUCT_NAME,
      :label => "dream",
      :id => ProductTestData::PRODUCT_ID,
      :multiplier => 1,
      :attrs => []
    )

    PRODUCT_WITH_CP_CONTENT ||= HashWithIndifferentAccess.new(
      :name => ProductTestData::PRODUCT_NAME,
      :label => "dreamer",
      :id => ProductTestData::PRODUCT_ID,
      :multiplier => 1,
      :productContent => [{
        "content" => {
          "name" => "some-name(33)",
          "id" => "1234999",
          "type" => "yum",
          "label" => "some-label",
          "vendor" => "redhat",
          "contentUrl" => "/released-extra/RHEL-5-Server/$releasever/$basearch/os/ClusterStorage/",
          "gpgUrl" => "/some/gpg/url/",
          "updated" => "2011-01-04T18:47:47.219+0000",
          "created" => "2011-01-04T18:47:47.219+0000",
        },
        "enabled" => true,
        "flexEntitlement" => 0,
        "physicalEntitlement" => 0},
                         ],
      :attrs => {'name' => ProductTestData::PRODUCT_NAME}
    )

    POOLS ||= HashWithIndifferentAccess.new(
      "id" => "ff808081311ad38001311ae11f4e0010",
      "attributes" => [],
      "owner" => {
        "href" => "/owners/ACME_Corporation",
        "id" => "ff808081311ad38001311ad3b5b60001",
        "key" => "ACME_Corporation_spec",
        "displayName" => "ACME_Corporation_spec",
      },
      "providedProducts" => [

        {
          "id" => "ff808081311ad38001311ae11f4f0011",
          "productName" => "Red Hat Enterprise Linux 6 Server SVC",
          "productId" => "20",
          "updated" => "2011-07-11T20=>26=>26.511+0000",
          "created" => "2011-07-11T20=>26=>26.511+0000",
        },
      ],
      "endDate" => "2025-05-29T00=>00=>00.000+0000",
      "startDate" => "2011-07-11T20=>10=>22.519+0000",
      "productName" => "Red Hat Enterprise Linux 6 Server",
      "quantity" => 100,
      "contractNumber" => "",
      "accountNumber" => "5400",
      "consumed" => 0,
      "productId" => "rhel6-server",
      "subscriptionId" => "ff808081311ad38001311ae11ee8000c",
      "sourceEntitlement" => nil,
      "href" => "/pools/ff808081311ad38001311ae11f4e0010",
      "activeSubscription" => true,
      "restrictedToUsername" => nil,
      "updated" => "2011-07-11T20=>26=>26.510+0000",
      "created" => "2011-07-11T20=>26=>26.510+0000"
    )

    DERIVED_PROVIDED_PRODUCT ||= HashWithIndifferentAccess.new(
        "created" => "2013-12-30T16:11:26.000+0000",
        "id" => "8a85f987430cc341014344462dc06c38",
        "productId" => "180",
        "productName" => "Red Hat Beta",
        "updated" => "2013-12-30T16:11:26.000+0000"
    )
  end
end
