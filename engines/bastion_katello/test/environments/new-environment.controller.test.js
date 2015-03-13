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

describe('Controller: NewEnvironmentController', function() {
    var $scope,
        FormUtils,
        Environment;

    beforeEach(module('Bastion.environments', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var dependencies,
            $controller = $injector.get('$controller');

        Environment = $injector.get('MockResource').$new();
        $scope = $injector.get('$rootScope').$new();

        FormUtils = {
            labelize: function () {}
        };

        $scope.environmentForm = $injector.get('MockForm');
        $scope.$stateParams.priorId = 1;

        dependencies = {
            $scope: $scope,
            Environment: Environment,
            FormUtils: FormUtils,
        };

        $controller('NewEnvironmentController', dependencies);
    }));

    it('should attach a new content view resource on to the scope', function() {
        expect($scope.environment).toBeDefined();
    });

    it('should fetch and attach the prior environment to the scope', function() {
        expect($scope.priorEnvironment).toBeDefined();
    });

    it('should save a new content view resource', function() {
        var environment = $scope.environment;

        spyOn($scope, 'transitionTo');
        spyOn(environment, '$save').andCallThrough();
        $scope.save(environment);

        expect(environment.$save).toHaveBeenCalled();
        expect(environment['prior_id']).toBe(1);
        expect($scope.transitionTo).toHaveBeenCalledWith('environments.index');
    });

    it('should fetch a label whenever the name changes', function() {
        spyOn(FormUtils, 'labelize');

        $scope.environment.name = 'ChangedName';
        $scope.$apply();

        expect(FormUtils.labelize).toHaveBeenCalled();
    });
});

