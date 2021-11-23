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
 * @requires DockerManifest
 * @requires DockerManifestList
 * @requires DockerTag
 * @requires File
 * @requires Deb
 * @requires ModuleStream
 * @requires AnsibleCollection
 * @requires GenericContent
 * @requires RepositoryTypesService
 *
 * @description
 *   Provides the functionality for the repository details pane.
 */
angular.module('Bastion.repositories').controller('RepositoryManageContentController',
    ['$scope', '$state', 'translate', 'Notification', 'Nutupane', 'Repository', 'Package', 'PackageGroup', 'DockerManifest', 'DockerManifestList', 'DockerTag', 'File', 'Deb', 'ModuleStream', 'AnsibleCollection', 'GenericContent', 'RepositoryTypesService',
    function ($scope, $state, translate, Notification, Nutupane, Repository, Package, PackageGroup, DockerManifest, DockerManifestList, DockerTag, File, Deb, ModuleStream, AnsibleCollection, GenericContent, RepositoryTypesService) {
        var contentTypes, nutupaneParams;

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

        $scope.updateContentType = function () {
            if ($state.params.contentTypeLabel) {
                $scope.contentType = contentTypes[$state.params.contentTypeLabel];
                nutupaneParams['content_type_name'] = $state.params.contentTypeLabel;
            } else {
                $scope.currentState = $state.current.name.split('.').pop();
                $scope.contentType = contentTypes[$scope.currentState];
            }
        };

        contentTypes = {
            'packages': { type: Package, controllerName: 'katello_rpms' },
            'package-groups': { type: PackageGroup, controllerName: 'katello_package_groups' },
            'docker-manifests': { type: DockerManifest, controllerName: 'katello_docker_manifests' },
            'docker-manifest-lists': { type: DockerManifestList, controllerName: 'katello_docker_manifest_lists' },
            'docker-tags': {type: DockerTag, controllerName: 'katello_docker_tags'},
            'files': { type: File, controllerName: 'katello_files' },
            'debs': { type: Deb, controllerName: 'katello_debs' },
            'module-streams': { type: ModuleStream, controllerName: 'katello_module_streams' },
            'ansible-collections': { type: AnsibleCollection, controllerName: 'katello_ansible_collections'}
        };

        //Add in generic content types
        _.each(RepositoryTypesService.genericContentTypes(), function (contentType) {
            contentTypes[contentType['pluralized_label']] = {
                type: GenericContent,
                controllerName: 'katello_generic_content_units',
                'pluralized_name': contentType['pluralized_name'],
                removable: contentType.removable,
                detailsColumns: contentType['details_columns']
            };
        });

        nutupaneParams = {
            'repository_id': $scope.$stateParams.repositoryId
        };


        $scope.updateContentType();
        $scope.contentNutupane = new Nutupane($scope.contentType.type, nutupaneParams);
        $scope.table = $scope.contentNutupane.table;
        $scope.contentNutupane.primaryOnly = true;
        $scope.controllerName = $scope.contentType.controllerName;

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
