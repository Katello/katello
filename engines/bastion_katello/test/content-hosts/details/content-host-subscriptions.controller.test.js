describe('Controller: ContentHostSubscriptionsController', function() {
    var $scope,
        $controller,
        translate,
        ContentHost,
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
        'content-hosts/details/views/host-collections.html',
        'content-hosts/views/content-hosts.html',
        'content-hosts/views/content-hosts-table-full.html'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q');

        ContentHost = $injector.get('MockResource').$new();
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
            this.removeRow = function() {};
            this.get = function() {};
            this.query = function() {};
            this.refresh = function() {};
            this.setSearchKey = function() {};
            this.setParams = function() {};
            this.load = function() {};
        };

        $scope.contentHost = new ContentHost({
            uuid: 12345,
            host: {id: 9389},
            subscriptions: [{id: 1, cp_id: "cpid1", quantity: 11}, {id: 2, cp_id: "cpid2", quantity: 22}]
        });

        $scope.subscriptionsPane = {
            refresh: function() {},
            table: {}
        }

        $controller('ContentHostSubscriptionsController', {
            $scope: $scope,
            $location: $location,
            translate: translate,
            Subscription: Subscription,
            Nutupane: Nutupane,
            ContentHost: ContentHost,
            HostSubscription: HostSubscription,
            SubscriptionsHelper: SubscriptionsHelper
        });
    }));

    it('attaches the nutupane table to the scope', function() {
        expect($scope.detailsTable).toBeDefined();
    });

    it("allows removing subscriptions from the content host", function() {

        var expected = {id: $scope.contentHost.host.id, subscriptions: [{id: 2, quantity: 5}]};
        spyOn(HostSubscription, 'removeSubscriptions');

        $scope.detailsTable.getSelected = function() {
            return [{id: 2, cp_id: "cpid2", quantity: 5}];
        };

        $scope.removeSelected();
        expect(HostSubscription.removeSubscriptions).toHaveBeenCalledWith(expected, jasmine.any(Function), jasmine.any(Function));
    });
});
