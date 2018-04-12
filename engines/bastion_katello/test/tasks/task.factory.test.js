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
        $httpBackend.expectPOST('foreman_tasks/api/tasks/bulk_search')
                    .respond(tasks.records);

        Task.bulkSearch(function(tasks) {
            expect(tasks.length).toBe(1);
        });
    });

});
