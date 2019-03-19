(function () {

    /**
     * @ngdoc factory
     * @name Bastion.features.factory:Features
     *
     * @description
     *   Wraps the
     */
    function Features($injector) {
        var features;

        try {
            features = $injector.get('FeatureSettings');
        } catch (e) {
            features = {};
        }

        return features;
    }

    angular
        .module('Bastion.features')
        .factory('Features', Features);

    Features.$inject = ['$injector'];

})();
