 /*
 * Copyright (c) 2008 John McMullen (http://www.smple.com)
 * This is licensed under GPL (http://www.opensource.org/licenses/gpl-license.php) licenses.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * For a copy of the GNU General Public License, see <http://www.gnu.org/licenses/>.
 *
 * Heavily modified by Jason Rist of Red Hat, Inc.
 *
 * jQuery Plugin for Hovering Over a Row and seeing "more stuff"
 *
 * to use:
 * 1.) include this script in your page.
 * 2.) add something like this this to your doc ready
        $('a.linkHoverClass').linkHover({overlay:true, padding:5, bgColor:'#fff', borderColor:'#333'});
*/

 (function($){
	$.fn.linkHover = function(options){

		var defaults = {
			borderColor: '#B5B5B5',
            padding: 5,
			inline: false,
			overlay: false,
            color: '#000',
            somethingMore: "something else here"
		};

		var opts = $.extend(defaults, options);

		var href = '';
		var currentText = '';

		return this.each(function(){
            $(this).hoverIntent({
                over: function(){
                    var currentBg = $(this).css("background-color");
                    currentText = $(this).html();
                    $(this).removeAttr('href');
                    var w = $(this).width();
                    var h = $(this).height();
                    $(this).css('position','relative');
                    var box = $('<div/>', {
                        id: 'link-text',
                        style:  'position: absolute; ' +
                                'left: -1px; ' +
                                'top: 0px; ' +
                                'display: block; ' +
                                'z-index: 10; ' +
                                'background: ' + currentBg + '; ' +
                                'border: ' + opts.borderColor + ' 1px solid; ' +
                                'width: 445px; ' +
                                'padding: 1px 1px 1px 2px; ' +
                                'height: ' + (2*h) + ';'
                    });
                    var origText = $('<div/>', {
                        style:  'top: 0; ' +
                                'padding: ' + opts.padding + 'px; ',
                        text: $(currentText)
                    });
                    var additionalText = $('<div/>', {
                        style:  'top: ' + (h) + '; ' +
                                'padding: ' + opts.padding + 'px; ',
                        text: opts.somethingMore
                    });
                    $(this).append(
                            box.append(
                                    origText.append($(currentText))).append(additionalText));
                },
                out: function(){
                    $(this).html($(currentText));
                },
                timeout: 500,
                sensitivity: 10,
                interval: 500
            });
		}); // end this.each
	}; // end fn.linkHover
})(jQuery);