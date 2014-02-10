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

describe('Controller: ContentViewAvailableRepositoriesController', function() {
    var $scope;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks', 'gettext'))

    beforeEach(inject(function($injector) {
        var Nutupane,
            $controller = $injector.get('$controller'),
            ContentViewRepositoriesUtil = $injector.get('ContentViewRepositoriesUtil'),
            Repository = $injector.get('MockResource').$new();

        Nutupane = function () {
            this.getAllSelectedResults = function () {
                return {included: {ids: [1, 2]}};
            };

            this.table = {};
        };

        $scope = $injector.get('$rootScope').$new();
        $scope.contentView = ContentView.get({id: 1});
        $scope.contentView['repository_ids'] = [];
        $scope.save = function () {
            return {
                then: function () {}
            };
        };

        spyOn($scope, 'save').andCallThrough();

        $controller('ContentViewAvailableRepositoriesController', {
            $scope: $scope,
            Repository: Repository,
            Nutupane: Nutupane,
            CurrentOrganization: 'ACME_Corporation',
            ContentViewRepositoriesUtil: ContentViewRepositoriesUtil
        });
    }));

    it("puts a repositories table on the scope", function() {
        expect($scope.repositoriesTable).toBeDefined();
    });

    it('provides a method to add repositories to a content view', function() {
        $scope.addRepositories($scope.contentView);

        expect($scope.save).toHaveBeenCalled();
        expect($scope.contentView['repository_ids'].length).toBe(2);
    });

});
