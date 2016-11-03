describe('Controller: ActivationKeysController', function() {
    var $scope,
        ActivationKey,
        Nutupane;

    beforeEach(module('Bastion.activation-keys', 'Bastion.test-mocks'));

    beforeEach(function() {
        Nutupane = function() {
            this.table = {
                showColumns: function() {}
            };
            this.get = function() {};
        };
        ActivationKey = {};
    });

    beforeEach(inject(function($controller, $rootScope, $location) {
        $scope = $rootScope.$new();

        $controller('ActivationKeysController', {
            $scope: $scope,
            $location: $location,
            translate: function(){},
            Nutupane: Nutupane,
            ActivationKey: ActivationKey,
            CurrentOrganization: 'CurrentOrganization'
        });
    }));

    it('attaches the nutupane table to the scope', function() {
        expect($scope.table).toBeDefined();
    });
});
