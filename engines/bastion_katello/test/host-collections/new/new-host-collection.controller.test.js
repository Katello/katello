describe('Controller: NewHostCollectionController', function() {
    var $scope;

    beforeEach(module('Bastion.host-collections', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            HostCollection = $injector.get('MockResource').$new;

        $scope = $injector.get('$rootScope').$new();

        $controller('NewHostCollectionController', {
            $scope: $scope,
            HostCollection: HostCollection
        });
    }));

    it('attaches a new host collection resource onto the scope', function() {
        expect($scope.hostCollection).toBeDefined();
    });

});
