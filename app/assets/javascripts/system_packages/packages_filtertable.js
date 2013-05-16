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

KT.packages_filtertable = (function() {
    var initialize = function() {
        var theTable = $('table.filter_table.packages');
        var filter = $('#filter');
        var load_more = $('a#more');
        var load_summary = $('span#loaded_summary');
        var count = theTable.attr('data-packageCount', 25);

        theTable.find('tbody tr:visible:odd').addClass('alt');

        filter.live('change, keyup', function(){
            if ( !this.value ){
                count = theTable.attr('data-packageCount');
                theTable.find('tbody tr').hide();
                theTable.find('tbody tr:lt('+count+')').show();
                coloring();
                footer("visible");
            } else {
                $.uiTableFilter(theTable, this.value);
                coloring();
                footer("hidden");
            }

            function coloring(){
                theTable.find('tbody tr').removeClass('alt');
                theTable.find('tbody tr:visible:odd').addClass('alt');
            }
            function footer(method){
                load_more.css('visibility',method);
                load_summary.css('visibility',method);
            }
        });

        //override the submit so it doesn't try to push a form
        $('#filter_form').submit(function () {
            filter.keyup();
            return false;
        }).focus(); //Give focus to input field
        $('.filter_button').click(function(){filter.change()});
    };
    return {
        initialize: initialize
    };
}(jQuery));

$(document).ready(function() {
    // initialize the filter table
    KT.packages_filtertable.initialize();
    //packages_filtertable.initialize();
});
