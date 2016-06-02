(function () {

    /**
     * @ngdoc run
     * @name Bastion.run:CheckCurrentOrganization
     *
     * @description
     *   Checks whether a page requires a current organization to be set and if it does
     *   redirects the user to the Katello 403 page to instruct them to select an organization to proceed.
     */
    function CheckCurrentOrganization($rootScope, $window, CurrentOrganization, FencedPages) {

        $rootScope.$on('$stateChangeStart', function (event, toState, toParams) {
            if (CurrentOrganization === "" && FencedPages.isFenced(toState)) {
                event.preventDefault();
                $rootScope.transitionTo('organizations.select', {toState: $rootScope.$state.href(toState.name, toParams, {absolute: 'true'})});
            }
        });

    }

    angular
        .module('Bastion.organizations')
        .run(CheckCurrentOrganization);

    CheckCurrentOrganization.$inject = ['$rootScope', '$window', 'CurrentOrganization', 'FencedPages'];

})();
