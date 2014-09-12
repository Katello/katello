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

describe('Controller: AvailableErrataFilterController', function() {
    var $scope, Rule;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'))

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            Filter = $injector.get('MockResource').$new(),
            translate = $injector.get('translateMock'),
            Nutupane = function() {
                var params = {};

                this.table = {};
                this.getAllSelectedResults = function () {
                    return {included: {ids: [1]}};
                };
                this.removeRow = function (item, field) {
                    return true;
                };
                this.enableSelectAllResults = function () {};
                this.table.selectAllResults = function () {};
                this.refresh = function () {};
                this.addParam = function (key, value) {
                    params[key] = value;
                }
                this.getParam = function (key) {
                    return params[key];
                }
            };

        Rule = $injector.get('MockResource').$new();
        spyOn(Rule, 'save');

        $scope = $injector.get('$rootScope').$new();
        $scope.filter = Filter({id: 1});
        $scope.rule = {};

        $controller('AvailableErrataFilterController', {
            $scope: $scope,
            translate: translate,
            Nutupane: Nutupane,
            Filter: Filter,
            Rule: Rule
        });
    }));

    it("puts a table object on the scope", function() {
        expect($scope.detailsTable).toBeDefined();
    });

    it("should provide a method to add errata to the filter", function () {
        spyOn($scope.nutupane, 'refresh');
        spyOn($scope.nutupane.table, 'selectAllResults');
        $scope.addErrata($scope.filter);

        expect($scope.successMessages.length).toBe(1);
        expect($scope.nutupane.refresh).toHaveBeenCalled();
        expect($scope.nutupane.table.selectAllResults).toHaveBeenCalledWith(false);
    });

    it("should provide a method to update the errata based on type", function () {
        spyOn($scope.nutupane, 'refresh');
        $scope.updateTypes({'security': true, 'enhancement': false, 'bugfix': false});

        expect($scope.nutupane.getParam('types[]')).toContain('security');
        expect($scope.nutupane.getParam('types[]')).not.toContain('bugfix');
        expect($scope.nutupane.refresh).toHaveBeenCalled();
    });

    it("should update the errata by start date", function () {
        var date = new Date();
        spyOn($scope.nutupane, 'refresh');
        $scope.rule['start_date'] = date;
        $scope.$digest();

        expect($scope.nutupane.refresh).toHaveBeenCalled();
        expect($scope.nutupane.getParam('start_date')).toBe(date.toISOString().split('T')[0]);
    });

    it("should update the errata by end date", function () {
        var date = new Date();
        spyOn($scope.nutupane, 'refresh');
        $scope.rule['end_date'] = date;
        $scope.$digest();

        expect($scope.nutupane.refresh).toHaveBeenCalled();
        expect($scope.nutupane.getParam('end_date')).toBe(date.toISOString().split('T')[0]);
    });

});
