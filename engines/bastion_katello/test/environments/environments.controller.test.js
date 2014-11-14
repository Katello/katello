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

describe('Controller: EnvironmentsController', function () {
    var $scope, paths;

    beforeEach(module('Bastion.environments', 'Bastion.test-mocks'));

    beforeEach(inject(function ($injector) {
        var $controller = $injector.get('$controller'),
            Organization = $injector.get('MockResource').$new();

        paths = [{environments:
            [{library: true, name: 'Library'}, {library: false, name: 'Dev'}]
        }];

        Organization.paths = function(params, callback) {
            callback(angular.copy(paths));
        };

        $scope = $injector.get('$rootScope').$new();

        $controller('EnvironmentsController', {
            $scope: $scope,
            Organization: Organization,
            CurrentOrganization: 'CurrentOrganization'
        });

    }));

    it('should fetch the paths for the current organization', function () {
        expect($scope.paths).toBeDefined();
    });

    it('should set the paths object without including library', function () {
        expect($scope.paths[0].environments.length).toBe(paths[0].environments.length - 1);
    });

    it('should set the Library object', function () {
        expect($scope.library).toBeDefined();
        expect($scope.library.name).toBe('Library');
    });

    it('should provide determining the last environment in a path', function () {
        var lastEnvironment = $scope.lastEnvironment(paths[0]);

        expect(lastEnvironment).toBe(paths[0].environments.pop());
    });
});
