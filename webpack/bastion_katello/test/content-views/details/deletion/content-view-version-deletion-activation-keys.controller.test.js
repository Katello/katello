describe('Controller: ContentViewVersionDeletionActivationKeysController', function() {
    var $scope, Organization, CurrentOrganization;

    beforeEach(module('Bastion.content-views', 'Bastion.test-mocks', 'Bastion.i18n'));

    beforeEach(inject(function($injector) {
        var Nutupane,
            $controller = $injector.get('$controller'),
            ContentView = $injector.get('MockResource').$new(),
            ContentViewVersion =  $injector.get('MockResource').$new(),
            ActivationKey =  $injector.get('MockResource').$new(),
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
        $scope.deleteOptions = {activationKeys: {}, environments: {}};

        spyOn(Organization, 'readableEnvironments').and.callThrough();
        spyOn($scope, 'validateEnvironmentSelection').and.callThrough();
        spyOn($scope, 'initEnvironmentWatch').and.callThrough();

        $controller('ContentViewVersionDeletionActivationKeysController', {
            $scope: $scope,
            $location: $location,
            Organization: Organization,
            CurrentOrganization: CurrentOrganization,
            Nutupane: Nutupane,
            ActivationKey: ActivationKey
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
        expect($scope.deleteOptions.activationKeys.environment).toBe(env);
        expect($scope.deleteOptions.activationKeys.contentView).toBe(view);
        expect($scope.transitionToNext).toHaveBeenCalled();
    });

    it('should construct the activation key link', function () {
        $scope.searchString = function (contentView, environments) {};
        spyOn($scope, 'searchString').and.returnValue('search');
        spyOn($scope.$state, 'href').and.returnValue('activationKeys');

        expect($scope.activationKeyLink()).toBe('activationKeys?search=search');
        expect($scope.searchString).toHaveBeenCalledWith($scope.contentView, $scope.deleteOptions.environments);
        expect($scope.$state.href).toHaveBeenCalledWith('activation-keys');
    });
});
