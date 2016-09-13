describe('Controller: ContentHostPackagesActionsController', function() {
    var $scope;

    beforeEach(module('Bastion.content-hosts', 'Bastion.hosts', 'Bastion.test-mocks'));

    beforeEach(inject(function($controller) {
        $scope = {};
        $controller('ContentHostPackagesActionsController', {$scope: $scope});
    }));

    it("defaults to package install", function() {
        expect($scope.packageAction.actionType).toBe('packageInstall');
    });
});
