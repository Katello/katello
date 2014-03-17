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

describe('Controller: ContentViewVersionsController', function() {
    var $scope, versions, AggregateTask;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var gettext = function() {},
            $controller = $injector.get('$controller');

        $scope = $injector.get('$rootScope').$new();

        $scope.contentView = ContentView.get({id: 1});

        $scope.reloadVersions = function () {};

        spyOn($scope, 'reloadVersions');

        $controller('ContentViewVersionsController', {
            $scope: $scope,
            gettext: gettext
        });
    }));

    it("puts an empty table object on the scope", function() {
        expect($scope.table).toBeDefined();
    });

});
