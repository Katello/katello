describe('Controller: SubscriptionProductsController', function() {
    var $scope;

    beforeEach(module(
        'Bastion.subscriptions',
        'Bastion.test-mocks'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            Subscription = $injector.get('MockResource').$new(),
            Product = $injector.get('MockResource').$new();

        $scope = $injector.get('$rootScope').$new();

        $scope.$stateParams = {subscriptionId: 1};

        $controller('SubscriptionProductsController', {
            $scope: $scope,
            Subscription: Subscription,
            Product: Product,
            CurrentOrganization: "ACME"
        });
    }));

    it('should attach a products resource onto the scope', function() {
        expect($scope.products).toBeDefined();
        expect($scope.displayArea.working).toBe(false);
    });

});
