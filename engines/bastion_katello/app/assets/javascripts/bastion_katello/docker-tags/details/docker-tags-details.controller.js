/**
 * @ngdoc object
 * @name  Bastion.docker-tags.controller:DockerTagsDetailsController
 *
 * @requires $scope
 * @requires $location
 * @requires DockerTag
 * @requires CurrentOrganization
 *
 * @description
 *   Provides the functionality for the docker tags details action pane.
 */
angular.module('Bastion.docker-tags').controller('DockerTagsDetailsController',
    ['$scope', '$location', 'Nutupane', 'DockerTag', 'CurrentOrganization',
    function ($scope, $location, Nutupane, DockerTag, CurrentOrganization) {
        if ($scope.tag) {
            $scope.panel = {loading: false};
        } else {
            $scope.panel = {loading: true};
        }

        $scope.tag = DockerTag.get({id: $scope.$stateParams.tagId});

        $scope.tag.$promise.then(function () {
            var params = {
                'organization_id': CurrentOrganization,
                'search': $location.search().search || "",
                'sort_by': 'name',
                'sort_order': 'ASC',
                'paged': false,
                'ids[]': _.pluck($scope.tag['related_tags'], 'id')
            };
            var nutupane = new Nutupane(DockerTag, params);
            $scope.table = nutupane.table;
            $scope.panel.loading = false;
            nutupane.refresh();
        });
    }
]);
