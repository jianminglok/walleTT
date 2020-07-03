<html>
<head>
    <?php
        include("conn.php");
        include("meta.html");
        include('nav.php');
        if ((isset($_GET['err']) && $_GET['err'] == ":)") || !isset($_GET['r']) || $_SESSION['LEVEL']==0){
            header("Location: stores.php");
        }
    ?>
    <style>
        body {
            background-color: #bfbfbf;
        }

        .eds {
            width: 75%;
            background-color: #ffffff;
            box-shadow: 0 0 9px 0 rgba(0, 0, 0, 0.3);
            margin: 100px auto;
        }

        .eds h2 {
            text-align: center;
            color: #5b6574;
            font-size: 24px;
            padding: 20px 0 20px 0;
            border-bottom: 1px solid #dee0e4;
        }

        .eds form {
            display: flex;
            flex-wrap: wrap;
            justify-content: center;
            padding-top: 20px;
        }

        .eds form label {
            display: flex;
            justify-content: center;
            align-items: center;
            width: 3rem;
            height: 3rem;
            background-color: #ef4c3c;
            color: #ffffff;
        }

        .eds form div {
            display: flex;
            justify-content: center;
            width: 80%;
        }

        .eds form p {
            width: 75%
        }

        .eds form input {
            width: 75%;
            height: 3rem;
            border: 1px solid #dee0e4;
            margin-bottom: 20px;
            padding: 0 15px;
            border-radius: 0px;
        }

        .eds form select {
            -webkit-appearance: none;
            -moz-osx-appearance: none;
            border-radius: 0px;
            width: 75%;
            height: 3rem;
            margin-bottom: 20px;
        }

    </style>
    <script>
    function execute(){
        var newpwd=$("#NewPWD").val()
        var $id="<?php echo $_GET['r']; ?>";
        var pwd = $("#admin").val()

        if(newpwd==$('#retype').val())
        {
            if(pwd!='')
            {
                $.ajax({
                    type: "POST",
                    url:"change_password.php",
                    data:{
                        PWD: pwd,
                        VENDORID: $id,
                        NewPassword: newpwd
                    },
                    success:function(r){
                        if(r=="signOut"){
                            window.location.replace("index.php?logout=true");//session time out
                            //session time out
                        }
                        else if(r == "ok"){
                            window.location.replace("stores.php");
                        }
                        else{
                            $("#warning").html(r);
                        }
                    }
                });
            }
        }
        else
        {
            $("#warning").html("*Passwords don't match! Please enter the same passwords in both the new password and confirmation field.")
        }
    }
    function back()
    {
        window.location.href = 'stores.php';
    }
    </script>
</head>
<body>
    <div class="container">
    <div class="eds">
        <h2 class="abril">Edit store password</h2>
        <form>
            <p style="color:red" id="warning"></p>
            <div>
                <label for='reg'><i class="fa fa-id-card"></i></label><input name="reg" type="text" disabled id='_id' value='<?php echo $_GET['r']; ?>'>
            </div>
            <div>
                <label for="NEWPWD"><i class="fa fa-lock"></i></label><input type="password" placeholder="Change Password" name="NEWPWD" id="NewPWD" maxlength=20 required>
            </div>
            <div>
                <label for="RETYPENEWPWD"><i class="fa fa-check"></i></label><input type="password" placeholder="Confirm Password" name="RETYPENEWPWD" maxlength=20 id="retype" required>
            </div>
            <div>
                <label for="ADMIN"><i class="fa fa-shield-alt"></i></label><input type="password" placeholder="Admin Password" name="ADMIN" id="admin" required>
            </div>
            <button type="button"class="abril sb obutton" style="width:50%;" onclick="execute()">Submit</button>
            <button type="button"class="abril sb bbutton" style="width:50%;" onclick="back()">Back</button>
        </form>
    </div>
    </div>
</body>
</html>