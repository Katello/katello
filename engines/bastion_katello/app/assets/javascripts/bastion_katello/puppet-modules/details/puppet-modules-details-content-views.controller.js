(function () {

    /**
     * @ngdoc object
     * @name  Bastion.puppet-modules.controller:PuppetModulesDetailsContentViewsController
     *
     * @description
     *   Provides the functionality for the puppet modules details contentViews page.
     */
    function PuppetModulesDetailsContentViewsController($scope, Nutupane, ContentViewVersion, CurrentOrganization) {
        var contentViewsNutupane,
            params = {
                'puppet_module_id': $scope.$stateParams.puppetModuleId,
                'organization_id': CurrentOrganization
            };

        contentViewsNutupane = new Nutupane(ContentViewVersion, params);
        contentViewsNutupane.masterOnly = true;
        contentViewsNutupane.searchKey = 'contentViewsSearch';

        $scope.detailsTable = contentViewsNutupane.table;

        $scope.environmentNames = function (environments) {
            var names = _.map(environments, function (environment) {
                return environment.name;
            });

            return names.join(',');
        };
    }

    angular
        .module('Bastion.puppet-modules')
        .controller('PuppetModulesDetailsContentViewsController', PuppetModulesDetailsContentViewsController);

    PuppetModulesDetailsContentViewsController.$inject = [
        '$scope',
        'Nutupane',
        'ContentViewVersion',
        'CurrentOrganization'
    ];

})();
