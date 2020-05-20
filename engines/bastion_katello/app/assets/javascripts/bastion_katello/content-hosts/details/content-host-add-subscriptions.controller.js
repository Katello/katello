/**
 * @ngdoc object
 * @name  Bastion.content-hosts.controller:ContentHostAddSubscriptionsController
 *
 * @requires $scope
 * @requires $location
 * @requires translate
 * @requires CurrentOrganization
 * @requires Subscription
 * @requires ContentHost
 * @requires SubscriptionsHelper
 * @requires Notification
 *
 * @description
 *   Provides the functionality for the content host details action pane.
 */
angular.module('Bastion.content-hosts').controller('ContentHostAddSubscriptionsController',
    ['$scope', '$location', 'translate', 'Nutupane', 'CurrentOrganization', 'Host', 'HostSubscription', 'Subscription', 'SubscriptionsHelper', 'Notification',
    function ($scope, $location, translate, Nutupane, CurrentOrganization, Host, HostSubscription, Subscription, SubscriptionsHelper, Notification) {

        var params = {
            'organization_id': CurrentOrganization,
            'search': $location.search().search || "",
            'sort_order': 'ASC',
            'available_for': 'host',
            'host_id': $scope.$stateParams.hostId
        };

        $scope.nutupane = new Nutupane(Subscription, params);
        $scope.controllerName = 'katello_subscriptions';
        $scope.nutupane.setSearchKey('subscriptionSearch');
        $scope.nutupane.masterOnly = true;
        $scope.table = $scope.nutupane.table;
        $scope.contextAdd = true;
        $scope.isAdding = false;
        $scope.groupedSubscriptions = {};

        $scope.$watch('table.rows', function (rows) {
            $scope.groupedSubscriptions = SubscriptionsHelper.groupByProductName(rows);
        });

        $scope.amountSelectorValues = SubscriptionsHelper.getAmountSelectorValues;
        $scope.showMatchHost = false;
        $scope.showMatchInstalled = false;
        $scope.showNoOverlap = false;

        $scope.toggleFilters = function () {
            $scope.nutupane.table.params['match_host'] = $scope.showMatchHost;
            $scope.nutupane.table.params['match_installed'] = $scope.showMatchInstalled;
            $scope.nutupane.table.params['no_overlap'] = $scope.showNoOverlap;
            $scope.nutupane.refresh();
        };

        $scope.disableAddButton = function () {
            return $scope.table.numSelected === 0 || $scope.isAdding;
        };

        $scope.addSelected = function () {
            var selected;
            selected = SubscriptionsHelper.getSelectedSubscriptionAmounts($scope.table);

            $scope.isAdding = true;
            HostSubscription.addSubscriptions({id: $scope.$stateParams.hostId, 'subscriptions': selected}, function () {
                Host.get({id: $scope.$stateParams.hostId}, function (host) {
                    $scope.$parent.host = host;
                    Notification.setSuccessMessage(translate("Successfully added %s subscriptions.").replace('%s', selected.length));
                    $scope.isAdding = false;
                    $scope.nutupane.refresh();
                });
            }, function (response) {
                Notification.setErrorMessage(response.data.displayMessage);
                $scope.isAdding = false;
                $scope.nutupane.refresh();
            });
        };
    }]
);
