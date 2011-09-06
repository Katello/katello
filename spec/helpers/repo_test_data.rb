#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http =>//www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module RepoTestData
  REPO_NAME = 'repo'

  REPO_ID = 'repository_id'
  CLONED_REPO_ID = 'cloned_repository_id'
  CLONED_2_REPO_ID = 'cloned_2_repository_id'

  REPO_PRODUCT_ID = 1313597888827
  REPO_PRODUCT_CP_ID = 4312314881818
  REPO_ENV_ID = 3
  REPO_ORG_ID = 2
  CLONED_REPO_ENV_ID = 4

  REPO_PROPERTIES = {
    :id => REPO_ID,
    :name => REPO_NAME,
    :arch => 'architecture',
    :feed => 'url',
    "groupid" => [
      "product:"+REPO_PRODUCT_CP_ID.to_s,
      "env:"+REPO_ENV_ID.to_s,
      "org:"+REPO_ORG_ID.to_s
    ],
    "clone_ids" => [
      CLONED_REPO_ID
    ],
  }.with_indifferent_access

  CLONED_PROPERTIES = {
    :id => CLONED_REPO_ID,
    :name => REPO_NAME,
    :arch => 'architecture',
    :feed => 'url',
    "groupid" => [
      "product:"+REPO_PRODUCT_CP_ID.to_s,
      "env:"+CLONED_REPO_ENV_ID.to_s,
      "org:"+REPO_ORG_ID.to_s
    ],
    "clone_ids" => [
    ],
  }.with_indifferent_access

  REPO_PACKAGES = [
    {
      "size" => 2244,
      "license" => "GPLv2",
      "vendor" => "",
      "name" => "elephant",
      "repo_defined" => true,
      "buildhost" => "buildhost.redhat.com",
      "checksum" => {
        "sha256" => "3e1c70cd1b421328acaf6397cb3d16145306bb95f65d1b095fc31372a0a701f3"
      },
      "requires" => [
        "/bin/sh"
      ],
      "download_url" => "https =>//localhost//pulp/repos/1313581687514-prod_a1_dummy_repos_zoo-ACME_Corporation/elephant-0.3-0.8.noarch.rpm",
      "filename" => "elephant-0.3-0.8.noarch.rpm",
      "epoch" => "0",
      "version" => "0.3",
      "provides" => [
        "elephant"
      ],
      "_ns" => "packages",
      "release" => "0.8",
      "group" => "Internet/Applications",
      "_id" => "8753bea9-d4d2-430e-8593-6d1dd583ce75",
      "arch" => "noarch",
      "id" => "8753bea9-d4d2-430e-8593-6d1dd583ce75",
      "description" => "A dummy package of elephant"
    }.with_indifferent_access,
    {
      "size" => 2232,
      "license" => "GPLv2",
      "vendor" => "",
      "name" => "cheetah",
      "repo_defined" => true,
      "buildhost" => "buildhost.redhat.com",
      "checksum" => {
        "sha256" => "422d0baa0cd9d7713ae796e886a23e17f578f924f74880debdbb7d65fb368dae"
      },
      "requires" => [
        "/bin/sh"
      ],
      "download_url" => "https =>//localhost//pulp/repos/1313581687514-prod_a1_dummy_repos_zoo-ACME_Corporation/cheetah-0.3-0.8.noarch.rpm",
      "filename" => "cheetah-0.3-0.8.noarch.rpm",
      "epoch" => "0",
      "version" => "0.3",
      "provides" => [
        "cheetah"
      ],
      "_ns" => "packages",
      "release" => "0.8",
      "group" => "Internet/Applications",
      "_id" => "7005d70b-e097-4285-a5c0-773b8b59ec9d",
      "arch" => "noarch",
      "id" => "7005d70b-e097-4285-a5c0-773b8b59ec9d",
      "description" => "A dummy package of cheetah"
    }.with_indifferent_access
  ]

  REPO_ERRATA = [
    {
      "_id" => "RHEA-2010 =>9983",
      "type" => "enhancements",
      "id" => "RHEA-2010 =>9983",
      "title" => "Zoo package enhancements"
    }.with_indifferent_access,
    {
      "_id" => "RHEA-2010 =>9984",
      "type" => "enhancements",
      "id" => "RHEA-2010 =>9984",
      "title" => "Zoo package enhancements"
    }.with_indifferent_access
  ]

  REPO_PACKAGE_GROUPS = {
    "123" =>
    {"name" => "katello",
     "conditional_package_names" => {},
     "mandatory_package_names" => [],
     "default" => true,
     "_id" => "123",
     "langonly" => nil,
     "id" => "123",
     "immutable" => false,
     "optional_package_names" => [],
     "default_package_names" => ["pulp-test-package-0.2.1-1.fc11.x86_64.rpm"],
     "translated_description" => {},
     "user_visible" => true,
     "display_order" => 1024,
     "repo_defined" => false,
     "description" => "Katello related packages",
     "translated_name" => {}
    }
  }.with_indifferent_access

  REPO_PACKAGE_GROUP_CATEGORIES = {
    "development" => 
    {"name" => "Development",
     "_id" => "development",
     "id" => "development",
     "immutable" => false,
     "translated_description" => {},
     "display_order" => 99,
     "repo_defined" => false,
     "description" => "",
     "packagegroupids" => ["123"],
     "translated_name" => {}}
  }.with_indifferent_access

  REPO_DISTRIBUTIONS = [
    {
    }
  ]

  SUCCESSFULL_SYNC_HISTORY = [
      {
        "scheduled_time" => nil,
        "exception" => nil,
        "traceback" => nil,
        "job_id" => nil,
        "status_path" => "/pulp/api/repositories/1313597888827-prod_a1_dummy_repos_zoo-ACME_Corporation/sync/24ca1782-c8ef-11e0-b3bb-0024d78b4ebc/",
        "class_name" => nil,
        "start_time" => "2011-08-17T18:37:06+02:00",
        "args" => [
          "1313597888827-prod_a1_dummy_repos_zoo-ACME_Corporation"
        ],
        "method_name" => "_sync",
        "finish_time" => "2011-08-17T18:37:12+02:00",
        "state" => "finished",
        "result" => true,
        "scheduler" => "immediate",
        "progress" => {
          "status" => "FINISHED",
          "num_success" => 8,
          "size_total" => 17872,
          "num_download" => 8,
          "item_name" => nil,
          "items_left" => 0,
          "items_total" => 8,
          "item_type" => "",
          "step" => "Importing data into pulp",
          "size_left" => 0,
          "details" => {
            "rpm" => {
              "num_success" => 8,
              "total_count" => 8,
              "items_left" => 0,
              "size_left" => 0,
              "total_size_bytes" => 17872,
              "num_error" => 0
            }
          },
          "error_details" => [

          ],
          "num_error" => 0
        },
        "id" => "24ca1782-c8ef-11e0-b3bb-0024d78b4ebc"
      }.with_indifferent_access
  ]

  LAST_SUCC_SYNC_START = "2011-08-17 16:37:06"
  LAST_SUCC_SYNC_FINISH = "2011-08-17 16:37:12"

  UNSUCCESSFULL_SYNC_HISTORY = [
      {
          "scheduled_time" => nil,
          "exception" => nil,
          "traceback" => nil,
          "job_id" => nil,
          "status_path" => "/pulp/api/repositories/1313597888827-prod_a1_dummy_repos_zoo-ACME_Corporation/sync/3b83eda3-c8f1-11e0-a41d-0024d78b4ebc/",
          "class_name" => nil,
          "start_time" => "2011-08-17T18:52:03+02:00",
          "args" => [
            "1313597888827-prod_a1_dummy_repos_zoo-ACME_Corporation"
          ],
          "method_name" => "_sync",
          "finish_time" => "2011-08-17T18:52:08+02:00",
          "state" => "canceled",
          "result" => nil,
          "scheduler" => "immediate",
          "progress" => {
            "status" => "FINISHED",
            "num_success" => 8,
            "size_total" => 17872,
            "num_download" => 0,
            "item_name" => nil,
            "items_left" => 0,
            "items_total" => 8,
            "item_type" => "",
            "step" => "Running Createrepo",
            "size_left" => 0,
            "details" => {
              "rpm" => {
                "num_success" => 8,
                "total_count" => 8,
                "items_left" => 0,
                "size_left" => 0,
                "total_size_bytes" => 17872,
                "num_error" => 0
              }
            },
            "error_details" => [

            ],
            "num_error" => 0
          },
          "id" => "3b83eda3-c8f1-11e0-a41d-0024d78b4ebc"
        }.with_indifferent_access
  ]


end
