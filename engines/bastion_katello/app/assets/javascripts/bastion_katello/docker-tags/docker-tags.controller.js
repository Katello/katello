/**
 * @ngdoc object
 * @name  Bastion.docker-tags.controller:DockerTagsController
 *
 * @requires $scope
 * @requires $location
 * @requires Nutupane
 * @requires DockerTag
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality specific to docker tags for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.docker-tags').controller('DockerTagsController',
    ['$scope', '$location', 'Nutupane', 'DockerTag', 'CurrentOrganization',
    function ($scope, $location, Nutupane, DockerTag, CurrentOrganization) {

        var params = {
            'organization_id': CurrentOrganization,
            'sort_by': 'name',
            'sort_order': 'ASC',
            'grouped': true
        };

        var nutupane = new Nutupane(DockerTag, params);
        $scope.controllerName = 'katello_docker_tags';
        $scope.table = nutupane.table;
        $scope.controllerName = 'katello_docker_tags';

        $scope.table.closeItem = function () {
            $scope.transitionTo('docker-tags');
        };

        $scope.availableSchemaVersions = function (tag) {
            var versions = [];
            if (tag.manifest_schema1) {
                versions.push(1);
            }

            if (tag.manifest_schema2) {
                versions.push(2);
            }
            return versions.join(", ");
        };

        $scope.getRepositoryNames = function (tag) {
            var names = [];
            var i;
            for (i = 0; i < tag.repositories.length; ++i) {
                names.push(tag.repositories[i].name);
            }

            return names.filter(function(item, index) {
                return names.indexOf(item) >= index;
            }).sort().join(", ");
        };
    }]
);
