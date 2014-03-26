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
 * @name  Bastion.systems.controller:SystemSubscriptionsController
 *
 * @requires $scope
 * @requires $location
 * @requires translate
 * @requires Subscription
 * @requires System
 * @requires Nutupane
 * @requires SystemsHelper
 * @requires SubscriptionsHelper
 *
 * @description
 *   Provides the functionality for the system details action pane.
 */
angular.module('Bastion.systems').controller('SystemSubscriptionsController',
    ['$scope', '$location', 'translate', 'Subscription', 'System', 'Nutupane', 'SystemsHelper', 'SubscriptionsHelper',
    function ($scope, $location, translate, Subscription, System, Nutupane, SystemsHelper, SubscriptionsHelper) {
        var subscriptionsPane, params;

        params = {
            'id':          $scope.$stateParams.systemId,
            'search':      $location.search().search || "",
            'sort_by':     'name',
            'sort_order':  'ASC',
            'paged':       true
        };

        subscriptionsPane = new Nutupane(System, params, 'subscriptions');
        $scope.subscriptionsTable = subscriptionsPane.table;
        $scope.subscriptionsTable.closeItem = function () {};
        $scope.isRemoving = false;

        $scope.groupedSubscriptions = {};
        $scope.$watch('subscriptionsTable.rows', function (rows) {
            $scope.groupedSubscriptions = SubscriptionsHelper.groupByProductName(rows);
        });

        $scope.disableRemoveButton = function () {
            return $scope.subscriptionsTable.numSelected === 0 || $scope.isRemoving || !$scope.system.permissions.editable;
        };

        $scope.removeSelected = function () {
            var selected;
            selected = SubscriptionsHelper.getSelectedSubscriptions($scope.subscriptionsTable);

            $scope.isRemoving = true;
            System.removeSubscriptions({uuid: $scope.system.uuid, 'subscriptions': selected}, function () {
                subscriptionsPane.table.selectAll(false);
                subscriptionsPane.refresh();
                $scope.successMessages.push(translate("Successfully removed %s subscriptions.").replace('%s', selected.length));
                $scope.isRemoving = false;
            }, function (response) {
                $scope.isRemoving = false;
                $scope.errorMessages.push(translate("An error occurred removing the subscriptions.") + response.data.displayMessage);
            });
        };

/*
http://projects.theforeman.org/issues/4253

        $scope.autoAttachSubscriptions = function () {
            System.refreshSubscriptions({uuid: $scope.system.uuid});
            refresh();
        };

        $scope.availableSubscriptionsTable.matchSystem = false;
        $scope.availableSubscriptionsTable.matchInstalled = false;
        $scope.availableSubscriptionsTable.noOverlap = false;

        $scope.availableSubscriptionsTable.filterSubscriptions = function () {
            var params = availableSubscriptionsNutupane.getParams();

            params['match_system'] = $scope.availableSubscriptionsTable.matchSystem;
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

        $scope.getStatusColor = SystemsHelper.getStatusColor;
*/
    }
]);
