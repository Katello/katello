describe('Controller: DockerTagsController', function() {
    var $scope,
        DockerTag,
        Repository,
        Nutupane;

    beforeEach(module('Bastion.docker-tags', 'Bastion.test-mocks'));

    beforeEach(function() {
        Nutupane = function() {
            this.table = {
                showColumns: function() {}
            };
            this.get = function() {};
            this.setParams = function (params) {};
            this.getParams = function (params) { return {}; };
            this.refresh = function () {};
        };
        DockerTag = {};
    });

    beforeEach(inject(function($controller, $rootScope, $location, MockResource, translateMock) {
        Repository = MockResource.$new();
        $scope = $rootScope.$new();

        $controller('DockerTagsController', {
            $scope: $scope,
            $location: $location,
            Nutupane: Nutupane,
            DockerTag: DockerTag,
            Repository: Repository,
            CurrentOrganization: 'CurrentOrganization',
            translate: translateMock
        });
    }));

    it('attaches the nutupane table to the scope', function() {
        expect($scope.table).toBeDefined();
    });

    it('sets the closeItem function to transition to the index page', function() {
        spyOn($scope, "transitionTo");
        $scope.table.closeItem();

        expect($scope.transitionTo).toHaveBeenCalledWith('docker-tags');
    });

});
