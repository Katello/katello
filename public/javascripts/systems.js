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

$(document).ready(function() {
  $('#update_subscriptions').live('submit', function(e) {
     e.preventDefault();
     var button = $(this).find('input[type|="submit"]');
      button.attr("disabled","disabled");
     $(this).ajaxSubmit({
         success: function(data) {
               button.removeAttr('disabled');
               notices.checkNotices();
         }, error: function(e) {
               button.removeAttr('disabled');
               notices.checkNotices();
         }});
  });
  // check if we are viewing systems by environment 
  if (window.env_select !== undefined) {
    env_select.click_callback = KT.systems_page.env_change;
  }

  KT.systems_page.registerActions();

});

KT.systems_page = (function() {

    var registerActions= function() {
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
    };

  return {
    env_change : function(env_id, element) {
      var url = element.attr("data-url");
      window.location = url;
    },
    registerActions: registerActions
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
    subSetup = function(){
        var subform = $('#subscribe');
        var subbutton = $('#sub_submit');
        var fakesubbutton = $('#fake_sub_submit');
        var subcheckboxes = $('#subscribe input[type="checkbox"]');
        var total = subcheckboxes.length;
        var checked = 0;
        subbutton.hide();

        subcheckboxes.each(function(){
            $(this).change(function(){
                if($(this).is(":checked")){
                    checked++;
                    $(this).parent().parent().parent().find(".ui-spinner").spinner("increment");
                    if(!(subbutton.is(":visible"))){
                        fakesubbutton.fadeOut("fast", function(){subbutton.fadeIn()});
                    }
                }else{
                    checked--;
                    $(this).parent().parent().parent().find(".ui-spinner").spinner("decrement");
                    if((subbutton.is(":visible")) && checked == 0){
                        subbutton.fadeOut("fast", function(){fakesubbutton.fadeIn()});
                    }
                }
            });
        });
    },
    spinnerSetup = function(){
        setTimeout("$('.ui-spinner').spinner()",1000);
    };
    
    return {
        unsubSetup: unsubSetup,
        subSetup: subSetup,
        spinnerSetup: spinnerSetup
    }
}();