/**
 * Copyright 2013 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either version
 * 2 of the License (GPLv2) or (at your option) any later version.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 **/

angular.module('Bastion.test-mocks', ['ui.compat']);

angular.module('Bastion.test-mocks').run(['$state', '$stateParams', '$rootScope',
    function($state, $stateParams, $rootScope) {

        $rootScope.transitionTo = function(state, params) {};
        $rootScope.$state = $state;
        $rootScope.$stateParams = $stateParams;

    }
]);

angular.module('Bastion.test-mocks').factory('GPGKey', function() {
    var GPGKey = {
        mockGPGKeys: {
            results: [
                { name: 'GPGKey1', id: 1 }
            ],
            total: 2,
            subtotal: 1
        },
        query: function() {
            return GPGKey.mockGPGKeys;
        }
    };

    return GPGKey;
});

angular.module('Bastion.test-mocks').factory('Product', function() {
    var Product = {
            mockProduct: {
                id: 1,
                failed: false,
                $update: function(success, error) {
                    if (Product.mockProduct.failed) {
                        error({ data: {errors: {}}});
                    } else {
                        success(Product.mockProduct);
                    }
                },
                $delete: function(callback) {
                    callback();
                }
            },
            get: function() {
                return Product.mockProduct;
            },
            query: function() {
                return [];
            }
        };

    return Product;
});

angular.module('Bastion.test-mocks').factory('Repository', function() {
    var Repository, mockRepository;

    mockRepository = {
        id: 1,
        failed: false,
        $update: function(success, error) {
            if (self.failed) {
                error({ data: {errors: {}}});
            } else {
                success(self);
            }
        },
        $delete: function(callback) {
            callback();
        }
    }

    Repository = {
        mockRepositories: {
            results: [
                mockRepository
            ],
            total: 2,
            subtotal: 1
        },
        get: function(id) {
            return Repository.mockRepositories[id];
        },
        query: function(params, callback) {
            callback(Repository.mockRepositories);
            return Repository.mockRepositories;
        }
    };

    return Repository;
});

angular.module('Bastion.test-mocks').factory('MockResource', function() {
    var Resource, mockResource, errorResponse;

    errorResponse = {
        data: {
            errors: {
                name: 'Invalid name'
            }
        }
    };

    mockResource = {
        id: 1,
        name: 'Test Resource',
        label: '',
        failed: false,
        $save: function(success, error) {
            if (!mockResource.failed) {
                success();
            } else {
                error(errorResponse);
            }
        },
        $update: function(success, error) {
            if (mockResource.failed) {
                error({ data: {errors: {}}});
            } else {
                success(mockResource);
            }
        },
        $delete: function(callback) {
            callback();
        }
    }

    Resource = function() {
        return mockResource;
    };

    Resource.mockResources = {
        results: [
            mockResource
        ],
        total: 2,
        subtotal: 1
    };

    Resource.get = function(params) {
        return Resource.mockResources.results[params.id - 1];
    };

    Resource.query = function(params, callback) {
        if (typeof(params) === "function") {
            params(Resource.mockResources);
        } else {
            callback(Resource.mockResources);
        }
        return Resource.mockResources;
    }

    return Resource;
});

angular.module('Bastion.test-mocks').factory('MockForm', function() {
    return {
        name: {
            $invalid: false,
            $setValidity: function() {
                this.$invalid = true;
            },
            $error: {
                messages: []
            }
        }
    };
});
