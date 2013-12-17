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
 * @name  Bastion.subscriptions.controller:SystemSubscriptionsController
 *
 * @requires $scope
 * @requires gettext
 * @requires System
 * @requires Nutupane
 *
 * @description
 *   Provides the functionality for the system details action pane.
 */
angular.module('Bastion.systems').controller('SystemSubscriptionsController',
    ['$scope', 'gettext', 'SystemSubscription', 'System', 'Nutupane', 'SystemsHelper',
    function ($scope, gettext, SystemSubscription, System, Nutupane, SystemsHelper) {
        var currentSubscriptionsNutupane,
            availableSubscriptionsNutupane,
            successHandler,
            errorHandler,
            refresh;

        successHandler = function () {
            refresh();
            $scope.successMessages.push(gettext('Subscriptions updated.'));
        };

        errorHandler = function (error) {
            _.each(error.data["errors"], function (errorMessage) {
                $scope.errorMessages.push(gettext('An error occurred updating the subscription: ') + errorMessage);
            });
            availableSubscriptionsNutupane.table.working = false;
            currentSubscriptionsNutupane.table.working = false;
        };

        currentSubscriptionsNutupane = new Nutupane(SystemSubscription, {systemId: $scope.$stateParams.systemId});
        $scope.currentSubscriptionsTable = currentSubscriptionsNutupane.table;
        currentSubscriptionsNutupane.query();

        availableSubscriptionsNutupane = new Nutupane(System, {id: $scope.$stateParams.systemId}, 'availableSubscriptions');
        $scope.availableSubscriptionsTable = availableSubscriptionsNutupane.table;
        availableSubscriptionsNutupane.query();

        refresh = function () {
            availableSubscriptionsNutupane.table.selectAll(false);
            availableSubscriptionsNutupane.refresh();
            currentSubscriptionsNutupane.table.selectAll(false);
            currentSubscriptionsNutupane.refresh();
            $scope.system.$get();
        };

        $scope.removeSubscriptions = function () {
            var selectedRows = $scope.currentSubscriptionsTable.getSelected(),
                allSelected = $scope.currentSubscriptionsTable.allSelected;

            availableSubscriptionsNutupane.table.working = true;
            currentSubscriptionsNutupane.table.working = true;

            if (allSelected) {
                SystemSubscription.remove({systemId: $scope.system.uuid}, successHandler, errorHandler);
            } else {
                _.each(selectedRows, function (row) {
                    SystemSubscription.remove({systemId: $scope.system.uuid, id: row.entitlementId},
                        successHandler, errorHandler);
                });
            }
        };

        $scope.attachSubscriptions = function () {
            var selectedRows = $scope.availableSubscriptionsTable.getSelected();

            _.each(selectedRows, function (row) {
                var quantity = row.amount || 1;
                SystemSubscription.save({systemId: $scope.system.uuid, 'subscription_id': row['cp_id'], quantity: quantity}, successHandler, errorHandler);
            });

        };

        $scope.autoAttachSubscriptions = function () {
            System.refreshSubscriptions({uuid: $scope.system.uuid});
            refresh();
        };

        $scope.availableSubscriptionsTable.range = function (start, end, step) {
            var range = [];
            start = start || 0;
            step = step || 1;

            if (end) {
                range = _.range(start, end, step);
            }
            return range;
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
            available = available < 0 ? gettext('Unlimited') : available;
            subscription.availableDisplay = available;
            return subscription;
        };

        $scope.availableSubscriptionsTable.showSelector = function (subscription) {
            return subscription['multi_entitlement'] &&
                subscription.available > 1 && subscription.selected;
        };

        $scope.getStatusColor = SystemsHelper.getStatusColor;
    }
]);
