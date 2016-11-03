describe('Controller: NewActivationKeyController', function() {
    var $scope,
        $httpBackend,
        paths,
        Organization,
        FormUtils,
        ContentView;

    beforeEach(module('Bastion.activation-keys', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $http = $injector.get('$http'),
            $q = $injector.get('$q'),
            ActivationKey= $injector.get('MockResource').$new();

        $scope = $injector.get('$rootScope').$new();
        $httpBackend = $injector.get('$httpBackend');


        $scope.activationKeyForm = $injector.get('MockForm');
        $scope.table = {};

        paths = [[{name: "Library", id: 1}, {name: "Dev", id: 2}]]

        Organization = $injector.get('MockResource').$new();
        Organization.readableEnvironments = function (params, callback) {
            var response = paths;

            if (callback) {
                callback.apply(this, response);
            }

            return response;
        };

        ContentView = $injector.get('MockResource').$new();
        ContentView.unPaged = function (params, callback) {};

        FormUtils = $injector.get('FormUtils');

        $controller('NewActivationKeyController', {
            $scope: $scope,
            $q: $q,
            FormUtils: FormUtils,
            ActivationKey: ActivationKey,
            Organization: Organization,
            CurrentOrganization: 'ACME',
            ContentView: ContentView
        });
    }));

    it('should attach a new activation key resource on to the scope', function() {
        expect($scope.activationKey).toBeDefined();
    });

    it('should fetch registerable environments', function() {
        expect($scope.environments).toBe(paths);
    });

    it('should save a new activation key resource', function() {
        var activationKey = $scope.activationKey;

        spyOn($scope, 'transitionTo');
        spyOn(activationKey, '$save').and.callThrough();
        $scope.save(activationKey);

        expect(activationKey.$save).toHaveBeenCalled();
        expect($scope.transitionTo).toHaveBeenCalledWith('activation-key.info',
                                                         {activationKeyId: $scope.activationKey.id})
    });

    it('should fail to save a new activation key resource', function() {
        var activationKey = $scope.activationKey;

        activationKey.failed = true;
        spyOn(activationKey, '$save').and.callThrough();
        $scope.save(activationKey);

        expect(activationKey.$save).toHaveBeenCalled();
        expect($scope.activationKeyForm['name'].$invalid).toBe(true);
        expect($scope.activationKeyForm['name'].$error.messages).toBeDefined();
    });

    it("should fetch content views", function () {
        $httpBackend.expectGET('/organizations/default_label?name=Test+Resource').respond('changed_name');
        spyOn(ContentView, 'queryUnpaged');
        $scope.activationKey.environment = paths[0][0];
        $scope.$apply();

        expect(ContentView.queryUnpaged).toHaveBeenCalled();
    });

});
