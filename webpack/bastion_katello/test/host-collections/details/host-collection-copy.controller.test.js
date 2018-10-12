describe('Controller: HostCollectionCopyController', function() {
    var $scope, HostCollection, newHostCollection;

    beforeEach(module('Bastion.host-collections', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $state = $injector.get('$state');

        newHostCollection = {id: 8};
        HostCollection = $injector.get('MockResource').$new();
        HostCollection.copy = function(params, success){
            success(newHostCollection)
        };

        $scope = $injector.get('$rootScope').$new();

        $scope.$stateParams = {hostCollectionId: 1};

        $controller('HostCollectionCopyController', {
            $scope: $scope,
            HostCollection: HostCollection
        });
    }));

    it('should be able to copy the host collection', function(){
        spyOn($scope, 'transitionTo');
        $scope.copy('name');
        expect($scope.transitionTo).toHaveBeenCalledWith('host-collection.info', {hostCollectionId: newHostCollection.id});
    });
});
