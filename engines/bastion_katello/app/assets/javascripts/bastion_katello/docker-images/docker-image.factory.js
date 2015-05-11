(function () {
    'use strict';

    /**
     * @ngdoc factory
     * @name  Bastion.docker-images.factory:DockerImage
     *
     * @description
     *   Provides a BastionResource for interacting with Docker Images
     */
    function DockerImage(BastionResource) {
        return BastionResource('/katello/api/v2/docker_images/:id',
            {'id': '@id'}
        );
    }

    angular
        .module('Bastion.docker-images')
        .factory('DockerImage', DockerImage);

    DockerImage.$inject = ['BastionResource'];

})();
