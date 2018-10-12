(function () {

    /**
     * @ngdoc service
     * @name Bastion.packages.details.service:RepositoriesFilters
     *
     * @description
     *   Provides a helper service for RepositoriesFilters.
     *
     */
    function RepositoriesFilters() {

        /**
         * modify params depending upon environment and content-view filters
         *
         * Return params
         */

        this.modifyParamsUsingFilters = function(params, contentViewFilter, environmentFilter) {
            var foundVersion, env;
            if (contentViewFilter) {
                if (environmentFilter) {
                    foundVersion = _.find(contentViewFilter.versions, function(version) {
                        // Find the version belonging to the environment specified by the enviroment filter
                        env = _.find(version.environment_ids, function(envId) {
                            return envId === environmentFilter;
                        });

                        return !angular.isUndefined(env);
                    });
                    if (!angular.isUndefined(foundVersion)) {
                        params = this.setContentViewFilter(params, foundVersion.id);
                    }

                } else {
                    params = this.setContentViewFilter(params, contentViewFilter.id, 'content_view_version');
                }
            } else {
                params = this.clearContentViewFilter(params);
            }

            if (environmentFilter) {
                params['environment_id'] = environmentFilter;
            } else {
                delete params['environment_id'];
                params['available_for'] = 'content_view_version';
            }
            return params;
        };

        /**
         * settings content_view_id or content_view_version_id depending upon environment selection i.e keyName passed
         *
         * Return params
         */

        this.setContentViewFilter = function(params, selectedId, keyName) {
            if (keyName && keyName === 'content_view_version') {
                params['content_view_id'] = selectedId;
                params['available_for'] = keyName;
                delete params['content_view_version_id'];
            } else {
                params['content_view_version_id'] = selectedId;
                delete params['content_view_id'];
                delete params['available_for'];
            }
            return params;
        };

        /**
         * delete content_view filter params
         *
         * Return params
         */
        this.clearContentViewFilter = function(params) {
            delete params['content_view_version_id'];
            delete params['content_view_id'];
            delete params['available_for'];

            return params;
        };

    }

    angular.module('Bastion.packages').service('RepositoriesFilters', RepositoriesFilters);

    // RepositoriesFilters.$inject = [];

})();
