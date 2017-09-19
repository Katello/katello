describe('Factory: HostBulkAction', function() {
    var $httpBackend,
        ContentHostBulkAction,
        contentHostParams,
        hostCollectionParams,
        subscriptionParams;

    beforeEach(module('Bastion.hosts', 'Bastion.test-mocks'));

    beforeEach(module(function($provide) {
        var contentHostIds = [1, 2, 3],
            hostCollectionIds = [8, 9];
            subscriptionParams = [4, 5]

        contentHostParams = {ids: contentHostIds};
        hostCollectionParams = {ids: contentHostIds, host_collection_ids: hostCollectionIds};
        subscriptionParams = {ids: contentHostIds, subscription_ids: hostCollectionIds};
    }));

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        ContentHostBulkAction = $injector.get('HostBulkAction');
    }));

    afterEach(function() {
        $httpBackend.flush();
    });

    it('provides a way to add host collections to content hosts', function() {
        $httpBackend.expect('PUT', 'api/v2/hosts/bulk/add_host_collections', hostCollectionParams).respond();
        ContentHostBulkAction.addHostCollections(hostCollectionParams);
    });

    it('provides a way to remove host collections from content hosts', function() {
        $httpBackend.expect('PUT', 'api/v2/hosts/bulk/remove_host_collections', hostCollectionParams).respond();
        ContentHostBulkAction.removeHostCollections(hostCollectionParams);
    });

    it('provides a way to add subscriptions to content hosts', function() {
        $httpBackend.expect('PUT', 'api/v2/hosts/bulk/add_subscriptions', subscriptionParams).respond();
        ContentHostBulkAction.addSubscriptions(subscriptionParams);
    });

    it('provides a way to remove subscriptions from content hosts', function() {
        $httpBackend.expect('PUT', 'api/v2/hosts/bulk/remove_subscriptions', subscriptionParams).respond();
        ContentHostBulkAction.removeSubscriptions(subscriptionParams);
    });

    it('provides a way to auto attach subscriptions to content hosts', function() {
        $httpBackend.expect('PUT', 'api/v2/hosts/bulk/auto_attach', subscriptionParams).respond();
        ContentHostBulkAction.autoAttach(subscriptionParams);
    });
    
    it('provides a way to install content on content hosts', function() {
        $httpBackend.expect('PUT', 'api/v2/hosts/bulk/install_content', contentHostParams).respond();
        ContentHostBulkAction.installContent(contentHostParams);
    });

    it('provides a way to update content on content hosts', function() {
        $httpBackend.expect('PUT', 'api/v2/hosts/bulk/update_content', contentHostParams).respond();
        ContentHostBulkAction.updateContent(contentHostParams);
    });

    it('provides a way to remove content from content hosts', function() {
        $httpBackend.expect('PUT', 'api/v2/hosts/bulk/remove_content', contentHostParams).respond();
        ContentHostBulkAction.removeContent(contentHostParams);
    });

    it('provides a way to unregister content hosts', function() {
        $httpBackend.expect('PUT', 'api/v2/hosts/bulk/destroy', contentHostParams).respond();
        ContentHostBulkAction.destroyHosts(contentHostParams);
    });
});
