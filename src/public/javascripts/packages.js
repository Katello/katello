/**
 Copyright 2011 Red Hat, Inc.

 This software is licensed to you under the GNU General Public
 License as published by the Free Software Foundation; either version
 2 of the License (GPLv2) or (at your option) any later version.
 There is NO WARRANTY for this software, express or implied,
 including the implied warranties of MERCHANTABILITY,
 NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 have received a copy of GPLv2 along with this software; if not, see
 http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
*/

KT.packages = function() {
    var valid_package_list_format = function(packages){
        var length = packages.length;

        for (var i = 0; i < length; i += 1){
            if( !valid_package_name(packages[i]) ){
                return false;
            }
        }
        return true;
    },
    valid_package_name = function(package_name){
        var is_match = package_name.match(/[^abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789\-\.\_\+\,]+/);

        return is_match === null ? true : false;
    };
    return {
        valid_package_list_format : valid_package_list_format,
        valid_package_name : valid_package_name
    }
}();
