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
        $httpBackend.expectGET('/api/v2/package_groups').respond(packageGroups);

        PackageGroup.queryPaged(function (packageGroups) {
            expect(packageGroups.records.length).toBe(1);
        });
    });

});
