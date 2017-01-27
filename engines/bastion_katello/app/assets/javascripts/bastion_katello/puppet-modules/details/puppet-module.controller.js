(function () {

    /**
     * @ngdoc object
     * @name  Bastion.puppet-modules.controller:PuppetModuleController
     *
     * @description
     *   Provides the functionality for the puppet modules details action pane.
     */
    function PuppetModuleController($scope, PuppetModule, ApiErrorHandler) {
        $scope.panel = {
            error: false,
            loading: true
        };

        if ($scope.puppetModule) {
            $scope.panel.loading = false;
        }

        $scope.puppetModule = PuppetModule.get({id: $scope.$stateParams.puppetModuleId}, function () {
            $scope.panel.loading = false;
        }, function (response) {
            $scope.panel.loading = false;
            ApiErrorHandler.handleGETRequestErrors(response, $scope);
        });
    }

    angular
        .module('Bastion.puppet-modules')
        .controller('PuppetModuleController', PuppetModuleController);

    PuppetModuleController.$inject = ['$scope', 'PuppetModule', 'ApiErrorHandler'];

})();
