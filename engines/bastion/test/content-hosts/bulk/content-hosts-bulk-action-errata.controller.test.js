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

describe('Controller: ContentHostsBulkActionErrataController', function() {
    var $scope, $q, translate, ContentHostBulkAction, HostCollection, selectedErrata,
         selectedContentHosts, CurrentOrganization, Nutupane;

    beforeEach(module('Bastion.content-hosts', 'Bastion.test-mocks'));

    beforeEach(function() {
        ContentHostBulkAction = {
            installContent: function() {}
        };
        translate = function() {};
        CurrentOrganization = 'foo';
        selectedErrata = [1, 2, 3, 4]
        selectedContentHosts = {included: {ids: [1, 2, 3]}};
        Nutupane = function() {
            this.table = {
                showColumns: function () {},
                getSelected: function () {return selectedErrata}
            };

        };
    });

    beforeEach(inject(function($controller, $rootScope, $q) {
        $scope = $rootScope.$new();
        $scope.nutupane = {
            table: {
                rows: [{}],
                numSelected: 5
            }
        };
        $scope.nutupane.getAllSelectedResults = function () { return selectedContentHosts }
        $scope.setState = function(){};

        $scope.detailsTable = {
            rows: [],
            numSelected: 5
        };

        $scope.table = {
            rows: [{}],
            numSelected: 5
        };

        $controller('ContentHostsBulkActionErrataController', {$scope: $scope,
            $q: $q,
            ContentHostBulkAction: ContentHostBulkAction,
            HostCollection: HostCollection,
            Nutupane: Nutupane,
            translate: translate,
            CurrentOrganization: CurrentOrganization
        });
    }));

    it("can install errata on multiple content hosts", function () {

        spyOn(ContentHostBulkAction, 'installContent');
        $scope.installErrata();

        expect(ContentHostBulkAction.installContent).toHaveBeenCalledWith(
            _.extend(selectedContentHosts, {
                content_type: 'errata',
                content: [1, 2, 3]
            }),
            jasmine.any(Function), jasmine.any(Function)
        );
    });

    it("Should fetch new errata on initial load if there are initial items present", function () {
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
