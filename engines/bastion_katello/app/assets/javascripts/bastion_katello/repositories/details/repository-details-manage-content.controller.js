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
 * @requires PackageGroup
 * @requires PuppetModule
 * @requires DockerManifest
 *
 * @description
 *   Provides the functionality for the repository details pane.
 */
angular.module('Bastion.repositories').controller('RepositoryManageContentController',
    ['$scope', '$state', 'translate', 'Nutupane', 'Repository', 'Package', 'PackageGroup', 'PuppetModule', 'DockerManifest',
    function ($scope, $state, translate, Nutupane, Repository, Package, PackageGroup, PuppetModule, DockerManifest) {
        var currentState, contentTypes;

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

        $scope.repository = Repository.get({id: $scope.$stateParams.repositoryId});

        currentState = $state.current.name.split('.').pop();

        contentTypes = {
            'packages': { type: Package },
            'package-groups': { type: PackageGroup },
            'puppet-modules': { type: PuppetModule },
            'docker-manifests': { type: DockerManifest }
        };

        $scope.contentNutupane = new Nutupane(contentTypes[currentState].type, {
            'repository_id': $scope.$stateParams.repositoryId
        });
        $scope.detailsTable = $scope.contentNutupane.table;
        $scope.detailsTable.closeItem = function () {};

        $scope.removeContent = function () {
            var selected = $scope.detailsTable.getSelected();
            $scope.detailsTable.working = true;
            Repository.removeContent({id: $scope.repository.id, uuids: _.pluck(selected, 'id')},
                function (response) {
                    success(response, selected);
                }, error);
        };

        $scope.taskUrl = function () {
            return $scope.$state.href('products.details.tasks.details', {productId: $scope.product.id,
                taskId: $scope.generationTaskId});
        };

        $scope.clearTaskId = function () {
            $scope.generationTaskId = undefined;
        };

    }]
);
