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

describe('Controller: ContentHostErrataController', function() {
    var $scope, Nutupane, ContentHostErratum,
        mockContentHost, mockTask, mockErratum;

    beforeEach(module('Bastion.content-hosts', 'Bastion.test-mocks'));

    beforeEach(function() {
        mockErratum = {
            errata_id: "RHSA-1024"
        };
        mockContentHost = {
            uuid: 5
        };
        mockTask = {
            pending: true,
            id: 7
        };
        Nutupane = function() {
            this.table = {
                showColumns: function() {},
                getSelected: function() {return [mockErratum];},
                selectAll: function() {}
            };
            this.get = function() {};
        };
        ContentHostErratum = {
            get: function() {return []},
            apply: function(errata, success) {
                success(mockTask);
                return mockTask
            }
        };
    });

    beforeEach(inject(function($controller, $rootScope) {
        $scope = $rootScope.$new();
        $scope.contentHost = mockContentHost;

        $controller('ContentHostErrataController', {$scope: $scope,
                                               ContentHostErratum: ContentHostErratum,
                                               Nutupane: Nutupane});
    }));

    it("Sets a table.", function() {
        expect($scope.errataTable).toBeTruthy();
    });

    it("provide a way to apply errata", function() {
        spyOn(ContentHostErratum, "apply").andCallThrough();
        spyOn($scope.errataTable, "selectAll");
        spyOn($scope, "transitionTo");
        $scope.applySelected();
        expect(ContentHostErratum.apply).toHaveBeenCalledWith({uuid: mockContentHost.uuid, errata_ids: [mockErratum.errata_id]},
                                                         jasmine.any(Function));
        expect($scope.transitionTo).toHaveBeenCalledWith('content-hosts.details.tasks.details', {taskId: mockTask.id});
        expect($scope.errataTable.selectAll).toHaveBeenCalledWith(false);
    });
});
