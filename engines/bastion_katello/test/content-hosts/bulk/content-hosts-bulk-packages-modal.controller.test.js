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
            contentType: 'package',
            content: 'zip, zsh, xterm'
        };

        spyOn(HostBulkAction, 'installContent');
        $scope.performContentAction();

        expect(HostBulkAction.installContent).toHaveBeenCalledWith(
            _.extend({}, hostIds, {
                content_type: $scope.content.contentType,
                content: $scope.content.content.split(/ *, */)
            }),
            jasmine.any(Function), jasmine.any(Function)
        );
    });

    it("can update packages on multiple content hosts", function() {
        $scope.content = {
            action: 'update',
            contentType: 'package',
            content: 'zip, zsh, xterm'
        };

        spyOn(HostBulkAction, 'updateContent');
        $scope.performContentAction();

        expect(HostBulkAction.updateContent).toHaveBeenCalledWith(
            _.extend({}, hostIds, {
                content_type: $scope.content.contentType,
                content: $scope.content.content.split(/ *, */)
            }),
            jasmine.any(Function), jasmine.any(Function)
        );
    });

    it("can remove packages on multiple content hosts", function() {
        $scope.content = {
            action: 'remove',
            contentType: 'package',
            content: 'zip, zsh, xterm'
        };

        spyOn(HostBulkAction, 'removeContent');
        $scope.performContentAction();

        expect(HostBulkAction.removeContent).toHaveBeenCalledWith(
            _.extend({}, hostIds, {
                content_type: $scope.content.contentType,
                content: $scope.content.content.split(/ *, */)
            }),
            jasmine.any(Function), jasmine.any(Function)
        );
    });

    it("can install package groups on multiple content hosts", function() {
        $scope.content = {
            action: 'install',
            contentType: 'package_group',
            content: 'Backup Client, Development Tools'
        };

        spyOn(HostBulkAction, 'installContent');
        $scope.performContentAction();

        expect(HostBulkAction.installContent).toHaveBeenCalledWith(
            _.extend({}, hostIds, {
                content_type: $scope.content.contentType,
                content: $scope.content.content.split(/ *, */)
            }),
            jasmine.any(Function), jasmine.any(Function)
        );
    });

    it("can update package groups on multiple content hosts", function() {
        $scope.content = {
            action: 'update',
            contentType: 'package_group',
            content: 'Backup Client, Development Tools'
        };

        spyOn(HostBulkAction, 'updateContent');
        $scope.performContentAction();

        expect(HostBulkAction.updateContent).toHaveBeenCalledWith(
            _.extend({}, hostIds, {
                content_type: $scope.content.contentType,
                content: $scope.content.content.split(/ *, */)
            }),
            jasmine.any(Function), jasmine.any(Function)
        );
    });

    it("can remove package groups on multiple content hosts", function() {
        $scope.content = {
            action: 'remove',
            contentType: 'package_group',
            content: 'Backup Client, Development Tools'
        };

        spyOn(HostBulkAction, 'removeContent');
        $scope.performContentAction();

        expect(HostBulkAction.removeContent).toHaveBeenCalledWith(
            _.extend({}, hostIds, {
                content_type: $scope.content.contentType,
                content: $scope.content.content.split(/ *, */)
            }),
            jasmine.any(Function), jasmine.any(Function)
        );
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
