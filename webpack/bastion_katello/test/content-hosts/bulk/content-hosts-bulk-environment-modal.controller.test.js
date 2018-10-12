describe('Controller: ContentHostsBulkEnvironmentModalController', function() {
    var $scope, $uibModalInstance, hostIds, BulkAction, CurrentOrganization, ContentView, paths, Organization;

    beforeEach(module('Bastion.content-hosts', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        BulkAction = {
            environmentContentView: function() {}
        };

        CurrentOrganization = 'foo';
        paths = [[{name: "Library", id: 1}, {name: "Dev", id: 2}]];
        hostIds = {included: {ids: [1, 2, 3]}};
        ContentView = $injector.get('MockResource').$new();
        Organization = $injector.get('MockResource').$new();
        ContentView.queryUnpaged = function(){return {}};

        Organization.readableEnvironments = function (params, callback) {
            var response = paths;

            if (callback) {
                callback.apply(this, response);
            }

            return response;
        };

        $uibModalInstance = {
            close: function () {},
            dismiss: function () {}
        };

        hostIds = {included: {ids: [1, 2, 3]}};
    }));

    beforeEach(inject(function($controller, $rootScope, $q) {
        $scope = $rootScope.$new();

        $scope.table = {
            rows: [],
            numSelected: 5
        };

        $controller('ContentHostsBulkEnvironmentModalController', {
            $scope: $scope,
            $uibModalInstance: $uibModalInstance,
            hostIds: hostIds,
            HostBulkAction: BulkAction,
            Organization: Organization,
            CurrentOrganization: CurrentOrganization,
            ContentView: ContentView
        });
    }));


    it("Should fetch environments on initial load", function () {
        expect($scope.environments).toBe(paths)
    });

    it("should fetch content views", function () {
        $scope.selected.environment = paths[0][0];
        spyOn(ContentView, 'queryUnpaged').and.callThrough();

        $scope.fetchViews();
        expect(ContentView.queryUnpaged).toHaveBeenCalled();
        expect($scope.contentViews).toBe(ContentView.queryUnpaged().results);
    });

    it("should perform the correct action", function () {
        var params = _.extend(hostIds, {environment_id: paths[0][0].id, content_view_id: 109, organization_id: CurrentOrganization});
        $scope.selected.environment = paths[0][0];
        $scope.selected.contentView = {id: 109};
        spyOn(BulkAction, 'environmentContentView')

        $scope.performAction();
        expect(BulkAction.environmentContentView).toHaveBeenCalledWith(params, jasmine.any(Function), jasmine.any(Function));
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
