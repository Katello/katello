describe('Controller: ContentHostsBulkHostCollectionsModalController', function() {
    var $scope, $uibModalInstance, hostIds, translate, HostBulkAction, HostCollection, Organization,
        Task, CurrentOrganization, Nutupane, $location, hostCollectionIds;

    beforeEach(module('Bastion.content-hosts', 'Bastion.test-mocks'));

    beforeEach(function() {
        hostCollectionIds =  ['hostCollection1', 'hostCollection2'];
        HostBulkAction = {
            addHostCollections: function() {},
            removeHostCollections: function() {},
            installContent: function() {},
            updateContent: function() {},
            removeContent: function() {},
            removeHosts: function() {}
        };
        HostCollection = {
            query: function() {}
        };
        Organization = {
            query: function() {},
            autoAttach: function() {}
        };
        Nutupane = function() {
           this.getAllSelectedResults = function() {
               return {
                   included: { ids: hostCollectionIds }
               };
            };
            this.table = { };
        };
        Task = {
            query: function() {},
            poll: function() {}
        };
        translate = function() {};
        CurrentOrganization = 'foo';

        $uibModalInstance = {
            close: function () {},
            dismiss: function () {}
        };

        hostIds = {included: {ids: [1, 2, 3]}};
    });

    beforeEach(inject(function($injector) {
        $location = $injector.get('$location');
    }));

    beforeEach(inject(function($controller, $rootScope, $q) {
        $scope = $rootScope.$new();

        $controller('ContentHostsBulkHostCollectionsModalController', {$scope: $scope,
            $uibModalInstance: $uibModalInstance,
            hostIds: hostIds,
            $location: $location,
            HostBulkAction: HostBulkAction,
            HostCollection: HostCollection,
            Nutupane: Nutupane,
            translate: translate,
            Organization: Organization,
            CurrentOrganization: CurrentOrganization,
            Task: Task});
    }));

    it("can add host collections to multiple content hosts", function() {
        var expected = hostIds;
        expected.host_collection_ids = hostCollectionIds;
        expected.organization_id = CurrentOrganization;

        $scope.hostCollections = {
            action: 'add'
        };

        spyOn(HostBulkAction, 'addHostCollections');
        $scope.performHostCollectionAction();

        expect(HostBulkAction.addHostCollections).toHaveBeenCalledWith(expected,
            jasmine.any(Function), jasmine.any(Function));
    });

    it("can remove host collections from multiple content hosts", function() {
        var expected = hostIds;
        expected.host_collection_ids = hostCollectionIds;
        expected.organization_id = CurrentOrganization;

        $scope.hostCollections = {
            action: 'remove'
        };

        spyOn(HostBulkAction, 'removeHostCollections');
        $scope.performHostCollectionAction();


        expect(HostBulkAction.removeHostCollections).toHaveBeenCalledWith(expected,
            jasmine.any(Function), jasmine.any(Function));
    });

});
