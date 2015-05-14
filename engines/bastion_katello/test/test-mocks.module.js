angular.module('Bastion.test-mocks', ['ui.router']);

angular.module('Bastion.test-mocks').config(['$provide', function ($provide) {

    $provide.factory('PrefixInterceptor', function () {
        return {
            request: function (config) {
                return config;
            }
        };
    });

}]);

angular.module('Bastion.test-mocks').run(['$state', '$stateParams', '$rootScope',
    function($state, $stateParams, $rootScope) {

        $rootScope.transitionTo = function(state, params) {};
        $rootScope.$state = $state;
        $rootScope.$stateParams = $stateParams;

    }
]);

angular.module('Bastion.test-mocks').factory('MockResource', function () {
    function resourceGenerator() {
        var Resource, mockResource, successResponse, errorResponse;

        successResponse ={
            displayMessages: {
                success: ['success'],
                error: ['error']
            }
        };

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
            readonly: false,
            $get: function() {
                return {then: function(callback) {
                    callback(mockResource);
                }};
            },
            $save: function(params, success, error) {
                if (typeof(params) === "function") {
                    error = success;
                    success = params;
                }

                if (!this.failed) {
                    success(this);
                } else {
                    error(errorResponse);
                }
            },
            $update: function(params, success, error) {
                if (typeof(params) === "function") {
                    error = success;
                    success = params;
                }

                if (this.failed) {
                    error({ data: {errors: ['error!']}});
                } else {
                    success(this);
                }
            },
            $delete: function(success, failure) {
                success(this);
            },
            $promise: {then: function(callback) {
                callback(mockResource);
            }}
        };

        Resource = function(parameters) {
            var copy = angular.copy(mockResource);
            if(parameters) {
                angular.extend(copy, parameters);
            }
            Resource.mockResources.results.push(copy);
            Resource.mockResources.total += 1;
            Resource.mockResources.subtotal += 1;
            return copy;
        };

        Resource.mockResources = {
            results: [
                mockResource
            ],
            total: 2,
            subtotal: 1
        };

        Resource.get = function(params, callback) {
            var item;

            angular.forEach(Resource.mockResources.results, function(value) {
                if (params.id) {
                    if (value.id.toString() === params.id.toString()) {
                        item = value;
                    }
                }
            });

            if (callback) {
                callback(item);
            }

            return item;
        };

        Resource.query = function(params, callback) {
            if (typeof(params) === "function") {
                params.call(this, Resource.mockResources);
            } else if (callback) {
                callback.call(this, Resource.mockResources);
            }
            return Resource.mockResources;
        };
        Resource.queryPaged = Resource.query;
        Resource.queryUnpaged = Resource.query;

        Resource.save = function(params, data, success, error) {
            var item = new Resource(data);

            Resource.mockResources.results.push(item);
            success(item);

            return item;
        };

        Resource.update = function(params, data, success, error) {
            var item = Resource.get(params);

            if (item) {
                item = angular.extend(item, data);
            } else {
                item = data;
            }

            if (success) {
                success(item);
            }
            return item;
        };

        Resource.delete = function(params, success, error) {
            params = null;
            delete params;

            if (this.failed) {
                error({ data: {errors: ['error!']}});
            } else {
                success(params);
            }

            return true;
        };

        Resource.remove = Resource.delete;

        return Resource;
    }

    return {
        $new: function() {
                return resourceGenerator();
            }
    };
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


angular.module('Bastion.test-mocks').factory('MockTask',  ['MockResource',
    function(MockResource) {
        var myMock = MockResource.$new();
        var searchIdGenerator = 0;
        myMock.registeredSearches = {};

        myMock.poll = function(task, finishedCallBack) {
            myMock.get(task, finishedCallBack);
        };

        myMock.registerSearch = function(searchParams, callback) {
            searchIdGenerator += 1;
            var searchId = searchIdGenerator;
            myMock.registeredSearches[searchId] = callback;
        };

        myMock.unregisterSearch = function(id) {
            delete myMock.registeredSearches[id];
        };

        myMock.simulateBulkSearch = function (taskData) {
            _.each(myMock.registeredSearches, function (callback) {
                callback(taskData);
            });
        };
        return myMock;
    }
]);

angular.module('Bastion.test-mocks').factory('MockOrganization',  ['MockResource',
    function(MockResource) {
        var myMock = MockResource.$new();

        myMock.mockDiscoveryTask = {
            pending: false,
            input: 'http://fake/',
            output: ['http://fake/foo']
        };

        myMock.cancelRepoDiscover = function(params, success) {
            success(myMock.mockDiscoveryTask);
        };
        myMock.repoDiscover = function(params, success) {
            success(myMock.mockDiscoveryTask);
        };

        return myMock;
    }
]);

angular.module('Bastion.test-mocks').factory('translateMock', function () {

    return function (message) {
        return message;
    };

});
