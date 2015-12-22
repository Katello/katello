describe('Controller: RepositoryManageOstreeBranchesController', function() {
    var $scope, translate, Repository;

    beforeEach(module(
        'Bastion.repositories',
        'Bastion.test-mocks'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $state = $injector.get('$state');

        Repository = $injector.get('MockResource').$new();

        $scope = $injector.get('$rootScope').$new();
        $scope.$stateParams = {
            productId: 1,
            repositoryId: 1,
        };

        translate = function(message) {
            return message;
        };

        $controller('RepositoryManageOstreeBranchesController', {
            $scope: $scope,
            translate: translate,
            Repository: Repository
        });
    }));

    it('sets up the ostree branch objects correctly', function() {
        var expectedBranches = ["redhat-atomic-host/el7.0/x86_64/base,redhat-atomic-host/el7.0/x86_64/medium",
                                "redhat-atomic-host/el7.0/x86_64/base,redhat-atomic-host/el7.0/x86_64/base"]

        $scope.wrap({id: 1, ostree_branches: expectedBranches});
        _.each(expectedBranches, function (branch) {
            expect($scope.branchObjects).toContain({name: branch});
        });
    });

    it('sets up the empty ostree branch objects correctly', function() {
        $scope.wrap({id: 1});
        expect($scope.branchObjects).toBeDefined();
        expect($scope.branchObjects.length).toBe(0);
    });
});
