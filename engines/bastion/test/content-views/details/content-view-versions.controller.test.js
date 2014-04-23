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

describe('Controller: ContentViewVersionsController', function() {
    var $scope

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            ContentView = $injector.get('MockResource').$new(),
            translate = function (string) {
                return string;
            };

        $scope = $injector.get('$rootScope').$new();
        $scope.contentView = ContentView.get({id: 1});
        $scope.reloadVersions = function () {};
        $scope.taskTypes = {
            promotion: "promotion",
            publish: "publish"
        };


        spyOn($scope, 'reloadVersions');

        $controller('ContentViewVersionsController', {
            $scope: $scope,
            translate: translate
        });
    }));

    it("puts an empty table object on the scope", function() {
        expect($scope.table).toBeDefined();
    });

    it("correctly hide a version's progress", function() {
        var version = {active_history: [], task: {state: 'running', progressbar: {type: 'success'}}};
        expect($scope.hideProgress(version)).toBe(true);

        version = {active_history: [{}], task: {state: 'running', progressbar: {type: 'success'}}};
        expect($scope.hideProgress(version)).toBe(false);

        version = {active_history: [], task: {state: 'stopped', progressbar: {type: 'success'}}};
        expect($scope.hideProgress(version)).toBe(true);

        version = {active_history: [{}], task: {state: 'stopped', progressbar: {type: 'error'}}};
        expect($scope.hideProgress(version)).toBe(false);
    });

    it("determines what history text to display", function() {
        var version = {active_history: [],
            last_event: {environment: {name: 'test'},
                         task: {label: $scope.taskTypes.promotion}
        }};
        expect($scope.historyText(version)).toBe("Promoted to test");

        version.last_event.task.label = $scope.taskTypes.publish;
        expect($scope.historyText(version)).toBe("Published");
    });
});
