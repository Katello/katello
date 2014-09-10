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

describe('Controller: ContentHostsBulkActionPackagesController', function() {
    var $scope, $q, translate, ContentHostBulkAction, HostCollection, Organization,
        Task, CurrentOrganization, selected;

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

        $controller('ContentHostsBulkActionPackagesController', {$scope: $scope,
            $q: $q,
            ContentHostBulkAction: ContentHostBulkAction,
            HostCollection: HostCollection,
            translate: translate,
            Organization: Organization,
            CurrentOrganization: CurrentOrganization,
            Task: Task});
    }));

    it("can install packages on multiple content hosts", function() {
        $scope.content = {
            action: 'install',
            contentType: 'package',
            content: 'zip, zsh, xterm'
        };

        spyOn(ContentHostBulkAction, 'installContent');
        $scope.performContentAction();

        expect(ContentHostBulkAction.installContent).toHaveBeenCalledWith(
            _.extend({}, selected, {
                content_type: $scope.content.contentType,
                content: $scope.content.content.split(/ *, */)
            }),
            jasmine.any(Function), jasmine.any(Function)
        );
    });

    it("can update packages on multiple content hosts", function() {
        $scope.content = {
            action: 'update',
            contentType: 'package',
            content: 'zip, zsh, xterm'
        };

        spyOn(ContentHostBulkAction, 'updateContent');
        $scope.performContentAction();

        expect(ContentHostBulkAction.updateContent).toHaveBeenCalledWith(
            _.extend({}, selected, {
                content_type: $scope.content.contentType,
                content: $scope.content.content.split(/ *, */)
            }),
            jasmine.any(Function), jasmine.any(Function)
        );
    });

    it("can remove packages on multiple content hosts", function() {
        $scope.content = {
            action: 'remove',
            contentType: 'package',
            content: 'zip, zsh, xterm'
        };

        spyOn(ContentHostBulkAction, 'removeContent');
        $scope.performContentAction();

        expect(ContentHostBulkAction.removeContent).toHaveBeenCalledWith(
            _.extend({}, selected, {
                content_type: $scope.content.contentType,
                content: $scope.content.content.split(/ *, */)
            }),
            jasmine.any(Function), jasmine.any(Function)
        );
    });

    it("can install package groups on multiple content hosts", function() {
        $scope.content = {
            action: 'install',
            contentType: 'package_group',
            content: 'Backup Client, Development Tools'
        };

        spyOn(ContentHostBulkAction, 'installContent');
        $scope.performContentAction();

        expect(ContentHostBulkAction.installContent).toHaveBeenCalledWith(
            _.extend({}, selected, {
                content_type: $scope.content.contentType,
                content: $scope.content.content.split(/ *, */)
            }),
            jasmine.any(Function), jasmine.any(Function)
        );
    });

    it("can update package groups on multiple content hosts", function() {
        $scope.content = {
            action: 'update',
            contentType: 'package_group',
            content: 'Backup Client, Development Tools'
        };

        spyOn(ContentHostBulkAction, 'updateContent');
        $scope.performContentAction();

        expect(ContentHostBulkAction.updateContent).toHaveBeenCalledWith(
            _.extend({}, selected, {
                content_type: $scope.content.contentType,
                content: $scope.content.content.split(/ *, */)
            }),
            jasmine.any(Function), jasmine.any(Function)
        );
    });

    it("can remove package groups on multiple content hosts", function() {
        $scope.content = {
            action: 'remove',
            contentType: 'package_group',
            content: 'Backup Client, Development Tools'
        };

        spyOn(ContentHostBulkAction, 'removeContent');
        $scope.performContentAction();

        expect(ContentHostBulkAction.removeContent).toHaveBeenCalledWith(
            _.extend({}, selected, {
                content_type: $scope.content.contentType,
                content: $scope.content.content.split(/ *, */)
            }),
            jasmine.any(Function), jasmine.any(Function)
        );
    });


});
