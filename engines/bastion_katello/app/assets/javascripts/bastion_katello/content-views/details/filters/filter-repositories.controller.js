/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:FilterRepositoriesController
 *
 * @requires $scope
 * @requires translate
 * @requires Filter
 * @requires ContentViewRepositoriesUtl
 *
 * @description
 *   Provides a way for users to select which repositories the filter applies to.
 */
angular.module('Bastion.content-views').controller('FilterRepositoriesController',
    ['$scope', 'translate', 'Filter', 'ContentViewRepositoriesUtil',
    function ($scope, translate, Filter, ContentViewRepositoriesUtil) {
        var refreshTable, success, error;

        ContentViewRepositoriesUtil($scope);

        refreshTable = function (filter) {
            var displayedRepositories = filter['content_view'].repositories,
                filterRepositories = filter.repositories;

            $scope.$parent.filter = filter;

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
            $scope.successMessages = [translate('Affected repositories have been updated.')];
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
                $scope.errorMessages = [translate('You must select at least one repository.')];
            } else {
                Filter.update({id: $scope.filter.id, 'repository_ids': repositoryIds}, success, error);
            }
        };

        $scope.selectAllRepositories = function () {
            Filter.update({id: $scope.filter.id, 'repository_ids': []}, success, error);
        };
    }]
);
