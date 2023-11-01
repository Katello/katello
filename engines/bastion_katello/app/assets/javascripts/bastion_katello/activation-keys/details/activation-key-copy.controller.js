(function () {
    'use strict';

    /**
     * @ngdoc controller
     * @name  Bastion.activation-keys.controller:ActivationKeyCopyController
     *
     * @description
     *   For copying a host collection.
     *
     *  @requires translate
     *
     */
    function ActivationKeyCopyController($scope, ActivationKey, Notification, translate) {
        $scope.copy = function (newName) {
            ActivationKey.copy({id: $scope.activationKey.id, 'new_name': newName}, function (response) {
                $scope.transitionTo('activation-key.info', {activationKeyId: response.id});
            }, function (response) {
                Notification.setErrorMessage(response.data.displayMessage);
            });
        };
        // Labels so breadcrumb strings can be translated
        $scope.label = translate('Create Copy');
    }

    angular
        .module('Bastion.activation-keys')
        .controller('ActivationKeyCopyController', ActivationKeyCopyController);

    ActivationKeyCopyController.$inject = ['$scope', 'ActivationKey', 'Notification', 'translate'];

})();
