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

describe('Controller: SystemsBulkActionSubscriptionsController', function() {
    var $scope, $q, gettext, SystemBulkAction, SystemGroup, Organization, Task, CurrentOrganization;

    beforeEach(module('Bastion.systems', 'Bastion.test-mocks'));

    beforeEach(function() {
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
            autoAttachSubscriptions: function() {}
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
        $scope.getSelectedSystemIds = function() {
            return [1,2,3]
        };

        $controller('SystemsBulkActionSubscriptionsController', {$scope: $scope,
            $q: $q,
            SystemBulkAction: SystemBulkAction,
            SystemGroup: SystemGroup,
            gettext: gettext,
            Organization: Organization,
            CurrentOrganization: CurrentOrganization,
            Task: Task});
    }));

    it("can auto-attach available subscriptions to all systems", function() {
        spyOn(Organization, 'autoAttachSubscriptions');
        $scope.performAutoAttachSubscriptions();

        expect(Organization.autoAttachSubscriptions).toHaveBeenCalled();
    });

});
