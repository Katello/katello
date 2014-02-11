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
 */

describe('Directive: pathSelector', function() {
    var scope,
        compile,
        paths,
        element;

    beforeEach(module(
        'Bastion.widgets',
        'widgets/views/path-selector.html'
    ));

    beforeEach(inject(function(_$compile_, _$rootScope_) {
        compile = _$compile_;
        scope = _$rootScope_;
    }));

    beforeEach(function() {
        paths = [
            [
                {id: 1, name: 'Library'},
                {id: 2, name: 'Dev'},
                {id: 3, name: 'Test'}
            ],[
                {id: 1, name: 'Library'},
                {id: 4, name: 'Stage'}
            ]
        ];
        scope.paths = paths;
        scope.environment = {};

        element = angular.element('<div path-selector="paths" ng-model="environment" mode="singleSelect"></div>');
        compile(element)(scope);
        scope.$digest();

        elementScope = element.isolateScope();
    });

    it("should create two seperate paths", function() {
        expect(element.find('.path-list').length).toBe(2);
    });

    it("should have three items in the first path", function() {
        expect(element.find('.path-list:first .path-list-item').length).toBe(3);
    });

    it("should have two items in the second path", function() {
        expect(element.find('.path-list:eq(1) .path-list-item').length).toBe(2);
    });

    it("should select both items if two items with the same id exist", function() {
        var checkbox = element.find('.path-list:first .path-list-item:first').find('input');

        checkbox.trigger('click');
        checkbox.attr('checked', 'checked');
        checkbox.prop('checked', true);

        expect(element.find('.path-list:eq(1)').find('.path-list-item:first input').is(':checked')).toBe(true);
    });

    it("should provide a way to disable path selection", function () {
        scope.disableAll = false;

        element = angular.element('<div path-selector="paths" ng-model="environment" mode="singleSelect" disable-trigger="disableAll"></div>');
        compile(element)(scope);
        scope.$digest();

        expect(element.find('.path-list-item:first input').attr('disabled')).toBe(undefined);

        scope.disableAll = true;
        scope.$digest();

        expect(element.find('.path-list-item:first input').attr('disabled')).toBe('disabled');
    });
});
