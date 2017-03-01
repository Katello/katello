(function () {

    /**
     * @ngdoc object
     * @name  Bastion.files.controller:FileContentViewsController
     *
     * @description
     *   Provides the functionality for the files details contentViews page.
     */
    function FileContentViewsController($scope, Nutupane, ContentViewVersion, CurrentOrganization) {
        var contentViewsNutupane,
            params = {
                'file_id': $scope.$stateParams.fileId,
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
        .module('Bastion.files')
        .controller('FileContentViewsController', FileContentViewsController);

    FileContentViewsController.$inject = [
        '$scope',
        'Nutupane',
        'ContentViewVersion',
        'CurrentOrganization'
    ];

})();
