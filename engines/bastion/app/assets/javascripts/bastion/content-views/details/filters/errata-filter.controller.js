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
 * @name  Bastion.content-views.controller:ErrataFilterController
 *
 * @requires $scope
 *
 * @description
 *   Provides common functionality on the $scope for Errata filters.
 */
angular.module('Bastion.content-views').controller('ErrataFilterController',
    ['$scope', function ($scope) {

        $scope.successMessages = [];
        $scope.errorMessages = [];

        $scope.rule = {
            errataType: 'all',
            'start_date': null,
            'end_date': null
        };

        $scope.date = {
            startOpen: false,
            endOpen: false
        };

        $scope.types = {
            enhancement: true,
            bugfix: true,
            security: true
        };

        $scope.errataFilter = function (errata) {
            var include = false,
                issued = new Date(errata.issued);

            if ($scope.types[errata.type]) {
                include = true;
            }

            if ($scope.rule['start_date']) {
                include = include && (issued.getTime() >= $scope.rule['start_date'].getTime());
            }

            if ($scope.rule['end_date']) {
                include = include && (issued.getTime() <= $scope.rule['end_date'].getTime());
            }

            return include;
        };

        $scope.openEndDate = function ($event) {
            $event.preventDefault();
            $event.stopPropagation();

            $scope.date.endOpen = true;
            $scope.date.startOpen = false;
        };

        $scope.openStartDate = function ($event) {
            $event.preventDefault();
            $event.stopPropagation();

            $scope.date.startOpen = true;
            $scope.date.endOpen = false;
        };

        $scope.onlySelected = function (object, type) {
            var selected = _.filter(object, function (value) {
                return value;
            });

            return object[type] && (selected.length === 1);
        };

    }]
);
