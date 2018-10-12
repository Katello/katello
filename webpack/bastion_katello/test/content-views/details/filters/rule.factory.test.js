describe('Factory: Rule', function() {
    var $httpBackend,
        rules;

    beforeEach(module('Bastion.content-views', 'Bastion.utils', 'Bastion.test-mocks'));

    beforeEach(module(function($provide) {
        rules = {
            results: [
                { name: 'Rule1', id: 1 },
                { name: 'Rule2', id: 2 }
            ],
            total: 10,
            subtotal: 5,
            limit: 5,
            offset: 0
        };
    }));

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        Rule = $injector.get('Rule');
    }));

    afterEach(function() {
        $httpBackend.flush();
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('provides a way to get a collection of rules', function() {
        $httpBackend.expectGET('katello/api/v2/content_view_filters/1/rules?full_result=true')
                    .respond(rules);

        Rule.queryUnpaged({filterId: 1}, function (response) {
            var views = response;

            expect(views.results.length).toBe(2);
            expect(views.total).toBe(10);
            expect(views.subtotal).toBe(5);
            expect(views.offset).toBe(0);
        });
    });

    it('provides a way to get a single filter rule', function() {
        $httpBackend.expectGET('katello/api/v2/content_view_filters/1/rules/1')
                    .respond(rules.results[0]);

        Rule.get({filterId: 1, ruleId: 1}, function (rule) {
            expect(rule).toBeDefined();
        });
    });

    it('provides a way to create a filter rule', function() {
        var rule = {id: 1, name: 'Rule'};

        $httpBackend.expectPOST('katello/api/v2/content_view_filters/1/rules/1')
                    .respond(rule);

        Rule.save({ruleId: 1, filterId: 1}, rule, function (rule) {
            expect(rule).toBeDefined();
        });
    });

    it('provides a way to update a filter rule', function() {
        $httpBackend.expectPUT('katello/api/v2/content_view_filters/1/rules/1')
                    .respond(rules.results[0]);

        Rule.update({filterId: 1, ruleId: 1}, {id: 1, name: 'New Rule Name'}, function (rule) {
            expect(rule).toBeDefined();
        });
    });

});
