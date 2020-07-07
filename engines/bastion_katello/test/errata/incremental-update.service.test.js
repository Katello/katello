describe('Service: IncrementalUpdate', function() {
    var IncrementalUpdate, Task, ids, bulkResource;

    beforeEach(module('Bastion.errata'));

    beforeEach(module(function($provide) {
        Task = {
            registerSearch: function () {},
            unregisterSearch: function () {}
        };

        $provide.value('Task', Task);
        $provide.value('CurrentOrganization', "ACME");
        $provide.value('Deb', {});
    }));

    beforeEach(inject(function($injector) {
        ids = [1, 2, 3];

        bulkResource = {
            included: {
                ids: [1, 2, 3]
            }
        };

        IncrementalUpdate = $injector.get('IncrementalUpdate');
    }));

    it("provides a method to set errata ids.", function () {
        IncrementalUpdate.setErrataIds(ids);
        expect(IncrementalUpdate.errataIds).toBe(ids);
    });

    it("provides a method to get errata ids.", function () {
        IncrementalUpdate.errataIds = ids;
        expect(IncrementalUpdate.getErrataIds()).toBe(ids);
    });

    it("provides a method to set content host ids.", function () {
        IncrementalUpdate.setContentHostIds(ids);
        expect(IncrementalUpdate.contentHostIds).toBe(ids);
    });

    it("provides a method to get content host ids.", function () {
        IncrementalUpdate.contentHostIds = ids;
        expect(IncrementalUpdate.getContentHostIds()).toBe(ids);
    });

    it("provides a method to set bulk errata.", function () {
        IncrementalUpdate.setBulkErrata(bulkResource);
        expect(IncrementalUpdate.bulkErrata).toBe(bulkResource);
    });

    it("provides a method to get bulk errata.", function () {
        IncrementalUpdate.bulkErrata = bulkResource;
        expect(IncrementalUpdate.getBulkErrata()).toBe(bulkResource);
    });

    it("provides a method to set bulk content host.", function () {
        IncrementalUpdate.setBulkContentHosts(bulkResource);
        expect(IncrementalUpdate.bulkContentHosts).toBe(bulkResource);
    });

    it("provides a method to get bulk content host.", function () {
        IncrementalUpdate.bulkContentHosts = bulkResource;
        expect(IncrementalUpdate.getBulkContentHosts()).toBe(bulkResource);
    });

    it("provides a method to get the incremental updates", function () {
        spyOn(Task, 'registerSearch').and.callFake(function (params, callback) {
            callback(ids);
            return 1;
        });

        spyOn(Task, 'unregisterSearch');

        IncrementalUpdate.getIncrementalUpdates();

        expect(Task.registerSearch).toHaveBeenCalled();
        expect(Task.unregisterSearch).toHaveBeenCalled();
    });
});
