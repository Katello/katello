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
 * @name  Bastion.content-views.controller:FilterRepositoriesController
 *
 * @requires $scope
 * @requires gettext
 * @requires Filter
 * @requires ContentViewRepositoriesUtl
 *
 * @description
 *   Provides a way for users to select which repositories the filter applies to.
 */
angular.module('Bastion.content-views').controller('FilterRepositoriesController',
    ['$scope', 'gettext', 'Filter', 'ContentViewRepositoriesUtil',
    function ($scope, gettext, Filter, ContentViewRepositoriesUtil) {
        var refreshTable, success, error;

        ContentViewRepositoriesUtil($scope);

        refreshTable = function (filter) {
            $scope.$parent.filter = filter;

            var displayedRepositories = filter['content_view'].repositories,
                filterRepositories = filter.repositories;

            if (filterRepositories.length === 0) {
                displayedRepositories = _.map(displayedRepositories, function (repository) {
                    repository.selected = true;
                    return repository;
                });
            } else {
                displayedRepositories = _.map(displayedRepositories, function (repository) {
                    repository.selected = _.pluck(filterRepositories, 'id').indexOf(repository.id) >= 0;
                    return repository;
                });
            }

            $scope.repositoriesTable.rows = displayedRepositories;
            $scope.showRepos = filterRepositories.length !== 0;
        };

        success = function (filter) {
            refreshTable(filter);
            $scope.successMessages = [gettext('Affected repositories have been updated.')];
        };

        error = function (response) {
            $scope.errorMessages = response.data.errors;
        };

        $scope.successMessages = [];
        $scope.errorMessages = [];
        $scope.showRepos = false;
        $scope.repositoriesTable = {};

        $scope.filter.$promise.then(refreshTable);

        $scope.updateRepositories = function () {
            var repositoryIds = _.pluck($scope.repositoriesTable.getSelected(), 'id');

            if (repositoryIds.length === 0) {
                $scope.errorMessages = [gettext('You must select at least one repository.')];
            } else {
                Filter.update({id: $scope.filter.id, 'repository_ids': repositoryIds}, success, error);
            }
        };

        $scope.selectAllRepositories = function () {
            Filter.update({id: $scope.filter.id, 'repository_ids': []}, success, error);
        };
    }]
);
