/**
 * Copyright 2014 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either environment
 * 2 of the License (GPLv2) or (at your option) any later environment.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 **/

describe('Controller: EnvironmentContentController', function() {
    var $scope,
        Erratum,
        Nutupane;

    beforeEach(module('Bastion.environments', 'Bastion.test-mocks'));

    beforeEach(function() {
        Nutupane = function (resource) {
            this.resource = resource;
            this.table = {
                showColumns: function() {}
            };
            this.removeRow = function() {};
            this.get = function() {};
            this.enableSelectAllResults = function() {}
        };
    });

    function SetupController (state) {

        inject(function($injector) {
            var $controller = $injector.get('$controller');

            Erratum = $injector.get('MockResource').$new();

            $scope = $injector.get('$rootScope').$new();
            $scope.$stateParams = {environmentId: '1'};
            $scope.$state = {current: {name: state}};

            $controller('EnvironmentContentController', {
                $scope: $scope,
                Nutupane: Nutupane,
                Erratum: Erratum,
            });
        });

    }

    it("puts a table object on the scope", function() {
        SetupController('environment.details');
        expect($scope.detailsTable).toBeDefined();
    });

    it("setups up Package resource when is state is 'errata'", function() {
        SetupController('environment.errata');
        expect($scope.nutupane.resource).toBe(Erratum);
    });

});

