/**
 * @ngdoc object
 * @name  Bastion.repositories.controller:RepositoryManageContentController
 *
 * @requires $scope
 * @requries $state
 * @requires translate
 * @requires Notification
 * @requires Nutupane
 * @requires Repository
 * @requires Package
 * @requires PackageGroup
 * @requires PuppetModule
 * @requires DockerManifest
 * @requires DockerManifestList
 * @requires DockerTag
 * @requires OstreeBranch
 * @requires File
 * @requires Deb
 * @requires ModuleStream
 * @requires AnsibleCollection
 *
 * @description
 *   Provides the functionality for the repository details pane.
 */
angular.module('Bastion.repositories').controller('RepositoryManageContentController',
    ['$scope', '$state', 'translate', 'Notification', 'Nutupane', 'Repository', 'Package', 'PackageGroup', 'PuppetModule', 'DockerManifest', 'DockerManifestList', 'DockerTag', 'OstreeBranch', 'File', 'Deb', 'ModuleStream', 'AnsibleCollection',
    function ($scope, $state, translate, Notification, Nutupane, Repository, Package, PackageGroup, PuppetModule, DockerManifest, DockerManifestList, DockerTag, OstreeBranch, File, Deb, ModuleStream, AnsibleCollection) {
        var contentTypes;

        function success(response, selected) {
            var message;

            $scope.contentNutupane.refresh();
            $scope.table.working = true;

            if (selected.length === 1) {
                message = translate("Successfully removed 1 item.");
            } else {
                message = translate("Successfully removed %s items.").replace('%s', selected.length);
            }
            Notification.setSuccessMessage(message);
            $scope.generationTaskId = response.output['task_id'];
        }

        function error(data) {
            $scope.table.working = true;
            Notification.setErrorMessage(data.response.displayMessage);
        }

        $scope.repository = Repository.get({id: $scope.$stateParams.repositoryId}, function (repository) {
            $scope.product = repository.product;
        });

        $scope.currentState = $state.current.name.split('.').pop();

        contentTypes = {
            'packages': { type: Package, controllerName: 'katello_rpms' },
            'package-groups': { type: PackageGroup, controllerName: 'katello_package_groups' },
            'puppet-modules': { type: PuppetModule, controllerName: 'katello_puppet_modules' },
            'docker-manifests': { type: DockerManifest, controllerName: 'katello_docker_manifests' },
            'docker-manifest-lists': { type: DockerManifestList, controllerName: 'katello_docker_manifest_lists' },
            'docker-tags': {type: DockerTag, controllerName: 'katello_docker_tags'},
            'ostree-branches': { type: OstreeBranch, controllerName: 'katello_ostree_branches' },
            'files': { type: File, controllerName: 'katello_files' },
            'debs': { type: Deb, controllerName: 'katello_debs' },
            'module-streams': { type: ModuleStream, controllerName: 'katello_module_streams' },
            'ansible-collections': { type: AnsibleCollection, controllerName: 'katello_ansible_collections'}
        };

        $scope.contentNutupane = new Nutupane(contentTypes[$scope.currentState].type, {
            'repository_id': $scope.$stateParams.repositoryId
        });
        $scope.table = $scope.contentNutupane.table;
        $scope.contentNutupane.masterOnly = true;

        $scope.controllerName = contentTypes[$scope.currentState].controllerName;

        $scope.removeContent = function () {
            var selected = $scope.table.getSelected();
            $scope.table.working = true;
            Repository.removeContent({id: $scope.repository.id, ids: _.map(selected, 'id')},
                function (response) {
                    success(response, selected);
                }, error);
        };

        $scope.taskUrl = function () {
            return $scope.$state.href('product.tasks.details', {productId: $scope.product.id,
                taskId: $scope.generationTaskId});
        };

        $scope.clearTaskId = function () {
            $scope.generationTaskId = undefined;
        };

        $scope.tagsForManifest = function(manifest) {
            return _.filter(manifest.tags, function(tag) {
                return tag.repository_id + '' === $scope.$stateParams.repositoryId;
            });
        };

        $scope.updateSelectable = function(item) {
            if ($scope.currentState === "docker-manifests" && !_.isEmpty(item.manifest_lists)) {
                item.unselectable = true;
            }
            return item;
        };
        $scope.availableSchemaVersions = function (tag) {
            var versions = [];
            if (tag.manifest_schema1) {
                versions.push(1);
            }

            if (tag.manifest_schema2) {
                versions.push(2);
            }
            return versions.join(", ");
        };
    }]
);
