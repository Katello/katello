describe('Controller: HostCollectionDetailsController', function() {
    var $scope, selected, translate, Notification, HostCollection, newHostCollection, newHost, Host,ContentHostsModalHelper;

    beforeEach(module('Bastion.host-collections', 'Bastion.test-mocks'));
    beforeEach(function() {
        selected = {included: {ids: [1, 2, 3]}};
    });
    beforeEach(inject(function($injector) {
        var ApiErrorHandler = $injector.get('ApiErrorHandler');
        var $controller = $injector.get('$controller'),
            $state = $injector.get('$state');

        newHostCollection = {id: 8};
        HostCollection = $injector.get('MockResource').$new();
        newHost = {
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
                if (newHost.failed) {
                    error({data: {error: {full_messages: ['error!']}}});
                } else {
                    success(newHost);
                }
            }
        };
        Host = {
            failed: false,
            get: function(params, callback) {
                callback(newHost);
                return newHost;
            },
            update: function (data, success, error) {
                if (this.failed) {
                    error({data: {error: {full_messages: ['error!']}}});
                } else {
                    success(newHost);
                }
            },
            delete: function (success, error) {success()},
            $promise: {then: function(callback) {callback(newHost)}}
        };

        Notification = {
            setSuccessMessage: function () {},
            setErrorMessage: function () {}
        };

        $scope = $injector.get('$rootScope').$new();
        $scope.$stateParams = {hostCollectionId: 1};
        $scope.selected = selected;
        $scope.removeRow = function() {};
        $scope.table = {
            addRow: function() {},
            replaceRow: function() {}
        };

        translate = function(message) {
            return message;
        };
        ContentHostsModalHelper ={
            resolveFunc: function(){},
            openHostCollectionsModal : function () {},
            openPackagesModal :function () {},
            openErrataModal : function () {},
            openEnvironmentModal : function () {},
            openSubscriptionsModal : function (){}
        };

        $controller('HostCollectionDetailsController', {
            $scope: $scope,
            $state: $state,
            translate: translate,
            Notification: Notification,
            Host: Host,
            HostCollection: HostCollection,
            ContentHostsModalHelper: ContentHostsModalHelper,
            ApiErrorHandler: ApiErrorHandler
        });
    }));

    it("gets the content host using the host collection service and puts it on the $scope.", function() {
        expect($scope.hostCollection).toBeDefined();
    });

    it('provides a method to remove a host collection', function() {
        spyOn($scope, 'transitionTo');

        $scope.removeHostCollection($scope.hostCollection);

        expect($scope.transitionTo).toHaveBeenCalledWith('host-collections');
    });

    it('should save the product successfully', function() {
        spyOn(Notification, 'setSuccessMessage');

        $scope.save($scope.hostCollection);

        expect(Notification.setSuccessMessage).toHaveBeenCalled();
    });

    it('should fail to save the host collection', function() {
        spyOn(Notification, 'setErrorMessage');

        $scope.hostCollection.failed = true;
        $scope.save($scope.hostCollection);

        expect(Notification.setErrorMessage).toHaveBeenCalled();
    });

    it("should be able to raise the host collection event on the .", function() {
        var eventRaised = false;
        $scope.$on("updateContentHostCollection", function (event, hostCollectionRow) {
             eventRaised = true;
        });
        $scope.refreshHostCollection();
        expect(eventRaised).toBe(true);
    });


});