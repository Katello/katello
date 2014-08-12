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

describe('Controller: ContentHostPackagesController', function() {
    var $scope, Nutupane, ContentHostPackage, mockContentHost, mockTask, translate, ContentHost;

    beforeEach(module('Bastion.content-hosts', 'Bastion.test-mocks'));

    beforeEach(function() {

        Nutupane = function() {
            this.table = {
                showColumns: function() {}
            };
            this.get = function() {};
            this.load = function() {};
        };
        ContentHost = {
            tasks: function() {return []}
        };
        ContentHostPackage = {
            get: function() {return []},
            remove: function(params, success) {
                success(mockTask);
                return mockTask
            },
            install: function() {return mockTask},
            update: function() {return mockTask},
            updateAll: function() {return mockTask}
        };
        mockContentHost = {
            uuid: 5
        };
        mockTask = {
            pending: true,
            id: 7
        };
        translate = function() {};

    });

    beforeEach(inject(function($controller, $rootScope) {
        $scope = $rootScope.$new();
        $scope.contentHost = mockContentHost;

        $controller('ContentHostPackagesController', {$scope: $scope,
                                               ContentHostPackage: ContentHostPackage,
                                               translate:translate,
                                               Nutupane: Nutupane});
    }));

    it("Sets a table.", function() {
        expect($scope.currentPackagesTable).toBeTruthy();
    });

    it("provides a way to open the event details panel.", function() {
        spyOn($scope, "transitionTo");
        $scope.currentPackagesTable.openEventInfo({ id: 2 });
        expect($scope.transitionTo).toHaveBeenCalledWith('content-hosts.details.events.details', {eventId: 2});
    });

    it("defaults to package install", function() {
        expect($scope.packageAction.actionType).toBe('packageInstall');
    });

    it("properly recognizes a failed package remove task", function() {
        expect($scope.currentPackagesTable.taskFailed({failed: true})).toBe(true);
        expect($scope.currentPackagesTable.taskFailed({failed: false})).toBe(false);
        expect($scope.currentPackagesTable.taskFailed({failed: false, affected_units: 0})).toBe(true);
        expect($scope.currentPackagesTable.taskFailed({failed: false, affected_units: 1})).toBe(false);
    });

    it("performs a package update", function() {
        spyOn(ContentHostPackage, 'update');
        $scope.packageAction.actionType = "packageUpdate";
        $scope.packageAction.term = "foo";
        $scope.performPackageAction();
        expect(ContentHostPackage.update).toHaveBeenCalledWith({uuid: mockContentHost.uuid, packages: ["foo"]},
                                                          jasmine.any(Function), jasmine.any(Function));
        expect($scope.working).toBe(true);
    });

    it("performs a package update with multiple packages", function() {
        spyOn(ContentHostPackage, 'update');
        $scope.packageAction.actionType = "packageUpdate";
        $scope.packageAction.term = "foo, bar";
        $scope.performPackageAction();
        expect(ContentHostPackage.update).toHaveBeenCalledWith({uuid: mockContentHost.uuid, packages: ["foo", "bar"]},
                                                          jasmine.any(Function), jasmine.any(Function));
        expect($scope.working).toBe(true);
    });

    it("performs a package group install", function() {
        spyOn(ContentHostPackage, 'install');
        $scope.packageAction.actionType = "groupInstall";
        $scope.packageAction.term = "bigGroup";
        $scope.performPackageAction();
        expect(ContentHostPackage.install).toHaveBeenCalledWith({uuid: mockContentHost.uuid, groups: ["bigGroup"]},
                                                          jasmine.any(Function), jasmine.any(Function));
        expect($scope.working).toBe(true);
    });

    it("performs a selected package removal", function() {
        var mockPackage, mockPackageClone
        mockPackage = {name: 'foo', version: '3', release: '14', arch: 'noarch'};
        mockPackageClone = {name: 'foo', version: '3', release: '14', arch: 'noarch'};

        spyOn(ContentHostPackage, 'remove');
        $scope.currentPackagesTable.removePackage(mockPackage);
        expect(ContentHostPackage.remove).toHaveBeenCalledWith({uuid: mockContentHost.uuid, packages: [mockPackageClone]},
                                                          jasmine.any(Function), jasmine.any(Function));
        expect($scope.working).toBe(true);
    });

    it("provides a way to upgrade all packages", function() {
        spyOn(ContentHostPackage, "updateAll");
        $scope.updateAll();
        expect(ContentHostPackage.updateAll).toHaveBeenCalledWith({uuid: mockContentHost.uuid}, jasmine.any(Function),
            jasmine.any(Function));
        expect($scope.working).toBe(true);
    });

    it("sets the default number of packages limit to 20", function() {
        expect($scope.currentPackagesTable.limit).toBe(50);
    });

    it("provides a way to load more packages", function() {
        expect($scope.currentPackagesTable.limit).toBe(50);

        $scope.currentPackagesTable.loadMorePackages();
        $scope.$digest();

        expect($scope.currentPackagesTable.limit).toBe(100);
    })
});
