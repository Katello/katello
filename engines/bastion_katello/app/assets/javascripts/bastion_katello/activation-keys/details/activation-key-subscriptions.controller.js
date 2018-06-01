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
 * @requires Notification
 *
 * @description
 *   Provides the functionality for the activation key subscriptions details action pane.
 */
angular.module('Bastion.activation-keys').controller('ActivationKeySubscriptionsController',
    ['$scope', '$location', 'translate', 'Nutupane', 'ActivationKey', 'Subscription', 'SubscriptionsHelper', 'Notification',
    function ($scope, $location, translate, Nutupane, ActivationKey, Subscription, SubscriptionsHelper, Notification) {
        var params;

        params = {
            'id': $scope.$stateParams.activationKeyId,
            'search': $location.search().search || "",
            'sort_order': 'ASC',
            'paged': true
        };

        $scope.contentNutupane = new Nutupane(ActivationKey, params, "subscriptions");
        $scope.controllerName = 'katello_subscriptions';
        $scope.table = $scope.contentNutupane.table;
        $scope.contentNutupane.masterOnly = true;
        $scope.contentNutupane.setSearchKey('subscriptionSearch');
        $scope.isRemoving = false;
        $scope.contextAdd = false;

        $scope.groupedSubscriptions = {};
        $scope.$watch('table.rows', function (rows) {
            $scope.groupedSubscriptions = SubscriptionsHelper.groupByProductName(rows);
        });

        $scope.disableRemoveButton = function () {
            return $scope.table.numSelected === 0 || $scope.isRemoving;
        };

        $scope.removeSelected = function () {
            var selected;
            selected = SubscriptionsHelper.getSelectedSubscriptionAmounts($scope.table);

            $scope.isRemoving = true;
            ActivationKey.removeSubscriptions({id: $scope.activationKey.id, 'subscriptions': selected}, function () {
                $scope.contentNutupane.table.selectAll(false);
                $scope.contentNutupane.refresh();
                Notification.setSuccessMessage(translate("Successfully removed %s subscriptions.").replace('%s', selected.length));
                $scope.isRemoving = false;
            }, function (response) {
                $scope.isRemoving = false;
                Notification.setErrorMessage(translate("An error occurred removing the subscriptions.") + response.data.displayMessage);
            });
        };

    }]
);
