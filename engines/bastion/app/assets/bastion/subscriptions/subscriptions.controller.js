/**
 * Copyright 2013 Red Hat, Inc.
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
 * @requires gettext
 * @requires Nutupane
 * @requires Subscription
 * @requires Provider
 * @requires CurrentOrganization
 * @requires unlimitedFilterFilter
 *
 * @description
 *   Provides the functionality specific to Subscriptions for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.subscriptions').controller('SubscriptionsController',
    ['$scope', '$q', '$location', 'gettext', 'Nutupane', 'Subscription', 'Provider', 'CurrentOrganization', 'unlimitedFilterFilter',
    function ($scope, $q, $location, gettext, Nutupane, Subscription, Provider, CurrentOrganization, unlimitedFilterFilter) {

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

        $scope.formatConsumed = function (subscription) {
            var quantity = unlimitedFilterFilter(subscription.quantity);

            return gettext('%(consumed)s out of %(quantity)s').replace('%(consumed)s', subscription.consumed).replace('%(quantity)s', quantity);
        };

        $scope.subscriptionType = function (subscription) {
            if (subscription['virt_only']) {
                return gettext('Virtual');
            } else {
                return gettext('Physical');
            }
        };

        $scope.providers = Provider.query({ 'provider_type': 'Red Hat' }, function (response) {
            $scope.provider = _.first(response.results);
        });

        $scope.subscriptions = Subscription.query();

        $q.all([$scope.providers.$promise, $scope.subscriptions.$promise]).then(function () {
            if ($scope.subscriptions.results.length < 1) {
                $scope.transitionTo('subscriptions.manifest.import', {providerId: $scope.provider.id});
            }
        });
    }]
);
