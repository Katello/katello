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
 * @name  Bastion.systems.controller:SystemAddSubscriptionsController
 *
 * @requires $scope
 * @requires $location
 * @requires translate
 * @requires CurrentOrganization
 * @requires Subscription
 * @requires System
 * @requires Nutupane
 * @requires SystemsHelper
 * @requires SubscriptionsHelper
 *
 * @description
 *   Provides the functionality for the system details action pane.
 */
angular.module('Bastion.systems').controller('SystemAddSubscriptionsController',
    ['$scope', '$location', 'translate', 'CurrentOrganization', 'Subscription', 'System', 'Nutupane', 'SystemsHelper', 'SubscriptionsHelper',
    function ($scope, $location, translate, CurrentOrganization, Subscription, System, Nutupane, SystemsHelper, SubscriptionsHelper) {

        var addSubscriptionsPane, params;

        params = {
            'id':                       $scope.$stateParams.systemId,
            'organization_id':          CurrentOrganization,
            'search':                   $location.search().search || "",
            'sort_by':                  'name',
            'sort_order':               'ASC'
        };

        addSubscriptionsPane = new Nutupane(System, params, 'available');
        $scope.addSubscriptionsTable = addSubscriptionsPane.table;
        $scope.isAdding  = false;
        $scope.addSubscriptionsTable.closeItem = function () {};

        $scope.groupedSubscriptions = {};
        $scope.$watch('addSubscriptionsTable.rows', function (rows) {
            $scope.groupedSubscriptions = SubscriptionsHelper.groupByProductName(rows);
        });

        $scope.disableAddButton = function () {
            return $scope.addSubscriptionsTable.numSelected === 0 || $scope.isAdding || !$scope.system.permissions.editable;
        };

        $scope.addSelected = function () {
            var selected;
            selected = SubscriptionsHelper.getSelectedSubscriptionAmounts($scope.addSubscriptionsTable);

            $scope.isAdding = true;
            System.addSubscriptions({uuid: $scope.system.uuid, 'subscriptions': selected}, function () {
                $scope.successMessages.push(translate("Successfully added %s subscriptions.").replace('%s', selected.length));
                $scope.isAdding = false;
                addSubscriptionsPane.refresh();
            }, function (response) {
                $scope.$parent.errorMessages = response.data.displayMessage;
                $scope.isAdding  = false;
            });
        };

        $scope.amountSelectorValues = function (subscription) {
            // TODO: should the logic for step go here since system is known whether phys or virt?
            var step, value, values;

            step = subscription['instance_multiplier'];
            if (!step || step < 1) {
                step = 1;
            }
            values = [];
            for (value = step; value < subscription.quantity && values.length < 5; value += step) {
                values.push(value);
            }
            values.push(subscription.quantity);
            return values;
        };

    }]
);
