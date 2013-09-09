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

describe('Controller: SystemPackagesController', function() {
    var $scope, Nutupane, SystemTask, SystemPackage, mockSystem, mockTask, i18nFilter, System;

    beforeEach(module('Bastion.systems', 'Bastion.test-mocks'));

    beforeEach(function() {

        Nutupane = function() {
            this.table = {
                showColumns: function() {}
            };
            this.get = function() {};
        };
        System = {
            tasks: function() {return []}
        };
        SystemTask = {
            get: function(){},
            poll: function(task, returnFunction){}
        };
        SystemPackage = {
            get: function(){return []},
            remove: function(params, success){
                success(mockTask);
                return mockTask
            },
            install: function(){return mockTask},
            update: function(){return mockTask},
            updateAll: function(){return mockTask}
        };
        mockSystem = {
            uuid: 5
        };
        mockTask = {
            pending: true,
            id: 7
        };
        i18nFilter = function(){};

    });

    beforeEach(inject(function($controller, $rootScope) {
        $scope = $rootScope.$new();
        $scope.system = mockSystem;

        $controller('SystemPackagesController', {$scope: $scope,
                                               SystemPackage: SystemPackage,
                                               SystemTask: SystemTask,
                                               i18nFilter:i18nFilter,
                                               Nutupane: Nutupane});
    }));

    it("Sets a table.", function() {
        expect($scope.currentPackagesTable).toBeTruthy();
    });

    it("provides a way to open the event details panel.", function() {
        spyOn($scope, "transitionTo");
        $scope.currentPackagesTable.openEventInfo({ id: 2 });
        expect($scope.transitionTo).toHaveBeenCalledWith('systems.details.events.details', {eventId: 2});
    });

    it("defaults to package install", function(){
        expect($scope.packageAction.actionType).toBe('packageInstall');
    });

    it("properly recognizes a failed package remove task", function(){
        expect($scope.currentPackagesTable.taskFailed({failed: true})).toBe(true);
        expect($scope.currentPackagesTable.taskFailed({failed: false})).toBe(false);
        expect($scope.currentPackagesTable.taskFailed({failed: false, affected_units: 0})).toBe(true);
        expect($scope.currentPackagesTable.taskFailed({failed: false, affected_units: 1})).toBe(false);

    });

    it("performs a package update", function(){
        spyOn(SystemPackage, 'update');
        $scope.packageAction.actionType = "packageUpdate";
        $scope.packageAction.term = "foo";
        $scope.performPackageAction();
        expect(SystemPackage.update).toHaveBeenCalledWith({uuid: mockSystem.uuid, packages: ["foo"]},
                                                          jasmine.any(Function));
    });

    it("performs a package update with multiple packages", function(){
        spyOn(SystemPackage, 'update');
        $scope.packageAction.actionType = "packageUpdate";
        $scope.packageAction.term = "foo, bar";
        $scope.performPackageAction();
        expect(SystemPackage.update).toHaveBeenCalledWith({uuid: mockSystem.uuid, packages: ["foo", "bar"]},
                                                          jasmine.any(Function));
    });

    it("performs a package group install", function(){
        spyOn(SystemPackage, 'install');
        $scope.packageAction.actionType = "groupInstall";
        $scope.packageAction.term = "bigGroup";
        $scope.performPackageAction();
        expect(SystemPackage.install).toHaveBeenCalledWith({uuid: mockSystem.uuid, groups: ["bigGroup"]},
                                                          jasmine.any(Function));
    });

    it("performs a selected package removal", function(){
        var mockPackage, mockPackageClone
        mockPackage = {name: 'foo', version: '3', release: '14', arch: 'noarch'};
        mockPackageClone = {name: 'foo', version: '3', release: '14', arch: 'noarch'};

        spyOn(SystemPackage, 'remove').andCallThrough();
        spyOn(SystemTask, 'poll');
        $scope.currentPackagesTable.removePackage(mockPackage);
        expect(SystemPackage.remove).toHaveBeenCalledWith({uuid: mockSystem.uuid, packages: [mockPackageClone]},
                                                          jasmine.any(Function),
                                                          jasmine.any(Function));
        expect(SystemTask.poll).toHaveBeenCalledWith(mockTask, jasmine.any(Function));
    });

    it("provides a way to upgrade all packages", function() {
        spyOn(SystemPackage, "updateAll");
        $scope.updateAll();
        expect(SystemPackage.updateAll).toHaveBeenCalledWith({uuid: mockSystem.uuid}, jasmine.any(Function));
    });

});
