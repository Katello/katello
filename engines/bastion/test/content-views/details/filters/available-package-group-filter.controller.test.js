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

describe('Controller: AvailablePackageGroupFilterController', function() {
    var $scope, Rule;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'))

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            Filter = $injector.get('MockResource').$new(),
            gettext = $injector.get('gettextMock'),
            Nutupane = function() {
                this.table = {};
                this.getAllSelectedResults = function () {
                    return {included: {ids: ['packageGroup']}};
                };
                this.removeRow = function (item, field) {
                    return true;
                };
            };

        Rule = $injector.get('MockResource').$new();
        spyOn(Rule, 'save');

        $scope = $injector.get('$rootScope').$new();
        $scope.filter = Filter({id: 1});

        $controller('AvailablePackageGroupFilterController', {
            $scope: $scope,
            gettext: gettext,
            Nutupane: Nutupane,
            Filter: Filter,
            Rule: Rule
        });
    }));

    it("puts a table object on the scope", function() {
        expect($scope.detailsTable).toBeDefined();
    });

    it("should provide a method to add errata to the filter", function () {
        $scope.addPackageGroups($scope.filter);

        expect($scope.successMessages.length).toBe(1);
    });

});
