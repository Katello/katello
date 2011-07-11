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

$(document).ready(function() {

    $('#path-expanded').hide();
    $('#path-collapsed').live('click', env_select.expand);
    $('#path-expanded').live('click', env_select.close);
    $('.path_link').live('click', env_select.env_selected);
    $('.path_entry').live('click', env_select.path_selected);

    //If we mouse over the entries box, deselect what is already selected
    $('#path-entries').mouseover(env_select.disable_active);
    $('#path-entries').mouseout(env_select.highlight_selected);


    env_select.active_div = $(".active").parents(".path_entry");
    env_select.highlight_selected();

    //Close the drop down if the user clicks somewhere else
    $('body').click(function(event){
        if (!($(event.target).parents("#path-entries").size() > 0) && env_select.is_open()) {
            env_select.close();
          }
    });

    $('#path-widget').hoverIntent({
        over:env_select.expand,
        timeout:750,
        interval: 200,
        out:env_select.close
    });

});




var env_select =   {
    /* Click callback should be a function:
     *
     * function(env_id, env_next_id, is_locker)
     * env_next_id may be undefined
     *
     */
    click_callback: undefined,
    active_div:  undefined,
    expand: function() {
        $('#path-collapsed').hide();
        $('#path-expanded').show();

        $('#path-entries').show();

    },
    close: function() {
        $('#path-collapsed').show();
        $('#path-expanded').hide();
        
        $('#path-entries').hide();
    },
    path_selected: function() {
        env_select.close();
        var content = $(this).html();
        $('#path-selected').find('ul').html(content);
        env_select.active_div = $(this);
        env_select.highlight_selected();
        return false;
    },
    env_selected: function() {
        env_select.close();
        var id = $(this).attr('data-env_id') ;

        $('a[data-env_id]').removeClass('active');
        $('a[data-env_id="'+ id + '"]').addClass('active');

        $(this).parentsUntil(".path_entry").trigger("click");

        if (env_select.click_callback) {
          env_select.click_callback(id, $(this));
        }
        return false;
    },
    disable_active: function() {
        //This is used when the user is highlighting entries, to clear
        //  what we manually highlighted.  CSS Hover will take care of it from here.
        $(".path_entry").removeClass("path_entry_selected");
    },
    is_open: function() {
        return $('#path-entries').is(":visible");
    },
    highlight_selected: function () {
        $(".path_entry").removeClass("path_entry_selected");
        env_select.active_div.addClass("path_entry_selected");
        return false;
    }

};