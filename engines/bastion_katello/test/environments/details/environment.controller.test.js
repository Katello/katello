describe('Controller: EnvrionmentController', function () {
    var $scope;

    beforeEach(module('Bastion.environments', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            Envrionment = $injector.get('MockResource').$new(),
            translate = $injector.get('translateMock');

        $scope = $injector.get('$rootScope').$new();
        $scope.$stateParams = {environmentId: 1};

        $controller('EnvironmentController', {
            $scope: $scope,
            Envrionment: Envrionment,
            translate: translate
        });
    }));

    it("puts an environment on the scope", function() {
        expect($scope.environment).toBeDefined();
    });

    it("should provide ability to save an environment and return a promise", function() {
        spyOn($scope.environment, '$update').and.callThrough();

        expect($scope.save($scope.environment).then).toBeDefined();
        expect($scope.environment.$update).toHaveBeenCalled();
    });

    it("should provide ability to remove an environment and return a promise", function() {
        spyOn($scope.environment, '$delete').and.callThrough();

        expect($scope.remove($scope.environment).then).toBeDefined();
        expect($scope.environment.$delete).toHaveBeenCalled();
    });

});
