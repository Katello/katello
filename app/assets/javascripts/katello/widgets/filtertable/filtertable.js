var filtertable = (function() {
    return {
        initialize : function() {
            var theTable = $('table.filter_table');
            var filter = $('#filter');

            filter.live('change, keyup', function(){
                $.uiTableFilter(theTable, this.value);
            });

            //override the submit so it doesn't try to push a form
            $('#filter_form').submit(function () {
                filter.keyup();
                return false;
            }).focus(); //Give focus to input field
            $('.filter_button').click(function(){filter.change()});
        }
    };
})();

$(document).ready(function() {
    // initialize the filter table
    filtertable.initialize();
});
