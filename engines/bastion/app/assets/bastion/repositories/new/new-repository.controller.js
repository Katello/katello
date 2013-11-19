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
 * @name  Bastion.repositories.controller:NewRepositoryController
 *
 * @requires $scope
 * @requires Repository
 * @requires GPGKey
 * @requires FormUtils
 *
 * @description
 *   Controls the creation of an empty Repository object for use by sub-controllers.
 */
angular.module('Bastion.repositories').controller('NewRepositoryController',
    ['$scope', 'Repository', 'GPGKey', 'FormUtils',
    function($scope, Repository, GPGKey, FormUtils) {

        $scope.repository = new Repository({'product_id': $scope.$stateParams.productId});
        $scope.repositoryTypes = [{name: 'yum'}, {name: 'puppet'}];

        $scope.$watch('repository.name', function() {
            $scope.repositoryForm.name.$setValidity('server', true);
            FormUtils.labelize($scope.repository, $scope.repositoryForm);
        });

        GPGKey.query(function(gpgKeys) {
            $scope.gpgKeys = gpgKeys.results;
        });

        $scope.save = function(repository) {
            repository.$save(success, error);
        };

        function success(response) {
            $scope.repositories.push(response);
            $scope.transitionTo('products.details.repositories.index', {productId: $scope.$stateParams.productId});
        }

        function error(response) {
            $scope.working = false;

            angular.forEach(response.data.errors, function(errors, field) {
                $scope.repositoryForm[field].$setValidity('server', false);
                $scope.repositoryForm[field].$error.messages = errors;
            });
        }

    }]
);
