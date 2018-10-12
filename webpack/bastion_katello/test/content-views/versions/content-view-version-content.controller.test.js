describe('Controller: ContentViewsVersionContentController', function() {
    var $scope,
        Package,
        PackageGroup,
        Nutupane,
        ContentViewVersion;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks'));

    beforeEach(function() {
        Nutupane = function (resource) {
            this.resource = resource;
            this.table = {
                showColumns: function() {}
            };
            this.get = function() {};
            this.enableSelectAllResults = function() {};
            this.refresh = function () {};
            this.getParams = function () { return {'repository_id': 1} };
            this.setParams = function () {};
        };
    });

    function SetupController (state) {

        inject(function($injector) {
            var $controller = $injector.get('$controller');

            Package = $injector.get('MockResource').$new();
            PackageGroup = $injector.get('MockResource').$new();
            Erratum = $injector.get('MockResource').$new();
            PuppetModule = $injector.get('MockResource').$new();
            ContentViewVersion = $injector.get('MockResource').$new();
            Repository = $injector.get('MockResource').$new();
            OstreeBranch = $injector.get('MockResource').$new();
            ModuleStream = $injector.get('MockResource').$new();

            $scope = $injector.get('$rootScope').$new();
            $scope.$stateParams = {versionId: '1'};
            $scope.$state = {current: {name: state}};
            $scope.version = ContentViewVersion.get({id: 1});
            $scope.version.repositories = [{id: 1, 'content_type': 'yum'}];

            $controller('ContentViewVersionContentController', {
                $scope: $scope,
                Nutupane: Nutupane,
                Package: Package,
                Erratum: Erratum,
                PackageGroup: PackageGroup,
                PuppetModule: PuppetModule,
                OstreeBranch: OstreeBranch,
                ModuleStream: ModuleStream,
                ContentViewVersion: ContentViewVersion,
                Repository: Repository
            });
        });
    }

    it("puts a table object on the scope", function() {
        SetupController('content-view.version.packages');
        expect($scope.table).toBeDefined();
    });

    it("setups up Package resource when the state is 'package'", function() {
        SetupController('content-view.version.packages');
        expect($scope.nutupane.resource).toBe(Package);
    });

    it("setups up PackageGroup resource when is state is 'package groups'", function() {
        SetupController('content-view.version.package-groups');
        expect($scope.nutupane.resource).toBe(PackageGroup);
    });


    it("setups up ModuleStream resource when is state is 'module streams'", function() {
        SetupController('content-view.version.module-streams');
        expect($scope.nutupane.resource).toBe(ModuleStream);
    });

    it("setups up Erratum resource when is state is 'errata'", function() {
        SetupController('content-view.version.errata');
        expect($scope.nutupane.resource).toBe(Erratum);
    });

    it("setups up PuppetModule resource when is state is 'puppet modules'", function() {
        SetupController('content-view.version.puppet-modules');
        expect($scope.nutupane.resource).toBe(PuppetModule);
    });

    it("setups up OSTree Branches resource when is state is 'ostree-branches'", function() {
        SetupController('content-view.version.ostree-branches');
        expect($scope.nutupane.resource).toBe(OstreeBranch);
    });

    it("setups up docker Repo resource when is state is 'docker content'", function() {
        SetupController('content-view.version.docker');
        expect($scope.nutupane.resource).toBe(Repository);
    });

    it("setups up yum Repo resource when is state is 'yum content'", function() {
        SetupController('content-view.version.yum');
        expect($scope.nutupane.resource).toBe(Repository);
    });

    it("setups up ContentViewVersion resource when is state is 'components'", function() {
        SetupController('content-view.version.components');
        expect($scope.nutupane.resource).toBe(ContentViewVersion);
    });

    it("builds a list of repositories from the version", function() {
        SetupController('content-view.version.packages');
        expect($scope.repositories.length).toBe(2);
    });

    it("builds a list of repositories from the version", function() {
        SetupController('content-view.version.packages');
        spyOn($scope.nutupane, 'refresh');

        $scope.repositories = {id: 2};
        $scope.$digest();
        expect($scope.nutupane.refresh).toHaveBeenCalled();
    });

});

