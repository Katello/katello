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
 * @name  Bastion.content-views.controller:NewContentViewController
 *
 * @requires $scope
 * @requires ContentView
 * @requires FormUtils
 *
 * @description
 */
angular.module('Bastion.content-views').controller('NewContentViewController',
    ['$scope', 'ContentView', 'FormUtils',
    function($scope, ContentView, FormUtils) {

        $scope.contentView = new ContentView();
        $scope.createOption = 'new';
        $scope.table = {};

        ContentView.query({}, function(response) {
            $scope.table.rows = response.results;
        });

        $scope.save = function(contentView) {
            contentView.$save(success, error);
        };

        $scope.$watch('contentView.name', function() {
            if ($scope.contentViewForm.name) {
                $scope.contentViewForm.name.$setValidity('server', true);
                $scope.contentView.label = $scope.contentView.name;
                //FormUtils.labelize($scope.contentView, $scope.contentViewForm);
            }
        });

        function success(response) {
            $scope.transitionTo('content-views-details.products.available', {contentViewId: response.id});
        }

        function error(response) {
            console.log('error');
        }

    }]
);
