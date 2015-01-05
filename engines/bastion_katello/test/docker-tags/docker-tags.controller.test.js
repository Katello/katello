/**
 * Copyright 2015 Red Hat, Inc.
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

describe('Controller: DockerTagsController', function() {
    var $scope,
        DockerTag,
        Repository,
        Nutupane;

    beforeEach(module('Bastion.docker-tags', 'Bastion.test-mocks'));

    beforeEach(function() {
        Nutupane = function() {
            this.table = {
                showColumns: function() {}
            };
            this.get = function() {};
            this.setParams = function (params) {};
            this.getParams = function (params) { return {}; };
            this.refresh = function () {};
        };
        DockerTag = {};
    });

    beforeEach(inject(function($controller, $rootScope, $location, MockResource, translateMock) {
        Repository = MockResource.$new();
        $scope = $rootScope.$new();

        $controller('DockerTagsController', {
            $scope: $scope,
            $location: $location,
            Nutupane: Nutupane,
            DockerTag: DockerTag,
            Repository: Repository,
            CurrentOrganization: 'CurrentOrganization',
            translate: translateMock
        });
    }));

    it('attaches the nutupane table to the scope', function() {
        expect($scope.table).toBeDefined();
    });

    it('sets the closeItem function to transition to the index page', function() {
        spyOn($scope, "transitionTo");
        $scope.table.closeItem();

        expect($scope.transitionTo).toHaveBeenCalledWith('docker-tags.index');
    });

});
