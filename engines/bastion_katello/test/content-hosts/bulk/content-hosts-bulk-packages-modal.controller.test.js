describe('Controller: ContentHostsBulkPackagesModalController', function() {
    var $scope, $uibModalInstance, hostIds, translate, HostBulkAction, HostCollection, Organization,
        Task, CurrentOrganization;

    beforeEach(module('Bastion.content-hosts', 'Bastion.test-mocks'));

    beforeEach(function() {
        HostBulkAction = {
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

        $uibModalInstance = {
            close: function () {},
            dismiss: function () {}
        };

        hostIds = {included: {ids: [1, 2, 3]}};
    });

    beforeEach(inject(function($controller, $rootScope, $q, $window) {
        $window.AUTH_TOKEN = 'secret_token';
        $scope = $rootScope.$new();

        $controller('ContentHostsBulkPackagesModalController', {$scope: $scope,
            $uibModalInstance: $uibModalInstance,
            hostIds: hostIds,
            HostBulkAction: HostBulkAction,
            HostCollection: HostCollection,
            translate: translate,
            Organization: Organization,
            CurrentOrganization: CurrentOrganization,
            Task: Task});
    }));

    it("can install packages on multiple content hosts", function() {
        $scope.content = {
            action: 'install',
            contentType: 'package'
        };

        $scope.remoteExecutionPresent = true;
        spyOn(HostBulkAction, 'installContent');
        $scope.performContentAction();

        expect($scope.packageActionFormValues.remoteAction).toEqual('package_install');
        expect($scope.packageActionFormValues.bulkHostIds).toBe(angular.toJson({ included: { ids: [1,2,3] }}));
    });

    it("can update packages on multiple content hosts", function() {
        $scope.content = {
            action: 'update',
            contentType: 'package',
        };

        $scope.remoteExecutionPresent = true;
        spyOn(HostBulkAction, 'updateContent');
        $scope.performContentAction();

        expect($scope.packageActionFormValues.remoteAction).toEqual('package_update');
        expect($scope.packageActionFormValues.bulkHostIds).toBe(angular.toJson({ included: { ids: [1,2,3] }}));
    });

    it("can remove packages on multiple content hosts", function() {
        $scope.content = {
            action: 'remove',
            contentType: 'package',
        };

        $scope.remoteExecutionPresent = true;
        spyOn(HostBulkAction, 'removeContent');
        $scope.performContentAction();

        expect($scope.packageActionFormValues.remoteAction).toEqual('package_remove');
        expect($scope.packageActionFormValues.bulkHostIds).toBe(angular.toJson({ included: { ids: [1,2,3] }}));
    });

    it("can install package groups on multiple content hosts", function() {
        $scope.content = {
            action: 'install',
            contentType: 'package_group'
        };

        $scope.remoteExecutionPresent = true;
        spyOn(HostBulkAction, 'installContent');
        $scope.performContentAction();

        expect($scope.packageActionFormValues.remoteAction).toEqual('group_install');
        expect($scope.packageActionFormValues.bulkHostIds).toBe(angular.toJson({ included: { ids: [1,2,3] }}));
    });

    it("can update package groups on multiple content hosts", function() {
        $scope.content = {
            action: 'update',
            contentType: 'package_group'
        };

        $scope.remoteExecutionPresent = true;
        spyOn(HostBulkAction, 'updateContent');
        $scope.performContentAction();

        expect($scope.packageActionFormValues.remoteAction).toEqual('group_update');
        expect($scope.packageActionFormValues.bulkHostIds).toBe(angular.toJson({ included: { ids: [1,2,3] }}));
    });

    it("can remove package groups on multiple content hosts", function() {
        $scope.content = {
            action: 'remove',
            contentType: 'package_group'
        };

        $scope.remoteExecutionPresent = true;
        spyOn(HostBulkAction, 'removeContent');
        $scope.performContentAction();

        expect($scope.packageActionFormValues.remoteAction).toEqual('group_remove');
        expect($scope.packageActionFormValues.bulkHostIds).toBe(angular.toJson({ included: { ids: [1,2,3] }}));
    });

    it("provides a function for closing the modal", function () {
        spyOn($uibModalInstance, 'close');
        $scope.ok();
        expect($uibModalInstance.close).toHaveBeenCalled();
    });

    it("provides a function for cancelling the modal", function () {
        spyOn($uibModalInstance, 'dismiss');
        $scope.cancel();
        expect($uibModalInstance.dismiss).toHaveBeenCalled();
    });
});
