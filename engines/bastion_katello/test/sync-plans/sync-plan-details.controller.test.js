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

describe('Controller: SyncPlanDetailsController', function() {
    var $scope;

    beforeEach(module('Bastion.sync-plans', 'Bastion.test-mocks'))

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $state = $injector.get('$state'),
            SyncPlan = $injector.get('MockResource').$new();

        $scope = $injector.get('$rootScope').$new();

        $scope.$stateParams = {syncPlanId: 1};

        $controller('SyncPlanDetailsController', {
            $scope: $scope,
            $state: $state,
            SyncPlan: SyncPlan
        });
    }));

    it("gets the sync plan using the SyncPlan service and puts it on the $scope.", function() {
        expect($scope.syncPlan).toBeDefined();
    });

});
