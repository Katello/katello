/**
 * Copyright 2014 Red Hat, Inc.
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

describe('Controller: ContentHostProductDetailsController', function () {
    var $scope,
        $controller,
        translate,
        ContentHost,
        mockContentHost;

    beforeEach(module('Bastion.content-hosts',
                      'content-hosts/views/content-hosts.html'));

    beforeEach(module(function ($stateProvider) {
        $stateProvider.state('content-hosts.fake', {});
    }));

    beforeEach(inject(function (_$controller_, $rootScope, $state) {
        $controller = _$controller_;
        $scope = $rootScope.$new();

        state = {
            transitionTo: function () {}
        };

        translate = function (message) {
            return message;
        };

        mockContentHost = {
            "id": 1,
            "content_overrides": [{
                "contentLabel": "content-override-true",
                "name": "enabled",
                "value": "1"
            }, {
                "contentLabel": "content-override-false",
                "name": "enabled",
                "value": "0"
            }],

            mockFailed: false,
            mockContent: null
        };

        mockContentHostProducts = {
            "total": 1,
            "subtotal": 1,
            "page": 1,
            "per_page": 20,
            "search": null,
            "sort": {
                "by": null,
                "order": null
            },
            "results": [{
                "id": 1,
                "name": "Some Product",
                "label": "some_product",
                "available_content": [{
                    "enabled": false,
                    "content": {
                        "id": "1",
                        "label": "false-content-not-overridden",
                        "name": "False Content Not Overridden",
                    }
                }, {
                    "enabled": false,
                    "content": {
                        "id": "2",
                        "label": "content-override-true",
                        "name": "Content Override True",
                    }
                }, {
                    "enabled": true,
                    "content": {
                        "id": "3",
                        "label": "content-override-false",
                        "name": "Content Override False",
                    }
                }, {
                    "enabled": true,
                    "content": {
                        "id": "4",
                        "label": "true-content-not-overridden",
                        "name": "True Content Not Overridden",
                    }
                }],
            }]
        };


        ContentHost = {
            get: function (params, callback) {
                callback(mockContentHost);
                return mockContentHost;
            },
            products: function (params, callback) {
                callback(mockContentHostProducts);
                return mockContentHostProducts;
            },
            contentOverride: function (parmas, content, successCallback, errorCallback) {
                if (mockContentHost.mockFailed) {
                    errorCallback({ data: { errors: ['error!'] } });
                } else {
                    successCallback();
                }
            }
        };

        spyOn(ContentHost, 'get').andCallThrough();
        spyOn(ContentHost, 'products').andCallThrough();
        spyOn(ContentHost, 'contentOverride').andCallThrough();

        $scope.contentHost = mockContentHost;
        $scope.products = mockContentHostProducts['results'];
        $scope.successMessages = [];
        $scope.errorMessages = [];

        $controller('ContentHostProductDetailsController', {
            $scope: $scope,
            translate: translate,
            ContentHost: ContentHost
        });
    }));

    it('should initialize product content successfully', function () {
        $scope.productDetails($scope.products[0]);

        expect($scope.details['available_content'][0].overrideEnabled).toBe(null);
        expect($scope.details['available_content'][0].enabledText).toBe("No (Default)");

        expect($scope.details['available_content'][1].overrideEnabled).toBe(1);
        expect($scope.details['available_content'][1].enabledText).toBe("Override to Yes");

        expect($scope.details['available_content'][2].overrideEnabled).toBe(0);
        expect($scope.details['available_content'][2].enabledText).toBe("Override to No");

        expect($scope.details['available_content'][3].overrideEnabled).toBe(null);
        expect($scope.details['available_content'][3].enabledText).toBe("Yes (Default)");
    });

    it('should save the content without override successfully', function () {
        $scope.productDetails($scope.products[0]);
        mockContentHost.mockContent = $scope.details['available_content'][0];
        $scope.saveContentOverride(mockContentHost.mockContent);

        expect($scope.successMessages.length).toBe(1);
        expect($scope.errorMessages.length).toBe(0);
    });

    it('should save the content with override successfully', function () {
        $scope.productDetails($scope.products[0]);
        mockContentHost.mockContent = $scope.details['available_content'][1];
        $scope.saveContentOverride(mockContentHost.mockContent);

        expect($scope.successMessages.length).toBe(1);
        expect($scope.errorMessages.length).toBe(0);
    });

    it('should fail to save the content override', function () {
        $scope.productDetails($scope.products[0]);
        mockContentHost.mockContent = $scope.details['available_content'][1];
        mockContentHost.mockFailed = true;
        $scope.saveContentOverride(mockContentHost.mockContent);

        expect($scope.successMessages.length).toBe(0);
        expect($scope.errorMessages.length).toBe(1);
    });

    it('should give back choices', function () {
        $scope.productDetails($scope.products[0]);
        expect($scope.overrideEnableChoices($scope.details['available_content'][1]).length).toBe(2);
    });

});
