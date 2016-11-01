describe('Controller: SyncPlansController', function() {
    var $scope,
        translate,
        Nutupane,
        SyncPlan;

    beforeEach(module('Bastion.sync-plans', 'Bastion.test-mocks'));

    beforeEach(function() {
        Nutupane = function() {
            this.table = {
                showColumns: function() {}
            };
            this.get = function() {};
            this.enableSelectAllResults = function () {};
        };

        translate = function (string) {
            return string;
        };

        SyncPlan = {};
    });

    beforeEach(inject(function($controller, $rootScope, $location) {
        $scope = $rootScope.$new();

        $controller('SyncPlansController', {
            $scope: $scope,
            $location: $location,
            translate: translate,
            Nutupane: Nutupane,
            SyncPlan: SyncPlan,
            CurrentOrganization: 'CurrentOrganization'
        });
    }));

    it('attaches the nutupane table to the scope', function() {
        expect($scope.syncPlanTable).toBeDefined();
    });

});

