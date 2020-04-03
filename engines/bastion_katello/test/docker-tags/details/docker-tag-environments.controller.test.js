describe('Controller: DockerTagEnvironmentsController', function() {
    var $scope,
        dockerTag,
        DockerTag,
        Repository,
        Nutupane;

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
        dockerTag = {id: 1, related_tags: [{id: 1}], repositories: ['test1']};
        DockerTag = MockResource.$new();
        Repository = MockResource.$new();
    }));

    beforeEach(inject(function($controller, $rootScope, $location, MockResource, $injector) {
        var ApiErrorHandler = $injector.get('ApiErrorHandler');
        var translate = function(){};

        $scope = $rootScope.$new();

        $scope.tag = dockerTag;
        $scope.panel = {};
        $scope.$stateParams = {tagId: 1};

        $controller('DockerTagEnvironmentsController', {
            $scope: $scope,
            $location: $location,
            translate: translate,
            Nutupane: Nutupane,
            DockerTag: DockerTag,
            Repository: Repository,
            CurrentOrganization: 'CurrentOrganization',
            ApiErrorHandler: ApiErrorHandler
        });
    }));


    it('attaches the nutupane table to the scope', function() {
        expect($scope.table).toBeDefined();
    });
});
