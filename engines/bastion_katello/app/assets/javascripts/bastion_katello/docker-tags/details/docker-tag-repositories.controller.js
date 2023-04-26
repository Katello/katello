/**
 * @ngdoc object
 * @name  Bastion.docker-tags.controller:DockerTagDetailsController
 *
 * @requires $scope
 * @requires $location
 * @requires DockerTag
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality for the docker tags details repositories list.
 */
angular.module('Bastion.docker-tags').controller('DockerTagRepositoriesController',
    ['$scope', '$location', 'Nutupane', 'DockerTag', 'CurrentOrganization',
    function ($scope, $location, Nutupane, DockerTag, CurrentOrganization) {
        var params = {
            'organization_id': CurrentOrganization,
            'search': $location.search().search || "",
            'sort_by': 'name',
            'sort_order': 'ASC',
            'paged': false
        };

        var nutupane = new Nutupane(DockerTag, params, null, {disableAutoLoad: true});

        var renderTable = function () {
            params.action = 'repositories';
            params.id = $scope.tag.id;

            nutupane.setParams(params);
            nutupane.refresh();
        };

        $scope.table = nutupane.table;

        $scope.controllerName = 'katello_docker_tags';

        $scope.tag.$promise.then(function() {
            $scope.panel.loading = false;
            renderTable();
        });
    }
]);
