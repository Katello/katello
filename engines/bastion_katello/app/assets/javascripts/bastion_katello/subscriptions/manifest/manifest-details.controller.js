/**
 * @ngdoc object
 * @name  Bastion.subscriptions.controller:ManifestDetailsController
 *
 * @requires $scope
 * @requires $q
 * @requires CurrentOrganization
 * @requires Organization
 *
 * @description
 *   Controls the import of a manifest.
 */
angular.module('Bastion.subscriptions').controller('ManifestDetailsController',
    ['$scope', '$q', 'CurrentOrganization', 'Organization',
    function ($scope, $q, CurrentOrganization, Organization) {

        $scope.organization = Organization.get({id: CurrentOrganization});
        $scope.redhatProvider = Organization.redhatProvider();

        $q.all([$scope.organization.$promise]).then(function () {
            $scope.details = $scope.organization['owner_details'];
            $scope.upstream = $scope.details.upstreamConsumer;

            angular.forEach($scope.redhatProvider['owner_imports'], function (value) {
                if (value.upstreamId === $scope.upstream.uuid) {
                    $scope.manifestImport = value;
                }
            });

            $scope.panel.loading = false;
        });

    }]
);
