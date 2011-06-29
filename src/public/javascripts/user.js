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
   
    $('#password_field').live('keyup.katello', verifyPassword);
    $('#confirm_field').live('keyup.katello',verifyPassword);
    $('#save_user').live('click',createNewUser);
    $('#clear_helptips').live('click',clear_helptips);
    $('#save_password').live('click',changePassword);

    $('#update_roles').live('submit', function(e) {
        e.preventDefault();
        var button = $(this).find('input[type|="submit"]');
        button.attr("disabled","disabled");
        $(this).ajaxSubmit({
            success: function(data) {
                button.removeAttr('disabled');
            },
            error: function(e) {
                button.removeAttr('disabled');
            }
        });
    });
});

function clear_helptips() {
	var obj = $(this);
	user.clear_helptips(obj.attr("username"),
	    function(data) {
		obj.button('destroy');
		//obj.button('option', 'label', data);
		obj.text(data);
	    },
	    function(data) {
		obj.button('option',  'label', data);
	    })

}


function checkboxChanged() {
	var checkbox = $(this);
	var name = $(this).attr("name");
	var obj = {};
	obj[name] = checkbox.attr("checked");
	user.update_user($(this).attr("data_username"), obj, function(){},function(){});
	
}



//match_button must be defined which is the id of the button to disable
//if a password match fails
function verifyPassword() {
    var match_button = $('.verify_password');
    var a = $('#password_field').val();
    var b = $('#confirm_field').val();
    
    if(a!= b){
        $("#password_conflict").text(i18n.password_match);
        $(match_button).addClass("disabled");
        $('#save_password').die('click');
        $('#save_user').die('click');
        return false;
    }
    else {
        $("#password_conflict").text("");
        $(match_button).removeClass("disabled");

        //reset the edit user button
        $('#save_password').die('click');
        $('#save_password').live('click',changePassword);
        //reset the new user button 
        $('#save_user').die('click');
        $('#save_user').live('click',createNewUser);
        return true;
    }
}

//Create user functions
function createNewUser(){
    if (verifyPassword()) {
        user.create($('#username_field').val(), $('#password_field').val(),
              successCreate, errorCreate);
    }
}

function successCreate(data) {
    list.add(data);
    panel.closePanel($('#panel'));
}

function errorCreate(request) {
 //alert(request.responseText);
}



//Change password functions
function changePassword() {
    user.update_password($(this).attr("data_username")  ,$('#password_field').val(),
        changePasswordSuccess, changePasswordFail);
}

function changePasswordFail(request) {
  //alert(request.responseText);
}

function changePasswordSuccess() {
  //alert("Success");
}



