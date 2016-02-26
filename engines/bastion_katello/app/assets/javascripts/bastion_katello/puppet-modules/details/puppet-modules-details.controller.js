(function () {

    /**
     * @ngdoc object
     * @name  Bastion.puppet-modules.controller:PuppetModulesDetailsController
     *
     * @description
     *   Provides the functionality for the puppet modules details action pane.
     */
    function PuppetModulesDetailsController($scope, PuppetModule, ApiErrorHandler) {
        $scope.successMessages = [];
        $scope.errorMessages = [];

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
        .controller('PuppetModulesDetailsController', PuppetModulesDetailsController);

    PuppetModulesDetailsController.$inject = ['$scope', 'PuppetModule', 'ApiErrorHandler'];

})();
