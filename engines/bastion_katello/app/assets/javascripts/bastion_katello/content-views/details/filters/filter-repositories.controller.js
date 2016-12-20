/**
 * @ngdoc object
 * @name  Bastion.content-views.controller:FilterRepositoriesController
 *
 * @requires $scope
 * @requires translate
 * @requires Filter
 * @requires ContentViewRepositoriesUtl
 * @requires GlobalNotification
 *
 * @description
 *   Provides a way for users to select which repositories the filter applies to.
 */
angular.module('Bastion.content-views').controller('FilterRepositoriesController',
    ['$scope', 'translate', 'Filter', 'ContentViewRepositoriesUtil', 'GlobalNotification',
    function ($scope, translate, Filter, ContentViewRepositoriesUtil, GlobalNotification) {
        var refreshTable, success, error;

        ContentViewRepositoriesUtil($scope);

        refreshTable = function (filter) {
            var displayedRepositories = filter['content_view'].repositories,
                repositoryType,
                filterRepositories = filter.repositories;

            if ($scope.stateIncludes('content-view.yum')) {
                repositoryType = 'yum';
            } else {
                repositoryType = 'docker';
            }
            $scope.repositoryType = repositoryType;
            displayedRepositories = _.filter(displayedRepositories, ["content_type", repositoryType]);

            $scope.$parent.filter = filter;

            if (filterRepositories.length === 0) {
                displayedRepositories = _.map(displayedRepositories, function (repository) {
                    repository.selected = true;
                    return repository;
                });
            } else {
                displayedRepositories = _.map(displayedRepositories, function (repository) {
                    repository.selected = _.map(filterRepositories, 'id').indexOf(repository.id) >= 0;
                    return repository;
                });
            }

            $scope.table.rows = displayedRepositories;
            $scope.showRepos = filterRepositories.length !== 0;
        };

        success = function (filter) {
            refreshTable(filter);
            GlobalNotification.setSuccessMessage(translate('Affected repositories have been updated.'));
        };

        error = function (response) {
            angular.forEach(response.errors, function (responseError) {
                GlobalNotification.setErrorMessage(responseError);
            });
        };

        $scope.showRepos = false;
        $scope.table = {};

        $scope.filter.$promise.then(refreshTable);

        $scope.updateRepositories = function () {
            var repositoryIds = _.map($scope.table.getSelected(), 'id');

            if (repositoryIds.length === 0) {
                GlobalNotification.setErrorMessage(translate('You must select at least one repository.'));
            } else {
                Filter.update({id: $scope.filter.id, 'repository_ids': repositoryIds}, success, error);
            }
        };

        $scope.selectAllRepositories = function () {
            Filter.update({id: $scope.filter.id, 'repository_ids': []}, success, error);
        };
    }]
);
