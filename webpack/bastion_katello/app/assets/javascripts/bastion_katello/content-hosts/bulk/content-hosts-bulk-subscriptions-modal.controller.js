/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostsBulkSubscriptionsModalController
 *
 * @requires $scope
 * @requires $location
 * @requires $uibModalInstance
 * @requires CurrentOrganization
 * @requires HostBulkAction
 * @requires Subscription
 * @requires ContentHost
 * @requires SubscriptionsHelper
 * @requires Notification
 * @requires hostIds
 *
 * @description
 *   A controller for providing bulk action functionality to the content hosts page.
 */
angular.module('Bastion.content-hosts').controller('ContentHostsBulkSubscriptionsModalController',
    ['$scope', '$location', '$uibModalInstance', 'Nutupane', 'CurrentOrganization', 'HostBulkAction', 'Subscription', 'SubscriptionsHelper', 'Notification', 'hostIds',
        function ($scope, $location, $uibModalInstance, Nutupane, CurrentOrganization, HostBulkAction, Subscription, SubscriptionsHelper, Notification, hostIds) {
            var success, error, params = {
                'organization_id': CurrentOrganization,
                'sort_order': 'ASC',
                'available_for': 'host',
                'host_id': $scope.$stateParams.hostId
            };

            function getBulkSubscriptionParams() {
                var bulkParams = hostIds;
                bulkParams.subscriptions = SubscriptionsHelper.getSelectedSubscriptionAmounts($scope.table);
                return bulkParams;
            }

            success = function (response) {
                $scope.contentNutupane.invalidate();
                $scope.ok();
                $scope.transitionTo('content-hosts.bulk-task', {taskId: response.id});
            };

            error = function (response) {
                angular.forEach(response.data.errors, function (responseError) {
                    Notification.setErrorMessage(responseError);
                });
            };


            $scope.contentNutupane = new Nutupane(Subscription, params,
              'queryPaged', {disableAutoLoad: true});
            $scope.controllerName = 'katello_subscriptions';
            $scope.table = $scope.contentNutupane.table;
            $scope.contentNutupane.setSearchKey('subscriptionSearch');
            $scope.contentNutupane.masterOnly = true;
            $scope.contentNutupane.load();
            $scope.groupedSubscriptions = {};

            $scope.$watch('table.rows', function (rows) {
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

            $scope.autoAttach = function () {
                var bulkParams = getBulkSubscriptionParams();
                HostBulkAction.autoAttach(bulkParams, success, error);
            };

            $scope.ok = function () {
                $uibModalInstance.close();
            };

            $scope.cancel = function () {
                $uibModalInstance.dismiss('cancel');
            };
        }]
);
