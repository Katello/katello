describe('Factory: Task', function() {
    var $httpBackend,
        tasks;

    beforeEach(module('Bastion.tasks', 'Bastion.test-mocks'));

    beforeEach(module(function($provide) {
        tasks = {
            records: [
                { name: 'Task1', id: 1 }
            ],
            total: 2,
            subtotal: 1
        };

        $provide.value('CurrentOrganization', 'ACME');
    }));

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        Task = $injector.get('Task');
    }));

    afterEach(function() {
        $httpBackend.flush();
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('provides a way to get a list of tasks', function() {
        $httpBackend.expectGET('/katello/api/v2/tasks?full_result=true&organization_id=ACME')
                    .respond(tasks);

        Task.queryUnpaged(function(tasks) {
            expect(tasks.records.length).toBe(1);
        });
    });

});
