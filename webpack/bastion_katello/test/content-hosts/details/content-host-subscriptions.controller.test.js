describe('Controller: ContentHostSubscriptionsController', function() {
    var $scope,
        $controller,
        translate,
        Host,
        HostSubscription,
        Subscription,
        Nutupane,
        expectedTable,
        expectedRows,
        SubscriptionsHelper;

    beforeEach(module(
        'Bastion.content-hosts',
        'Bastion.subscriptions',
        'Bastion.test-mocks',
        'content-hosts/details/views/content-host-host-collections.html',
        'content-hosts/views/content-hosts.html'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q');

        Host = $injector.get('MockResource').$new();
        HostSubscription = $injector.get('MockResource').$new();
        $scope = $injector.get('$rootScope').$new();
        $location = $injector.get('$location');
        SubscriptionsHelper = $injector.get('SubscriptionsHelper');

        HostSubscription.removeSubscriptions = function() {};

        translate = function(message) {
            return message;
        };

        expectedRows = [];

        expectedTable = {
            showColumns: function() {},
            getSelected: function() {
                return expectedRows;
            },
            rows: function () {
                return expectedRows;
            },
            selectAll: function() {},
            allSelected: false
        };
        Nutupane = function() {
            this.table = expectedTable;
            this.get = function() {};
            this.query = function() {};
            this.refresh = function() {};
            this.setSearchKey = function() {};
            this.setParams = function() {};
            this.load = function() {};
        };

        $scope.host = new Host({
           id: 9389
        });

        $scope.subscriptionsPane = {
            refresh: function() {},
            table: {}
        };
        $scope.$stateParams = {hostId: $scope.host.id};

        $controller('ContentHostSubscriptionsController', {
            $scope: $scope,
            $location: $location,
            translate: translate,
            Subscription: Subscription,
            Nutupane: Nutupane,
            HostSubscription: HostSubscription,
            SubscriptionsHelper: SubscriptionsHelper
        });
    }));

    it('attaches the nutupane table to the scope', function() {
        expect($scope.table).toBeDefined();
    });

    it("allows removing subscriptions from the content host", function() {

        var expected = {id: $scope.host.id, subscriptions: [{id: 2, quantity: 5}]};
        spyOn(HostSubscription, 'removeSubscriptions');

        $scope.table.getSelected = function() {
            return [{id: 2, cp_id: "cpid2", quantity_consumed: 5}];
        };

        $scope.removeSelected();
        expect(HostSubscription.removeSubscriptions).toHaveBeenCalledWith(expected, jasmine.any(Function), jasmine.any(Function));
    });
});
