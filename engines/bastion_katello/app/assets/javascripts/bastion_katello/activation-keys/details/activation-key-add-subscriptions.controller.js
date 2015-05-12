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

        var addSubscriptionsPane, params;

        params = {
            'id': $scope.$stateParams.activationKeyId,
            'organization_id': CurrentOrganization,
            'search': $location.search().search || "",
            'sort_by': 'name',
            'sort_order': 'ASC'
        };

        addSubscriptionsPane = new Nutupane(ActivationKey, params, 'availableSubscriptions');
        $scope.addSubscriptionsTable = addSubscriptionsPane.table;
        $scope.isAdding = false;
        $scope.addSubscriptionsTable.closeItem = function () {};

        $scope.groupedSubscriptions = {};
        $scope.$watch('addSubscriptionsTable.rows', function (rows) {
            $scope.groupedSubscriptions = SubscriptionsHelper.groupByProductName(rows);
        });

        $scope.disableAddButton = function () {
            return $scope.addSubscriptionsTable.numSelected === 0 || $scope.isAdding;
        };

        $scope.addSelected = function () {
            var selected;
            selected = SubscriptionsHelper.getSelectedSubscriptionAmounts($scope.addSubscriptionsTable);

            $scope.isAdding = true;
            ActivationKey.addSubscriptions({id: $scope.activationKey.id, 'subscriptions': selected}, function () {
                $scope.successMessages.push(translate("Successfully added %s subscriptions.").replace('%s', selected.length));
                $scope.isAdding = false;
                addSubscriptionsPane.refresh();
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
