/**
 * Copyright 2014 Red Hat, Inc.
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
 * @name  Bastion.content-hosts.controller:ContentHostSubscriptionsController
 *
 * @requires $scope
 * @requires $location
 * @requires translate
 * @requires Subscription
 * @requires ContentHost
 * @requires SubscriptionsHelper
 *
 * @description
 *   Provides the functionality for the content host details action pane.
 */
angular.module('Bastion.content-hosts').controller('ContentHostSubscriptionsController',
    ['$scope', '$location', 'translate', 'Subscription', 'ContentHost', 'SubscriptionsHelper',
    function ($scope, $location, translate, Subscription, ContentHost, SubscriptionsHelper) {
        
        $scope.subscriptionsTable = $scope.subscriptionsPane.table;
        $scope.subscriptionsTable.closeItem = function () {};
        $scope.isRemoving = false;

        $scope.groupedSubscriptions = {};
        $scope.$watch('subscriptionsTable.rows', function (rows) {
            $scope.groupedSubscriptions = SubscriptionsHelper.groupByProductName(rows);
        });

        $scope.disableRemoveButton = function () {
            return $scope.subscriptionsTable.numSelected === 0 || $scope.isRemoving;
        };

        $scope.removeSelected = function () {
            var selected;
            selected = SubscriptionsHelper.getSelectedSubscriptions($scope.subscriptionsTable);

            $scope.isRemoving = true;
            ContentHost.removeSubscriptions({uuid: $scope.contentHost.uuid, 'subscriptions': selected}, function () {
                ContentHost.get({id: $scope.$stateParams.contentHostId}, function (host) {
                    $scope.$parent.contentHost = host;
                    $scope.subscriptionsPane.table.selectAll(false);
                    $scope.subscriptionsPane.refresh();
                    $scope.successMessages.push(translate("Successfully removed %s subscriptions.").replace('%s', selected.length));
                    $scope.isRemoving = false;
                    $scope.nutupane.refresh();
                });
            }, function (response) {
                $scope.isRemoving = false;
                $scope.errorMessages.push(translate("An error occurred removing the subscriptions.") + response.data.displayMessage);
            });
        };

/*
http://projects.theforeman.org/issues/4253

        $scope.autoAttachSubscriptions = function () {
            ContentHost.refreshSubscriptions({uuid: $scope.contentHost.uuid});
            refresh();
        };

        $scope.availableSubscriptionsTable.matchContentHost = false;
        $scope.availableSubscriptionsTable.matchInstalled = false;
        $scope.availableSubscriptionsTable.noOverlap = false;

        $scope.availableSubscriptionsTable.filterSubscriptions = function () {
            var params = availableSubscriptionsNutupane.getParams();

            params['match_system'] = $scope.availableSubscriptionsTable.matchContentHost;
            params['match_installed'] = $scope.availableSubscriptionsTable.matchInstalled;
            params['no_overlap'] = $scope.availableSubscriptionsTable.noOverlap;

            availableSubscriptionsNutupane.setParams(params);
            availableSubscriptionsNutupane.refresh();
        };

        $scope.availableSubscriptionsTable.formatAvailableDisplay = function (subscription) {
            var available = subscription.available;
            available = available < 0 ? translate('Unlimited') : available;
            subscription.availableDisplay = available;
            return subscription;
        };

        $scope.availableSubscriptionsTable.showSelector = function (subscription) {
            return subscription['multi_entitlement'] &&
                subscription.available > 1 && subscription.selected;
        };

        $scope.getStatusColor = ContentHostsHelper.getStatusColor;
*/
    }
]);
