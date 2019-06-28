describe('Controller: ActivationKeyDetailsController', function() {
    var $scope,
        $controller,
        ActivationKey,
        CurrentOrganization,
        Organization,
        mockOrg,
        mockActivationKey;

    beforeEach(module(
        'Bastion.activation-keys',
        'Bastion.organizations',
        'activation-keys/views/activation-keys.html'));

    beforeEach(inject(function(_$controller_, $rootScope, $state, $injector) {
        $controller = _$controller_;
        $scope = $rootScope.$new();
        $httpBackend = $injector.get('$httpBackend');

        mockOrg = {
            id: '1',
            system_purposes: {
                roles: ['custom-role'],
                usage: ['custom-usage'],
                addons: ['custom-addon']
            }
        }

        Organization = $injector.get('Organization');
        spyOn(Organization, 'get').and.callThrough();
        $httpBackend.expectGET('/katello/api/v2/organizations/1').respond(mockOrg);

        CurrentOrganization = '1';

        mockActivationKey = {
            id: 1,
            purpose_usage: 'current-usage',
            purpose_role: 'current-role',
            purpose_addons: ['current-addon'],
            $update: function (success, error) {
                if (mockActivationKey.failed) {
                    error({data: {error: {full_messages: ['error!']}}});
                } else {
                    success(mockActivationKey);
                }
            }
        };

        ActivationKey = {
            failed: false,
            get: function (params, callback) {
                callback(mockActivationKey);
                return mockActivationKey;
            },
            update: function (data, success, error) {
                if (this.failed) {
                    error({data: {error: {full_messages: ['error!']}}});
                } else {
                    success(mockActivationKey);
                }
            },
            delete: function (success, error) {success();},
            $promise: { then: function (callback) {callback(mockActivationKey);}}
        };

        $scope.$stateParams = {activationkeyId: mockActivationKey.id};

        $controller('ActivationKeyDetailsController', {
            $scope: $scope,
            $state: $state,
            ActivationKey: ActivationKey,
            CurrentOrganization: CurrentOrganization,
            Organization: Organization
        });
    }));

    it("provides a list of system purpose roles", function() {
        $scope.purposeRoles().then(function(roles) {
            expect(roles.sort()).toEqual(['Red Hat Enterprise Linux Server', 'Red Hat Enterprise Linux Workstation',
                'Red Hat Enterprise Linux Compute Node', 'custom-role', 'current-role'].sort());
        });
        $httpBackend.flush();
    });

    it("provides a list of system purpose usages", function() {
        $scope.purposeUsages().then(function(usages) {
            expect(usages.sort()).toEqual(['Production', 'Development/Test', 'Disaster Recovery',
                'custom-usage', 'current-usage'].sort());
        });
        $httpBackend.flush();
    });

    it("provides a list of system purpose addons", function() {
        $scope.purposeAddons().then(function(addons) {
            expect(addons).toEqual([
                {name: 'custom-addon', selected: false},
                {name: 'current-addon', selected: true},
            ]);
        });
        $httpBackend.flush();
    });
});


