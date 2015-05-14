/**
 * @ngdoc object
 * @name  Bastion.errata.controller:ErrataDetailsController
 *
 * @requires $scope
 * @requires Errata
 *
 * @description
 *   Provides the functionality for the errata details action pane.
 */
angular.module('Bastion.errata').controller('ErrataDetailsController', ['$scope', 'Erratum',
    function ($scope, Erratum) {
        if ($scope.errata) {
            $scope.panel = {loading: false};
        } else {
            $scope.panel = {loading: true};
        }

        $scope.errata = Erratum.get({id: $scope.$stateParams.errataId}, function () {
            $scope.panel.loading = false;
        });
    }
]);
