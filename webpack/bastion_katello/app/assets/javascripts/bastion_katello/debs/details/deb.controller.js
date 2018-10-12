(function () {

    /**
     * @ngdoc object
     * @name  Bastion.debs.controller:DebController
     *
     * @description
     *   Provides the functionality for the debs details action pane.
     */
    function DebController($scope, Deb, ApiErrorHandler) {
        $scope.panel = {
            error: false,
            loading: true
        };

        if ($scope.deb) {
            $scope.panel.loading = false;
        }

        $scope.deb = Deb.get({id: $scope.$stateParams.debId}, function () {
            $scope.panel.loading = false;
        }, function (response) {
            $scope.panel.loading = false;
            ApiErrorHandler.handleGETRequestErrors(response, $scope);
        });
    }

    angular
        .module('Bastion.debs')
        .controller('DebController', DebController);

    DebController.$inject = ['$scope', 'Deb', 'ApiErrorHandler'];

})();
