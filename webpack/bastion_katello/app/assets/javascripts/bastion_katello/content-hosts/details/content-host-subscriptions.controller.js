/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostSubscriptionsController
 *
 * @requires $scope
 * @requires $location
 * @requires translate
 * @requires Subscription
 * @requires SubscriptionsHelper
 * @requires Notification
 *
 * @description
 *   Provides the functionality for the content host details action pane.
 */
angular.module('Bastion.content-hosts').controller('ContentHostSubscriptionsController',
    ['$scope', '$location', 'translate', 'Nutupane', 'CurrentOrganization', 'Subscription', 'Host', 'HostSubscription', 'SubscriptionsHelper', 'Notification',
    function ($scope, $location, translate, Nutupane, CurrentOrganization, Subscription, Host, HostSubscription, SubscriptionsHelper, Notification) {

        var params = {
            'organization_id': CurrentOrganization,
            'id': $scope.$stateParams.hostId,
            'search': $location.search().search || "",
            'sort_order': 'ASC'
        };

        $scope.nutupane = new Nutupane(HostSubscription, params);
        $scope.controllerName = 'katello_subscriptions';
        $scope.nutupane.table.initialLoad = false;
        $scope.table = $scope.nutupane.table;
        $scope.nutupane.masterOnly = true;
        $scope.isRemoving = false;
        $scope.contextAdd = false;
        $scope.groupedSubscriptions = {};
        $scope.$watch('table.rows', function (rows) {
            $scope.groupedSubscriptions = SubscriptionsHelper.groupByProductName(rows);
        });

        $scope.nutupane.setParams(params);
        $scope.nutupane.load(true);

        $scope.disableRemoveButton = function () {
            return $scope.table.numSelected === 0 || $scope.isRemoving;
        };

        $scope.removeSelected = function () {
            var selected;
            selected = SubscriptionsHelper.getSelectedSubscriptions($scope.table);

            $scope.isRemoving = true;
            HostSubscription.removeSubscriptions({id: $scope.$stateParams.hostId, 'subscriptions': selected}, function () {
                Host.get({id: $scope.$stateParams.hostId}, function (host) {
                    $scope.$parent.host = host;
                    $scope.nutupane.table.selectAll(false);
                    $scope.nutupane.refresh();
                    Notification.setSuccessMessage(translate("Successfully removed %s subscriptions.").replace('%s', selected.length));
                    $scope.isRemoving = false;
                });
            }, function (response) {
                $scope.isRemoving = false;
                Notification.setErrorMessage(translate("An error occurred removing the subscriptions.") + response.data.displayMessage);
            });
        };
    }
]);
