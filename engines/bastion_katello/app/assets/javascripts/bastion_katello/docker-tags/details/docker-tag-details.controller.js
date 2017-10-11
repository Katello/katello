/**
 * @ngdoc object
 * @name  Bastion.docker-tags.controller:DockerTagDetailsController
 *
 * @requires $scope
 * @requires translate
 * @requires $location
 * @requires DockerTag
 * @requires CurrentOrganization
 * @requires ApiErrorHandler
 *
 * @description
 *   Provides the functionality for the docker tags details action pane.
 */
angular.module('Bastion.docker-tags').controller('DockerTagDetailsController',
    ['$scope', 'translate', '$location', 'Nutupane', 'DockerTag', 'CurrentOrganization', 'ApiErrorHandler',
    function ($scope, translate, $location, Nutupane, DockerTag, CurrentOrganization, ApiErrorHandler) {
        $scope.panel = {
            error: false,
            loading: true
        };

        $scope.table = {};

        if ($scope.tag) {
            $scope.panel.loading = false;
        }

        $scope.tag = DockerTag.get({id: $scope.$stateParams.tagId}, function () {
            $scope.panel.loading = false;
        }, function (response) {
            $scope.panel.loading = false;
            ApiErrorHandler.handleGETRequestErrors(response, $scope);
        });

        $scope.tag.$promise.then(function () {
            var ids = _.map($scope.tag.related_tags, 'id');
            var params = {
                'organization_id': CurrentOrganization,
                'search': $location.search().search || "",
                'sort_by': 'name',
                'sort_order': 'ASC',
                'paged': false,
                'ids[]': ids
            };
            var nutupane = new Nutupane(DockerTag, params, null, {disableAutoLoad: true});

            $scope.controllerName = 'katello_docker_tags';
            $scope.table = nutupane.table;
            $scope.panel.loading = false;

            if (!_.isEmpty(ids)) {
                nutupane.refresh();
            }
        });

        $scope.getManifestType = function (schema) {
            if (schema['manifest_type'] === 'image') {
                return translate("Image");
            }
            return translate("List");

        };

    }
]);
