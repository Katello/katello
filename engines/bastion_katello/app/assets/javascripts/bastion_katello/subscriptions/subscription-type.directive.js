/**
 * @ngdoc directive
 * @name Bastion.subscriptions:subscriptionType
 *
 * @description
 *   Directive for the subscription type
 */
angular.module('Bastion.subscriptions').directive('subscriptionType', function () {
    return {
        restrict: 'AE',
        scope: {
            subscription: '=subscriptionType'
        },
        templateUrl: 'subscriptions/views/subscription-type.html'
    };
});
