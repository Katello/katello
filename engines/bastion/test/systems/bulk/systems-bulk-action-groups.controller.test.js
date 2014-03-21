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

describe('Controller: SystemsBulkActionGroupsController', function() {
    var $scope, $q, gettext, SystemBulkAction, SystemGroup, Organization,
        Task, CurrentOrganization, Nutupane, $location, groupIds;

    beforeEach(module('Bastion.systems', 'Bastion.test-mocks'));

    beforeEach(function() {
        groupIds =  ['group1', 'group2'];
        SystemBulkAction = {
            addSystemGroups: function() {},
            removeSystemGroups: function() {},
            installContent: function() {},
            updateContent: function() {},
            removeContent: function() {},
            removeSystems: function() {}
        };
        SystemGroup = {
            query: function() {}
        };
        Organization = {
            query: function() {},
            autoAttach: function() {}
        };
        Nutupane = function() {
           this.getAllSelectedResults = function() {
               return {
                   included: { ids: groupIds }
               };
            };
            this.table = { };
        };
        Task = {
            query: function() {},
            poll: function() {}
        };
        gettext = function() {};
        CurrentOrganization = 'foo';
    });

    beforeEach(inject(function($injector) {
        $location = $injector.get('$location');
    }));

    beforeEach(inject(function($controller, $rootScope, $q) {
        $scope = $rootScope.$new();
        $scope.setState = function(){};
        $scope.nutupane = new Nutupane();
        $scope.nutupane.getAllSelectedResults = function() {
            return {
                included: {
                    ids: ['sys1', 'sys2']
                }
            }
        };

        $controller('SystemsBulkActionGroupsController', {$scope: $scope,
            $q: $q,
            $location: $location,
            SystemBulkAction: SystemBulkAction,
            SystemGroup: SystemGroup,
            Nutupane: Nutupane,
            gettext: gettext,
            Organization: Organization,
            CurrentOrganization: CurrentOrganization,
            Task: Task});
    }));

    it("can add system groups to multiple systems", function() {
        $scope.systemGroups = {
            action: 'add'
        };

        spyOn(SystemBulkAction, 'addSystemGroups');
        $scope.performSystemGroupAction();

        expected = $scope.nutupane.getAllSelectedResults();
        expected.system_group_ids = groupIds;
        expected.organization_id = CurrentOrganization;
        expect(SystemBulkAction.addSystemGroups).toHaveBeenCalledWith(expected,
            jasmine.any(Function), jasmine.any(Function));
    });

    it("can remove system groups from multiple systems", function() {
        $scope.systemGroups = {
            action: 'remove'
        };

        spyOn(SystemBulkAction, 'removeSystemGroups');
        $scope.performSystemGroupAction();

        expected = $scope.nutupane.getAllSelectedResults();
        expected.system_group_ids = groupIds;
        expected.organization_id = CurrentOrganization;
        expect(SystemBulkAction.removeSystemGroups).toHaveBeenCalledWith(expected,
            jasmine.any(Function), jasmine.any(Function));
    });

});
