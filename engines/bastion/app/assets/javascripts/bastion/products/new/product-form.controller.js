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
 * @name  Bastion.products.controller:ProducFormController
 *
 * @requires $scope
 * @requires $q
 * @requires Product
 * @requires Provider
 * @requires GPGKey
 * @requires SyncPlan
 * @requires FormUtils
 *
 * @description
 *   Provides the functionality specific to Products for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.products').controller('ProductFormController',
    ['$scope', '$q', 'Product', 'Provider', 'GPGKey', 'SyncPlan', 'FormUtils',
    function ($scope, $q, Product, Provider, GPGKey, SyncPlan, FormUtils) {

        function fetchProviders() {
            Provider.query(function (providers) {
                $scope.providers = providers.results;
            });
        }

        function fetchGpgKeys() {
            GPGKey.query(function (gpgKeys) {
                $scope.gpgKeys = gpgKeys.results;
            });
        }

        function fetchSyncPlans() {
            SyncPlan.query(function (syncPlans) {
                $scope.syncPlans = syncPlans.results;
            });
        }

        function populateSelects() {
            var deferred = $q.defer();

            $scope.$watch("providers && gpgKeys && syncPlans", function (value) {
                if (value !== undefined) {
                    deferred.resolve(true);
                }
            });

            fetchProviders();
            fetchGpgKeys();
            fetchSyncPlans();

            return deferred.promise;
        }

        function success(response) {
            $scope.productTable.addRow(response);
            $scope.transitionTo('products.details.repositories.index', {productId: $scope.product.id});
        }

        function error(response) {
            $scope.working = false;
            angular.forEach(response.data.errors, function (errors, field) {
                $scope.productForm[field].$setValidity('server', false);
                $scope.productForm[field].$error.messages = errors;
            });
        }

        $scope.product = $scope.product || new Product();

        $scope.$watch('product.name', function () {
            if ($scope.productForm.name) {
                $scope.productForm.name.$setValidity('server', true);
                FormUtils.labelize($scope.product, $scope.productForm);
            }
        });

        $scope.save = function (product) {
            product.$save(success, error);
        };

        populateSelects().then(function () {
            $scope.panel.loading = false;
        });
    }]
);
