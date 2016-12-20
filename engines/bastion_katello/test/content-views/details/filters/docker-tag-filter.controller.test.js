describe('Controller: DockerTagFilterController', function() {
    var $scope, Rule, DockerTag, GlobalNotification;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'))

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            Filter = $injector.get('MockResource').$new(),
            $q = $injector.get('$q');

        Rule = $injector.get('MockResource').$new();
        DockerTag = $injector.get('MockResource').$new();

        GlobalNotification = {
            setSuccessMessage: function () {}
        };

        $scope = $injector.get('$rootScope').$new();
        $scope.$stateParams = {
            contentViewId: 1,
            filterId: 1
        };
        $scope.filter = Filter.get({id: 1});
        $scope.filter.rules = [];
        $scope.contentView = {'repository_ids': []};

        DockerTag.autocompleteName = function () {
            return {
                $promise: $q.defer().promise
            };
        };

        translate = function (string) {
            return string;
        };

        $controller('DockerTagFilterController', {
            $scope: $scope,
            translate: translate,
            Rule: Rule,
            DockerTag: DockerTag,
            GlobalNotification: GlobalNotification
        });
    }));

    it("should provide a method to add a rule to the current filter", function() {
        var rule = {
            name: 'Test',
            version: 1
        };

        spyOn(GlobalNotification, 'setSuccessMessage');

        $scope.addRule(rule, $scope.filter);

        expect($scope.rule.editMode).toBe(false);
        expect($scope.rule.working).toBe(false);
        expect(GlobalNotification.setSuccessMessage).toHaveBeenCalled();
        expect($scope.filter.rules.length).toBe(1);
    });

    it("should provide a method to update a rule", function() {
        var rule = {
            name: 'Test',
            version: 1
        };

        spyOn(GlobalNotification, 'setSuccessMessage');

        $scope.updateRule(rule, $scope.filter);

        expect(rule.editMode).toBe(false);
        expect(rule.working).toBe(false);
        expect(GlobalNotification.setSuccessMessage).toHaveBeenCalled();
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

    it("should provide a method to retrieve autocomplete name results", function () {
        var autocomplete;

        spyOn(DockerTag, 'autocompleteName').and.callThrough();
        autocomplete = $scope.fetchAutocompleteName('gir');

        expect(autocomplete.then).toBeDefined();
        expect(DockerTag.autocompleteName).toHaveBeenCalled();
    });

    it("should provide a method to filter repos by type", function() {
        var result;
        $scope.filter.repositories = [{id: 1, content_type: "yum"}, {id: 2, content_type: "yum"},
                                      {id: 3, content_type: "docker"}, {id: 4, content_type: "docker"}];

        result = $scope.filterRepositoriesByType();
        expect(result.length).toBe(2);
        expect(result[0].id).toBe(3);
        expect(result[1].id).toBe(4);
    });
});
