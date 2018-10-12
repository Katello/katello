describe('Factory: HostErratum', function() {
    var $httpBackend,
        task,
        errata,
        HostErratum;

    beforeEach(module('Bastion.content-hosts', 'Bastion.utils', 'Bastion.test-mocks'));

    beforeEach(module(function() {
        errata = {
            records: [
                { errata_id: 'RHSA-1' },
                { errata_id: 'RHBA-2' }
            ],
            total: 2,
            subtotal: 2
        };
        task = {id: 'task_id'};
    }));

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        HostErratum = $injector.get('HostErratum');
    }));

    afterEach(function() {
        $httpBackend.flush();
    });

    it('provides a way to get a list of errata', function() {
        $httpBackend.expectGET('api/v2/hosts/HOST_ID/errata').respond(errata);
        HostErratum.get({ id: 'HOST_ID' }, function(results) {
            expect(results.total).toBe(2);
        });
    });

    it('provides a way to apply a list of errata', function() {
        $httpBackend.expectPUT('api/v2/hosts/HOST_ID/errata/apply').respond(task);
        HostErratum.apply({ id: 'HOST_ID', errata_ids: ['RHSA-1'] }, function(results) {
            expect(results.id).toBe(task.id);
        });
    });
});
