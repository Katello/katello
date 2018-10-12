(function () {

    /**
     * @ngdoc run
     * @name Bastion.run:FeatureFlag
     *
     * @description
     *   Handles checking if a given feature is enabled. Provides this functionality on
     *   the root scope and also checks routes to send the user to a 404.
     */
    function KatelloFeatures(FeatureFlag) {
        var remoteActions = [
            'content-host.provisioning',
            'content-hosts.bulk-actions.packages',
            'content-hosts.bulk-actions.errata.list',
            'content-hosts.bulk-actions.erratum',
            'content-hosts.bulk-actions.errata.content-hosts',
            'content-hosts.bulk-actions.environment'
        ];

        var customProducts = [
            'products.new.form',
            'products.discovery',
            'products.discovery.scan',
            'products.discovery.create',
            'content-credentials',
            'content-credentials.new',
            'content-credential.info',
            'content-credential.products',
            'content-credential.repositories'
        ];

        FeatureFlag.addStates('remote_actions', remoteActions);
        FeatureFlag.addStates('custom_products', customProducts);
    }

    angular
        .module('Bastion.features')
        .run(KatelloFeatures);

    KatelloFeatures.$inject = ['FeatureFlag'];

})();
