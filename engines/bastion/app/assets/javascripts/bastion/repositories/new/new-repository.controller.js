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
 * @name  Bastion.repositories.controller:NewRepositoryController
 *
 * @requires $scope
 * @requires Repository
 * @requires GPGKey
 * @requires FormUtils
 * @requires translate
 *
 * @description
 *   Controls the creation of an empty Repository object for use by sub-controllers.
 */
angular.module('Bastion.repositories').controller('NewRepositoryController',
    ['$scope', 'Repository', 'GPGKey', 'FormUtils', 'translate',
    function ($scope, Repository, GPGKey, FormUtils, translate) {

        $scope.repository = new Repository({'product_id': $scope.$stateParams.productId, unprotected: true,
            'checksum_type': null});
        $scope.repositoryTypes = [{}, {name: 'yum'}, {name: 'puppet'}];

        $scope.$watch('repository.name', function () {
            if ($scope.repositoryForm.name) {
                $scope.repositoryForm.name.$setValidity('server', true);
                FormUtils.labelize($scope.repository);
            }
        });

        GPGKey.queryUnpaged(function (gpgKeys) {
            $scope.gpgKeys = gpgKeys.results;
        });

        $scope.save = function (repository) {
            repository.$save(success, error);
        };

        function success(response) {
            $scope.repositoriesTable.rows.push(response);
            $scope.successMessages.push(translate('Repository %s successfully created.').replace('%s', $scope.repository.name));
            $scope.transitionTo('products.details.repositories.index', {productId: $scope.$stateParams.productId});
        }

        function error(response) {
            var foundError = false;
            $scope.working = false;

            angular.forEach($scope.repositoryForm, function (value, field) {
                if ($scope.repositoryForm.hasOwnProperty(field) && value.hasOwnProperty('$setValidity')) {
                    value.$setValidity('server', true);
                    $scope.repositoryForm[field].$error.messages = [];
                }
            });

            angular.forEach(response.data.errors, function (errors, field) {
                if ($scope.repositoryForm.hasOwnProperty(field)) {
                    foundError = true;
                    $scope.repositoryForm[field].$setValidity('server', false);
                    $scope.repositoryForm[field].$error.messages = errors;
                }
            });

            if (!foundError) {
                $scope.errorMessages = [response.data.displayMessage];
            }
        }

    }]
);
