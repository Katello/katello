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

describe('Controller: SystemEventsController', function() {
    var $scope, Nutupane;

    beforeEach(module('Bastion.systems'));

    beforeEach(function() {
        Nutupane = function() {
            this.table = {
                showColumns: function() {}
            };
            this.get = function() {};
        };
        System = {
            tasks: function() {return []}
        };
    });

    beforeEach(inject(function($controller, $rootScope) {
        $scope = $rootScope.$new();
        $scope.transitionTo = function(){};
        $controller('SystemEventsController', {$scope: $scope, System: System, Nutupane: Nutupane});
    }));

    it("Sets a table.", function() {
        expect($scope.eventsTable).toBeTruthy();
    });

    it("provides a way to open the details panel.", function() {
        spyOn($scope, "transitionTo");
        $scope.eventsTable.openEventInfo({ id: 2 });
        expect($scope.transitionTo).toHaveBeenCalledWith('systems.details.events.details', {eventId: 2});
    });
});
