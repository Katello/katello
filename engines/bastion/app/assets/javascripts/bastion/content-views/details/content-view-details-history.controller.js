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
            'order':            'created_at DESC'
        }, 'history');

        nutupane.table.closeItem = function () {};
        $scope.detailsTable = nutupane.table;

        $scope.actionText = function (history) {
            var message,
                taskType = history.task.label,
                taskTypes = $scope.taskTypes;

            if (taskType === taskTypes.deletion) {
                message = translate("Deleted from %s").replace('%s', history.environment.name);
            } else if (taskType === taskTypes.promotion) {
                message = translate("Promoted to %s").replace('%s', history.environment.name);
            } else if (taskType === taskTypes.publish) {
                message = translate("Published new version");
            }

            return message;
        };
    }]
);
