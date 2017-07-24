(function () {

    /**
     * @ngdoc object
     * @name  Bastion.debs.controller:DebContentViewsController
     *
     * @description
     *   Provides the functionality for the debs details contentViews page.
     */
    function DebContentViewsController($scope, Nutupane, ContentViewVersion, CurrentOrganization) {
        var contentViewsNutupane,
            params = {
                'deb_id': $scope.$stateParams.debId,
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
        .module('Bastion.debs')
        .controller('DebContentViewsController', DebContentViewsController);

    DebContentViewsController.$inject = [
        '$scope',
        'Nutupane',
        'ContentViewVersion',
        'CurrentOrganization'
    ];

})();
