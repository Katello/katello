describe('Controller: ContentViewVersionDeletionEnvironmentsController', function() {
    var $scope, environments, version;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller');

        environments = [{name: 'dev', permissions: {promotable_or_removable: true} }];
        version = {id: 1, environments: environments};

        $scope = $injector.get('$rootScope').$new();
        $scope.transitionToNext = function() {};
        $scope.deleteOptions = {environments: []};
        $scope.version = version;
        $scope.version.$promise = {then: function(callback) {callback(version)}};

        $controller('ContentViewVersionDeletionEnvironmentsController', {
            $scope: $scope
        });
    }));

    it("Should set environmentsTable", function() {
        expect($scope.environmentsTable.rows).toBe(environments);
    });

    it("should save environments as part of processing", function() {
        var selected = [{name: 'troyandabedinthemorning'}];
        spyOn($scope, 'transitionToNext');

        $scope.environmentsTable.getSelected = function() { return selected; };
        $scope.processSelection();

        expect($scope.transitionToNext).toHaveBeenCalled();
        expect( $scope.deleteOptions.environments).toBe(selected);
    });

});
