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
 * @name  Bastion.content-views.controller:ContentViewPublishController
 *
 * @requires $scope
 * @requires translate
 * @requires ContentView
 *
 * @description
 *   Provides the functionality specific to ContentViews for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.content-views').controller('ContentViewPublishController',
    ['$scope', 'translate', 'ContentView', function ($scope, translate, ContentView) {

        $scope.version = {};

        $scope.publish = function (contentView) {
            var description = $scope.version.description,
                data = {'id': contentView.id, 'description': description};
            $scope.working = true;
            ContentView.publish(data, success, failure);
        };

        function success() {
            $scope.transitionTo('content-views.details.versions',
                                {contentViewId: $scope.contentView.id});

            //get the latest version number from the server
            $scope.$parent.contentView = ContentView.get({id: $scope.$stateParams.contentViewId});

            $scope.working = false;
        }

        function failure(response) {
            $scope.$parent.errorMessages = [response.data.displayMessage];
            $scope.working = false;
        }

    }]
);
