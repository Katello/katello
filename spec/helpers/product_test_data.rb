module Katello
  module ProductTestData
    ORG_ID = "admin-org-37070".freeze
    PRODUCT_ID = '37070'.freeze
    PRODUCTS =
      [
        { 'productId' => 'product_1' },
        { 'productId' => 'product_2', 'providedProductIds' => ['p product 1', 'p product 2'] },
        { 'productId' => 'product_3', 'providedProductIds' => ['p product 1', 'p product 3'] },
        { 'productId' => 'product_4', 'providedProductIds' => ['p product 4', 'p product 3'] }
      ].freeze

    PRODUCT_NAME = "Load_Balancing".freeze

    SIMPLE_PRODUCT = {
      :name => ProductTestData::PRODUCT_NAME,
      :label => "product-foo",
      :id => ProductTestData::PRODUCT_ID,
      :cp_id => 1,
      :productContent => [],
      :attrs => [],
      :multiplier => 1,
      :organization_id => 1
    }.with_indifferent_access

    SIMPLE_PRODUCT_WITH_INVALID_NAME = HashWithIndifferentAccess.new(
      :name => 'This name is invalid',
      :label => "foo",
      :id => ProductTestData::PRODUCT_ID,
      :multiplier => 1,
      :productContent => [],
      :attrs => []
    )

    PRODUCT_WITH_ATTRS = HashWithIndifferentAccess.new(
      :name => ProductTestData::PRODUCT_NAME,
      :label => "foo",
      :id => ProductTestData::PRODUCT_ID,
      :multiplier => 1,
      :productContent => [],
      :attrs => [{
        "name" => "version",
        "value" => "1.0"
      },
                 {
                   "name" => "variant",
                   "value" => "ALL"
                 },
                 {
                   "name" => "arch",
                   "value" => "ALL"
                 },
                 {
                   "name" => "type",
                   "value" => "SVC"
                 },
                 {
                   "name" => "sockets",
                   "value" => 2
                 }]
    )

    PRODUCT_WITH_CONTENT = HashWithIndifferentAccess.new(
      :name => ProductTestData::PRODUCT_NAME,
      :label => "dream",
      :id => ProductTestData::PRODUCT_ID,
      :multiplier => 1,
      :productContent => [
        Katello::Candlepin::ProductContent.new(
         "content" => {
           "name" => "some-name(33)",
           "id" => "1234999",
           "type" => "yum",
           "label" => "some-label",
           "vendor" => "redhat",
           "contentUrl" => "/released-extra/RHEL-5-Server/$releasever/$basearch/os/ClusterStorage",
           "gpgUrl" => "/some/gpg/url/",
           "updated" => "2011-01-04T18:47:47.219+0000",
           "created" => "2011-01-04T18:47:47.219+0000"
         }.with_indifferent_access,
         "enabled" => true,
         "flexEntitlement" => 0,
         "physicalEntitlement" => 0
        )
      ],
      :attrs => []
    )

    PRODUCT_WITH_CP_CONTENT = HashWithIndifferentAccess.new(
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
          "created" => "2011-01-04T18:47:47.219+0000"
        }.with_indifferent_access,
        "enabled" => true,
        "flexEntitlement" => 0,
        "physicalEntitlement" => 0}
                         ],
      :attrs => []
    )

    POOLS = HashWithIndifferentAccess.new(
      "id" => "ff808081311ad38001311ae11f4e0010",
      "attributes" => [],
      "owner" => {
        "href" => "/owners/ACME_Corporation",
        "id" => "ff808081311ad38001311ad3b5b60001",
        "key" => "ACME_Corporation_spec",
        "displayName" => "ACME_Corporation_spec"
      },
      "providedProducts" => [

        {
          "id" => "ff808081311ad38001311ae11f4f0011",
          "productName" => "Red Hat Enterprise Linux 6 Server SVC",
          "productId" => "20",
          "updated" => "2011-07-11T20=>26=>26.511+0000",
          "created" => "2011-07-11T20=>26=>26.511+0000"
        }
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

    DERIVED_PROVIDED_PRODUCT = HashWithIndifferentAccess.new(
        "created" => "2013-12-30T16:11:26.000+0000",
        "id" => "8a85f987430cc341014344462dc06c38",
        "productId" => "180",
        "productName" => "Red Hat Beta",
        "updated" => "2013-12-30T16:11:26.000+0000"
    )

    #   PRODUCT_WITHOUT_CONTENT_ID = HashWithIndifferentAccess.new({
    #     :name => ProductTestData::PRODUCT_NAME,
    #     :id => ProductTestData::PRODUCT_ID,
    #     :multiplier => 1,
    #     :productContent => [ { :enabled => ProductTestData::CONTENT_ENABLED } ],
    #     :attributes => {
    #       :version => "1.0",
    #       :variant => "ALL",
    #       :arch => "ALL",
    #       :type => "SVC",
    #       :sockets => 2
    #     }
    #   })
    #
    #   CREATED_CONTENT_URL = "/foo/path/always"
    #   CREATED_CONTENT = {
    #       "flexEntitlement" => 0,
    #       "physicalEntitlement" => 0,
    #       "enabled" => true,
    #       "content" => {
    #         "name" => "always-enabled-content",
    #         "label" => "always-enabled-content",
    #         "contentUrl" => CREATED_CONTENT_URL,
    #         "id" => "1",
    #         "type" => "yum",
    #         "vendor" => "test-vendor",
    #         "gpgUrl" => "/foo/path/always/gpg",
    #         "updated" => "2010-11-25T20:33:28.394+0000",
    #         "created" => "2010-11-25T20:33:28.394+0000"
    #       }
    #   }
    #
    #   CREATED_PRODUCT = {
    #     "href" => "/products/66667",
    #     "name" => ProductTestData::PRODUCT_NAME,
    #     "productContent" => [CREATED_CONTENT],
    #     "multiplier" => 1,
    #     "attributes" => [
    #       {"name" => "version","value" => "1.0","updated" => "2010-11-25T20:02:42.775+0000","created" => "2010-11-25T20:02:42.775+0000"},
    #       {"name" => "variant","value" => "ALL","updated" => "2010-11-25T20:02:42.775+0000","created" => "2010-11-25T20:02:42.775+0000"},
    #       {"name" => "sockets","value" => "2","updated" => "2010-11-25T20:02:42.775+0000","created" => "2010-11-25T20:02:42.775+0000"},
    #       {"name" => "arch","value" => "ALL","updated" => "2010-11-25T20:02:42.775+0000","created" => "2010-11-25T20:02:42.775+0000"},
    #       {"name" => "type","value" => "SVC","updated" => "2010-11-25T20:02:42.775+0000","created" => "2010-11-25T20:02:42.775+0000"}
    #     ],
    #     "id" =>  ProductTestData::PRODUCT_ID,
    #     "updated" => "2010-11-25T20:02:42.775+0000",
    #     "created" => "2010-11-25T20:02:42.775+0000"
    #   }
    #
    #   CREATED_PRODUCT_WITH_NO_CONTENT = {
    #     "href" => "/products/66667",
    #     "name" => ProductTestData::PRODUCT_NAME,
    #     "productContent" => [],
    #     "multiplier" => 1,
    #     "attributes" => [
    #       {"name" => "version","value" => "1.0","updated" => "2010-11-25T20:02:42.775+0000","created" => "2010-11-25T20:02:42.775+0000"},
    #       {"name" => "variant","value" => "ALL","updated" => "2010-11-25T20:02:42.775+0000","created" => "2010-11-25T20:02:42.775+0000"},
    #       {"name" => "sockets","value" => "2","updated" => "2010-11-25T20:02:42.775+0000","created" => "2010-11-25T20:02:42.775+0000"},
    #       {"name" => "arch","value" => "ALL","updated" => "2010-11-25T20:02:42.775+0000","created" => "2010-11-25T20:02:42.775+0000"},
    #       {"name" => "type","value" => "SVC","updated" => "2010-11-25T20:02:42.775+0000","created" => "2010-11-25T20:02:42.775+0000"}
    #     ],
    #     "id" =>  ProductTestData::PRODUCT_ID,
    #     "updated" => "2010-11-25T20:02:42.775+0000",
    #     "created" => "2010-11-25T20:02:42.775+0000"
    #   }
    #
    #   SYNC_STATUS_STARTED = {
    #     "scheduled_time" => 0,
    #     "exception" => nil,
    #     "status_path" => "/pulp/api/repositories/fedora-12333277-admin/sync/5f0f0fbd-4ab7-11e0-8544-0019d1630404/",
    #     "finish_time" => nil,
    #     "start_time" => "1299692425557",
    #     "traceback" => nil,
    #     "method_name" => "_sync",
    #     "state" => "running",
    #     "result" => nil,
    #     "progress" => {
    #       "status" => "downloaded",
    #       "num_success" => 97,
    #       "size_total" => 24060105095,
    #       "num_download" => 0,
    #       "item_name" => "pthsem-2.0.7-3.fc12.i686.rpm",
    #       "items_left" => 23109,
    #       "items_total" => 23206,
    #       "step" => "Downloading Items or Verifying",
    #       "size_left" => 24035997447,
    #       "details" => {
    #         "rpm" => {
    #           "num_success" => 97,
    #           "total_count" => 22161,
    #           "items_left" => 22064,
    #           "size_left" => 23612420259,
    #           "total_size_bytes" => 23636527907,
    #           "num_error" => 0
    #         },
    #         "delta_rpm" => {
    #           "num_success" => 0,
    #           "total_count" => 1045,
    #           "items_left" => 1045,
    #           "size_left" => 423577188,
    #           "total_size_bytes" => 423577188,
    #           "num_error" => 0
    #         }
    #       },
    #       "error_details" => [
    #
    #       ],
    #       "num_error" => 0
    #     },
    #     "id" => "5f0f0fbd-4ab7-11e0-8544-0019d1630404"
    #   }
    #
    #   SYNC_STATUS_FINISHED =  {
    #     "scheduled_time" => 0,
    #     "exception" => nil,
    #     "status_path" => "/pulp/api/repositories/tl-2-3-admin/sync/1ff5c247-4ab8-11e0-b577-0019d1630404/",
    #     "finish_time" => 1299693291,
    #     "start_time" => 1299693291,
    #     "traceback" => nil,
    #     "method_name" => "_sync",
    #     "state" => "finished",
    #     "result" => nil,
    #     "progress" => {
    #       "status" => "FINISHED",
    #       "num_success" => 62,
    #       "size_total" => 40314541,
    #       "num_download" => 0,
    #       "item_name" => nil,
    #       "items_left" => 0,
    #       "items_total" => 62,
    #       "step" => "Finished",
    #       "size_left" => 0,
    #       "details" => {
    #         "rpm" => {
    #           "num_success" => 62,
    #           "total_count" => 62,
    #           "items_left" => 0,
    #           "size_left" => 0,
    #           "total_size_bytes" => 40314541,
    #           "num_error" => 0
    #         }
    #       },
    #       "error_details" => [
    #
    #       ],
    #       "num_error" => 0
    #     },
    #     "id" => "1ff5c247-4ab8-11e0-b577-0019d1630404"
    #   }
    #
    #   SYNC_STATUS_ERRORED =
    #   {
    #     "scheduled_time" => 0,
    #     "exception" => "RepoError()",
    #     "status_path" => "/pulp/api/repositories/test-rhel5-3-admin/sync/632c1d35-4ab9-11e0-bbab-0019d1630404/",
    #     "finish_time" => "1299693291491",
    #     "start_time" => "1299693291483",
    #     "traceback" => [
    #       "Traceback (most recent call last):\n",
    #       "  File \"/home/mmccune/devel/pulp/src/pulp/server/tasking/task.py\", line 131, in run\n    result = self.callable(*self.args, **self.kwargs)\n",
    #       "  File \"/home/mmccune/devel/pulp/src/pulp/server/api/repo.py\", line 1371, in _sync\n    synchronizer)\n",
    #       "  File \"/home/mmccune/devel/pulp/src/pulp/server/api/repo_sync.py\", line 103, in sync\n    repo_dir = synchronizer.sync(repo, repo_source, skip_dict, progress_callback)\n",
    #       "  File \"/home/mmccune/devel/pulp/src/pulp/server/api/repo_sync.py\", line 451, in sync\n    report = self.yum_repo_grinder.fetchYumRepo(store_path, callback=progress_callback)\n",
    #       "  File \"/home/mmccune/devel/grinder/src/grinder/RepoFetch.py\", line 312, in fetchYumRepo\n    self.yumFetch.getRepoData()\n",
    #       "  File \"/home/mmccune/devel/grinder/src/grinder/RepoFetch.py\", line 119, in getRepoData\n    for ftype in self.repo.repoXML.fileTypes():\n",
    #       "  File \"/usr/lib/python2.6/site-packages/yum/yumRepo.py\", line 1413, in <lambda>\n    repoXML = property(fget=lambda self: self._getRepoXML(),\n",
    #       "  File \"/usr/lib/python2.6/site-packages/yum/yumRepo.py\", line 1409, in _getRepoXML\n    raise Errors.RepoError, msg\n",
    #       "RepoError: Cannot retrieve repository metadata (repomd.xml) for repository: . Please verify its path and try again\n"
    #     ],
    #     "method_name" => "_sync",
    #     "state" => "error",
    #     "result" => nil,
    #     "progress" => {
    #       "status" => nil,
    #       "num_success" => 0,
    #       "size_total" => 0,
    #       "num_download" => 0,
    #       "item_name" => nil,
    #       "items_left" => 0,
    #       "items_total" => 0,
    #       "step" => "Downloading Metadata",
    #       "size_left" => 0,
    #       "details" => {
    #
    #       },
    #       "error_details" => [
    #
    #       ],
    #       "num_error" => 0
    #     },
    #     "id" => "632c1d35-4ab9-11e0-bbab-0019d1630404"
    #   }
    #
    #
  end
end
