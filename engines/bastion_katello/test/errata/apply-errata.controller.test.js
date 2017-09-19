describe('Controller: ApplyErrataController', function() {
    var $controller, dependencies, $scope, translate, HostBulkAction, ContentViewVersion, IncrementalUpdate,
        CurrentOrganization;

    beforeEach(module('Bastion.errata', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        $controller = $injector.get('$controller'),

        translate = function (string) {
            return string;
        };

        HostBulkAction = {
            failed: false,
            installContent: function (params, success, error) {
                if (this.failed) {
                    error({data: {errors: ['error']}});
                } else {
                    success({id: 1});
                }
            },
            availableIncrementalUpdates: function () {}
        };

        ContentViewVersion = {
            incrementalUpdate: function (params, success, error) {
                if (this.failed) {
                    error({data: {errors: ['error']}});
                } else {
                    success({id: 1});
                }
            }
        };

        CurrentOrganization = 'foo';

        IncrementalUpdate = {
            canApply: function () {},
            getContentHostIds: function () {},
            getErrataIds: function () {},
            getBulkContentHosts: function () {},
            getIncrementalUpdates: function () {
                return {
                    then: function(cb){
                        cb($scope.updates)
                    }
                }
            }
        };

        $scope = $injector.get('$rootScope').$new();
        $scope.errorMessages = [];
        $scope.successMessages = [];

        dependencies = {
            $scope: $scope,
            translate: translate,
            HostBulkAction: HostBulkAction,
            IncrementalUpdate: IncrementalUpdate,
            ContentViewVersion: ContentViewVersion,
            CurrentOrganization: CurrentOrganization
        };
    }));

    it("sets the errataIds on the scope", function () {
        spyOn(IncrementalUpdate, 'getErrataIds').and.returnValue([2]);
        $controller('ApplyErrataController', dependencies);
        expect(IncrementalUpdate.getErrataIds).toHaveBeenCalled();
        expect($scope.errataIds).toEqual([2]);
    });

    describe("can apply errata", function () {
        var expectedParams, bulkContentHosts;

        bulkContentHosts = {
            included: {
                ids: [1, 2, 3]
            }
        };

        beforeEach(function () {
            spyOn(IncrementalUpdate, 'canApply').and.returnValue(true);
            spyOn(IncrementalUpdate,'getBulkContentHosts').and.returnValue(bulkContentHosts);
            spyOn(IncrementalUpdate, 'getErrataIds').and.returnValue([10]);

            $controller('ApplyErrataController', dependencies);
        });

        afterEach(function () {
            expect(IncrementalUpdate.canApply).toHaveBeenCalled();
            expect(IncrementalUpdate.getErrataIds).toHaveBeenCalled();
            expect(IncrementalUpdate.getBulkContentHosts).toHaveBeenCalled();
        });

        it("by setting the updates on the $scope if there are selected content hosts", function () {
            var updates = ['update'];

            spyOn(HostBulkAction, 'availableIncrementalUpdates').and.callFake(function (params, success) {
                success(updates);
            });
            
            $controller('ApplyErrataController', dependencies);

            expect(HostBulkAction.availableIncrementalUpdates).toHaveBeenCalledWith($scope.selectedContentHosts,
                jasmine.any(Function));
            expect($scope.updates).toEqual(updates);
        });


        describe("if no incremental update is needed", function () {
            beforeEach(function () {
                expectedParams = {
                    included: {ids: [1, 2, 3]},
                    'content_type': 'errata',
                    errata_ids: [10],
                    content: [10],
                    'organization_id': CurrentOrganization
                };

                $scope.updates = [];
                spyOn(HostBulkAction, 'installContent').and.callThrough();
            });

            afterEach(function () {
                expect(HostBulkAction.installContent).toHaveBeenCalledWith(expectedParams, jasmine.any(Function),
                    jasmine.any(Function));
            });

            it("and succeed", function () {
                spyOn($scope, 'transitionTo');
                $scope.confirmApply();

                expect($scope.transitionTo).toHaveBeenCalledWith('errata.tasks.task', {taskId: 1});
                expect($scope.errorMessages.length).toBe(0);
            });

            it("and fail", function () {
                HostBulkAction.failed = true;
                $scope.confirmApply();

                expect($scope.successMessages.length).toBe(0);
                expect($scope.errorMessages.length).toBe(1);
                expect($scope.errorMessages[0]).toBe('error');
            });
        });

        describe("if an incremental update is needed", function () {
            beforeEach(function () {
                expectedParams = {
                    'add_content': {
                        'errata_ids': [10]
                    },
                    'content_view_version_environments': [{
                        'content_view_version_id': 1,
                        'environment_ids': [2]
                    }],
                    'resolve_dependencies': true
                };

                $scope.updates = [{
                    'content_view_version': {id: 1},
                    environments: [{id: 2}]
                }];

                spyOn(ContentViewVersion, 'incrementalUpdate').and.callThrough();
            });

            afterEach(function () {
                expect(ContentViewVersion.incrementalUpdate).toHaveBeenCalledWith(expectedParams, jasmine.any(Function),
                    jasmine.any(Function));
            });

            it("and succeed", function () {
                spyOn($scope, 'transitionTo');

                $scope.confirmApply();

                expect($scope.transitionTo).toHaveBeenCalledWith('errata.tasks.task', {taskId: 1});
                expect($scope.errorMessages.length).toBe(0);
                expect($scope.hasComposites($scope.updates)).toBeFalsy();
            });

            it("and fail", function () {
                ContentViewVersion.failed = true;
                $scope.confirmApply();

                expect($scope.successMessages.length).toBe(0);
                expect($scope.errorMessages.length).toBe(1);
                expect($scope.errorMessages[0]).toBe('error');
            });

            it("can pass a parameter to update the content hosts", function () {
                expectedParams['update_hosts'] = {included: {ids: [1, 2, 3]}, errata_ids: [ 10 ],
                    organization_id: 'foo', content_type: 'errata', content: [ 10 ]};
                $scope.applyErrata = true;

                $scope.confirmApply();
            });
        });

        describe("if an incremental update is needed with composites", function () {
            beforeEach(function () {
                expectedParams = {
                    'add_content': {
                        'errata_ids': [10]
                    },
                    'content_view_version_environments': [{
                        'content_view_version_id': 1,
                        'environment_ids': [2]
                    },{
                        'content_view_version_id': 5,
                        'environment_ids': []
                    }],
                    'resolve_dependencies': true
                };

                $scope.updates = [{
                    'content_view_version': {id: 1},
                    environments: [{id: 2}],
                    components: [{id: 5}]
                }];

                spyOn(ContentViewVersion, 'incrementalUpdate').and.callThrough();
            });

            afterEach(function () {
                expect(ContentViewVersion.incrementalUpdate).toHaveBeenCalledWith(jasmine.any(Object), jasmine.any(Function),
                    jasmine.any(Function));
                expect(ContentViewVersion.incrementalUpdate.calls.mostRecent().args[0]['add_content']).toEqual(expectedParams['add_content'])
                expect(ContentViewVersion.incrementalUpdate.calls.mostRecent().args[0]['content_view_version_environments']).toContain(expectedParams['content_view_version_environments'][0])
                expect(ContentViewVersion.incrementalUpdate.calls.mostRecent().args[0]['content_view_version_environments']).toContain(expectedParams['content_view_version_environments'][1])
                expect(ContentViewVersion.incrementalUpdate.calls.mostRecent().args[0]['resolve_dependencies']).toEqual(expectedParams['resolve_dependencies'])
            });

            it("and succeed", function () {
                spyOn($scope, 'transitionTo');

                $scope.confirmApply();

                expect($scope.transitionTo).toHaveBeenCalledWith('errata.tasks.task', {taskId: 1});
                expect($scope.errorMessages.length).toBe(0);
                expect($scope.hasComposites($scope.updates)).toBeTruthy();
            });
        });

        describe("if an incremental update is needed with composites and component", function () {
            beforeEach(function () {
                expectedParams = {
                    'add_content': {
                        'errata_ids': [10]
                    },
                    'content_view_version_environments': [{
                        'content_view_version_id': 1,
                        'environment_ids': [2]
                    },{
                        'content_view_version_id': 5,
                        'environment_ids': [99]
                    }],
                    'resolve_dependencies': true
                };

                $scope.updates = [{
                    'content_view_version': {id: 1},
                    environments: [{id: 2}],
                    components: [{id: 5}]
                },{
                    'content_view_version': {id: 5},
                    environments: [{id: 99}],
                    components: undefined
                }];

                spyOn(ContentViewVersion, 'incrementalUpdate').and.callThrough();
            });

            afterEach(function () {
                expect(ContentViewVersion.incrementalUpdate).toHaveBeenCalledWith(jasmine.any(Object), jasmine.any(Function),
                    jasmine.any(Function));
                expect(ContentViewVersion.incrementalUpdate.calls.mostRecent().args[0]['add_content']).toEqual(expectedParams['add_content'])
                expect(ContentViewVersion.incrementalUpdate.calls.mostRecent().args[0]['content_view_version_environments']).toContain(expectedParams['content_view_version_environments'][0])
                expect(ContentViewVersion.incrementalUpdate.calls.mostRecent().args[0]['content_view_version_environments']).toContain(expectedParams['content_view_version_environments'][1])
                expect(ContentViewVersion.incrementalUpdate.calls.mostRecent().args[0]['resolve_dependencies']).toEqual(expectedParams['resolve_dependencies'])
            });

            it("and succeed", function () {
                spyOn($scope, 'transitionTo');

                $scope.confirmApply();

                expect($scope.transitionTo).toHaveBeenCalledWith('errata.tasks.task', {taskId: 1});
                expect($scope.errorMessages.length).toBe(0);
                expect($scope.hasComposites($scope.updates)).toBeTruthy();
            });
        });
    });
});
