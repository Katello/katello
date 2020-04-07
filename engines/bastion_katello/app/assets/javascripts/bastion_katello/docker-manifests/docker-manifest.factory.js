(function () {
    'use strict';

    /**
     * @ngdoc factory
     * @name  Bastion.docker-manifests.factory:DockerManifest
     *
     * @description
     *   Provides a BastionResource for interacting with Docker Manifests
     */
    function DockerManifest(BastionResource, CurrentOrganization) {
        return BastionResource('katello/api/v2/docker_manifests/:id',
            {'id': '@id', 'organization_id': CurrentOrganization},
            {
                'autocomplete': {method: 'GET', isArray: true, params: {id: 'auto_complete_search'}}
            }
        );
    }

    angular
        .module('Bastion.docker-manifests')
        .factory('DockerManifest', DockerManifest);

    DockerManifest.$inject = ['BastionResource', 'CurrentOrganization'];

})();
