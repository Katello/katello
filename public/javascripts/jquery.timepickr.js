/*
  jQuery Ui timepickr
  (c) Maxime Haineault <haineault@gmail.com>
  http://haineault.com

  MIT License (http://www.opensource.org/licenses/mit-license.php
  Modified under license by Daniel Wachsstock & Haso Keric

	Updated 10/25/2010 for jQuery UI 1.8.5
*/

(function($) {
	var menuTemplate = '<div class="ui-helper-reset ui-timepickr ui-widget" />';
	var rowTemplate = '<ol />';
	var buttonTemplate = '<li class="{className}">{label}</li>';
	function format(s, o){ // simple parameterizing strings
		for (key in o) s = s.replace('{'+key+'}', o[key]);
		return s;
	}

$.widget('ui.timepickr', {
	_init: function() {
		var ui = this, element = this.element;
		element.data('timepickr.initialValue', element.val());
		var menu = this.menu = ui._buildMenu().insertAfter(element);
		menu.children().hide();

		element.bind(this.options.trigger + '.timepickr', function(){
			ui.show();
		});

		var hover = this.options.hoverIntent && $.fn.hoverIntent ? 'hoverIntent' : 'hover';
		menu
			.data('timepickr', this)
			.css({width:this.options.width})
			.find('li')
				.addClass('ui-state-default ui-corner-all')
				[hover](function(){
					ui.inside = true;
					$(this).siblings().removeClass('ui-state-hover');
					$(this).addClass('ui-state-hover');
					ui._redraw();
					ui.showNextLevel(this);
					ui.update();
				}, function(){
					ui.inside = false;
				}).end()
			.find('ol')
				.addClass('ui-widget ui-helper-clearfix ui-helper-reset')
				.hide();

		this._redraw();

		element.blur(function(e) {
			ui.hide();
			if (ui.inside){
				// clicking outside the element blurs it before the click on the new element in called
				ui._trigger ('select', [e, ui]);
			}
			if (ui.options.resetOnBlur) {
				element.val(element.data('timepickr.initialValue'));
			}
		});

		if (this.options.val) {
			element.val(this.options.val);
		}

		if (this.options.handle) {
			$(this.options.handle).click(function() {
				ui.show();
				ui.element.focus();
			});
		}

		if (this.options.resetOnBlur) {
			menu.find('li').bind('mousedown.timepickr', function(){
				element.data('timepickr.initialValue', element.val());
			});
		}

		this._redraw();
	},

	update: function() {
		var val = {
			h: this.getValue('hour'),
			m: this.getValue('minute'),
			prefix: this.getValue('prefix'),
			suffix: this.getValue('suffix')
		};
		$(this.element).val(format(this.options.format, val));
	},

	getValue: function(type) {
		// get the highlighted element; if none is highlighted, get the first one
		var elem = $('.'+ type +'.ui-state-hover', this.menu)[0] || $('.'+type+':first', this.menu)[0];
		return $(elem).text();
	},

	destroy: function() {
		this.menu.remove();
		$.Widget.prototype.destroy.apply(this);
	},

	show: function() {
		this.menu.css({
			top: this.element.position().top + this.element.height() + this.options.top,
			zIndex: 1000
		});
		this.menu.find('ol:eq(0)').css('left', this.element.position().left).show();
	},

	showNextLevel: function(el) {
		$(el).closest('ol').next().show(this.options.animSpeed);
	},

	// essentially reposition each ol
	_redraw: function() {
		this.menu.css({
			top: this.element.position().top + this.element.height() + this.options.top,
			left: this.element.position().left + this.options.left
		});

		if (this.options.convention === 24) {
			var hrs        = this.menu.find('ol:eq(1)');
			var dayHours   = hrs.find('li').slice(0, 12);
			var nightHours = hrs.find('li').slice(12, 24);
			if (this.menu.find('ol:eq(0) li:eq(0)').hasClass('ui-state-hover')){
				// daytime
				nightHours.hide();
				dayHours.show();
			}else{
				//nighttime
				dayHours.hide();
				nightHours.show();
			}
		}

		// reposition each ol
		var ols = this.menu.find('ol');
		ols.each(function(i) {
			var prevOL = $(this).prev('ol');
			// find the span that's being hovered; if nothing, use the first one
			var pos = prevOL.find('.ui-state-hover:visible').position() || prevOL.find('li:visible:first').position();
			if (pos) $(this).css('margin-left', pos.left);
		});
	},

	// hide all levels
	hide: function() {
		this.menu.find('ol').hide();
	},

	activate: function(e) {
		this.element.focus();
		this.show(this.options.animSpeed);
	},

	_createRow: function(range, className) {
		var row = $(rowTemplate);
		$.each(range, function(){
			row.append($(format(buttonTemplate, {className: className, label: this.toString()})));
		});
		return row;
	},

	_getRanges12: function() {
		var o = [];
		o.push(this._createRow(['01','02','03','04','05','06','07','08','09','10','11','12'], 'hour'));
		o.push(this._createRow(this.options.rangeMin, 'minute'));
		o.push(this._createRow(this.options.suffix, 'suffix'));
		return o;
	},

	_getRanges24: function() {
		var o = [], opt = this.options;
		o.push(this._createRow(this.options.prefix, false, 'prefix')); // prefix is required in 24h mode
		o.push(this._createRow(
			['00','01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23'],
			'hour'
		));
		o.push(this._createRow(this.options.rangeMin, 'minute'));
		return o;
	},

	_buildMenu: function() {
		var menu   = $(menuTemplate);
		var ranges = this.options.convention === 24
								 && this._getRanges24() || this._getRanges12();
		$.each(ranges, function(i, val){
				menu.append(val);
		});
		return menu;
	}
});

$.ui.timepickr.prototype.options = {
	top:       6,
	left:      0,
	animSpeed: 0,
	trigger:   'click',
	convention:  12, // 24, 12
	format:    '{h}:{m} {suffix}',
	handle:      false,
	prefix:      ['00-11', '12-23'],
	suffix:      ['am', 'pm'],
	rangeMin:    ['00', '15', '30', '45'],
	resetOnBlur: true,
	val:         false,
	hoverIntent: false
};

})(jQuery);
