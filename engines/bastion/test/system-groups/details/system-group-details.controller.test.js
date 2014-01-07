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

describe('Controller: SystemGroupDetailsController', function() {
    var $scope, gettext, SystemGroup, newGroup;

    beforeEach(module('Bastion.system-groups', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $state = $injector.get('$state');

        newGroup = {id: 8};
        SystemGroup = $injector.get('MockResource').$new();
        SystemGroup.copy = function(params, success){success(newGroup)};

        $scope = $injector.get('$rootScope').$new();

        $scope.$stateParams = {systemGroupId: 1};
        $scope.removeRow = function() {};
        $scope.table = {
            addRow: function() {},
            replaceRow: function() {}
        };

        gettext = function(message) {
            return message;
        };

        $controller('SystemGroupDetailsController', {
            $scope: $scope,
            $state: $state,
            gettext: gettext,
            SystemGroup: SystemGroup
        });
    }));

    it("gets the system using the group service and puts it on the $scope.", function() {
        expect($scope.group).toBeDefined();
    });

    it('provides a method to remove a system group', function() {
        spyOn($scope, 'transitionTo');
        spyOn($scope, 'removeRow');

        $scope.removeGroup($scope.group);

        expect($scope.transitionTo).toHaveBeenCalledWith('system-groups.index');
        expect($scope.removeRow).toHaveBeenCalledWith($scope.group.id);
    });

    it('should save the product successfully', function() {
        $scope.save($scope.group);

        expect($scope.errorMessages.length).toBe(0);
        expect($scope.successMessages.length).toBe(1);
    });

    it('should fail to save the group', function() {
        $scope.group.failed = true;
        $scope.save($scope.group);

        expect($scope.successMessages.length).toBe(0);
        expect($scope.errorMessages.length).toBe(1);
    });

    it('should be able to copy the group', function(){
        spyOn($scope, 'transitionTo');
        spyOn($scope.table, 'addRow');
        $scope.copy(name);

        expect($scope.transitionTo).toHaveBeenCalledWith('system-groups.details.info', {systemGroupId: newGroup.id});
        expect($scope.table.addRow).toHaveBeenCalledWith(newGroup)
    });

});
