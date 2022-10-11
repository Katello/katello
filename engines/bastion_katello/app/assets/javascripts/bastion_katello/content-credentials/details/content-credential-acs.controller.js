/**
 * @ngdoc object
 * @name  Bastion.content-credentials.controller:ContentCredentialACSController
 *
 * @requires $scope
 * @requires Nutupane
 * @requires ContentCredential
 * @requires ApiErrorHandler
 *
 * @description
 *   Page for Content Credential acs
 */
(function () {
    function ContentCredentialACSController($scope, Nutupane, ContentCredential, ApiErrorHandler) {
      var nutupane = new Nutupane(ContentCredential, {
          id: $scope.$stateParams.contentCredentialId
      }, 'acs');
      $scope.controllerName = 'katello_content_credentials';
      nutupane.primaryOnly = true;

      $scope.panel = $scope.panel || {error: false, loading: false};

      $scope.contentCredential = ContentCredential.get({id: $scope.$stateParams.contentCredentialId}, function () {
          $scope.panel.error = false;
          $scope.panel.loading = false;
      }, function (response) {
          $scope.panel.loading = false;
          ApiErrorHandler.handleGETRequestErrors(response, $scope);
      });

      $scope.table = nutupane.table;
  }

    angular.module('Bastion.content-credentials').controller('ContentCredentialACSController', ContentCredentialACSController);
    ContentCredentialACSController.$inject = ['$scope', 'Nutupane', 'ContentCredential', 'ApiErrorHandler'];
})();
