/**
 * Copyright 2013-2014 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either version
 * 2 of the License (GPLv2) or (at your option) any later version.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
*/

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
    ['$scope', '$filter', '$q', '$location', 'translate', 'Nutupane', 'Subscription', 'Organization', 'CurrentOrganization', 'SubscriptionsHelper',
    function ($scope, $filter, $q, $location, translate, Nutupane, Subscription, Organization, CurrentOrganization, SubscriptionsHelper) {

        var params = {
            'organization_id':  CurrentOrganization,
            'search':           $location.search().search || "",
            'sort_by':          'name',
            'sort_order':       'ASC',
            'enabled' :         true,
            'paged':            true
        };

        var nutupane = new Nutupane(Subscription, params);
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
            if (subscription['instance_multiplier'] === undefined || subscription['instance_multiplier'] === "" || subscription['instance_multiplier'] === 0) {
                return translate("No");
            }
            return translate("Yes");
        };

        $scope.redhatProvider =  Organization.redhatProvider();

        $scope.subscriptions = Subscription.queryPaged();

        $q.all([$scope.subscriptions.$promise]).then(function () {
            if ($scope.subscriptions.results.length < 1) {
                $scope.transitionTo('subscriptions.manifest.import');
            }
        });
    }]
);
