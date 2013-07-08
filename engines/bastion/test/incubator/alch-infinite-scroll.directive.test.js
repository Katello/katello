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
    var $scope, $compile, element;

    beforeEach(module('alchemy'));

    beforeEach(inject(function ($rootScope, _$compile_){
        $scope = $rootScope;
        $compile = _$compile_;

        $scope.scrollHandler = {
            doIt: function () {}
        };

        element = angular.element('<div alch-infinite-scroll="scrollHandler.doIt()" style="height: 10px; position: absolute; overflow-y: auto;"><p style="height: 100px">lalala</p></div>');
        $('body').append(element);
        $compile(element)($scope);
        $scope.$digest();

    }));

    it("calls the provided scroll function when scrolling near the bottom.", function() {
        spyOn($scope.scrollHandler, "doIt");

        // 95% of the height of the scroll area
        element.scrollTop(element[0].scrollHeight *.95);
        element.trigger('scroll');

        expect($scope.scrollHandler.doIt).toHaveBeenCalled();
    });

    it("does not calls the provided scroll function when not scrolling near the bottom", function() {
        spyOn($scope.scrollHandler, "doIt");

        // 10% of the height of the scroll area
        element.scrollTop(element[0].scrollHeight *.10);
        element.trigger('scroll');

        expect($scope.scrollHandler.doIt).not.toHaveBeenCalled();
    });
});
