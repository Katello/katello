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


describe('Directive: nutupaneTable', function() {
    var scope,
        compile,
        tableElement;

    beforeEach(module('alchemy'));

    beforeEach(inject(function(_$compile_, _$rootScope_) {
        compile = _$compile_;
        scope = _$rootScope_;
    }));

    beforeEach(function() {
        tableElement = angular.element(
            '<div nutupane-table>' +
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
        scope.$broadcast("$stateChangeSuccess", {}, {}, {}, {});
    });

    it("should create a new table element with just the thead", function() {
        var theads = tableElement.find('thead'),
            tbodys = tableElement.find('tbody');

        expect(theads.length).toEqual(2);
        expect(tbodys.length).toEqual(1);
    });

    it("should hide the original table's thead", function() {
        var originalTableHead = angular.element(tableElement.find('thead')[1]);

        expect(originalTableHead.css('display')).toBe('none');
    });

    it("should remove the duplicate row select from the cloned table if present", function() {
        var rowSelectTable = tableElement.clone();
        rowSelectTable.find('thead').prepend("<tr><th class='row-select'></th></tr>");
        compile(rowSelectTable)(scope);
        scope.$digest();
        scope.$broadcast("$stateChangeSuccess", {}, {}, {}, {});
        expect(rowSelectTable.find('.row-select').length).toBe(1);
    });
});
