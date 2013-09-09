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

describe('Controller: SystemErrataController', function() {
    var $scope, Nutupane, SystemTask, SystemErratum,
        mockSystem, mockTask, mockErratum;

    beforeEach(module('Bastion.systems', 'Bastion.test-mocks'));

    beforeEach(function() {
        mockErratum = {
            errata_id: "RHSA-1024"
        };
        mockSystem = {
            uuid: 5
        };
        mockTask = {
            pending: true,
            id: 7
        };
        Nutupane = function() {
            this.table = {
                showColumns: function() {},
                getSelected: function(){return [mockErratum];},
                selectAll: function(){}
            };
            this.get = function() {};
        };
        SystemTask = {
            get: function(){},
            poll: function(task, returnFunction){}
        };
        SystemErratum = {
            get: function(){return []},
            apply: function(errata, success){
                success(mockTask);
                return mockTask
            }
        };
    });

    beforeEach(inject(function($controller, $rootScope) {
        $scope = $rootScope.$new();
        $scope.system = mockSystem;

        $controller('SystemErrataController', {$scope: $scope,
                                               SystemErratum: SystemErratum,
                                               SystemTask: SystemTask,
                                               Nutupane: Nutupane});
    }));

    it("Sets a table.", function() {
        expect($scope.errataTable).toBeTruthy();
    });

    it("provides a way to open the errata details panel.", function() {
        spyOn($scope, "transitionTo");
        $scope.errataTable.transitionToErratum(mockErratum);
        expect($scope.erratum).toBeTruthy();
        expect($scope.transitionTo).toHaveBeenCalledWith('systems.details.errata.details',
                                                         {errataId: mockErratum.errata_id});
    });

    it("provides a way to open event details.", function() {
        spyOn($scope, "transitionTo");
        $scope.openEventInfo(mockTask);
        expect($scope.transitionTo).toHaveBeenCalledWith('systems.details.events.details',
                                                         {eventId: mockTask.id});
    });

    it("provide a way to apply errata", function(){
        spyOn(SystemErratum, "apply").andCallThrough();
        spyOn($scope.errataTable, "selectAll");
        spyOn($scope, "openEventInfo");
        $scope.applySelected();
        expect(SystemErratum.apply).toHaveBeenCalledWith({uuid: mockSystem.uuid, errata_ids: [mockErratum.errata_id]},
                                                         jasmine.any(Function));
        expect($scope.openEventInfo).toHaveBeenCalledWith(mockTask);
        expect($scope.errataTable.selectAll).toHaveBeenCalledWith(false);
    });
});
