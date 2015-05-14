describe('Factory: ContentHostErratum', function($provide) {
    var $httpBackend,
        task,
        errata,
        ContentHostErratum;

    beforeEach(module('Bastion.content-hosts', 'Bastion.utils', 'Bastion.test-mocks'));

    beforeEach(module(function($provide) {
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
        ContentHostErratum = $injector.get('ContentHostErratum');
    }));

    afterEach(function() {
        $httpBackend.flush();
    });

    it('provides a way to get a list of errata', function() {
        $httpBackend.expectGET('/katello/api/v2/systems/SYS_ID/errata').respond(errata);
        ContentHostErratum.get({ id: 'SYS_ID' }, function(results) {
            expect(results.total).toBe(2);
        });
    });

    it('provides a way to apply a list of errata', function() {
        $httpBackend.expectPUT('/katello/api/v2/systems/SYS_ID/errata/apply').respond(task);
        ContentHostErratum.apply({ uuid: 'SYS_ID', errata_ids: ['RHSA-1'] }, function(results) {
            expect(results.id).toBe(task.id);
        });
    });
});
