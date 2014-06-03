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

describe('Controller: PackageFilterController', function() {
    var $scope, Rule, Package;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'))

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            Filter = $injector.get('MockResource').$new(),
            $q = $injector.get('$q');

        Rule = $injector.get('MockResource').$new();
        Package = $injector.get('MockResource').$new();

        $scope = $injector.get('$rootScope').$new();
        $scope.$stateParams = {
            contentViewId: 1,
            filterId: 1
        };
        $scope.filter = Filter.get({id: 1});
        $scope.filter.rules = [];
        $scope.contentView = {'repository_ids': []};

        Package.autocomplete = function () {
            return {
                $promise: $q.defer().promise
            };
        };

        translate = function (string) {
            return string;
        };

        $controller('PackageFilterController', {
            $scope: $scope,
            translate: translate,
            Rule: Rule,
            Package: Package
        });
    }));

    it("should provide a method to add a rule to the current filter", function() {
        var rule = {
            name: 'Test',
            version: 1
        };

        $scope.addRule(rule, $scope.filter);

        expect($scope.rule.editMode).toBe(false);
        expect($scope.rule.working).toBe(false);
        expect($scope.successMessages.length).toBe(1);
        expect($scope.filter.rules.length).toBe(1);
    });

    it("should provide a method to update a rule", function() {
        var rule = {
            name: 'Test',
            version: 1
        };

        $scope.updateRule(rule, $scope.filter);

        expect(rule.editMode).toBe(false);
        expect(rule.working).toBe(false);
        expect($scope.successMessages.length).toBe(1);
    });

    it("should provide a method to clear a rule", function() {
        var rule = {
            name: 'test',
            min_version: '2',
            max_version: '3',
        };

        $scope.clearValues(rule);

        expect(rule.min_version).toBe(undefined);
        expect(rule.max_version).toBe(undefined);
    });

    it("should provide a method to determine if a rule is valid if no name is given", function() {
        var result,
            rule = {};

        result = $scope.valid(rule);
        expect(result).toBe(false);
    });

    it("should provide a method to determine if a rule is valid if no version and type is 'equal'", function() {
        var result,
            rule = {
                type: 'equal'
            };

        result = $scope.valid(rule);
        expect(result).toBe(false);
    });

    it("should provide a method to determine if a rule is valid if no max_version and type is 'less'", function() {
        var result,
            rule = {
                type: 'less'
            };

        result = $scope.valid(rule);
        expect(result).toBe(false);
    });

    it("should provide a method to determine if a rule is valid if no min_version and type is 'greater'", function() {
        var result,
            rule = {
                type: 'greater'
            };

        result = $scope.valid(rule);
        expect(result).toBe(false);
    });

    it("should provide a method to determine if a rule is valid if min_version but not max_version and type is 'range'", function() {
        var result,
            rule = {
                type: 'range',
                min_version: '2'
            };

        result = $scope.valid(rule);
        expect(result).toBe(false);
    });

    it("should provide a method to retrieve autocomplete results", function () {
        var autocomplete;

        spyOn(Package, 'autocomplete').andCallThrough();
        autocomplete = $scope.fetchAutocomplete('gir');

        expect(autocomplete.then).toBeDefined();
        expect(Package.autocomplete).toHaveBeenCalled();
    });

});
