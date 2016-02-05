(function () {
    'use strict';

    /**
     * @ngdoc factory
     * @name  Bastion.docker-manifests.factory:DockerManifest
     *
     * @description
     *   Provides a BastionResource for interacting with Docker Manifests
     */
    function DockerManifest(BastionResource) {
        return BastionResource('/katello/api/v2/docker_manifests/:id',
            {'id': '@id'}
        );
    }

    angular
        .module('Bastion.docker-manifests')
        .factory('DockerManifest', DockerManifest);

    DockerManifest.$inject = ['BastionResource'];

})();
