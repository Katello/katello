describe('Controller: ContentHostDetailsController', function() {
    var $scope,
        $controller,
        translate,
        Notification,
        Host,
        HostSubscription,
        CurrentOrganization,
        Organization,
        mockOrg,
        MenuExpander,
        mockHost;

    beforeEach(module('Bastion.content-hosts',
                       'content-hosts/views/content-hosts.html'));

    beforeEach(module(function($stateProvider) {
        $stateProvider.state('content-hosts.fake', {});
    }));

    beforeEach(inject(function(_$controller_, $rootScope, $state, $injector) {
        $controller = _$controller_;
        $scope = $rootScope.$new();
        $httpBackend = $injector.get('$httpBackend');

        mockOrg = {
          id: '1',
          service_levels: ['Premium'],
          system_purposes: {
            roles: ['custom-role'],
            usage: ['custom-usage'],
            addons: ['custom-addon']
          }
        }

        Organization = $injector.get('Organization');
        spyOn(Organization, 'get').and.callThrough();
        $httpBackend.expectGET('/katello/api/v2/organizations/1').respond(mockOrg);

        translate = function(message) {
            return message;
        };

        Notification = {
            setSuccessMessage: function () {},
            setErrorMessage: function () {}
        };

        CurrentOrganization = '1';

        mockHost = {
            failed: false,
            id: 1,
            hasSubscription: function(){ return true; },
            facts: {
                cpu: "Itanium",
                "lscpu.architecture": "Intel Itanium architecture",
                "lscpu.instructionsPerCycle": "6",
                anotherFact: "yes"
            },
            subscription: {uuid: 'abcd-1234'},
            subscription_facet_attributes: {
              id: 101,
              release_version: '7Server',
              autoheal: true,
              service_level: 'Premium',
              purpose_role: 'current-role',
              purpose_usage: 'current-usage',
              purpose_addons: ['current-addon']
            },

            $update: function(success, error) {
                if (mockHost.failed) {
                    error({data: {error: {full_messages: ['error!']}}});
                } else {
                    success(mockHost);
                }
            }
        };

        Host = {
            failed: false,
            get: function(params, callback) {
                callback(mockHost);
                return mockHost;
            },
            update: function (data, success, error) {
                if (this.failed) {
                    error({data: {error: {full_messages: ['error!']}}});
                } else {
                    success(mockHost);
                }
            },
            delete: function (success, error) {success()},
            $promise: {then: function(callback) {callback(mockHost)}}
        };

        HostSubscription = {
            'delete': function (parmas, success, error) {success()}
        };

        MenuExpander = {};

        spyOn(Host, 'get').and.callThrough();

        $scope.$stateParams = {hostId: mockHost.id};

        $controller('ContentHostDetailsController', {
            $scope: $scope,
            $state: $state,
            translate: translate,
            Notification: Notification,
            Host: Host,
            CurrentOrganization: CurrentOrganization,
            Organization: Organization,
            HostSubscription: HostSubscription,
            MenuExpander: MenuExpander
        });
    }));

    describe("saveSubscriptionFacet()", function() {
        var expectedHost;

        beforeEach(function() {
            expectedHost = {
                id: 1,
                subscription_facet_attributes: {
                  id: 101,
                  autoheal: true,
                  purpose_role: 'current-role',
                  purpose_usage: 'current-usage',
                  service_level: 'Premium',
                  release_version: '7Server',
                }
            };
        });

        it("sends purpose addons when they are set", function() {
          spyOn($scope, 'save');
          $scope.purposeAddonsList = [
              {name: "Addon1", selected: true},
              {name: "Addon2", selected: false},
          ];
          expectedHost['subscription_facet_attributes']['purpose_addons'] = ['Addon1'];

          $scope.saveSubscriptionFacet(mockHost);

          expect($scope.save).toHaveBeenCalledWith(expectedHost, true);
        });

        it ("doesn't send addons when they aren't set", function() {
          spyOn($scope, 'save');

          $scope.saveSubscriptionFacet(mockHost);

          expect($scope.save).toHaveBeenCalledWith(expectedHost, true);
        });
    });

    it("sets the menu expander on the scope", function() {
        expect($scope.menuExpander).toBe(MenuExpander);
    });

    it("attaches an organization to the scope", function() {
        expect(Organization.get).toHaveBeenCalledWith({id: '1'}, jasmine.any(Function));
        expect($scope.organization).toBeDefined();
    });

    it("provides a list of service levels", function() {
        $scope.serviceLevels().then(function(service_levels) {
            expect(service_levels.sort()).toEqual(['Self-Support', 'Standard', 'Premium'].sort());
        });
        $httpBackend.flush();
    });

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

    it("gets the host using the Host service and puts it on the $scope.", function() {
        expect(Host.get).toHaveBeenCalledWith({id: mockHost.id}, jasmine.any(Function), jasmine.any(Function));
        expect($scope.host).toBe(mockHost);
    });

    it('provides a method to transition states when a host is present', function() {
        expect($scope.transitionTo('content-hosts.fake')).toBeTruthy();
    });

    it('should save the host and return a promise', function() {
        var promise = $scope.save(mockHost);

        expect(promise.then).toBeDefined();
    });

    it('should save the host successfully', function() {
        spyOn(Notification, 'setSuccessMessage');
        $scope.save(mockHost);
        expect(Notification.setSuccessMessage).toHaveBeenCalled();
    });

    it('should fail to save the host', function() {
        spyOn(Notification, 'setErrorMessage');

        Host.failed = true;
        $scope.save(mockHost);

        expect(Notification.setErrorMessage).toHaveBeenCalled();
    });


    it("provides a way to unregister content hosts.", function() {
        var testHost = {
            id: 123,
            unregisterDelete: false
        };

        spyOn($scope, "transitionTo");
        spyOn(HostSubscription, 'delete').and.callThrough();

        $scope.unregisterContentHost(testHost);

        expect(HostSubscription.delete).toHaveBeenCalledWith({'id': 123}, jasmine.any(Function), jasmine.any(Function));
        expect($scope.transitionTo).toHaveBeenCalledWith('content-hosts');

    });

    it("provides a way to delete a host.", function() {
        var testHost = {
            id: 123,
            '$delete': function(callback) {
                callback();
            },
            unregisterDelete: true
        };

        spyOn($scope, "transitionTo");
        spyOn(testHost, '$delete').and.callThrough();

        $scope.unregisterContentHost(testHost);
        expect(testHost.$delete).toHaveBeenCalled();
        expect($scope.transitionTo).toHaveBeenCalledWith('content-hosts');
    });
});
