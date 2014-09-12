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
 * @name  Bastion.subscriptions.controller:SubscriptionAssociationsContentHostsController
 *
 * @requires $scope
 * @requires translate
 * @requires Subscription
 * @requires ContentHostsHelper
 *
 * @description
 *   Provides the functionality for the subscription details for content host associations.
 */
angular.module('Bastion.subscriptions').controller('SubscriptionAssociationsContentHostsController',
    ['$scope', 'translate', 'Subscription', 'ContentHostsHelper',
    function ($scope, translate, Subscription, ContentHostsHelper) {

        if ($scope.contentHosts) {
            $scope.working = false;
        } else {
            $scope.working = true;
        }

        Subscription.get({id: $scope.$stateParams.subscriptionId}, function (subscription) {
            $scope.contentHosts = subscription.systems;
            $scope.working = false;
        });

        $scope.getStatusColor = ContentHostsHelper.getStatusColor;

        $scope.memory = ContentHostsHelper.memory;

        $scope.virtual = function (facts) {
            if (facts['virt'] === undefined || facts.virt['is_guest'] === undefined) {
                return false;
            }
            return (facts.virt['is_guest'] === true || facts.virt['is_guest'] === 'true');
        };
    }]
);
