describe('Factory: HostPackage', function() {
    var $httpBackend,
        task,
        packages,
        HostPackage;

    beforeEach(module('Bastion.hosts', 'Bastion.utils', 'Bastion.test-mocks'));

    beforeEach(module(function($provide) {
        packages = {
            records: [
                { name: 'kernel', id: 1 },
                { name: 'firefox', id: 2 }
            ],
            total: 2,
            subtotal: 2
        };
        task = {id: 'task_id'};
    }));

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        HostPackage = $injector.get('HostPackage');
    }));

    afterEach(function() {
        $httpBackend.flush();
    });

    it('provides a way to get a list of packages', function() {
        $httpBackend.expectGET('api/v2/hosts/SYS_ID/packages').respond(packages);
        HostPackage.get({ id: 'SYS_ID' }, function(results) {
            expect(results.total).toBe(2);
        });
    });

    it('provides a way to install a list of packages', function() {
        $httpBackend.expectPUT('api/v2/hosts/SYS_ID/packages/install').respond(task);
        HostPackage.install({ id: 'SYS_ID', packages: ['kernel'] }, function(results) {
            expect(results.id).toBe(task.id);
        });
    });

    it('provides a way to update a list of packages', function() {
        $httpBackend.expectPUT('api/v2/hosts/SYS_ID/packages/upgrade').respond(task);
        HostPackage.update({ id: 'SYS_ID', packages: ['kernel'] }, function(results) {
            expect(results.id).toBe(task.id);
        });
    });

    it('provides a way to update all of packages', function() {
        $httpBackend.expectPUT('api/v2/hosts/SYS_ID/packages/upgrade_all').respond(task);
        HostPackage.updateAll({ id: 'SYS_ID', packages: ['kernel'] }, function(results) {
            expect(results.id).toBe(task.id);
        });
    });

    it('provides a way to remove a list of packages', function() {
        $httpBackend.expectPUT('api/v2/hosts/SYS_ID/packages/remove').respond(task);
        HostPackage.remove({ id: 'SYS_ID', packages: ['kernel'] }, function(results) {
            expect(results.id).toBe(task.id);
        });
    });

});
