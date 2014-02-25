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

describe('Controller: DiscoveryController', function() {
    var $scope, Organization, mockTask, mockOrg, CurrentOrganization;

    beforeEach(module('Bastion.products', 'Bastion.test-mocks'));

    beforeEach(function() {
        mockOrg = {
            name: 'discoverOrg',
            label: 'discoverOrg',
            id: 'discoverOrg',
            discovery_task_id: 'discovery_task'
        };

        mockTask = {
            id: 'discovery_task',
            pending: false,
            parameters: {url: 'http://fake/foo'},
            result: ['http://fake/foo']
        };
        CurrentOrganization = "discoverOrg";
    });

    beforeEach(inject(function($controller, $rootScope, $injector) {
        var $http = $injector.get('$http'),
            $q = $injector.get('$q'),
            $timeout = $injector.get('MockResource').$new();

        Task = $injector.get('MockTask');
        new Task(mockTask);

        Organization = $injector.get('MockOrganization');
        new Organization(mockOrg);

        $scope = $rootScope.$new();
        $scope.panel = {};
        $scope.discoveryTable = {
            getSelected: function() {},
            selectAll: function() {},
            rows: []
        };

        $httpBackend = $injector.get('$httpBackend');

        $controller('DiscoveryController', {
            $scope: $scope,
            $q: $q,
            $timeout: $timeout,
            $http: $http,
            Task: Task,
            Organization: Organization,
            CurrentOrganization: CurrentOrganization
        });
    }));

    it('setting up selected transitions to create state', function() {
        var fakeSelected = [1,2,3];
        spyOn($scope.discoveryTable, 'getSelected').andReturn(fakeSelected);
        spyOn($scope, 'transitionTo');

        $scope.setupSelected();

        expect($scope.panel.loading).toBe(true);
        expect($scope.discovery.selected).toBe(fakeSelected);
        expect($scope.transitionTo).toHaveBeenCalledWith('products.discovery.create');
    });


    it('default name should handle leading and trailing slashes', function() {
        spyOn($scope, 'defaultName').andCallThrough();
        expect($scope.defaultName("/foo/")).toBe("foo");
    });

    it('default name should convert / to space', function() {
        spyOn($scope, 'defaultName').andCallThrough();
        expect($scope.defaultName("/foo/bar")).toBe("foo bar");
    });


    it('should cancel discovery', function() {
        spyOn(Organization, 'cancelRepoDiscover');
        $scope.cancelDiscovery();
        expect(Organization.cancelRepoDiscover).toHaveBeenCalled();
        expect($scope.discovery.working).toBe(true);
    });


    /* TODO: For now, we don't support loading the current disovery task
       when reloading the page */
    xit('should fetch discovery task through org and set details', function() {
        expect($scope.discovery.url).toBe(mockTask.parameters.url);
        expect($scope.discovery.pending).toBe(mockTask.pending);
        expect($scope.discoveryTable.rows[0].url).toBe(mockTask.result[0]);
    });

    it('should initiate discovery', function() {
        $scope.discovery.url = 'http://fake/';
        spyOn(Organization, 'repoDiscover').andCallThrough();

        $scope.discover();

        expect(Organization.repoDiscover).toHaveBeenCalledWith({id: CurrentOrganization, url: 'http://fake/'},
                                                               jasmine.any(Function));
    });

    it('should set discovery table upon completed discovery', function() {
        $scope.discovery.url = 'http://fake/';
        spyOn(Task, 'get');
        $scope.discover();

        expect(Task.get).not.toHaveBeenCalled();

        Task.simulateBulkSearch(Organization.mockDiscoveryTask);

        expect($scope.discoveryTable.rows[0].url).toBe(Organization.mockDiscoveryTask.output[0]);
        expect($scope.discoveryTable.rows[0].path).toBe('foo');
    });

    it('discovery should poll if task is pending', function() {
        $scope.discover();
        Organization.mockDiscoveryTask.pending = true
        spyOn(Task, 'unregisterSearch');
        Task.simulateBulkSearch(Organization.mockDiscoveryTask);
        expect(Task.unregisterSearch).not.toHaveBeenCalled();
    });

    it('discovery should stop polling if task is not pending', function() {
        $scope.discover();
        Organization.mockDiscoveryTask.pending = false
        spyOn(Task, 'unregisterSearch');
        Task.simulateBulkSearch(Organization.mockDiscoveryTask);
        expect(Task.unregisterSearch).toHaveBeenCalled();
    });

});

