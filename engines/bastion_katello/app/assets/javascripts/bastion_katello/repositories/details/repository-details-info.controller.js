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
 * @name  Bastion.repositories.controller:RepositoryDetailsInfoController
 *
 * @requires $scope
 * @requires $state
 * @requires $q
 * @requires translate
 * @requires Repository
 * @requires GPGKey
 *
 * @description
 *   Provides the functionality for the repository details pane.
 */
angular.module('Bastion.repositories').controller('RepositoryDetailsInfoController',
    ['$scope', '$state', '$q', 'translate', 'Repository', 'GPGKey', function ($scope, $state, $q, translate, Repository, GPGKey) {
        var updateRepositoriesTable;

        $scope.successMessages = [];
        $scope.errorMessages = [];
        $scope.uploadSuccessMessages = [];
        $scope.uploadErrorMessages = [];

        $scope.progress = {uploading: false};

        $scope.repository = Repository.get({
            'product_id': $scope.$stateParams.productId,
            'id': $scope.$stateParams.repositoryId
        });

        $scope.repository.$promise.then(function () {
            $scope.uploadURL = '/katello/api/v2/repositories/' + $scope.repository.id + '/upload_content';
        });

        $scope.gpgKeys = function () {
            var deferred = $q.defer();

            GPGKey.queryUnpaged(function (gpgKeys) {
                var results = gpgKeys.results;

                results.unshift({id: null});
                deferred.resolve(results);
            });

            return deferred.promise;
        };

        $scope.save = function (repository) {
            var deferred = $q.defer();

            repository.$update(function (response) {
                deferred.resolve(response);
                $scope.successMessages = [translate('Repository Saved.')];
                updateRepositoriesTable();
            }, function (response) {
                deferred.reject(response);
                _.each(response.data.errors, function (errorMessage) {
                    $scope.errorMessages.push(translate("An error occurred saving the Repository: ") + errorMessage);
                });
            });

            return deferred.promise;
        };

        $scope.uploadContent = function (content) {
            var returnData, error;

            if (content) {
                try {
                    returnData = JSON.parse(angular.element(content).html());
                } catch (err) {
                    returnData = content;
                }

                if (!returnData) {
                    returnData = content;
                }

                if (returnData !== null && returnData['status'] === 'success') {
                    $scope.uploadSuccessMessages = [translate('Content successfully uploaded')];
                    $scope.repository.$get();
                    updateRepositoriesTable();
                } else {
                    if (typeof(returnData) === "string" && returnData.indexOf("Request Entity Too Large")) {
                        error = translate('File too large. Please use the CLI instead.');
                    } else {
                        error = returnData.displayMessage;
                    }
                    $scope.uploadErrorMessages = [translate('Error during upload: ') + error];
                }

                $scope.progress.uploading = false;
            }
        };

        $scope.syncInProgress = function (task) {
            var inProgress = false;
            if (task && (task.state === 'pending' || task.state === 'running')) {
                inProgress = true;
            }
            return inProgress;
        };

        $scope.syncRepository = function (repository) {
            Repository.sync({id: repository.id}, function (task) {
                $state.go('products.details.tasks.details', {taskId: task.id});
            });
            updateRepositoriesTable();
        };

        $scope.getRepoNonDeletableReason = function (repo, product) {
            var readOnlyReason = null;

            if (repo.$resolved && product.$resolved) {
                if ($scope.denied('delete_products', product)) {
                    readOnlyReason = 'permissions';
                } else if (repo.promoted) {
                    readOnlyReason = 'published';
                } else if (repo['product_type'] === "redhat") {
                    readOnlyReason = 'redhat';
                }
            }

            return readOnlyReason;
        };

        $scope.canRemove = function (repo, product) {
            return $scope.getRepoNonDeletableReason(repo, product) === null;
        };

        $scope.removeRepository = function (repository) {
            var success, error, repositoryName = repository.name;

            success = function () {
                $scope.transitionTo('products.details.repositories.index', {productId: $scope.$stateParams.productId});
                $scope.$parent.successMessages = [translate('Repository "%s" successfully deleted').replace('%s', repositoryName)];
            };

            error = function error(response) {
                $scope.errorMessages = response.data.errors;
            };

            $scope.repositoriesTable.removeRow(repository.id);
            repository.$delete(success, error);
        };

        $scope.checksumTypeDisplay = function (checksum) {
            if (checksum === null) {
                checksum = translate('Default');
            }
            return checksum;
        };

        updateRepositoriesTable = function () {
            $scope.repositoriesTable.replaceRow($scope.repository);
        };
    }]
);
