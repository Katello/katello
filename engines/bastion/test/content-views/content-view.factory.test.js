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

describe('Factory: ContentView', function() {
    var $httpBackend,
        contentViews;

    beforeEach(module('Bastion.content-views', 'Bastion.utils'));

    beforeEach(module(function($provide) {
        contentViews = {
            results: [
                { name: 'ContentView1', id: 1 },
                { name: 'ContentView2', id: 2 }
            ],
            total: 10,
            subtotal: 5,
            limit: 5,
            offset: 0
        };

        $provide.value('CurrentOrganization', 'ACME');
    }));

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        ContentView = $injector.get('ContentView');
    }));

    afterEach(function() {
        $httpBackend.flush();
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('provides a way to get a collection of content views', function() {
        $httpBackend.expectGET('/api/v2/content_views?organization_id=ACME')
                    .respond(contentViews);

        ContentView.query(function (response) {
            var views = response;

            expect(views.results.length).toBe(2);
            expect(views.total).toBe(10);
            expect(views.subtotal).toBe(5);
            expect(views.offset).toBe(0);
        });
    });

    it('provides a way to get a single content view', function() {
        $httpBackend.expectGET('/api/v2/content_views/1?organization_id=ACME')
                    .respond(contentViews.results[0]);

        ContentView.get({id: 1}, function (contentView) {
            expect(contentView).toBeDefined();
            expect(contentView.name).toEqual('ContentView1');
        });
    });

    it('provides a way to create a content view', function() {
        var contentView = {id: 1, name: 'Content View'};

        $httpBackend.expectPOST('/api/v2/content_views/1?organization_id=ACME')
                    .respond(contentView);

        ContentView.save(contentView, function (contentView) {
            expect(contentView).toBeDefined();
            expect(contentView.name).toEqual('Content View');
        });
    });

    it('provides a way to update a content view', function() {
        $httpBackend.expectPUT('/api/v2/content_views/1?organization_id=ACME')
                    .respond(contentViews.results[0]);

        ContentView.update({id: 1, name: 'NewCVName'}, function (contentView) {;
            expect(contentView).toBeDefined();
        });
    });
});
