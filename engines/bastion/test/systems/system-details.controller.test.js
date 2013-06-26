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

describe('Controller: SystemDetailsController', function() {
    var $scope, $state;

    // load the systems module and template
    beforeEach(module('Bastion.systems', 'systems/views/systems-table.html'));

    // Initialize controller
    beforeEach(inject(function($controller, $rootScope) {
        $scope = $rootScope.$new();
        // Mocks
        $scope.table = {
            showColumns: function() {}
        }
        $state = {
            transitionTo: function() {}
        };
        var System = {
            get: function() {}
        };
        $controller('SystemDetailsController', {$scope: $scope, $state: $state, System: System});
    }));

    it("provides a way to close the details panel.", function() {
        spyOn($state, "transitionTo");
        spyOn($scope.table, 'showColumns');

        $scope.table.closeItem();
        expect($state.transitionTo).toHaveBeenCalledWith('systems.index');
        expect($scope.table.showColumns).toHaveBeenCalled();
    });
});

