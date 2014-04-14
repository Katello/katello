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

describe('Factory: ContentHostBulkAction', function() {
    var $httpBackend,
        ContentHostBulkAction,
        contentHostParams,
        systemGroupParams;

    beforeEach(module('Bastion.content-hosts', 'Bastion.test-mocks'));

    beforeEach(module(function($provide) {
        var contentHostIds = [1, 2, 3],
            systemGroupIds = [8, 9];

        contentHostParams = {ids: contentHostIds};
        systemGroupParams = {ids: contentHostIds, system_group_ids: systemGroupIds};
    }));

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        ContentHostBulkAction = $injector.get('ContentHostBulkAction');
    }));

    afterEach(function() {
        $httpBackend.flush();
    });

    it('provides a way to add system groups to content hosts', function() {
        $httpBackend.expect('PUT', '/api/v2/systems/bulk/add_system_groups', systemGroupParams).respond();
        ContentHostBulkAction.addSystemGroups(systemGroupParams);
    });

    it('provides a way to remove system groups from content hosts', function() {
        $httpBackend.expect('PUT', '/api/v2/systems/bulk/remove_system_groups', systemGroupParams).respond();
        ContentHostBulkAction.removeSystemGroups(systemGroupParams);
    });

    it('provides a way to install content on content hosts', function() {
        $httpBackend.expect('PUT', '/api/v2/systems/bulk/install_content', contentHostParams).respond();
        ContentHostBulkAction.installContent(contentHostParams);
    });

    it('provides a way to update content on content hosts', function() {
        $httpBackend.expect('PUT', '/api/v2/systems/bulk/update_content', contentHostParams).respond();
        ContentHostBulkAction.updateContent(contentHostParams);
    });

    it('provides a way to remove content from content hosts', function() {
        $httpBackend.expect('PUT', '/api/v2/systems/bulk/remove_content', contentHostParams).respond();
        ContentHostBulkAction.removeContent(contentHostParams);
    });

    it('provides a way to remove content hosts', function() {
        $httpBackend.expect('PUT', '/api/v2/systems/bulk/destroy', contentHostParams).respond();
        ContentHostBulkAction.removeContentHosts(contentHostParams);
    });
});
