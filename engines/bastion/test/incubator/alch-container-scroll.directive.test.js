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


describe('Directive: alchContainerScroll', function() {
    var scope,
        compile,
        window,
        tableElement;

    beforeEach(module('alchemy'));

    beforeEach(inject(function(_$compile_, _$rootScope_, _$window_) {
        compile = _$compile_;
        scope = _$rootScope_;
        window = _$window_;
    }));

    beforeEach(function() {
        tableElement = angular.element(
            '<div alch-container-scroll control-width="table">' +
              '<table>' +
                '<thead>' +
                  '<tr><th>Column 1</th></tr>' +
                '</thead>' +
                '<tbody>' +
                  '<tr>' +
                    '<td>Row 1</td>' +
                 '</tr>' +
                '</tbody>' +
              '</table>' +
            '</div>');

        compile(tableElement)(scope);
        scope.$digest();
    });

    it("should adjust the table width on window resize", function() {
        var table = tableElement.find('table'),
            tableWidth = table.width(),
            windowElement = angular.element(window);

        windowElement.width('300px');
        windowElement.trigger('resize');

        expect(table.width()).toEqual(windowElement.width());
    });

    it("should adjust the table height on window resize", function() {
        var table = tableElement.find('table'),
            windowElement = angular.element(window);

        windowElement.height('100px');
        windowElement.trigger('resize');

        expect(tableElement.height()).toEqual(windowElement.height() - tableElement.offset().top);
    });
});
