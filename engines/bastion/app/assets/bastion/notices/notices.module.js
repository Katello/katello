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
 * @name  Bastion.notices
 *
 * @description
 *   Module for notices related functionality.
 */
angular.module('Bastion.notices', [
    'ngResource',
    'alchemy',
    'alch-templates',
    'ui.compat',
    'Bastion.widgets'
]);

/**
 * @ngdoc object
 * @name Bastion.notices.config
 *
 * @requires $stateProvider
 *
 * @description
 *   Used for notices level configuration such as setting up the ui state machine.
 */
angular.module('Bastion.notices').config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('notices', {
        abstract: true,
        controller: 'NoticesController',
        templateUrl: 'notices/views/notices.html'
    });

    $stateProvider.state('notices.index', {
        url: '/notices',
        views: {
            'table': {
                templateUrl: 'notices/views/notices-table-full.html'
            }
        }
    });

    $stateProvider.state("notices.details", {
        abstract: true,
        url: '/notice/:noticeId',
        collapsed: true,
        views: {
            'table': {
                templateUrl: 'notices/views/notices-table-collapsed.html'
            },
            'action-panel': {
                controller: 'NoticeDetailsController',
                templateUrl: 'notices/details/views/notice-details.html'
            }
        }
    })

    .state('notices.details.info', {
        url: '/info',
        collapsed: true,
        controller: 'NoticeDetailsInfoController',
        templateUrl: 'notices/details/views/notice-info.html'
    });

}]);
