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
        System,
        mockSystem,
        mockContentViews;

    beforeEach(module(
        'Bastion.systems',
        'systems/details/views/system-info.html',
        'systems/views/systems.html',
        'systems/views/systems-table-full.html'
    ));

    beforeEach(inject(function(_$controller_, $rootScope, $q, $state) {
        $controller = _$controller_;
        $scope = $rootScope.$new();

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
            }
        };
        mockContentViews = {
            results: [
                {id: 1, name: 'ContentView1'},
                {id: 2, name: 'ContentView2'}
            ]
        };

        Environment = {};
        ContentView = {
            query: function(params, callback) {
                callback(mockContentViews);
            }
        };

        $scope.$stateParams = {systemId: 2};

        $scope.setupSelector = function() {};
        $scope.pathSelector = {
            select: function() {}
        };

        $controller('SystemDetailsInfoController', {
            $scope: $scope,
            $q: $q,
            System: System,
            ContentView: ContentView
        });

        $scope.system = System.get();
        $scope.$broadcast('system.loaded');
    }));

    it("gets the available release versions and puts them on the $scope", function() {
        $scope.releaseVersions().then(function(releases) {
            expect(releases).toEqual(['RHEL6']);
        });
    });


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
        var promise = $scope.save(mockSystem);

        promise.then(function(response) {
            console.log('test');
        });

        expect($scope.saveSuccess).toBe(true);
    });

    it('should fail to save the system', function() {
        var promise;

        mockSystem.failed = true;
        promise = $scope.save(mockSystem);

        expect($scope.saveSuccess).toBe(false);
        expect($scope.saveError).toBe(true);
    });

});

