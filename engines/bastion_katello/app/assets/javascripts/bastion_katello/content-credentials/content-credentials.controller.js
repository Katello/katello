/**
 * @ngdoc object
 * @name  Bastion.content-credentials.controller:ContentCredentialsController
 *
 * @requires $scope
 * @requires $location
 * @requires Nutupane
 * @requires ContentCredential
 * @requires CurrentOrganization
 * @requires translate
 *
 * @description
 *   Provides the functionality specific to ContentCredentials for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.content-credentials').controller('ContentCredentialsController',
    ['$scope', '$location', 'Nutupane', 'ContentCredential', 'CurrentOrganization', 'translate',
    function ($scope, $location, Nutupane, ContentCredential, CurrentOrganization, translate) {
        var params = {
            'organization_id': CurrentOrganization,
            'search': $location.search().search || "",
            'sort_by': 'name',
            'sort_order': 'ASC',
            'paged': true
        };

        var nutupane = new Nutupane(ContentCredential, params);

        // Labels so breadcrumb strings can be translated
        $scope.label = translate('Content Credential');

        $scope.controllerName = 'katello_content_credentials';
        $scope.table = nutupane.table;
        $scope.panel = {loading: false};
        $scope.removeRow = nutupane.removeRow;
    }]
);
