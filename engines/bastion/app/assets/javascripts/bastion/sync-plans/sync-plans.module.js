/**
 Copyright 2014 Red Hat, Inc.

 This software is licensed to you under the GNU General Public
 License as published by the Free Software Foundation; either version
 2 of the License (GPLv2) or (at your option) any later version.
 There is NO WARRANTY for this software, express or implied,
 including the implied warranties of MERCHANTABILITY,
 NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 have received a copy of GPLv2 along with this software; if not, see
 http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 **/

/**
 * @ngdoc module
 * @name  Bastion.sync-plans
 *
 * @description
 *   Module for sync plan related functionality.
 */
angular.module('Bastion.sync-plans', [
    'ngResource',
    'ui.router',
    'Bastion'
]);

/**
 * @ngdoc object
 * @name Bastion.sync-plans.config
 *
 * @requires $stateProvider
 *
 * @description
 *   Used for sync plan level configuration such as setting up the ui state machine.
 */
angular.module('Bastion.sync-plans').config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('sync-plans', {
        abstract: true,
        controller: 'SyncPlansController',
        templateUrl: 'sync-plans/views/sync-plans.html'
    })
    .state('sync-plans.index', {
        url: '/sync_plans',
        views: {
            'table': {
                templateUrl: 'sync-plans/views/sync-plans-table-full.html'
            }
        }
    })

    .state('sync-plans.new', {
        url: '/sync_plans/new',
        collapsed: true,

        views: {
            'table': {
                templateUrl: 'sync-plans/views/sync-plans-table-collapsed.html'
            },
            'action-panel': {
                controller: 'NewSyncPlanController',
                templateUrl: 'sync-plans/new/views/new-sync-plan.html'
            },
            'sync-plan-form@sync-plans.new': {
                controller: 'NewSyncPlanController',
                templateUrl: 'sync-plans/new/views/new-sync-plan-form.html'
            }
        }
    })

    .state("sync-plans.details", {
        abstract: true,
        url: '/sync_plans/:syncPlanId',
        collapsed: true,
        views: {
            'table': {
                templateUrl: 'sync-plans/views/sync-plans-table-collapsed.html'
            },
            'action-panel': {
                controller: 'SyncPlanDetailsController',
                templateUrl: 'sync-plans/details/views/sync-plan-details.html'
            }
        }
    })
    .state('sync-plans.details.info', {
        url: '/info',
        collapsed: true,
        controller: 'SyncPlanDetailsInfoController',
        templateUrl: 'sync-plans/details/views/sync-plan-info.html'
    })

    .state('sync-plans.details.products', {
        abstract: true,
        collapsed: true,
        templateUrl: 'sync-plans/details/views/sync-plan-products.html'
    })
    .state('sync-plans.details.products.list', {
        url: '/products',
        collapsed: true,
        controller: 'SyncPlanProductsController',
        templateUrl: 'sync-plans/details/views/sync-plan-products-table.html'
    })
    .state('sync-plans.details.products.add', {
        url: '/products/add',
        collapsed: true,
        controller: 'SyncPlanAddProductsController',
        templateUrl: 'sync-plans/details/views/sync-plan-products-table.html'
    });

}]);
