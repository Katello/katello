/**
 * @ngdoc object
 * @name  Bastion.errata.controller:ErrataDetailsController
 *
 * @requires $scope
 * @requires Errata
 * @requires ApiErrorHandler
 *
 * @description
 *   Provides the functionality for the errata details action pane.
 */
angular.module('Bastion.errata').controller('ErrataDetailsController', ['$scope', 'Erratum', 'ApiErrorHandler',
    function ($scope, Erratum, ApiErrorHandler) {
        $scope.panel = {
            error: false,
            loading: true
        };

        if ($scope.errata) {
            $scope.panel.loading = false;
        }

        $scope.errata = Erratum.get({id: $scope.$stateParams.errataId}, function () {
            $scope.panel.loading = false;
        }, function (response) {
            $scope.panel.loading = false;
            ApiErrorHandler.handleGETRequestErrors(response, $scope);
        });
    }
]);
