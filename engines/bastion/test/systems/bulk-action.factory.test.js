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

describe('Factory: BulkAction', function() {
    var $httpBackend,
        BulkAction,
        systemParams,
        systemGroupParams;

    beforeEach(module('Bastion.systems'));

    beforeEach(module(function($provide) {
        var routes,
            systemIds = [1, 2, 3],
            systemGroupIds = [8, 9];

        routes = {
            apiSystemsPath: function() {return '/katello/api/systems'}
        };

        systemParams = {ids: systemIds};
        systemGroupParams = {ids: systemIds, system_group_ids: systemGroupIds};

        $provide.value('Routes', routes);
    }));

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        BulkAction = $injector.get('BulkAction');
    }));

    afterEach(function() {
        $httpBackend.flush();
    });

    it('provides a way to add system groups to systems', function() {
        $httpBackend.expect('PUT', '/katello/api/systems/bulk/add_system_groups', systemGroupParams).respond();
        BulkAction.addSystemGroups(systemGroupParams);
    });

    it('provides a way to remove system groups from systems', function() {
        $httpBackend.expect('PUT', '/katello/api/systems/bulk/remove_system_groups', systemGroupParams).respond();
        BulkAction.removeSystemGroups(systemGroupParams);
    });

    it('provides a way to install content on systems', function() {
        $httpBackend.expect('PUT', '/katello/api/systems/bulk/install_content', systemParams).respond();
        BulkAction.installContent(systemParams);
    });

    it('provides a way to update content on systems', function() {
        $httpBackend.expect('PUT', '/katello/api/systems/bulk/update_content', systemParams).respond();
        BulkAction.updateContent(systemParams);
    });

    it('provides a way to remove content from systems', function() {
        $httpBackend.expect('PUT', '/katello/api/systems/bulk/remove_content', systemParams).respond();
        BulkAction.removeContent(systemParams);
    });

    it('provides a way to remove systems', function() {
        $httpBackend.expect('PUT', '/katello/api/systems/bulk/destroy', systemParams).respond();
        BulkAction.removeSystems(systemParams);
    });
});
