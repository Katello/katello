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

describe('Service:formUtils', function() {
    var FormUtils;

    beforeEach(module('Bastion.utils', 'Bastion.test-mocks'));

    beforeEach(inject(function($injector) {
        FormUtils = $injector.get('FormUtils');
    }));

    describe("provides a function that turns a name into a label", function() {
        var uuidFormat = (/[a-z0-9]{8}-[a-z0-9]{4}-4[a-z0-9]{3}-[a-z0-9]{4}-[a-z0-9]{12}/);

        it("that replaces special characters with underscores", function() {
            var model = {name: 'a label !@# 123'};

            FormUtils.labelize(model);

            expect(model.label).toBe('a_label_____123');
        });

        it("that will generate a UUID if a non-ascii name is used", function() {
            var model = {name: 'žluťoučký'};

            FormUtils.labelize(model);

            expect(model.label).toMatch(uuidFormat);
        });


        it("that will generate a UUID if name contains more than 128 characters", function() {
            var model = {name: 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. ' +
                'Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque pena'};

            FormUtils.labelize(model);

            expect(model.label).toMatch(uuidFormat);
        });
    });
});
