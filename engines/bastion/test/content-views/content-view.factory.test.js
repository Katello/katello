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

describe('Factory: ContentView', function() {
    var $resource,
        Routes,
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

        Routes = {
            apiOrganizationContentViewsPath: function(organizationId) {}
        };

        $resource = function() {
            this.get = function(id) {
                return contentViews.results[0];
            };
            this.update = function(data) {
                contentViews.results[0] = data;
                return contentViews.results[0];
            };
            this.query = function() {
                return contentViews;
            };

            return this;
        };

        $provide.value('$resource', $resource);
        $provide.value('Routes', Routes);
        $provide.value('CurrentOrganization', 'ACME');
    }));

    beforeEach(inject(function(_ContentView_) {
        ContentView = _ContentView_;
    }));

    it('provides a way to get a collection of content views', function() {
        var views = ContentView.query();

        expect(views.results.length).toBe(2);
        expect(views.total).toBe(10);
        expect(views.subtotal).toBe(5);
        expect(views.offset).toBe(0);
    });

    it('provides a way to get a single content view', function() {
        var view = ContentView.get({ id: 1 });

        expect(view).toBeDefined();
        expect(view.name).toEqual('ContentView1');
    });

    it('provides a way to update a content view', function() {
        var view = ContentView.update({ id: 1, name: 'NewCVName' });

        expect(view).toBeDefined();
        expect(view.name).toEqual('NewCVName');
    });
});

