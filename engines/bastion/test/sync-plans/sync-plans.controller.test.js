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

describe('Controller: SyncPlansController', function() {
    var $scope,
        gettext,
        Nutupane,
        SyncPlan;

    beforeEach(module('Bastion.sync-plans', 'Bastion.test-mocks'));

    beforeEach(function() {
        Nutupane = function() {
            this.table = {
                showColumns: function() {}
            };
            this.get = function() {};
            this.enableSelectAllResults = function () {};
            this.removeRow = function () {};
        };

        gettext = function (string) {
            return string;
        };

        SyncPlan = {};
    });

    beforeEach(inject(function($controller, $rootScope, $location) {
        $scope = $rootScope.$new();

        $controller('SyncPlansController', {
            $scope: $scope,
            $location: $location,
            gettext: gettext,
            Nutupane: Nutupane,
            SyncPlan: SyncPlan,
            CurrentOrganization: 'CurrentOrganization'
        });
    }));

    it('attaches the nutupane table to the scope', function() {
        expect($scope.syncPlanTable).toBeDefined();
    });

    it('sets the closeItem function to transition to the index page', function() {
        spyOn($scope, "transitionTo");
        $scope.syncPlanTable.closeItem();

        expect($scope.transitionTo).toHaveBeenCalledWith('sync-plans.index');
    });

    it('provides a way to remove a sync plan', function() {
        var syncPlanInstance = {
            id: 1,
            $remove: function (callback) {
                callback();
            }
        };
        spyOn($scope, 'removeRow');
        spyOn($scope, 'transitionTo');
        spyOn(syncPlanInstance, '$remove').andCallThrough();

        $scope.removeSyncPlan(syncPlanInstance);

        expect(syncPlanInstance.$remove).toHaveBeenCalled();
        expect($scope.removeRow).toHaveBeenCalledWith(1);
        expect($scope.transitionTo).toHaveBeenCalledWith('sync-plans.index');
    });

});

