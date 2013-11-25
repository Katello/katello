/**
 Copyright 2013 Red Hat, Inc.

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
 * @name  Bastion.systems
 *
 * @description
 *   Module for systems related functionality.
 */
angular.module('Bastion.systems', [
    'ngResource',
    'alchemy',
    'alch-templates',
    'ui.router',
    'Bastion.widgets',
    'Bastion.subscriptions',
    'Bastion.nodes',
    'Bastion.system-groups'
]);

/**
 * @ngdoc object
 * @name Bastion.systems.config
 *
 * @requires $stateProvider
 *
 * @description
 *   Used for systems level configuration such as setting up the ui state machine.
 */
angular.module('Bastion.systems').config(['$stateProvider', function($stateProvider) {
    var templatePrefix = '../';

    $stateProvider.state('systems', {
        abstract: true,
        controller: 'SystemsController',
        templateUrl: templatePrefix + 'systems/views/systems.html'
    });

    $stateProvider.state('systems.index', {
        url: '/systems',
        views: {
            'table': {
                templateUrl: templatePrefix + 'systems/views/systems-table-full.html'
            }
        }
    });

    $stateProvider.state('systems.register', {
        url: '/system/register',
        collapsed: true,
        views: {
            'table': {
                templateUrl: templatePrefix + 'systems/views/systems-table-collapsed.html'
            },
            'action-panel': {
                controller: 'SystemRegisterController',
                templateUrl: templatePrefix + 'systems/views/register.html'
            }
        }
    });

    $stateProvider.state("systems.details", {
        abstract: true,
        url: '/systems/:systemId',
        collapsed: true,
        views: {
            'table': {
                templateUrl: templatePrefix + 'systems/views/systems-table-collapsed.html'
            },
            'action-panel': {
                controller: 'SystemDetailsController',
                templateUrl: templatePrefix + 'systems/details/views/system-details.html'
            }
        }
    })
    .state('systems.details.info', {
        url: '/info',
        collapsed: true,
        controller: 'SystemDetailsInfoController',
        templateUrl: templatePrefix + 'systems/details/views/system-info.html'
    });

    $stateProvider.state('systems.details.events', {
        abstract: true,
        collapsed: true,
        controller: 'SystemEventsController',
        template: '<div ui-view></div>'
    })
    .state('systems.details.events.index', {
        url: '/events',
        collapsed: true,
        templateUrl: templatePrefix + 'systems/details/views/system-events.html'
    })
    .state('systems.details.events.details', {
        url: '/events/:eventId',
        collapsed: true,
        controller: 'SystemEventDetailsController',
        templateUrl: templatePrefix + 'systems/details/views/system-event-details.html'
    });

    $stateProvider.state('systems.details.subscriptions', {
        url: '/subscriptions',
        collapsed: true,
        controller: 'SystemSubscriptionsController',
        templateUrl: templatePrefix + 'systems/details/views/system-subscriptions.html'
    });

    $stateProvider.state("systems.bulk-actions", {
        abstract: true,
        collapsed: true,
        views: {
            'table': {
                templateUrl: templatePrefix + 'systems/views/systems-table-collapsed.html'
            },
            'action-panel': {
                controller: 'SystemsBulkActionController',
                templateUrl: templatePrefix + 'systems/bulk/views/bulk-actions.html'
            }
        }
    })
    .state('systems.bulk-actions.packages', {
        url: '/systems/bulk-actions/packages',
        collapsed: true,
        controller: 'SystemsBulkActionPackagesController',
        templateUrl: templatePrefix + 'systems/bulk/views/bulk-actions-packages.html'
    })
    .state('systems.bulk-actions.errata', {
        url: '/systems/bulk-actions/errata',
        collapsed: true,
        controller: 'SystemsBulkActionErrataController',
        templateUrl: templatePrefix + 'systems/bulk/views/bulk-actions-errata.html'
    })
    .state('systems.bulk-actions.groups', {
        url: '/systems/bulk-actions/groups',
        collapsed: true,
        controller: 'SystemsBulkActionGroupsController',
        templateUrl: templatePrefix + 'systems/bulk/views/bulk-actions-groups.html'
    })
    .state('systems.bulk-actions.subscriptions', {
        url: '/systems/bulk-actions/bulk-subscriptions',
        collapsed: true,
        controller: 'SystemsBulkActionSubscriptionsController',
        templateUrl: templatePrefix + 'systems/bulk/views/bulk-actions-subscriptions.html'
    });

    $stateProvider.state('systems.details.packages', {
        url: '/packages/',
        collapsed: true,
        controller: 'SystemPackagesController',
        templateUrl: templatePrefix + 'systems/content/views/system-packages.html'
    });


    $stateProvider.state('systems.details.errata', {
         abstract: true,
         collapsed: true,
         controller: 'SystemErrataController',
         template: '<div ui-view></div>'
     })
    .state('systems.details.errata.index', {
        url: '/errata/',
        collapsed: true,
        templateUrl: templatePrefix + 'systems/content/views/system-errata.html'
    })
    .state('systems.details.errata.details', {
        url: '/errata/:errataId/',
        collapsed: true,
        templateUrl: templatePrefix + 'systems/content/views/errata-details.html'
    });

}]);
