describe('Controller: SubscriptionDetailsController', function() {
    var $scope, translate;

    beforeEach(module(
        'Bastion.subscriptions',
        'Bastion.test-mocks'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            Subscription = $injector.get('MockResource').$new(),
            ApiErrorHandler = $injector.get('ApiErrorHandler');

        $scope = $injector.get('$rootScope').$new();

        $scope.$stateParams = {subscriptionId: 1};

        translate = function(a) { return a };

        $controller('SubscriptionDetailsController', {
            $scope: $scope,
            translate: translate,
            Subscription: Subscription,
            ApiErrorHandler: ApiErrorHandler
        });
    }));

    it('should attach a subscription resource onto the scope', function() {
        expect($scope.subscription).toBeDefined();
    });

    describe('provides a subscription limits method', function() {

        it("returns the number of sockets for subscription with socket limit", function() {
            var subscription = {sockets: 5};
            expect($scope.subscriptionLimits(subscription)).toBe("Sockets: 5");
        });

        it("returns the amount of ram for subscription with memory limit", function() {
            var subscription = {ram: 4};
            expect($scope.subscriptionLimits(subscription)).toBe("RAM: 4 GB");
        });

        it("returns sockets and cores for subscription with socket and core limit", function() {
            var subscription = {sockets: 2, cores: 4};
            expect($scope.subscriptionLimits(subscription)).toBe("Sockets: 2, Cores: 4");
        });

    });

});
