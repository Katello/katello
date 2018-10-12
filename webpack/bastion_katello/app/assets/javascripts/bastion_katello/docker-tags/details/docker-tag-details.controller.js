/**
 * @ngdoc object
 * @name  Bastion.docker-tags.controller:DockerTagDetailsController
 *
 * @requires $scope
 * @requires $location
 * @requires DockerTag
 * @requires CurrentOrganization
 * @requires ApiErrorHandler
 * @requires translate
 *
 * @description
 *   Provides the functionality for the docker tags details action pane.
 */
angular.module('Bastion.docker-tags').controller('DockerTagDetailsController',
    ['$scope', '$location', 'DockerTag', 'CurrentOrganization', 'ApiErrorHandler', 'translate',
    function ($scope, $location, DockerTag, CurrentOrganization, ApiErrorHandler, translate) {
        $scope.panel = {
            error: false,
            loading: true
        };

        if ($scope.tag) {
            $scope.panel.loading = false;
        }

        $scope.tag = DockerTag.get({id: $scope.$stateParams.tagId}, function (data) {
            if (data.manifest_schema1) {
                data.manifest_schema1["manifest_type_display"] = $scope.getManifestDisplayType(data.manifest_schema1);
            }
            if (data.manifest_schema2) {
                data.manifest_schema2["manifest_type_display"] = $scope.getManifestDisplayType(data.manifest_schema2);
            }
            $scope.panel.loading = false;
        }, function (response) {
            $scope.panel.loading = false;
            ApiErrorHandler.handleGETRequestErrors(response, $scope);
        });

        $scope.getManifestDisplayType = function (schema) {
            if (schema['manifest_type'] === 'image') {
                return translate("Image");
            }
            return translate("List");
        };
    }
]);
