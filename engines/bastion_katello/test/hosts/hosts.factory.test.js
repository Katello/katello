describe('Factory: Host', function() {
    var Host, $httpBackend, hosts;

    beforeEach(module('Bastion.hosts'));

    beforeEach(function() {
        hosts = {
            results: [{id: 1, name: "booyah"}]
        };
    });

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        Host = $injector.get('Host');
    }));

    afterEach(function() {
        $httpBackend.flush();
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it("provides a way to update the host's host collections", function() {
        var host = hosts.results[0];

        $httpBackend.expectPUT('/api/v2/hosts/1/host_collections').respond(host);

        Host.updateHostCollections({id: 1}, {"host_collection_ids": [1,2]});
    });
});
