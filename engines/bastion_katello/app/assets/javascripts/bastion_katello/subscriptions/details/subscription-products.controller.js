/**
 * @ngdoc object
 * @name  Bastion.subscriptions.controller:SubscriptionProductsController
 *
 * @requires $scope
 * @requires $state
 * @requires Subscription
 * @requires Product
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality for the subscription products action pane.
 */
angular.module('Bastion.subscriptions').controller('SubscriptionProductsController',
    ['$scope', '$state', 'Subscription', 'Product', 'CurrentOrganization', function ($scope, $state, Subscription, Product, CurrentOrganization) {

        $scope.displayArea = { working: true };

        Product.queryUnpaged({'organization_id': CurrentOrganization,
                              'subscription_id': $scope.$stateParams.subscriptionId,
                              enabled: true,
                              'full_result': true,
                              'include_available_content': true
                             }, function (response) {
            $scope.products = response.results;
            $scope.displayArea.working = false;
        });

    }]
);
