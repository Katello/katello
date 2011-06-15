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

//i18n global variable
var i18n = {};

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
    $(".helptip-open").live('click', helptip.handle_close);
    $(".helptip-close").live('click', helptip.handle_open);
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
});

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

var helptip =  (function() {
    return {
        handle_close: function(){
          var key = this.id.split("helptip-opened_")[1];
          $("#helptip-opened_" + key).hide();
          $("#helptip-closed_" + key).show();
          helptip.disable(key); 
        },
        handle_open: function(){
          var key = this.id.split("helptip-closed_")[1];
          $("#helptip-opened_" + key).show();
          $("#helptip-closed_" + key).hide();
          helptip.enable(key);
        },
        enable: function(key) {
          $.ajax({
            type: "POST",
            url: "/users/enable_helptip",
            data: { "key":key},
            cache: false
           });
        },
        disable: function(key) {
          $.ajax({
            type: "POST",
            url: "/users/disable_helptip",
            data: { "key":key},
            cache: false
           });
        }
    };
})();

//requires jQuery
var common = (function() {
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
            return myid.replace(/(:|\.)/g,'\\$1');
        }
    };
})();
