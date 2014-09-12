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
 * @name  Bastion.subscriptions.controller:SubscriptionDetailsController
 *
 * @requires $scope
 * @requires translate
 * @requires Subscription
 *
 * @description
 *   Provides the functionality for the subscription details action pane.
 */
angular.module('Bastion.subscriptions').controller('SubscriptionDetailsController',
    ['$scope', 'translate', 'Subscription',
    function ($scope, translate, Subscription) {

        if ($scope.subscription) {
            $scope.panel = {loading: false};
        } else {
            $scope.panel = {loading: true};
        }

        $scope.subscription = Subscription.get({id: $scope.$stateParams.subscriptionId}, function () {
            $scope.panel.loading = false;
        });

        $scope.subscriptionLimits = function (subscription) {
            var limits = [];

            if (subscription.sockets) {
                limits.push(translate("Sockets: %s").replace("%s", subscription.sockets));
            }
            if (subscription.cores) {
                limits.push(translate("Cores: %s").replace("%s", subscription.cores));
            }
            if (subscription.ram) {
                limits.push(translate("RAM: %s GB").replace("%s", subscription.ram));
            }

            if (limits.length > 0) {
                return limits.join(", ");
            } else {
                return "";
            }
        };
    }]
);
