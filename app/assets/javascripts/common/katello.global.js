/**
 Copyright 2013 Red Hat, Inc.

 This software is licensed to you under the GNU General Public
 License as published by the Free Software Foundation; either version
 2 of the License (GPLv2) or (at your option) any later version.
 There is NO WARRANTY for this software, express or implied,
 including the implied warranties of MERCHANTABILITY,
 NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 have received a copy of GPLv2 along with this software; if not, see
 http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
*/

//Katello global object namespace that all others should be attached to
var KT = {};

//i18n global variable
var i18n = {};

//Setup underscorejs
KT.utils = _.noConflict();

KT.utils.unescape = function(code) {
    return code.replace(/\\\\/g, '\\').replace(/\\'/g, "'");
};

function localize(data) {
    for (var key in data) {
        if(data.hasOwnProperty(key)) {
            i18n[key] = data[key];
        }
    }
}

