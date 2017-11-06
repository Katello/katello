describe('Controller: DockerTagDetailsController', function() {
    var $scope,
        DockerTag,
        dockerTag;

    beforeEach(module('Bastion.docker-tags', 'Bastion.test-mocks', 'Bastion.common'));

    beforeEach(inject(function(MockResource, $injector) {
        DockerTag = $injector.get('MockResource').$new();
        spyOn(DockerTag, 'get').and.callThrough();
        dockerTag = DockerTag.get({id: 1});
    }));

    beforeEach(inject(function($controller, $rootScope, $location, MockResource, $injector) {
        var ApiErrorHandler = $injector.get('ApiErrorHandler');

        $scope = $rootScope.$new();

        $scope.tag = DockerTag;

        $scope.$stateParams = {tagId: 1};

        $controller('DockerTagDetailsController', {
            $scope: $scope,
            $location: $location,
            DockerTag: DockerTag,
            CurrentOrganization: 'CurrentOrganization',
            ApiErrorHandler: ApiErrorHandler
        });
    }));

    it("gets the tag using the DockerTag service and puts it on the $scope.", function() {
        expect(DockerTag.get).toHaveBeenCalledWith({id: $scope.$stateParams.tagId}, jasmine.any(Function), jasmine.any(Function));
        expect($scope.tag).toBe(dockerTag);
        expect($scope.tag.$promise.then).toBeDefined();
    });
});
