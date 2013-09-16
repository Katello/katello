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
 * @name  Bastion.notices.controller:NoticeDetailsController
 *
 * @requires $scope
 * @requires $q
 * @requires $http
 * @requires Routes
 * @requires Notice
 *
 * @description
 *   Provides the functionality for the notice details action pane.
 */
angular.module('Bastion.notices').controller('NoticeDetailsInfoController',
    ['$scope', '$q', '$http', 'Routes', 'Notice',
    function($scope, $q, $http, Routes, Notice) {
        var customInfoErrorHandler = function(error) {
            $scope.saveError = true;
            $scope.errors = error["errors"];
        };

        $scope.saveSuccess = false;
        $scope.saveError = false;

    }]
);
