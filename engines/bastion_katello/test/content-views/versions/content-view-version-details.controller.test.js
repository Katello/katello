describe('Controller: ContentViewVersionController', function() {
    var $scope;

    beforeEach(module('Bastion.content-views.versions', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            ContentViewVersion = $injector.get('MockResource').$new();

        $scope = $injector.get('$rootScope').$new();
        $scope.$stateParams = {versionId: 1};

        $controller('ContentViewVersionController', {
            $scope: $scope,
            ContentViewVersion: ContentViewVersion
        });
    }));

    it("puts a content view version on the scope", function() {
        expect($scope.version).toBeDefined();
    });

});
