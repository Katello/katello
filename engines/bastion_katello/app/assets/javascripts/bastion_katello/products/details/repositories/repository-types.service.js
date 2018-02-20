(function () {
    'use strict';

    /**
     * @ngdoc service
     * @name  Bastion.products.details.repositories.service:RepositoryTypes
     *
     * @description
     *   Provides common functions for managing content types and can build a Nutupane
     *   pre-configured for the content type based on params that are passed in and the
     *   current state of the application.
     */
    function RepositoryTypesService(repositoryTypes) {

        this.repositoryTypes = function () {
            return repositoryTypes;
        };

        this.creatable = function() {
            return _.filter(repositoryTypes, function (type) {
                return type.creatable;
            });
        };

        this.repositoryTypeEnabled = function (desiredType) {
            var found = _.find(repositoryTypes, function(type) {
                return type.id === desiredType;
            });
            return angular.isDefined(found);
        };
    }

    angular
        .module('Bastion.environments')
        .service('RepositoryTypesService', RepositoryTypesService);

    RepositoryTypesService.$inject = ['repositoryTypes'];

})();
