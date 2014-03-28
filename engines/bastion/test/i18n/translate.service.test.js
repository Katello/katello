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

describe('Service: translate', function() {
    var translate, gettextCatalog;

    beforeEach(module('Bastion.i18n'));

    beforeEach(module(function($provide) {
        gettextCatalog = {
            getString: function () {}
        };

        $provide.value('gettextCatalog', gettextCatalog);
    }));

    beforeEach(inject(function(_translate_) {
        translate = _translate_;
    }));

    it('passes through to the gettextCatalog.getString', function() {
        var string = 'lalala';
        spyOn(gettextCatalog, 'getString').andReturn(string);
        expect(translate(string)).toBe(string);
        expect(gettextCatalog.getString).toHaveBeenCalledWith(string);
    });
});

