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
        $http,
        Routes,
        System,
        SystemGroup,
        ContentView,
        mockSystem,
        mockContentViews;

    beforeEach(module(
        'Bastion.systems',
        'Bastion.system-groups',
        'systems/details/views/system-info.html',
        'systems/views/systems.html',
        'systems/views/systems-table-full.html'
    ));

    beforeEach(inject(function(_$controller_, $rootScope, $q, _$http_) {
        $controller = _$controller_;
        $scope = $rootScope.$new();
        $http = _$http_;

        mockSystem = {
            failed: false,
            uuid: 2,
            facts: {
                cpu: "Itanium",
                "lscpu.architecture": "Intel Itanium architecture",
                "lscpu.instructionsPerCycle": "6",
                anotherFact: "yes"
            },
            environment: {
                id: 1
            },
            $update: function(success, error) {
                if (mockSystem.failed) {
                    error({ data: {errors: {}}});
                } else {
                    success(mockSystem);
                }
            }
        };
        System = {
            get: function(params, callback) {
                if (callback) {
                    callback(mockSystem);
                }
                return mockSystem;
            },
            releaseVersions: function(params, callback) {
                callback.apply(this, [['RHEL6']]);
            },
            saveSystemGroups: function() {}
        };

        SystemGroup = {
            query: function() {}
        };

        spyOn(System, 'get').andCallThrough();
        spyOn(System, 'releaseVersions').andReturn(['RHEL6']);

        mockContentViews = {
            results: [
                {id: 1, name: 'ContentView1'},
                {id: 2, name: 'ContentView2'}
            ]
        };

        ContentView = {
            query: function(params, callback) {
                callback(mockContentViews);
            }
        };

        Routes = {
            apiCustomInfoPath: function(informable, id) {
                return ['/api', informable, id].join('/')
            }
        };

        $scope.setupSelector = function() {};
        $scope.pathSelector = {
            select: function() {}
        };

        $controller('SystemDetailsInfoController', {
            $scope: $scope,
            $q: $q,
            $http: $http,
            Routes: Routes,
            System: System,
            SystemGroup: SystemGroup,
            ContentView: ContentView
        });

        $scope.system = System.get(function(){});
        $scope.$broadcast('system.loaded');
    }));

    it("gets the available release versions and puts them on the $scope", function() {
        $scope.releaseVersions().then(function(releases) {
            expect(releases).toEqual(['RHEL6']);
        });
    });

    it("populates organizational system groups via the SystemGroups factory.", function() {
        spyOn(SystemGroup, 'query');
        $scope.systemGroups();
        expect(SystemGroup.query).toHaveBeenCalledWith(jasmine.any(Function));
    });

    it("allows updating the system's groups", function() {
        var expected = { system : { system_group_ids : [ 1, 2 ] } };
        spyOn(System, 'saveSystemGroups');
        $scope.updateSystemGroups([{id: 1, name: "lalala"}, {id: 2, name: "hello!"}])
        expect(System.saveSystemGroups).toHaveBeenCalledWith({id: 2}, expected, jasmine.any(Function), jasmine.any(Function));
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

        // TODO remove me when we upgrade to AngularJS 1.1.4, see note in system-details-info.controller.js
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
            $scope.setEnvironment(2);

            expect($scope.system.environment.id).toBe(2);
            expect($scope.previousEnvironment).toBe(1);
            expect($scope.editContentView).toBe(true);
        });

        it('should reset the system environment when cancelling a content view update', function() {
            $scope.editContentView = true;
            $scope.previousEnvironment = 2;
            $scope.cancelContentViewUpdate();

            expect($scope.system.environment.id).toBe(2);
            expect($scope.editContentView).toBe(false);
        });

        it('should save the system and return a promise', function() {
            var promise = $scope.save(mockSystem);

            expect(promise.then).toBeDefined();
        });

        it('should save the system successfully', function() {
            $scope.save(mockSystem);

            expect($scope.saveSuccess).toBe(true);
        });

        it('should fail to save the system', function() {
            mockSystem.failed = true;
            $scope.save(mockSystem);

            expect($scope.saveSuccess).toBe(false);
            expect($scope.saveError).toBe(true);
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
            expectedUrl = [Routes.apiCustomInfoPath('system', 1), info.keyname].join('/');
            expectedData = {'custom_info': info};
        });

        afterEach(function() {
            $httpBackend.verifyNoOutstandingExpectation();
            $httpBackend.verifyNoOutstandingRequest();
        });

        it("by posting to the API on save", function() {
            $httpBackend.expectPUT(expectedUrl, expectedData).respond();
            $scope.saveCustomInfo(info);
            $httpBackend.flush();
        });

        it("by posting to the API on create", function() {
            expectedUrl = Routes.apiCustomInfoPath('system', 1);
            $httpBackend.expectPOST(expectedUrl, expectedData).respond();
            $scope.addCustomInfo(info);
            $httpBackend.flush();
        });

        it("by posting to the API on delete", function() {
            $httpBackend.expectDELETE(expectedUrl).respond();
            $scope.deleteCustomInfo(info);
            $httpBackend.flush();
        });
    });
});
