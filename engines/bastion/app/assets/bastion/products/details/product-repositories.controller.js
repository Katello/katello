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
 * @name  Bastion.products.controller:ProductRepositoriesController
 *
 * @requires $scope
 * @requires Repository
 * @requires $stateParams
 * @requires CurrentOrganization
 *
 *
 * @description
 *   Provides the functionality for manipulating repositories attached to a product.
 */
angular.module('Bastion.products').controller('ProductRepositoriesController',
    ['$scope', 'Repository', '$stateParams', 'CurrentOrganization',
    function($scope, Repository, $stateParams, CurrentOrganization) {

        if ($stateParams.productId && !$stateParams.repositoryId) {
            $scope.repositories = Repository.query({
                'product_id': $stateParams.productId,
                'library': true,
                'organization_id': CurrentOrganization,
                'enabled': true
            });
        }

        $scope.showRepository = function(repository) {
            $scope.transitionTo('products.details.repositories.info', {productId: $stateParams.productId, repositoryId: repository.id});
        };

        $scope.openCreateRepository = function(product) {
            $scope.transitionTo('products.details.repositories.new', {productId: product.id});
        };

    }]
);
