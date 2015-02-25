/**
 * Copyright 2014 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either environment
 * 2 of the License (GPLv2) or (at your option) any later environment.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 **/

describe('Service: ContentService', function() {
    var ContentService, Package;

    beforeEach(module('Bastion.environments', 'Bastion.test-mocks'));

    beforeEach(inject(function ($injector) {
        var $state = $injector.get('$state');

        $state.current = {name: 'environments.environment.packages'};
        Package = $injector.get('Package');
        ContentService = $injector.get('ContentService');
    }));

    it("should expose the list of content types", function() {
        expect(ContentService.contentTypes.length).toBe(6);
    });

    it("should expose a method to get the repository type for an object", function() {
        expect(ContentService.getRepositoryType()).toBe('yum');
    });

    it("should provide a method to build a nutupane based on the current state", function () {
        var nutupane = ContentService.buildNutupane();

        expect(nutupane).toBeDefined();
        expect(nutupane.table.resource).toBe(Package);
    });

    it("should provide a method to build a nutupane based on params", function () {
        var nutupane = ContentService.buildNutupane({environmentId: 1});

        expect(nutupane).toBeDefined();
        expect(nutupane.getParams()['environmentId']).toBe(1);
    });

});

