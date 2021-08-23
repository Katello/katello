/**
 * @ngdoc object
 * @name  Bastion.repositories.controller:RepositoryDetailsInfoController
 *
 * @requires $scope
 * @requires $q
 * @requires translate
 * @requires Notification
 * @requires ContentCredential
 * @requires CurrentOrganization
 * @requires Checksum
 * @requires DownloadPolicy
 * @requires OstreeUpstreamSyncPolicy
 * @requires Architecture
 * @requires HttpProxyPolicy
 * @requires OSVersions
 *
 * @description
 *   Provides the functionality for the repository details info page.
 */
angular.module('Bastion.repositories').controller('RepositoryDetailsInfoController',
    ['$scope', '$q', 'translate', 'Notification', 'ContentCredential', 'CurrentOrganization', 'Checksum', 'DownloadPolicy', 'OstreeUpstreamSyncPolicy', 'Architecture', 'HttpProxy', 'HttpProxyPolicy', 'OSVersions',
        function ($scope, $q, translate, Notification, ContentCredential, CurrentOrganization, Checksum, DownloadPolicy, OstreeUpstreamSyncPolicy, Architecture, HttpProxy, HttpProxyPolicy, OSVersions) {
            $scope.organization = CurrentOrganization;

            $scope.progress = {uploading: false};

            $scope.repository.$promise.then(function () {
                $scope.uploadURL = 'katello/api/v2/repositories/' + $scope.repository.id + '/upload_content';
                $scope.repository['ignore_srpms'] = $scope.repository['ignorable_content'] && $scope.repository['ignorable_content'].includes("srpm");
                $scope.repository['ansible_collection_auth_exists'] = $scope.repository['ansible_collection_auth_url'] && $scope.repository['ansible_collection_auth_token'];
            });

            $scope.gpgKeys = function () {
                var deferred = $q.defer();

                ContentCredential.queryUnpaged(function (contentCredentials) {
                    var results = contentCredentials.results;

                    results = results.filter(function(obj) {
                        if (obj.content_type === "gpg_key") {
                            return true;
                        }
                        return false;
                    });

                    results.unshift({id: null, name: ''});
                    deferred.resolve(results);
                });

                return deferred.promise;
            };

            $scope.certs = function () {
                var deferred = $q.defer();

                ContentCredential.queryUnpaged(function (contentCredentials) {
                    var results = contentCredentials.results;

                    results = results.filter(function(obj) {
                        if (obj.content_type === "cert") {
                            return true;
                        }
                        return false;
                    });

                    results.unshift({id: null, name: ''});
                    deferred.resolve(results);
                });

                return deferred.promise;
            };

            $scope.architectures = function () {
                var deferred = $q.defer();
                Architecture.queryUnpaged(function (architectures) {
                    var results = architectures.results;
                    results.map(function(i) {
                        i.id = i.name;
                    });
                    results.unshift({
                        id: 'noarch',
                        name: translate('No restriction'),
                        value: null
                    });
                    deferred.resolve(results);
                });
                return deferred.promise;
            };

            $scope.save = function (repository, saveUpstreamAuth) {
                var deferred = $q.defer();
                var fields = ['upstream_password', 'upstream_username', 'ansible_collection_auth_token', 'ansible_collection_auth_url', 'ansible_collection_requirements'];
                if (repository.content_type === 'yum' && typeof repository.ignore_srpms !== 'undefined') {
                    if (repository['ignore_srpms']) {
                        repository['ignorable_content'] = ["srpm"];
                    } else {
                        repository['ignorable_content'] = [];
                    }
                }

                if (!saveUpstreamAuth) {
                    repository['upstream_username'] = null;
                    repository['upstream_password'] = null;
                }

                if (!_.isEmpty(repository.commaTagsWhitelist)) {
                    repository["docker_tags_whitelist"] = repository.commaTagsWhitelist.split(",").map(function(tag) {
                        return tag.trim();
                    });
                } else {
                    repository["docker_tags_whitelist"] = [];
                }
                /* eslint-disable camelcase */

                angular.forEach(fields, function(field) {
                    if (repository[field] === '') {
                        repository[field] = null;
                    }
                });
                repository.os_versions = $scope.osVersionsParam();
                repository.$update(function (response) {
                    deferred.resolve(response);
                    $scope.repository.ignore_srpms = $scope.repository.ignorable_content && $scope.repository.ignorable_content.includes("srpm");
                    if (!_.isEmpty(response["docker_tags_whitelist"])) {
                        repository.commaTagsWhitelist = repository["docker_tags_whitelist"].join(", ");
                    } else {
                        repository.commaTagsWhitelist = null;
                    }
                    Notification.setSuccessMessage(translate('Repository Saved.'));
                }, function (response) {
                    deferred.reject(response);
                    Notification.setErrorMessage(translate("An error occurred saving the Repository: ") + response.data.displayMessage);
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
                        Notification.setSuccessMessage(translate('Successfully uploaded content: ') + uploaded);
                        $scope.repository.$get();
                    } else {
                        error = returnData.displayMessage;
                        Notification.setErrorMessage(translate('Error during upload: ') + error);
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
                Notification.setErrorMessage(translate('Error during upload: ') + error);
                $scope.progress.uploading = false;
            };

            $scope.handleFiles = function (element) {
                var reader = new FileReader();
                $scope.uploadedFile = true;
                reader.addEventListener("loadend", function() {
                    var data = reader.result;
                    $scope.repository.ansible_collection_requirements = data;
                    $scope.$apply();
                });
                reader.readAsText(element.files[0]);
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

            $scope.clearUpstreamAuth = function () {
                $scope.repository['upstream_password'] = null;
                $scope.repository['upstream_auth_exists'] = false;
                $scope.repository['upstream_username'] = null;
                $scope.save($scope.repository);
            };

            $scope.clearAnsibleCollectionAuth = function () {
                $scope.repository['ansible_collection_auth_url'] = null;
                $scope.repository['ansible_collection_auth_token'] = null;
                $scope.repository['ansible_collection_auth_exists'] = false;
                $scope.save($scope.repository);
            };

            $scope.policies = HttpProxyPolicy.policies;
            $scope.proxies = [];

            $scope.displayHttpProxyPolicyName = function (policy) {
                return HttpProxyPolicy.displayHttpProxyPolicyName(policy);
            };

            $scope.displayHttpProxyName = function (proxyId) {
                return HttpProxyPolicy.displayHttpProxyName($scope.proxies, proxyId);
            };

            $scope.osVersionsOptions = function () {
                $scope.selectedOSVersion = $scope.formatOSVersions();
                return OSVersions.getOSVersionsOptions();
            };

            $scope.formatOSVersions = function () {
                return OSVersions.formatOSVersions($scope.repository.os_versions);
            };

            $scope.osVersionsParam = function () {
                return OSVersions.osVersionsParam($scope.selectedOSVersion);
            };

            HttpProxy.queryUnpaged(function (proxies) {
                $scope.proxies = proxies.results;
            });

        }]
);
