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

describe('Controller: SystemsBulkActionPackagesController', function() {
    var $scope, $q, translate, SystemBulkAction, SystemGroup, Organization,
		Task, CurrentOrganization, selected;

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
            autoAttach: function() {}
        };
        Task = {
            query: function() {},
            poll: function() {}
        };
        translate = function() {};
        CurrentOrganization = 'foo';
        selected = {included: {ids: [1, 2, 3]}}
    });

    beforeEach(inject(function($controller, $rootScope, $q) {
        $scope = $rootScope.$new();
        $scope.nutupane = {};
        $scope.nutupane.getAllSelectedResults = function () { return selected }
        $scope.setState = function(){};

        $controller('SystemsBulkActionPackagesController', {$scope: $scope,
            $q: $q,
            SystemBulkAction: SystemBulkAction,
            SystemGroup: SystemGroup,
            translate: translate,
            Organization: Organization,
            CurrentOrganization: CurrentOrganization,
            Task: Task});
    }));

    it("can install packages on multiple systems", function() {
        $scope.content = {
            action: 'install',
            contentType: 'package',
            content: 'zip, zsh, xterm'
        };

        spyOn(SystemBulkAction, 'installContent');
        $scope.performContentAction();

        expect(SystemBulkAction.installContent).toHaveBeenCalledWith(
            _.extend({}, selected, {
                content_type: $scope.content.contentType,
                content: $scope.content.content.split(/ *, */)
            }),
            jasmine.any(Function), jasmine.any(Function)
        );
    });

    it("can update packages on multiple systems", function() {
        $scope.content = {
            action: 'update',
            contentType: 'package',
            content: 'zip, zsh, xterm'
        };

        spyOn(SystemBulkAction, 'updateContent');
        $scope.performContentAction();

        expect(SystemBulkAction.updateContent).toHaveBeenCalledWith(
            _.extend({}, selected, {
                content_type: $scope.content.contentType,
                content: $scope.content.content.split(/ *, */)
            }),
            jasmine.any(Function), jasmine.any(Function)
        );
    });

    it("can remove packages on multiple systems", function() {
        $scope.content = {
            action: 'remove',
            contentType: 'package',
            content: 'zip, zsh, xterm'
        };

        spyOn(SystemBulkAction, 'removeContent');
        $scope.performContentAction();

        expect(SystemBulkAction.removeContent).toHaveBeenCalledWith(
            _.extend({}, selected, {
                content_type: $scope.content.contentType,
                content: $scope.content.content.split(/ *, */)
            }),
            jasmine.any(Function), jasmine.any(Function)
        );
    });

    it("can install package groups on multiple systems", function() {
        $scope.content = {
            action: 'install',
            contentType: 'package_group',
            content: 'Backup Client, Development Tools'
        };

        spyOn(SystemBulkAction, 'installContent');
        $scope.performContentAction();

        expect(SystemBulkAction.installContent).toHaveBeenCalledWith(
            _.extend({}, selected, {
                content_type: $scope.content.contentType,
                content: $scope.content.content.split(/ *, */)
            }),
            jasmine.any(Function), jasmine.any(Function)
        );
    });

    it("can update package groups on multiple systems", function() {
        $scope.content = {
            action: 'update',
            contentType: 'package_group',
            content: 'Backup Client, Development Tools'
        };

        spyOn(SystemBulkAction, 'updateContent');
        $scope.performContentAction();

        expect(SystemBulkAction.updateContent).toHaveBeenCalledWith(
            _.extend({}, selected, {
                content_type: $scope.content.contentType,
                content: $scope.content.content.split(/ *, */)
            }),
            jasmine.any(Function), jasmine.any(Function)
        );
    });

    it("can remove package groups on multiple systems", function() {
        $scope.content = {
            action: 'remove',
            contentType: 'package_group',
            content: 'Backup Client, Development Tools'
        };

        spyOn(SystemBulkAction, 'removeContent');
        $scope.performContentAction();

        expect(SystemBulkAction.removeContent).toHaveBeenCalledWith(
            _.extend({}, selected, {
                content_type: $scope.content.contentType,
                content: $scope.content.content.split(/ *, */)
            }),
            jasmine.any(Function), jasmine.any(Function)
        );
    });


});
