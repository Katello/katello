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

describe('Controller: SystemsBulkActionErrataController', function() {
    var $scope, $q, gettext, SystemBulkAction, SystemGroup, selectedErrata,
         selectedSystems, CurrentOrganization, Nutupane;

    beforeEach(module('Bastion.systems', 'Bastion.test-mocks'));

    beforeEach(function() {
        SystemBulkAction = {
            installContent: function() {}
        };
        gettext = function() {};
        CurrentOrganization = 'foo';
        selectedErrata = [1, 2, 3, 4]
        selectedSystems = {included: {ids: [1, 2, 3]}};
        Nutupane = function() {
            this.table = {
                showColumns: function () {},
                getSelected: function () {return selectedErrata}
            };

        };
    });

    beforeEach(inject(function($controller, $rootScope, $q) {
        $scope = $rootScope.$new();
        $scope.nutupane = {};
        $scope.nutupane.getAllSelectedResults = function () { return selectedSystems }
        $scope.setState = function(){};

        $scope.detailsTable = {};

        $scope.table = {
            rows: [],
            numSelected: 5
        };

        $controller('SystemsBulkActionErrataController', {$scope: $scope,
            $q: $q,
            SystemBulkAction: SystemBulkAction,
            SystemGroup: SystemGroup,
            Nutupane: Nutupane,
            gettext: gettext,
            CurrentOrganization: CurrentOrganization
      	});
    }));

    it("can install errata on multiple systems", function () {

        spyOn(SystemBulkAction, 'installContent');
        $scope.installErrata();

        expect(SystemBulkAction.installContent).toHaveBeenCalledWith(
            _.extend(selectedSystems, {
                content_type: 'errata',
                content: [1, 2, 3]
            }),
            jasmine.any(Function), jasmine.any(Function)
        );
    });

    it("Should fetch new errata on initial load", function () {
        $scope.initialLoad = true;
        spyOn($scope, 'fetchErrata');
        $scope.$apply();
        expect($scope.fetchErrata).toHaveBeenCalled();
    });

    it("watches for table row changes", function () {
        $scope.outOfDate = false;
        $scope.initialLoad = false;
        $scope.table.numSelected = $scope.table.numSelected + 1;
        $scope.$apply();
        expect($scope.outOfDate).toBe(true);
    })

});
