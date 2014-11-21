/**
 * Copyright 2014 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either environment
 * 2 of the License (GPLv2) or (at your option) any later environment.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 **/

describe('Controller: EnvrionmentController', function () {
    var $scope;

    beforeEach(module('Bastion.environments', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            Envrionment = $injector.get('MockResource').$new(),
            translate = $injector.get('translateMock');

        $scope = $injector.get('$rootScope').$new();
        $scope.$stateParams = {environmentId: 1};

        $controller('EnvironmentController', {
            $scope: $scope,
            Envrionment: Envrionment,
            translate: translate
        });
    }));

    it("puts an environment on the scope", function() {
        expect($scope.environment).toBeDefined();
    });

    it("should provide ability to save an environment and return a promise", function() {
        spyOn($scope.environment, '$update').andCallThrough();

        expect($scope.save($scope.environment).then).toBeDefined();
        expect($scope.environment.$update).toHaveBeenCalled();
    });

    it("should provide ability to remove an environment and return a promise", function() {
        spyOn($scope.environment, '$delete').andCallThrough();

        expect($scope.remove($scope.environment).then).toBeDefined();
        expect($scope.environment.$delete).toHaveBeenCalled();
    });

});
