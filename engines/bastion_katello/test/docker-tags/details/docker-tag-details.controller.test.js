describe('Controller: DockerTagDetailsController', function() {
    var $scope,
        DockerTag,
        Nutupane,
        dockerTag,
        translate;

    beforeEach(module('Bastion.docker-tags', 'Bastion.test-mocks', 'Bastion.common'));

    beforeEach(inject(function(MockResource, $injector) {
        Nutupane = function() {
            this.table = {
                showColumns: function() {}
            };
            this.get = function() {};
            this.setParams = function (params) {};
            this.getParams = function (params) { return {}; };
            this.refresh = function () {};
        };
        DockerTag = $injector.get('MockResource').$new();
        spyOn(DockerTag, 'get').and.callThrough();
        dockerTag = DockerTag.get({id: 1});
        translate = function(message) {
            return message;
        };
    }));

    beforeEach(inject(function($controller, $rootScope, $location, MockResource, translateMock, $injector) {
        var ApiErrorHandler = $injector.get('ApiErrorHandler');

        $scope = $rootScope.$new();

        $scope.tag = DockerTag;

        $scope.$stateParams = {tagId: 1};

        $controller('DockerTagDetailsController', {
            $scope: $scope,
            translate: translate,
            $location: $location,
            Nutupane: Nutupane,
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
