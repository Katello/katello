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

describe('Controller: SystemGroupFormController', function() {
    var $scope,
        $httpBackend;

    beforeEach(module('Bastion.system-groups', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $http = $injector.get('$http'),
            $q = $injector.get('$q'),
            SystemGroup= $injector.get('MockResource').$new();

        $scope = $injector.get('$rootScope').$new();
        $httpBackend = $injector.get('$httpBackend');


        $scope.groupForm = $injector.get('MockForm');
        $scope.table = {
            addRow: function() {},
            closeItem: function() {}
        };

        $controller('SystemGroupFormController', {
            $scope: $scope,
            $q: $q,
            CurrentOrganization: 'foo',
            SystemGroup: SystemGroup
        });
    }));

    it('should attach a new group resource on to the scope', function() {
        expect($scope.group).toBeDefined();
    });

    it('should save a new group resource', function() {
        var group = $scope.group;

        spyOn($scope.table, 'addRow');
        spyOn($scope, 'transitionTo');
        spyOn(group, '$save').andCallThrough();
        $scope.save(group);

        expect(group.$save).toHaveBeenCalled();
        expect($scope.table.addRow).toHaveBeenCalled();
        expect($scope.transitionTo).toHaveBeenCalledWith('system-groups.details.info',
                                                         {systemGroupId: $scope.group.id})
    });

    it('should fail to save a new group resource', function() {
        var group = $scope.group;

        group.failed = true;
        spyOn(group, '$save').andCallThrough();
        $scope.save(group);

        expect(group.$save).toHaveBeenCalled();
        expect($scope.groupForm['name'].$invalid).toBe(true);
        expect($scope.groupForm['name'].$error.messages).toBeDefined();
    });

    it('should correctly determine unlimited', function() {
        $scope.group.max_systems = -1;
        expect($scope.isUnlimited($scope.group)).toBe(true);
    });

    it('should correctly determine limited', function() {
        $scope.group.max_systems = 0;
        expect($scope.isUnlimited($scope.group)).toBe(false);
    });

    it('should set unlimited to true if input changes if actually unlimited', function(){
        $scope.unlimited = false;
        $scope.group.max_systems = -1;
       $scope.inputChanged($scope.group);
       expect($scope.unlimited).toBe(true);
    });

    it('should not set unlimited to true if input changes if not unlimited', function(){
       $scope.unlimited = false;
       $scope.group.max_systems = 1;
       $scope.inputChanged($scope.group);
       expect($scope.unlimited).toBe(false);
    });

    it('should set max_systems to 1 if unlimited unchecked', function(){
        $scope.unlimited = true;
        $scope.group.max_systems = -1;
        $scope.unlimitedChanged($scope.group);

        expect($scope.unlimited).toBe(false);
        expect($scope.group.max_systems).toBe(1);
    });

    it('should set max_systems to -1 if unlimited checked', function(){
        $scope.unlimited = false;
        $scope.group.max_systems = 0;
        $scope.unlimitedChanged($scope.group);

        expect($scope.unlimited).toBe(true);
        expect($scope.group.max_systems).toBe(-1);
    });

});
