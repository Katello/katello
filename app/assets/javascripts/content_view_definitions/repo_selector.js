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

KT.repo_input = (function() {
    register = function() {
        // initialize the select
        var select = $('#repo_select');
        if (select.length === 0){
            return;
        }

        select.chosen({allow_single_deselect: true}).change(function(e) {
            var select = $(this),
                data = {};

            select.prev(".spinner").show();

            data[select.attr("name")] = select.val();
            $.ajax({
                type: "PUT",
                contentType: "application/json",
                url: select.data("url"),
                data: JSON.stringify(data),
                cache: false,
                success: function(){
                    select.prev(".spinner").hide();
                }
            });
        });
    };

    return {
        register: register
    };
})();
