describe('Controller: HostCollectionAddContentHostsController', function() {
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
                    return [{uuid: 'abcd'}]
                }
            };
            this.get = function() {};
        };
        HostCollection = {addContentHosts: function(){}};
        System = {};
    });

    beforeEach(inject(function($controller, $rootScope, $location) {
        $scope = $rootScope.$new();
        $scope.hostCollection = {id: 5};

        $controller('HostCollectionAddContentHostsController', {
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
        expect($scope.addContentHostsTable).toBeDefined();
    });

    it('sets the closeItem function to not do anything', function() {
        spyOn($scope, "transitionTo");
        $scope.addContentHostsTable.closeItem();
        expect($scope.transitionTo).not.toHaveBeenCalled();
    });

    it('adds selected content hosts', function(){
        spyOn(HostCollection, "addContentHosts");
        $scope.addSelected();
        expected_params = {id: $scope.hostCollection.id, 'system_ids': ['abcd']};
        expect(HostCollection.addContentHosts).toHaveBeenCalledWith(expected_params, jasmine.any(Function), jasmine.any(Function));
    });

});
