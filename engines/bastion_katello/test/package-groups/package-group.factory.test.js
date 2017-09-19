describe('Factory: PackageGroup', function () {
    var $httpBackend,
        packageGroups;

    beforeEach(module('Bastion.package-groups', 'Bastion.test-mocks'));

    beforeEach(module(function ($provide) {
        packageGroups = {
            records: [
                { name: 'PackageGroup1', id: 1 }
            ],
            total: 2,
            subtotal: 1
        };
    }));

    beforeEach(inject(function ($injector) {
        $httpBackend = $injector.get('$httpBackend');
        PackageGroup = $injector.get('PackageGroup');
    }));

    afterEach(function () {
        $httpBackend.flush();
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('provides a way to get a list of repositorys', function () {
        $httpBackend.expectGET('katello/api/v2/package_groups').respond(packageGroups);

        PackageGroup.queryPaged(function (packageGroups) {
            expect(packageGroups.records.length).toBe(1);
        });
    });

});
