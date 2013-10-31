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
 * @name  Bastion.repositories.controller:RepositoryDetailsInfoController
 *
 * @requires $scope
 * @requires $q
 * @requires Repository
 * @requires GPGKey
 *
 * @description
 *   Provides the functionality for the repository details pane.
 */
angular.module('Bastion.repositories').controller('RepositoryDetailsInfoController',
    ['$scope', '$q', 'Repository', 'GPGKey', function($scope, $q, Repository, GPGKey) {

        $scope.saveSuccess = false;
        $scope.saveError = false;

        $scope.repository = Repository.get({
            'product_id': $scope.$stateParams.productId,
            'id': $scope.$stateParams.repositoryId
        });

        $scope.gpgKeys = function() {
            var deferred = $q.defer();

            GPGKey.query(function(gpgKeys) {
                var results = gpgKeys.results;

                results.unshift({id: null});
                deferred.resolve(results);
            });

            return deferred.promise;
        };

        $scope.triggerSync = function(repository) {
           repository.$sync();
        };

        $scope.save = function(repository) {
            var deferred = $q.defer();

            repository.$update(function(response) {
                deferred.resolve(response);
                $scope.saveSuccess = true;
            }, function(response) {
                deferred.reject(response);
                $scope.saveError = true;
                $scope.errors = response.data.errors;
            });

            return deferred.promise;
        };

        $scope.removeRepository = function(repository) {
            repository.$delete(function() {
                $scope.transitionTo('products.details.repositories.index', {productId: $scope.$stateParams.productId});
            });
        };

        $scope.uploadContent = function(content, completed) {
            var returnData;

            if (content !== "Please wait...") {
                try {
                    returnData = JSON.parse(angular.element(content).html());
                } catch(err) {
                    returnData = content;
                }

                if (!returnData) {
                    returnData = content;
                }

                if (completed && returnData !== null && returnData['status'] === 'success') {
                    $scope.uploadStatus = 'success';
                    $scope.repository.$get();
                } else {
                    $scope.errorMessage = returnData;
                    $scope.uploadStatus = 'error';
                }

                $scope.uploading = false;
            }
        };

        $scope.syncInProgress = function(state) {
            return (state === 'running' || state === 'waiting');
        };

        $scope.syncRepository = function(repository) {
            Repository.sync({id: repository.id}, function(task) {
                repository['sync_state'] = task.state;
            });
        };

    }]
);
