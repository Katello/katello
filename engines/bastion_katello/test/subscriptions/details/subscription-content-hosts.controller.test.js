describe('Controller: SubscriptionContentHostsController', function() {
    var $scope, translate;

    beforeEach(module(
        'Bastion.subscriptions',
        'Bastion.test-mocks'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            Subscription = $injector.get('MockResource').$new();

        $scope = $injector.get('$rootScope').$new();

        $scope.$stateParams = {subscriptionId: 1};

        translate = function (message) {
            return message;
        };

        $controller('SubscriptionContentHostsController', {
            $scope: $scope,
            translate: translate,
            Subscription: Subscription,
            ContentHostsHelper: {}
        });
    }));

    it('should return proper virtual', function() {
        expect($scope.virtual).toBeDefined();
        expect($scope.virtual({ virt: { 'is_guest': true } })).toBe(true);
        expect($scope.virtual({ virt: { 'is_guest': 'true' } })).toBe(true);
        expect($scope.virtual({ virt: { 'is_guest': false } })).toBe(false);
        expect($scope.virtual({ })).toBe(false);
    });

});
