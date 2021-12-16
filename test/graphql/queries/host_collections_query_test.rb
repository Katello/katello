require 'katello_test_helper'

module Queries
  class HostCollectionsQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
        query {
          hostCollections {
            nodes {
              id
              name
            }
          }
        }
      GRAPHQL
    end

    test 'should host collection' do
      assert_not_empty result['data']['hostCollections']['nodes']
    end
  end
end
