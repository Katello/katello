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

describe('Controller: ContentHostEventsController', function() {
    var $scope, Nutupane, ContentHostTask, mockTask;

    beforeEach(module('Bastion.content-hosts', 'Bastion.test-mocks'));

    beforeEach(function() {
        mockTask = {id: 4, pending: true};
        Nutupane = function() {
            this.table = {
                showColumns: function() {}
            };
            this.get = function() {};
        };
        ContentHost = {
            tasks: function() {return []}
        };
        ContentHostTask = {
            get: function(task, success) {success(task)},
            poll: function(task, success) {success(task)}
        };
    });

    beforeEach(inject(function($controller, $rootScope) {
        $scope = $rootScope.$new();
        $controller('ContentHostEventsController', {$scope: $scope,
                                               ContentHost: ContentHost,
                                               ContentHostTask: ContentHostTask,
                                               Nutupane: Nutupane});
    }));

    it("Sets a table.", function() {
        expect($scope.eventsTable).toBeTruthy();
    });
});
