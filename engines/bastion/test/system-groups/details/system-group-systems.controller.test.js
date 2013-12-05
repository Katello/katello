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

describe('Controller: SystemGroupSystemsController', function() {
    var $scope,
        SystemGroup,
        System,
        Nutupane;

    beforeEach(module('Bastion.system-groups', 'Bastion.test-mocks'));

    beforeEach(function() {
        Nutupane = function() {
            this.table = {
                showColumns: function() {},
                getSelected: function() {
                    return [{uuid: 'abcd'}]
                }
            };
            this.get = function() {};
        };
        SystemGroup = {removeSystems: function(){}};
        System = {};
    });

    beforeEach(inject(function($controller, $rootScope, $location) {
        $scope = $rootScope.$new();
        $scope.group = {id: 5};

        $controller('SystemGroupSystemsController', {
            $scope: $scope,
            $location: $location,
            Nutupane: Nutupane,
            gettext: function(){},
            SystemGroup: SystemGroup,
            System: System,
            CurrentOrganization: 'CurrentOrganization'
        });
    }));

    it('attaches the nutupane table to the scope', function() {
        expect($scope.systemsTable).toBeDefined();
    });

    it('sets the closeItem function to not do anything', function() {
        spyOn($scope, "transitionTo");
        $scope.systemsTable.closeItem();
        expect($scope.transitionTo).not.toHaveBeenCalled();
    });

    it('removes selected systems', function(){
        spyOn(SystemGroup, "removeSystems");
        $scope.removeSelected();
        expected_params = {id: $scope.group.id, 'system_ids': ['abcd']};
        expect(SystemGroup.removeSystems).toHaveBeenCalledWith(expected_params, jasmine.any(Function), jasmine.any(Function));
    });

});
