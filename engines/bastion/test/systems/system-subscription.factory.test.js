/**
 * Copyright 2013 Red Hat, Inc.
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

describe('Factory: SystemSubscription', function() {
    var $httpBackend,
        subscription,
        SystemSubscription;

    beforeEach(module('Bastion.systems'));

    beforeEach(module(function($provide) {
        var routes;
        subscription = {id: 1};
        routes = {
            apiSystemsPath: function(){return '/api/systems'}
        };
        $provide.value('Routes', routes);
    }));

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        SystemSubscription = $injector.get('SystemSubscription');
    }));

    afterEach(function() {
        $httpBackend.flush();
    });

    it('provides a way to get a system subscription', function() {
        $httpBackend.expectGET('/api/systems/1/subscriptions/1').respond(subscription);
        SystemSubscription.get({ id: 1, systemId: 1}, function(results) {
            expect(results.id).toBe(subscription.id);
        });
    });

    it('provides a way to create a system subscription', function() {
        $httpBackend.expectPOST('/api/systems/1/subscriptions/1').respond(subscription);
        SystemSubscription.save({ id: 1, systemId: 1}, function(results) {
            expect(results.id).toBe(subscription.id);
        });
    });

    it('provides a way to remove a system subscription', function() {
        $httpBackend.expectDELETE('/api/systems/1/subscriptions/1').respond(subscription);
        SystemSubscription.remove({ id: 1, systemId: 1}, function(results) {
            expect(results.id).toBe(subscription.id);
        });
    });
});
