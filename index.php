<html>
    <head>
        <?php
            include("conn.php");
            include("meta.html");
            if(isset($_GET["logout"]) && $_GET["logout"]==true)
            {
                session_unset();
            }
            else if(isset($_SESSION['ID']))
            {
                header("Location: agent.php");
            }

        ?>
        <style>
            body {
                background-color: #bfbfbf;
            }
            .login {
                width: 400px;
                background-color: #ffffff;
                box-shadow: 0 0 9px 0 rgba(0, 0, 0, 0.3);
                position: absolute;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%)
            }
            .login h2{
                text-align: center;
                color: #5b6574;
                font-size: 24px;
                padding: 20px 0 20px 0;
                border-bottom: 1px solid #dee0e4;
            }
            .login form {
                display: flex;
                flex-wrap: wrap;
                justify-content: center;
                padding-top: 20px;
                margin-bottom: 0;
            }
            .login form label {
                display: flex;
                justify-content: center;
                align-items: center;
                width: 50px;
                height: 50px;
                background-color: #ef4c3c;
                color: #ffffff;
            }
            .login form input[type="password"], .login form input[type="text"] {
                width: 310px;
                height: 50px;
                border: 1px solid #dee0e4;
                margin-bottom: 20px;
                padding: 0 15px;
                border-radius: 0px;
            }
            
        </style>
        <script>
        function send()
        {
            $.ajax({
                async: true,
                type: "POST",
                url: "verify.php",
                data:{
                    USER: $("#username").val(),
                    PASS: $("#password").val()
                },
                success:function(r)
                {
                    if(r=='ok')
                    {
                        window.location.replace("agent.php");
                    }
                    else if(r == 1 || r==2 || r==0)
                    {
                        window.location.replace("index.php?err="+r);
                    }
                    else if(r=='yay')
                    {
                        console.log($("#username").val() + $("#password").val());
                    }
                    else
                    {
                        console.log(r);
                    }
                }
            });
        }
        </script>
    </head>
    <body>
    <!--login form-->
	<div class="login">
        <h2 class="abril">WalleTT</h2>
        <!--error messsage for not entered parameters-->
            <?php if (isset($_GET['err']) && $_GET['err'] == 0): ?>
                <p style="color:red;display:flex;padding:10px 0 0 20px">*Please enter both fields!</p> 
            <?php endif; ?>
            <!--error message for failure to get UAC-->
            <?php if (isset($_GET['err']) && $_GET['err'] == 1): ?>
                <p style="color:red;display:flex;padding:10px 0 0 20px">*Incorrect username/password!</p>
            <?php endif; ?>
            <?php if (isset($_GET['err']) && $_GET['err'] == 2): ?>
                <p style="color:red;display:flex;padding:10px 0 0 20px">*User does not exist</p>
            <?php endif; ?>
            <?php if (isset($_GET['err']) && $_GET['err'] == 3): ?>
                <p style="color:red;display:flex;padding:10px 0 0 20px">*Server error. Please try again.</p>
            <?php endif; ?>
            <?php if (isset($_GET['err']) && $_GET['err'] == 4): ?>
                <p style="color:red;display:flex;padding:10px 0 0 20px">*Session timed out.</p>
            <?php endif; ?>
        <form id="login-form" method="post" action="verify.php">
            
	        <label for="USER"><i class="fas fa-user"></i></label><input type="text" placeholder="User ID" name="USER" id="username" required>
	        <label for="PASS"><i class="fas fa-lock"></i></label><input type="password" placeholder="Password" name="PASS" id="password" required>
    	<input type="button" value="Login" class="abril sb obutton" onclick="send()" style='border-radius:0px;'>
	</div>
	
	
</div>
    </body>
</html>