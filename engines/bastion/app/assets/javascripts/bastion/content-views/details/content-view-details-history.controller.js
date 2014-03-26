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
 * @name  Bastion.content-views.controller:ContentViewHistoryController
 *
 * @requires $scope
 * @requires ContentView
 * @requires Nutupane
 *
 * @description
 *   A controller for showing the history of a content view
 */
angular.module('Bastion.content-views').controller('ContentViewHistoryController',
    ['$scope', 'translate', 'ContentView', 'Nutupane',
    function ($scope, translate, ContentView, Nutupane) {
        var nutupane;

        nutupane = new Nutupane(ContentView, {
            id: $scope.$stateParams.contentViewId,
            'sort_by':          'created_at',
            'sort_order':       'DESC'
        }, 'history');

        nutupane.table.closeItem = function () {};
        $scope.detailsTable = nutupane.table;

        $scope.actionText = function (history) {
            var message;
            if (history.environment) {
                message = translate("Promote to %s").replace('%s', history.environment.name);
            } else {
                message = translate("Publish new version.");
            }
            return message;
        };
    }]
);
