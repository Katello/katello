/**
 Copyright 2014 Red Hat, Inc.

 This software is licensed to you under the GNU General Public
 License as published by the Free Software Foundation; either version
 2 of the License (GPLv2) or (at your option) any later version.
 There is NO WARRANTY for this software, express or implied,
 including the implied warranties of MERCHANTABILITY,
 NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 have received a copy of GPLv2 along with this software; if not, see
 http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 **/

describe('Factory: ActivationKey', function() {
    beforeEach(module('Bastion.activation-keys'));

    beforeEach(function() {
        activationKeys = {
            "total":1,
            "subtotal":1,
            "page":"1",
            "per_page":20,
            "search":"",
            "sort":{"by":"name","order":"ASC"},
            "results":[{"id":1,"name":"actkey","label":"actkey","description":"actkey description",
                        "organization":{"name":"Mega Corporation","label":"megacorp"},
                        "created_at":"2014-02-04T17:52:21Z","updated_at":"2014-02-04T18:15:56Z",
                        "content_view":{"id":2,"name":"Default Organization View","label":"Default_Organization_View","description":null,"content_view_definition_id":null,"organization_id":3,"default":true,"created_at":"2014-02-04T12:17:49Z","updated_at":"2014-02-04T12:17:49Z","organization":"Mega Corporation","definition":null,"environments":["Library"],"versions":[1],"versions_details":[{"version":1,"published":"2014-02-04 12:17:50 UTC","environments":["Library"]}]},
                        "content_view_id":2,
                        "environment_id":2,
                        "usage_count":0,
                        "user_id":1,
                        "usage_limit":-1,
                        "permissions":{"editable":true},
                        "environment":{"id":2,"name":"Library","label":"Library","description":null,"organization":{"name":"Mega Corporation","label":"megacorp"},"created_at":"2014-02-04T12:17:49Z","updated_at":"2014-02-04T12:17:49Z","library":true,"prior":null}
                }]};
        });

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        ActivationKey = $injector.get('ActivationKey');
    }));

    afterEach(function() {
        $httpBackend.flush();
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('ActivationKey.get GET /api/v2/activation_keys/1?fields=full', function() {
        $httpBackend.expectGET('/api/v2/activation_keys/1?fields=full').respond(activationKeys.results[0]);

        ActivationKey.get({id: 1}, function(response) {
            expect(response.id).toBe(activationKeys.results[0].id);
        });
    });

    it('ActivationKey.query GET /api/v2/activation_keys', function() {
        $httpBackend.expectGET('/api/v2/activation_keys').respond(activationKeys);

        ActivationKey.query(function(response) {
            expect(response.results.length).toBe(activationKeys.results.length);

            for (var i = 0; i < activationKeys.results.length; i++) {
                expect(response.results[i].id).toBe(activationKeys.results[i].id);
            }
        });
    });

    it('ActivationKey.update PUT /api/v2/activation_keys/1', function() {
        $httpBackend.expectPUT('/api/v2/activation_keys/1').respond(activationKeys.results[0]);

        ActivationKey.update({id: 1}, function(response) {
            expect(response).toBeDefined();
        });
    });

    it('ActivationKey.copy POST /api/v2/activation_keys/1/copy', function() {
        $httpBackend.expectPOST('/api/v2/activation_keys/1/copy').respond(activationKeys.results[0]);

        ActivationKey.copy({id: 1}, function(response) {
            expect(response).toBeDefined();
        });
    });

    it('ActivationKey.available GET /api/v2/activation_keys/1/subscriptions/available', function() {
        $httpBackend.expectGET('/api/v2/activation_keys/1/subscriptions/available').respond(activationKeys.results[0]);

        ActivationKey.available({id: 1}, function(response) {
            expect(response).toBeDefined();
        });
    });

    it('ActivationKey.removeSubscriptions PUT /api/v2/activation_keys/1/subscriptions', function() {
        $httpBackend.expectPUT('/api/v2/activation_keys/1/subscriptions').respond(activationKeys.results[0]);

        ActivationKey.removeSubscriptions({id: 1}, function(response) {
            expect(response).toBeDefined();
        });
    });

    it('ActivationKey.addSubscriptions POST /api/v2/activation_keys/1/subscriptions', function() {
        $httpBackend.expectPOST('/api/v2/activation_keys/1/subscriptions').respond(activationKeys.results[0]);

        ActivationKey.addSubscriptions({id: 1}, function(response) {
            expect(response).toBeDefined();
        });
    });

});