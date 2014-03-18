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

describe('Controller: ContentViewCompositeContentViewsListController', function() {
    var $scope;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks', 'gettext'))

    beforeEach(inject(function($injector) {
        var Nutupane,
            $controller = $injector.get('$controller'),
            ContentView = $injector.get('MockResource').$new();

        Nutupane = function () {
            this.getAllSelectedResults = function () {
                return {included: {ids: [1, 2]}};
            };

            this.table = {};
        };

        $scope = $injector.get('$rootScope').$new();
        $scope.contentView = ContentView.get({id: 1});
        $scope.contentView['component_ids'] = [1, 2, 3];
        $scope.contentView.components = [
            {
                id: 2,
                content_view_id: 25
            }
        ];

        $scope.save = function () {
            return {
                then: function () {}
            };
        };

        spyOn($scope, 'save').andCallThrough();

        $controller('ContentViewCompositeContentViewsListController', {
            $scope: $scope,
            Nutupane: Nutupane,
            CurrentOrganization: 'ACME_Corporation',
            ContentView: ContentView
        });
    }));

    it("puts a content view version table on the scope", function() {
        expect($scope.detailsTable).toBeDefined();
    });

    it("provides a way to update the content view's version", function () {
        var newContentViewVersion = {'content_view_id': 25, id: 4};

        $scope.saveContentViewVersion(newContentViewVersion);

        expect($scope.save).toHaveBeenCalled();
        expect($scope.contentView['component_ids'].length).toBe(3);
        expect($scope.contentView['component_ids'].indexOf(4)).toBe(2);
    });

    it('provides a method to remove content views from a composite content view', function() {
        $scope.removeContentViews();

        expect($scope.save).toHaveBeenCalled();
        expect($scope.contentView['component_ids'].length).toBe(1);
        expect($scope.contentView['component_ids'][0]).toBe(3);
    });
});
