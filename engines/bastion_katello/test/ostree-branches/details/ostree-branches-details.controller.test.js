describe('Controller: OstreeBranchDetailsController', function() {
    var $scope, OstreeBranch;

    beforeEach(module('Bastion.ostree-branches', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller');

        OstreeBranch = $injector.get('MockResource').$new();
        $scope = $injector.get('$rootScope').$new();

        $scope.$stateParams = {branchId: 1};

        $controller('OstreeBranchDetailsController', {
            $scope: $scope,
            OstreeBranch: OstreeBranch
        });
    }));

    it("gets the content host using the host collection service and puts it on the $scope.", function() {
        expect($scope.branch).toBeDefined();
    });
});
