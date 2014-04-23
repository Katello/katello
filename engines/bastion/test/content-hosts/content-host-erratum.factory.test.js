/**
* Copyright 2014 Red Hat, Inc.
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
        $httpBackend.expectGET('/api/v2/systems/SYS_ID/errata').respond(errata);
        ContentHostErratum.get({ id: 'SYS_ID' }, function(results) {
            expect(results.total).toBe(2);
        });
    });

    it('provides a way to apply a list of errata', function() {
        $httpBackend.expectPUT('/api/v2/systems/SYS_ID/errata/apply').respond(task);
        ContentHostErratum.apply({ uuid: 'SYS_ID', errata_ids: ['RHSA-1'] }, function(results) {
            expect(results.id).toBe(task.id);
        });
    });
});
