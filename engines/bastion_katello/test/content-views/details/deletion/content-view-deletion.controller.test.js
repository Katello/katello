describe('Controller: ContentViewDeletionController', function() {
    var $scope,
        versions,
        ContentView;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller');

        versions = [{version: 1, environments:[{name: "name", permissions: {readable: true}}]}, {version: 2, environments: []}];
        ContentView = $injector.get('MockResource').$new();

        $scope = $injector.get('$rootScope').$new();
        $scope.$stateParams = {contentViewId: 1};
        $scope.contentView = {id: '99'};

        ContentView.conflictingVersions = function () {
            return versions;
        };

        $controller('ContentViewDeletionController', {
            $scope: $scope,
            ContentView: ContentView
        });
    }));

    it("properly detects conflicting versions", function() {
        expect($scope.conflictingVersions[0]).toBe(versions[0]);
    });

    it("properly extracts environment names", function () {
        expect($scope.environmentNames(versions[0])[0]).toBe("name");
    });

    it("properly deletes the view", function () {
        spyOn(ContentView, 'remove');
        $scope.delete();
        expect(ContentView.remove).toHaveBeenCalledWith({id: $scope.contentView.id},
            jasmine.any(Function), jasmine.any(Function));
    });
});
