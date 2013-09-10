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

describe('Factory: SystemPackage', function() {
    var $httpBackend,
        task,
        packages,
        SystemPackage;

    beforeEach(module('Bastion.systems', 'Bastion.utils'));

    beforeEach(module(function($provide) {
        var routes;

        packages = {
            records: [
                { name: 'kernel', id: 1 },
                { name: 'firefox', id: 2 }
            ],
            total: 2,
            subtotal: 2
        };
        task = {id: 'task_id'};
        routes = {
            apiSystemsPath: function(){return '/katello/api/systems'}
        };
        $provide.value('Routes', routes);
    }));

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        SystemPackage = $injector.get('SystemPackage');
    }));

    afterEach(function() {
        $httpBackend.flush();
    });

    it('provides a way to get a list of packages', function() {
        $httpBackend.expectGET('/katello/api/systems/SYS_ID/packages').respond(packages);
        SystemPackage.get({ id: 'SYS_ID' }, function(results) {
            expect(results.total).toBe(2);
        });
    });

    it('provides a way to install a list of packages', function() {
        $httpBackend.expectPUT('/katello/api/systems/SYS_ID/packages/install').respond(task);
        SystemPackage.install({ uuid: 'SYS_ID', packages: ['kernel'] }, function(results) {
            expect(results.id).toBe(task.id);
        });
    });

    it('provides a way to update a list of packages', function() {
        $httpBackend.expectPUT('/katello/api/systems/SYS_ID/packages/upgrade').respond(task);
        SystemPackage.update({ uuid: 'SYS_ID', packages: ['kernel'] }, function(results) {
            expect(results.id).toBe(task.id);
        });
    });

    it('provides a way to update all of packages', function() {
        $httpBackend.expectPUT('/katello/api/systems/SYS_ID/packages/upgrade_all').respond(task);
        SystemPackage.updateAll({ uuid: 'SYS_ID', packages: ['kernel'] }, function(results) {
            expect(results.id).toBe(task.id);
        });
    });

    it('provides a way to remove a list of packages', function() {
        $httpBackend.expectPUT('/katello/api/systems/SYS_ID/packages/remove').respond(task);
        SystemPackage.remove({ uuid: 'SYS_ID', packages: ['kernel'] }, function(results) {
            expect(results.id).toBe(task.id);
        });
    });

});
