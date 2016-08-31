describe('Controller: ContentHostsBulkActionSubscriptionsController', function() {
    var $scope, CurrentOrganization, HostBulkAction, HostCollection, SubscriptionsHelper;

    beforeEach(module('Bastion.content-hosts', 'Bastion.test-mocks'));

    beforeEach(function() {
        CurrentOrganization = 'foo';

        HostBulkAction = {
            addHostCollections: function() {},
            removeHostCollections: function() {},
            addSubscriptions: function() {},
            removeSubscriptions: function() {},
            installContent: function() {},
            updateContent: function() {},
            removeContent: function() {},
            unregisterContentHosts: function() {}
        };

        HostCollection = {
            query: function() {}
        };

        SubscriptionsHelper = {
            getSelectedSubscriptionAmounts: function () {},
            groupByProductName: function () {},
            getAmountSelectorValues: function () {}
        };

    });

    beforeEach(inject(function($rootScope, $controller) {
        $scope = $rootScope.$new();
        $scope.nutupane = {
            getAllSelectedResults: function() {
                return {included: [1,2,3]}
            }
        };

        $scope.setState = function () {};

        $controller('ContentHostsBulkActionSubscriptionsController', {
            $scope: $scope,
            CurrentOrganization: CurrentOrganization,
            HostBulkAction: HostBulkAction,
            HostCollection: HostCollection,
            SubscriptionsHelper: SubscriptionsHelper,
        });
    }));

    it('attaches the nutupane table to the scope', function () {
        expect($scope.contentNutupane).toBeDefined();
        expect($scope.detailsTable).toBeDefined();
    });

    it("groups subscriptions by product name", function () {
        var expected = [1];
        spyOn(SubscriptionsHelper, 'groupByProductName');

        $scope.detailsTable.rows = expected;
        $scope.$digest();

        expect(SubscriptionsHelper.groupByProductName).toHaveBeenCalledWith(expected)
    });

    it("sets a local scope function for getting the selector amount values from the subscription helper", function () {
        expect($scope.getAmountSelectorValues).toBe(SubscriptionsHelper.getAmountSelectorValues);
    });

    describe("manipulates subscriptions on the hosts", function () {
        beforeEach(function () {
            spyOn($scope.nutupane, 'getAllSelectedResults').and.callThrough();
            spyOn(SubscriptionsHelper, 'getSelectedSubscriptionAmounts');
            spyOn($scope, 'setState');
            spyOn($scope, 'transitionTo');
        });

        afterEach(function () {
            expect($scope.nutupane.getAllSelectedResults).toHaveBeenCalled();
            expect(SubscriptionsHelper.getSelectedSubscriptionAmounts).toHaveBeenCalledWith($scope.detailsTable);
        });

        describe("by adding subscriptions", function () {
            it("and succeeding", function () {
                var response = {id: 1};
                spyOn(HostBulkAction, 'addSubscriptions').and.callFake(function (params, success) {
                    success(response);
                });

                $scope.addSelected();

                expect($scope.setState).toHaveBeenCalledWith(false, [], []);
                expect($scope.transitionTo).toHaveBeenCalledWith('content-hosts.bulk-actions.task-details', {taskId: response.id})
            });

            it("and failing", function () {
                var response = {errors: []};

                spyOn(HostBulkAction, 'addSubscriptions').and.callFake(function (params, success, error) {
                    error(response);
                });

                $scope.addSelected();
                expect($scope.setState).toHaveBeenCalledWith(false, [], response.errors);
                expect($scope.transitionTo).not.toHaveBeenCalled();
            });
        });

        describe("by removing subscriptions", function () {
            it("and succeeding", function () {
                var response = {id: 1};
                spyOn(HostBulkAction, 'removeSubscriptions').and.callFake(function (params, success) {
                    success(response);
                });

                $scope.removeSelected();

                expect($scope.setState).toHaveBeenCalledWith(false, [], []);
                expect($scope.transitionTo).toHaveBeenCalledWith('content-hosts.bulk-actions.task-details', {taskId: response.id})
            });

            it("and failing", function () {
                var response = {errors: []};

                spyOn(HostBulkAction, 'removeSubscriptions').and.callFake(function (params, success, error) {
                    error(response);
                });

                $scope.removeSelected();
                expect($scope.setState).toHaveBeenCalledWith(false, [], response.errors);
                expect($scope.transitionTo).not.toHaveBeenCalled();
            });
        });
    });
});
