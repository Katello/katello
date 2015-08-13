/**
 * @ngdoc object
 * @name  Bastion.subscriptions.controller:SubscriptionsController
 *
 * @requires $scope
 * @requires $q
 * @requires $location
 * @requires translate
 * @requires Nutupane
 * @requires Subscription
 * @requires Organization
 * @requires CurrentOrganization
 * @requires unlimitedFilterFilter
 *
 * @description
 *   Provides the functionality specific to Subscriptions for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.subscriptions').controller('SubscriptionsController',
    ['$scope', '$filter', '$location', 'translate', 'Nutupane', 'Subscription', 'Organization', 'CurrentOrganization', 'SubscriptionsHelper',
    function ($scope, $filter, $location, translate, Nutupane, Subscription, Organization, CurrentOrganization, SubscriptionsHelper) {
        var params, nutupane;

        params = {
            'organization_id': CurrentOrganization,
            'search': $location.search().search || "",
            'sort_order': 'ASC',
            'enabled': true,
            'paged': true
        };

        nutupane = new Nutupane(Subscription, params);
        $scope.table = nutupane.table;
        $scope.refreshTable = nutupane.refresh;
        $scope.successMessages = [];
        $scope.errorMessages = [];

        $scope.table.closeItem = function () {
            $scope.transitionTo('subscriptions.index');
        };

        $scope.groupedSubscriptions = {};
        $scope.$watch('table.rows', function (rows) {
            $scope.groupedSubscriptions = SubscriptionsHelper.groupByProductName(rows);
        });

        $scope.formatConsumed = function (subscription) {
            var quantity = $filter('unlimitedFilter')(subscription.quantity);

            return translate('%(consumed)s out of %(quantity)s').replace('%(consumed)s', subscription.consumed).replace('%(quantity)s', quantity);
        };

        $scope.formatInstanceBased = function (subscription) {
            if (angular.isUndefined(subscription['instance_multiplier']) || subscription['instance_multiplier'] === "" || subscription['instance_multiplier'] === 0) {
                return translate("No");
            }
            return translate("Yes");
        };

        $scope.redhatProvider = Organization.redhatProvider();

        $scope.subscriptions = Subscription.queryPaged();

        $scope.$on('$stateChangeSuccess', function () {
            $scope.subscriptions.$promise.then(function () {
                if ($scope.subscriptions.results.length < 1) {
                    $scope.transitionTo('subscriptions.manifest.import');
                }
            });
        });
    }]
);
