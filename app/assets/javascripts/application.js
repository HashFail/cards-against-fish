//= require jquery
//= require jquery_ujs
//= require notices
//= require private_pub
//= require twitter/bootstrap/collapse
$(document).ready(function() {
	gameForm = new ConfirmBox($("#game_form"));
	gameForm.okay = function() {
		gameForm.hide();
		showWait("Creating game...");
		$.ajax({
			method : "POST",
			url : "/games",
			data : this.div.children(".message").children("form").serialize(),
			success : function(data) {
				data = JSON.parse(data);
				if(data.error)
				{
					hideWait();
					errorBox.show(data.error, function(){gameForm.show();});
				}
				else
				{
					window.location.href = data.url;
				}
			}
		});
	};
	gameForm.show = function(e){
		if(e)
		{
			e.preventDefault();
		}
		this.display();
	}
});
