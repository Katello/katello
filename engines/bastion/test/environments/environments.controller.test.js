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

describe('Controller: EnvironmentsController', function () {
    var $scope,
        Routes,
        Environment;

    beforeEach(module('Bastion.environments', 'Bastion.test-mocks'));

    beforeEach(function () {
        Routes = {
            apiOrganizationEnvironmentsPath: function (organizationId) {}
        };
        Environment = {};
    });

    beforeEach(inject(function ($injector) {
        var $controller = $injector.get('$controller'),
            $http = $injector.get('$http'),
            $timeout = $injector.get('$timeout');

        $scope = $injector.get('$rootScope').$new();

        $controller('EnvironmentsController', {
            $scope: $scope,
            $timeout: $timeout,
            $http: $http,
            Routes:Routes,
            Environment: Environment,
            CurrentOrganization: 'CurrentOrganization'
        });
    }));

    it('should support initializing a new path', function () {
        $scope.environmentsTable = {
            rows: [
                {
                    permissions: {readonly: false},
                    path: [
                        {environment: {id: 1}},
                        {environment: {id: 2}}
                    ]
                }
            ]
        };
        expect($scope.environmentsTable.rows.length).toBe(1);

        $scope.initiateCreatePath();
        expect($scope.environmentsTable.rows.length).toBe(2);
    });

    it('should correctly determine if the path is readonly', function () {
        $scope.environmentsTable = {rows: [{permissions: {readonly: false}}]};
        expect($scope.readonly()).toBe(false);

        $scope.environmentsTable = {rows: [{permissions: {readonly: true}}]};
        expect($scope.readonly()).toBe(true);
    });
});
