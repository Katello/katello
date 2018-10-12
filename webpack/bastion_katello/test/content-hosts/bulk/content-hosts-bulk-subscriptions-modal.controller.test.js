describe('Controller: ContentHostsBulkSubscriptionsModalController', function() {
    var $scope, $uibModalInstance, Nutupane, hostIds, CurrentOrganization, HostBulkAction, HostCollection, SubscriptionsHelper;

    beforeEach(module('Bastion.content-hosts', 'Bastion.test-mocks'));

    beforeEach(function() {
        CurrentOrganization = 'foo';

        HostBulkAction = {
            addHostCollections: function() {},
            removeHostCollections: function() {},
            addSubscriptions: function() {},
            removeSubscriptions: function() {},
            autoAttach: function () {},
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

        $uibModalInstance = {
            close: function () {},
            dismiss: function () {}
        };

        Nutupane = function() {
            this.getAllSelectedResults = function() {
                return {
                    included: { ids: hostCollectionIds }
                };
            };
            this.invalidate = function () {};
            this.setSearchKey = function () {};
            this.table = { };
            this.load = function () {};
        };

        hostIds = {included: {ids: [1, 2, 3]}};
    });

    beforeEach(inject(function($rootScope, $controller) {
        $scope = $rootScope.$new();

        $controller('ContentHostsBulkSubscriptionsModalController', {
            $scope: $scope,
            $uibModalInstance: $uibModalInstance,
            hostIds: hostIds,
            Nutupane: Nutupane,
            CurrentOrganization: CurrentOrganization,
            HostBulkAction: HostBulkAction,
            HostCollection: HostCollection,
            SubscriptionsHelper: SubscriptionsHelper
        });
    }));

    it('attaches the nutupane table to the scope', function () {
        expect($scope.contentNutupane).toBeDefined();
        expect($scope.table).toBeDefined();
    });

    it("groups subscriptions by product name", function () {
        var expected = [1];
        spyOn(SubscriptionsHelper, 'groupByProductName');

        $scope.table.rows = expected;
        $scope.$digest();

        expect(SubscriptionsHelper.groupByProductName).toHaveBeenCalledWith(expected)
    });

    it("sets a local scope function for getting the selector amount values from the subscription helper", function () {
        expect($scope.getAmountSelectorValues).toBe(SubscriptionsHelper.getAmountSelectorValues);
    });

    describe("manipulates subscriptions on the hosts", function () {
        beforeEach(function () {
            spyOn(SubscriptionsHelper, 'getSelectedSubscriptionAmounts');
            spyOn($scope, 'transitionTo');
        });

        afterEach(function () {
            expect(SubscriptionsHelper.getSelectedSubscriptionAmounts).toHaveBeenCalledWith($scope.table);
        });

        describe("by adding subscriptions", function () {
            it("and succeeding", function () {
                var response = {id: 1};
                spyOn(HostBulkAction, 'addSubscriptions').and.callFake(function (params, success) {
                    success(response);
                });

                $scope.addSelected();

                expect($scope.transitionTo).toHaveBeenCalledWith('content-hosts.bulk-task', {taskId: response.id})
            });

            it("and failing", function () {
                var response = {data: {errors: []}};

                spyOn(HostBulkAction, 'addSubscriptions').and.callFake(function (params, success, error) {
                    error(response);
                });

                $scope.addSelected();
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

                expect($scope.transitionTo).toHaveBeenCalledWith('content-hosts.bulk-task', {taskId: response.id})
            });

            it("and failing", function () {
                var response = {data: {errors: []}};

                spyOn(HostBulkAction, 'removeSubscriptions').and.callFake(function (params, success, error) {
                    error(response);
                });

                $scope.removeSelected();
                expect($scope.transitionTo).not.toHaveBeenCalled();
            });
        });


        describe("by auto attaching", function () {
            it("and succeeding", function () {
                var response = {id: 1};
                spyOn(HostBulkAction, 'autoAttach').and.callFake(function (params, success) {
                    success(response);
                });

                $scope.autoAttach();

                expect($scope.transitionTo).toHaveBeenCalledWith('content-hosts.bulk-task', {taskId: response.id})
            });

            it("and failing", function () {
                var response = {data: {errors: []}};

                spyOn(HostBulkAction, 'autoAttach').and.callFake(function (params, success, error) {
                    error(response);
                });

                $scope.autoAttach();
                expect($scope.transitionTo).not.toHaveBeenCalled();
            });
        });

    });

    it("provides a function for closing the modal", function () {
        spyOn($uibModalInstance, 'close');
        $scope.ok();
        expect($uibModalInstance.close).toHaveBeenCalled();
    });

    it("provides a function for cancelling the modal", function () {
        spyOn($uibModalInstance, 'dismiss');
        $scope.cancel();
        expect($uibModalInstance.dismiss).toHaveBeenCalled();
    });
});
