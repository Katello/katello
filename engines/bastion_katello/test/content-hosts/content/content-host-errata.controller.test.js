describe('Controller: ContentHostErrataController', function() {
    var $scope, Nutupane, HostErratum, Environment, Organization,
        mockContentHost, mockTask, mockErratum, ContentHost, mockHost, mockContentView, nutupaneMock;

    beforeEach(module('Bastion.content-hosts', 'Bastion.test-mocks'));

    beforeEach(function() {
        mockErratum = {
            errata_id: "RHSA-1024"
        };
        mockContentHost = {
            uuid: 5
        };
        mockTask = {
            pending: true,
            id: 7
        };
        mockHost = {
            id: 123
        };
        mockContentView = {
            id: 5,
            default: false
        };
        nutupaneMock = {
            setParams: function() {},
            refresh: function(){},
            load: function () {}
        };
        Nutupane = function() {
            this.table = {
                showColumns: function() {},
                getSelected: function() {return [mockErratum];},
                selectAll: function() {}
            };
            this.get = function() {};
            this.setParams = function(args) {nutupaneMock.setParams(args)};
            this.refresh = function() {nutupaneMock.refresh()};
            this.load = function () {nutupaneMock.load()};
        };
        HostErratum = {
            get: function() {return []},
            apply: function(errata, success) {
                success(mockTask);
                return mockTask
            }
        };
    });

    beforeEach(inject(function($controller, $rootScope, $injector) {
        $scope = $rootScope.$new();
        Environment = $injector.get('MockResource').$new();
        Organization = $injector.get('MockResource').$new();
        ContentHost = $injector.get('MockResource').$new();

        Organization.mockResources.results[0].id = 'org-id-5';
        Organization.mockResources.results[0].default_content_view_id = 'def-content-view-id-77';
        Organization.mockResources.results[0].library_id = 'library-id';


        Environment.mockResources.results[0].prior = {name: "Dev", id: 8999};
        Environment.mockResources.results[0].organization = Organization.mockResources.results[0];
        Environment.mockResources.results[0].library = false;

        ContentHost.mockResources.results[0].uuid = 5;
        ContentHost.mockResources.results[0].content_view_id = 'content-view-id';
        ContentHost.mockResources.results[0].environment = Environment.mockResources.results[0];
        ContentHost.mockResources.results[0].content_view = mockContentView;
        ContentHost.mockResources.results[0].host = mockHost;
        mockContentHost =  ContentHost.mockResources.results[0];

        $scope.contentHost = ContentHost.get({id: mockContentHost.id});
        $scope.$stateParams = {contentHostId: $scope.contentHost.id};

        $controller('ContentHostErrataController', {$scope: $scope,
                                               HostErratum: HostErratum,
                                               Nutupane: Nutupane,
                                               Environment: Environment,
                                               Organization: Organization});
    }));

    it("Sets a table.", function() {
        expect($scope.detailsTable).toBeTruthy();
    });

    it("provide a way to apply errata", function() {
        spyOn(HostErratum, "apply").andCallThrough();
        spyOn($scope.detailsTable, "selectAll");
        spyOn($scope, "transitionTo");
        $scope.applySelected();
        expect(HostErratum.apply).toHaveBeenCalledWith({id: mockHost.id, errata_ids: [mockErratum.errata_id]},
                                                         jasmine.any(Function));
        expect($scope.transitionTo).toHaveBeenCalledWith('content-hosts.details.tasks.details', {taskId: mockTask.id});
        expect($scope.detailsTable.selectAll).toHaveBeenCalledWith(false);
    });

    it("should refresh errata with no options for current", function () {
        spyOn(nutupaneMock, 'setParams');
        spyOn(nutupaneMock, 'refresh');
        $scope.refreshErrata('current');
        expect(nutupaneMock.setParams).toHaveBeenCalledWith({id: mockHost.id});
        expect(nutupaneMock.refresh).toHaveBeenCalled();
    });

    it("should refresh errata with all options for prior", function () {
        spyOn(nutupaneMock, 'setParams');
        spyOn(nutupaneMock, 'refresh');
        $scope.refreshErrata('prior');
        expect(nutupaneMock.setParams).toHaveBeenCalledWith({id: mockHost.id,
            content_view_id: $scope.contentHost.content_view_id, environment_id: $scope.contentHost.environment.prior.id});
        expect(nutupaneMock.refresh).toHaveBeenCalled();
    });

    it("should refresh errata with no options for library ", function () {
        spyOn(nutupaneMock, 'setParams');
        spyOn(nutupaneMock, 'refresh');
        $scope.refreshErrata('library');
        expect(nutupaneMock.setParams).toHaveBeenCalledWith({id: mockHost.id,
            content_view_id: Organization.mockResources.results[0].default_content_view_id,
            environment_id: Organization.mockResources.results[0].library_id});
        expect(nutupaneMock.refresh).toHaveBeenCalled();
    });


    it("By default should have 3 options, with appropriate values", function() {
        var defaultLib = _.find($scope.errataOptions, function(opt) { return opt.label === 'library'; }),
        prior = _.find($scope.errataOptions, function(opt) { return opt.label === 'prior'; });

        expect($scope.errataOptions.length).toBe(3);
        expect(defaultLib.environment_id).toBe(Organization.mockResources.results[0].library_id);
        expect(defaultLib.content_view_id).toBe(Organization.mockResources.results[0].default_content_view_id);
        expect(prior.environment_id).toBe( ContentHost.mockResources.results[0].environment.prior.id);
        expect(prior.content_view_id).toBe( ContentHost.mockResources.results[0].content_view_id);
    });

    it("By default should have 3 options, with appropriate values after setupOptions", function() {
        var defaultLib, prior;
        $scope.setupErrataOptions($scope.contentHost);

        defaultLib = _.find($scope.errataOptions, function(opt) { return opt.label === 'library'; });
        prior = _.find($scope.errataOptions, function(opt) { return opt.label === 'prior'; });

        expect($scope.errataOptions.length).toBe(3);
        expect(defaultLib.environment_id).toBe(Organization.mockResources.results[0].library_id);
        expect(defaultLib.content_view_id).toBe(Organization.mockResources.results[0].default_content_view_id);
        expect(prior.environment_id).toBe( ContentHost.mockResources.results[0].environment.prior.id);
        expect(prior.content_view_id).toBe( ContentHost.mockResources.results[0].content_view_id);
    });


    it("If no prior, do not include it as an option", function() {
        Environment.mockResources.results[0].library = true;
        $scope.contentHost.environment.library = true;
        $scope.setupErrataOptions($scope.contentHost);

        var defaultLib = _.find($scope.errataOptions, function(opt) { return opt.label === 'library'; }),
        prior = _.find($scope.errataOptions, function(opt) { return opt.label === 'prior'; });

        expect($scope.errataOptions.length).toBe(2);
        expect(defaultLib).toBeTruthy();
        expect(prior).toBe(undefined);
     });


    it("If already the default content view,, do not include it as an option", function() {
        Environment.mockResources.results[0].library = true;
        $scope.contentHost.environment.library = true;
        $scope.contentHost.content_view_id = Organization.mockResources.results[0].default_content_view_id
        $scope.contentHost.content_view = {default: true};
        $scope.setupErrataOptions($scope.contentHost);

        var defaultLib = _.find($scope.errataOptions, function(opt) { return opt.label === 'library'; }),
        prior = _.find($scope.errataOptions, function(opt) { return opt.label === 'prior'; });

        expect($scope.errataOptions.length).toBe(1);
        expect(defaultLib).toBe(undefined);
        expect(prior).toBe(undefined);
     });




});
