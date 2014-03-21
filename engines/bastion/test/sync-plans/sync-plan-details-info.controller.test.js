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

describe('Controller: SyncPlanDetailsInfoController', function() {
    var $scope, gettext, MenuExpander;

    beforeEach(module('Bastion.sync-plans', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q'),
            SyncPlan = $injector.get('MockResource').$new();

        $scope = $injector.get('$rootScope').$new();
        $scope.$stateParams = {syncPlanId: 1};

        MenuExpander = {};

        gettext = function(message) {
            return message;
        };

        $controller('SyncPlanDetailsInfoController', {
            $scope: $scope,
            $q: $q,
            gettext: gettext,
            SyncPlan: SyncPlan,
            MenuExpander: MenuExpander
        });
    }));

    it("sets the menu expander on the scope", function() {
        expect($scope.menuExpander).toBe(MenuExpander);
    });

    it('should save the sync plan and return a promise', function() {
        var promise = $scope.save($scope.syncPlan);

        expect(promise.then).toBeDefined();
    });

    it('should save the sync plan successfully', function() {
        $scope.save($scope.syncPlan);

        expect($scope.successMessages.length).toBe(1);
        expect($scope.errorMessages.length).toBe(0);
    });

    it('should fail to save the product', function() {
        $scope.syncPlan.failed = true;

        $scope.save($scope.syncPlan);

        expect($scope.successMessages.length).toBe(0);
        expect($scope.errorMessages.length).toBe(1);
    });
});
