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

describe('Factory: Rule', function() {
    var $httpBackend,
        rules;

    beforeEach(module('Bastion.content-views', 'Bastion.utils'));

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
        $httpBackend.expectGET('/api/v2/filters/1/rules')
                    .respond(rules);

        Rule.query({filterId: 1}, function (response) {
            var views = response;

            expect(views.results.length).toBe(2);
            expect(views.total).toBe(10);
            expect(views.subtotal).toBe(5);
            expect(views.offset).toBe(0);
        });
    });

    it('provides a way to get a single filter rule', function() {
        $httpBackend.expectGET('/api/v2/filters/1/rules/1')
                    .respond(rules.results[0]);

        Rule.get({filterId: 1, ruleId: 1}, function (rule) {
            expect(rule).toBeDefined();
        });
    });

    it('provides a way to create a filter rule', function() {
        var rule = {id: 1, name: 'Rule'};

        $httpBackend.expectPOST('/api/v2/filters/1/rules/1')
                    .respond(rule);

        Rule.save({ruleId: 1, filterId: 1}, rule, function (rule) {
            expect(rule).toBeDefined();
        });
    });

    it('provides a way to update a filter rule', function() {
        $httpBackend.expectPUT('/api/v2/filters/1/rules/1')
                    .respond(rules.results[0]);

        Rule.update({filterId: 1, ruleId: 1}, {id: 1, name: 'New Rule Name'}, function (rule) {
            expect(rule).toBeDefined();
        });
    });

});
