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

describe('Factory: PageTitle', function () {
    var $window, $interpolate, PageTitle;

    beforeEach(module('Bastion.widgets'));

    beforeEach(inject(function (_$window_, _$interpolate_, _PageTitle_) {
        $window = _$window_;
        $interpolate = _$interpolate_;
        PageTitle = _PageTitle_;
    }));

    it("provides a way to set titles", function () {
        PageTitle.setTitle("my new title: {{ title }}", {title: 'blah'})
        expect(PageTitle.titles.length).toBe(1);
        expect($window.document.title).toBe("my new title: blah");
    });

    it("provides a way to reset to the first title", function () {
        PageTitle.setTitle("my new title: {{ title }}", {title: 'blah'})
        PageTitle.setTitle('title 1');
        PageTitle.setTitle('title 2');

        PageTitle.resetToFirst();
        expect(PageTitle.titles.length).toBe(1);
        expect($window.document.title).toBe("my new title: blah");
    });

    it("stores a stack of titles and provides a way to retrieve it", function () {
        expect(PageTitle.titles.length).toBe(0);

        PageTitle.setTitle('title 1');
        expect(PageTitle.titles.length).toBe(1);

        PageTitle.setTitle('title 2');
        expect(PageTitle.titles.length).toBe(2);
        expect(PageTitle.titles[1]).toBe('title 2');
    })
});
