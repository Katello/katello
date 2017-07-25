describe('Controller: ContentHostDetailsInfoController', function() {
    var $scope,
        $controller,
        translate,
        Host,
        mockContentViews;

    beforeEach(module(
        'Bastion.content-hosts',
        'Bastion.host-collections',
        'Bastion.test-mocks',
        'content-hosts/details/views/content-host-info.html',
        'content-hosts/views/content-hosts.html'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q'),
            $http = $injector.get('$http'),
            ContentView = $injector.get('MockResource').$new(),
            Organization = $injector.get('MockResource').$new();

        Host = $injector.get('MockResource').$new();
        $scope = $injector.get('$rootScope').$new();

        ContentView.queryUnpaged = function(){};


        Organization.readableEnvironments = function(params, callback) {
            var response = [[{name: 'Library', id: 1}]];

            if (callback) {
                callback.apply(this, response);
            }

            return response;
        };

        translate = function(message) {
            return message;
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

        $scope.saveContentFacet = $scope.save;

        $scope.host = new Host({
            id: 2,
            facts: {
                cpu: "Itanium",
                "lscpu.architecture": "Intel Itanium architecture",
                "lscpu.instructionsPerCycle": "6",
                anotherFact: "yes"
            },
            content_facet_attributes: {
                lifecycle_environment: {
                    id: 1
                },
                content_view: {
                    id: 2
                }
            },
            subscription_facet_attributes: {'virtual_guests': []},
            hasContent: function() { return true; }
        });

        $scope.host.$promise = {then: function (callback) { callback($scope.host); }};

        $controller('ContentHostDetailsInfoController', {
            $scope: $scope,
            $q: $q,
            translate: translate,
            Host: Host,
            ContentView: ContentView,
            Organization: Organization,
            CurrentOrganization: 'ACME_Corporation'
        });
    }));

    it("gets the available release versions and puts them on the $scope", function() {
        Host.releaseVersions = function(params, callback) {
            callback.apply(this, [['RHEL6']]);
        };
        spyOn(Host, 'releaseVersions').and.returnValue(['RHEL6']);

        $scope.releaseVersions().then(function(releases) {
            expect(releases).toEqual(['RHEL6']);
        });
    });

    it("sets edit mode to false when saving a content view", function() {
        $scope.saveContentView($scope.host);

        expect($scope.editContentView).toBe(false);
    });

    it("builds list of guest ids", function () {
        $scope.host.subscription_facet_attributes['virtual_guests'] = [{ id: 2, name: "guest2" }, { id: 3, name: "guest3"}];
        expect($scope.virtualGuestIds($scope.host)).toEqual("name = guest2 or name = guest3");
    });

    it('provides a method to retrieve available content views for a content host', function() {
        var promise = $scope.contentViews();

        promise.then(function(contentViews) {
            expect(contentViews).toEqual(mockContentViews);
        });
    });

    it('should set the environment and force a content view to be selected', function() {
        $scope.host.content_facet_attributes.lifecycle_environment = {name: 'Dev', id: 2};
        $scope.$digest();

        expect($scope.host.content_facet_attributes.lifecycle_environment.id).toBe(2);
        expect($scope.originalEnvironment.id).toBe(1);
        expect($scope.editContentView).toBe(true);
        expect($scope.disableEnvironmentSelection).toBe(true);
    });

    it('should reset the content host environment when cancelling a content view update', function() {
        $scope.editContentView = true;
        $scope.originalEnvironment.id = 2;
        $scope.cancelContentViewUpdate();

        expect($scope.host.content_facet_attributes.lifecycle_environment.id).toBe(2);
        expect($scope.editContentView).toBe(false);
    });
});
