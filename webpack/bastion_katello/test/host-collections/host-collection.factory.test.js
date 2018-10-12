describe('Factory: HostCollection', function() {
    var HostCollection, $httpBackend, hostCollections;

    beforeEach(module('Bastion.host-collections', 'Bastion.test-mocks'));

    beforeEach(function() {
        hostCollections = {
            results: [{id: 0, name: "booyah"}, {id: 1, name: 'lalala'}, {id: 2, name: 'yesssir'}]
        };
    });

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        HostCollection = $injector.get('HostCollection');
    }));

    afterEach(function() {
        $httpBackend.flush();
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('makes a request to get the host collection list from the API.', function() {
        $httpBackend.expectGET('katello/api/v2/host_collections').respond(hostCollections);

        HostCollection.queryPaged(function(response) {
            expect(response.results.length).toBe(hostCollections.results.length);

            for (var i = 0; i < hostCollections.results.length; i++) {
                expect(response.results[i].id).toBe(hostCollections.results[i].id);
            }
        });
    });

    it('provides a way to update a host collection', function() {
        var hostCollection = hostCollections.results[0];

        hostCollection.name = 'NewName';
        $httpBackend.expectPUT('katello/api/v2/host_collections/0').respond(hostCollection);

        HostCollection.update({name: hostCollection.name, id: 0}, function(response) {
            expect(response).toBeDefined();
            expect(response.name).toBe(hostCollection.name);
        });
    });

    it('provides a way to add hosts', function() {
        var hosts = {test: 'this'};
        $httpBackend.expectPUT('katello/api/v2/host_collections/0/add_hosts').respond(hosts);
        HostCollection.addHosts({'host_collection': {'host_ids': [1,2]} , id: 0}, function(response) {
            expect(response.test).toBe('this');
        });
    });

    it('provides a way to remove hosts', function() {
        var hosts = {test: 'this'};
        $httpBackend.expectPUT('katello/api/v2/host_collections/0/remove_hosts').respond(hosts);
        HostCollection.removeHosts({'host_collection': {'host_ids': [1,2]} , id: 0}, function(response) {
            expect(response.test).toBe('this');
        });
    });
});
