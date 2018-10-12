(function () {
    /**
     * @ngdoc run
     * @name Bastion.run:ContentOverrideHelper
     *
     * @description
     *  Provides common functionality for repository sets content overrides.
     */
    function ContentOverrideHelper() {
        var self = this;

        this.getContentOverrides = function (productRepositorySets, overrideName, overrideValue, remove) {
            var contentOverrides = [];

            angular.forEach(productRepositorySets, function (productRepositorySet) {
                var repositorySet = {
                    'content_label': productRepositorySet.content.label,
                    name: overrideName,
                    value: overrideValue
                };

                if (remove) {
                    repositorySet.remove = true;
                }

                contentOverrides.push(repositorySet);
            });

            return {'content_overrides': contentOverrides};
        };

        this.getEnabledContentOverrides = function (productRepositorySets) {
            return self.getContentOverrides(productRepositorySets, 'enabled', true);
        };

        this.getDisabledContentOverrides = function (productRepositorySets) {
            return self.getContentOverrides(productRepositorySets, 'enabled', false);
        };

        this.getDefaultContentOverrides = function (productRepositorySets) {
            return self.getContentOverrides(productRepositorySets, 'enabled', false, true);

        };
    }

    angular.module('Bastion.repository-sets').service('ContentOverrideHelper', ContentOverrideHelper);
})();
