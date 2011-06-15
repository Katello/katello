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

$(document).ready(function() {

  $("#new_product").hide();
  $('#add_product').click(function() {
    $("#new_product").toggle();
  });

  $('div[id^="new_repo_form_"]').hide();
  $('div[id^="add_repository_"]').click(function() {
    var form = $(this).closest("ul[id^=repo_list_]").next("div[id^=new_repo_form_]");
    toggle_form(form);
  });

  $('.clickable').click(function(){
    $(this).parent().parent().parent().find('ul').slideToggle();

    var arrow = $(this).parent().find('a').find('img');
    if(arrow.attr("src").indexOf("collapsed") === -1){
      arrow.attr("src", "/images/icons/expander-collapsed.png");
    } else {
      arrow.attr("src", "/images/icons/expander-expanded.png");
    }
    return false;
  });
});

function toggle_form(form) {
  if (form.is(':hidden')) {
    form.show();
  } else {
    form.hide();
  }
}

