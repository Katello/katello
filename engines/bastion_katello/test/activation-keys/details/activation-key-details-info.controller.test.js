describe('Controller: ActivationKeyDetailsInfoController', function() {
    var $scope,
        ActivationKey;

    beforeEach(module(
        'Bastion.activation-keys',
        'Bastion.test-mocks',
        'activation-keys/details/views/activation-key-info.html',
        'activation-keys/views/activation-keys.html'

    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q'),
            ContentView = $injector.get('MockResource').$new(),
            Organization = $injector.get('MockResource').$new();

        ActivationKey = $injector.get('MockResource').$new();
        $scope = $injector.get('$rootScope').$new();

        ContentView.queryUnpaged = function(){};

        Organization.readableEnvironments = function(params, callback) {
            var response = [[{name: 'Library', id: 1}]];

            if (callback) {
                callback.apply(this, response);
            }

            return response;
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

        $scope.activationKey = new ActivationKey({
            id: 2,
            purpose_usage: "test usage",
            purpose_role: "test role",
            purpose_addons: ["test addon1"],

            hasContent: function() { return true; }
        });
        $scope.activationKey.$promise = {then: function (callback) { callback($scope.activationKey); }};

        $controller('ActivationKeyDetailsInfoController', {
            $scope: $scope,
            $q: $q,
            ActivationKey: ActivationKey,
            ContentView: ContentView,
            Organization: Organization,
            CurrentOrganization: 'Default_Organization'
        });
    }));

    it("gets the available release versions and puts them on the $scope", function() {
        ActivationKey.releaseVersions = function(params, callback) {
            callback.apply(this, [['RHEL6']]);
        };
        spyOn(ActivationKey, 'releaseVersions').and.returnValue(['RHEL6']);

        $scope.releaseVersions().then(function(releases) {
            expect(releases).toEqual(['RHEL6']);
        });
    });

    it("sets edit mode to false when saving a content view", function() {
        $scope.saveContentView($scope.activationKey);

        expect($scope.editContentView).toBe(false);
    });

    it('should clear usage', function() {
        $scope.clearUsage();
        expect($scope.activationKey['purpose_usage']).toBe('');
    });

    it('should clear role', function() {
        $scope.clearRole();
        expect($scope.activationKey['purpose_role']).toBe('');
    });

    it('should clear addOns', function() {
        $scope.clearAddOns();
        expect($scope.activationKey['purpose_addons']).toEqual([]);
    });

});