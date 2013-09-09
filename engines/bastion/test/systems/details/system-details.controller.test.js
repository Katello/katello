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
    var $scope,
        $controller,
        System,
        mockSystem;

    beforeEach(module('Bastion.systems',
                       'systems/views/systems.html'));

    beforeEach(module(function($stateProvider) {
        $stateProvider.state('systems.fake', {});
    }));

    beforeEach(inject(function(_$controller_, $rootScope, $state) {
        $controller = _$controller_;
        $scope = $rootScope.$new();

        state = {
            transitionTo: function(){}
        };

        mockSystem = {
            uuid: 2,
            facts: {
                cpu: "Itanium",
                "lscpu.architecture": "Intel Itanium architecture",
                "lscpu.instructionsPerCycle": "6",
                anotherFact: "yes"
            }
        };
        System = {
            get: function(params, callback) {
                callback(mockSystem);
                return mockSystem;
            }
        };

        spyOn(System, 'get').andCallThrough();

        $scope.$stateParams = {systemId: 2};

        $controller('SystemDetailsController', {$scope: $scope, $state: $state, System: System});
    }));

    it("gets the system using the System service and puts it on the $scope.", function() {
        expect(System.get).toHaveBeenCalledWith({id: 2}, jasmine.any(Function));
        expect($scope.system).toBe(mockSystem);
    });

    it('provides a method to transition states when a system is present', function() {
        expect($scope.transitionTo('systems.fake')).toBeTruthy();
    });

});

