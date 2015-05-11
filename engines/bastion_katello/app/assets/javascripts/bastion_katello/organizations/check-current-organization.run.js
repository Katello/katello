(function () {

    /**
     * @ngdoc run
     * @name Bastion.run:CheckCurrentOrganization
     *
     * @description
     *   Checks whether a page requires a current organization to be set and if it does
     *   redirects the user to the Katello 403 page to instruct them to select an organization to proceed.
     */
    function CheckCurrentOrganization($rootScope, $window, CurrentOrganization) {
        var fencedPages = [
            'products',
            'activation-keys',
            'environments',
            'subscriptions',
            'gpg-keys',
            'sync-plans',
            'content-views',
            'errata',
            'content-hosts',
            'host-collections'
        ];

        $rootScope.$on('$stateChangeStart', function (event, toState) {
            if (CurrentOrganization === "" && fencedPages.indexOf(toState.name.split('.')[0]) !== -1) {
                event.preventDefault();
                $rootScope.transitionTo('organizations.select', {toState: toState.url});
            }
        });

    }

    angular
        .module('Bastion.organizations')
        .run(CheckCurrentOrganization);

    CheckCurrentOrganization.$inject = ['$rootScope', '$window', 'CurrentOrganization'];

})();
