
describe('Controller: ContentHostsBulkReleaseVersionModalController', function() {
    var $scope, $uibModalInstance, hostIds, BulkAction, CurrentOrganization, releaseVersions, Organization;

    beforeEach(module('Bastion.content-hosts', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        BulkAction = {
            releaseVersion: function() {}
        };

        CurrentOrganization = 'foo';
        releaseVersions = ["5.0", "6.0","7Server", "7.1"];
        hostIds = {included: {ids: [1, 2, 3]}};
        Organization = $injector.get('MockResource').$new();

        Organization.releaseVersions = function (params, callback) {
            var response = {results: releaseVersions};
            if (callback) {
                callback(response);
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

        $controller('ContentHostsBulkReleaseVersionModalController', {
            $scope: $scope,
            $uibModalInstance: $uibModalInstance,
            hostIds: hostIds,
            HostBulkAction: BulkAction,
            Organization: Organization,
            CurrentOrganization: CurrentOrganization
        });
    }));


    it("Should fetch releases on initial load", function () {
        expect($scope.releases).toBe(releaseVersions)
    });

    it("should perform the correct action", function () {
        var params = _.extend(hostIds, {release_version: releaseVersions[0], organization_id: CurrentOrganization});
        $scope.selected.release = releaseVersions[0];
        $scope.selected.contentView = {id: 109};
        spyOn(BulkAction, 'releaseVersion')

        $scope.performAction();
        expect(BulkAction.releaseVersion).toHaveBeenCalledWith(params, jasmine.any(Function), jasmine.any(Function));
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
