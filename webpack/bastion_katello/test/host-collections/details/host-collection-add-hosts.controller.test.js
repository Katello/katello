describe('Controller: HostCollectionAddHostsController', function() {
    var $scope,
        HostCollection,
        Host,
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
            this.setSearchKey = function() {};
            this.refresh = function() {};
        };
        HostCollection = {addHosts: function(){}};
        Host = {
            results: [{id: 1, name: "booyah"}]
        };
    });

    beforeEach(inject(function($controller, $rootScope, $location) {
        $scope = $rootScope.$new();
        $scope.hostCollection = {id: 5};

        $controller('HostCollectionAddHostsController', {
            $scope: $scope,
            $location: $location,
            Nutupane: Nutupane,
            translate: function(){},
            HostCollection: HostCollection,
            Host: Host,
            CurrentOrganization: 'CurrentOrganization'
        });
    }));

    it('attaches the nutupane table to the scope', function() {
        expect($scope.table).toBeDefined();
    });

    it('adds selected hosts', function(){
        var expected_params = {id: $scope.hostCollection.id, 'host_ids': ['abcd']};
        spyOn(HostCollection, "addHosts");
        $scope.addSelected();
        expect(HostCollection.addHosts).toHaveBeenCalledWith(expected_params, jasmine.any(Function), jasmine.any(Function));
    });

});
