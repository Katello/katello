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
 * @name  Bastion.products.controller:ProducFormController
 *
 * @requires $scope
 * @requires $http
 * @requires Product
 * @requires Provider
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality specific to Products for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.products').controller('ProductFormController',
    ['$scope', '$http', '$q', 'Product', 'Provider', 'GPGKey', 'CurrentOrganization',
    function($scope, $http, $q, Product, Provider, GPGKey, CurrentOrganization) {

        $scope.product = $scope.product || new Product();

        $scope.$on('$stateChangeSuccess', function(event, toState) {
            if (toState.name === 'products.new.form') {
                $scope.providers = fetchProviders();
                $scope.gpgKeys = fetchGPGKeys();

                $q.all([$scope.gpgKeys, $scope.providers]).then(function() {
                    console.log($scope.gpgKeys);
                    $scope.panel.loading = false;
                });
            }
        });

        $scope.save = function(product) {
            product.$save(success, error);
        };

        $scope.$watch('product.name', function() {
            $http({
                method: 'GET',
                url: '/katello/organizations/default_label',
                params: {'name': $scope.product.name}
            })
            .success(function(response) {
                $scope.product.label = response;
            })
            .error(function(response) {
                $scope.productForm.label.$setValidity('', false);
                $scope.productForm.label.$error.messages = response.errors;
            });
        });

        function fetchProviders() {
            var deferred = $q.defer()

            Provider.query(function(providers) {
                deferred.resolve(providers.results);
            });

            return deferred.promise;
        }

        function fetchGPGKeys() {
            var deferred = $q.defer()

            GPGKey.query(function(gpgKeys) {
                deferred.resolve(gpgKeys.results);
            });

            return deferred.promise;
        }

        function success(response) {
            $scope.table.addRow(response);
            $scope.table.closeItem();
        }

        function error(response) {
            angular.forEach(response.data.errors, function(errors, field) {
                $scope.productForm[field].$setValidity('', false);
                $scope.productForm[field].$error.messages = errors;
            });
        }

    }]
);
