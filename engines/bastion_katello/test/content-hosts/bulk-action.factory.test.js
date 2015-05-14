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
        $httpBackend.expect('PUT', '/katello/api/v2/systems/bulk/add_host_collections', hostCollectionParams).respond();
        ContentHostBulkAction.addHostCollections(hostCollectionParams);
    });

    it('provides a way to remove host collections from content hosts', function() {
        $httpBackend.expect('PUT', '/katello/api/v2/systems/bulk/remove_host_collections', hostCollectionParams).respond();
        ContentHostBulkAction.removeHostCollections(hostCollectionParams);
    });

    it('provides a way to install content on content hosts', function() {
        $httpBackend.expect('PUT', '/katello/api/v2/systems/bulk/install_content', contentHostParams).respond();
        ContentHostBulkAction.installContent(contentHostParams);
    });

    it('provides a way to update content on content hosts', function() {
        $httpBackend.expect('PUT', '/katello/api/v2/systems/bulk/update_content', contentHostParams).respond();
        ContentHostBulkAction.updateContent(contentHostParams);
    });

    it('provides a way to remove content from content hosts', function() {
        $httpBackend.expect('PUT', '/katello/api/v2/systems/bulk/remove_content', contentHostParams).respond();
        ContentHostBulkAction.removeContent(contentHostParams);
    });

    it('provides a way to unregister content hosts', function() {
        $httpBackend.expect('PUT', '/katello/api/v2/systems/bulk/destroy', contentHostParams).respond();
        ContentHostBulkAction.unregisterContentHosts(contentHostParams);
    });
});
