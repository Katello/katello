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

        Package.autocompleteName = function () {
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

    it("should provide a method to backup a rule", function() {
        var rule = {
            name: 'test',
            type: 'all',
            version: '1',
            min_version: '2',
            max_version: '3'
        };

        $scope.backupPrevious(rule);

        expect(rule.previous.name).toBe(rule.name);
        expect(rule.previous.type).toBe(rule.type);
        expect(rule.previous.version).toBe(rule.version);
        expect(rule.previous.min_version).toBe(rule.min_version);
        expect(rule.previous.max_version).toBe(rule.max_version);
    });

    it("should provide a method to restore a rule", function() {
        var rule = {
            name: 'current',
            type: 'all',
            version: '1',
            min_version: '2',
            max_version: '3'
        }, previousRule = {
            name: 'previous',
            type: 'previous all',
            version: '10',
            min_version: '20',
            max_version: '30'
        };
        rule.previous = previousRule;

        $scope.restorePrevious(rule);

        expect(rule.name).toBe(previousRule.name);
        expect(rule.type).toBe(previousRule.type);
        expect(rule.version).toBe(previousRule.version);
        expect(rule.min_version).toBe(previousRule.min_version);
        expect(rule.max_version).toBe(previousRule.max_version);
        expect(Object.keys(rule.previous).length).toBe(0)
    });

    it("should provide a method to get selected rules", function () {
        $scope.filter.rules = [{id: 1, selected: true}, {id: 2, selected: false}];
        expect($scope.getSelectedRules($scope.filter).length).toBe(1);
        expect($scope.getSelectedRules($scope.filter)[0].id).toBe(1);
    });

    it("should provide a method to delete a rule", function () {
        $scope.filter.rules = [{id: 1, selected: true}, {id: 2, selected: false}];

        $scope.removeRules($scope.filter);
        expect($scope.filter.rules.length).toBe(1);
        expect($scope.filter.rules[0].id).toBe(2);
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

        spyOn(Package, 'autocompleteName').andCallThrough();
        autocomplete = $scope.fetchAutocomplete('gir');

        expect(autocomplete.then).toBeDefined();
        expect(Package.autocompleteName).toHaveBeenCalled();
    });

});
