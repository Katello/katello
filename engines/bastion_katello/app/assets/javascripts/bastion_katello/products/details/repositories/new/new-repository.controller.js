/**
 * @ngdoc object
 * @name  Bastion.repositories.controller:NewRepositoryController
 *
 * @requires $scope
 * @requires $sce
 * @requires Repository
 * @requires Product
 * @requires ContentCredential
 * @requires FormUtils
 * @requires translate
 * @requires Notification
 * @requires ApiErrorHandler
 * @requires BastionConfig
 * @requires Checksum
 * @requires DownloadPolicy
 * @requires OstreeUpstreamSyncPolicy
 * @requires Architecture
 * @requires RepositoryTypesService
 * @requires OSVersions
 * #requires HttpProxyPolicy
 *
 * @description
 *   Controls the creation of an empty Repository object for use by sub-controllers.
 */
angular.module('Bastion.repositories').controller('NewRepositoryController',
    ['$scope', '$sce', 'Repository', 'Product', 'ContentCredential', 'FormUtils', 'translate', 'Notification', 'ApiErrorHandler', 'BastionConfig', 'Checksum', 'DownloadPolicy', 'OstreeUpstreamSyncPolicy', 'Architecture', 'RepositoryTypesService', 'HttpProxy', 'HttpProxyPolicy', 'OSVersions',
        function ($scope, $sce, Repository, Product, ContentCredential, FormUtils, translate, Notification, ApiErrorHandler, BastionConfig, Checksum, DownloadPolicy, OstreeUpstreamSyncPolicy, Architecture, RepositoryTypesService, HttpProxy, HttpProxyPolicy, OSVersions) {

            function success() {
                Notification.setSuccessMessage(translate('Repository %s successfully created.').replace('%s', $scope.repository.name));
                $scope.transitionTo('product.repositories', {productId: $scope.$stateParams.productId});
            }

            function error(response) {
                var foundError = false;
                $scope.working = false;

                angular.forEach($scope.repositoryForm, function (field) {
                    if ($scope.repositoryForm.hasOwnProperty(field) && field.hasOwnProperty('$modelValue')) {
                        field.$setValidity('server', true);
                        $scope.repositoryForm[field].$error.messages = [];
                    }
                });

                angular.forEach(response.data.errors, function (errors, field) {
                    if ($scope.repositoryForm.hasOwnProperty(field)) {
                        foundError = true;
                        $scope.repositoryForm[field].$setValidity('server', false);
                        $scope.repositoryForm[field].$error.messages = errors;
                    }
                });

                if (!foundError) {
                    Notification.setErrorMessage(response.data.displayMessage);
                }
            }

            $scope.page = {
                error: false,
                loading: true
            };

            $scope.repository = new Repository({'product_id': $scope.$stateParams.productId, unprotected: true,
                'checksum_type': null, 'mirror_on_sync': true, 'verify_ssl_on_sync': true,
                'download_policy': BastionConfig.defaultDownloadPolicy, 'arch': null,
                'ostree_upstream_sync_policy': 'latest'});

            $scope.product = Product.get({id: $scope.$stateParams.productId}, function () {
                $scope.page.loading = false;
            }, function (response) {
                $scope.page.loading = false;
                ApiErrorHandler.handleGETRequestErrors(response, $scope);
            });

            $scope.repositoryTypes = RepositoryTypesService.creatable();
            $scope.repositoryTypes = _.sortBy($scope.repositoryTypes, 'name');

            $scope.checksums = Checksum.checksums;
            $scope.downloadPolicies = DownloadPolicy.downloadPolicies;
            $scope.ostreeUpstreamSyncPolicies = OstreeUpstreamSyncPolicy.syncPolicies;

            $scope.$watch('repository.name', function () {
                if ($scope.repositoryForm && $scope.repositoryForm.name) {
                    $scope.repositoryForm.name.$setValidity('server', true);
                    FormUtils.labelize($scope.repository);
                }
            });

            $scope.$watch('repository.content_type', function () {
                $scope.genericRemoteOptions = RepositoryTypesService.getAttribute($scope.repository, "generic_remote_options");
                $scope.urlDescription = RepositoryTypesService.getAttribute($scope.repository, "url_description");
                if ($scope.genericRemoteOptions && $scope.genericRemoteOptions !== []) {
                    $scope.genericRemoteOptions.forEach(function(option) {
                        option.value = "";
                    });
                }
            });

            $scope.handleFiles = function (element) {
                var reader = new FileReader();
                reader.addEventListener("loadend", function() {
                    var data = reader.result;
                    /* eslint-disable camelcase */
                    $scope.repository.ansible_collection_requirements = data;
                    $scope.$apply();
                });
                reader.readAsText(element.files[0]);
            };

            ContentCredential.queryUnpaged(function (contentCredentials) {
                $scope.contentCredentials = contentCredentials.results;
            });

            Architecture.queryUnpaged(function (architecture) {
                var results = architecture.results;
                var noarch = {
                    id: 'noarch',
                    name: translate('No restriction'),
                    value: null
                };
                results.map(function(i) {
                    i.id = i.name;
                });
                results.unshift(noarch);
                $scope.architecture = results;
                $scope.repository.arch = results[0].id;
            });

            $scope.save = function (repository) {
                var fields = ['upstream_password', 'upstream_username', 'ansible_collection_auth_token', 'ansible_collection_auth_url', 'ansible_collection_requirements'];
                if (repository.content_type === 'ostree') {
                    repository.unprotected = false;
                }
                if (repository.content_type === 'yum') {
                    repository.os_versions = $scope.osVersionsParam();
                    if ($scope.repositoryForm.ignore_srpms.$modelValue) {
                        repository.ignorable_content = ["srpm"];
                    } else {
                        repository.ignorable_content = [];
                    }
                }
                if (repository.content_type !== 'yum' && repository.content_type !== 'deb' ) {
                    repository['download_policy'] = '';
                }
                if (repository.arch === 'No restriction') {
                    repository.arch = null;
                }

                angular.forEach(fields, function(field) {
                    if (repository[field] === '') {
                        repository[field] = null;
                    }
                });

                if ($scope.genericRemoteOptions && $scope.genericRemoteOptions !== []) {
                    $scope.genericRemoteOptions.forEach(function(option) {
                        if (option.type === "Array" && option.value !== "") {
                            repository[option.name] = option.value.split(option.delimiter);
                        } else {
                            repository[option.name] = option.value;
                        }
                    });
                }
                repository.$save(success, error);
            };

            $scope.repository['http_proxy_policy'] = HttpProxyPolicy.policies[0].label;
            $scope.policies = HttpProxyPolicy.policies;
            $scope.proxies = [];

            $scope.collectionURLPopover = $sce.trustAsHtml("You can sync collections utilizing just the url:<br/>" +
          "<b>1. For all collections in Ansible Galaxy:</b><br/>" +
          "https://galaxy.ansible.com/api/<br/>" +
          "<b>2. For specific collections with Requirements.yml:</b><br/>" +
          "Use base URL https://galaxy.ansible.com/ and specify requirements.yml below to specify collections");

            $scope.requirementPopover = $sce.trustAsHtml("To learn more about requirement.yml specification, visit <a href='https://docs.ansible.com/ansible/latest/galaxy/user_guide.html#install-multiple-collections-with-a-requirements-file' target=\"_blank\">documentation </a>");

            $scope.displayHttpProxyPolicyName = function (policy) {
                return HttpProxyPolicy.displayHttpProxyPolicyName(policy);
            };

            $scope.displayHttpProxyName = function (proxyId) {
                return HttpProxyPolicy.displayHttpProxyName($scope.proxies, proxyId);
            };

            HttpProxy.queryUnpaged(function (proxies) {
                $scope.proxies = proxies.results;
            });

            $scope.osVersionsOptions = OSVersions.getOSVersionsOptions($scope.repository);
            $scope.repository.os_versions = $scope.osVersionsOptions[0]; // ensure that No restriction is selected initially

            $scope.osVersionsParam = function () {
                return OSVersions.osVersionsParam($scope.repository.os_versions);
            };

        }]
);
