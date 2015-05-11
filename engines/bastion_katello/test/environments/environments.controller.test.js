describe('Controller: EnvironmentsController', function () {
    var $scope, paths;

    beforeEach(module('Bastion.environments', 'Bastion.test-mocks'));

    beforeEach(inject(function ($injector) {
        var $controller = $injector.get('$controller'),
            Organization = $injector.get('MockResource').$new();

        paths = [{environments:
            [{library: true, name: 'Library'}, {library: false, name: 'Dev'}]
        }];

        Organization.paths = function(params, callback) {
            callback(angular.copy(paths));
        };

        $scope = $injector.get('$rootScope').$new();

        $controller('EnvironmentsController', {
            $scope: $scope,
            Organization: Organization,
            CurrentOrganization: 'CurrentOrganization'
        });

    }));

    it('should fetch the paths for the current organization', function () {
        expect($scope.paths).toBeDefined();
    });

    it('should set the paths object without including library', function () {
        expect($scope.paths[0].environments.length).toBe(paths[0].environments.length - 1);
    });

    it('should set the Library object', function () {
        expect($scope.library).toBeDefined();
        expect($scope.library.name).toBe('Library');
    });

    it('should provide determining the last environment in a path', function () {
        var lastEnvironment = $scope.lastEnvironment(paths[0]);

        expect(lastEnvironment).toBe(paths[0].environments.pop());
    });
});
