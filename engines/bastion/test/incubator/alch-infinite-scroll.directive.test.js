/**
 * Copyright 2013 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either version
 * 2 of the License (GPLv2) or (at your option) any later version.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 */
describe('Directive: alchInfiniteScroll', function () {
    var $scope, $compile, $q, element;

    beforeEach(module('alchemy'));

    beforeEach(inject(function ($rootScope, _$compile_, _$q_){
        $scope = $rootScope;
        $compile = _$compile_;
        $q = _$q_;

        $scope.scrollHandler = {
            doIt: function() {
                var deferred = $q.defer();
                element.append('<p style="height: 10px">lalala</p>');
                deferred.resolve({});
                return deferred.promise;
            }
        };

        element = angular.element('<div alch-infinite-scroll="scrollHandler.doIt()" style="height: 100px; position: absolute; overflow-y: auto;"></div>');
        $('body').append(element);
    }));

    describe("loads more results if scrolling near the bottom", function() {
        beforeEach(function() {
            $compile(element)($scope);
            $scope.$digest();
        });

        it("calls the provided scroll function when scrolling near the bottom.", function() {
            spyOn($scope.scrollHandler, "doIt");

            // 95% of the height of the scroll area
            element.scrollTop(element[0].scrollHeight *.95);
            element.trigger('scroll');

            expect($scope.scrollHandler.doIt).toHaveBeenCalled();
        });

        it("does not calls the provided scroll function when not scrolling near the bottom.", function() {
            spyOn($scope.scrollHandler, "doIt");

            // 10% of the height of the scroll area
            element.scrollTop(element[0].scrollHeight *.10);
            element.trigger('scroll');

            expect($scope.scrollHandler.doIt).not.toHaveBeenCalled();
        });
    });

    describe("loads more results if there is not a scrollbar", function() {
        it("on initial load.", function() {
            spyOn($scope.scrollHandler, "doIt").andCallThrough();
            $compile(element)($scope);
            $scope.$digest();
            expect($scope.scrollHandler.doIt.callCount).toBe(5);
        });
    });

    describe("does not load more results if there is already a scrollbar", function() {
        beforeEach(function() {
            $compile(element)($scope);
            $scope.$digest();
        });

        it("on initial load.", function() {
            spyOn($scope.scrollHandler, "doIt").andCallThrough();
            $scope.$digest();
            expect($scope.scrollHandler.doIt.callCount).toBe(0);
        });
    });
});
