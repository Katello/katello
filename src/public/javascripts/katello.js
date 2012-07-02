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
 * Katello Global JavaScript File
 * Author: @jrist
 * Date: 09/01/2010
 */


//Katello global object namespace that all others should be attached to
var KT = {};

KT.utils = _.noConflict();

//i18n global variable
var i18n = {};

function localize(data) {
	for (var key in data) {
		i18n[key] =  data[key];
	}
}

function update_status() {
  var statusElement = $(".status");
  var i = setInterval(function() {
      $.ajax({
          url: "#{@_request.fullpath}",
          dataType: 'json',
          success: function (json, status, xhr) {
              statusElement.text(json.status);
              if (xhr.status == 200) clearInterval(i);
          },
          error: function (xhr, status, error) {
              statusElement.text(jQuery.parseJSON(xhr.responseText).message);
              clearInterval(i);
          }
      });
  }, 1000);
}  

// Common functionality throughout Katello

// Simple function to dump a message to the browser error log
function log(msg) {
    setTimeout(function() {
        throw new Error(msg);
    }, 0);
}

KT.helptip =  (function($) {
    var enable = function(key, url) {
        $.ajax({
          type: "POST",
          url: url,
          data: { "key":key},
          cache: false
          });
        },
        disable = function(key, url) {
          $.ajax({
            type: "POST",
            url: url,
            data: { "key":key},
            cache: false
           });
        },
        handle_close = function(){
          var key = this.id.split("helptip-opened_")[1],
              url = $(this).attr('data-url');

          $("#helptip-opened_" + key).hide();
          $("#helptip-closed_" + key).show(); 
          
          $(document).trigger('helptip-closed');
          
          disable(key, url);
        },
        handle_open = function(){
          var key = this.id.split("helptip-closed_")[1],
              url = $(this).attr('data-url');

          $("#helptip-opened_" + key).show();
          $("#helptip-closed_" + key).hide();
          
          $(document).trigger('helptip-opened');
          
          enable(key, url);
        };
        
    return {
        handle_close    :    handle_close,
        handle_open     :    handle_open
    };
})(jQuery);


//Add backwards compatible version of Object.keys
// https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Object/keys
if(!Object.keys) {
    Object.keys = function(o){
     if (o !== Object(o))
        throw new TypeError('Object.keys called on non-object');
     var ret=[],p;
     for(p in o) {
       if(Object.prototype.hasOwnProperty.call(o,p)){
         ret.push(p);
       }
     }
     return ret;
  };
}


//override the jQuery UJS $.rails.allowAction
$.rails.allowAction = function(element) {
    var message = element.data('confirm'),
    answer = false, callback;
    if (!message) { return true; }

    if ($.rails.fire(element, 'confirm')) {
        KT.common.customConfirm({
            message: message,
            yes_callback: function() {
                callback = $.rails.fire(element, 'confirm:complete', [answer]);
                if(callback) {
                    var oldAllowAction = $.rails.allowAction;
                    $.rails.allowAction = function() { return true; };
                    element.trigger('click');
                    $.rails.allowAction = oldAllowAction;
                }
            }
        });
    }
    return false;
};

//make jQuery Contains case insensitive
$.expr[':'].Contains = function(a, i, m) {
  return $(a).text().toUpperCase().indexOf(m[3].toUpperCase()) >= 0;
};
$.expr[':'].contains = function(a, i, m) {
  return $(a).text().toUpperCase().indexOf(m[3].toUpperCase()) >= 0;
};

//requires jQuery
KT.common = (function() {
    var root_url = undefined; 
    return {
        height: function() {
            return $(window).height();
        },
        width: function() {
            return $(window).width();
        },
        scrollTop: function() {
            return $(window).scrollTop();
        },
        scrollLeft: function() {
            return $(window).scrollLeft();
        },
        decode: function(value){
            var decoded = decodeURIComponent(value);
            return decoded.replace(/\+/g, " ");
        },
        escapeId: function(myid) {
            return myid.replace(/([ #;&,.%+*~\':"!^$[\]()=>|\/])/g,'\\$1')
        },
        customConfirm : function (params) {
          var settings = {
              message: undefined,
              warning_message: undefined,
              yes_text: i18n.yes,
              no_text: i18n.no,
              yes_callback: function(){},
              no_callback: function(){},
              include_cancel: false
          },
          confirmTrue = new Boolean(true),
          confirmFalse = new Boolean(false);

          $.extend(settings, params);

          var message = "<div style='margin:20px;'><span class='status_confirm_icon'/><div style='margin-left: 24px; display:table;height:1%;'>" + settings.message + "</div></div>",
              warning_message = (settings.warning_message === undefined) ? undefined : "<div style='margin:20px;'><span class='status_warning_icon'/><div style='margin-left: 24px; display:table;height:1%;color:red;'>" + settings.warning_message + "</div></div>",
              html = (warning_message === undefined) ? message : "<div>"+message+warning_message+"</div>",
              buttons = {
                "Yes": {
                  click : function () {
                    $(this).dialog("close");
                    $(this).dialog("destroy");
                    settings.yes_callback();
                    return confirmTrue;
                  },
                  'class' : 'button',
                  'text' : settings.yes_text
                },
                "No": {
                  click:function () {
                    $(this).dialog("close");
                    $(this).dialog("destroy");
                    settings.no_callback();
                    return confirmFalse;
                  },
                  'class' : 'button',
                  'text' : settings.no_text
                }
              };

          if(settings.include_cancel === true) {
              buttons["Cancel"] = {
                click:function () {
                  $(this).dialog("close");
                  $(this).dialog("destroy");
                  return confirmFalse;
                },
                'class' : 'button',
                'text' : i18n.cancel
              };
          }

          $(html).dialog({
            closeOnEscape: true,
            open: function (event, ui) {
                $('.ui-dialog-titlebar-close').hide();
                $('.confirmation').find('.ui-button')[1].focus();
            },
            modal: true,
            resizable: false,
            width: 450,
            title: i18n.confirmation,
            dialogClass: "confirmation",
            buttons: buttons
          });
        },
        customAlert : function(message) {
          var html = "<div style='margin:20px;'><span class='status_exclamation_icon'/><div style='margin-left: 24px; display:table;height:1%;'>" + message + "</div></div>";
          $(html).dialog({
            closeOnEscape: true,
            open: function (event, ui) { $('.ui-dialog-titlebar-close').hide(); },
            modal: true,
            resizable: false,
            width: 300,
            title: i18n.alert,
            dialogClass: "alert",
            stack: false,
            buttons: {
                "Ok": {
                  click : function () {
                    $(this).dialog("close");
                    $(this).dialog("destroy");
                    return false;
                  },
                  'class' : 'button',
                  'text' : i18n.ok
                }
            }
          });
        },
        orgSwitcherSetup : function() {
            //org switcher
            var button = $('#switcherButton');
            var container = $('#switcherContainer');
            var box = $('#switcherBox');
            var form = $('#switcherForm');
            var orgbox = $('#orgbox');
            var orgboxapi = null;
            button.removeAttr('href');
            button.click(function(switcher) {
                box.fadeToggle('fast');
                button.toggleClass('active');
                container.toggleClass('active');
                if(button.hasClass('active')){
                    if(!(box.hasClass('jspScrollable'))){
                      //the horizontalDragMaxWidth kills the horizontal scroll bar
                      // (on purpose, since we have ellipsis...)
                      orgbox.jScrollPane({ hideFocus: true, horizontalDragMaxWidth: 0 });
                      orgboxapi = orgbox.data('jsp');
                    }
                    $.ajax({
                        type: "GET",
                        url: orgbox.attr("data-url"),
                        cache: false,
                        success: function(data) {
                          orgboxapi.getContentPane().html(data);
                          orgboxapi.reinitialise();
                        },
                        error: function(data) {
                          orgboxapi.getContentPane().html("<p>User is not allowed to access any Organizations.</p>");
                          orgboxapi.reinitialise();
                        }
                    });
                }
            });
            form.mouseup(function() {
                return false;
            });
            $(document).mouseup(function(switcher) {
                if(!($(switcher.target).parent('#switcherContainer').length > 0)) {
                    button.removeClass('active');
                    container.removeClass('active');
                    box.fadeOut('fast');
                }
            });
        },
        orgBoxRefresh : function (){
          var orgbox = $('#orgbox');
          var orgboxapi = orgbox.data('jsp');
          orgboxapi.reinitialise();
        },
        orgFilterSetup : function(){
            $('form.filter').submit(function(){
                $('#orgfilter_input').change();
                return false;
            });
            $('#orgfilter_input').live('change, keyup', function(){
                if ($.trim($(this).val()).length >= 2) {
                    $("#orgbox a:not(:contains('" + $(this).val() + "'))").filter(':not').fadeOut('fast');
                    $("#orgbox a:contains('" + $(this).val() + "')").filter(':hidden').fadeIn('fast');
                } else {
                    $("#orgbox a").fadeIn('fast');
                }
            });
            $('#orgfilter_input').val("").change();
        },
        rootURL : function() {
            if (root_url === undefined) {
                //root_url = $('#root_url').attr('data-url');
                root_url = KT.config['root_url'];
            }
            return root_url;
        },
        getSearchParams : function(val) {
            var search_string = $.bbq.getState('list_search');

        	if( search_string ){
        		return { 'search' : search_string };	
        	} else {
        		return false;
        	}
        },
        spinner_path : function() {
          return KT.common.rootURL() + "images/embed/icons/spinner.gif";
        },
        jscroll_init: function(element) {
            element.jScrollPane({ hideFocus: true });
        },
        jscroll_resize: function(element) {
            element.resize(function(event){
                var element = $('.scroll-pane');
                if (element.length){
                    element.data('jsp').reinitialise();
                }
            });
        },
        to_human_readable_bytes : function(bytes) {
            var sizes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'],
                i;
            
            if (bytes == 0) { 
                return '0';
            } else {
                i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)));
                return ((i == 0) ? (bytes / Math.pow(1024, i)) : (bytes / Math.pow(1024, i)).toFixed(1)) + ' ' + sizes[i];
            }
        }
    };
})();


var client_common = {
    create: function(data, url, on_success, on_error) {
      $.ajax({
        type: "POST",
        url: url,
        data: data,
        cache: false,
        success: on_success,
        error: on_error
      });
    },
    destroy: function(url, on_success, on_error) {
      $.ajax({
        type: "DELETE",
        url: url,
        cache: false,
        success: on_success,
        error: on_error
      });
    }
};

/**
 * Document Ready function
 */
$(document).ready(function (){
	//Add a handler so that if any input has focus
	//   our keyboard shortcuts don't steal it
	$(":input").focus(function() {
		onInputField = true;
	}).blur(function() {
		onInputField = false;
	});

  //Add a handler for helptips
  $(".helptip-open").live('click', KT.helptip.handle_close);
  $(".helptip-close").live('click', KT.helptip.handle_open);

  // Add a handler for ellipsis
  $(".one-line-ellipsis").ellipsis(true);
  $(".tipsify").tipsy({ live : true, gravity: 's', fade: true, delayIn : 350 });
  $(".tipsify-west").tipsy({ gravity: 'w', hoverable : 'true' });

  KT.common.orgSwitcherSetup();
  KT.common.orgFilterSetup();
});

/**
 * Window Ready function
 */
$(window).ready(function(){
    $('.fc').parent().css({"text-align":"center"});
    //all purpose display loading icon for ajax calls
    $("#loading").bind("ajaxSend", function(){
      $(this).show();
      $('body').css('cursor', 'wait');
    }).bind("ajaxComplete", function(){
      $(this).hide();
      $('body').css('cursor', 'default');
    });
    $().UItoTop({ easingType: 'easeOutQuart' });

    //allow all buttons with class .button to be clicked via enter or space button
    $('.button').live('keyup', function(e){
        if(e.which == 13 || e.which == 32)
        {
            $(this).click();
        }
    });

    window.alert = function(message){KT.common.customAlert(message);return false;};
    $.rails.confirm = function(message) {
        KT.common.customConfirm({message: message}); return false;
    };
});
