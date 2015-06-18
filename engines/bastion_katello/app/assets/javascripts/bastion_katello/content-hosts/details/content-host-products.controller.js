/**
 * Copyright 2013-2014 Red Hat, Inc.
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
 * @name  Bastion.content-hosts.controller:ContentHostProductsController
 *
 * @requires $scope
 * @requires translate
 * @requires ContentHost
 * @requires Product
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality for the content-host products action pane.
 */
angular.module('Bastion.content-hosts').controller('ContentHostProductsController',
    ['$scope', 'translate', 'ContentHost', 'Product', 'CurrentOrganization',
    function ($scope, translate, ContentHost, Product, CurrentOrganization) {

        $scope.successMessages = [];
        $scope.errorMessages = [];
        $scope.displayArea = { working: true, isAvailableContent: false };

        $scope.isAnyAvailableContent = function (products) {
            var isAvailableContent = false;
            angular.forEach(products, function (product) {
                if (product['available_content'].length > 0) {
                    isAvailableContent = true;
                }
            });
            return isAvailableContent;
        };

        $scope.contentHost.$promise.then(function () {
            ContentHost.products({id: $scope.contentHost.uuid,
                                  'organization_id': CurrentOrganization,
                                  enabled: true,
                                  'full_result': true,
                                  'include_available_content': true
                                 }, function (response) {
                $scope.products = response.results;
                $scope.displayArea.isAvailableContent = $scope.isAnyAvailableContent($scope.products);
                $scope.displayArea.working = false;
            });
        });

    }]
);
