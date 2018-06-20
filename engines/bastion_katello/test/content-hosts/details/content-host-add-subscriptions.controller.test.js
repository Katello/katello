describe('Controller: ContentHostAddSubscriptionsController', function() {
    var $scope,
        $controller,
        translate,
        HostSubscription,
        Subscription,
        Host,
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
        HostSubscription.addSubscriptions = function() {};
        $scope = $injector.get('$rootScope').$new();
        $location = $injector.get('$location');
        SubscriptionsHelper = $injector.get('SubscriptionsHelper');

        translate = function(message) {
            return message;
        };

        expectedRows = [];

        expectedTable = {
            showColumns: function() {},
            getSelected: function() {
                return expectedRows;
            },
            params: {},
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
        translate = function(message) {
            return message;
        };
        ContentHostSubscription = {
            remove: function() {},
            save: function() {}
        };

        subscription = {
            'multi_entitlement': false,
            available: 0,
            selected: false
        };

        $scope.host = new Host({
            id: 12345
        });

        $scope.$stateParams = {hostId: $scope.host.id};

        $controller('ContentHostAddSubscriptionsController', {
            $scope: $scope,
            $location: $location,
            translate: translate,
            CurrentOrganization: 'organization',
            Subscription: Subscription,
            Host: Host,
            Nutupane: Nutupane,
            SubscriptionsHelper: SubscriptionsHelper,
            HostSubscription: HostSubscription
        });
    }));

    it('attaches the nutupane table to the scope', function() {
        expect($scope.nutupane).toBeDefined();
        expect($scope.table).toBeDefined();
    });

    it("groups subscriptions by product name", function () {
        var expected = [1];
        spyOn(SubscriptionsHelper, 'groupByProductName');

        $scope.table.rows = expected;
        $scope.$digest();

        expect(SubscriptionsHelper.groupByProductName).toHaveBeenCalledWith(expected)
    });

    it("defaults filters to false", function () {
        expect($scope.showMatchHost).toBe(false);
        expect($scope.showMatchInstalled).toBe(false);
        expect($scope.showNoOverlap).toBe(false);
    });

    it("provides a method to toggle the filters", function () {
        $scope.showMatchHost = true;
        $scope.showMatchInstalled = true;
        $scope.showNoOverlap = true;
        spyOn($scope.nutupane, 'refresh');

        $scope.toggleFilters();

        expect($scope.nutupane.table.params['match_host']).toBe(true);
        expect($scope.nutupane.table.params['match_installed']).toBe(true);
        expect($scope.nutupane.table.params['no_overlap']).toBe(true);
        expect($scope.nutupane.refresh).toHaveBeenCalled();
    });

    it("disables the add subscription button if necessary", function () {
        $scope.table.numSelected = 0;
        $scope.isAdding = true;
        expect($scope.disableAddButton()).toBe(true);

        $scope.table.numSelected = 1;
        $scope.isAdding = true;
        expect($scope.disableAddButton()).toBe(true);

        $scope.table.numSelected = 0;
        $scope.isAdding = false
        expect($scope.disableAddButton()).toBe(true);

        $scope.table.numSelected = 1;
        $scope.isAdding = false;
        expect($scope.disableAddButton()).toBe(false);
    });

    it("allows adding subscriptions to the content host", function() {
        var expected = {id: $scope.host.id, subscriptions: [
                                                      {id: 2, quantity: 0},
                                                      {id: 3, quantity: 1},
                                                      {id: 4, quantity: 1}
                                                    ]};
        spyOn(HostSubscription, 'addSubscriptions');

        $scope.table.getSelected = function() {
            return [
                     {id: 2, 'multi_entitlement': true},
                     {id: 3, 'multi_entitlement': true, 'amount': 1},
                     {id: 4, 'multi_entitlement': false}
                   ];
        };

        $scope.addSelected();
        expect(HostSubscription.addSubscriptions).toHaveBeenCalledWith(expected, jasmine.any(Function), jasmine.any(Function));
    });

    it("sets a local scope function for getting the selector amount values from the subscription helper", function () {
        expect($scope.amountSelectorValues).toBe(SubscriptionsHelper.getAmountSelectorValues);
    });
});
