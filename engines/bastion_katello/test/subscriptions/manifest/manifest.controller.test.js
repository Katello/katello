describe('Controller: ManifestController', function() {
    var $scope;

    beforeEach(module('Bastion.subscriptions', 'Bastion.test-mocks'));

    beforeEach(inject(function($controller, $rootScope, $injector) {
        var translate;

        translate = function(a) { return a };
        $scope = $rootScope.$new();
        Subscription = $injector.get('Subscription');
        $controller('ManifestController', {
            $scope: $scope,
            translate: translate,
            Subscription: Subscription
        });
    }));
});
