describe('Controller: PackageFilterController', function() {
    var $scope, Rule, Package, Notification;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'))

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            Filter = $injector.get('MockResource').$new(),
            $q = $injector.get('$q');

        Rule = $injector.get('MockResource').$new();
        Package = $injector.get('MockResource').$new();

        Notification = {
            setSuccessMessage: function () {}
        };

        $scope = $injector.get('$rootScope').$new();
        $scope.$stateParams = {
            contentViewId: 1,
            filterId: 1
        };
        $scope.filter = Filter.get({id: 1});

        $scope.contentView = {'repository_ids': []};

        Package.autocompleteName = function () {
            return {
                $promise: $q.defer().promise
            };
        };

        Package.autocompleteArch = function () {
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
            Package: Package,
            Notification: Notification
        });

        $scope.table.getSelected = function () {};
    }));

    it("should provide a method to add a rule to the current filter", function() {
        $scope.addRule();
        expect($scope.table.rows.length).toBe(1);
    });

    describe("should provide a method to save a rule", function() {
        var rule;

        beforeEach(function () {
            rule = {
                name: 'Test',
                version: 1
            };

            spyOn(Notification, 'setSuccessMessage');
        });

        afterEach(function () {
            expect(Notification.setSuccessMessage).toHaveBeenCalled();
        });

        it("and create the rule if it's new", function () {
            spyOn(Rule, 'save').and.callThrough();
            $scope.saveRule(rule);
            expect(Rule.save).toHaveBeenCalled();
        });

        it("and update the rule if it exists", function () {
            rule.id = 1;
            spyOn(Rule, 'update').and.callThrough();
            $scope.saveRule(rule);
            expect(Rule.update).toHaveBeenCalled();
        });
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
            id: 1,
            name: 'current',
            type: 'all',
            version: '1',
            min_version: '2',
            max_version: '3'
        }, previousRule = {
            id: 1,
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

    it("should provide a method to delete a rule", function () {
        var selected = [{id: 1, selected: true}];
        spyOn($scope.table, 'getSelected').and.returnValue(selected);
        $scope.table.rows = [{id: 1, selected: true}, {id: 2, selected: false}];

        $scope.removeRules();
        expect($scope.table.rows.length).toBe(1);
        expect($scope.table.rows[0].id).toBe(2);
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

    it("should provide a method to retrieve autocomplete name results", function () {
        var autocomplete;

        spyOn(Package, 'autocompleteName').and.callThrough();
        autocomplete = $scope.fetchAutocompleteName('gir');

        expect(autocomplete.then).toBeDefined();
        expect(Package.autocompleteName).toHaveBeenCalled();
    });

    it("should provide a method to retrieve autocomplete arch results", function () {
        var autocomplete;

        spyOn(Package, 'autocompleteArch').and.callThrough();
        autocomplete = $scope.fetchAutocompleteArch('x86');

        expect(autocomplete.then).toBeDefined();
        expect(Package.autocompleteArch).toHaveBeenCalled();
    });

    it("should provide a method to filter repos by type", function() {
        var result;
        $scope.filter.repositories = [{id: 1, content_type: "yum"}, {id: 2, content_type: "yum"},
                                      {id: 3, content_type: "docker"}, {id: 4, content_type: "docker"}];

        result = $scope.filterRepositoriesByType();
        expect(result.length).toBe(2);
        expect(result[0].id).toBe(1);
        expect(result[1].id).toBe(2);
    });
});
