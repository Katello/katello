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
 * @name  Bastion.subscriptions.controller:SubscriptionAssociationsActivationKeysController
 *
 * @requires $scope
 * @requires $q
 * @requires translate
 * @requires Subscription
 *
 * @description
 *   Provides the functionality for the subscription details action pane.
 */
angular.module('Bastion.subscriptions').controller('SubscriptionAssociationsActivationKeysController',
    ['$scope', '$q', 'translate', 'Subscription',
    function ($scope, $q, translate, Subscription) {

        if ($scope.activationKeys) {
            $scope.working = false;
        } else {
            $scope.working = true;
        }

        Subscription.get({id: $scope.$stateParams.subscriptionId}, function (subscription) {
            $scope.activationKeys = subscription['activation_keys'];
            $scope.working = false;
        });
    }]
);
