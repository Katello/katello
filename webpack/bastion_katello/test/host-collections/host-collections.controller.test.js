describe('Controller: HostCollectionsController', function() {
    var $scope,
        HostCollection,
        Nutupane,
        urlencodeFilter;

    beforeEach(module('Bastion.host-collections', 'Bastion.test-mocks'));

    beforeEach(function() {
        Nutupane = function() {
            this.table = {
                showColumns: function() {}
            };
            this.get = function() {};
        };

        HostCollection = {};

        urlencodeFilter = function () {};
    });

    beforeEach(inject(function($controller, $rootScope, $location) {
        $scope = $rootScope.$new();

        $controller('HostCollectionsController', {
            $scope: $scope,
            $location: $location,
            Nutupane: Nutupane,
            translate: function(){},
            HostCollection: HostCollection,
            CurrentOrganization: 'CurrentOrganization',
            urlencodeFilter: urlencodeFilter
        });
    }));

    it('attaches the nutupane table to the scope', function() {
        expect($scope.table).toBeDefined();
    });
});
