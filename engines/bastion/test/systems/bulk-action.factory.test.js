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

describe('Factory: SystemBulkAction', function() {
    var $httpBackend,
        SystemBulkAction,
        systemParams,
        systemGroupParams;

    beforeEach(module('Bastion.systems'));

    beforeEach(module(function($provide) {
        var systemIds = [1, 2, 3],
            systemGroupIds = [8, 9];

        systemParams = {ids: systemIds};
        systemGroupParams = {ids: systemIds, system_group_ids: systemGroupIds};
    }));

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        SystemBulkAction = $injector.get('SystemBulkAction');
    }));

    afterEach(function() {
        $httpBackend.flush();
    });

    it('provides a way to add system groups to systems', function() {
        $httpBackend.expect('PUT', '/api/v2/systems/bulk/add_system_groups', systemGroupParams).respond();
        SystemBulkAction.addSystemGroups(systemGroupParams);
    });

    it('provides a way to remove system groups from systems', function() {
        $httpBackend.expect('PUT', '/api/v2/systems/bulk/remove_system_groups', systemGroupParams).respond();
        SystemBulkAction.removeSystemGroups(systemGroupParams);
    });

    it('provides a way to install content on systems', function() {
        $httpBackend.expect('PUT', '/api/v2/systems/bulk/install_content', systemParams).respond();
        SystemBulkAction.installContent(systemParams);
    });

    it('provides a way to update content on systems', function() {
        $httpBackend.expect('PUT', '/api/v2/systems/bulk/update_content', systemParams).respond();
        SystemBulkAction.updateContent(systemParams);
    });

    it('provides a way to remove content from systems', function() {
        $httpBackend.expect('PUT', '/api/v2/systems/bulk/remove_content', systemParams).respond();
        SystemBulkAction.removeContent(systemParams);
    });

    it('provides a way to remove systems', function() {
        $httpBackend.expect('PUT', '/api/v2/systems/bulk/destroy', systemParams).respond();
        SystemBulkAction.removeSystems(systemParams);
    });
});
