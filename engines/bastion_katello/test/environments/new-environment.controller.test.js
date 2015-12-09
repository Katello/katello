describe('Controller: NewEnvironmentController', function() {
    var $scope,
        FormUtils,
        Environment,
        PathsService;

    beforeEach(module('Bastion.environments', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var dependencies,
            $controller = $injector.get('$controller'),
            currentPath = [{name: "Library", library: true, id: 1}, {name: "Dev", library: false, id: 2}];

        Environment = $injector.get('MockResource').$new();
        $scope = $injector.get('$rootScope').$new();
        PathsService = $injector.get('MockResource').$new();

        FormUtils = {
            labelize: function () {}
        };

        $scope.environmentForm = $injector.get('MockForm');
        $scope.$stateParams.priorId = 1;

        PathsService.getCurrentPath = function (prior) {
            return {
                then: function (callback) { return callback(currentPath); }
            }
        }

        dependencies = {
            $scope: $scope,
            Environment: Environment,
            FormUtils: FormUtils,
            PathsService: PathsService
        };

        $controller('NewEnvironmentController', dependencies);
    }));

    it('should attach a new environment on to the scope', function() {
        expect($scope.environment).toBeDefined();
    });

    it('should fetch and attach the prior environment to the scope', function() {
        expect($scope.priorEnvironment).toBeDefined();
    });

    it('should identify the environments path', function () {
        expect($scope.environment['path_id']).toBeDefined();
        expect($scope.environment['path_id']).toBe(2);
    });

    it('should save a new content view resource', function() {
        var environment = $scope.environment;

        spyOn($scope, 'transitionTo');
        spyOn(environment, '$save').and.callThrough();
        $scope.save(environment);

        expect(environment.$save).toHaveBeenCalled();
        expect(environment['prior_id']).toBe(1);
        expect($scope.transitionTo).toHaveBeenCalledWith('environments');
    });

    it('should fetch a label whenever the name changes', function() {
        spyOn(FormUtils, 'labelize');

        $scope.environment.name = 'ChangedName';
        $scope.$apply();

        expect(FormUtils.labelize).toHaveBeenCalled();
    });
});

