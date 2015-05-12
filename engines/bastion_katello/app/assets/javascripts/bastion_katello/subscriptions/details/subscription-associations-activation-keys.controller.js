/**
 * @ngdoc object
 * @name  Bastion.subscriptions.controller:SubscriptionAssociationsActivationKeysController
 *
 * @requires $scope
 * @requires $q
 * @requires translate
 * @requires Subscription
 *
 * @description
 *   Provides the functionality for the subscription details for activation key associations.
 */
angular.module('Bastion.subscriptions').controller('SubscriptionAssociationsActivationKeysController',
    ['$scope', '$q', 'translate', 'Subscription',
    function ($scope, $q, translate, Subscription) {

        if ($scope.activationKeys) {
            $scope.working = false;
        } else {
            $scope.working = true;
        }

        Subscription.get({id: $scope.$stateParams.subscriptionId}, function (subscription) {
            $scope.activationKeys = subscription['activation_keys'];
            $scope.working = false;
        });
    }]
);
