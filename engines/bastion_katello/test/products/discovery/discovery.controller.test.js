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
            $timeout = $injector.get('MockResource').$new(),
            translate;

        Task = $injector.get('MockTask');
        new Task(mockTask);

        Organization = $injector.get('MockOrganization');
        new Organization(mockOrg);

        translate = function (message) {
            return message;
        };

        $scope = $rootScope.$new();
        $scope.panel = {};
        $scope.table = {
            getSelected: function() {},
            selectAll: function() {},
            rows: [],
            resource: {
                total: 0,
                subtotal: 0
            },
            numSelected: 0
        };

        $httpBackend = $injector.get('$httpBackend');

        $controller('DiscoveryController', {
            $scope: $scope,
            $q: $q,
            $timeout: $timeout,
            $http: $http,
            Task: Task,
            Organization: Organization,
            CurrentOrganization: CurrentOrganization,
            translate: translate
        });
    }));

    it('setting up selected transitions to create state', function() {
        var fakeSelected = [1,2,3],
            fakeUrl = 'http://fake/';
        spyOn($scope.table, 'getSelected').and.returnValue(fakeSelected);
        spyOn($scope, 'transitionTo').and.returnValue({then: function () {}});
        $scope.discovery.url = fakeUrl;

        $scope.setupSelected();

        expect($scope.page.loading).toBe(true);
        expect($scope.discovery.selected).toBe(fakeSelected);
        expect($scope.transitionTo).toHaveBeenCalledWith('product-discovery.create');
    });


    it('default name should handle leading and trailing slashes', function() {
        spyOn($scope, 'defaultName').and.callThrough();
        expect($scope.defaultName("/foo/")).toBe("foo");
    });

    it('default name should convert / to space', function() {
        spyOn($scope, 'defaultName').and.callThrough();
        expect($scope.defaultName("/foo/bar")).toBe("foo bar");
    });


    it('should cancel discovery', function() {
        spyOn(Organization, 'cancelRepoDiscover');
        $scope.cancelDiscovery();
        expect(Organization.cancelRepoDiscover).toHaveBeenCalled();
        expect($scope.discovery.working).toBe(false);
    });


    /* TODO: For now, we don't support loading the current disovery task
       when reloading the page */
    xit('should fetch discovery task through org and set details', function() {
        expect($scope.discovery.url).toBe(mockTask.parameters.url);
        expect($scope.discovery.pending).toBe(mockTask.pending);
        expect($scope.table.rows[0].url).toBe(mockTask.result[0]);
    });

    it('should initiate yum discovery', function() {
        $scope.discovery.url = 'http://fake/';
        spyOn(Organization, 'repoDiscover').and.callThrough();

        $scope.discover();

        expect(Organization.repoDiscover).toHaveBeenCalledWith({id: CurrentOrganization, url: 'http://fake/', 'content_type': 'yum', upstream_username: undefined, upstream_password: undefined, search: undefined},
                                                               jasmine.any(Function));
    });

    it('should initiate docker discovery', function() {
        $scope.discovery.registryType = 'custom';
        $scope.discovery.customRegistryUrl = 'http://fake/';
        $scope.discovery.contentType = 'docker';
        spyOn(Organization, 'repoDiscover').and.callThrough();

        $scope.discover();

        expect(Organization.repoDiscover).toHaveBeenCalledWith({id: CurrentOrganization, url: 'http://fake/', 'content_type': 'docker', upstream_username: undefined, upstream_password: undefined, search: undefined},
                                                               jasmine.any(Function));
    });

    it('should initiate docker discovery with search for rh registry', function() {
        $scope.discovery.registryType = 'redhat';
        $scope.discovery.contentType = 'docker';
        $scope.discovery.search = 'search';
        spyOn(Organization, 'repoDiscover').and.callThrough();

        $scope.discover();

        expect(Organization.repoDiscover).toHaveBeenCalledWith({id: CurrentOrganization, url: 'https://registry.redhat.io', 'content_type': 'docker', upstream_username: undefined, upstream_password: undefined, search: 'search'},
                                                               jasmine.any(Function));
    });

    it('should initiate docker discovery for docker hub', function() {
        $scope.discovery.registryType = 'dockerhub';
        $scope.discovery.contentType = 'docker';
        $scope.discovery.search = 'search';

        spyOn(Organization, 'repoDiscover').and.callThrough();
        $scope.discover();

        expect(Organization.repoDiscover).toHaveBeenCalledWith({id: CurrentOrganization, url: 'https://index.docker.io', 'content_type': 'docker', upstream_username: undefined, upstream_password: undefined, search: 'search'},
                                                               jasmine.any(Function));
    });

    it('should initiate docker discovery for quay', function() {
        $scope.discovery.registryType = 'quay';
        $scope.discovery.contentType = 'docker';
        $scope.discovery.search = 'search';

        spyOn(Organization, 'repoDiscover').and.callThrough();
        $scope.discover();

        expect(Organization.repoDiscover).toHaveBeenCalledWith({id: CurrentOrganization, url: 'https://quay.io', 'content_type': 'docker', upstream_username: undefined, upstream_password: undefined, search: 'search'},
                                                               jasmine.any(Function));
    });

    it('should initiate docker discovery with search for custom', function() {
        $scope.discovery.registryType = 'custom';
        $scope.discovery.customRegistryUrl = 'http://fake/';
        $scope.discovery.contentType = 'docker';
        $scope.discovery.search = 'search';
        spyOn(Organization, 'repoDiscover').and.callThrough();

        $scope.discover();

        expect(Organization.repoDiscover).toHaveBeenCalledWith({id: CurrentOrganization, url: 'http://fake/', 'content_type': 'docker', upstream_username: undefined, upstream_password: undefined, search: 'search'},
                                                               jasmine.any(Function));
    });

    it('should set docker discovery table upon completed discovery', function() {
        $scope.discovery.url = 'http://fake/';
        $scope.discovery.contentType = 'docker';
        spyOn(Task, 'get');
        $scope.discover();

        expect(Task.get).not.toHaveBeenCalled();
        Task.simulateBulkSearch(Organization.mockDiscoveryTask);

        expect($scope.table.rows[0].path).toBe('http://fake/foo');
        expect($scope.table.rows[0].name).toBe('http://fake/foo');
        expect($scope.table.rows[0].dockerUpstreamName).toBe('http://fake/foo');
    });

    it('discovery should poll if task is pending', function() {
        $scope.discovery.url = 'http://fake/';
        $scope.discovery.contentType = 'docker';
        $scope.discover();
        Organization.mockDiscoveryTask.state = 'running';
        spyOn(Task, 'unregisterSearch');
        Task.simulateBulkSearch(Organization.mockDiscoveryTask);
        expect(Task.unregisterSearch).not.toHaveBeenCalled();
    });

    it('discovery should stop polling if task is not pending', function() {
        $scope.discovery.contentType = 'docker';
        $scope.discover();
        Organization.mockDiscoveryTask.state = 'finished';
        spyOn(Task, 'unregisterSearch');
        Task.simulateBulkSearch(Organization.mockDiscoveryTask);
        expect(Task.unregisterSearch).toHaveBeenCalled();
    });
});

