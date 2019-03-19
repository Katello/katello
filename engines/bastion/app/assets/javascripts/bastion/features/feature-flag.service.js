(function () {

    /**
     * @ngdoc service
     * @name Bastion.features.service:FeatureFlag
     *
     * @description
     *   Provides a service for checking whether a given feature or state based on a feature
     *   is enabled. States may be added to a features state set via the service (see example).
     *
     * @example
     *   Add states:
     *     FeatureFlag.addStates('custom_products', ['products.new']);
     *
     *   Check feature enabled:
     *     FeatureFlag.stateEnabled('custom_products');
     *
     *   Check state enabled:
     *     FeatureFlag.stateEnabled('products.new');
     *
     */
    function FeatureFlag(Features) {
        var featureFlags = {};

        angular.forEach(Features, function (enabled, feature) {
            featureFlags[feature] = {states: [], enabled: enabled};
        });

        /**
         * Returns whether a given feature is enabled or not
         *
         * @param {String} flag Name of a feature flag
         *
         * @returns {Boolean}
         */
        this.featureEnabled = function (flag) {
            return angular.isUndefined(featureFlags[flag]) ? true : featureFlags[flag].enabled;
        };

        /**
         * Returns whether a given state is enabled or not.
         * If a state is defined for multiple flags, returns true if the
         * flag is true for any state that is defined for that flag.
         *
         * @param {String} state ui-router state to check against
         *
         * @returns {Boolean}
         */
        this.stateEnabled = function (state) {
            var enabled = [];

            angular.forEach(featureFlags, function (feature) {
                if (feature.states.indexOf(state) > -1) {
                    enabled.push(feature.enabled);
                }
            });

            return ((enabled.length === 0) ? true : enabled.indexOf(true) > -1);
        };

        /**
         * Add states to a feature flag
         *
         * @param {String} feature The feature to add states to
         * @param {Array}  states  The set of states to add to the feature
         *
         * @returns {Object} Returns the service itself, can be chained
         */
        this.addStates = function (feature, states) {
            feature = featureFlags[feature];

            if (angular.isUndefined(feature)) {
                feature = {states: []};
            } else if (angular.isUndefined(undefined)) {
                feature.states = [];
            }

            feature.states = feature.states.concat(states);

            return this;
        };
    }

    angular
        .module('Bastion.features')
        .service('FeatureFlag', FeatureFlag);

    FeatureFlag.$inject = ['Features'];

})();
