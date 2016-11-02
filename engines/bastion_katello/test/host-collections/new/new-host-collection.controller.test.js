describe('Controller: NewHostCollectionController', function() {
    var $scope, $httpBackend;

    beforeEach(module('Bastion.host-collections', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $http = $injector.get('$http'),
            HostCollection= $injector.get('MockResource').$new();

        $scope = $injector.get('$rootScope').$new();
        $httpBackend = $injector.get('$httpBackend');


        $scope.hostCollectionForm = $injector.get('MockForm');

        $controller('NewHostCollectionController', {
            $scope: $scope,
            CurrentOrganization: 'foo',
            HostCollection: HostCollection
        });
    }));

    it('should attach a new host collection resource on to the scope', function() {
        expect($scope.hostCollection).toBeDefined();
    });

    describe('should save a new host collection resource', function() {
        var hostCollection;

        beforeEach(function () {
            hostCollection = $scope.hostCollection;
            spyOn($scope, 'transitionTo');
            spyOn(hostCollection, '$save').and.callThrough();
        });

        afterEach(function () {
            expect(hostCollection.$save).toHaveBeenCalled();
            expect($scope.transitionTo).toHaveBeenCalledWith('host-collection.info',
                {hostCollectionId: $scope.hostCollection.id})
        });

        it('with unlimited hosts', function () {
            hostCollection['max_hosts'] = 3;
            hostCollection.unlimited_hosts = true;
            $scope.save(hostCollection);
            expect(hostCollection['unlimited_hosts']).toBe(true);
        });

        it ('with a host limit', function () {
            hostCollection['max_hosts'] = 3;
            hostCollection.unlimited_hosts = false;
            $scope.save(hostCollection);
            expect(hostCollection['max_hosts']).toBe(3);
        });
    });

    it('should fail to save a new host collection resource', function() {
        var hostCollection = $scope.hostCollection;

        hostCollection.failed = true;
        spyOn(hostCollection, '$save').and.callThrough();
        $scope.save(hostCollection);

        expect(hostCollection.$save).toHaveBeenCalled();
        expect($scope.hostCollectionForm['name'].$invalid).toBe(true);
        expect($scope.hostCollectionForm['name'].$error.messages).toBeDefined();
    });
});
