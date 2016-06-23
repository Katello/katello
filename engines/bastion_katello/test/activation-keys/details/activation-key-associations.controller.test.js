describe('Controller: ActivationKeyAssociationsController', function() {
    var $scope,
        ActivationKey,
        CurrentOrganization,
        Host,
        translate;

    beforeEach(module(
        'Bastion.activation-keys',
        'Bastion.test-mocks'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            ActivationKey = $injector.get('MockResource').$new(),
            Host  = $injector.get('MockResource').$new();

        translate = function (message) {
            return message;
        };

        $scope = $injector.get('$rootScope').$new();

        ActivationKey = {
            contentHosts: function (params, callback) {
                return {};
            }
        };
        $scope.table = {
            working: true
        };
        $scope.activationKey = {};
        $scope.activationKey.$promise = { then: function (callback) { callback({}) } };

        $scope.$stateParams = {activationKeyId: 1};

        $controller('ActivationKeyAssociationsController', {
            $scope: $scope,
            translate: translate,
            ActivationKey: ActivationKey,
            Host: Host,
            ContentHostsHelper: {},
            CurrentOrganization: "ACME"
        });
    }));

    it('should attach a activation-key resource onto the scope', function() {
        expect($scope.activationKey).toBeDefined();
    });

});
