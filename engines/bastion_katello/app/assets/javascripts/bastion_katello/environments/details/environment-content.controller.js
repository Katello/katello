(function () {
    'use strict';

    /**
     * @ngdoc controller
     * @name  Bastion.environments.controller:EnvironmentContent
     *
     * @description
     *   Controls displaying content tables for a given environment along with appropriate filtering.
     */
    function EnvironmentContentController($scope, ContentService, ContentView, Repository, translate, $location) {
        var nutupane, allRepositories, nutupaneParams;

        function fetchContentViews(environmentId) {
            ContentView.queryUnpaged({'environment_id': environmentId}, function (data) {
                $scope.contentViews = [$scope.contentView].concat(data.results);
            });
        }

        function fetchRepositories(contentView) {
            var promise, params = {
                'environment_id': $scope.$stateParams.environmentId,
                'content_type': ContentService.getRepositoryType(),
                library: true
            };

            if (contentView && contentView.id !== 'all') {
                params['content_view_id'] = contentView.id;
            }

            promise = Repository.queryUnpaged(params).$promise;

            promise.then(function (data) {
                var repository;

                $scope.repositories = [allRepositories].concat(data.results);

                if ($location.search().repositoryId) {
                    repository = _.find($scope.repositories, function (repo) {
                        return repo.id.toString() === $location.search().repositoryId.toString();
                    });
                }

                if (repository === null) {
                    $location.search('repositoryId', null);
                }

                $scope.repository = repository || allRepositories;
            });

            return promise;
        }

        function getVersionId(contentView, environmentId) {
            var versionId, version;

            if (contentView.id !== 'all') {
                version = _.find(contentView.versions, function (vers) {
                    return vers['environment_ids'].indexOf(parseInt(environmentId, 10)) > -1;
                });
                versionId = version.id;
            }

            return versionId;
        }

        nutupaneParams = {'environment_id': $scope.$stateParams.environmentId, library: true};
        if ($location.search().repositoryId) {
            nutupaneParams['repository_id'] = $location.search().repositoryId;
        }

        nutupane = ContentService.buildNutupane(nutupaneParams);
        nutupane.masterOnly = true;

        $scope.nutupane = nutupane;
        $scope.detailsTable = nutupane.table;

        $scope.contentView = {id: 'all', name: translate('All Content Views')};

        allRepositories = {id: 'all', name: translate('All Repositories')};
        $scope.repository = allRepositories;

        fetchContentViews($scope.$stateParams.environmentId);

        if (ContentService.getRepositoryType()) {
            fetchRepositories();
        }

        $scope.contentViewSelected = function (contentView) {
            var params = nutupane.getParams();

            fetchRepositories(contentView).then(function (response) {
                var repo;

                params['content_view_version_id'] = getVersionId(contentView, $scope.$stateParams.environmentId);

                if (params['repository_id']) {
                    repo = _.find(response.results, function (repository) {
                        return repository.id.toString() === params['repository_id'].toString();
                    });
                }

                if (!repo) {
                    params['repository_id'] = null;
                }

                nutupane.setParams(params);
                nutupane.refresh();
            });
        };

        $scope.repositorySelected = function (repository) {
            var params = nutupane.getParams();

            if (repository.id === 'all') {
                $location.search('repositoryId', null);
            } else {
                $location.search('repositoryId', repository.id);
            }

            params['repository_id'] = $location.search().repositoryId;
            nutupane.setParams(params);
            nutupane.refresh();
        };
    }

    angular
        .module('Bastion.environments')
        .controller('EnvironmentContentController', EnvironmentContentController);

    EnvironmentContentController.$inject = ['$scope', 'ContentService', 'ContentView', 'Repository', 'translate', '$location'];

})();
