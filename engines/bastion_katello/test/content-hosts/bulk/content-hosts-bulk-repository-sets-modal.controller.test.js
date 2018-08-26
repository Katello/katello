describe('Controller: ContentHostsBulkRepositorySetsModalController', function() {
    var $scope, $uibModalInstance, hostIds, translate, HostBulkAction, RepositorySet, Organization,
        Task, CurrentOrganization, Nutupane, $location, repositorySetIds;

    beforeEach(module('Bastion.content-hosts', 'Bastion.test-mocks'));

    beforeEach(function() {
        repositorySetIds =  [{ id:'repositorySet1', label:'repositorySet1' }, { id:'repositorySet2', label:'repositorySet2' }];
        HostBulkAction = {
            updateRepositorySets: function() {}
        };
        RepositorySet = {
            query: function() {}
        };
        Organization = {
            query: function() {},
            autoAttach: function() {}
        };
        Nutupane = function() {
           this.load = function () {};
           this.setSearchKey = function () {};
           this.getAllSelectedResults = function() {
               return {
                   included: { resources: repositorySetIds }
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

        $controller('ContentHostsBulkRepositorySetsModalController', {$scope: $scope,
            $uibModalInstance: $uibModalInstance,
            hostIds: hostIds,
            $location: $location,
            HostBulkAction: HostBulkAction,
            RepositorySet: RepositorySet,
            Nutupane: Nutupane,
            translate: translate,
            Organization: Organization,
            CurrentOrganization: CurrentOrganization,
            Task: Task});
    }));

    it("can enable repository sets on multiple content hosts", function() {
        var expected = hostIds;
        expected.organization_id = CurrentOrganization;
        expected.content_overrides = [
            {content_label: "repositorySet1", name: "enabled", value: true, remove: false},
            {content_label: "repositorySet2", name: "enabled", value: true, remove: false}
        ];

        $scope.repositorySets = {
            action: 'enable'
        };

        spyOn(HostBulkAction, 'updateRepositorySets');
        $scope.performRepositorySetAction();

        expect(HostBulkAction.updateRepositorySets).toHaveBeenCalledWith(expected,
            jasmine.any(Function), jasmine.any(Function));
    });

    it("can disable repository sets on multiple content hosts", function() {
        var expected = hostIds;
        expected.organization_id = CurrentOrganization;
        expected.content_overrides = [
            {content_label: "repositorySet1", name: "enabled", value: false, remove: false},
            {content_label: "repositorySet2", name: "enabled", value: false, remove: false}
        ];

        $scope.repositorySets = {
            action: 'disable'
        };

        spyOn(HostBulkAction, 'updateRepositorySets');
        $scope.performRepositorySetAction();

        expect(HostBulkAction.updateRepositorySets).toHaveBeenCalledWith(expected,
            jasmine.any(Function), jasmine.any(Function));
    });

    it("can reset repository sets on multiple content hosts", function() {
        var expected = hostIds;
        expected.organization_id = CurrentOrganization;
        expected.content_overrides = [
            {content_label: "repositorySet1", name: "enabled", value: true, remove: true},
            {content_label: "repositorySet2", name: "enabled", value: true, remove: true}
        ];

        $scope.repositorySets = {
            action: 'reset'
        };

        spyOn(HostBulkAction, 'updateRepositorySets');
        $scope.performRepositorySetAction();

        expect(HostBulkAction.updateRepositorySets).toHaveBeenCalledWith(expected,
            jasmine.any(Function), jasmine.any(Function));
    });

});
