describe('Controller: HostCollectionHostsController', function() {
    var $scope,
        HostCollection,
        ContentHost,
        Nutupane;

    beforeEach(module('Bastion.host-collections', 'Bastion.test-mocks'));

    beforeEach(function() {
        Nutupane = function() {
            this.table = {
                showColumns: function() {},
                getSelected: function() {
                    return [{id: 'abcd'}]
                }
            };
            this.get = function() {};
        };
        HostCollection = {removeHosts: function(){}};
        ContentHost = {};
    });

    beforeEach(inject(function($controller, $rootScope, $location) {
        $scope = $rootScope.$new();
        $scope.hostCollection = {id: 5};

        $controller('HostCollectionHostsController', {
            $scope: $scope,
            $location: $location,
            Nutupane: Nutupane,
            translate: function(){},
            HostCollection: HostCollection,
            ContentHost: ContentHost,
            CurrentOrganization: 'CurrentOrganization'
        });
    }));

    it('attaches the nutupane table to the scope', function() {
        expect($scope.hostsTable).toBeDefined();
    });

    it('sets the closeItem function to not do anything', function() {
        spyOn($scope, "transitionTo");
        $scope.hostsTable.closeItem();
        expect($scope.transitionTo).not.toHaveBeenCalled();
    });

    it('removes selected content hosts', function(){
        var expected_params = {id: $scope.hostCollection.id, 'host_ids': ['abcd']};
        spyOn(HostCollection, "removeHosts");
        $scope.removeSelected();
        expect(HostCollection.removeHosts).toHaveBeenCalledWith(expected_params, jasmine.any(Function), jasmine.any(Function));
    });

});
