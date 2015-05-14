describe('Controller: SyncPlanDetailsInfoController', function() {
    var $scope, translate, MenuExpander;

    beforeEach(module('Bastion.sync-plans', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q'),
            SyncPlan = $injector.get('MockResource').$new();

        $scope = $injector.get('$rootScope').$new();
        $scope.$stateParams = {syncPlanId: 1};

        MenuExpander = {};

        translate = function(message) {
            return message;
        };

        $controller('SyncPlanDetailsInfoController', {
            $scope: $scope,
            $q: $q,
            translate: translate,
            SyncPlan: SyncPlan,
            MenuExpander: MenuExpander
        });
    }));

    it("sets the menu expander on the scope", function() {
        expect($scope.menuExpander).toBe(MenuExpander);
    });

    it('should save the sync plan and return a promise', function() {
        var promise = $scope.save($scope.syncPlan);

        expect(promise.then).toBeDefined();
    });

    it('should save the sync plan successfully', function() {
        $scope.save($scope.syncPlan);

        expect($scope.successMessages.length).toBe(1);
        expect($scope.errorMessages.length).toBe(0);
    });

    it('should fail to save the product', function() {
        $scope.syncPlan.failed = true;

        $scope.save($scope.syncPlan);

        expect($scope.successMessages.length).toBe(0);
        expect($scope.errorMessages.length).toBe(1);
    });
});
