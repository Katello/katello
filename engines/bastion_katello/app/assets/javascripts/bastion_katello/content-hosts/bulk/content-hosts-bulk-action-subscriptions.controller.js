/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostsBulkActionController
 *
 * @requires $scope
 * @requires $location
 * @requires CurrentOrganization
 * @requires HostBulkAction
 * @requires Subscription
 * @requires ContentHost
 * @requires SubscriptionsHelper
 *
 * @description
 *   A controller for providing bulk action functionality to the content hosts page.
 */
angular.module('Bastion.content-hosts').controller('ContentHostsBulkActionSubscriptionsController',
    ['$scope', '$location', 'Nutupane', 'CurrentOrganization', 'HostBulkAction', 'Subscription', 'SubscriptionsHelper',
        function ($scope, $location, Nutupane, CurrentOrganization, HostBulkAction, Subscription, SubscriptionsHelper) {
            var success, error, params = {
                'organization_id': CurrentOrganization,
                'search': $location.search().search || "",
                'sort_order': 'ASC',
                'available_for': 'host',
                'host_id': $scope.$stateParams.hostId
            };

            function getBulkSubscriptionParams() {
                var bulkParams = $scope.nutupane.getAllSelectedResults();
                bulkParams.subscriptions = SubscriptionsHelper.getSelectedSubscriptionAmounts($scope.detailsTable);
                return bulkParams;
            }

            success = function (response) {
                $scope.setState(false, [], []);
                $scope.transitionTo('content-hosts.bulk-actions.task-details', {taskId: response.id});
            };

            error = function (response) {
                $scope.setState(false, [], response.errors);
            };

            $scope.contentNutupane = new Nutupane(Subscription, params);
            $scope.detailsTable = $scope.contentNutupane.table;
            $scope.contentNutupane.setSearchKey('subscriptionSearch');
            $scope.contentNutupane.masterOnly = true;
            $scope.groupedSubscriptions = {};
            $scope.setState(false, [], []);

            $scope.$watch('detailsTable.rows', function (rows) {
                $scope.groupedSubscriptions = SubscriptionsHelper.groupByProductName(rows);
            });

            $scope.getAmountSelectorValues = SubscriptionsHelper.getAmountSelectorValues;

            $scope.addSelected = function () {
                var bulkParams = getBulkSubscriptionParams();
                HostBulkAction.addSubscriptions(bulkParams, success, error);
            };

            $scope.removeSelected = function () {
                var bulkParams = getBulkSubscriptionParams();
                HostBulkAction.removeSubscriptions(bulkParams, success, error);
            };
        }]
);
