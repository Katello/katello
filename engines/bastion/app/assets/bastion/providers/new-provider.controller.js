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
 * @name  Bastion.products.controller:NewProviderController
 *
 * @requires $scope
 * @requires Provider
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality specific to Products for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.providers').controller('NewProviderController',
    ['$scope', 'Provider', 'CurrentOrganization',
    function($scope, Provider, CurrentOrganization) {

        $scope.provider = new Provider({'organization_id': CurrentOrganization});

        $scope.save = function(provider) {
            provider.$save(success, error);
        };

        function success() {
            $scope.product['provider_id'] = $scope.provider.id;
            $scope.transitionTo('products.new.form');
        }

        function error(response) {
            angular.forEach(response.data.errors, function(errors, field) {
                $scope.providerForm[field].$setValidity('', false);
                $scope.providerForm[field].$error.messages = errors;
            });
        }

    }]
);
