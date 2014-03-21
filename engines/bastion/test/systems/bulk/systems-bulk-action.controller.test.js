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

describe('Controller: SystemsBulkActionController', function() {
    var $scope, $q, selected, gettext, SystemBulkAction, SystemGroup, Organization, Task, CurrentOrganization;

    beforeEach(module('Bastion.systems', 'Bastion.test-mocks'));

    beforeEach(function() {
        selected = {included: {ids: [1, 2, 3]}};
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
        Task = {
            query: function() {},
            poll: function() {}
        };
        gettext = function() {};
        CurrentOrganization = 'foo';
    });

    beforeEach(inject(function($controller, $rootScope, $q) {
        $scope = $rootScope.$new();

        $scope.nutupane = {};
        $scope.nutupane.getAllSelectedResults = function () { return selected };

        $controller('SystemsBulkActionController', {$scope: $scope,
            $q: $q,
            SystemBulkAction: SystemBulkAction,
            SystemGroup: SystemGroup,
            CurrentOrganization: 'foo',
            gettext: gettext,
            Organization: Organization,
            CurrentOrganization: CurrentOrganization,
            Task: Task});
    }));

    it("can a remove multiple systems", function() {
        spyOn(SystemBulkAction, 'removeSystems');
        $scope.performRemoveSystems();

        expect(SystemBulkAction.removeSystems).toHaveBeenCalledWith(_.extend(selected, {'organization_id': 'foo'}),
            jasmine.any(Function), jasmine.any(Function)
        );
    });


});
