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
 * @name  Bastion.content-hosts.controller:ContentHostBaseSubscriptionsController
 *
 * @requires $scope
 * @requires translate
 * @requires CurrentOrganization
 * @requires Subscription
 * @requires ContentHost
 * @requires Nutupane
 *
 * @description
 *   Provides the functionality for the content host details action pane.
 */
angular.module('Bastion.content-hosts').controller('ContentHostBaseSubscriptionsController',
    ['$scope', 'translate', 'CurrentOrganization', 'Subscription', 'ContentHost', 'Nutupane',
    function ($scope, translate, CurrentOrganization, Subscription, ContentHost, Nutupane) {
        var params = {
            'id':                       $scope.$stateParams.contentHostId,
            'organization_id':          CurrentOrganization,
            'sort_by':                  'name',
            'sort_order':               'ASC',
            'match_system':             true
        };

        $scope.subscription = {
            workingMode: false
        };

        $scope.addSubscriptionsPane = new Nutupane(ContentHost, params, 'availableSubscriptions');
        $scope.subscriptionsPane = new Nutupane(ContentHost, params, 'subscriptions');

        $scope.autoAttachSubscriptions = function () {
            $scope.subscription.workingMode = true;
            ContentHost.refreshSubscriptions({uuid: $scope.contentHost.uuid}, success, failure);
        };

        function success() {
            $scope.subscription.workingMode = false;
            $scope.$parent.successMessages = [translate('Successfully updated subscriptions.')];
            $scope.addSubscriptionsPane.refresh();
            $scope.subscriptionsPane.refresh();
            $scope.contentHost.$get();
        }

        function failure() {
            $scope.subscription.workingMode = false;
            $scope.$parent.errorMessages = [translate('An error occurred trying to auto-attach subscriptions.  Please check your log for further information.')];
        }

    }]
);
