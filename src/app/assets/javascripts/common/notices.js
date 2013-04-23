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

var notices = (function() {
    return {
        setup_notices: function(pollingTimeOut) {
          if (pollingTimeOut === undefined) {
            pollingTimeOut = 45000;
          }
          
          notices.checkTimeout = pollingTimeOut;
          //start continual checking for new notifications
          notices.start();
        },
        clearPreviousFailures: function(requestType) {
            $('.' + requestType).closest('.jnotify-notification').remove();
        },
        displayNotice: function(level, notice, requestType) {
            var noticesParsed = $.parseJSON(notice),
                options = {
                    type: level, 
                    slideSpeed: 200,
                    alwaysClosable: true
                },
                generate_list = function(notices){
                    var notices_list = '<ul class='+requestType+'>',
                        i, length = notices.length;
                    
                    for( i=0; i < length; i += 1) {
                        notices_list += '<li>' + notices[i] + '</li>';
                    }
                    notices_list += '</ul>';

                    return notices_list;
                };

            var noticeObj = {};
            noticeObj.time = (new Date()).valueOf();
            noticeObj.level = level;
            noticeObj.notices = noticesParsed['notices'];
            noticeObj.validationErrors = noticesParsed['validation_errors'];
            noticeObj.requestType = requestType;
            $(document).trigger("notice", noticeObj);

            if (level === 'success') {
                notices.clearPreviousFailures(requestType);
            }

            if ((level === "error") || (level === "warning")) {
                options["sticky"] = true;
                options["fadeSpeed"] = 600;
            } else if( level === "message" ) {
                options["sticky"] = true;
                options["fadeSpeed"] = 600;        	
            } else {
                options["sticky"] = false;
                options["fadeSpeed"] = 600;
            }

            if( noticesParsed['validation_errors'] !== undefined ){
                var validation_html = generate_list(noticesParsed['validation_errors']);
                validation_html = '<span>' + i18n.validation_errors + '</span>' + validation_html;
                // set the options as this is an error
                options["type"] = "error";
                options["sticky"] = true;
                options["fadeSpeed"] = 600;
                $.jnotify(validation_html, options);
                $('.jnotify-message ul').css({'list-style': 'disc',
                              'margin-left': '30px'});    
            } 
            if( noticesParsed['notices'] && noticesParsed['notices'].length !== 0 ){
                $.jnotify(generate_list(noticesParsed['notices']), options);
            }
        },
        storeNotice: function(event, noticeObj) {
            var maxAge = 600000,
                curTime = (new Date()).valueOf(),
                idx = notices.noticeArray.length - 1;
            // Discard notices older than maxAge
            for (; idx>=0; idx-=1) {
                if (curTime - notices.noticeArray[idx].time > maxAge) {
                    notices.noticeArray.splice(idx, 1);
                }
            }
            notices.noticeArray.push(noticeObj);
        },
        addNotices: function(data) {
            var unread_notices = $("#unread_notices");
            var unread_notices_count = $("#unread_notices_count");
            if (!data || data.unread_count.length === 0) {
                return true;
            }
            unread_notices.data('last', parseInt(unread_notices.text(), 10));
            //if coming from the server may have new count
            if (data.unread_count > 0 && data.unread_count > unread_notices.data('last')) {
                unread_notices_count.text(data.unread_count);
                unread_notices.effect("bounce", "fast");
                unread_notices.data('last', data.unread_count);
            }

            $.each(data.new_notices, function(index, notice) {
                notices.displayNotice(notice.level, window.JSON.stringify({ "notices": [notice.text] }), notice.request_type);
            });

            return true;
        },
        checkNotices : function() {
            var url = KT.routes.notices_get_new_path()

            //Make sure when we load the page we get notifs
            $.ajax({
              type: 'GET',
              url: url,
              dataType: 'json',
              global: false,
              success: notices.addNotices
            });
        },
        checkNoticesInResponse : function(xhr) {
            var message, messageType;

            if (xhr !== undefined) {
                message = xhr.getResponseHeader('X-Message');
                if (message) {
                    messageType = xhr.getResponseHeader('X-Message-Type');
                    messageRequestType = xhr.getResponseHeader('X-Message-Request-Type');
                    notices.displayNotice(messageType, KT.common.decode(message), messageRequestType);
                }
            }
        },
        start: function () {
            var url = KT.routes.notices_get_new_path()

            // do not wait for PeriodUpdater, check new notices immediately
            $.ajax({
                type:"GET",
                url:url,
                cache:false,
                success:notices.addNotices
            });

            var pu = $.PeriodicalUpdater(url, {
                method: 'get',
                type: 'json',
                global: false,
                minTimeout: notices.checkTimeout,
                maxTimeout: notices.checkTimeout
            }, notices.addNotices);

        }
    };
})();

$(document).ready(function() {

    // perform periodic polling of notices (e.g. async scenarios)
    //notices.checkNotices();

    notices.noticeArray = [];
    $(document).bind("notice", notices.storeNotice);

    $(document).ajaxComplete(function(event, xhr, options){
        // look for notices in the response (e.g. sync scenarios)
        notices.checkNoticesInResponse(xhr);
    });
});
