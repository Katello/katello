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

describe('Controller: SystemDetailsController', function() {
    var $scope, $controller, System, mockSystem;

    // load the systems module and template
    beforeEach(module('Bastion.systems', 'systems/views/systems.html'));

    // Initialize controller
    beforeEach(inject(function(_$controller_, $rootScope) {
        $controller = _$controller_;
        $scope = $rootScope.$new();
        // Mocks
        mockSystem = {
            facts: {
                cpu: "Itanium",
                "lscpu.architecture": "Intel Itanium architecture",
                "lscpu.instructionsPerCycle": "6",
                anotherFact: "yes"
            }
        };
        System = {
            get: function() {
                return mockSystem;
            },
            releaseVersions: function() {}
        };
        spyOn(System, 'get').andCallThrough();
        spyOn(System, 'releaseVersions').andReturn(['RHEL6']);

        $scope.$stateParams = {systemId: 2};

        $controller('SystemDetailsController', {$scope: $scope, System: System});
    }));

    it("gets the system using the System service and puts it on the $scope.", function() {
        expect(System.get).toHaveBeenCalledWith({id: 2}, jasmine.any(Function));
        expect($scope.system).toBe(mockSystem);
    });

    it("gets the available release versions and puts them on the $scope", function() {
        expect(System.releaseVersions).toHaveBeenCalledWith({id: 2});
        expect($scope.releaseVersions).toEqual(['RHEL6']);
    });

    describe("populates advanced system information", function () {
        beforeEach(function() {
            System.get = function(systemId, callback) {
                callback.apply();
            }
            $controller('SystemDetailsController', {$scope: $scope, System: System});
        });

        it("creates the system facts object by converting dot notation response to an object.", function() {
            expect(typeof $scope.systemFacts).toBe("object");
            expect(typeof $scope.systemFacts.lscpu).toBe("object");
            expect($scope.systemFacts.lscpu.architecture).toBe("Intel Itanium architecture");
        });

        it("populates advanced info into two groups", function() {
            expect(Object.keys($scope.advancedInfoRight).length).toBe(1);
            expect(Object.keys($scope.advancedInfoRight).length).toBe(1);
        });
    });

    // TODO remove me when we upgrade to AngularJS 1.1.4, see note in system-details.controller.js
    it("retrieves the correct template for each field based on it's type", function() {
        expect($scope.getTemplateForType("somethingElse")).toBe("systems/views/partials/system-detail-value.html");
        expect($scope.getTemplateForType({})).toBe("systems/views/partials/system-detail-object.html");
    });
});

