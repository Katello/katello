/**
 * @ngdoc object
 * @name  Bastion.products.controller:ProductsBulkAdvancedSyncModalController
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
 *
 * @description
 *   A controller for providing bulk action functionality to the products page.
 */
angular.module('Bastion.products').controller('ProductsBulkAdvancedSyncModalController',
    ['$scope', '$state', '$sce', 'translate', 'ProductBulkAction', 'CurrentOrganization', 'Notification', '$uibModalInstance', 'bulkParams',
        function ($scope, $state, $sce, translate, ProductBulkAction, CurrentOrganization, Notification, $uibModalInstance, bulkParams) {
            var success, error;

            success = function (task) {
                var url, message, taskLink;
                url = $state.href('task', {taskId: task.id});
                taskLink = $sce.trustAsHtml("<a href=" + url + ">here</a>");
                message = translate("Product syncs has been initiated in the background. " +
                    "Click %s to monitor the progress.");

                Notification.setSuccessMessage(message.replace('%s', taskLink));
            };

            error = function (response) {
                angular.forEach(response.data.errors, function(message) {
                    Notification.setErrorMessage(translate("An error occurred initiating the sync: " ) + message);
                });
            };

            $scope.ok = function () {
                var params = bulkParams;
                if ($scope.syncType === "skipMetadataCheck") {
                    params['skip_metadata_check'] = true;
                } else if ($scope.syncType === "validateContents") {
                    params['validate_contents'] = true;
                }
                ProductBulkAction.syncProducts(params, success, error);
                $uibModalInstance.close();
            };

            $scope.cancel = function () {
                $uibModalInstance.dismiss('cancel');
            };
        }]
);
