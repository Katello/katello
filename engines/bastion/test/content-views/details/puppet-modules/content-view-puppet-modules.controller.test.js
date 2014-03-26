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

describe('Controller: ContentViewPuppetModulesController', function() {
    var $scope, Nutupane, ContentViewPuppetModule, puppetModule;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks', 'Bastion.i18n'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller');

        Nutupane = function () {
            this.removeRow = function () {};
            this.table = {};
        };

        ContentViewPuppetModule = $injector.get('MockResource').$new();
        puppetModule = {
            id: 3,
            name: "puppet",
            computed_version: '0.2.0'
        };

        $scope = $injector.get('$rootScope').$new();
        $scope.transitionTo = function () {};
        $scope.$stateParams.contentViewId = 1;

        $controller('ContentViewPuppetModulesController', {
            $scope: $scope,
            Nutupane: Nutupane,
            ContentViewPuppetModule: ContentViewPuppetModule
        });
    }));

    it("puts a content view version table on the scope", function() {
        expect($scope.detailsTable).toBeDefined();
    });

    describe("can determine the version text based on the puppet module", function () {
        it("by setting the version to latest", function () {
            expect($scope.versionText(puppetModule)).toBe("Latest (Currently 0.2.0)");
        });

        it("by setting a specific version", function () {
            puppetModule.puppet_module = {version: "0.0.1"};
            expect($scope.versionText(puppetModule)).toBe("0.0.1");
        });
    });

    it("provides a way to select a new version of the puppet module", function () {
        spyOn($scope, 'transitionTo');

        $scope.selectNewVersion(puppetModule);

        expect($scope.transitionTo).toHaveBeenCalledWith('content-views.details.puppet-modules.versionsForModule',
            {contentViewId: 1, moduleName: "puppet", moduleId: 3}
        );
    });

    describe("provides a way to remove a module", function () {
        beforeEach(function () {
            spyOn(ContentViewPuppetModule, 'remove').andCallThrough();
        });

        afterEach(function () {
            expect(ContentViewPuppetModule.remove).toHaveBeenCalledWith({contentViewId: 1, id: 3},
                jasmine.any(Function), jasmine.any(Function));
        });

        it("and succeeds", function () {
            $scope.removeModule(puppetModule);

            expect($scope.successMessages.length).toBe(1);
            expect($scope.errorMessages.length).toBe(0);
        });

        it("and fails", function () {
            ContentViewPuppetModule.failed = true;
            $scope.removeModule(puppetModule);

            expect($scope.successMessages.length).toBe(0);
            expect($scope.errorMessages.length).toBe(1);
        });
    });
});
