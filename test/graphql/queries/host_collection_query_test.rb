require 'katello_test_helper'

module Queries
  class HostCollectionQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
        query($id:String!) {
          hostCollection(id: $id) {
            id
            name
            description
            maxHosts
            unlimitedHosts
            hosts {
              nodes {
                id
                name
              }
            }
          }
        }
      GRAPHQL
    end

    let(:host_collection) { katello_host_collections(:limited_hosts_host_collection) }
    let(:global_id) { Foreman::GlobalId.for(host_collection) }
    let(:variables) { { id: global_id } }
    let(:data) { result['data']['hostCollection'] }

    test 'should host collection' do
      assert_equal global_id, data['id']
      assert_equal host_collection.name, data['name']
      assert_equal host_collection.description, data['description']
      refute data['unlimitedHosts']
      assert_equal 5, data['maxHosts']
      assert_not_empty data['hosts']['nodes']
    end
  end
end
