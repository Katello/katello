/**
 * @ngdoc object
 * @name  Bastion.activation-keys.controller:ActivationKeyAddSubscriptionsController
 *
 * @requires $scope
 * @requires $state
 * @requires $location
 * @requires translate
 * @requires Nutupane
 * @requires CurrentOrganization
 * @requires Subscription
 * @requires ActivationKey
 * @requires SubscriptionsHelper
 *
 * @description
 *   Provides the functionality for the activation key add subscriptions pane.
 */
angular.module('Bastion.activation-keys').controller('ActivationKeyAddSubscriptionsController',
    ['$scope', '$state', '$location', 'translate', 'Nutupane', 'CurrentOrganization', 'Subscription', 'ActivationKey', 'SubscriptionsHelper',
    function ($scope, $state, $location, translate, Nutupane, CurrentOrganization, Subscription, ActivationKey, SubscriptionsHelper) {

        var params;

        params = {
            'activation_key_id': $scope.$stateParams.activationKeyId,
            'organization_id': CurrentOrganization,
            'search': $location.search().search || "",
            'sort_order': 'ASC',
            'available_for': 'activation_key'
        };

        $scope.contentNutupane = new Nutupane(Subscription, params);
        $scope.detailsTable = $scope.contentNutupane.table;
        $scope.isAdding = false;
        $scope.contentNutupane.setSearchKey('subscriptionSearch');
        $scope.contentNutupane.masterOnly = true;

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
            ActivationKey.addSubscriptions({id: $scope.activationKey.id, 'subscriptions': selected}, function () {
                $scope.successMessages.push(translate("Successfully added %s subscriptions.").replace('%s', selected.length));
                $scope.isAdding = false;
                $scope.contentNutupane.refresh();
            }, function (response) {
                $scope.$parent.errorMessages = response.data.displayMessage;
                $scope.isAdding = false;
            });
        };

        $scope.amountSelectorValues = function (subscription) {
            var value, values;

            values = [];
            for (value = 1; value < subscription.quantity && values.length < 5; value += 1) {
                values.push(value);
            }
            values.push(subscription.quantity);
            return values;
        };

    }]
);
