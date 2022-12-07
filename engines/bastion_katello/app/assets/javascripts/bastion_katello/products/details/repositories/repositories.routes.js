(function () {
    function RepositoryRoutes($stateProvider) {
        /**
         * @ngdoc object
         * @name  Bastion.repositories:RepositoryRoutes
         *
         * @requires $stateProvider
         *
         * @description
         *   Routes for repository pages.
         */

        $stateProvider.state('product.repositories', {
            url: '/repositories',
            permission: 'view_products',
            controller: 'ProductRepositoriesController',
            templateUrl: 'products/details/repositories/views/product-repositories.html',
            ncyBreadcrumb: {
                label: "{{ 'Repositories' | translate }}",
                parent: 'product.info'
            }
        })
        .state('product.repositories.new', {
            url: '/new',
            permission: 'create_products',
            views: {
                '@product': {
                    controller: 'NewRepositoryController',
                    templateUrl: 'products/details/repositories/new/views/new-repository.html'
                }
            },
            ncyBreadcrumb: {
                label: "{{ 'New Repository' | translate }}",
                parent: 'product.repositories'
            }
        });

        $stateProvider.state("product.repository", {
            abstract: true,
            url: '/repositories/:repositoryId',
            permission: 'view_products',
            views: {
                '@': {
                    controller: 'RepositoryDetailsController',
                    templateUrl: 'products/details/repositories/details/views/repository-details.html'
                }
            }
        })
        .state('product.repository.info', {
            url: '',
            permission: 'view_products',
            controller: 'RepositoryDetailsInfoController',
            templateUrl: 'products/details/repositories/details/views/repository-info.html',
            ncyBreadcrumb: {
                label: "{{ repository.name }}",
                parent: 'product.repositories'
            }
        })
        .state('product.repository.advanced_sync', {
            url: '/advanced_sync',
            permission: 'view_products',
            controller: 'RepositoryAdvancedSyncController',
            templateUrl: 'products/details/repositories/details/views/repository-advanced-sync.html',
            ncyBreadcrumb: {
                label: "{{ 'Advanced Sync' | translate }}",
                parent: 'product.repository.info'
            }
        })
        .state('product.repository.manage-content', {
            abstract: true,
            url: '/content',
            controller: 'RepositoryManageContentController',
            template: '<div ui-view></div>'
        })
        .state('product.repository.manage-content.packages', {
            url: '/packages',
            permission: 'view_products',
            templateUrl: 'products/details/repositories/details/views/repository-manage-packages.html',
            ncyBreadcrumb: {
                label: "{{'Packages' | translate }}",
                parent: 'product.repository.info'
            }
        })
        .state('product.repository.manage-content.package-groups', {
            url: '/package_groups',
            permission: 'view_products',
            templateUrl: 'products/details/repositories/details/views/repository-manage-package-groups.html',
            ncyBreadcrumb: {
                label: "{{'Package Groups' | translate }}",
                parent: 'product.repository.info'
            }
        })
        .state('product.repository.manage-content.docker-manifests', {
            url: '/docker_manifests',
            permission: 'view_products',
            templateUrl: 'products/details/repositories/details/views/repository-manage-docker-manifests.html',
            ncyBreadcrumb: {
                label: "{{'Container Image Manifests' | translate }}",
                parent: 'product.repository.info'
            }
        })
        .state('product.repository.manage-content.docker-tags', {
            url: '/docker_tags',
            permission: 'view_products',
            templateUrl: 'products/details/repositories/details/views/repository-manage-docker-tags.html',
            ncyBreadcrumb: {
                label: "{{'Docker Tags' | translate }}",
                parent: 'product.repository.info'
            }
        })
        .state('product.repository.manage-content.docker-manifest-lists', {
            url: '/docker_manifest_lists',
            permission: 'view_products',
            templateUrl: 'products/details/repositories/details/views/repository-manage-docker-manifest-lists.html',
            ncyBreadcrumb: {
                label: "{{'Container Image Manifest Lists' | translate }}",
                parent: 'product.repository.info'
            }
        })
        .state('product.repository.manage-content.files', {
            url: '/files',
            permission: 'view_products',
            templateUrl: 'products/details/repositories/details/views/repository-manage-files.html',
            ncyBreadcrumb: {
                label: "{{'Files' | translate }}",
                parent: 'product.repository.info'
            }
        })
        .state('product.repository.manage-content.module-streams', {
            url: '/module_streams',
            permission: 'view_products',
            templateUrl: 'products/details/repositories/details/views/repository-manage-module-streams.html',
            ncyBreadcrumb: {
                label: "{{'Module Streams' | translate }}",
                parent: 'product.repository.info'
            }
        })
        .state('product.repository.manage-content.debs', {
            url: '/debs',
            permission: 'view_products',
            templateUrl: 'products/details/repositories/details/views/repository-manage-debs.html',
            ncyBreadcrumb: {
                label: "{{'Debs' | translate }}",
                parent: 'product.repository.info'
            }
        })
        .state('product.repository.manage-content.ansible-collections', {
            url: '/ansible_collections',
            permission: 'view_products',
            templateUrl: 'products/details/repositories/details/views/repository-manage-ansible-collections.html',
            ncyBreadcrumb: {
              label: "{{'Ansible Collections' | translate }}",
              parent: 'product.repository.info'
            }
        })
        .state('product.repository.manage-content.generic-content', {
            url: '/:contentTypeLabel',
            permission: 'view_products',
            templateUrl: 'products/details/repositories/details/views/repository-manage-generic-content.html',
            ncyBreadcrumb: {
                label: "{{ content_type.pluralized_name }}",
                parent: 'product.repository.info'
            }
        });

        $stateProvider.state('product.repository.tasks', {
            abstract: true,
            template: '<div ui-view></div>'
        })
        .state('product.repository.tasks.index', {
            url: '/tasks',
            permission: 'view_products',
            templateUrl: 'products/details/repositories/details/views/repository-tasks.html',
            ncyBreadcrumb: {
                label: "{{'Tasks' | translate }}",
                parent: 'product.repository.info'
            }
        })
        .state('product.repository.tasks.details', {
            url: '/tasks/:taskId',
            permission: 'view_products',
            controller: 'TaskDetailsController',
            templateUrl: 'tasks/views/task-details.html',
            ncyBreadcrumb: {
                label: "{{ task.id }}",
                parent: 'product.repository.tasks.index'
            }
        });
    }

    angular.module('Bastion.repositories').config(RepositoryRoutes);
    RepositoryRoutes.$inject = ['$stateProvider'];
})();
