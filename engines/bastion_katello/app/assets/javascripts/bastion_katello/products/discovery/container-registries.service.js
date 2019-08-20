/**
 * @ngdoc service
 * @name  Bastion.product.service:ContainerRegistry
 *
 * @requires translate
 *
 * @description
 *   Provides a list of container registries
 */
angular.module('Bastion.products').service('ContainerRegistries',
    ['translate', function () {

        this.registries = {
            'redhat': { name: 'Red Hat Registry (registry.redhat.io)', url: "https://registry.redhat.io" },
            'dockerhub': { name: 'Docker Hub', url: "https://index.docker.io",
                                                createUrl: "https://registry-1.docker.io" },
            'quay': { name: 'Quay', url: "https://quay.io" },
            'custom': { name: 'Custom' }
        };

        this.urlFor = function (registryType, customUrl) {
            if (registryType === "custom") {
                return customUrl;
            } else if (angular.isDefined(this.registries[registryType])) {
                return this.registries[registryType].url;
            }
        };

        this.createUrlFor = function (registryType, customUrl) {
            if (registryType === "custom") {
                return customUrl;
            } else if (angular.isDefined(this.registries[registryType])) {
                if (this.registries[registryType].createUrl) {
                    return this.registries[registryType].createUrl;
                }
                return this.registries[registryType].url;
            }
        };
    }]
);
