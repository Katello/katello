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

describe('Controller: ErrataContentHostsController', function() {
    var $scope, translate, Nutupane, ContentHost, ContentHostBulkAction,
        CurrentOrganization;

    beforeEach(module('Bastion.errata', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            MockResource = $injector.get('MockResource');

        translate = function (string) {
            return string;
        };

        Nutupane = function() {
            this.table = {
                params: {},
                showColumns: function () {}
            };
            this.enableSelectAllResults = function () {};
            this.getAllSelectedResults = function () {
                return {include: [1, 2, 3]};
            };
            this.setParams = function (params) {
                this.table.params = params;
            };
            this.refresh = function () {};
            this.load = function () {
                return {then: function () {}}
            };
        };

        ContentHost = {};

        ContentHostBulkAction = {
            failed: false,
            installContent: function (params, success, error) {
                if (this.failed) {
                    error({errors: ['error']});
                } else {
                    success();
                }
            }
        };

        Environment = MockResource.$new();
        CurrentOrganization = 'foo';
        
        $scope = $injector.get('$rootScope').$new();
        $scope.$stateParams = {errataId: 1};

        $controller('ErrataContentHostsController', {
            $scope: $scope,
            translate: translate,
            Nutupane: Nutupane,
            ContentHost: ContentHost,
            Environment: Environment,
            ContentHostBulkAction: ContentHostBulkAction,
            CurrentOrganization: CurrentOrganization                      
        });
    }));

    it("puts the errata content hosts table object on the scope", function() {
        expect($scope.detailsTable).toBeDefined();
    });

    it("allows the filtering of installable errata only", function () {
        $scope.errata = {
            showAvailable: true
        };
        
        $scope.toggleAvailable();
        expect($scope.detailsTable.params['erratum_restrict_available']).toBe(true)
    });

    it("provides a way to filter on environment", function () {
        var nutupane = $scope.nutupane;

        spyOn(nutupane, 'setParams').andCallThrough();
        spyOn(nutupane, 'refresh');

        $scope.selectEnvironment('foo');

        expect(nutupane.setParams).toHaveBeenCalled();
        expect(nutupane.refresh).toHaveBeenCalled();
        expect($scope.detailsTable.params['environment_id']).toBe('foo');
    });

    describe("provides a way to go to the next apply step", function () {
        beforeEach(function () {
            spyOn($scope.nutupane, 'getAllSelectedResults');
            spyOn($scope, 'transitionTo');
        });

        afterEach(function() {
            expect($scope.nutupane.getAllSelectedResults).toHaveBeenCalled();
        });

        it("and goes to the errata details apply page if there is an errata", function () {
            $scope.errata = {id: 1};
            $scope.goToNextStep();
            expect($scope.transitionTo).toHaveBeenCalledWith('errata.details.apply', {errataId: $scope.errata.id})
        });

        it("and goes to the errata apply page if there is not an errata", function () {
            $scope.goToNextStep();
            expect($scope.transitionTo).toHaveBeenCalledWith('errata.apply.confirm');
        });
    });
});
