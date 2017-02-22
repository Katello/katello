/**
 * @ngdoc directive
 * @name Bastion.subscriptions:subscriptionStartDate
 *
 * @description
 *   Directive for the subscription start date
 */
angular.module('Bastion.subscriptions').directive('subscriptionStartDate', function () {
    return {
        restrict: 'AE',
        scope: {
            subscription: '=subscriptionStartDate'
        },
        templateUrl: 'subscriptions/views/subscription-start-date.html',
        controller: ['$scope', 'translate', function ($scope, translate) {
            $scope.checkFutureDate = function (date) {
                return (Date.parse(date) > Date.parse(Date()) ? translate(' (future)') : '');
            };
        }]
    };
});
