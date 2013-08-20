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

describe('Controller: SystemsEventsController', function() {
    var $scope, Nutupane;

    beforeEach(module('Bastion.systems'));

    beforeEach(inject(function($controller, $rootScope) {
        $scope = $rootScope.$new();
        $scope.transitionTo = function(){};
        $scope.$stateParams.eventId = '3'
        $scope.$parent.eventsTable = { rows : [{id:3}]}
        spyOn($scope, "transitionTo");

        $controller('SystemEventDetailsController', {$scope: $scope});
    }));

    it("redirects back to event list if event is not found", function(){
        $scope.$parent.eventsTable = { rows : [{id:4}]}
        $scope.$digest();

        expect($scope.transitionTo).toHaveBeenCalledWith('systems.details.events.index');

    });

    it("provides a way to go back to event list.", function() {
        $scope.transitionToIndex();
        expect($scope.transitionTo).toHaveBeenCalledWith('systems.details.events.index');
    });
});
