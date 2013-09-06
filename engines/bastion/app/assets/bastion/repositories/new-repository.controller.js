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
 * @name  Bastion.repositorys.controller:NewProductController
 *
 * @requires $scope
 * @requires $http
 * @requires Repository
 * @requires GPGKey
 *
 * @description
 *   Controls the creation of an empty Repository object for use by sub-controllers.
 */
angular.module('Bastion.repositories').controller('NewRepositoryController',
    ['$scope', '$http', 'Repository', 'GPGKey',
    function($scope, $http, Repository, GPGKey) {

        $scope.repository = new Repository({'product_id': $scope.$stateParams.productId});

        $scope.repositoryTypes = [{name: 'yum'}, {name: 'puppet'}];

        GPGKey.query({}, function(gpg_keys) {
            $scope.gpg_keys = gpg_keys.results;
        });

        $scope.save = function(repository) {
            resetForm();
            repository.$save(success, error);
        };

        $scope.$watch('repository.name', function() {
            $http({
                method: 'GET',
                url: '/katello/organizations/default_label',
                params: {'name': $scope.repository.name}
            })
            .success(function(response) {
                $scope.repository.label = response;
            });
        });

        function resetForm() {
            angular.forEach($scope.repository, function(value, key) {
                if ($scope.repositoryForm.hasOwnProperty(key)) {
                    $scope.repositoryForm[key].$setValidity('', true);
                }
            });
        }

        function success(response) {
            $scope.table.addRow(response);
            $scope.transitionTo('products.details.repositories.index', {productId: $scope.$stateParams.productId});
        }

        function error(response) {
            $scope.repositoryForm.$setDirty();

            angular.forEach(response.data.errors, function(errors, field) {
                $scope.repositoryForm[field].$setValidity('', false);
                $scope.repositoryForm[field].$error.messages = errors;
            });
        }

    }]
);
