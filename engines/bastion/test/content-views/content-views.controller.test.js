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

describe('Controller: ContentViewsController', function() {
    var $scope,
        ContentView,
        Nutupane;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'));

    beforeEach(function() {
        Nutupane = function() {
            this.table = {
                showColumns: function() {}
            };
            this.removeRow = function() {};
            this.get = function() {};
            this.enableSelectAllResults = function() {}
        };
        ContentView = {};
    });

    beforeEach(inject(function($injector) {
        $scope = $injector.get('$rootScope').$new();
        var $controller = $injector.get('$controller');

        $controller('ContentViewsController', {
            $scope: $scope,
            Nutupane: Nutupane,
            ContentView: ContentView,
            CurrentOrganization: 'CurrentOrganization'
        });
    }));

    it("puts a table object on the scope", function() {
        expect($scope.table).toBeDefined();
    });

});

