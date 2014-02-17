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
 * @name  Bastion.activation-keys.controller:ActivationKeySubscriptionsController
 *
 * @requires $scope
 * @requires $location
 * @requires gettext
 * @requires Nutupane
 * @requires ActivationKey
 * @requires SubscriptionsHelper
 *
 * @description
 *   Provides the functionality for the activation key subscriptions details action pane.
 */
angular.module('Bastion.activation-keys').controller('ActivationKeySubscriptionsController',
    ['$scope', '$location', 'gettext', 'Nutupane', 'ActivationKey', 'SubscriptionsHelper',
    function ($scope, $location, gettext, Nutupane, ActivationKey, SubscriptionsHelper) {
        var subscriptionsPane, params;

        params = {
            'id':          $scope.$stateParams.activationKeyId,
            'search':      $location.search().search || "",
            'sort_by':     'name',
            'sort_order':  'ASC',
            'paged':       true
        };

        subscriptionsPane = new Nutupane(ActivationKey, params, 'subscriptions');
        $scope.subscriptionsTable = subscriptionsPane.table;
        $scope.subscriptionsTable.closeItem = function () {};
        $scope.isRemoving = false;

        $scope.groupedSubscriptions = {};
        $scope.$watch('subscriptionsTable.rows', function (rows) {
            $scope.groupedSubscriptions = SubscriptionsHelper.groupByProductName(rows);
        });

        $scope.disableRemoveButton = function () {
            return $scope.subscriptionsTable.numSelected === 0 || $scope.isRemoving || !$scope.activationKey.permissions.editable;
        };

        $scope.removeSelected = function () {
            var selected;
            selected = SubscriptionsHelper.getSelectedSubscriptionAmounts($scope.subscriptionsTable);

            $scope.isRemoving = true;
            ActivationKey.removeSubscriptions({id: $scope.activationKey.id, 'subscriptions': selected}, function () {
                subscriptionsPane.table.selectAll(false);
                subscriptionsPane.refresh();
                $scope.successMessages.push(gettext("Successfully removed %s subscriptions.").replace('%s', selected.length));
                $scope.isRemoving = false;
            }, function (response) {
                $scope.isRemoving = false;
                $scope.errorMessages.push(gettext("An error occurred removing the subscriptions.") + response.data.displayMessage);
            });
        };

    }]
);
