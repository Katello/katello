/**
 * Copyright 2014 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either version
 * 2 of the License (GPLv2) or (at your option) any later version.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 */


/*
 * Katello Global JavaScript File
 * Author: @jrist
 * Date: 09/01/2010
 */

var KT = KT ? KT : {};
KT.widget = {};

// Must be at the top to prevent AngularJS unnecessary digest operations
// And to handle the hashPrefix that AngularJS adds that confuses BBQ
$(window).bind("hashchange", function(event) {
// refresh the favicon to make sure it shows up
    $('link[type*=icon]').detach().appendTo('head');
});

if ($.bbq !== undefined) {
    $.bbq.pushState('!', '');
}

function update_status() {
  var statusElement = $(".status");
  var i = setInterval(function() {
      $.ajax({
          url: "#{@_request.fullpath}",
          dataType: 'json',
          success: function (json, status, xhr) {
              statusElement.text(json.status);
              if (xhr.status === 200) {
                  clearInterval(i);
              }
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

// Workaround for a bug in chosen
// When a chosen select receives focus() invoked from js code
// it ends up in an infinite loop of displaying and hiding the options.
// 2pane gives automatically focus to a first enabled visible input on the panel.
// Therefore we disable the inner input at the beginning and enable it
// after 400ms.
//
// requires jQuery
$.fn.delayed_chosen = function(options, delay_time) {
    var chzn_input;

    $(this).chosen(options);

    delay_time = (delay_time === undefined) ? 400 : delay_time;
    chzn_input = $(this).parent().find('.chzn-container :input');
    chzn_input.prop('disabled', true);
    chzn_input.delay(delay_time).queue(function() {
        $(this).prop('disabled', false);
        $(this).dequeue();
    });
};

//requires jQuery
KT.getData = function(fieldNames) {
    var data = {},
        value;

    $.each(fieldNames, function(i, fieldName){
        value = $('#'+fieldName).val();
        if (value !== undefined) {
            data[fieldName] = value;
        }
    });
    return data;
};


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
     if (o !== Object(o)) {
        throw new TypeError('Object.keys called on non-object');
     }
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

KT.orgswitcher = (function($) {
    var checkboxChanged = function(checkbox) {
      var this_checkbox = $(checkbox);
      this_checkbox.attr("disabled", "disabled");
      //var for all favorite icons to clear them
      var all_favorites = $('.favorite');
      //current favorite
      var this_favorite = this_checkbox.parent().find('.favorite');
      var this_spinner = this_checkbox.parent().find('.fav_spinner');
      var name = this_checkbox.attr("name");

      //extract the URL for the preference change
      var url = checkbox.data("url");

      var selected_org_id = this_checkbox.attr("value");
      var checked = this_checkbox.attr("checked");
      var options = {};

      if (checked){
        options = {user_id : $('#user_id').data("user_id")};
      } else {
        options = {org_id : selected_org_id, user_id : $('#user_id').data("user_id")};
      }

      if (!checked) {
          //hide the favorite icon temporarily while the ajax operation occurs
          this_favorite.hide();

          //show the spinner while waiting
          this_spinner.removeClass('hidden').show();

          $.ajax({
              type: "PUT",
              url: url,
              data: options,
              cache: false,
              success: function(data, textStatus, jqXHR){
                //hide spinner
                this_spinner.addClass('hidden').hide();
                if(checked){
                  this_checkbox.attr("checked", false);
                  this_favorite.addClass("icon-star-empty").addClass('clickable');
                  this_favorite.removeClass("icon-star");
                  this_favorite.attr("title", katelloI18n.make_default_org);
                  if(this_favorite.parent().find('label').length){
                    this_favorite.parent().find('label').html(katelloI18n.make_default_org);
                  }
                } else {
                  this_checkbox.attr("checked", true);
                  all_favorites.removeClass("icon-star");
                  all_favorites.attr("title", katelloI18n.make_default_org);
                  $('.favorite').addClass("icon-star").removeClass('clickable');
                  this_favorite.removeClass("icon-star-empty").addClass("icon-star");
                  this_favorite.attr("title", katelloI18n.current_default_org);
                  if(this_favorite.parent().find('label').length){
                    this_favorite.parent().find('label').html(katelloI18n.current_default_org);
                  }
                }
                this_favorite.show();

                this_checkbox.removeAttr("disabled");
              },
              error: function(data, textStatus, jqXHR){
                //hide the spinner and show the favorite is not selected
                this_spinner.addClass('hidden').hide();
                this_checkbox.attr("checked", false);
                this_favorite.show();
                this_checkbox.removeAttr("disabled");
              }
          });
      }

      return false;
    };
    return {
        checkboxChanged: checkboxChanged
    };
}(jQuery));

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
    KT.common.link_hover_setup('dark');

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
    $(".tipsify").tooltip({ placement: 'bottom', delay : 350 });
    $(".tipsify-left").tooltip({ placement: 'left'});

    KT.common.orgSwitcherSetup();
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

    //allow all buttons with class .button to be clicked via enter or space button
    $('.button').live('keyup', function(e){
        if(e.which === 13 || e.which === 32)
        {
            $(this).click();
        }
    });

    window.alert = function(message){KT.common.customAlert(message);return false;};
    $.rails.confirm = function(message) {
        KT.common.customConfirm({message: message}); return false;
    };
});
