describe('Controller: ManifestImportController', function() {
    var $scope, organization, history, $q, Task, Organization, Subscription;

    beforeEach(module(
        'Bastion.subscriptions',
        'Bastion.test-mocks'
    ));

    beforeEach(module(function($provide) {
        provider = {
            name: "Red Hat",
            id: 1
        };

        organization = {
            name: "ACME",
            id: 1,
            owner_details: {
                upstreamConsumer: {
                    uuid: 'borges',
                    name: 'uqbar_tlon',
                    webUrl: 'http://redhat.com'
                }
            }
        };

        history = ["first", "second", "third", "fourth"];
        $provide.value('CurrentOrganization', 'ACME');

    }));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $httpBackend = $injector.get('$httpBackend'),
            translate;
        Organization = $injector.get('Organization');
        Subscription = $injector.get('Subscription');
        GlobalNotification = $injector.get('GlobalNotification');

        $httpBackend.expectGET('/api/organization/ACME/subscriptions/manifest_history').respond([]);
        $httpBackend.expectGET('/api/v2/organizations/ACME/redhat_provider').respond({name: "Red Hat"});
        $httpBackend.expectGET('/api/organization/ACME').respond(organization);
        $httpBackend.expectGET('/api/v2/organizations/ACME/redhat_provider').respond({name: "Red Hat"});

        $scope = $injector.get('$rootScope').$new();
        $q = $injector.get('$q');
        $scope.redhatProvider = Organization.redhatProvider();
        $scope.histories = Subscription.manifestHistory();

        spyOn(GlobalNotification, "setSuccessMessage");
        spyOn(GlobalNotification, "setErrorMessage");

        Task = {registerSearch: function() {}, unregisterSearch: function () {}};

        translate = function(a) { return a };

        $controller('ManifestImportController', {
            $scope: $scope,
            $q: $q,
            translate: translate,
            CurrentOrganization: "ACME",
            Organization: Organization,
            Subscription: Subscription,
            Task: Task,
            GlobalNotification: GlobalNotification
        });
    }));

    it('should attach organization to the scope', function() {
        expect($scope.organization).toBeDefined();
    });

    it('should provide a method to determine if a task is pending', function () {
        expect($scope.isTaskPending()).toBe(false);

        $scope.task = {pending: true};
        expect($scope.isTaskPending()).toBe(true);

        $scope.task = null;
        $scope.deleteTask = {pending: true};
        expect($scope.isTaskPending()).toBe(true);
    });

    it('should provide a method for getting manifest history info', function() {
        $q.all([$scope.organization.$promise]).then(function () {
            expect($scope.manifestStatuses.length).toBe(3);
            expect($scope.showHistoryMoreLink).toBe(true);
            expect($scope.upstream).toBe(organization.owner_details.upstreamConsumer);
            expect($scope.manifestLink).toEqual('http://redhat.com/borges');
            expect($scope.manifestName).toEqual('uqbar_tlon');
        });
    });

    it('should provide a method to save cdnUrl in a provider', function() {
        var promise;
        $httpBackend.expectPUT('/api/v2/organizations/ACME/');
        promise = $scope.saveCdnUrl($scope.organization);
        promise.then(function() {
            expect(GlobalNotification.setErrorMessage).not.toHaveBeenCalled();
            expect(GlobalNotification.setSuccessMessage).toHaveBeenCalled();
        });
    });

    it('should provide a method to delete a manifest', function() {
        $httpBackend.expectPOST('/api/v2/organizations/ACME/subscriptions/delete_manifest');
        spyOn(Subscription, 'deleteManifest').and.callThrough();
        $scope.deleteManifest($scope.organization);
        $q.all([$scope.organization.$promise]).then(function () {
            expect(GlobalNotification.setErrorMessage).not.toHaveBeenCalled();
            expect(GlobalNotification.setSuccessMessage).toHaveBeenCalled();
        });
    });

    it('should provide a method to refresh a manifest', function() {
        $httpBackend.expectPOST('/api/v2/organizations/ACME/subscriptions/refresh_manifest');
        spyOn(Subscription, 'refreshManifest').and.callThrough();
        $scope.refreshManifest($scope.organization);
        $q.all([$scope.organization.$promise]).then(function () {
            expect(GlobalNotification.setErrorMessage).not.toHaveBeenCalled();
            expect(GlobalNotification.setSuccessMessage).toHaveBeenCalled();
        });
    });

    it('should set an error message if a manifest upload status is not success', function() {
        $q.all([$scope.organization.$promise]).then(function () {
            $scope.uploadManifest('<pre>"There was an error"</pre>', true);

            expect(GlobalNotification.setSuccessMessage).not.toHaveBeenCalled();
            expect($scope.uploadErrorMessages.length).toBe(1);
        });
    });

    it('should set an error message if there was a 413 response', function() {
        $q.all([$scope.organization.$promise]).then(function () {
            $scope.uploadManifest('Could not parse JSON', 'Request Entity Too Large');

            expect(GlobalNotification.setSuccessMessage).not.toHaveBeenCalled();
            expect($scope.uploadErrorMessages.length).toBe(1);
            expect($scope.uploadErrorMessages[0]).toBe("Error during upload: File too large.");
        });
    });

    it('should set the upload status to success and refresh data if upload status is success', function() {
        $q.all([$scope.organization.$promise]).then(function () {
            spyOn($scope, 'refreshTable');
            $scope.uploadManifest('<pre>{"status": "success"}</pre>', true);

            expect($scope.saveSuccess).toBe(true);
            expect($scope.uploadErrorMessages.length).toBe(0);
            expect(GlobalNotification.setSuccessMessage).toHaveBeenCalled();
            expect($scope.refreshTable).toHaveBeenCalled();
        });
    });

    it('should refresh organization info when requested', function () {
        spyOn(Organization, 'get').and.callThrough();
        $scope.refreshOrganizationInfo();
        expect(Organization.get).toHaveBeenCalled();
    });

    it('should truncate the histories', function () {
        var histories = [{}, {}, {}, {}, {}];
        var result = $scope.truncateHistories($scope.histories);
        expect(result.length).toBeLessThan(histories.length);
    });
});
