/**
* Copyright 2014 Red Hat, Inc.
*
* This software is licensed to you under the GNU General Public
* License as published by the Free Software Foundation; either version
* 2 of the License (GPLv2) or (at your option) any later version.
* There is NO WARRANTY for this software, express or implied,
* including the implied warranties of MERCHANTABILITY,
* NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
* have received a copy of GPLv2 along with this software; if not, see
* http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
**/

describe('Controller: ApplyErrataController', function() {
    var $controller, dependencies, $scope, translate, ContentHostBulkAction, ContentViewVersion,
        CurrentOrganization;

    beforeEach(module('Bastion.errata', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        $controller = $injector.get('$controller'),

        translate = function (string) {
            return string;
        };

        ContentHostBulkAction = {
            failed: false,
            installContent: function (params, success, error) {
                if (this.failed) {
                    error({data: {errors: ['error']}});
                } else {
                    success();
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

        $scope = $injector.get('$rootScope').$new();

        dependencies = {
            $scope: $scope,
            translate: translate,
            ContentHostBulkAction: ContentHostBulkAction,
            ContentViewVersion: ContentViewVersion,
            CurrentOrganization: CurrentOrganization
        };
    }));

    describe("sets the errataIds on the scope", function () {
        it("to the errataId in the $stateParams if present", function () {
            $scope.$stateParams = {errataId: 2};
            $controller('ApplyErrataController', dependencies);
            expect($scope.errataIds).toEqual([2]);
        });

        it("to the selected errata from the errata table otherwise", function () {
            $scope.selectedErrata = {included: {ids: [1]}};
            $controller('ApplyErrataController', dependencies);
            expect($scope.errataIds).toEqual([1]);
        });
    });

    it("sets the updates on the $scope if there are selected content hosts", function () {
        var updates = ['update'];
        spyOn(ContentHostBulkAction, 'availableIncrementalUpdates').andCallFake(function (params, success) {
            success(updates);
        });

        $scope.$stateParams = {errataId: 2};
        $scope.selectedContentHosts = ['abc'];

        $controller('ApplyErrataController', dependencies);

        expect(ContentHostBulkAction.availableIncrementalUpdates).toHaveBeenCalledWith($scope.selectedContentHosts,
            jasmine.any(Function));
        expect($scope.updates).toEqual(updates);
    });

    describe("can apply errata", function () {
        var expectedParams;

        beforeEach(function () {
            $controller('ApplyErrataController', dependencies);
            $scope.selectedContentHosts = {include: [1, 2, 3]};
            $scope.errataIds = [10];
        });

        describe("if no incremental update is needed", function () {
            beforeEach(function () {
                expectedParams = {
                    include: [1, 2, 3],
                    'content_type': 'errata',
                    content: [10],
                    'organization_id': CurrentOrganization
                };

                $scope.updates = [];
                spyOn(ContentHostBulkAction, 'installContent').andCallThrough();
            });

            afterEach(function () {
                expect(ContentHostBulkAction.installContent).toHaveBeenCalledWith(expectedParams, jasmine.any(Function),
                    jasmine.any(Function));
            });

            it("and succeed", function () {
                $scope.confirmApply();

                expect($scope.successMessages.length).toBe(1);
                expect($scope.errorMessages.length).toBe(0);
            });

            it("and fail", function () {
                ContentHostBulkAction.failed = true;
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
                    'propagate_to_composites': true
                };

                $scope.updates = [{
                    'content_view_version': {id: 1},
                    environments: [{id: 2}]
                }];

                spyOn(ContentViewVersion, 'incrementalUpdate').andCallThrough();
            });

            afterEach(function () {
                expect(ContentViewVersion.incrementalUpdate).toHaveBeenCalledWith(expectedParams, jasmine.any(Function),
                    jasmine.any(Function));
            });

            it("and succeed", function () {
                spyOn($scope, 'transitionTo');

                $scope.confirmApply();

                expect($scope.transitionTo).toHaveBeenCalledWith('errata.tasks.details', {taskId: 1});
                expect($scope.errorMessages.length).toBe(0);
            });

            it("and fail", function () {
                ContentViewVersion.failed = true;
                $scope.confirmApply();

                expect($scope.successMessages.length).toBe(0);
                expect($scope.errorMessages.length).toBe(1);
                expect($scope.errorMessages[0]).toBe('error');
            });

            it("can pass a parameter to update the content hosts", function () {
                expectedParams['update_systems'] = {include: [1, 2, 3]};
                $scope.errataConfirm = {applyErrata: true};

                $scope.confirmApply();
            });
        });
    });
});
