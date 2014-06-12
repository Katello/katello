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

describe('Controller: ContentHostDetailsInfoController', function() {
    var $scope,
        $controller,
        translate,
        ContentHost,
        CustomInfo,
        mockContentViews;

    beforeEach(module(
        'Bastion.content-hosts',
        'Bastion.host-collections',
        'Bastion.test-mocks',
        'content-hosts/details/views/content-host-info.html',
        'content-hosts/views/content-hosts.html',
        'content-hosts/views/content-hosts-table-full.html'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q'),
            $http = $injector.get('$http'),
            ContentView = $injector.get('MockResource').$new(),
            Organization = $injector.get('MockResource').$new();

        CustomInfo = $injector.get('MockResource').$new(),
        ContentHost = $injector.get('MockResource').$new();
        $scope = $injector.get('$rootScope').$new();

        ContentView.queryUnpaged = function(){};
        ContentHost.releaseVersions = function(params, callback) {
            callback.apply(this, [['RHEL6']]);
        };

        Organization.readableEnvironments = function(params, callback) {
            var response = [[{name: 'Library', id: 1}]];

            if (callback) {
                callback.apply(this, response);
            }

            return response;
        };

        spyOn(ContentHost, 'releaseVersions').andReturn(['RHEL6']);

        translate = function(message) {
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

        $scope.contentHost = new ContentHost({
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
        $scope.contentHost.$promise = {then: function (callback) { callback(); }};

        $controller('ContentHostDetailsInfoController', {
            $scope: $scope,
            $q: $q,
            translate: translate,
            CustomInfo: CustomInfo,
            ContentHost: ContentHost,
            ContentView: ContentView,
            Organization: Organization,
            CurrentOrganization: 'ACME_Corporation'
        });
    }));

    it("gets the available release versions and puts them on the $scope", function() {
        $scope.releaseVersions().then(function(releases) {
            expect(releases).toEqual(['RHEL6']);
        });
    });

    it("sets edit mode to false when saving a content view", function() {
        $scope.saveContentView($scope.contentHost);

        expect($scope.editContentView).toBe(false);
    });

    it("pulls and converts memory from content host facts.", function() {
        var facts = {memory: {memtotal: "6857687"}, dmi: {memory: {size: "1 TB"}}};
        expect($scope.memory(facts)).toEqual(6.54);
        facts = {dmi: {memory: {size: "1 TB"}}};
        expect($scope.memory(facts)).toEqual(1024);
    });

    it("builds list of guest ids", function () {
        var host;
        host = {id: 1};
        expect($scope.virtualGuestIds(host)).toEqual("id:1");
        host = {id: 1, "virtual_guests":[]};
        expect($scope.virtualGuestIds(host)).toEqual("id:1");
        host = {id: 1, "virtual_guests":[{ id: 2 }, { id: 3}]};
        expect($scope.virtualGuestIds(host)).toEqual("id:1 id:2 id:3");
    });

    describe("populates advanced content host information", function () {

        it("creates the content host facts object by converting dot notation response to an object.", function() {
            expect(typeof $scope.contentHostFacts).toBe("object");
            expect(typeof $scope.contentHostFacts.lscpu).toBe("object");
            expect($scope.contentHostFacts.lscpu.architecture).toBe("Intel Itanium architecture");
        });

        it("populates advanced info into two groups", function() {
            expect(Object.keys($scope.advancedInfoRight).length).toBe(1);
            expect(Object.keys($scope.advancedInfoRight).length).toBe(1);
        });

        it("retrieves the correct template for each field based on it's type", function() {
            expect($scope.getTemplateForType("somethingElse")).toBe("content-hosts/details/views/partials/content-host-detail-value.html");
            expect($scope.getTemplateForType({})).toBe("content-hosts/details/views/partials/content-host-detail-object.html");
        });

        it('provides a method to retrieve available content views for a content host', function() {
            var promise = $scope.contentViews();

            promise.then(function(contentViews) {
                expect(contentViews).toEqual(mockContentViews);
            });
        });

        it('should set the environment and force a content view to be selected', function() {
            $scope.contentHost.environment = {name: 'Dev', id: 2};
            $scope.$digest();

            expect($scope.contentHost.environment.id).toBe(2);
            expect($scope.originalEnvironment.id).toBe(1);
            expect($scope.editContentView).toBe(true);
            expect($scope.disableEnvironmentSelection).toBe(true);
        });

        it('should reset the content host environment when cancelling a content view update', function() {
            $scope.editContentView = true;
            $scope.originalEnvironment.id = 2;
            $scope.cancelContentViewUpdate();

            expect($scope.contentHost.environment.id).toBe(2);
            expect($scope.editContentView).toBe(false);
        });
    });

    describe("handles custom info CRUD operations", function() {
        var $httpBackend, info, expectedUrl, expectedData;

        beforeEach(function() {

            inject(function(_$httpBackend_) {
                $httpBackend = _$httpBackend_;
            });

            $scope.contentHost = {id: 1, customInfo: []};
            info = {id: 1, keyname: 'key', value: 'value'};
            expectedData = {'custom_info': info};
        });

        it("should provide a way to update custom info", function() {
            $scope.contentHost.customInfo = [{id: 1, name: 'CustomInfo1'}];
            expect($scope.saveCustomInfo({name: 'CustomInfo2'}).custom_info.name).toBe('CustomInfo2');
        });

        it("should provide a way to create custom info", function() {
            $scope.addCustomInfo(info);

            expect($scope.contentHost.customInfo.length).toBe(1);
        });

        it("should provide a way to delete custom info", function() {
            var customInfo = {keyname: 'CustomInfo1'};
            $scope.contentHost.customInfo = [customInfo];
            expect($scope.deleteCustomInfo(customInfo)).toBe(true);
        });
    });
});
