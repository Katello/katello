/**
 Copyright 2013 Red Hat, Inc.

 This software is licensed to you under the GNU General Public
 License as published by the Free Software Foundation; either version
 2 of the License (GPLv2) or (at your option) any later version.
 There is NO WARRANTY for this software, express or implied,
 including the implied warranties of MERCHANTABILITY,
 NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 have received a copy of GPLv2 along with this software; if not, see
 http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 **/

describe('Controller: SystemsController', function() {
    var $scope, $state, Nutupane, Routes;

    // load the systems module and template
    beforeEach(module('Bastion.systems'));

    // Set up mocks
    beforeEach(function() {
        $state = {
            transitionTo: function() {}
        };
        Nutupane = function() {
            this.table = {};
            this.get = function() {};
        };
        Routes = {
            apiSystemsPath: function() { return '/api/systems';},
            editSystemPath: function(id) { return '/system/' + id;}
        };
    });

    // Initialize controller
    beforeEach(inject(function($controller, $rootScope) {
        $scope = $rootScope.$new();
        $controller('SystemsController', {$scope: $scope, $state: $state, Nutupane: Nutupane, Routes: Routes});
    }));

    it("provides a way to get the status color for the system.", function() {
        expect($scope.getStatusColor("valid")).toBe("green");
        expect($scope.getStatusColor("partial")).toBe("yellow");
        expect($scope.getStatusColor("error")).toBe("red");
    });
});

