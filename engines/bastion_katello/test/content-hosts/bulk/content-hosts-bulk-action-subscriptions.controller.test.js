describe('Controller: ContentHostsBulkActionSubscriptionsController', function() {
    var $scope, $q, promise, translate, ContentHostBulkAction, HostCollection, Organization, Task, CurrentOrganization, GlobalNotification;

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
            registerSearch: function () {},
            monitorTask: function() { return promise; }
        };
        translate = function() {};
        CurrentOrganization = 'foo';
    });

    beforeEach(inject(function(_GlobalNotification_, $controller, $rootScope, _$q_) {
        $q = _$q_;
        promise = $q.defer();
        $scope = $rootScope.$new();
        GlobalNotification = _GlobalNotification_;
        $scope.getSelectedContentHostIds = function() {
            return [1,2,3]
        };

        $controller('ContentHostsBulkActionSubscriptionsController', {
            $scope: $scope,
            $q: $q,
            ContentHostBulkAction: ContentHostBulkAction,
            HostCollection: HostCollection,
            translate: translate,
            Organization: Organization,
            CurrentOrganization: CurrentOrganization,
            Task: Task,
            GlobalNotification: GlobalNotification
        });
    }));

    it("can auto-attach available subscriptions to all content hosts", function() {
        spyOn(Organization, 'autoAttachSubscriptions');
        spyOn(Task, 'monitorTask').and.returnValue(promise);

        promise.stopMonitoring = function () {};
        $scope.performAutoAttachSubscriptions();

        expect(Organization.autoAttachSubscriptions).toHaveBeenCalled();
    });

});
