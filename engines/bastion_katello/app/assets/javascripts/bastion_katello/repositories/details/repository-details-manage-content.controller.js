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
 * @name  Bastion.repositories.controller:RepositoryManageContentController
 *
 * @requires $scope
 * @requries $state
 * @requires translate
 * @requires Nutupane
 * @requires Repository
 * @requires Package
 * @requires PuppetModule
 * @requires DockerImage
 *
 * @description
 *   Provides the functionality for the repository details pane.
 */
angular.module('Bastion.repositories').controller('RepositoryManageContentController',
    ['$scope', '$state', 'translate', 'Nutupane', 'Repository', 'Package', 'PuppetModule', 'DockerImage',
    function ($scope, $state, translate, Nutupane, Repository, Package, PuppetModule, DockerImage) {
        var currentState, contentTypes;

        $scope.repository = Repository.get({id: $scope.$stateParams.repositoryId});

        currentState = $state.current.name.split('.').pop();

        contentTypes = {
            'packages': { type: Package },
            'puppet-modules': { type: PuppetModule },
            'docker-images': { type: DockerImage }
        };

        $scope.contentNutupane = new Nutupane(contentTypes[currentState].type, {
            'repository_id': $scope.$stateParams.repositoryId
        });
        $scope.detailsTable = $scope.contentNutupane.table;
        $scope.detailsTable.closeItem = function () {};

        $scope.removeContent = function () {
            var selected = $scope.detailsTable.getSelected();
            $scope.detailsTable.working = true;
            Repository.removeContent({id: $scope.repository.id, uuids : _.pluck(selected, 'id')},
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

            $scope.contentNutupane.refresh();
            $scope.detailsTable.working = true;

            if (selected.length === 1) {
                message = translate("Successfully removed 1 item.");
            } else {
                message = translate("Successfully removed %s items.").replace('%s', selected.length);
            }
            $scope.successMessages = [message];
            $scope.generationTaskId = response.output['task_id'];
        }

        function error(data) {
            $scope.detailsTable.working = true;
            $scope.errorMessages = [data.response.displayMessage];
        }

        $scope.clearTaskId = function () {
            $scope.generationTaskId = undefined;
        };

        $scope.formatRepoDockerTags =  function (image, repoId) {
            var tags = '';

            if (!_.isEmpty(image.tags)) {
                tags = _.filter(image.tags, function (tag) {
                    return tag["repository_id"] === repoId;
                });

                tags = _.pluck(tags, 'name').join(', ');
            }

            return tags;
        };

    }]
);
