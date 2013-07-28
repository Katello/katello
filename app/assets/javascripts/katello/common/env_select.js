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
var env_select =   {
    /* Click callback should be a function:
     *
     * function(env_id, env_next_id, is_library)
     * env_next_id may be undefined
     *
     */
    scroll_obj: undefined,
    click_callback: undefined,

    // To facilitate triggering UI elements to change state based upon the currently selected environment,
    // this callback is called whenever the env is changed. Note that this does not guarantee that the env id
    // is actually different, just that the user interacted w/ the UI in a way that it updated.
    //
    // eg. Consider user.js, which saves off the original env id and then enables/disables the save button.
    // 1. The original id is set when the page is loaded (see _edit_environment.html.haml
    // 2. Callback is defined in user.js to enable/disable save button
    // 3. *IMPORTANT* Note that the callback is manually triggered in user.js:set_expand_cb(). This is where
    //    the widget is populated with a new org.
    // 4. Finally in this example case, once the new env is successfully saved the button should be disabled
    //    and the original env updated. (see user_methods.js)
    env_changed_callback: function(env_id) {},

    active_div:  undefined,
    recalc_scroll: function() {
        $(".path_entries").show();
        env_select.scroll_obj.bind();
        $(".path_entries").hide();
    },
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

        if(env_select.env_changed_callback){
            env_select.env_changed_callback(env_select.get_selected_env());
        }

        return false;
    },
    get_selected_env: function() {
        return $(".path_link.active").attr("data-env_id");
    },
    set_selected: function(env_id) {
        $('[data-env_id=' + env_id + '].path_link').click();
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
        if(env_select.env_changed_callback){
            env_select.env_changed_callback(id);
        }

        env_select.recalc_scroll();

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
    },
    init : function(){
        $('#path-expanded').hide();
        $('#path-collapsed').live('click', env_select.expand);
        $('#path-expanded').live('click', env_select.close);
        $('.path_link').live('click', env_select.env_selected);
        $('.path_entry').live('click', env_select.path_selected);

        //If we mouse over the entries box, deselect what is already selected
        $('#path-entries').mouseover(env_select.disable_active);
        $('#path-entries').mouseout(env_select.highlight_selected);

        env_select.active_div = $(".path_link.active").parents(".path_entry");
        env_select.highlight_selected();

        //Close the drop down if the user clicks somewhere else
        $('body').click(function(event){
            if (($(event.target).parents("#path-entries").size() <= 0) && env_select.is_open()) {
                env_select.close();
              }
        });

        env_select.reset_hover();
        env_select.scroll_obj = KT.env_select_scroll({});
        env_select.recalc_scroll();
    },
    reset_hover: function() {
        $('#path-container').hoverIntent({
            over:env_select.expand,
            timeout:500,
            interval: 200,
            out:env_select.close
        });
    }
};

$(document).ready(function() {
    env_select.init();
});

