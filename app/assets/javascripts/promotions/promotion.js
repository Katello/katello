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

var promotion_page = (function($){
    var types =             ["content_view"],
        changeset_queue =   [],
        changeset_data =    {},
        interval_id,
        current_changeset,
        current_changeset_breadcrumb,  // e.g. promotion or deletion breadcrumb
        changeset_tree,
        content_tree,

        start_timer = function() {
            interval_id = setInterval(push_changeset, 1000);
        },
        stop_timer = function() {
          clearInterval(interval_id);
          interval_id = undefined;
        },
        are_updates_complete = function() { //if there are no pending (and complete) updates, return true
            return changeset_queue.length === 0 && interval_id !== undefined;
        },
        //  Finds the add/remove buttons currently active on the page (for both content and changeset trees).
        //  In order to locate the buttons for a single tree, pass in the appropriate tree id (e.g. '#content_tree',
        //  '#changeset_tree')
        find_button = function(id, type, tree_id) {
            if (tree_id) {
                return $(tree_id).find("a[class~=content_add_remove][data-id=" + KT.common.escapeId(id) + "][data-type=" + type + "]");
            }
            return $("a[class~=content_add_remove][data-id=" + KT.common.escapeId(id) + "][data-type=" + type + "]");
        },
        conflict = function(){
            //conflict object that stores conflict information
            var content_view_add = [],
                content_view_remove = [];

            return {
                content_views_added: content_view_add,
                content_views_removed: content_view_remove,
                size : function() {
                    var total = 0;
                        total += content_view_add.length + content_view_remove.length;
                    return total;
                },
                add_item : function(type, name, added) {
                    var action = added ? "add" : "remove";
                    if (type === 'content_view') {
                        var content_view_array = added ? content_view_add : content_view_remove;
                        content_view_array.push(name);
                    }
                }
            };
        },
        calculate_conflict = function(old_changeset, new_changeset) {
            var myconflict = conflict();
            // TODO: CONFLICT: update the logic to handle content views.  This will be done in separate commit.
            return myconflict;
        },
        show_conflict = function(conflict) {
            $("#conflict-dialog").dialog({modal: true, width: 400});
            $("#conflict-accordion").html(promotionsRenderer.renderConflict(conflict));
        },
        show_conflict_details = function() {
            var accord = $("#conflict-accordion");
            accord.show();
            accord.accordion({fillSpace:true, beforeClose: hide_conflict});
        },
        hide_conflict = function() {
            $("#conflict-dialog").dialog('close');
            var accord = $("#conflict-accordion");
            accord.accordion("destroy");
            accord.html('');
            accord.hide();
        },
        push_changeset = function() {

            if(changeset_queue.length > 0 && current_changeset) {
                stop_timer();
                var data = [];
                while(changeset_queue.length > 0) {
                    data.push(changeset_queue.shift());
                }

                current_changeset.update(data,
                    function(data) {
                        if (changeset_queue.length === 0 || !data.changeset) {
                            if(data.changeset) {
                                var old_changeset = current_changeset;
                                current_changeset = changeset_obj(data.changeset);
                                reset_page();
                                changeset_tree.rerender_content();
                                var diff = calculate_conflict(old_changeset, current_changeset);
                                if (diff.size() > 0) {
                                    show_conflict(diff);
                                }
                            }
                            else {
                                current_changeset.set_timestamp(data.timestamp);
                            }
                        }
                        start_timer();
                    },
                    throw_error);
            }
        },
        wait = function(break_cb, finished_cb) {
            $("#wait_dialog").dialog({
                closeOnEscape: false,
                modal: true,
                //Remove the close button
                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); }
            });
            if (!break_cb()) {
                setTimeout(function() {
                    wait(break_cb, finished_cb);
                }, 250);
            }
            else {
                $("#wait_dialog").dialog("close");
                finished_cb();
            }
        },
        throw_error = function() {
            $("#error_dialog").dialog({
                closeOnEscape: false,
                modal: true,
                //Remove the close button
                open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); }
            });
        },
        modify_changeset = function(id, display, type) {
            var changeset = current_changeset,
                adding = true,
                button = find_button(id, type);

            if ( changeset && changeset.has_item(type, id) ){
                adding = false;
            }
            if (adding) {
                button.html(i18n.undo).addClass("remove_" + type).removeClass('add_'+type);
                button.prev('.added').removeClass('hidden').attr('original-title', i18n.added_to_changeset(changeset.getName()));

                if (type === "content_view") {
                    if (changeset.getContentViews()[id] === undefined) {
                        add_content_view_breadcrumbs(changeset.id, id, display);
                    }
                }
                changeset.add_item(type, id, display);
                changeset_tree.rerender_content();
            }
            else {
                button.html(i18n.add).addClass("add_" + type).removeClass('remove_' + type);
                button.prev('.added').addClass('hidden').removeAttr('original-title');

                changeset.remove_item(type, id);
                if (type === "content_view") {
                    delete changeset.getContentViews()[id];
                    changeset_tree.rerender_content();
                }
            }
            sort_changeset();
            draw_status();
            changeset_queue.push([type, id, display, adding]);
        },
        sort_changeset = function() {
            $(".right_tree .will_have_content").find("li").each(function(index, element){
                $(element).find('li').sortElements(function(a,b){
                        var a_html = $(a).find(".sort_attr").html();
                        var b_html = $(b).find(".sort_attr").html();
                        if (a_html && b_html ) {
                            return  a_html.toUpperCase() >
                                    b_html.toUpperCase() ? 1 : -1;
                        }
                });
            });
        },
        activate_changeset_tree = function(type) {
            // unselect the currently selected tree
            $('.sliding_tree_category.selected').removeClass('selected');

            // update settings to switch to the requested changeset tree
            if (type === 'promotion') {
                $('.sliding_tree_category[data-cs_type="promotion"]').addClass('selected');
                promotion_page.set_current_changeset_breadcrumb(promotion_changeset_breadcrumb);
                promotion_page.get_changeset_tree().reset_tree(promotion_changeset_breadcrumb);

            } else { // type === 'deletion'
                $('.sliding_tree_category[data-cs_type="deletion"]').addClass('selected');
                promotion_page.set_current_changeset_breadcrumb(deletion_changeset_breadcrumb);
                promotion_page.get_changeset_tree().reset_tree(deletion_changeset_breadcrumb);
            }
            promotion_page.update_new_changeset_url(type);
        },
        init_changeset_list = function(){
            var changeset, id;
            sort_changeset();
            if( !current_changeset ){
                for( id in current_changeset_breadcrumb ){
                    if( current_changeset_breadcrumb.hasOwnProperty(id) ){
                        if( id.split("_")[0] === "changeset" ){
                            changeset = current_changeset_breadcrumb[id];
                            if ( changeset.state === "failed") {
                                changesetStatusActions.initProgressBar(id, changeset.progress, i18n.changeset_apply_failed);
                            }else if( !changeset.is_new && ( changeset.progress === null || changeset.progress === undefined ) ){
                                changesetStatusActions.setLocked(id);
                            } else if( changeset.progress !== null && changeset.progress !== undefined ){
                                changesetStatusActions.initProgressBar(id, changeset.progress);
                                changesetStatusActions.checkProgressTask(id.split("_")[1]);
                            }
                        }
                    }
                }
            }
        },
        env_change = function(env_id, element) {
            var url = element.attr("data-url");
            window.location = url;
        },
        fetch_changeset = function(changeset_id, callback) {
            $("#tree_loading").css("z-index", 300);
            $.ajax({
                type: "GET",
                url: KT.common.rootURL() + "changesets/" + changeset_id + "/object/",
                cache: false,
                success: function(data) {
                    $("#tree_loading").css("z-index", -1);
                    current_changeset = changeset_obj(data);
                    reset_page();
                    callback();
                }});
        },
        draw_status = function() {
            if (current_changeset === undefined) {
                $('#changeset_status').html('');
            }
            else {
                //array of  [type, quantity] arrays
                var counts = [];

                //count how many content views are in the changeset
                var content_view_count = 0;
                $.each(current_changeset.getContentViews(), function(key, content_view){
                    content_view_count+=1;
                });
                //push the i18n string to lookup and the count
                counts.push(["content_view", content_view_count]);

                //convert counts into human readable format
                var strings = [];
                $.each(counts, function(index, item){
                     if (item[1] === 1) {
                        strings.push(item[1] + " " + i18n[item[0] + "_singular"]);
                    }
                    else if (item[1] > 1) {
                         strings.push(item[1] + " " + i18n[item[0] + "_plural"]);
                    }
                });

                if(strings.length === 0) {
                    $('#changeset_status').html(i18n.summary + " " + i18n.changeset_empty);
                }
                else {
                    $('#changeset_status').html(i18n.summary + " " + strings.join(", "));
                }
            }
        },
        /*
         *  Resets anything that is listed to have the correct button value
         *    if there is no changeset selected this will reset everything
         *    This will be called when a new changeset is loaded, or when the user
         *    moves from page to page in the content (left hand) side
         *    //TODO make more efficient by identify exactly which page we are on and only reseting those buttons
         */
        reset_page = function() {
            if (current_changeset && permissions.manage_changesets) {
                var buttons = $('#list').find("a[class~=content_add_remove][data-type=content_view]");
                buttons.html(i18n.add).removeClass('remove_content_view').addClass("add_content_view"); //reset all to 'add'
                buttons.prev('.added').addClass('hidden').removeAttr('original-title');
                $.each(current_changeset.getContentViews(), function(index, content_view) {
                    $.each(buttons, function(button_index, button){
                        if( $(button).attr('id') === ('add_remove_content_view_' + content_view.id) ){
                            $(button).html(i18n.undo).removeClass('add_content_view').addClass("remove_content_view").removeClass("disabled");
                            $(button).prev('.added').removeClass('hidden').attr('original-title', i18n.added_to_changeset(current_changeset.getName()));
                        }
                    });
                });
                if (current_changeset.type() === "deletion") {
                    // show all add/remove links
                    buttons.show();

                } else { // promotion changeset
                    // show add/remove links for only promotable objects
                    buttons.filter('[data-promotable="true"]').show();
                }
            } else {
                disable_all(types);
            }

            //Reset the review/promote(or delete)/cancel button

            var cancel_btn = $("#review_cancel");
            var status = $('#changeset_status');
            var action_btn = $('#promote_changeset');

            if (current_changeset) {
                status.show();
                $("#sliding_tree_actionbar > div").removeClass("disabled");
                if (!permissions.manage_changesets) {
                    $('#edit_changeset').addClass("disabled");
                    $('#delete_changeset').addClass("disabled");
                    $('#review_changeset').addClass("disabled");
                }

                if (current_changeset.type() === "promotion") {
                    action_btn.find('span.text').html(i18n.action_promote);
                    action_btn.attr('original-title', i18n.apply_promotion_title);
                    $('#delete_changeset').data('confirm-text', i18n.remove_promotion_changeset_confirm);
                } else {
                    action_btn.find('span.text').html(i18n.action_delete);
                    action_btn.attr('original-title', i18n.apply_deletion_title);
                    $('#delete_changeset').data('confirm-text', i18n.remove_deletion_changeset_confirm);
                }

                if (current_changeset.is_new() || current_changeset.state() === "failed") {
                    cancel_btn.hide();

                    $("#changeset_tree .tree_breadcrumb").removeClass("locked_breadcrumb");
                    $(".breadcrumb_filter").removeClass("locked_breadcrumb_filter");
                    $("#cslist").removeClass("locked");
                    $('#locked_icon').remove();
                    $('#review_changeset > span').html(i18n.review);
                    $('#review_changeset').attr('original-title', i18n.review_title);
                    $('#promote_changeset').addClass("disabled");
                }
                else if( current_changeset.state() === "promoted" || current_changeset.state() === "promoting" ){
                    $("#changeset_tree .tree_breadcrumb").addClass("locked_breadcrumb");
                    $(".breadcrumb_filter").addClass("locked_breadcrumb_filter");
                    if( $('#locked_icon').length === 0 ){
                        $("#changeset_tree .tree_breadcrumb #changeset_" + current_changeset.id).prepend('<div id="locked_icon" class="locked_icon fl" >');
                    }
                    $("#cslist").addClass("locked");
                    $(".content_add_remove").hide();
                    $("#sliding_tree_actionbar > div").addClass("disabled");
                } else { //in review stage
                    cancel_btn.show();
                    $("#changeset_tree .tree_breadcrumb").addClass("locked_breadcrumb");
                    $(".breadcrumb_filter").addClass("locked_breadcrumb_filter");
                    if( $('#locked_icon').length === 0 ){
                        $("#changeset_tree .tree_breadcrumb #changeset_" + current_changeset.id).prepend('<div id="locked_icon" class="locked_icon fl" >');
                    }
                    $("#cslist").addClass("locked");
                    $(".content_add_remove").hide();

                    $('#review_changeset > span').html(i18n.cancel_review);
                    $('#review_changeset').attr('original-title', i18n.cancel_review_title);

                    if ((current_changeset.type() === "promotion" && permissions.apply_promotion_changesets) || (current_changeset.type() !== "promotion" && permissions.apply_deletion_changesets) ) {
                        $('#promote_changeset').removeClass("disabled");
                    }
                    else {
                        $('#promote_changeset').addClass("disabled");
                    }
                }
            }
            else {
                $(status.hide());
                $("#changeset_tree .tree_breadcrumb").removeClass("locked_breadcrumb");
                $(".breadcrumb_filter").removeClass("locked_breadcrumb_filter");
                $("#cslist").removeClass("locked");
                $('#locked_icon').remove();

                cancel_btn.hide();
                changesetEdit.close();

                if ($('.sliding_tree_category.selected').data('cs_type') === 'promotion') {
                    action_btn.find('span.text').html(i18n.action_promote);
                    action_btn.attr('original-title', i18n.apply_promotion_title);
                    $('#delete_changeset').data('confirm-text', i18n.remove_promotion_changeset_confirm);
                } else {
                    action_btn.find('span.text').html(i18n.action_delete);
                    action_btn.attr('original-title', i18n.apply_deletion_title);
                    $('#delete_changeset').data('confirm-text', i18n.remove_deletion_changeset_confirm);
                }
                $("#sliding_tree_actionbar > div").addClass("disabled");
            }

            if (!permissions.manage_changesets) {
                disable_all(types);
            }

            draw_status();
        },
        disable_all = function(types){
            $.each(types, function(index, type){
                var buttons = $("a[class~=content_add_remove][data-type=" + type + "]");
                buttons.hide().html(i18n.add);
                buttons.prev('.added').addClass('hidden').removeAttr('original-title');
            });
        },
        checkUsersInResponse = function(users) {
          if (users.length > 0) {
            var msg = users.join(", ") + ' ' + i18n.viewing;
            $('#changeset_users').html(msg).fadeIn();
          }
          else {
            $('#changeset_users').fadeOut("slow", function() { $(this).html(""); });
          }
        },
        add_content_view_breadcrumbs = function(changeset_id, id, name){
            var changesetBC = "changeset_" + changeset_id;
            var contentViewBC = 'content_view-cs_' + changeset_id + '_' + id;
            current_changeset_breadcrumb[contentViewBC] = {
                cache: null,
                client_render: true,
                name: name,
                trail: ['changesets', changesetBC],
                url: 'url'
            };
        },
        update_new_changeset_url = function(type) {
            new_changeset_link = $('a.fr.block');
            base_url = new_changeset_link.attr('base-ajax_url');
            new_changeset_link.attr('data-ajax_url', base_url + '&changeset_type=' + type);
        };

    return {
        activate_changeset_tree: activate_changeset_tree,
        get_current_changeset_breadcrumb: function(){return current_changeset_breadcrumb;},
        set_current_changeset_breadcrumb: function(cb){current_changeset_breadcrumb = cb;},
        get_changeset_tree:     function(){return changeset_tree;},
        set_changeset_tree:     function(ct){changeset_tree = ct;},
        get_content_tree:       function(){return content_tree;},
        set_content_tree:       function(ct){content_tree = ct;},
        get_changeset:          function(){return current_changeset;},
        set_changeset:          function(cs){current_changeset = cs;},
        modify_changeset:       modify_changeset,
        sort_changeset:         sort_changeset,
        fetch_changeset:        fetch_changeset,
        are_updates_complete:   are_updates_complete,
        env_change:             env_change,
        checkUsersInResponse:   checkUsersInResponse,
        start_timer:            start_timer,
        reset_page:             reset_page,
        throw_error:            throw_error,
        wait:                   wait,
        calc_conflict:          calculate_conflict,
        hide_conflict:          hide_conflict,
        show_conflict_details:  show_conflict_details,
        init_changeset_list:    init_changeset_list,
        update_new_changeset_url: update_new_changeset_url
    };
}(jQuery));

var changeset_obj = function(data_struct) {
    var id = data_struct["id"],
        timestamp = data_struct["timestamp"],
        content_views = data_struct.content_views,
        is_new = data_struct.is_new,
        state = data_struct.state,
        type = data_struct.type,  // promotion, deletion...etc
        has_failed = false, // used to indicate if there was a previous failed promo attempt since the page loaded
        name = data_struct.name,
        description = data_struct.description;

    var change_state = function(new_state, on_success, on_error) {
          $.ajax({
            contentType:"application/json",
            type: "PUT",
            url: KT.common.rootURL() + "changesets/" + id,
            data: JSON.stringify({timestamp:timestamp, state:new_state}),
            cache: false,
            success: function(data) {
                timestamp = data.timestamp;
                is_new = (new_state === "new");
                state = new_state;
                on_success();
            },
            error: function(data) {
                if (data.changeset) {
                    promotion_page.set_changeset( changeset_obj(data.changeset) );
                }
                else {
                    promotion_page.throw_error();
                }
            }
          });
        };

    return {
        id:id,
        getName: function(){return name;},
        setName: function(newName){
            name = newName;
            promotion_page.get_current_changeset_breadcrumb()["changeset_" + id].name = newName;
        },
        getDescription: function(){return description;},
        setDescription: function(newDesc){description = newDesc;},
        getContentViews: function() {return content_views;},
        is_new : function() {return is_new;},
        state : function() {return state;},
        type : function() {return type;},
        has_failed : function() {return has_failed;},
        set_timestamp:function(ts) { timestamp = ts; },
        timestamp: function(){return timestamp;},
        has_item: function(type, id) {
            var found = undefined;
            if (type === 'content_view') {
                if( content_views.hasOwnProperty(id) ){
                    return true;
                }
            }
            return found !== undefined;
        },
        add_item:function (type, id, display_name) {
            if (type === 'content_view') {
                content_views[id] = {'name': display_name, 'id': id};
            }
        },
        remove_item:function(type, id) {
            if (type == 'content_view') {
                delete content_views[id];
            }
        },
        review: function(on_success, on_error) {
            var success = function() {
                on_success();
            };

            change_state("review", success, on_error);
            promotion_page.get_current_changeset_breadcrumb()['changeset_' + id].is_new = false;
        },
        cancel_review: function(on_success, on_error) {
            change_state("new", on_success, on_error);
            promotion_page.get_current_changeset_breadcrumb()['changeset_' + id].is_new = true;
        },
        promote: function(on_success, on_error, confirm) {
         var data = {},
             cs = this;
         if(confirm){
             data.confirm = confirm;
         }
         $.ajax({
            type: "POST",
            url: KT.routes.apply_changeset_path(id),
            cache: false,
            data: data,
            success: function(data) {
                if(data.warnings){ //if there is a warning, make the user confirm
                    var warn_elem = $("#warning_dialog");
                    var buttons = {};
                    warn_elem.find(".warning").html(data.warnings);
                    buttons[i18n.cancel] = function(){$(this).dialog('close'); on_error();};
                    buttons[i18n.continue_promotion] =function(){
                        $(this).dialog('close');
                        cs.promote(on_success, on_error, true)
                    };
                    warn_elem.dialog({
                        closeOnEscape: false,
                        modal: true,
                        title: i18n.warning,
                        buttons: buttons,
                        open: function(event, ui) { $(".ui-dialog-titlebar-close").hide(); }
                    })
                }
                else {
                    if (on_success) {
                        on_success();
                    }
                    promotion_page.get_current_changeset_breadcrumb()['changeset_' + id].is_new = true;
                    promotion_page.get_current_changeset_breadcrumb()['changeset_' + id].state = "new";
                    promotion_page.get_current_changeset_breadcrumb()['changeset_' + id].progress = 0;
                    promotion_page.get_changeset_tree().render_content('changesets');
                    promotion_page.get_content_tree().render_content('content');
                }
            },
            error: function() {
                if(on_error) {
                    on_error();
                }
            }
            });
        },
        update: function(items, on_success, on_error) {
          var data = [];
          $.each(items, function(index, value) {
              var item = {};
              item["type"] = value[0];
              item["item_id"] = value[1];
              item["item_name"] = value[2];
              item["adding"] = value[3];
              data.push(item);
            });
          $.ajax({
            contentType:"application/json",
            type: "PUT",
            url: KT.common.rootURL() + "changesets/" + id,
            data: JSON.stringify({data:data, timestamp:timestamp}),
            cache: false,
            success: on_success,
            error: on_error
          });
        }
    };
};

//doc ready
var registerEvents = function(){
    $('.sliding_tree_category[data-cs_type]').live('click', function() {
        // user clicked on a changeset category (promotion/deletion)
        var selected = $(this);
        if (selected.hasClass('selected')) {
            // the user clicked changeset tree that is currently active; therefore, do nothing..
            return;
        }

        promotion_page.activate_changeset_tree(selected.data('cs_type'));
    });

    $('#save_changeset_button').live('click', function(){
        var button = $(this);
        if(button.hasClass("disabled")){return false;}
        button.addClass("disabled");
        $.ajax({
          type: "POST",
          url: button.attr('data-url'),
          data: $('#new_changeset').serialize(),
          cache: false,
          success: function(data){
              promotion_page.activate_changeset_tree(data.changeset.type);
              $.extend(promotion_page.get_current_changeset_breadcrumb(), data.breadcrumb);
              promotion_page.set_changeset(changeset_obj(data.changeset));
              promotion_page.get_changeset_tree().render_content('changeset_' + data.id);
              KT.panel.closePanel($('#panel'));
          },
          error: function(){ button.removeClass("disabled");}
        });
        return true;
    });

    $("#delete_changeset").click(function() {
        var button = $(this);
        if (button.hasClass('disabled')){
            return false;
        }
        var id = promotion_page.get_changeset().id;
        KT.common.customConfirm({
            message: button.data('confirm-text'),
            yes_callback: function(){
                button.addClass('disabled');
                $.ajax({
                    type: "DELETE",
                    url: button.attr('data-url') + '/' + id,
                    cache: false,
                    success: function(data){
                        delete promotion_page.get_current_changeset_breadcrumb()['changeset_' + id];
                        promotion_page.set_changeset('changesets');
                        promotion_page.get_changeset_tree().render_content('changesets');
                    }
                });
            }
        });
        return true;
    });

    $("#review_changeset").live('click', function() {
       var button = $(this);
        if (button.hasClass('disabled')){
            return false;
        }
        button.addClass("disabled");
        var cs = promotion_page.get_changeset();
        if(cs.is_new() || cs.state() === "failed") { //move to review
            var review_func = function() {
                cs.review(function() {
                    button.removeClass("disabled");
                    promotion_page.reset_page();
                    promotion_page.get_changeset_tree().rerender_content();
                });
            };
            if (!promotion_page.are_updates_complete()) {
                promotion_page.wait(promotion_page.are_updates_complete, review_func);
            }
            else {
                review_func();
            }
        }
        else {
            cs.cancel_review(function() {
                button.removeClass("disabled");
                promotion_page.reset_page();
                promotion_page.get_changeset_tree().rerender_content();
            });
        }
        return true;
    });

    $("#promote_changeset").live('click', function() {
        if ($(this).hasClass("disabled")) {
            return false;
        }
        $(this).addClass("disabled");
        $("#sliding_tree_actionbar > div").addClass("disabled");
        var cs = promotion_page.get_changeset();
        var after = function() {$(this).removeClass("disabled");};
        var error = function(){
            after();
            $("#sliding_tree_actionbar > div").removeClass("disabled");
        };
        cs.promote(after, error);
        return true;
    });

    //Ask the user if they really want to leave the page if updates aren't finished
    window.onbeforeunload = function(){
        if(!promotion_page.are_updates_complete()){
            return i18n.leave_page;
        }
    };

    $('#conflict_close').click(promotion_page.hide_conflict);
    $('#conflict-details').click(promotion_page.show_conflict_details);

    $('#edit_changeset').live('click', function() {
        if ($(this).hasClass('disabled')){
            return false;
        }
        changesetEdit.toggle();
        return true;
    });
};

var changesetEdit = (function(){

    var opened = false;

    var toggle = function(delay){
        var edit_window = $('#changeset_edit'),
        name_box = $('.edit_name_text'),
        edit_button = $('#edit_changeset > span'),
        description = $('.edit_description'),
        type = $('.edit_type'),
        changeset = promotion_page.get_changeset(),
        animate_time = 500;

        if (delay != undefined){
            animate_time = delay;
        }

        opened = !opened;

        var after_function = undefined;
        if (opened) {
            $('#edit_changeset').attr('original-title', i18n.close_edit_title);
            name_box.html(changeset.getName());
            edit_button.html(i18n.close_details);
            description.html(changeset.getDescription());
            type.html(changeset.type());
            edit_button.parent().addClass("highlighted");
            after_function = setup_edit;
        }
        else {
            $('#edit_changeset').attr('original-title', i18n.edit_title);
            edit_button.html(i18n.edit_details);
            edit_button.parent().removeClass("highlighted");
        }

        edit_window.slideToggle(animate_time, after_function);
    },
    setup_edit = function() {

        var changeset = promotion_page.get_changeset(),
        url = KT.common.rootURL() + "changesets/" + changeset.id,
        name_box = $('.edit_name_text'),
        description = $('.edit_description');

        name_box.each(function() {
            $(this).editable('destroy');
            $(this).editable( url, {
                type        :  'text',
                width       :  270,
                method      :  'PUT',
                name        :  $(this).attr('name'),
                cancel      :  i18n.cancel,
                submit      :  i18n.save,
                indicator   :  i18n.saving,
                tooltip     :  i18n.clickToEdit,
                placeholder :  i18n.clickToEdit,
                submitdata  :  {authenticity_token: AUTH_TOKEN},
                onsuccess   :  function(data) {
                    var parsed = $.parseJSON(data);
                    changeset.setName(parsed.name);
                    $('.edit_name_text').html(parsed.name);
                    changeset.set_timestamp(parsed.timestamp);
                    promotion_page.get_changeset_tree().rerender_breadcrumb();
                },
                onerror     :  function(settings, original, xhr) {
                    original.reset();
                }
            });
        });

        description.each(function() {
            $(this).editable('destroy');
            $(this).editable(url , {
                type        :  'textarea',
                method      :  'PUT',
                name        :  $(this).attr('name'),
                cancel      :  i18n.cancel,
                submit      :  i18n.save,
                indicator   :  i18n.saving,
                tooltip     :  i18n.clickToEdit,
                placeholder :  i18n.clickToEdit,
                submitdata  :  {authenticity_token: AUTH_TOKEN},
                rows        :  5,
                cols        :  30,
                onsuccess   :  function(data) {
                    var parsed = $.parseJSON(data);
                    $('.edit_description').html(parsed.description);
                    changeset.setDescription(data.description);
                    changeset.set_timestamp(parsed.timestamp);
                },
                onerror     :  function(settings, original, xhr) {
                    original.reset();
                }
            });
        });
    },
    close = function() {
        if (opened) {
            toggle(0);
        }
    };

    return {
        toggle: function() {toggle();},
        close: close
    };
})();


var promotionsRenderer = (function(){
    var render = function(hash, render_cb){
        if( hash === 'changesets'){
            var post_wait_function = function() {
                promotion_page.set_changeset(undefined);
                render_cb(templateLibrary.changesetsList(promotion_page.get_current_changeset_breadcrumb()));
            };
            //any pending updates, if so wait!
            if (!promotion_page.are_updates_complete()) {
                promotion_page.wait(promotion_page.are_updates_complete, function() {
                    post_wait_function();
                });
            }
            else {
                post_wait_function();
            }
        }
        else {
            var split = hash.split("_"),
            page = split[0],
            changeset_id = split[1],
            cs = promotion_page.get_changeset();

            //if we've come to a page with a different changset than what we have, clear the current changeset
            if (page === "changeset" && cs !== undefined && changeset_id !==  cs.id) {
               promotion_page.set_changeset(undefined);
            }

            if (promotion_page.get_changeset() === undefined) {
                promotion_page.fetch_changeset(changeset_id, function() {
                    render_cb(getContent(page));
                });
            }
            else {
                render_cb(getContent(page));
            }
        }
        promotion_page.reset_page();
    },
    getContent =  function(key) {
        var changeset = promotion_page.get_changeset(),
            inReviewPhase = (!changeset.is_new() && (changeset.state() !== "failed"));

        if (key === 'changeset'){
            return templateLibrary.contentList(changeset, changeset.id, !inReviewPhase);
        }
    },
    renderConflict = function(conflict) {
        // TODO: CONFLICT: update the logic to handle content views.  This will be done in separate commit.
        var html = "";
//        var html = templateLibrary.conflictFullProducts(conflict.products_added, conflict.products_removed);
//        $.each(conflict.products, function(key, product){
//            html += templateLibrary.conflictProduct(key, product);
//        });
        return html;
    };

    return {
        render: render,
        renderConflict: renderConflict
    };
})();

var templateLibrary = (function(){
    var changesetsListItem = function(id, name){
            var html ='<li class="slide_link">' + '<div class="simple_link link_details" id="' + id + '">';

            html += '<span class="sort_attr">'+ name + '</span></div></li>';
            return html;
        },
        changesetsList = function(changesets){
            var html = '<ul class="filterable">';
            $.each(changesets, function(item){
                if( changesets.hasOwnProperty(item) ){
                    //do the search filter here
                    if( item.split("_")[0] === "changeset" ){
                        html += changesetsListItem(item, changesets[item].name);
                    }
                }
            });
            html += '</ul>';
            return html;
        },
        contentList = function(changeset, changeset_id, showButton){
            var ul_start = '<ul class="filterable">',
                ul_end = '</ul>',
                html = ul_start,
                content_views_list = '',
                content_views = changeset.getContentViews();

            for(key in content_views) {
                if(content_views.hasOwnProperty(key) ){
                    content_view = content_views[key];
                    content_views_list += contentViewItem(changeset_id, key, content_view.name, showButton);
                }
            }
            html += ul_end + ul_start;
            html += '<h5>'+i18n.content_view_plural+'</h5>';
            html += content_views_list ? content_views_list : '<div class="empty_list">' + i18n['no_content_views'] + '</div>';
            html += ul_end + ul_start;
            return html;
        },
        contentViewItem = function(changeset_id, id, name, showButton){
            var anchor = "",
                html = '';
            if ( showButton ){
                anchor = '<a class="st_button content_add_remove fr remove_content_view" data-display_name="' +
                    name +'" data-id="' + id + '" data-type="content_view" id="add_remove_content_view_' + id +
                    '" data-content_view_id="' + id +
                    '">' + i18n.remove + '</a>';
            }
            html += '<li class="clear">' + anchor;
            html += '<div id="simple_link content_view-cs_' + changeset_id + '_' + id + '">' +
                '<span class="content_view-icon sort_attr" >' + name + '</span>' +
                '</div></li>';

            return html;
        },
    // TODO: CONFLICT: update the logic to handle content views.  This will be done in separate commit.
//        conflictFullProducts = function(added, removed) {
//            if (added.length === 0 && removed.length === 0) {
//                return "";
//            }
//            var html = "<h3>"+ i18n.full_product +"</h3>";
//            html +="<div>";
//            html += conflictAccordianListItem(true, added);
//            html += conflictAccordianListItem(false, removed);
//            html += "</div>";
//            return html;
//        },
//        conflictProduct = function(product_name, conflict_product) {
//            var html = '<h3><a href="#">'+ product_name+ '</a></h3>';
//            html +="<div>";
//            $.each(promotion_page.subtypes, function(index, type){
//                var added = conflict_product[type + "_add"];
//                var removed = conflict_product[type + "_remove"];
//
//                if (added.length > 0 || removed.length > 0) {
//                    html += '<div>' + i18n[type] + ':</div>';
//                    html += conflictAccordianListItem(true, added);
//                    html += conflictAccordianListItem(false, removed);
//                }
//            });
//            html += "</div>";
//            return html;
//        },
        conflictAccordianListItem = function(added, items) {
            if (items.length === 0) {
                return "";
            }

            var html = '<div class="conflict_item_type"><div>' + (added ? i18n.added : i18n.removed) + '</div>';
            html += '<ul>';
            $.each(items, function(index, item) {
                html += "<li class='conflict_item'>" + item +  "</li>";
            });
            html += '</ul></div>';
            return html;
        };

    return {
        changesetsList: changesetsList,
        contentList: contentList
// TODO: CONFLICT: update the logic to handle content views.  This will be done in separate commit.
//        conflictFullProducts: conflictFullProducts,
//        conflictProduct: conflictProduct
    };
})();

var changesetStatusActions = (function($){
    var set_margins = function(){
            if( $('.progressbar').length ) {
                $('#cslist .slider .link_details:not(:has(.progressbar)):not(:has(.locked_icon))').css('margin-left', '43px');
                $('#cslist .slider .link_details:not(:has(.progressbar)) .locked_icon').css({'margin-left': '9px', 'margin-right' : '22px'});
            } else if( $('#cslist .locked_icon').length ){
                $('#cslist .slider .link_details:not(:has(.progressbar)):not(:has(.locked_icon))').css('margin-left', '20px');
            }
        },
        initProgressBar = function(id, status, status_text){
            var changeset = $('#' + id),
                status_title = status_text;

            if (status_text === undefined) {
                status_text = i18n.changeset_applying;
                status_title = i18n.changeset_progress;
            }

            changeset.css('margin-left', '0');
            changeset.prepend('<span class="changeset_status"><span class="progressbar"></span><label></label></span>');
            changeset.find('.changeset_status label').text(status + '%');
            //changeset.find('.progressbar').progressbar({value: status});
            changeset.addClass('being_promoted');
            changeset.attr('title', status_title);
            changeset.find('.changeset_status label').text(status_text);
            set_margins();
        },
        setProgress = function(id, progress){
            var changeset = $('#' + id);
            //changeset.find(".progressbar").progressbar({value: progress});
            //changeset.find('.changeset_status label').text(progress + '%');
        },
        finish = function(id){
            var changeset = $('#' + id);
            changeset.find(".changeset_status label").text(i18n.changeset_applied);
            changeset.attr('title', i18n.changeset_applied);
            /*changeset.parent().fadeOut(3000, function(){
                changeset.parent().remove();
                if( !$('.changeset_status').length ){
                    $('#cslist .slider .link_details').animate({'margin-left' : '0'}, 200);
                }
            });*/
        },
        failed = function(id){
            // if the promotion failed, check the server for additional details (via notices)
            notices.checkNotices();

            var changeset = $('#' + id);
            changeset.find(".changeset_status label").text(i18n.changeset_apply_failed);
            changeset.attr('title', i18n.changeset_apply_failed);

            promotion_page.get_current_changeset_breadcrumb()[id].has_failed = true;
        },
        setLocked = function(id){
            var changeset = $('#' + id);
            changeset.css('margin-left', '0');
            changeset.prepend('<img class="fl locked_icon" src="' + KT.common.rootURL() + 'assets/icons/locked.png">');
            set_margins();
        },
        removeLocked = function(id){
            var changeset = $('#' + id);
            changeset.find('img').remove();
            changeset.css('margin-left', '20px');
            if( !$('#cslist .locked_icon').length ){
                $('#cslist .slider .link_details').css('margin-left', '0');
            }
        },
        checkProgressTask = function(id){
            var timeout = 8000;
            var updater = $.PeriodicalUpdater(KT.routes.status_changeset_path(id), {
                method: 'GET',
                type: 'JSON',
                cache: false,
                global: false,
                minTimeout: timeout,
                maxTimeout: timeout
            }, function(data, success){

                setProgress(data.id, data.progress);

                if (success === "notmodified") {
                  // received a 304 not modified...
                  var changeset_id = 'changeset_' + id;
                  if (promotion_page.get_current_changeset_breadcrumb()[changeset_id].has_failed === true) {
                      // attempting to promote this changeset previously failed..., so if the promotion progress
                      // remains 'not modified' that implies that it failed again...
                      failed(changeset_id);
                      updater.stop();
                  }
                } else if ((data.state === 'promoted') || (data.state === 'deleted')){
                    delete promotion_page.get_current_changeset_breadcrumb()['changeset_' + id];

                    // TODO: update logic to remove content view from the list. This will be done in separate commit.
                    // if the user deleted one or more products with the changeset, remove those products
                    // from the content tree
//                    if (data.state === 'deleted' && data.product_ids) {
//                        $.each(data.product_ids, function(index, product_id) {
//                            delete content_breadcrumb['details_' + product_id];
//                        });
//                        promotion_page.get_content_tree().rerender_content('content');
//                    }

                    finish(data.id);
                    updater.stop();
                } else if (data.state === 'failed') {
                    failed(data.id);
                    updater.stop();
                }
            });
        };

    return {
        initProgressBar     : initProgressBar,
        setProgress         : setProgress,
        finishProgess       : finish,
        checkProgressTask   : checkProgressTask,
        setLocked           : setLocked,
        removeLocked        : removeLocked
    };
})(jQuery);

//doc ready
$(document).ready(function() {
    $('.left_panel').resizable('destroy');

    promotion_page.start_timer();

    $(".content_add_remove").live('click', function() {
       if( !$(this).hasClass('disabled') ){
          var environment_id = $(this).attr('data-environment_id');
          var id = $(this).attr('data-id');
          var display = $(this).attr('data-display_name');
          var type = $(this).attr('data-type');
          promotion_page.modify_changeset(id, display, type);
       }
    });

    $('#changeset_users').hide();

    //initiate the left tree
    var contentTree = sliding_tree("content_tree", {
                                        breadcrumb      :  content_breadcrumb,
                                        default_tab     :  "content",
                                        bbq_tag         :  "content",
                                        base_icon       :  'home_img',
                                        expand_cb       :  promotion_page.reset_page //need to reset page during the extended scroll
                                    });
    contentTree.enableSearch();
    promotion_page.set_content_tree(contentTree);

    $(document).bind('search_complete.slidingtree', promotion_page.reset_page);

    // If the 'deletion' changeset tree is selected or if the page is being loaded with
    // 'changeset' hash (e.g. "#changeset=changeset_10") and the changeset is in the list
    // of deletion changesets, then load the page with the deletion changeset sliding tree;
    // otherwise, the default is to use promotion changeset sliding tree.
    var changeset_hash = $.deparam.fragment()["changeset"],
        selected_tree = $('.sliding_tree_category.selected');

    if (selected_tree.data('cs_type') === "deletion") {
        promotion_page.set_current_changeset_breadcrumb(deletion_changeset_breadcrumb);
    } else if (changeset_hash && changeset_hash != "changesets" &&
      !$.isEmptyObject(deletion_changeset_breadcrumb[changeset_hash])) {
        promotion_page.set_current_changeset_breadcrumb(deletion_changeset_breadcrumb);
        $('.sliding_tree_category.selected').removeClass('selected');
        $('.sliding_tree_category[data-cs_type="deletion"]').addClass('selected');
    } else {
        promotion_page.set_current_changeset_breadcrumb(promotion_changeset_breadcrumb);
    }
    promotion_page.set_changeset_tree( sliding_tree("changeset_tree", {
                                        breadcrumb      :  promotion_page.get_current_changeset_breadcrumb(),
                                        default_tab     :  "changesets",
                                        bbq_tag         :  "changeset",
                                        base_icon       :  'home_img',
                                        render_cb       :  promotionsRenderer.render,
                                        enable_filter   :  true,
                                        enable_float    :  true,
                                        tab_change_cb   :  function(hash_id) {
                                          promotion_page.init_changeset_list();
                                        }
                                    }));

    $(window).trigger('hashchange');

    //when loading the new panel item, if its new, we need to add a form submit handler
    KT.panel.set_expand_cb(function(id) {
        if (id === 'new') {
          $('#new_changeset').submit(function(e) {
              e.preventDefault();
              $('#save_changeset_button').trigger('click');
          });
        }
        if ($("#content_view_content").length > 0) {
            $("#content_view_content").treeTable({
                expandable: true,
                initialState: "collapsed",
                clickableNodeNames: true,
                onNodeShow: function(){$.sparkline_display_visible()}
            });
        }
    });

    //set function for env selection callback
    env_select.click_callback = promotion_page.env_change;

    registerEvents();

    $(document).ajaxComplete(function(event, xhr, options){
        var userHeader = xhr.getResponseHeader('X-ChangesetUsers');
        if(userHeader !== null && userHeader !== undefined) {
          var userj = $.parseJSON(userHeader);
          promotion_page.checkUsersInResponse(userj);
        }
    });

    KT.panel.registerPanel($('#changeset_tree'), $('#content_tree').width() + 50);

    var tupane = $('#panel');
    $(document).bind('hash_change.slidingtree', function(){
       if( tupane.hasClass('opened') ){
           KT.panel.closePanel(tupane);
       }
    });
});
