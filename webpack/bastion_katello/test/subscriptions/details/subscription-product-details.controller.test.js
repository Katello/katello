describe('Controller: SubscriptionProductDetailsController', function() {
    var $scope;

    beforeEach(module('Bastion.subscriptions',
                      'subscriptions/views/subscriptions.html'));

    beforeEach(module(function ($stateProvider) {
        $stateProvider.state('subscriptions.fake', {});
    }));

    beforeEach(inject(function (_$controller_, $rootScope, $state) {
        $controller = _$controller_;
        $scope = $rootScope.$new();

        state = {
            transitionTo: function () {}
        };

        $controller('SubscriptionProductDetailsController', {
            $scope: $scope
        });
    }));

    it('should have enabled equal true', function() {
        expect($scope.expanded).toBe(true);
    });
});
