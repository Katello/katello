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

describe('Factory: Subscription', function() {
    var $httpBackend,
        Subscription,
        subscription,
        subscriptions;

    beforeEach(module('Bastion.subscriptions', 'Bastion.test-mocks'));

    beforeEach(module(function($provide) {
        subscriptions = {
            results: [
                { name: 'subscription1', id: 1 },
                { name: 'subscription2', id: 2 }
            ],
            total: 3,
            subtotal: 2
        };
        subscription = _.first(subscriptions.results);

        $provide.value('CurrentOrganization', 'ACME');
    }));

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        Subscription = $injector.get('Subscription');
    }));

    afterEach(function() {
        $httpBackend.flush();
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('provides a way to get a list of subscriptions', function() {
        $httpBackend.expectGET('/api/v2/organizations/ACME/subscriptions').respond(subscriptions);

        Subscription.queryPaged(function(subscriptions) {
            expect(subscriptions.results.length).toBe(2);
        });
    });

    it('provides a way to get a subscription', function() {
        $httpBackend.expectGET('/api/v2/organizations/ACME/subscriptions/1').respond(subscription);
        Subscription.get({ id: 1 }, function(results) {
            expect(results.id).toBe(subscription.id);
        });
    });

});
