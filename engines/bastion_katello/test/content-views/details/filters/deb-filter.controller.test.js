describe('Controller: DebFilterController', function() {
    var $scope, Rule, Deb, Notification, $uibModal;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'))

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            Filter = $injector.get('MockResource').$new(),
            $q = $injector.get('$q');

        Rule = $injector.get('MockResource').$new();

        Rule.matchingContent = function() {
          return {
            $promise: $q.defer().promise,
          }
        };

        Deb = $injector.get('MockResource').$new();

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

        Deb.autocompleteName = function () {
            return {
                $promise: $q.defer().promise
            };
        };

        Deb.autocompleteArch = function () {
            return {
                $promise: $q.defer().promise
            };
        };

        translate = function (string) {
            return string;
        };

        $uibModal = {
            open: function () {
                return {
                    closed: {
                        then: function () {}
                    }
                }
            }
        };

        $controller('DebFilterController', {
            $scope: $scope,
            translate: translate,
            Rule: Rule,
            Deb: Deb,
            Notification: Notification,
            $uibModal: $uibModal
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


    it("should provide a method to backup a rule", function() {
        var rule = {
            name: 'test',
            type: 'all'
        };

        $scope.backupPrevious(rule);

        expect(rule.previous.name).toBe(rule.name);
        expect(rule.previous.type).toBe(rule.type);
    });

    it("should provide a method to restore a rule", function() {
        var rule = {
            id: 1,
            name: 'current',
            type: 'all'
        }, previousRule = {
            id: 1,
            name: 'previous',
            type: 'previous all'
        };
        rule.previous = previousRule;

        $scope.restorePrevious(rule);

        expect(rule.name).toBe(previousRule.name);
        expect(rule.type).toBe(previousRule.type);
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

    it("should provide a method to retrieve autocomplete name results", function () {
        var autocomplete;

        spyOn(Deb, 'autocompleteName').and.callThrough();
        autocomplete = $scope.fetchAutocompleteName('gir');

        expect(autocomplete.then).toBeDefined();
        expect(Deb.autocompleteName).toHaveBeenCalled();
    });

    it("should provide a method to retrieve autocomplete arch results", function () {
        var autocomplete;

        spyOn(Deb, 'autocompleteArch').and.callThrough();
        autocomplete = $scope.fetchAutocompleteArch('x86');

        expect(autocomplete.then).toBeDefined();
        expect(Deb.autocompleteArch).toHaveBeenCalled();
    });

    it("should provide a method to filter repos by type", function() {
        var result;
        $scope.filter.repositories = [{id: 1, content_type: "yum"}, {id: 2, content_type: "yum"},
                                      {id: 3, content_type: "docker"}, {id: 4, content_type: "docker"},
                                      {id: 5, content_type: "deb"}, {id: 6, content_type: "deb"}];

        result = $scope.filterRepositoriesByType();
        expect(result.length).toBe(2);
        expect(result[0].id).toBe(5);
        expect(result[1].id).toBe(6);
    });

    it("can show matching content", function () {
        var result, rule;
        spyOn($uibModal, 'open').and.callThrough();
        rule = {};

        $scope.getMatchingContent(rule);

        result = $uibModal.open.calls.argsFor(0)[0];

        expect(result.templateUrl).toContain('content-views/details/filters/views/filter-rule-matching-deb-modal.html');
        expect(result.controller).toBe('FilterRuleMatchingDebModal');
    });
});
