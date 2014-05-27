$(document).ready(function(){
	Popup = function(div)
	{
		this.div = div;
		this.okay = function(){
			if(typeof this.onContinue === "function")
			{
				this.onContinue();
			}
			this.hide();
		};
		this.show = function(message, onContinue){
			this.onContinue = onContinue;
			this.div.children(".message").html(message);
			this.display();
		}
		this.display = function(){
			this.div.show();
			$("#main").css("opacity",".5");
		}
		this.hide = function(){
			this.div.hide();
			$("#main").css("opacity","1");
		}
		$(this.div).data("popup", this);
		var target = this;
		$(this.div).children(".okay_button").on("click", function(){
			target.okay();
		});
	}

	errorBox = new Popup($("#error_container"));

	noticeBox = new Popup($("#notice_container"));

	softErrorInit = function(div){
		$("#soft_popup_container").append(div);
		div[0].timer = window.setTimeout(function(){
			div.fadeOut(400, function(){
				$(this).remove();
			});
		}, 5000);
		div.mouseenter(function(){
			window.clearTimeout(this.timer);
		});
		div.mouseleave(function(){
			var t = this;
			this.timer = window.setTimeout(function(){
				$(t).fadeOut(400, function(){
					$(this).remove();
				});
			}, 5000);
		});
		div.children("button").on("click", function(){
			$(div).fadeOut(400, function(){
				$(div).remove();
			});
		});
	}

	softError = function(message){
		var div = $('<div class="alert alert-danger alert-dismissable soft_popup"><button type="button" class="close" data-dismiss="alert" aria-hidden="true">x</button><span>'+message+'</span></div>');
		softErrorInit(div);
	};

	softNotice = function(message){
		var div = $('<div class="alert alert-success alert-dismissable soft_popup"><button type="button" class="close" data-dismiss="alert" aria-hidden="true">x</button><span>'+message+'</span></div>');
		softErrorInit(div);
	};
	
	ConfirmBox = function(div)
	{
		var confirmBox = new Popup(div)
		confirmBox.show = function(message, onContinue, onCancel){
			this.div.children(".message").html(message);
			this.onContinue = onContinue;
			this.onCancel = onCancel;
			this.display();
		}
		confirmBox.cancel = function(){
			if(typeof this.onCancel === "function")
			{
				this.onCancel();
			}
			this.hide();
		}
		var target = confirmBox;
		$(confirmBox.div).children(".cancel_button").on("click", function(){
			target.cancel();
		});
		return confirmBox;
	}

	confirmBox = new ConfirmBox($("#confirm_container"));

	showWait = function(message)
	{
		$("#wait_container").children(".message").html(message);
		$("#wait_container").show();
		$("#main").css("opacity",".5");
	}

	hideWait = function()
	{
		$("#wait_container").hide();
		$("#main").css("opacity","1");
	}

	function positionPopups()
	{
		$(".popup").each(function(){
			var t = $(this);
			t.css("top", window.innerHeight/2 - t.height()/2);
		});
	}

	$(window).on("resize", positionPopups);
	$(document).ready(positionPopups);
});
