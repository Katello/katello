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
 */
describe('Filter:availableForComposite', function() {
    var availableForCompositeFilter;

    beforeEach(module('Bastion.content-views'));

    beforeEach(inject(function($filter) {
        availableForCompositeFilter = $filter('availableForComposite');
    }));

    it("can filter out content views that already exist in the composite", function () {
        var contentViews = [{id: 1}, {id:2}],
            compositeView = {components: [{'content_view_id': 1}]},
            result = availableForCompositeFilter(contentViews, compositeView);
        expect(result.length).toBe(1);
        expect(result[0].id).toBe(2);
    });

    it("returns all contentViews if the composite does not have any components", function () {
        var contentViews = [{id: 1}, {id:2}],
            result = availableForCompositeFilter(contentViews, {components: []});
        expect(result.length).toBe(2);
        expect(result[0].id).toBe(1);
        expect(result[1].id).toBe(2);
    });

    it("provides defaults if no arguments are passed", function() {
        var result = availableForCompositeFilter();
        expect(result.length).toBe(0);
    });
});
