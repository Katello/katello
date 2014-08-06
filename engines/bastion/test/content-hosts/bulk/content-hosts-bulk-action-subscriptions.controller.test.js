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

describe('Controller: ContentHostsBulkActionSubscriptionsController', function() {
    var $scope, $_q_, translate, ContentHostBulkAction, HostCollection, Organization, Task, CurrentOrganization;

    beforeEach(module('Bastion.content-hosts', 'Bastion.test-mocks'));

    beforeEach(function() {
        ContentHostBulkAction = {
            addHostCollections: function() {},
            removeHostCollections: function() {},
            installContent: function() {},
            updateContent: function() {},
            removeContent: function() {},
            unregisterContentHosts: function() {}
        };
        HostCollection = {
            query: function() {}
        };
        Organization = {
            queryUnpaged: function() {},
            autoAttachSubscriptions: function() {}
        };
        Task = {
            queryUnpaged: function() {},
            poll: function() {},
            monitorTask: function() { return $_q_.defer(); },
        };
        translate = function() {};
        CurrentOrganization = 'foo';
    });

    beforeEach(inject(function($controller, $rootScope, $q) {
        $_q_ = $q;
        $scope = $rootScope.$new();
        $scope.getSelectedContentHostIds = function() {
            return [1,2,3]
        };

        $controller('ContentHostsBulkActionSubscriptionsController', {$scope: $scope,
            $q: $q,
            ContentHostBulkAction: ContentHostBulkAction,
            HostCollection: HostCollection,
            translate: translate,
            Organization: Organization,
            CurrentOrganization: CurrentOrganization,
            Task: Task});
    }));

    it("can auto-attach available subscriptions to all content hosts", function() {
        spyOn(Organization, 'autoAttachSubscriptions');
        $scope.performAutoAttachSubscriptions();

        expect(Organization.autoAttachSubscriptions).toHaveBeenCalled();
    });

});
