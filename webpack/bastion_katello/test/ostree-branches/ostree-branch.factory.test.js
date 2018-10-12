describe('Factory: OstreeBranch', function () {
    var $httpBackend,
        ostreeBranches;

    beforeEach(module('Bastion.ostree-branches', 'Bastion.test-mocks'));

    beforeEach(module(function ($provide) {
        ostreeBranches = {
            records: [
                { name: 'abc123', id: 1 }
            ],
            total: 2,
            subtotal: 1
        };
    }));

    beforeEach(inject(function ($injector) {
        $httpBackend = $injector.get('$httpBackend');
        OstreeBranch = $injector.get('OstreeBranch');
    }));

    afterEach(function () {
        $httpBackend.flush();
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('provides a way to get a list of repositories', function () {
        $httpBackend.expectGET('katello/api/v2/ostree_branches').respond(ostreeBranches);

        OstreeBranch.queryPaged(function (ostreeBranches) {
            expect(ostreeBranches.records.length).toBe(1);
        });
    });

});
