describe('Controller: ContentHostDetailsController', function() {
    var $scope,
        $controller,
        translate,
        Host,
        HostSubscription,
        Organization,
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

        translate = function(message) {
            return message;
        };

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

            $update: function(success, error) {
                if (mockHost.failed) {
                    error({ data: {errors: ['error!']}});
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
                    error({data: {errors: ['error']}});
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

        Organization = {};
        MenuExpander = {};

        spyOn(Host, 'get').andCallThrough();

        $scope.$stateParams = {hostId: mockHost.id};
        $scope.removeRow = function(){};

        $controller('ContentHostDetailsController', {
            $scope: $scope,
            $state: $state,
            translate: translate,
            Host: Host,
            Organization: Organization,
            HostSubscription: HostSubscription,
            GlobalNotification: $injector.get('GlobalNotification'),
            MenuExpander: MenuExpander
        });
    }));

    it("sets the menu expander on the scope", function() {
        expect($scope.menuExpander).toBe(MenuExpander);
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
        $scope.save(mockHost);

        expect($scope.successMessages.length).toBe(1);
        expect($scope.errorMessages.length).toBe(0);
    });

    it('should fail to save the host', function() {
        Host.failed = true;
        $scope.save(mockHost);

        expect($scope.successMessages.length).toBe(0);
        expect($scope.errorMessages.length).toBe(1);
    });


    it("provides a way to unregister content hosts.", function() {
        var testHost = {
            id: 123,
            unregisterDelete: false
        };

        spyOn($scope, "transitionTo");
        spyOn(HostSubscription, 'delete').andCallThrough();

        $scope.unregisterContentHost(testHost);

        expect(HostSubscription.delete).toHaveBeenCalledWith({'id': 123}, jasmine.any(Function), jasmine.any(Function));
        expect($scope.transitionTo).toHaveBeenCalledWith('content-hosts.index');

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
        spyOn($scope, "removeRow");
        spyOn(testHost, '$delete').andCallThrough();

        $scope.unregisterContentHost(testHost);
        expect(testHost.$delete).toHaveBeenCalled();
        expect($scope.removeRow).toHaveBeenCalled();
        expect($scope.transitionTo).toHaveBeenCalledWith('content-hosts.index');
    });
});
