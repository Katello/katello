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

describe('Controller: ContentHostDetailsController', function() {
    var $scope,
        $controller,
        translate,
        ContentHost,
        Organization,
        MenuExpander,
        mockContentHost;

    beforeEach(module('Bastion.content-hosts',
                       'content-hosts/views/content-hosts.html'));

    beforeEach(module(function($stateProvider) {
        $stateProvider.state('content-hosts.fake', {});
    }));

    beforeEach(inject(function(_$controller_, $rootScope, $state) {
        $controller = _$controller_;
        $scope = $rootScope.$new();

        state = {
            transitionTo: function() {}
        };

        translate = function(message) {
            return message;
        };

        mockContentHost = {
            failed: false,
            uuid: 2,
            facts: {
                cpu: "Itanium",
                "lscpu.architecture": "Intel Itanium architecture",
                "lscpu.instructionsPerCycle": "6",
                anotherFact: "yes"
            },
            $update: function(success, error) {
                if (mockContentHost.failed) {
                    error({ data: {errors: ['error!']}});
                } else {
                    success(mockContentHost);
                }
            }
        };
        ContentHost = {
            get: function(params, callback) {
                callback(mockContentHost);
                return mockContentHost;
            }
        };

        Organization = {};
        MenuExpander = {};

        spyOn(ContentHost, 'get').andCallThrough();

        $scope.$stateParams = {contentHostId: 2};

        $controller('ContentHostDetailsController', {
            $scope: $scope,
            $state: $state,
            translate: translate,
            ContentHost: ContentHost,
            Organization: Organization,
            MenuExpander: MenuExpander
        });
    }));

    it("sets the menu expander on the scope", function() {
        expect($scope.menuExpander).toBe(MenuExpander);
    });

    it("gets the content host using the ContentHost service and puts it on the $scope.", function() {
        expect(ContentHost.get).toHaveBeenCalledWith({id: 2}, jasmine.any(Function));
        expect($scope.contentHost).toBe(mockContentHost);
    });

    it('provides a method to transition states when a content host is present', function() {
        expect($scope.transitionTo('content-hosts.fake')).toBeTruthy();
    });

    it('should save the content host and return a promise', function() {
        var promise = $scope.save(mockContentHost);

        expect(promise.then).toBeDefined();
    });

    it('should save the content host successfully', function() {
        $scope.save(mockContentHost);

        expect($scope.successMessages.length).toBe(1);
        expect($scope.errorMessages.length).toBe(0);
    });

    it('should fail to save the content host', function() {
        mockContentHost.failed = true;
        $scope.save(mockContentHost);

        expect($scope.successMessages.length).toBe(0);
        expect($scope.errorMessages.length).toBe(1);
    });

});
