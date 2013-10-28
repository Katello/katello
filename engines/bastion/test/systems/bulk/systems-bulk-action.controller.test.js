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

describe('Controller: SystemsBulkActionController', function() {
    var $scope, $q, gettext, BulkAction, SystemGroup, Organization, Task, CurrentOrganization;

    beforeEach(module('Bastion.systems', 'Bastion.test-mocks'));

    beforeEach(function() {
        BulkAction = {
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
        Task = {
            query: function() {},
            poll: function() {}
        };
        gettext = function() {};
        CurrentOrganization = 'foo';
    });

    beforeEach(inject(function($controller, $rootScope, $q) {
        $scope = $rootScope.$new();
        $scope.systemTable = {
            getSelected: function() {return [
                {id: 1},
                {id: 2},
                {id: 3}
            ];}
        };

        $controller('SystemsBulkActionController', {$scope: $scope,
            $q: $q,
            BulkAction: BulkAction,
            SystemGroup: SystemGroup,
            gettext: gettext,
            Organization: Organization,
            CurrentOrganization: CurrentOrganization,
            Task: Task});
    }));

    it("can a remove multiple systems", function() {
        spyOn(BulkAction, 'removeSystems');
        $scope.performRemoveSystems();

        expect(BulkAction.removeSystems).toHaveBeenCalledWith(
            {ids: _.pluck($scope.systemTable.getSelected(), 'id')},
            jasmine.any(Function), jasmine.any(Function)
        );
    });


});
