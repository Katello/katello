describe('Service: PathsService', function () {
    var PathsService, data, Organization, CurrentOrganization,
        lib, dev, test, random;

    beforeEach(module('Bastion.environments', 'Bastion.test-mocks'));

    beforeEach(function () {
        module(function ($provide) {
            $provide.service('Organization', function () {
                return {};
            });
            $provide.service('CurrentOrganization', function () {
                return {};
            });
        });
    });

    beforeEach(inject(function ($injector) {
        lib = { name: "Library", library: true, id: 1, prior: null};
        dev = { name: "Dev", library: false, id: 2, prior: lib };
        test = { name: "Test", library: false, id: 3, prior: dev };
        random = { name: "Random", library: false, id: 4, prior: lib};
        data = [
            { environments: [lib, dev, test] },
            { environments: [lib, random] }
        ];
        PathsService = $injector.get('PathsService');
        PathsService.loadPaths = function () {
            return {
                then: function (callback) {
                    return callback(data);
                }
            }
        };
    }));

    it('should return library when getActualPaths is called', function () {
        expect(PathsService).toBeDefined();
        expect(PathsService.getActualPaths().library).toBe(lib);
    });

    it('should return paths without library when getActualPaths is called', function () {
        var actualPaths = PathsService.getActualPaths().paths
        expect(actualPaths[0].environments[0].library).toBe(false);
    });

    it('should return whole current path when getCurrentPath is called', function () {
        var currentPath = PathsService.getCurrentPath(test);
        expect(currentPath[0].library).toBe(true);
        expect(currentPath[currentPath.length - 1].name).toBe("Test");
    });
});
