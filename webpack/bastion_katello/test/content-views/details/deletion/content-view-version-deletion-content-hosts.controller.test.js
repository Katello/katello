describe('Controller: ContentViewVersionDeletionContentHostsController', function() {
    var $scope, Organization, CurrentOrganization;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks', 'Bastion.i18n'));

    beforeEach(inject(function($injector) {
        var Nutupane,
            $controller = $injector.get('$controller'),
            ContentView = $injector.get('MockResource').$new(),
            ContentViewVersion =  $injector.get('MockResource').$new(),
            Host =  $injector.get('MockResource').$new(),
            $location = $injector.get('$location');

        CurrentOrganization = "FOO";
        Organization =  $injector.get('MockResource').$new();
        Organization.readableEnvironments = function() {return []};
        Nutupane = function () {
            this.table = {};
        };

        $scope = $injector.get('$rootScope').$new();
        $scope.contentView = ContentView.get({id: 1});
        $scope.version = ContentViewVersion.get({id: 1});
        $scope.initEnvironmentWatch = function() {};
        $scope.validateEnvironmentSelection = function() {};
        $scope.deleteOptions = {contentHosts: {}};

        spyOn(Organization, 'readableEnvironments').and.callThrough();
        spyOn($scope, 'validateEnvironmentSelection').and.callThrough();
        spyOn($scope, 'initEnvironmentWatch').and.callThrough();

        $controller('ContentViewVersionDeletionContentHostsController', {
            $scope: $scope,
            $location: $location,
            Organization: Organization,
            CurrentOrganization: CurrentOrganization,
            Nutupane: Nutupane,
            Host: Host
        });
    }));

    it("loads registerable environments on load", function() {
        expect(Organization.readableEnvironments).toHaveBeenCalledWith(
            {id: CurrentOrganization});
    });

    it('should validate environments', function() {
        expect($scope.validateEnvironmentSelection).toHaveBeenCalled();
    });

    it('should init environment watch', function() {
        expect($scope.initEnvironmentWatch).toHaveBeenCalled();
    });

    it('should transform search', function() {
        var env = {id: 5},
            view = {id: 3};

        $scope.transitionToNext = function() {};
        spyOn($scope, 'transitionToNext');

        $scope.contentViewsForEnvironment = [view];
        $scope.selectedEnvironment = env;
        $scope.selectedContentViewId = view.id;
        $scope.processSelection();

        expect($scope.selectedEnvironment).toBe(undefined);
        expect($scope.selectedContentViewId).toBe(undefined);
        expect($scope.deleteOptions.contentHosts.environment).toBe(env);
        expect($scope.deleteOptions.contentHosts.contentView).toBe(view);
        expect($scope.transitionToNext).toHaveBeenCalled();
    });

});
