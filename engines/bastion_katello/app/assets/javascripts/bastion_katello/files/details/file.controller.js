(function () {

    /**
     * @ngdoc object
     * @name  Bastion.files.controller:FileController
     *
     * @description
     *   Provides the functionality for the files details action pane.
     */
    function FileController($scope, File, ApiErrorHandler) {
        $scope.panel = {
            error: false,
            loading: true
        };

        if ($scope.file) {
            $scope.panel.loading = false;
        }

        $scope.file = File.get({id: $scope.$stateParams.fileId}, function () {
            $scope.panel.loading = false;
        }, function (response) {
            $scope.panel.loading = false;
            ApiErrorHandler.handleGETRequestErrors(response, $scope);
        });
    }

    angular
        .module('Bastion.files')
        .controller('FileController', FileController);

    FileController.$inject = ['$scope', 'File', 'ApiErrorHandler'];

})();
