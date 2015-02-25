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
 **/

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
        var nutupane, allRepositories, params;

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
                    repository = _.find($scope.repositories, function (repository) {
                        return repository.id.toString() === $location.search().repositoryId.toString();
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
                version = _.find(contentView.versions, function (version) {
                    return version['environment_ids'].indexOf(parseInt(environmentId, 10)) > -1;
                });
                versionId = version.id;
            }

            return versionId;
        }

        params = {'environment_id': $scope.$stateParams.environmentId, library: true};
        if ($location.search().repositoryId) {
            params['repository_id'] = $location.search().repositoryId;
        }

        nutupane = ContentService.buildNutupane(params);
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
