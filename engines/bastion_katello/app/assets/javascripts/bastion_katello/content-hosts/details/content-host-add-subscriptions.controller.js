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
 *
 * @description
 *   Provides the functionality for the content host details action pane.
 */
angular.module('Bastion.content-hosts').controller('ContentHostAddSubscriptionsController',
    ['$scope', '$location', 'translate', 'Nutupane', 'CurrentOrganization', 'Subscription', 'ContentHost', 'SubscriptionsHelper',
    function ($scope, $location, translate, Nutupane, CurrentOrganization, Subscription, ContentHost, SubscriptionsHelper) {

        var params = {
            'system_id': $scope.$stateParams.contentHostId,
            'organization_id': CurrentOrganization,
            'search': $location.search().search || "",
            'sort_order': 'ASC',
            'available_for': 'content_host'
        };

        $scope.contentNutupane = new Nutupane(Subscription, params);
        $scope.detailsTable = $scope.contentNutupane.table;
        $scope.contentNutupane.setSearchKey('subscriptionSearch');

        $scope.contentNutupane.masterOnly = true;
        $scope.isAdding = false;

        $scope.groupedSubscriptions = {};
        $scope.$watch('detailsTable.rows', function (rows) {
            $scope.groupedSubscriptions = SubscriptionsHelper.groupByProductName(rows);
        });

        $scope.disableAddButton = function () {
            return $scope.detailsTable.numSelected === 0 || $scope.isAdding;
        };

        $scope.addSelected = function () {
            var selected;
            selected = SubscriptionsHelper.getSelectedSubscriptionAmounts($scope.detailsTable);

            $scope.isAdding = true;
            ContentHost.addSubscriptions({uuid: $scope.contentHost.uuid, 'subscriptions': selected}, function () {
                ContentHost.get({id: $scope.$stateParams.contentHostId}, function (host) {
                    $scope.$parent.contentHost = host;
                    $scope.successMessages.push(translate("Successfully added %s subscriptions.").replace('%s', selected.length));
                    $scope.isAdding = false;
                    $scope.contentNutupane.refresh();
                });
            }, function (response) {
                $scope.$parent.errorMessages = response.data.displayMessage;
                $scope.isAdding = false;
            });
        };

        $scope.amountSelectorValues = function (subscription) {
            var step, value, values;

            step = subscription['instance_multiplier'];
            if (!step || step < 1) {
                step = 1;
            }
            values = [];
            for (value = step; value < subscription.quantity && values.length < 5; value += step) {
                values.push(value);
            }
            values.push(subscription.quantity);
            return values;
        };

    }]
);
