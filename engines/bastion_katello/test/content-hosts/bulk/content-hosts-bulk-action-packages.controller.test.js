describe('Controller: ContentHostsBulkActionPackagesController', function() {
    var $scope, $q, translate, ContentHostBulkAction, HostCollection, Organization,
        Task, CurrentOrganization, selected;

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
            query: function() {},
            autoAttach: function() {}
        };
        Task = {
            query: function() {},
            poll: function() {}
        };
        translate = function() {};
        CurrentOrganization = 'foo';
        selected = {included: {ids: [1, 2, 3]}}
    });

    beforeEach(inject(function($controller, $rootScope, $q) {
        $scope = $rootScope.$new();
        $scope.nutupane = {};
        $scope.nutupane.getAllSelectedResults = function () { return selected }
        $scope.setState = function(){};

        $controller('ContentHostsBulkActionPackagesController', {$scope: $scope,
            $q: $q,
            ContentHostBulkAction: ContentHostBulkAction,
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

        spyOn(ContentHostBulkAction, 'installContent');
        $scope.performContentAction();

        expect(ContentHostBulkAction.installContent).toHaveBeenCalledWith(
            _.extend({}, selected, {
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

        spyOn(ContentHostBulkAction, 'updateContent');
        $scope.performContentAction();

        expect(ContentHostBulkAction.updateContent).toHaveBeenCalledWith(
            _.extend({}, selected, {
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

        spyOn(ContentHostBulkAction, 'removeContent');
        $scope.performContentAction();

        expect(ContentHostBulkAction.removeContent).toHaveBeenCalledWith(
            _.extend({}, selected, {
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

        spyOn(ContentHostBulkAction, 'installContent');
        $scope.performContentAction();

        expect(ContentHostBulkAction.installContent).toHaveBeenCalledWith(
            _.extend({}, selected, {
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

        spyOn(ContentHostBulkAction, 'updateContent');
        $scope.performContentAction();

        expect(ContentHostBulkAction.updateContent).toHaveBeenCalledWith(
            _.extend({}, selected, {
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

        spyOn(ContentHostBulkAction, 'removeContent');
        $scope.performContentAction();

        expect(ContentHostBulkAction.removeContent).toHaveBeenCalledWith(
            _.extend({}, selected, {
                content_type: $scope.content.contentType,
                content: $scope.content.content.split(/ *, */)
            }),
            jasmine.any(Function), jasmine.any(Function)
        );
    });


});
