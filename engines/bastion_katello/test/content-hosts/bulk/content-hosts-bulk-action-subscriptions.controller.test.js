describe('Controller: ContentHostsBulkActionSubscriptionsController', function() {
    var $scope, $_q_, translate, ContentHostBulkAction, HostCollection, Organization, Task, CurrentOrganization, GlobalNotification;

    beforeEach(module('Bastion.content-hosts', 'Bastion.test-mocks'));

    beforeEach(function() {
        ContentHostBulkAction = {
            addHostCollections: function() {},
            removeHostCollections: function() {},
            installContent: function() {},
            updateContent: function() {},
            removeContent: function() {},
            unregisterContentHosts: function() {}
        };
        HostCollection = {
            query: function() {}
        };
        Organization = {
            queryUnpaged: function() {},
            autoAttachSubscriptions: function() {}
        };
        Task = {
            queryUnpaged: function() {},
            poll: function() {},
            monitorTask: function() { return $_q_.defer(); },
        };
        translate = function() {};
        CurrentOrganization = 'foo';
    });

    beforeEach(inject(function(_GlobalNotification_, $controller, $rootScope, $q) {
        $_q_ = $q;
        $scope = $rootScope.$new();
        GlobalNotification = _GlobalNotification_;
        $scope.getSelectedContentHostIds = function() {
            return [1,2,3]
        };

        $controller('ContentHostsBulkActionSubscriptionsController', {$scope: $scope,
            $q: $q,
            ContentHostBulkAction: ContentHostBulkAction,
            HostCollection: HostCollection,
            translate: translate,
            Organization: Organization,
            CurrentOrganization: CurrentOrganization,
            Task: Task,
            GlobalNotification: GlobalNotification});
    }));

    it("can auto-attach available subscriptions to all content hosts", function() {
        spyOn(Organization, 'autoAttachSubscriptions');
        $scope.performAutoAttachSubscriptions();

        expect(Organization.autoAttachSubscriptions).toHaveBeenCalled();
    });

});
