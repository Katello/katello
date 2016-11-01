/**
 * @ngdoc object
 * @name  Bastion.subscriptions.controller:SubscriptionActivationKeysController
 *
 * @requires $scope
 * @requires $q
 * @requires translate
 * @requires Subscription
 *
 * @description
 *   Provides the functionality for the subscription details for activation keys.
 */
angular.module('Bastion.subscriptions').controller('SubscriptionActivationKeysController',
    ['$scope', '$q', 'translate', 'Subscription',
    function ($scope, $q, translate, Subscription) {

        if ($scope.activationKeys) {
            $scope.working = false;
        } else {
            $scope.working = true;
        }

        $scope.table = {};

        Subscription.get({id: $scope.$stateParams.subscriptionId}, function (subscription) {
            $scope.activationKeys = subscription['activation_keys'];
            $scope.working = false;
        });
    }]
);
