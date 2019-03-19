/**
 * @ngdoc directive
 * @name Bastion.components.directive:bstModal
 * @restrict A
 *
 * @requires $templateCache
 * @requires $uibModal
 *
 * @description
 *   Provides a wrapper around angular-ui's modal dialog service.
 */
angular.module('Bastion.components').directive('bstModal',
    ['$templateCache', '$uibModal', function ($templateCache, $uibModal) {
    return {
        scope: {
            action: '&bstModal',
            modelName: '@model',
            model: '=',
            templateUrl: '@'
        },
        compile: function(tElement, tAttrs) {
            var template = angular.element('<div extend-template="components/views/bst-modal.html"></div>'),
                templateUrl = tAttrs.templateUrl;

            if (!templateUrl) {
                template.append(tElement.children());
                tElement.html('');
                tElement = angular.element(template);

                templateUrl = 'bstModal%d.html'.replace('%d', Math.random().toString());
                $templateCache.put(templateUrl, tElement);
            }

            return function (scope) {
                var modalInstance, modalController;

                modalController = ['$scope', '$uibModalInstance', 'model', function ($scope, $uibModalInstance, model) {
                    $scope[scope.modelName] = model;

                    $scope.ok = function () {
                        $uibModalInstance.close();
                    };

                    $scope.cancel = function () {
                        $uibModalInstance.dismiss('cancel');
                    };
                }];

                scope.openModal = function () {
                    modalInstance = $uibModal.open({
                        templateUrl: templateUrl,
                        controller: modalController,
                        resolve: {
                            model: function () {
                                return scope.model;
                            }
                        }
                    });

                    modalInstance.result.then(function () {
                        scope.action();
                    });
                };

                scope.$parent.openModal = scope.openModal;
            };
        }
    };
}]);
