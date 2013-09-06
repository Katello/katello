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
 * @name  Bastion.products.controller:ProductDetailsController
 *
 * @requires $scope
 * @requires $q
 * @requires Product
 * @requires GPGKey
 *
 * @description
 *   Provides the functionality for the product details action pane.
 */
angular.module('Bastion.products').controller('ProductDetailsInfoController',
    ['$scope', '$q', 'Product', 'GPGKey', function($scope, $q, Product, GPGKey) {

        $scope.gpgKeys = function() {
            var deferred = $q.defer()

            GPGKey.query({}, function(gpg_keys) {
                deferred.resolve(gpg_keys.results);
            });

            return deferred.promise;
        };

        $scope.save = function(product) {
            var deferred = $q.defer();

            product.$update(function(response) {
                deferred.resolve(response);
                $scope.saveSuccess = true;
            }, function(response) {
                deferred.reject(response);
                $scope.saveError = true;
                $scope.errors = response.data.errors;
            });

            return deferred.promise;
        };

    }]
);
