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
 * @name  Bastion.content-views.controller:ContentViewDetailsController
 *
 * @requires $scope
 * @requires ContentView
 * @requires gettext
 *
 * @description
 *   Provides the functionality specific to ContentViews for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.content-views').controller('ContentViewDetailsController',
    ['$scope', 'ContentView', 'gettext',
    function ($scope, ContentView, gettext) {

        $scope.successMessages = [];
        $scope.errorMessages = [];

        ContentView.get({id: $scope.$stateParams.contentViewId}, function (view) {
            $scope.contentView = view;
        });

        $scope.save = function (contentView) {
            return contentView.$update(saveSuccess, saveError);
        };

        function saveSuccess() {
            $scope.successMessages = [gettext('Content View updated.')];
        }

        function saveError(response) {
            angular.forEach(response.data.errors, function (errorMessage) {
                $scope.errorMessages = [gettext("An error occurred updating the Content View: ") + errorMessage];
            });
        }

    }]
);
