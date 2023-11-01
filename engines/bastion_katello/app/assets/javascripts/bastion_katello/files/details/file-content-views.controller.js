(function () {

    /**
     * @ngdoc object
     * @name  Bastion.files.controller:FileContentViewsController
     *
     * @description
     *   Provides the functionality for the files details contentViews page.
     *
     *  @requires translate
     *
     */
    function FileContentViewsController($scope, Nutupane, ContentViewVersion, CurrentOrganization, translate) {
        var contentViewsNutupane,
            params = {
                'file_id': $scope.$stateParams.fileId,
                'organization_id': CurrentOrganization,
                'nondefault': true
            };

        contentViewsNutupane = new Nutupane(ContentViewVersion, params);
        $scope.controllerName = 'katello_content_views';

        // Labels so breadcrumb strings can be translated
        $scope.label = translate('Content Views');

        contentViewsNutupane.primaryOnly = true;
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
        'CurrentOrganization',
        'translate'
    ];

})();
