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
 * @name  Bastion.repositories.controller:RepositoryManagePackagesController
 *
 * @requires $scope
 * @requires Nutupane
 * @requires translate
 * @requires Package
 * @requires Repository
 *
 * @description
 *   Provides the functionality for the repository details pane.
 */
angular.module('Bastion.repositories').controller('RepositoryManagePackagesController',
    ['$scope', 'Nutupane', 'translate', 'Package', 'Repository',
    function ($scope, Nutupane, translate, Package, Repository) {
        $scope.repository = Repository.get({id: $scope.$stateParams.repositoryId});
        $scope.packagesNutupane = new Nutupane(Package, {
            'repository_id': $scope.$stateParams.repositoryId
        });

        $scope.detailsTable = $scope.packagesNutupane.table;
        $scope.detailsTable.closeItem = function () {};

        $scope.removePackages = function () {
            var selected = $scope.detailsTable.getSelected();
            $scope.detailsTable.working = true;
            Repository.removePackages({id: $scope.repository.id, uuids : _.pluck(selected, 'id')},
                function (response) {
                    success(response, selected);
                }, error);
        };

        $scope.taskUrl = function () {
            return $scope.$state.href('products.details.tasks.details', {productId: $scope.product.id,
                taskId: $scope.generationTaskId});
        };

        function success(response, selected) {
            var message;

            $scope.packagesNutupane.refresh();
            $scope.detailsTable.working = false;

            if (selected.length === 1) {
                message = translate("Successfully removed 1 package.");
            } else {
                message = translate("Successfully removed %s package.").replace('%s', selected.length);
            }
            $scope.successMessages = [message];
            $scope.generationTaskId = response.output['task_id'];
        }

        function error(data) {
            $scope.detailsTable.working = false;
            $scope.errorMessages = [data.response.displayMessage];
        }

    }]
);
