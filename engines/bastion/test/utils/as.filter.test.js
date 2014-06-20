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

describe('Filter:as', function() {
    var array, scope = {};

    beforeEach(module('Bastion.utils'));

    beforeEach(inject(function($filter) {
        array = [
            {id: 1, name: 'one'},
            {id: 2, name: 'two'},
            {id: 3, name: 'three'}
        ];
        scope.asFilter = $filter('as')
    }));

    it("should set items to the value of array", function() {
        expect(scope.asFilter(array, 'items')).toEqual(array);
        expect(scope.items).toEqual(array);
    });

});
