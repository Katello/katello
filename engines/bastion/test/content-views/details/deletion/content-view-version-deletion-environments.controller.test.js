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

describe('Controller: ContentViewVersionDeletionEnvironmentsController', function() {
    var $scope, environments, version;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller');

        environments = [{name: 'dev'}];
        version = {id: 1, environments: environments};

        $scope = $injector.get('$rootScope').$new();
        $scope.transitionToNext = function() {};
        $scope.deleteOptions = {environments: []};
        $scope.version = version;
        $scope.version.$promise = {then: function(callback) {callback(version)}};

        $controller('ContentViewVersionDeletionEnvironmentsController', {
            $scope: $scope
        });
    }));

    it("Should set environmentsTable", function() {
        expect($scope.environmentsTable.rows).toBe(environments);
    });

    it("should save environments as part of processing", function() {
        var selected = [{name: 'troyandabedinthemorning'}];
        spyOn($scope, 'transitionToNext');

        $scope.environmentsTable.getSelected = function() { return selected; };
        $scope.processSelection();

        expect($scope.transitionToNext).toHaveBeenCalled();
        expect( $scope.deleteOptions.environments).toBe(selected);
    });

});
