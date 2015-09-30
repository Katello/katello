/**
 * @ngdoc object
 * @name  Bastion.activation-keys.controller:ActivationKeySubscriptionsController
 *
 * @requires $scope
 * @requires $location
 * @requires translate
 * @requires Nutupane
 * @requires ActivationKey
 * @requires SubscriptionsHelper
 *
 * @description
 *   Provides the functionality for the activation key subscriptions details action pane.
 */
angular.module('Bastion.activation-keys').controller('ActivationKeySubscriptionsController',
    ['$scope', '$location', 'translate', 'Nutupane', 'ActivationKey', 'Subscription', 'SubscriptionsHelper',
    function ($scope, $location, translate, Nutupane, ActivationKey, Subscription, SubscriptionsHelper) {
        var params;

        params = {
            'activation_key_id': $scope.$stateParams.activationKeyId,
            'search': $location.search().search || "",
            'sort_order': 'ASC',
            'paged': true
        };

        $scope.contentNutupane = new Nutupane(Subscription, params);
        $scope.detailsTable = $scope.contentNutupane.table;
        $scope.contentNutupane.masterOnly = true;
        $scope.isRemoving = false;

        $scope.groupedSubscriptions = {};
        $scope.$watch('detailsTable.rows', function (rows) {
            $scope.groupedSubscriptions = SubscriptionsHelper.groupByProductName(rows);
        });

        $scope.disableRemoveButton = function () {
            return $scope.detailsTable.numSelected === 0 || $scope.isRemoving;
        };

        $scope.removeSelected = function () {
            var selected;
            selected = SubscriptionsHelper.getSelectedSubscriptionAmounts($scope.detailsTable);

            $scope.isRemoving = true;
            ActivationKey.removeSubscriptions({id: $scope.activationKey.id, 'subscriptions': selected}, function () {
                $scope.contentNutupane.table.selectAll(false);
                $scope.contentNutupane.refresh();
                $scope.successMessages.push(translate("Successfully removed %s subscriptions.").replace('%s', selected.length));
                $scope.isRemoving = false;
            }, function (response) {
                $scope.isRemoving = false;
                $scope.errorMessages.push(translate("An error occurred removing the subscriptions.") + response.data.displayMessage);
            });
        };

    }]
);
