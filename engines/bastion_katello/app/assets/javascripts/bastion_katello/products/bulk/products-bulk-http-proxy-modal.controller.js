/**
 * @ngdoc object
 * @name  Bastion.products.controller:ProductsBulkHttpProxyModalController
 *
 * @requires $scope
 * @requires $state
 * @requires $sce
 * @requires translate
 * @requires ProductBulkAction
 * @requires CurrentOrganization
 * @requires Notification
 * @requires $uibModalInstance
 * @requires bulkParams
 * @requires globalContentProxy
 *
 * @description
 *   A controller for providing bulk action functionality to the products page.
 */
angular.module('Bastion.products').controller('ProductsBulkHttpProxyModalController',
    ['$scope', '$state', '$sce', 'translate', 'HttpProxy', 'ProductBulkAction', 'CurrentOrganization', 'Notification', '$uibModalInstance', 'bulkParams', 'HttpProxyPolicy',
        function ($scope, $state, $sce, translate, HttpProxy, ProductBulkAction, CurrentOrganization, Notification, $uibModalInstance, bulkParams, HttpProxyPolicy) {
            var success, error;

            $scope.proxyOptions = {httpProxyPolicy: 'global_default_http_proxy',
                                    httpProxyId: undefined};

            $scope.policies = HttpProxyPolicy.policies;

            $scope.proxies = [];
            HttpProxy.queryUnpaged(function (proxies) {
                $scope.proxies = proxies.results;
            });

            $scope.update = function () {
                var updateParams = bulkParams;
                $scope.working = true;
                bulkParams['http_proxy_policy'] = $scope.proxyOptions.httpProxyPolicy;
                if (bulkParams['http_proxy_policy'] === 'use_selected_http_proxy') {
                    bulkParams['http_proxy_id'] = $scope.proxyOptions.httpProxyId;

                } else {
                    bulkParams['http_proxy_id'] = null;
                }
                ProductBulkAction.updateProductHttpProxy(updateParams, success, error);
            };

            success = function (task) {
                var url, message;
                url = $state.href('task', {taskId: task.id});

                message = translate("Repository HTTP proxy changes have been initiated in the background.");

                Notification.setSuccessMessage(message, {
                    link: {
                        children: translate("Click to view task"),
                        href: url

                    }});
                $scope.ok();
            };

            error = function (response) {
                angular.forEach(response.data.errors, function(message) {
                    Notification.setErrorMessage(translate("An error occurred: " ) + message);
                });
                $scope.working = false;
            };

            $scope.ok = function () {
                $uibModalInstance.close();
            };

            $scope.cancel = function () {
                $uibModalInstance.dismiss('cancel');
            };
        }]
);
