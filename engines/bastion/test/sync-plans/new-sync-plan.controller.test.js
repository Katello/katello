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

describe('Controller: NewSyncPlanController', function() {
    var $scope, translate, SyncPlan;

    beforeEach(module(
        'Bastion.sync-plans',
        'Bastion.test-mocks'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller');

        SyncPlan = $injector.get('MockResource').$new()
        $scope = $injector.get('$rootScope').$new();
        $scope.transitionBack = function () {};
        $scope.product = {};

        translate = function (string) { return string; };

        $controller('NewSyncPlanController', {
            $scope: $scope,
            translate: translate,
            SyncPlan: SyncPlan
        });

    }));

    it('should attach a sync plan resource on to the scope', function() {
        expect($scope.syncPlan).toBeDefined();
    });

    it('should save a new sync plan resource', function() {
        var syncPlan = {startDate: '11/17/1982', endDate: '14:40'};
        syncPlan.$save = new SyncPlan().$save;

        spyOn($scope, 'transitionBack');
        spyOn(syncPlan, '$save').andCallThrough();

        $scope.createSyncPlan(syncPlan);

        expect($scope.working).toBe(false);
        expect($scope.successMessages.length).toBe(1);
        expect($scope.transitionBack).toHaveBeenCalled();
    });
});
