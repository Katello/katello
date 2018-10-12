/**
 * @ngdoc object
 * @name  Bastion.products.controller:ProductDetailsInfoController
 *
 * @requires $scope
 * @requires $q
 * @requires translate
 * @requires Product
 * @requires SyncPlan
 * @requires ContentCredential
 * @requires MenuExpander
 * @requires Notification
 *
 * @description
 *   Provides the functionality for the product details action pane.
 */
angular.module('Bastion.products').controller('ProductDetailsInfoController',
    ['$scope', '$state', '$q', 'translate', 'Product', 'SyncPlan', 'ContentCredential', 'MenuExpander', 'Notification',
    function ($scope, $state, $q, translate, Product, SyncPlan, ContentCredential, MenuExpander, Notification) {
        $scope.menuExpander = MenuExpander;
        $scope.page = $scope.page || {loading: false};

        $scope.product = $scope.product || Product.get({id: $scope.$stateParams.productId}, function () {
            $scope.page.loading = false;
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
                results.unshift({id: null});

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
                results.unshift({id: null});

                deferred.resolve(results);
            });

            return deferred.promise;
        };

        $scope.syncPlans = function () {
            return SyncPlan.queryUnpaged().$promise;
        };

        $scope.save = function (product) {
            var deferred = $q.defer();

            product.$update(function (response) {
                deferred.resolve(response);
                Notification.setSuccessMessage(translate('Product Saved'));
            }, function (response) {
                deferred.reject(response);
                angular.forEach(response.data.errors, function (errorMessage) {
                    Notification.setErrorMessage(translate("An error occurred saving the Product: ") + errorMessage);
                });
            });

            return deferred.promise;
        };

        $scope.$on('$stateChangeSuccess', function (event, toState, toParams, fromState) {
            if (fromState.name === 'product.info.new-sync-plan') {
                $scope.product.$update();
            }
        });
    }]
);
