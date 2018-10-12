describe('Controller: SubscriptionsController', function() {
    var $scope,
        Nutupane,
        unlimitedFilterFilter,
        translate;

    beforeEach(module('Bastion.subscriptions', 'Bastion.test-mocks', 'Bastion.components.formatters'));

    beforeEach(function() {
        Nutupane = function() {
            this.table = {
                showColumns: function() {}
            };
            this.get = function() {};
        };
    });

    beforeEach(module(function($provide) {
        $provide.value('translate', function(a) {return a});
    }));

    beforeEach(inject(function($controller, $rootScope, $location, $injector, $filter) {
        $scope = $rootScope.$new();
        $q = $injector.get('$q');
        Subscription = $injector.get('MockResource').$new(),
        Provider = $injector.get('MockResource').$new();
        Provider.redhatProvider = function() {};

        translate = function(message) {
            return message;
        };
        unlimitedFilterFilter = $filter('unlimitedFilter');
        $controller('SubscriptionsController', {
            $scope: $scope,
            $q: $q,
            $location: $location,
            translate: translate,
            Nutupane: Nutupane,
            Subscription: Subscription,
            Provider: Provider,
            CurrentOrganization: 'CurrentOrganization',
            unlimitedFilterFilter: unlimitedFilterFilter
        });
    }));

    it('attaches the nutupane table to the scope', function() {
        expect($scope.table).toBeDefined();
    });
    
    it('returns "x of y" for consumed where y can be unlimited', function() {
        var subscription = {consumed: 4, quantity: -1};
        expect($scope.formatConsumed(subscription)).toEqual("4 out of Unlimited");

        var subscription = {consumed: 4, quantity: 10};
        expect($scope.formatConsumed(subscription)).toEqual("4 out of 10");
    });
});
