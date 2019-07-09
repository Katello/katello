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
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it("determines if its debian with debian os", function() {
        host = new Host({operatingsystem_name: "Debian"})

        expect(host.isDebEnabled()).toEqual(true)
    });

    it("determines if its debian with debian os", function() {
        host = new Host({operatingsystem_name: "Best Debian"})

        expect(host.isDebEnabled()).toEqual(true)
    });

    it("determines if its debian with debian os", function() {
        host = new Host({operatingsystem_name: "Best Ubuntu"})

        expect(host.isDebEnabled()).toEqual(true)
    });

    it("determines if its debian with debian os", function() {
        host = new Host({operatingsystem_name: "Best Debian"})

        expect(host.isDebEnabled()).toEqual(true)
    });

    it("determines if its debian with debian os", function() {
        host = new Host({operatingsystem_name: "Redhat"})

        expect(host.isDebEnabled()).toEqual(false)
    });

    it("determines if its debian with null os", function() {
        host = new Host({operatingsystem_name: null})

        expect(host.isDebEnabled()).toEqual(false)
    });

    it("determines if its debian with undefined os", function() {
        host = new Host({})

        expect(host.isDebEnabled()).toEqual(false)
    });

    it("provides a way to update the host's host collections", function() {
        var host = hosts.results[0];

        $httpBackend.expectPUT('/api/v2/hosts/1/host_collections').respond(host);

        Host.updateHostCollections({id: 1}, {"host_collection_ids": [1,2]});
        $httpBackend.flush();
    });

    it("provides a way to get the host index via a post", function() {
        $httpBackend.expectPOST('/api/v2/hosts/post_index').respond({});
        Host.postIndex();
        $httpBackend.flush();
    });
});
