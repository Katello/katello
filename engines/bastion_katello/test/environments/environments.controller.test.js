describe('Controller: EnvironmentsController', function () {
    var $scope, paths, lib, PathsService, data;

    beforeEach(module('Bastion.environments', 'Bastion.test-mocks'));

    beforeEach(inject(function ($injector) {
        var $controller = $injector.get('$controller');
        lib = {library: true, name: 'Library'};
        PathsService = $injector.get('MockResource').$new();
        $scope = $injector.get('$rootScope').$new();

        paths = [{environments:
            [lib, {library: false, name: 'Dev'}]
        }];

        data = {library: lib, paths: paths};

        PathsService.getActualPaths = function() {
            return {
                then: function (callback) { return callback(data); }
            }
        };

        $controller('EnvironmentsController', {
            $scope: $scope,
            PathsService: PathsService
        });

    }));

    it('should fetch the paths for the current organization', function () {
        expect($scope.paths).toBeDefined();
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
