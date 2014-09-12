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
        Product,
        CurrentOrganization,
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
            mockContent: null/*,
            $contentOverride: function (success, error) {
                if (mockContentHost.mockFailed) {
                    error({ data: { errors: ['error!'] } });
                } else {
                    success(mockContentHost.mockContent);
                }
            }*/
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
            }
        };

        spyOn(ContentHost, 'get').andCallThrough();
        spyOn(ContentHost, 'products').andCallThrough();

        $scope.contentHost = mockContentHost;
        $scope.contentHost.$promise = { then: function (callback) { callback(mockContentHost) } };

        $controller('ContentHostProductsController', {
            $scope: $scope,
            translate: translate,
            ContentHost: ContentHost,
            Product: Product,
            CurrentOrganization: CurrentOrganization
        });
    }));

    it('gets the content host products', function () {
        expect(ContentHost.products).toHaveBeenCalled();
        expect($scope.displayArea.isAvailableContent).toBe(true);
        expect($scope.displayArea.working).toBe(false);
    });

    it('is available content', function () {
        var products = [{ 'available_content': [1, 2, 3] }];
        expect($scope.isAnyAvailableContent(products)).toBe(true);
    });

    it('is no available content', function () {
        var products = [{ 'available_content': [] }];
        expect($scope.isAnyAvailableContent(products)).toBe(false);
    });
});
