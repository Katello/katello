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
 **/

(function () {
    'use strict';

    /**
     * @ngdoc service
     * @name  Bastion.environments.service:Content
     *
     * @description
     *   Provides common functions for managing content types and can build a Nutupane
     *   pre-configured for the content type based on params that are passed in and the
     *   current state of the application.
     */
    function ContentService($injector, Nutupane, $state, translate) {
        var contentTypes;

        function currentState() {
            return $state.current.name.split('.').pop();
        }

        function getContentType(state) {
            return _.find(contentTypes, function (type) {
                return state === type.state;
            });
        }

        this.contentTypes = contentTypes = [
            {
                state: 'content-views',
                resource: 'ContentView',
                display: translate('Content Views'),
                params: {nondefault: true}
            }, {
                state: 'repositories',
                resource: 'Repository',
                params: {'content_type': 'yum'},
                display: 'Yum Repositories'
            }, {
                state: 'errata',
                resource: 'Erratum',
                display: translate('Errata'),
                repositoryType: 'yum'
            }, {
                state: 'packages',
                resource: 'Package',
                display: translate('Packages'),
                repositoryType: 'yum'
            }, {
                state: 'puppet-modules',
                resource: 'PuppetModule',
                display: translate('Puppet Modules'),
                repositoryType: 'puppet'
            }, {
                state: 'docker',
                resource: 'DockerTag',
                display: translate('Docker Tags'),
                repositoryType: 'docker'
            }
        ];

        this.getRepositoryType = function () {
            return getContentType(currentState()).repositoryType;
        };

        this.buildNutupane = function (params) {
            var nutupane;

            params = params || {};
            params = angular.extend(params, getContentType(currentState()).params);
            nutupane = new Nutupane($injector.get(getContentType(currentState()).resource), params, 'queryPaged');

            return nutupane;
        };

    }

    angular
        .module('Bastion.environments')
        .service('ContentService', ContentService);

    ContentService.$inject = ['$injector', 'Nutupane', '$state', 'translate'];

})();
