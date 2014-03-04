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

describe('Controller: PathController', function () {
    var $scope,
        gettext,
        FormUtils,
        Environment,
        environment;

    beforeEach(module('Bastion.environments', 'Bastion.test-mocks'));

    beforeEach(function () {
        Environment = {
            save: function() {},
            update: function () {},
            delete: function () {}
        };

        gettext = function() {};

        environment = {id: 1, name: 'env name', library: false};
    });

    beforeEach(inject(function ($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q'),
            $http = $injector.get('$http'),
            $timeout = $injector.get('$timeout'),
            FormUtils = $injector.get('FormUtils');

        $scope = $injector.get('$rootScope').$new();

        $scope.row = {
            showCreate: false,
            showEdit: false
        };

        $controller('PathController', {
            $scope: $scope,
            $q: $q,
            gettext: gettext,
            $timeout: $timeout,
            $http: $http,
            Environment: Environment,
            FormUtils: FormUtils
        });
    }));

    it('should support selecting a non-library environment', function () {
        spyOn($scope, 'close');

        $scope.selectEnvironment(environment);

        expect($scope.close).toHaveBeenCalled();
        expect($scope.workingOn.environment.id).toBe(1);
    });

    it('should not support selecting a library environment', function () {
        environment.library = true;
        spyOn($scope, 'close');

        $scope.selectEnvironment(environment);

        expect($scope.close).not.toHaveBeenCalled();
        expect($scope.workingOn.environment).toBe(undefined);
    });

    it('should reset scope attributes during close', function () {
        $scope.working = true;

        $scope.close();

        expect($scope.row.showCreate).toBe(false);
        expect($scope.row.showEdit).toBe(false);
        expect($scope.working).toBe(false);
        expect($scope.workingOn.environment).toBe(undefined);
    });

    it('should create an environment', function() {
        var env = {id: 1};

        $scope.row = {
            environments: [env]
        };

        spyOn(Environment, 'save');

        $scope.create(environment);

        expect(Environment.save).toHaveBeenCalledWith(environment, jasmine.any(Function),
            jasmine.any(Function));
    });

    it('should update an environment', function() {
        spyOn(Environment, 'update');

        $scope.update(environment);

        expect(Environment.update).toHaveBeenCalledWith(environment, jasmine.any(Function),
            jasmine.any(Function));
    });

    it('should remove an environment', function() {
        spyOn(Environment, 'delete');

        $scope.remove(environment);

        expect(Environment.delete).toHaveBeenCalledWith(environment, jasmine.any(Function),
            jasmine.any(Function));
    });

    it('should correctly determine if environment is last in the path', function() {
        var env1 = {id: 1}, env2 = {id: 2};

        $scope.row = {
            environments: [env1, env2]
        };

        expect($scope.isLastEnvironment(env1)).toBe(false);
        expect($scope.isLastEnvironment(env2)).toBe(true);
    });

    it('should support initializing a new environment', function () {
        expect($scope.row.showCreate).toBe(false);
        spyOn($scope, 'close');

        $scope.initiateCreateEnvironment();

        expect($scope.close).toHaveBeenCalled();
        expect($scope.row.showCreate).toBe(true);
    });

});
