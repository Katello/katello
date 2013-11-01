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
 * @requires gettext
 * @requires Repository
 * @requires GPGKey
 *
 * @description
 *   Provides the functionality for the repository details pane.
 */
angular.module('Bastion.repositories').controller('RepositoryDetailsInfoController',
    ['$scope', '$q', 'gettext', 'Repository', 'GPGKey', function ($scope, $q, gettext, Repository, GPGKey) {

        $scope.successMessages = [];
        $scope.errorMessages = [];
        $scope.uploadSuccessMessages = [];
        $scope.uploadErrorMessages = [];

        $scope.progress = {uploading: false};

        $scope.repository = Repository.get({
            'product_id': $scope.$stateParams.productId,
            'id': $scope.$stateParams.repositoryId
        });

        $scope.gpgKeys = function () {
            var deferred = $q.defer();

            GPGKey.query(function (gpgKeys) {
                var results = gpgKeys.results;

                results.unshift({id: null});
                deferred.resolve(results);
            });

            return deferred.promise;
        };

        $scope.triggerSync = function(repository) {
           Repository.sync({ id: repository.id });
        };

        $scope.save = function (repository) {
            var deferred = $q.defer();

            repository.$update(function (response) {
                deferred.resolve(response);
                $scope.successMessages.push(gettext('Repository Saved.'));
            }, function (response) {
                deferred.reject(response);
                _.each(response.data.errors, function (errorMessage) {
                    $scope.errorMessages.push(gettext("An error occurred saving the Repository: ") + errorMessage);
                });
            });

            return deferred.promise;
        };

        $scope.removeRepository = function (repository) {
            repository.$delete(function () {
                $scope.transitionTo('products.details.repositories.index', {productId: $scope.$stateParams.productId});
            });
        };

        $scope.uploadContent = function (content) {
            var returnData;

            if (content !== "Please wait...") {
                try {
                    returnData = JSON.parse(angular.element(content).html());
                } catch (err) {
                    returnData = content;
                }

                if (!returnData) {
                    returnData = content;
                }

                if (returnData !== null && returnData['status'] === 'success') {
                    $scope.uploadSuccessMessages = [gettext('Puppet module successfully uploaded')];
                    $scope.repository.$get();
                } else {
                    $scope.uploadErrorMessages = [gettext('Error during upload: ') + returnData.displayMessage];
                }

                $scope.progress.uploading = false;
            }
        };

        $scope.syncInProgress = function (state) {
            return (state === 'running' || state === 'waiting');
        };

        $scope.syncRepository = function (repository) {
            Repository.sync({id: repository.id}, function (task) {
                repository['sync_state'] = task.state;
            });
        };

    }]
);
