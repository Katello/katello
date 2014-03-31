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
 * @name  Bastion.content-views.controller:NewFilterController
 *
 * @requires $scope
 * @requires Filter
 * @requires Rule
 *
 * @description
 */
angular.module('Bastion.content-views').controller('NewFilterController',
    ['$scope', 'Filter', 'Rule', function ($scope, Filter, Rule) {
        var filterType;

        $scope.filter = new Filter();
        $scope.working = false;

        $scope.save = function (filter, contentView) {
            filterType = filter.type;

            if (filter.type === 'erratumId' || filter.type === 'erratumDateType') {
                filter.type = 'erratum';
            }

            filter.$save({'content_view_id': contentView.id}, success, failure);
        };

        function success(filter) {
            if (filterType === 'erratumDateType') {
                addErrataDateTypeRule(filter);
            } else {
                transitionToDetails(filter);
            }
        }

        function failure(response) {
            $scope.working = false;
            angular.forEach(response.data.errors, function (errors, field) {
                $scope.filterForm[field].$setValidity('server', false);
                $scope.filterForm[field].$error.messages = errors;
            });
        }

        function transitionToDetails(filter) {
            var state = '';

            if (filterType === 'erratumId') {
                state = 'content-views.details.filters.details.erratum.available';
            } else if (filterType === 'erratumDateType') {
                state = 'content-views.details.filters.details.erratum.dateType';
            } else if (filterType === 'rpm') {
                state = 'content-views.details.filters.details.rpm.details';
            } else if (filterType === 'package_group') {
                state = 'content-views.details.filters.details.package_group.available';
            }

            $scope.$emit('filter.created');
            $scope.transitionTo(state, {filterId: filter.id, contentViewId: filter['content_view'].id});
        }

        function addErrataDateTypeRule(filter) {
            var rule = new Rule({
                    types: ['security', 'enhancement', 'bugfix']
                }),
                success, failure;

            success = function () {
                transitionToDetails(filter);
            };

            failure = function (response) {
                $scope.errorMessages = [response.data.displayMessage];
            };

            rule.$save({filterId: filter.id}, success, failure);
        }

    }]
);
