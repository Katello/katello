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

        this.genericContentTypes = function (repoTypeLabel) {
            var types;
            var typesToSearch = repositoryTypes;
            if (angular.isDefined(repoTypeLabel)) {
                typesToSearch = [this.repositoryType(repoTypeLabel)];
            }
            types = _.map(typesToSearch, function(repoType) {
                return _.filter(repoType['content_types'], function(contentType) {
                    return contentType.generic;
                });
            });
            return [].concat.apply([], types);
        };

        this.repositoryType = function (typeLabel) {
            return _.find(repositoryTypes, function(type) {
                return type.id === typeLabel;
            });
        };

        this.repositoryTypeEnabled = function (desiredType) {
            return angular.isDefined(this.repositoryType(desiredType));
        };

        this.repositoryType = this.repositoryType.bind(this);
        this.repositoryTypeEnabled = this.repositoryTypeEnabled.bind(this);

        this.pulp3Supported = function(desiredType) {
            var found = _.find(repositoryTypes, function(type) {
                return type.id === desiredType;
            });

            return found.pulp3_support;
        };

        this.getAttribute = function(repository, key) {
            var typeIndex = repositoryTypes.map(function(type) {
                return type.name;
            }).indexOf(repository.content_type);
            if (angular.isDefined(repositoryTypes[typeIndex])) {
                return repositoryTypes[typeIndex][key];
            }
        };
    }

    angular
        .module('Bastion.environments')
        .service('RepositoryTypesService', RepositoryTypesService);

    RepositoryTypesService.$inject = ['repositoryTypes'];

})();
