(function () {

    /**
     * @ngdoc object
     * @name Bastion.organizations.config
     *
     * @requires $stateProvider
     *
     * @description
     *   State routes defined for the organizations module.
     */
    function OrganizationRoutes($stateProvider) {
        $stateProvider.state('organizations', {
            abstract: true,
            template: '<div ui-view></div>'
        })
        .state('organizations.select', {
            url: '/select_organization?toState',
            permission: 'view_organizations',
            controller: 'OrganizationSelectorController',
            templateUrl: 'organizations/views/organization-selector.html'
        });
    }

    angular.module('Bastion.organizations').config(OrganizationRoutes);

    OrganizationRoutes.$inject = ['$stateProvider'];

})();
