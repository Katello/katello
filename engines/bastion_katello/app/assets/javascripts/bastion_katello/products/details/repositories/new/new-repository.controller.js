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
 * @requires Architecture
 * @requires RepositoryTypesService
 * @requires OSVersions
 * @requires HttpProxyPolicy
 * @requires MirroringPolicy
 *
 * @description
 *   Controls the creation of an empty Repository object for use by sub-controllers.
 */
angular.module('Bastion.repositories').controller('NewRepositoryController',
    ['$scope', '$sce', 'Repository', 'Product', 'ContentCredential', 'FormUtils', 'translate', 'Notification', 'ApiErrorHandler', 'BastionConfig', 'Checksum', 'DownloadPolicy', 'Architecture', 'RepositoryTypesService', 'HttpProxy', 'HttpProxyPolicy', 'OSVersions', 'MirroringPolicy',
        function ($scope, $sce, Repository, Product, ContentCredential, FormUtils, translate, Notification, ApiErrorHandler, BastionConfig, Checksum, DownloadPolicy, Architecture, RepositoryTypesService, HttpProxy, HttpProxyPolicy, OSVersions, MirroringPolicy) {

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

            // Labels so breadcrumb strings can be translated
            $scope.label = translate('New Repository');

            $scope.page = {
                error: false,
                loading: true
            };

            $scope.repository = new Repository({'product_id': $scope.$stateParams.productId, unprotected: true,
                'checksum_type': null,
                'verify_ssl_on_sync': true,
                'download_policy': BastionConfig.defaultDownloadPolicy,
                'arch': null,
                'mirroring_policy': null,
                'include_tags': '', 'exclude_tags': '*-source'});

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

            $scope.mirroringPolicies = MirroringPolicy.mirroringPolicies;

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
                /* eslint-disable camelcase */
                if ($scope.repository.content_type === 'yum') {
                    $scope.repository.mirroring_policy = BastionConfig.defaultYumMirroringPolicy;
                } else {
                    $scope.repository.mirroring_policy = BastionConfig.defaultNonYumMirroringPolicy;
                }
                /* eslint-enable camelcase */
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
                var fields = ['upstream_password', 'upstream_username', 'ansible_collection_auth_token', 'ansible_collection_auth_url', 'ansible_collection_requirements', 'sync_repositories'];
                if (repository.content_type === 'yum') {
                    repository.os_versions = $scope.osVersionsParam();
                    repository.ignorable_content = [];
                    if (repository.ignore_srpms) {
                        repository.ignorable_content.push("srpm");
                    }
                    if (repository.ignore_treeinfo) {
                        repository.ignorable_content.push("treeinfo");
                    }
                }
                if (repository.content_type !== 'deb' && repository.content_type !== 'docker' && repository.content_type !== 'file' && repository.content_type !== 'yum') {
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
                        } else if (option.type === "number" && option.value === "") {
                            repository[option.name] = option.default;
                        } else {
                            repository[option.name] = option.value;
                        }
                    });
                }
                if (!Array.isArray(repository.include_tags)) {
                    if (!_.isEmpty(repository.include_tags)) {
                        repository["include_tags"] = repository.include_tags.split(",").map(function(tag) {
                            return tag.trim();
                        });
                    } else {
                        repository["include_tags"] = [];
                    }
                }

                if (!Array.isArray(repository.exclude_tags)) {
                    if (!_.isEmpty(repository.exclude_tags)) {
                        repository["exclude_tags"] = repository.exclude_tags.split(",").map(function(tag) {
                            return tag.trim();
                        });
                    } else {
                        repository["exclude_tags"] = [];
                    }
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

            $scope.debURLPopover = $sce.trustAsHtml("For standard Debian repos, this is the folder that contains the \"dists/\" and the \"pool/\" subfolders.");

            $scope.distPopover = $sce.trustAsHtml("A \"distribution\" provides the path from the repository root to the \"Release\" file you want to access. Each<br/>" +
             "distribution in the list should use /etc/apt/sources.list syntax. For most official Debian and Ubuntu repositories,<br/>" +
             "the distribution is equal to either the codename or the suite. Upstream repos that do not contain a \"dists/\" <br>" +
             "folder may be using the deprecated \"flat repository format\".<br>" +
             "(See: https://wiki.debian.org/DebianRepository/Format#Flat_Repository_Format).<br>" +
             "When syncing a repo using flat repository format specify exactly one distribution, which must end with a \"/\". When<br>" +
             "syncing repositories that do not use \"flat repository format\" you must not use a trailing \"/\" for your distributions! <br>");

            $scope.componentPopover = $sce.trustAsHtml("Requesting a component that does not exist in the upstream repo, will result in <br/>" +
             "a Pulp warning, but no error. A typo can therefore result in missing content.");

            $scope.archPopover = $sce.trustAsHtml("A list of valid Debian machine architecture strings can be obtained by running <br/>" +
             "\"dpkg-architecture -L\". If present in the upstream repo, the \"all\"<br/>" +
             " architecture is always synced, and does not need to be provided here.<br/>" +
             " Requesting an architecture that does not exist in the upstream repo, <br/>" +
             "will result in a Pulp warning, but no error. A typo can therefore result <br/>" +
             "in missing content.");

            $scope.validateDebAttrList = function(deb_attribute) {
                var value = document.getElementById(deb_attribute).value;
                var pattern = new RegExp(/^((?!,).)*$/);
                return pattern.test(value);
            };

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
