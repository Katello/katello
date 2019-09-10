describe('Controller: CapsuleContentController', function() {
    var $scope,
        translate,
        CapsuleContent,
        syncState,
        deferred;


    beforeEach(module(
        'Bastion.capsule-content',
        'Bastion.test-mocks'
    ));

    beforeEach(inject(function($injector, $q) {
        var $controller = $injector.get('$controller'),
            $urlMatcherFactory = $injector.get('$urlMatcherFactory'),
            $location = { path: function(){ return '/smart_proxies/83' } },
            AggregateTask = { new: function(){} }

        deferred = $q.defer();

        var syncStatusData = {
            active_sync_tasks: [],
            last_failed_sync_tasks: []
        }

        CapsuleContent = $injector.get('MockResource').$new();
        CapsuleContent.syncStatus = function (params, callback) {
            var statusDeferred = $q.defer();
            statusDeferred.resolve(syncStatusData);
            return { $promise: statusDeferred.promise };
        }
        CapsuleContent.cancelSync = function (params, callback) {
            return { $promise: deferred.promise };
        }
        CapsuleContent.sync = function (params) {
            return { $promise: deferred.promise };
        }

        translate = function (message) {
            return message;
        };

        $scope = $injector.get('$rootScope').$new();

        $controller('CapsuleContentController', {
            $scope: $scope,
            $urlMatcherFactory: $urlMatcherFactory,
            $location: $location,
            translate: translate,
            CapsuleContent: CapsuleContent,
            AggregateTask: AggregateTask
        });
        $scope.$apply();

        syncState = $scope.syncState;
        syncState.set(syncState.DEFAULT);
    }));

    describe('productsOrVersionUrl', function() {
        it('returns the correct url if default CV', function() {
            expect($scope.productsOrVersionUrl(true, 1)).toBe("/products")
        });

        it('returns the correct url if not default CV', function() {
            expect($scope.productsOrVersionUrl(false, 2)).toBe("/content_views/2/versions")
        });
    });

    describe('syncCapsule', function() {
        it('has no effect when sync is in progress', function() {
            spyOn(CapsuleContent, 'sync').and.callThrough();
            syncState.set(syncState.SYNCING);
            $scope.syncCapsule(false);
            expect(CapsuleContent.sync).not.toHaveBeenCalled();
        });

        it('starts capsule synchronization', function() {
            spyOn(CapsuleContent, 'sync').and.callThrough();
            $scope.syncCapsule(false);
            expect(CapsuleContent.sync).toHaveBeenCalledWith({ id: '83', 'skip_metadata_check': false });
        });

        it('starts capsule synchronization with skip metadata option', function() {
            spyOn(CapsuleContent, 'sync').and.callThrough();
            $scope.syncCapsule(true);
            expect(CapsuleContent.sync).toHaveBeenCalledWith({ id: '83', 'skip_metadata_check': true });
        });

        it('sets state to SYNC_TRIGGERED', function() {
            $scope.syncCapsule(false);
            expect(syncState.is(syncState.SYNC_TRIGGERED)).toBeTruthy();
        });

        it('sets state to SYNCING when the response is successful', function() {
            $scope.syncCapsule(false);
            deferred.resolve({id: '1'});
            $scope.$apply();

            expect(syncState.is(syncState.SYNCING)).toBeTruthy();
        });


        it('adds task to active_sync_tasks when the response is successful', function() {
            var taskCount = $scope.syncStatus['active_sync_tasks'].length;

            $scope.syncCapsule(false);
            deferred.resolve({id: '1'});
            $scope.$apply();

            expect($scope.syncStatus['active_sync_tasks'].length).toBe(taskCount + 1);
        });

        it('sets state to DEFAULT when there is some error', function() {
            $scope.syncCapsule(false);
            deferred.reject({});
            $scope.$apply();

            expect(syncState.is(syncState.DEFAULT)).toBeTruthy();
        });
    });

    describe('cancelSync', function() {
        it('has no effect when sync is not in progress', function() {
            spyOn(CapsuleContent, 'cancelSync').and.callThrough();
            $scope.cancelSync();
            expect(CapsuleContent.cancelSync).not.toHaveBeenCalled();
        });

        it('tries to cancel the sync', function() {
            spyOn(CapsuleContent, 'cancelSync').and.callThrough();
            syncState.set(syncState.SYNCING);
            $scope.cancelSync();
            expect(CapsuleContent.cancelSync).toHaveBeenCalledWith({ id: '83' });
        });

        it('sets state to CANCEL_TRIGGERED', function() {
            spyOn(CapsuleContent, 'cancelSync').and.callThrough();
            syncState.set(syncState.SYNCING);
            $scope.cancelSync();
            expect(syncState.is(syncState.CANCEL_TRIGGERED)).toBeTruthy();
        });
    });
});
