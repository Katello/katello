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

describe('Controller: ErrataFilterController', function() {
    var $scope, Filter;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'))

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller');

        $scope = $injector.get('$rootScope').$new();

        $controller('ErrataFilterController', {
            $scope: $scope
        });
    }));

    it("adds an empty rule to the scope", function() {
        expect($scope.rule).toBeDefined();
    });

    it("adds a date object to control date picker to the scope", function() {
        expect($scope.date).toBeDefined();
        expect($scope.date.startOpen).toBe(false);
        expect($scope.date.endOpen).toBe(false);
    });

    it("adds types to the scope", function() {
        expect($scope.types).toBeDefined();
        expect($scope.types.enhancement).toBe(true);
        expect($scope.types.bugfix).toBe(true);
        expect($scope.types.security).toBe(true);
    });

    it("adds a method to open the start date picker", function() {
        $scope.openStartDate({preventDefault: function () {}, stopPropagation: function () {}});

        expect($scope.date.startOpen).toBe(true);
        expect($scope.date.endOpen).toBe(false);
    });

    it("adds a method to open the end date picker", function() {
        $scope.openEndDate({preventDefault: function () {}, stopPropagation: function () {}});

        expect($scope.date.startOpen).toBe(false);
        expect($scope.date.endOpen).toBe(true);
    });

    it("should provide a method to filter errata by type", function () {
        var errata = {
            type: 'security'
        };

        expect($scope.errataFilter(errata)).toBe(true);

        $scope.types = ['bugfix'];
        expect($scope.errataFilter(errata)).toBe(false);
    });

    it("should provider a method to filter errata that were issued after a particular date", function () {
        var errata = {
            type: 'security',
            issued: new Date('1/1/2012')
        };

        $scope.rule['start_date'] = new Date('1/1/2012');
        expect($scope.errataFilter(errata)).toBe(true);

        $scope.rule['start_date'] = new Date('1/2/2012');
        expect($scope.errataFilter(errata)).toBe(false);
    });

    it("should provider a method to filter errata that were issued before a particular date", function () {
        var errata = {
            type: 'security',
            issued: new Date('1/2/2012')
        };

        $scope.rule['end_date'] = new Date('1/1/2012');
        expect($scope.errataFilter(errata)).toBe(false);

        $scope.rule['end_date'] = new Date('1/3/2012');
        expect($scope.errataFilter(errata)).toBe(true);
    });

});
