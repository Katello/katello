require 'katello_test_helper'
require 'support/pulp3_support'

module Katello
  module Service
    module Pulp3
      class TaskTest < ActiveSupport::TestCase
        def setup
          @task = {
            "created_resources": %w[
              /pulp/api/v3/publictions/rpm/rpm/529aebe5-d0b1-4d86-895b-33ee42937fd2/
              /pulp/api/v3/publications/rpm/rpm/93145c6f-3df7-44a4-a4b7-a7512eb34c97/
              /pulp/api/v3/publications/rpm/rpm/967cb4c8-665b-4050-aab1-9abff4dcc995/
              /pulp/api/v3/publications/rpm/rpm/00740609-f339-4ba0-b45c-47c4b9a55080/
              /pulp/api/v3/repositories/rpm/rpm/1be4e0c6-be29-4e38-986e-d71582f35617/versions/1/
              /pulp/api/v3/publications/rpm/rpm/17e9690a-4f58-4fac-9cbe-ace9b1c15aae/
            ],
          }.with_indifferent_access
        end

        def test_version_href
          assert_equal '/pulp/api/v3/repositories/rpm/rpm/1be4e0c6-be29-4e38-986e-d71582f35617/versions/1/', Katello::Pulp3::Task.version_href(@task)
          assert_equal '/pulp/api/v3/repositories/rpm/rpm/1be4e0c6-be29-4e38-986e-d71582f35617/versions/1/', Katello::Pulp3::Task.version_href([@task])
        end

        def test_publication_href
          assert_equal '/pulp/api/v3/publications/rpm/rpm/17e9690a-4f58-4fac-9cbe-ace9b1c15aae/', Katello::Pulp3::Task.publication_href(@task)
          assert_equal '/pulp/api/v3/publications/rpm/rpm/17e9690a-4f58-4fac-9cbe-ace9b1c15aae/', Katello::Pulp3::Task.publication_href([@task])
        end
      end
    end
  end
end
