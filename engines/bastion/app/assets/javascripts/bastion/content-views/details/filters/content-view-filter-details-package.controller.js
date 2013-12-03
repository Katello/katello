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
 * @name  Bastion.content-views.controller:ContentViewFilterDetailsController
 *
 * @requires $scope
 * @requires ContentView
 *
 * @description
 *   Provides the functionality specific to ContentViews for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.content-views').controller('ContentViewFilterDetailsPackageController',
    ['$scope', 'ContentView',
    function($scope, ContentView) {

        $scope.filter = $scope.contentView.filters[$scope.$stateParams.filterId - 1];
        $scope.rule = {
            type: "included"
        };

        $scope.filterRules = [];

        $scope.addRule = function(rule) {
            rule.added = new Date();
            rule.detail = 'all';
            $scope.filterRules.push(rule);
            $scope.rule = {
                type: "included"
            };
        };

    }]
);
