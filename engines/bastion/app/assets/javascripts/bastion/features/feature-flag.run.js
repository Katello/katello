(function () {

    /**
     * @ngdoc service
     * @name Bastion.run:FeatureFlag
     *
     * @description
     *   Handles checking if a state is enabled on state change. If the state is disabled, the user
     *   is redirected to a 404 page.
     */
    function FeaturesInit($rootScope, $window, FeatureFlag) {
        $rootScope.$on('$stateChangeStart', function (event, toState) {
            if (!FeatureFlag.stateEnabled(toState.name)) {
                $window.location.href = '/404';
            }
        });
    }

    angular
        .module('Bastion.features')
        .run(FeaturesInit);

    FeaturesInit.$inject = ['$rootScope', '$window', 'FeatureFlag'];

})();
