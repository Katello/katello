describe('Controller: HostCollectionDetailsController', function() {
    var $scope, translate, HostCollection, newHostCollection;

    beforeEach(module('Bastion.host-collections', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $state = $injector.get('$state');

        newHostCollection = {id: 8};
        HostCollection = $injector.get('MockResource').$new();
        HostCollection.copy = function(params, success){success(newHostCollection)};

        $scope = $injector.get('$rootScope').$new();

        $scope.$stateParams = {hostCollectionId: 1};
        $scope.removeRow = function() {};
        $scope.table = {
            addRow: function() {},
            replaceRow: function() {}
        };

        translate = function(message) {
            return message;
        };

        $controller('HostCollectionDetailsController', {
            $scope: $scope,
            $state: $state,
            translate: translate,
            HostCollection: HostCollection
        });
    }));

    it("gets the content host using the host collection service and puts it on the $scope.", function() {
        expect($scope.hostCollection).toBeDefined();
    });

    it('provides a method to remove a host collection', function() {
        spyOn($scope, 'transitionTo');
        spyOn($scope, 'removeRow');

        $scope.removeHostCollection($scope.hostCollection);

        expect($scope.transitionTo).toHaveBeenCalledWith('host-collections.index');
        expect($scope.removeRow).toHaveBeenCalledWith($scope.hostCollection.id);
    });

    it('should save the product successfully', function() {
        $scope.save($scope.hostCollection);

        expect($scope.errorMessages.length).toBe(0);
        expect($scope.successMessages.length).toBe(1);
    });

    it('should fail to save the host collection', function() {
        $scope.hostCollection.failed = true;
        $scope.save($scope.hostCollection);

        expect($scope.successMessages.length).toBe(0);
        expect($scope.errorMessages.length).toBe(1);
    });

    it('should be able to copy the host collection', function(){
        spyOn($scope, 'transitionTo');
        spyOn($scope.table, 'addRow');
        $scope.copy(name);

        expect($scope.transitionTo).toHaveBeenCalledWith('host-collections.details.info', {hostCollectionId: newHostCollection.id});
        expect($scope.table.addRow).toHaveBeenCalledWith(newHostCollection)
    });

    it("should be able to raise the host collection event on the .", function() {
        var eventRaised = false;
        $scope.$on("updateContentHostCollection", function (event, hostCollectionRow) {
             eventRaised = true;
        });
        $scope.refreshHostCollection();
        expect(eventRaised).toBe(true);
    });


});
