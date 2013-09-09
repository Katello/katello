/**
* Copyright 2013 Red Hat, Inc.
*
* This software is licensed to you under the GNU General Public
* License as published by the Free Software Foundation; either version
* 2 of the License (GPLv2) or (at your option) any later version.
* There is NO WARRANTY for this software, express or implied,
* including the implied warranties of MERCHANTABILITY,
* NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
* have received a copy of GPLv2 along with this software; if not, see
* http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
**/

describe('Factory: SystemTask', function() {
    var $httpBackend,
        task,
        pendingTask,
        SystemTask;

    beforeEach(module('Bastion.systems'));
    beforeEach(module(function($provide) {
        var routes;
        task = {id: 'TASK_ID', pending: false};
        pendingTask = {id: 'PENDING_TASK_ID', pending: true};
        routes = {
            apiSystemsPath: function(){return '/katello/api/systems/'}
        };
        $provide.value('Routes', routes);
    }));

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        SystemTask = $injector.get('SystemTask');
    }));

    afterEach(function() {
        $httpBackend.flush();
    });

    it('provides a way to get a system task', function() {
        $httpBackend.expectGET('/katello/api/systems//tasks/TASK_ID?paged=false').respond(task);
        SystemTask.get({ id: 'TASK_ID' }, function(results) {
            expect(results.id).toBe(task.id);
        });
    });

    it('provides a way to poll a task', function() {
        $httpBackend.expectGET('/katello/api/systems//tasks/PENDING_TASK_ID?paged=false').respond(pendingTask);
        SystemTask.poll(pendingTask, function(results) {});
    });
});
