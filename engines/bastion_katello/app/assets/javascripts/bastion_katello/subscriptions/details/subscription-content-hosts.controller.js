/**
 * @ngdoc object
 * @name  Bastion.subscriptions.controller:SubscriptionContentHostsController
 *
 * @requires $scope
 * @requires translate
 * @requires Subscription
 * @requires ContentHostsHelper
 *
 * @description
 *   Provides the functionality for the subscription details for content hosts.
 */
angular.module('Bastion.subscriptions').controller('SubscriptionContentHostsController',
    ['$scope', 'translate', 'Subscription', 'ContentHostsHelper',
    function ($scope, translate, Subscription, ContentHostsHelper) {

        if ($scope.contentHosts) {
            $scope.working = false;
        } else {
            $scope.working = true;
        }

        $scope.table = {};

        Subscription.get({id: $scope.$stateParams.subscriptionId}, function (subscription) {
            $scope.contentHosts = subscription.systems;
            $scope.working = false;
        });

        $scope.getHostStatusIcon = ContentHostsHelper.getHostStatusIcon;

        $scope.memory = ContentHostsHelper.memory;

        $scope.virtual = function (facts) {
            if (angular.isUndefined(facts.virt) || angular.isUndefined(facts.virt['is_guest'])) {
                return false;
            }
            return (facts.virt['is_guest'] === true || facts.virt['is_guest'] === 'true');
        };
    }]
);
