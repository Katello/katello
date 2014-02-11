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

describe('Controller: SystemDetailsInfoController', function() {
    var $scope,
        $controller,
        gettext,
        System,
        CustomInfo,
        mockContentViews;

    beforeEach(module(
        'Bastion.systems',
        'Bastion.system-groups',
        'Bastion.test-mocks',
        'systems/details/views/system-info.html',
        'systems/views/systems.html',
        'systems/views/systems-table-full.html'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q'),
            $http = $injector.get('$http'),
            ContentView = $injector.get('MockResource').$new(),
            Organization = $injector.get('MockResource').$new();

        CustomInfo = $injector.get('MockResource').$new(),
        System = $injector.get('MockResource').$new();
        $scope = $injector.get('$rootScope').$new();

        System.releaseVersions = function(params, callback) {
            callback.apply(this, [['RHEL6']]);
        };

        Organization.registerableEnvironments = function(params, callback) {
            var response = [[{name: 'Library', id: 1}]];

            if (callback) {
                callback.apply(this, response);
            }

            return response;
        };

        spyOn(System, 'releaseVersions').andReturn(['RHEL6']);

        gettext = function(message) {
            return message;
        };

        $scope.setupSelector = function() {};
        $scope.pathSelector = {
            select: function() {},
            enable_all: function() {},
            disable_all: function() {}
        };
        $scope.save = function() {
            var deferred = $q.defer();
            deferred.resolve();
            return deferred.promise;
        };

        $controller('SystemDetailsInfoController', {
            $scope: $scope,
            $q: $q,
            gettext: gettext,
            CustomInfo: CustomInfo,
            System: System,
            ContentView: ContentView,
            Organization: Organization,
            CurrentOrganization: 'ACME_Corporation'
        });

        $scope.system = new System({
            uuid: 2,
            facts: {
                cpu: "Itanium",
                "lscpu.architecture": "Intel Itanium architecture",
                "lscpu.instructionsPerCycle": "6",
                anotherFact: "yes"
            },
            environment: {
                id: 1
            }
        });
        $scope.$broadcast('system.loaded');
    }));

    it("gets the available release versions and puts them on the $scope", function() {
        $scope.releaseVersions().then(function(releases) {
            expect(releases).toEqual(['RHEL6']);
        });
    });

    it("sets edit mode to false when saving a content view", function() {
        $scope.saveContentView($scope.system);

        expect($scope.editContentView).toBe(false);
    });

    it("pulls and converts memory from system facts.", function() {
        var facts = {memory: {memtotal: "6857687"}, dmi: {memory: {size: "1 TB"}}};
        expect($scope.memory(facts)).toEqual(6.54);
        facts = {dmi: {memory: {size: "1 TB"}}};
        expect($scope.memory(facts)).toEqual(1024);
    });

    describe("populates advanced system information", function () {

        it("creates the system facts object by converting dot notation response to an object.", function() {
            expect(typeof $scope.systemFacts).toBe("object");
            expect(typeof $scope.systemFacts.lscpu).toBe("object");
            expect($scope.systemFacts.lscpu.architecture).toBe("Intel Itanium architecture");
        });

        it("populates advanced info into two groups", function() {
            expect(Object.keys($scope.advancedInfoRight).length).toBe(1);
            expect(Object.keys($scope.advancedInfoRight).length).toBe(1);
        });

        it("retrieves the correct template for each field based on it's type", function() {
            expect($scope.getTemplateForType("somethingElse")).toBe("systems/details/views/partials/system-detail-value.html");
            expect($scope.getTemplateForType({})).toBe("systems/details/views/partials/system-detail-object.html");
        });

        it('provides a method to retrieve available content views for a system', function() {
            var promise = $scope.contentViews();

            promise.then(function(contentViews) {
                expect(contentViews).toEqual(mockContentViews);
            });
        });

        it('should set the environment and force a content view to be selected', function() {
            $scope.system.environment = {name: 'Dev', id: 2};
            $scope.$digest();

            expect($scope.system.environment.id).toBe(2);
            expect($scope.originalEnvironment.id).toBe(1);
            expect($scope.editContentView).toBe(true);
            expect($scope.disableEnvironmentSelection).toBe(true);
        });

        it('should reset the system environment when cancelling a content view update', function() {
            $scope.editContentView = true;
            $scope.originalEnvironment.id = 2;
            $scope.cancelContentViewUpdate();

            expect($scope.system.environment.id).toBe(2);
            expect($scope.editContentView).toBe(false);
        });
    });

    describe("handles custom info CRUD operations", function() {
        var $httpBackend, info, expectedUrl, expectedData;

        beforeEach(function() {

            inject(function(_$httpBackend_) {
                $httpBackend = _$httpBackend_;
            });

            $scope.system = {id: 1, customInfo: []};
            info = {id: 1, keyname: 'key', value: 'value'};
            expectedData = {'custom_info': info};
        });

        it("should provide a way to update custom info", function() {
            $scope.system.customInfo = [{id: 1, name: 'CustomInfo1'}];
            expect($scope.saveCustomInfo({name: 'CustomInfo2'}).custom_info.name).toBe('CustomInfo2');
        });

        it("should provide a way to create custom info", function() {
            $scope.addCustomInfo(info);

            expect($scope.system.customInfo.length).toBe(1);
        });

        it("should provide a way to delete custom info", function() {
            var customInfo = {keyname: 'CustomInfo1'};
            $scope.system.customInfo = [customInfo];
            expect($scope.deleteCustomInfo(customInfo)).toBe(true);
        });
    });
});
