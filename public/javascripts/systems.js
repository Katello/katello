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


/*
 * A small javascript file needed to load system subscription related stuff
 *
 */
KT.panel.set_expand_cb(function(){
	KT.menu.hoverMenu('#panel .menu_parent', { top : '75px' });
});




KT.panel_search_autocomplete = KT.panel_search_autocomplete.concat(["distribution.name:", "distribution.version:", "network.hostname:", "network.ipaddr:", "...Any System Fact"]);

(function(){
    var options = { create : 'new_system' };

    if (window.env_select !== undefined) {

        // When the systems index page env selector changes, update the pre-populated attributes
        env_select.env_changed_callback = function(env_id) {
            if(env_select.envsys == true){
                $('#new').attr('data-ajax_url', KT.routes.new_system_path() + '?env_id=' + env_id);
            }
            $('#system_environment_id').attr('value', env_id);
        };

        $.extend(options, { 'extra_params' :
					[ { hash_id 	: 'env_id',
						init_func 	: function(){
							var state = $.bbq.getState('env_id'); 
							
							if( state ){ 
								env_select.set_selected(state); 
							} else {
								$.bbq.pushState({ env_id : env_select.get_selected_env() });
							}
						}
				  	} 
				]});
  	}
  	KT.panel.list.registerPage('systems', options);
}());

$(document).ready(function() {

  KT.panel.set_expand_cb(function() {
    KT.subs.initialize_edit();
  });

  KT.systems_page.registerActions();

    // These run after the subscribe/unsubscribe forms have been submitted to update
    // the left hand list entry (which reflects the subscribed status of the system).
    $('#unsubscribe').live('ajax:complete', function(evt, data, status, xhr){
        var id = $('.left').find('.active');
        var url = id.attr('data-ajax_url');
        url = url.substring(0, url.length - 5);  // Strip off trailing '/edit'
        KT.panel.list.refresh(id.attr('id'), url);
        $(this).find('input[type="submit"]').removeAttr('disabled');
    }).live('ajax:before', function(){
        $(this).find('input[type="submit"]').attr('disabled', 'disabled');
    });

    $('#subscribe').live('ajax:complete', function(evt, data, status, xhr){
        var id = $('.left').find('.active');
        var url = id.attr('data-ajax_url');
        url = url.substring(0, url.length - 5);  // Strip off trailing '/edit'
        KT.panel.list.refresh(id.attr('id'), url);
        $(this).find('input[type="submit"]').removeAttr('disabled');
    }).live('ajax:before', function(){
        $(this).find('input[type="submit"]').attr('disabled', 'disabled');
    });
});

KT.systems_page = (function() {
  return {
    env_change : function(env_id, element) {
      var url = element.attr("data-url");
      window.location = url;
    },
    create_system : function(data) {
        var button = data.find('input[type|="submit"]');
        button.attr("disabled","disabled");
        data.ajaxSubmit({
            success: function(data) {
                list.add(data);
                KT.panel.closePanel($('#panel'));
                KT.panel.select_item(list.last_child().attr("id"));
            },
            error: function(e) {
                button.removeAttr('disabled');
            }
        });
    },
    registerActions : function() {
        var remove = $(".panel_action[data-id=remove_systems]");
        KT.panel.actions.registerAction("remove_systems",
            {  url: remove.attr("data-url"),
               method: remove.attr("data-method"),
               success_cb: function(ids){
                    $.each(ids,function(index, item){
                        list.remove("system_" + item);
                    });
               }
            }
        );
    }
  }
})();

KT.subs = function() {
    var unsubSetup = function(){
        var unsubform = $('#unsubscribe');
        var unsubbutton = $('#unsub_submit');
        var fakeunsubbutton = $('#fake_unsub_submit');
        var unsubcheckboxes = $('#unsubscribe input[type="checkbox"]');
        var total = unsubcheckboxes.length;
        var checked = 0;
        unsubbutton.hide();
        unsubcheckboxes.each(function(){
            $(this).change(function(){
                if($(this).is(":checked")){
                    checked++;
                    if(!(unsubbutton.is(":visible"))){
                        fakeunsubbutton.fadeOut("fast", function(){unsubbutton.fadeIn()});
                    }
                }else{
                    checked--;
                    if((unsubbutton.is(":visible")) && checked == 0){
                        unsubbutton.fadeOut("fast", function(){fakeunsubbutton.fadeIn()});
                    }
                }
            });
        });
    },
    save_selected_environment = function(env_id) {
        // save the id of the env selected
        $("#system_environment_id").attr('value', env_id);
    },
    initialize_edit = function() {
       reset_env_select();
    },
    reset_env_select = function() {
    	if (window.env_select !== undefined) {
	        $('#path-expanded').hide();
	        env_select.reset_hover();
	        env_select.recalc_scroll();
       }
    },
    subSetup = function(){
        var subform = $('#subscribe');
        var subbutton = $('#sub_submit');
        var fakesubbutton = $('#fake_sub_submit');
        var subcheckboxes = $('#subscribe input[type="checkbox"]');
        var total = subcheckboxes.length;
        var checked = 0;
        var spinner;
        var of_string;
        subbutton.hide();

        subcheckboxes.each(function(){
            $(this).change(function(){
                if($(this).is(":checked")){
                    checked++;
                    spinner = $(this).parent().parent().parent().find(".ui-spinner");
                    if(spinner.length > 0){
                        if(spinner.spinner("value") == "0") {
                            spinner.spinner("increment");
                        }
                    }else{
                        $(this).parent().parent().parent().find(".ui-nonspinner").val(1);
                        spinner = $(this).parent().parent().parent().find(".ui-nonspinner-label")[0];
                        if(spinner) {
                            of_string = "1" + spinner.innerHTML.substr(1);
                            spinner.innerHTML = of_string;
                        }
                    }
                    if(!(subbutton.is(":visible"))){
                        fakesubbutton.fadeOut("fast", function(){subbutton.fadeIn()});
                    }
                }else{
                    checked--;
                    spinner = $(this).parent().parent().parent().find(".ui-spinner");
                    if(spinner.length > 0){
                        spinner.spinner("value", 0);
                    }else{
                        $(this).parent().parent().parent().find(".ui-nonspinner").val(0);
                        spinner = $(this).parent().parent().parent().find(".ui-nonspinner-label")[0];
                        if(spinner) {
                            of_string = "0" + spinner.innerHTML.substr(1);
                            spinner.innerHTML = of_string;
                        }
                    }
                    if((subbutton.is(":visible")) && checked == 0){
                        subbutton.fadeOut("fast", function(){fakesubbutton.fadeIn()});
                    }
                }
            });
        });
    },
    spinnerSetup = function(){
        setTimeout("$('.ui-spinner').spinner()",1000);
    },
    autohealSetup = function(){
        var checkboxes = $('#autoheal');
        checkboxes.each(function(){
          $(this).unbind("change");
          $(this).change(function(){
            $('#autoheal_form').ajaxSubmit({
              data: { autoheal: $(this).is(":checked") },  // Checkboxes in forms aren't included when false
              dataType: 'html',
              success: function(data) {
                notices.checkNotices();
              }, error: function(e) {
                notices.checkNotices();
              }
            });
          });
        });
    },

    matchsystemSetup = function(){
      $('#matchsystem').unbind("click");
      $('#matchsystem').change(function(e){
        $('#matchsystem_form').ajaxSubmit({
          data: { value: $(this).is(":checked") },  // Checkboxes in forms aren't included when false
          dataType: 'html',
          success: function(data) {
            notices.checkNotices();
            $('#subscriptions > a').click();
          }, error: function(e) {
            notices.checkNotices();
            $('#subscriptions > a').click();
          }
        });
      });
    };
    
    return {
        unsubSetup: unsubSetup,
        subSetup: subSetup,
        spinnerSetup: spinnerSetup,
        save_selected_environment: save_selected_environment,
        initialize_edit: initialize_edit,
        reset_env_select: reset_env_select,
        autohealSetup: autohealSetup,
        matchsystemSetup: matchsystemSetup
    }
}();
