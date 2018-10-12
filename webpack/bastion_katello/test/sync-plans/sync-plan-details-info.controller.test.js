describe('Controller: SyncPlanDetailsInfoController', function() {
    var $scope, translate, MenuExpander, Notification;

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

        Notification = {
            setSuccessMessage: function () {},
            setErrorMessage: function () {}
        };

        $controller('SyncPlanDetailsInfoController', {
            $scope: $scope,
            $q: $q,
            translate: translate,
            SyncPlan: SyncPlan,
            MenuExpander: MenuExpander,
            Notification: Notification
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
        spyOn(Notification, 'setSuccessMessage');
        $scope.save($scope.syncPlan);
        expect(Notification.setSuccessMessage).toHaveBeenCalled();
    });

    it('should fail to save the product', function() {
        spyOn(Notification, 'setErrorMessage');

        $scope.syncPlan.failed = true;
        $scope.save($scope.syncPlan);

        expect(Notification.setErrorMessage).toHaveBeenCalled();
    });
});
