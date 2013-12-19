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
 * @name  Bastion.products.controller:ProductDetailsInfoController
 *
 * @requires $scope
 * @requires $q
 * @requires gettext
 * @requires Product
 * @requires GPGKey
 * @requires MenuExpander
 *
 * @description
 *   Provides the functionality for the product details action pane.
 */
angular.module('Bastion.products').controller('ProductDetailsInfoController',
    ['$scope', '$q', 'gettext', 'Product', 'GPGKey', 'MenuExpander', function ($scope, $q, gettext, Product, GPGKey, MenuExpander) {

        $scope.successMessages = [];
        $scope.errorMessages = [];

        $scope.menuExpander = MenuExpander;
        $scope.panel = $scope.panel || {loading: false};

        $scope.product = $scope.product || Product.get({id: $scope.$stateParams.productId}, function () {
            $scope.panel.loading = false;
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

        $scope.save = function (product) {
            var deferred = $q.defer();

            product.$update(function (response) {
                deferred.resolve(response);
                $scope.successMessages.push(gettext('Product Saved'));
            }, function (response) {
                deferred.reject(response);
                _.each(response.data.errors, function (errorMessage) {
                    $scope.errorMessages.push(gettext("An error occurred saving the Product: ") + errorMessage);
                });
            });

            return deferred.promise;
        };

    }]
);
