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
        hostCollectionParams;

    beforeEach(module('Bastion.content-hosts', 'Bastion.test-mocks'));

    beforeEach(module(function($provide) {
        var contentHostIds = [1, 2, 3],
            hostCollectionIds = [8, 9];

        contentHostParams = {ids: contentHostIds};
        hostCollectionParams = {ids: contentHostIds, host_collection_ids: hostCollectionIds};
    }));

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        ContentHostBulkAction = $injector.get('ContentHostBulkAction');
    }));

    afterEach(function() {
        $httpBackend.flush();
    });

    it('provides a way to add host collections to content hosts', function() {
        $httpBackend.expect('PUT', '/api/v2/systems/bulk/add_host_collections', hostCollectionParams).respond();
        ContentHostBulkAction.addHostCollections(hostCollectionParams);
    });

    it('provides a way to remove host collections from content hosts', function() {
        $httpBackend.expect('PUT', '/api/v2/systems/bulk/remove_host_collections', hostCollectionParams).respond();
        ContentHostBulkAction.removeHostCollections(hostCollectionParams);
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

    it('provides a way to unregister content hosts', function() {
        $httpBackend.expect('PUT', '/api/v2/systems/bulk/destroy', contentHostParams).respond();
        ContentHostBulkAction.unregisterContentHosts(contentHostParams);
    });
});
