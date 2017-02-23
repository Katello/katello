(function () {

    /**
     * @ngdoc object
     * @name  Bastion.puppet-modules.controller:PuppetModuleContentViewsController
     *
     * @description
     *   Provides the functionality for the puppet modules details contentViews page.
     */
    function PuppetModuleContentViewsController($scope, Nutupane, ContentViewVersion, CurrentOrganization) {
        var contentViewsNutupane,
            params = {
                'puppet_module_id': $scope.$stateParams.puppetModuleId,
                'organization_id': CurrentOrganization
            };

        contentViewsNutupane = new Nutupane(ContentViewVersion, params);
        $scope.controllerName = 'katello_content_views';
        contentViewsNutupane.masterOnly = true;
        contentViewsNutupane.setSearchKey('contentViewsSearch');

        $scope.table = contentViewsNutupane.table;

        $scope.environmentNames = function (environments) {
            var names = _.map(environments, function (environment) {
                return environment.name;
            });

            return names.join(',');
        };
    }

    angular
        .module('Bastion.puppet-modules')
        .controller('PuppetModuleContentViewsController', PuppetModuleContentViewsController);

    PuppetModuleContentViewsController.$inject = [
        '$scope',
        'Nutupane',
        'ContentViewVersion',
        'CurrentOrganization'
    ];

})();
