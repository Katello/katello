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

describe('Factory: PuppetModules', function () {
    var $httpBackend,
        puppetModules;

    beforeEach(module('Bastion.puppet-modules', 'Bastion.test-mocks'));

    beforeEach(module(function ($provide) {
        puppetModules = {
            records: [
                { name: 'PuppetModules1', id: 1 }
            ],
            total: 2,
            subtotal: 1
        };
    }));

    beforeEach(inject(function ($injector) {
        $httpBackend = $injector.get('$httpBackend');
        PuppetModule = $injector.get('PuppetModule');
    }));

    afterEach(function () {
        $httpBackend.flush();
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('provides a way to get a list of puppet modules', function () {
        $httpBackend.expectGET('/api/v2/puppet_modules').respond(puppetModules);

        PuppetModule.queryPaged(function (puppetModules) {
            expect(puppetModules.records.length).toBe(1);
        });
    });

});
