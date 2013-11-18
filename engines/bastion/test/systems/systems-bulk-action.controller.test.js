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
    var $scope, $q, gettext, BulkAction, SystemGroup, Organization, Task;

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

    it("can retrieve system groups", function() {
        spyOn(SystemGroup, 'query');
        $scope.getSystemGroups();

        expect(SystemGroup.query).toHaveBeenCalled();
    });

    it("can add system groups to multiple systems", function() {
        $scope.systemGroups = {
            action: 'add',
            groups: [{id: 8}, {id: 9}]
        };

        spyOn(BulkAction, 'addSystemGroups');
        $scope.performSystemGroupAction();

        expect(BulkAction.addSystemGroups).toHaveBeenCalledWith(
            {
                ids: _.pluck($scope.systemTable.getSelected(), 'id'),
                system_group_ids: _.pluck($scope.systemGroups.groups, 'id')
            },
            jasmine.any(Function), jasmine.any(Function)
        );
    });

    it("can remove system groups from multiple systems", function() {
        $scope.systemGroups = {
            action: 'remove',
            groups: [{id: 8}, {id: 9}]
        };

        spyOn(BulkAction, 'removeSystemGroups');
        $scope.performSystemGroupAction();

        expect(BulkAction.removeSystemGroups).toHaveBeenCalledWith(
            {
                ids: _.pluck($scope.systemTable.getSelected(), 'id'),
                system_group_ids: _.pluck($scope.systemGroups.groups, 'id')
            },
            jasmine.any(Function), jasmine.any(Function)
        );
    });

    it("can install packages on multiple systems", function() {
        $scope.content = {
            action: 'install',
            contentType: 'package',
            content: 'zip, zsh, xterm'
        };

        spyOn(BulkAction, 'installContent');
        $scope.performContentAction();

        expect(BulkAction.installContent).toHaveBeenCalledWith(
            {
                ids: _.pluck($scope.systemTable.getSelected(), 'id'),
                content_type: $scope.content.contentType,
                content: $scope.content.content.split(/ *, */)
            },
            jasmine.any(Function), jasmine.any(Function)
        );
    });

    it("can update packages on multiple systems", function() {
        $scope.content = {
            action: 'update',
            contentType: 'package',
            content: 'zip, zsh, xterm'
        };

        spyOn(BulkAction, 'updateContent');
        $scope.performContentAction();

        expect(BulkAction.updateContent).toHaveBeenCalledWith(
            {
                ids: _.pluck($scope.systemTable.getSelected(), 'id'),
                content_type: $scope.content.contentType,
                content: $scope.content.content.split(/ *, */)
            },
            jasmine.any(Function), jasmine.any(Function)
        );
    });

    it("can remove packages on multiple systems", function() {
        $scope.content = {
            action: 'remove',
            contentType: 'package',
            content: 'zip, zsh, xterm'
        };

        spyOn(BulkAction, 'removeContent');
        $scope.performContentAction();

        expect(BulkAction.removeContent).toHaveBeenCalledWith(
            {
                ids: _.pluck($scope.systemTable.getSelected(), 'id'),
                content_type: $scope.content.contentType,
                content: $scope.content.content.split(/ *, */)
            },
            jasmine.any(Function), jasmine.any(Function)
        );
    });

    it("can install package groups on multiple systems", function() {
        $scope.content = {
            action: 'install',
            contentType: 'package_group',
            content: 'Backup Client, Development Tools'
        };

        spyOn(BulkAction, 'installContent');
        $scope.performContentAction();

        expect(BulkAction.installContent).toHaveBeenCalledWith(
            {
                ids: _.pluck($scope.systemTable.getSelected(), 'id'),
                content_type: $scope.content.contentType,
                content: $scope.content.content.split(/ *, */)
            },
            jasmine.any(Function), jasmine.any(Function)
        );
    });

    it("can update package groups on multiple systems", function() {
        $scope.content = {
            action: 'update',
            contentType: 'package_group',
            content: 'Backup Client, Development Tools'
        };

        spyOn(BulkAction, 'updateContent');
        $scope.performContentAction();

        expect(BulkAction.updateContent).toHaveBeenCalledWith(
            {
                ids: _.pluck($scope.systemTable.getSelected(), 'id'),
                content_type: $scope.content.contentType,
                content: $scope.content.content.split(/ *, */)
            },
            jasmine.any(Function), jasmine.any(Function)
        );
    });

    it("can remove package groups on multiple systems", function() {
        $scope.content = {
            action: 'remove',
            contentType: 'package_group',
            content: 'Backup Client, Development Tools'
        };

        spyOn(BulkAction, 'removeContent');
        $scope.performContentAction();

        expect(BulkAction.removeContent).toHaveBeenCalledWith(
            {
                ids: _.pluck($scope.systemTable.getSelected(), 'id'),
                content_type: $scope.content.contentType,
                content: $scope.content.content.split(/ *, */)
            },
            jasmine.any(Function), jasmine.any(Function)
        );
    });

    it("can install errata on multiple systems", function() {
        $scope.content = {
            action: 'install',
            contentType: 'errata',
            content: 'RHSA-2013:0848, RHBA-2012:0777'
        };

        spyOn(BulkAction, 'installContent');
        $scope.performContentAction();

        expect(BulkAction.installContent).toHaveBeenCalledWith(
            {
                ids: _.pluck($scope.systemTable.getSelected(), 'id'),
                content_type: $scope.content.contentType,
                content: $scope.content.content.split(/ *, */)
            },
            jasmine.any(Function), jasmine.any(Function)
        );
    });

    it("can auto-attach available subscriptions to all systems", function() {
        spyOn(Organization, 'autoAttach');
        $scope.performAutoAttachSubscriptions();

        expect(Organization.autoAttach).toHaveBeenCalled();
    });

});
