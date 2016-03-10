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
            }, {
                state: 'ostree',
                resource: 'OstreeBranch',
                display: translate('OSTree Branches'),
                repositoryType: 'ostree'
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
