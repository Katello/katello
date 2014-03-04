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
 * @name  Bastion.content-views.controller:FiltersController
 *
 * @requires $scope
 * @requires gettext
 * @requires Filter
 * @requires Nutupane
 *
 * @description
 *   Handles loading all filters for a content view.
 */
angular.module('Bastion.content-views').controller('FiltersController',
    ['$scope', 'gettext', 'Filter', 'Nutupane', function ($scope, gettext, Filter, Nutupane) {
        var nutupane;

        nutupane = new Nutupane(Filter, {
            'content_view_id': $scope.$stateParams.contentViewId,
        });

        $scope.detailsTable = nutupane.table;

        $scope.$on('filter.created', function () {
            nutupane.refresh();
        });

        $scope.removeFilters = function () {
            var filterIds = nutupane.getAllSelectedResults().included.ids;

            angular.forEach(filterIds, removeFilter);
        };

        function removeFilter(id) {
            var success, failure;

            success = function () {
                nutupane.removeRow(id);
                $scope.successMessages = [gettext('Filters successfully removed.')];
            };

            failure = function (response) {
                $scope.errorMessages = [response.data.displayMessage];
            };

            Filter.delete({filterId: id}, success, failure);
        }

    }]
);
