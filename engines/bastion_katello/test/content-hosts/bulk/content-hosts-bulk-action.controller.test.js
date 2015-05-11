describe('Controller: ContentHostsBulkActionController', function() {
    var $scope, $q, selected, translate, ContentHostBulkAction, HostCollection, Organization, Task, CurrentOrganization;

    beforeEach(module('Bastion.content-hosts', 'Bastion.test-mocks'));

    beforeEach(function() {
        selected = {included: {ids: [1, 2, 3]}};
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
            query: function() {},
            autoAttach: function() {}
        };
        Task = {
            query: function() {},
            poll: function() {}
        };
        translate = function() {};
        CurrentOrganization = 'foo';
    });

    beforeEach(inject(function($controller, $rootScope, $q) {
        $scope = $rootScope.$new();

        $scope.nutupane = {};
        $scope.nutupane.getAllSelectedResults = function () { return selected };

        $controller('ContentHostsBulkActionController', {$scope: $scope,
            $q: $q,
            ContentHostBulkAction: ContentHostBulkAction,
            HostCollection: HostCollection,
            CurrentOrganization: 'foo',
            translate: translate,
            Organization: Organization,
            CurrentOrganization: CurrentOrganization,
            Task: Task});
    }));

    it("can unregister multiple content hosts", function() {
        spyOn(ContentHostBulkAction, 'unregisterContentHosts');
        $scope.performUnregisterContentHosts();

        expect(ContentHostBulkAction.unregisterContentHosts).toHaveBeenCalledWith(_.extend(selected, {'organization_id': 'foo'}),
            jasmine.any(Function), jasmine.any(Function)
        );
    });

    it("defaults showConfirm to false", function () {
        expect($scope.showConfirm).toBe(false);
    });

    it("provides a way to show a confirmation dialog", function () {
        $scope.showConfirmDialog();
        expect($scope.showConfirm).toBe(true);
    });

    it("provides a way to hide a confirmation dialog", function () {
        $scope.showConfirmDialog();
        $scope.hideConfirmDialog();
        expect($scope.showConfirm).toBe(false);
    });
});
