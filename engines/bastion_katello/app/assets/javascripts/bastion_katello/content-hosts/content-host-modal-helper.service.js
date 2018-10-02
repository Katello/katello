/**
 * @ngdoc service
 * @name  Bastion.content-hosts.service:ContentHostsModalHelper
 *
 * @requires $uibModal
 *
 * @description
 *  Helper service that contains functionality common amongst content hosts action modals.
*/

angular.module('Bastion.content-hosts').service('ContentHostsModalHelper', ['$uibModal',
    function ($uibModal) {

        this.resolveFunc = null;

        this.openHostCollectionsModal = function() {
        $uibModal.open({
            templateUrl: 'content-hosts/bulk/views/content-hosts-bulk-host-collections-modal.html',
            controller: 'ContentHostsBulkHostCollectionsModalController',
            size: 'lg',
            resolve: {
                hostIds: this.resolveFunc()
            }
        });
    };

        this.openPackagesModal = function() {
            $uibModal.open({
            templateUrl: 'content-hosts/bulk/views/content-hosts-bulk-packages-modal.html',
            controller: 'ContentHostsBulkPackagesModalController',
            size: 'lg',
            resolve: {
                hostIds: this.resolveFunc()
            }
        });
        };

        this.openErrataModal = function() {
            $uibModal.open({
                templateUrl: 'content-hosts/bulk/views/content-hosts-bulk-errata-modal.html',
                controller: 'ContentHostsBulkErrataModalController',
                size: 'lg',
                resolve: {
                    hostIds: this.resolveFunc()
                }
            });
        };

        this.openEnvironmentModal = function() {
            $uibModal.open({
                templateUrl: 'content-hosts/bulk/views/content-hosts-bulk-environment-modal.html',
                controller: 'ContentHostsBulkEnvironmentModalController',
                size: 'lg',
                resolve: {
                    hostIds: this.resolveFunc()
                }
            });
        };

        this.openReleaseVersionModal = function() {
            $uibModal.open({
                templateUrl: 'content-hosts/bulk/views/content-hosts-bulk-release-version-modal.html',
                controller: 'ContentHostsBulkReleaseVersionModalController',
                size: 'lg',
                resolve: {
                    hostIds: this.resolveFunc()
                }
            });
        };

        this.openSubscriptionsModal = function() {
            $uibModal.open({
                templateUrl: 'content-hosts/bulk/views/content-hosts-bulk-subscriptions-modal.html',
                controller: 'ContentHostsBulkSubscriptionsModalController',
                size: 'lg',
                resolve: {
                    hostIds: this.resolveFunc()
                }
            });
        };

        this.openModuleStreamsModal = function() {
            $uibModal.open({
                templateUrl: 'content-hosts/bulk/views/content-host-bulk-module-streams-modal.html',
                controller: 'ContentHostsBulkModuleStreamsModalController',
                size: 'lg',
                resolve: {
                    hostIds: this.resolveFunc()
                }
            });
        };
    }]
);
