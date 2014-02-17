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

angular.module('Bastion.test-mocks', ['ui.router']);

angular.module('Bastion.test-mocks').run(['$state', '$stateParams', '$rootScope',
    function($state, $stateParams, $rootScope) {

        $rootScope.transitionTo = function(state, params) {};
        $rootScope.$state = $state;
        $rootScope.$stateParams = $stateParams;

    }
]);

angular.module('Bastion.test-mocks').factory('MockResource', function() {
    function resourceGenerator() {
        var Resource, mockResource, successResponse, errorResponse;

        successResponse ={
            displayMessages: ['success']
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
            $get: function() {},
            $save: function(success, error) {
                if (!this.failed) {
                    success(successResponse);
                } else {
                    error(errorResponse);
                }
            },
            $update: function(success, error) {
                if (this.failed) {
                    error({ data: {errors: ['error!']}});
                } else {
                    success(this);
                }
            },
            $delete: function(callback) {
                callback();
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
                if (value.id.toString() === params.id.toString()) {
                    item = value;
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

        Resource.save = function(params, data, success, error) {
            var item = new Resource(data);

            Resource.mockResources.results.push(item);
            success(item);

            return item;
        };

        Resource.update = function(params, data, success, error) {
            var item = Resource.get(params);

            item = angular.extend(item, data);

            if (success) {
                success(item);
            }
            return item;
        };

        Resource.delete = function(params, success, error) {
            params = null;
            delete params;
            return true;
        };

        return Resource;
    };

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

        myMock.poll = function(task, finishedCallBack) {
            myMock.get(task, finishedCallBack);
        };
        return myMock;
    }
]);

angular.module('Bastion.test-mocks').factory('MockOrganization',  ['MockResource',
    function(MockResource) {
        var myMock = MockResource.$new();

        myMock.mockDiscoveryTask = {
            id: 'discovery_task',
            pending: false,
            parameters: {url: 'http://fake/'},
            result: ['http://fake/foo']
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

angular.module('Bastion.test-mocks').factory('gettextMock', function () {

    return function (message) {
        return message;
    };

});
