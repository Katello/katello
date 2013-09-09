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

describe('Controller: SystemEventDetailsController', function() {
    var $scope, SystemTask, mockEvent;

    beforeEach(module('Bastion.systems', 'Bastion.test-mocks'));

    beforeEach(inject(function($controller, $rootScope) {
        mockEvent = {id: 3, pending: true};

        SystemTask = {
            get: function(eventId, success) {
                success(mockEvent);
                return mockEvent
            },
            poll: function(eventId, success) {
                success(mockEvent);
            }
        };

        $scope = $rootScope.$new();
        $scope.$stateParams.eventId = '3';

        spyOn($scope, "transitionTo");
        spyOn(SystemTask, "get").andCallThrough();
        spyOn(SystemTask, "poll").andCallThrough();

        $controller('SystemEventDetailsController', {$scope: $scope, SystemTask: SystemTask});
    }));

    it("provides a way to go back to event list by default", function() {
        $scope.transitionBack();
        expect($scope.transitionTo).toHaveBeenCalledWith('systems.details.events.index', {});
    });

    it("provides a way to go back to any page", function(){
        var fromParams = {foo:1};
        $scope.$broadcast('$stateChangeSuccess', '', '', 'blah.blah', fromParams);
        $scope.transitionBack();
        expect($scope.transitionTo).toHaveBeenCalledWith('blah.blah', fromParams);
    });

    it("sets event", function() {
        expect(SystemTask.get).toHaveBeenCalledWith({id: '3'}, jasmine.any(Function));
        expect($scope.event).toBe(mockEvent);
    });

    it("polls if needed", function() {
        expect(SystemTask.poll).toHaveBeenCalledWith(mockEvent, jasmine.any(Function));
    });

});
