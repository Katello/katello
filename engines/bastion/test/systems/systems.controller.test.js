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
    var $scope, gettext, System, Nutupane, Routes;

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
        gettext = function(message) {
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
            gettext: gettext,
            Nutupane: Nutupane,
            System: System,
            CurrentOrganization: 'CurrentOrganization'
        });
    }));

    it("provides a way to close the details panel.", function() {
        spyOn($scope, "transitionTo");
        $scope.systemTable.closeItem();
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
        expect($scope.successMessages[0]).toBe('System test has been deleted.');

    });
});

