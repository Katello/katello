describe('Controller: ContentHostErrataController', function() {
    var $scope, Nutupane, HostErratum, Environment, Organization,
        mockTask, mockErratum, mockContentView, nutupaneMock, host;

    beforeEach(module('Bastion.content-hosts', 'Bastion.test-mocks'));

    beforeEach(function() {
        mockErratum = {
            errata_id: "RHSA-1024"
        };
        mockTask = {
            pending: true,
            id: 7
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
        host = {
            id: 5,
            organization_id: 'org-id-5',
            content_facet_attributes: {
                uuid: 4,
                lifecycle_environment: {
                    id: 'env_id_stage',
                    name: 'env stage'
                },
                lifecycle_environment_id: 'env_id_stage',
                content_view_id: 'content-view-id'
            },
            hasContent: function() { return true; },
            $promise: {then: function(callback) {callback(host)}}
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
            this.enableSelectAllResults = function () {};
            this.getAllSelectedResults = function() {
                return {
                    included: { ids: [mockErratum.errata_id] }
                };
            };
        };
        HostErratum = {
            get: function() {return []},
            apply: function(errata, success) {
                success(mockTask);
                return mockTask
            },
            regenerateApplicability: function(options, success, error) {
                success(mockTask)
            }
        };
    });

    beforeEach(inject(function($controller, $rootScope, $injector, $window) {
        $window.AUTH_TOKEN = 'secret_token';
        $scope =  $rootScope.$new();
        $scope.host = host;

        Environment = $injector.get('MockResource').$new();
        Organization = $injector.get('MockResource').$new();

        Organization.mockResources.results[0].id = 'org-id-5';
        Organization.mockResources.results[0].default_content_view_id = 'def-content-view-id-77';
        Organization.mockResources.results[0].library_id = 'library-id';


        Environment.mockResources.results[0].id = 'env_id_stage'
        Environment.mockResources.results[0].prior = {name: "Dev", id: 8999};
        Environment.mockResources.results[0].organization = Organization.mockResources.results[0];
        Environment.mockResources.results[0].library = false;
        Environment.mockResources.results[0].$promise = {then: function(callback) {callback(Environment.mockResources.results[0])}};

        $scope.$stateParams = {hostId: $scope.host.id};

        $controller('ContentHostErrataController', {$scope: $scope,
                                               HostErratum: HostErratum,
                                               Nutupane: Nutupane,
                                               Environment: Environment,
                                               Organization: Organization});
    }));

    it("Sets a table.", function() {
        expect($scope.table).toBeTruthy();
    });

    it("provide a way to apply errata", function() {
        spyOn(HostErratum, "apply").and.callThrough();
        spyOn($scope.table, "selectAll");
        spyOn($scope, "transitionTo");
        $scope.applySelected();
        expect(HostErratum.apply).toHaveBeenCalledWith({id: host.id, bulk_errata_ids: {included: { ids: [mockErratum.errata_id]}}},
                                                         jasmine.any(Function));
        expect($scope.transitionTo).toHaveBeenCalledWith('content-host.tasks.details', {taskId: mockTask.id});
        expect($scope.table.selectAll).toHaveBeenCalledWith(false);
    });

    it("can apply errata with remote execution", function() {
        $scope.remoteExecutionByDefault = true;

        $scope.applySelected();

        expect($scope.errataActionFormValues.hostIds).toEqual(host.id);
        expect($scope.errataActionFormValues.customize).toEqual(false);
        expect($scope.errataActionFormValues.errata).toEqual(mockErratum.errata_id);
    });

    it("provide a way to regenerate applicability", function() {
        spyOn(HostErratum, "regenerateApplicability").and.callThrough();
        spyOn($scope, "transitionTo");
        $scope.calculateApplicability();
        expect(HostErratum.regenerateApplicability).toHaveBeenCalledWith({id: host.id},  jasmine.any(Function), jasmine.any(Function));
        expect($scope.transitionTo).toHaveBeenCalledWith('content-host.tasks.details', {taskId: mockTask.id});
    });

    it("should refresh errata with no options for current", function () {
        spyOn(nutupaneMock, 'setParams');
        spyOn(nutupaneMock, 'refresh');
        $scope.refreshErrata('current');
        expect(nutupaneMock.setParams).toHaveBeenCalledWith({id: host.id});
        expect(nutupaneMock.refresh).toHaveBeenCalled();
    });

    it("should refresh errata with all options for prior", function () {
        spyOn(nutupaneMock, 'setParams');
        spyOn(nutupaneMock, 'refresh');
        $scope.refreshErrata('prior');
        expect(nutupaneMock.setParams).toHaveBeenCalledWith({id: host.id,
            content_view_id: $scope.host.content_facet_attributes.content_view_id, environment_id: Environment.mockResources.results[0].prior.id});
        expect(nutupaneMock.refresh).toHaveBeenCalled();
    });

    it("should refresh errata with no options for library ", function () {
        spyOn(nutupaneMock, 'setParams');
        spyOn(nutupaneMock, 'refresh');
        $scope.refreshErrata('library');
        expect(nutupaneMock.setParams).toHaveBeenCalledWith({id: host.id,
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
        expect(prior.environment_id).toBe(Environment.mockResources.results[0].prior.id);
        expect(prior.content_view_id).toBe(host.content_facet_attributes.content_view_id);
    });

    it("By default should have 3 options, with appropriate values after setupOptions", function() {
        var defaultLib, prior;
        $scope.setupErrataOptions($scope.host);

        defaultLib = _.find($scope.errataOptions, function(opt) { return opt.label === 'library'; });
        prior = _.find($scope.errataOptions, function(opt) { return opt.label === 'prior'; });

        expect($scope.errataOptions.length).toBe(3);
        expect(defaultLib.environment_id).toBe(Organization.mockResources.results[0].library_id);
        expect(defaultLib.content_view_id).toBe(Organization.mockResources.results[0].default_content_view_id);
        expect(prior.environment_id).toBe(Environment.mockResources.results[0].prior.id);
        expect(prior.content_view_id).toBe(host.content_facet_attributes.content_view_id);
    });


    it("If no prior, do not include it as an option", function() {
        Environment.mockResources.results[0].library = true;
        $scope.host.content_facet_attributes['lifecycle_environment_library?'] = true;
        $scope.setupErrataOptions($scope.host);

        var defaultLib = _.find($scope.errataOptions, function(opt) { return opt.label === 'library'; }),
        prior = _.find($scope.errataOptions, function(opt) { return opt.label === 'prior'; });

        expect($scope.errataOptions.length).toBe(2);
        expect(defaultLib).toBeTruthy();
        expect(prior).toBe(undefined);
     });


    it("If already the default content view,, do not include it as an option", function() {
        Environment.mockResources.results[0].library = true;
        $scope.host.content_facet_attributes['lifecycle_environment_library?'] = true;
        $scope.host.content_facet_attributes.content_view_id = Organization.mockResources.results[0].default_content_view_id
        $scope.host.content_facet_attributes['content_view_default?'] = true;
        $scope.setupErrataOptions($scope.host);

        var defaultLib = _.find($scope.errataOptions, function(opt) { return opt.label === 'library'; }),
        prior = _.find($scope.errataOptions, function(opt) { return opt.label === 'prior'; });

        expect($scope.errataOptions.length).toBe(1);
        expect(defaultLib).toBe(undefined);
        expect(prior).toBe(undefined);
     });

});
