<!DOCTYPE html>
<html>
    <head>
    <?php
        include("conn.php");
        include("meta.html");
        include('nav.php');
        if($_SESSION['LEVEL']==0)
        {
            header("Location: stores.php");
            exit();
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
        var admin=$("#_admin").val()
        if(admin!='' && $("#username").val()!='' && $("#password").val()!='' && $("#phone").val()!='')
        {
            $.ajax({
                type: "POST",
                url:"create_store.php",
                data:{
                    PWD: admin,
                    NewUser: $("#username").val(),
                    NewPass: $("#password").val(),
                    PhoneNumber: $("#phone").val()
                },
                success:function(r){
                        if(r=="signOut"){
                            window.location.replace("index.php?logout=true&err=4");
                            //session time Out
                        }
                        else if(r =="ok")
                        {
                            window.location.replace("stores.php");
                        }
                        else{
                            $("#warning").html(r);
                        }
                    }
            });
        }
        else
        {
            alert("Please fill all fields!")
        }
    }
    function back(){
        window.location.replace("stores.php")
    }
    </script>
    </head>
    <body>
        <div class="container">
    <div class="eds">
        <h2 class="abril">Register Store</h2>
        <form id="login-form" method="post" action="NewStore.php">
            <p style="color:red" id="warning"></p>
            <div>
                <label><i class="fa fa-store-alt"></i></label><input type="text" placeholder="Enter vendor name" name="USER" id="username" required>
            </div>
            <div>
                <label><i class="fa fa-lock"></i></label><input type="password" placeholder="Enter password" name="PASS" id="password" required>
            </div>
            <div>
                <label><i class="fa fa-phone"></i></label><input type="text" placeholder="Enter phone number" name="PHONE" id="phone" required>
            </div>
            <div>
                <label><i class="fa fa-shield-alt"></i></label><input type="password" placeholder="Admin password" name="ADMIN" id="_admin" required>
            </div>
        <button type="button" class="abril sb obutton" onclick="execute()" style="width:50%">Submit</button>
        <button type="button" class="abril sb bbutton" onclick="back()" style="width:50%">Back</button>
        </form>
    </div>
</div>
    </body>
</html>