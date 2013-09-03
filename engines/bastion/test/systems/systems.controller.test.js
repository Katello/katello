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

describe('Controller: SystemsController', function() {
    var $scope, i18nFilter, System, Nutupane, Routes;

    // load the systems module and template
    beforeEach(module('Bastion.systems', 'Bastion.test-mocks'));

    // Set up mocks
    beforeEach(function() {
        Nutupane = function() {
            this.table = {
                showColumns: function() {}
            };
            this.removeRow = function() {};
            this.get = function() {};
        };
        Routes = {
            apiSystemsPath: function() { return '/api/systems';},
            editSystemPath: function(id) { return '/system/' + id;}
        };
        i18nFilter = function(message) {
            return message;
        };
        System = {};
    });

    // Initialize controller
    beforeEach(inject(function($controller, $rootScope, $state) {
        $scope = $rootScope.$new();

        $controller('SystemsController', {
            $scope: $scope,
            $state: $state,
            i18nFilter: i18nFilter,
            Nutupane: Nutupane,
            System: System,
            CurrentOrganization: 'CurrentOrganization'
        });
    }));

    it("provides a way to get the status color for the system.", function() {
        expect($scope.getStatusColor("valid")).toBe("green");
        expect($scope.getStatusColor("partial")).toBe("yellow");
        expect($scope.getStatusColor("error")).toBe("red");
    });

    it("provides a way to open the details panel.", function() {
        spyOn($scope, "transitionTo");
        $scope.table.openDetails({ uuid: 2 });
        expect($scope.transitionTo).toHaveBeenCalledWith('systems.details.info', {systemId: 2});
    });

    it("provides a way to close the details panel.", function() {
        spyOn($scope, "transitionTo");
        $scope.table.closeItem();
        expect($scope.transitionTo).toHaveBeenCalledWith('systems.index');
    });

    it("provides a way to delete systems.", function() {
        var testSystem = {
            uuid: 'abcde',
            name: 'test',
            $remove: function(callback) {
                callback();
            }
        };

        spyOn($scope, "transitionTo");

        $scope.removeSystem(testSystem);

        expect($scope.transitionTo).toHaveBeenCalledWith('systems.index');
        expect($scope.saveSuccess).toBe(true);
        expect($scope.successMessages[0]).toBe('System test has been deleted.');

    });
});

