/**
 * @ngdoc object
 * @name  Bastion.repositories.controller:RepositoryDetailsInfoController
 *
 * @requires $scope
 * @requires $q
 * @requires translate
 * @requires GPGKey
 * @requires CurrentOrganization
 * @requires Checksum
 * @requires DownloadPolicy
 * @requires OstreeUpstreamSyncPolicy
 *
 * @description
 *   Provides the functionality for the repository details info page.
 */
angular.module('Bastion.repositories').controller('RepositoryDetailsInfoController',
    ['$scope', '$q', 'translate', 'GPGKey', 'CurrentOrganization', 'Checksum', 'DownloadPolicy', 'OstreeUpstreamSyncPolicy',
    function ($scope, $q, translate, GPGKey, CurrentOrganization, Checksum, DownloadPolicy, OstreeUpstreamSyncPolicy) {
        $scope.successMessages = [];
        $scope.errorMessages = [];
        $scope.uploadSuccessMessages = [];
        $scope.uploadErrorMessages = [];
        $scope.organization = CurrentOrganization;

        $scope.progress = {uploading: false};

        $scope.repository.$promise.then(function () {
            $scope.uploadURL = '/katello/api/v2/repositories/' + $scope.repository.id + '/upload_content';
        });

        $scope.gpgKeys = function () {
            var deferred = $q.defer();

            GPGKey.queryUnpaged(function (gpgKeys) {
                var results = gpgKeys.results;

                results.unshift({id: null});
                deferred.resolve(results);
            });

            return deferred.promise;
        };

        $scope.save = function (repository) {
            var deferred = $q.defer();

            repository.$update(function (response) {
                deferred.resolve(response);
                $scope.successMessages = [translate('Repository Saved.')];
            }, function (response) {
                deferred.reject(response);
                _.each(response.data.errors, function (errorMessage) {
                    $scope.errorMessages.push(translate("An error occurred saving the Repository: ") + errorMessage);
                });
            });

            return deferred.promise;
        };

        $scope.uploadContent = function (content) {
            var returnData, error, uploaded;

            if (content) {
                try {
                    returnData = angular.fromJson(angular.element(content).html());
                } catch (err) {
                    returnData = content;
                }

                if (!returnData) {
                    returnData = content;
                }

                if (returnData !== null && returnData.status === 'success') {
                    uploaded = returnData.filenames.join(', ');
                    $scope.uploadSuccessMessages = [translate('Successfully uploaded content: ') + uploaded];
                    $scope.repository.$get();
                } else {
                    error = returnData.displayMessage;
                    $scope.uploadErrorMessages = [translate('Error during upload: ') + error];
                }

                $scope.progress.uploading = false;
            }
        };

        $scope.uploadError = function (error, content) {
            if (angular.isString(content) && content.indexOf("Request Entity Too Large")) {
                error = translate('File too large. Please use the CLI instead.');
            } else {
                error = content;
            }
            $scope.uploadErrorMessages = [translate('Error during upload: ') + error];
            $scope.progress.uploading = false;
        };

        $scope.checksums = Checksum.checksums;
        $scope.downloadPolicies = DownloadPolicy.downloadPolicies;
        $scope.ostreeUpstreamSyncPolicies = OstreeUpstreamSyncPolicy.syncPolicies;

        $scope.checksumTypeDisplay = function (checksum) {
            return Checksum.checksumType(checksum);
        };

        $scope.downloadPolicyDisplay = function (downloadPolicy) {
            return DownloadPolicy.downloadPolicyName(downloadPolicy);
        };

        $scope.ostreeUpstreamSyncPolicyDisplay = function (repository) {
            var policy = repository["ostree_upstream_sync_policy"];
            if ( policy === "custom") {
                return OstreeUpstreamSyncPolicy.syncPolicyName(policy, repository["ostree_upstream_sync_depth"]);
            }
            return OstreeUpstreamSyncPolicy.syncPolicyName(policy);
        };

        $scope.clearUpstreamPassword = function () {
            $scope.repository['upstream_password'] = null;
            $scope.repository['upstream_password_exists'] = false;
            $scope.save($scope.repository);
        };
    }]
);
