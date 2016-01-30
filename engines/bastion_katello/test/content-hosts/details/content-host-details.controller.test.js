describe('Controller: ContentHostDetailsController', function() {
    var $scope,
        $controller,
        translate,
        ContentHost,
        Host,
        Organization,
        MenuExpander,
        mockContentHost,
        mockHost;

    beforeEach(module('Bastion.content-hosts',
                       'content-hosts/views/content-hosts.html'));

    beforeEach(module(function($stateProvider) {
        $stateProvider.state('content-hosts.fake', {});
    }));

    beforeEach(inject(function(_$controller_, $rootScope, $state) {
        $controller = _$controller_;
        $scope = $rootScope.$new();

        state = {
            transitionTo: function() {}
        };

        translate = function(message) {
            return message;
        };

        mockContentHost = {
            failed: false,
            uuid: "abcd-1234",
            facts: {
                cpu: "Itanium",
                "lscpu.architecture": "Intel Itanium architecture",
                "lscpu.instructionsPerCycle": "6",
                anotherFact: "yes"
            },
            $update: function(success, error) {
                if (mockContentHost.failed) {
                    error({ data: {errors: ['error!']}});
                } else {
                    success(mockContentHost);
                }
            }
        };

        mockHost = {
            id: 4,
            subscription: {uuid: mockContentHost.uuid},
            content_host_id: mockContentHost.uuid
        };

        Host = {
            get: function(params, callback) {
                callback(mockHost);
                return mockHost;
            },
            $promise: {then: function(callback) {callback(mockHost)}}
        };
        ContentHost = {
            get: function(params, callback) {
                callback(mockContentHost);
                return mockContentHost;
            }
        };

        Organization = {};
        MenuExpander = {};

        spyOn(ContentHost, 'get').andCallThrough();
        spyOn(Host, 'get').andCallThrough();


        $scope.$stateParams = {hostId: mockHost.id};

        $controller('ContentHostDetailsController', {
            $scope: $scope,
            $state: $state,
            translate: translate,
            Host: Host,
            ContentHost: ContentHost,
            Organization: Organization,
            MenuExpander: MenuExpander
        });
    }));

    it("sets the menu expander on the scope", function() {
        expect($scope.menuExpander).toBe(MenuExpander);
    });

    it("gets the content host using the ContentHost service and puts it on the $scope.", function() {
        expect(ContentHost.get).toHaveBeenCalledWith({id: mockContentHost.uuid}, jasmine.any(Function));
        expect($scope.contentHost).toBe(mockContentHost);
    });

    it("gets the host using the Host service and puts it on the $scope.", function() {
        expect(Host.get).toHaveBeenCalledWith({id: mockHost.id}, jasmine.any(Function));
        expect($scope.host).toBe(mockHost);
    });

    it('provides a method to transition states when a content host is present', function() {
        expect($scope.transitionTo('content-hosts.fake')).toBeTruthy();
    });

    it('should save the content host and return a promise', function() {
        var promise = $scope.save(mockContentHost);

        expect(promise.then).toBeDefined();
    });

    it('should save the content host successfully', function() {
        $scope.save(mockContentHost);

        expect($scope.successMessages.length).toBe(1);
        expect($scope.errorMessages.length).toBe(0);
    });

    it('should fail to save the content host', function() {
        mockContentHost.failed = true;
        $scope.save(mockContentHost);

        expect($scope.successMessages.length).toBe(0);
        expect($scope.errorMessages.length).toBe(1);
    });

});
