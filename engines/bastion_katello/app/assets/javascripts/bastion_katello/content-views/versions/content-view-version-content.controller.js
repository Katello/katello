(function () {
    'use strict';

    /**
     * @ngdoc controller
     * @name  Bastion.content-views.versions.controller:ContentViewVersionContent
     *
     * @description
     *   Handles fetching content view version content and populating Nutupane based on the current
     *   ui-router state.
     */
    function ContentViewVersionContentController($scope, translate, Nutupane, Package, Erratum,
                                                 PackageGroup, PuppetModule, OstreeBranch, ModuleStream, Deb, Repository,
                                                 ContentViewVersion) {
        var nutupane, contentTypes, currentState, params;

        currentState = $scope.$state.current.name.split('.').pop();

        contentTypes = {
            'docker': {
                type: Repository,
                repositoryType: 'docker',
                params: {
                    'content_type': "docker",
                    'content_view_version_id': $scope.$stateParams.versionId

                }
            },
            'yum': {
                type: Repository,
                repositoryType: 'yum',
                params: {
                    'content_type': "yum",
                    'content_view_version_id': $scope.$stateParams.versionId,
                    archived: true
                }
            },
            'packages': {
                type: Package,
                repositoryType: 'yum'
            },
            'package-groups': {
                type: PackageGroup,
                repositoryType: 'yum',
                params: {
                    'sort_by': 'name',
                    'sort_order': 'ASC',
                    'content_view_version_id': $scope.$stateParams.versionId
                }
            },
            'errata': {
                type: Erratum,
                repositoryType: 'yum'
            },
            'puppet-modules': {
                type: PuppetModule,
                repositoryType: 'puppet'
            },
            'ostree-branches': {
                type: OstreeBranch,
                repositoryType: 'ostree',
                params: {
                    'content_type': "ostree",
                    'content_view_version_id': $scope.$stateParams.versionId,
                    'sort_by': 'version',
                    'sort_order': 'DESC'
                }
            },
            'module-streams': {
                type: ModuleStream,
                repositoryType: 'yum',
                params: {
                    'content_view_version_id': $scope.$stateParams.versionId,
                    'sort_by': 'name',
                    'sort_order': 'ASC'
                }
            },
            'components': {
                type: ContentViewVersion,
                params: {
                    'composite_version_id': $scope.$stateParams.versionId
                }
            },
            'file': {
                type: Repository,
                repositoryType: 'file',
                params: {
                    'content_type': 'file',
                    'content_view_version_id': $scope.$stateParams.versionId,
                    library: true
                }
            },
            'apt': {
                type: Repository,
                repositoryType: 'deb',
                params: {
                    'content_type': 'deb',
                    'content_view_version_id': $scope.$stateParams.versionId,
                    library: true
                }
            },
            'deb': {
                type: Deb,
                repositoryType: 'deb'
            }
        };

        params = contentTypes[currentState].params || {'content_view_version_id': $scope.$stateParams.versionId};

        nutupane = new Nutupane(contentTypes[currentState].type, params, 'queryPaged', { 'disableAutoLoad': true });
        nutupane.masterOnly = true;

        $scope.nutupane = nutupane;
        $scope.table = nutupane.table;
        $scope.contentTypeInfo = contentTypes[currentState];

        $scope.repositoryId = "all";
        $scope.repositories = [];

        $scope.version.$promise.then(function (version) {
            $scope.repositories = _.filter(version.repositories, function(repo) {
                return $scope.contentTypeInfo.repositoryType === repo["content_type"];
            });

            if ($scope.repositories.length === 0 || $scope.repositories[0].id !== "all") {
                $scope.repositories.unshift({name: translate('All Repositories'), id: 'all'});
            }
        });

        $scope.$watch('repositoryId', function (repositoryId) {
            var nutupaneParams = nutupane.getParams();

            if (repositoryId === 'all') {
                nutupaneParams['repository_id'] = null;
                nutupane.setParams(nutupaneParams);
            } else {
                nutupaneParams['repository_id'] = repositoryId;
                nutupane.setParams(nutupaneParams);
            }

            nutupane.refresh();
        });
    }

    angular
        .module('Bastion.content-views.versions')
        .controller('ContentViewVersionContentController', ContentViewVersionContentController);

    ContentViewVersionContentController.$inject = ['$scope', 'translate', 'Nutupane', 'Package', 'Erratum',
                                                   'PackageGroup', 'PuppetModule', 'OstreeBranch', 'ModuleStream', 'Deb', 'Repository', 'ContentViewVersion'];

})();
