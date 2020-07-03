<html>
    <head>
    <?php
        include("conn.php");
        include("meta.html");
        include('nav.php');
        if ($_SESSION['LEVEL']==0){
            header("Location: products.php");
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
    function execute()
    {
        var pwd = $("#_admin").val()
        if(pwd != '' && $("#productName").val() != '' && $("#price").val() != '' && $("#vendor").val() != '')
        {
            $.ajax({
                type: "POST",
                url:"create_product.php",
                data:{
                    PWD: pwd,
                    ProductName: $("#productName").val(),
                    Price: $("#price").val(),
                    Vendor: $("#vendor").val()
                },
                success:function(r){
                    if(r=="signOut"){
                        window.location.replace("index.php?logout=true&err=4");
                        //sesion time out
                    }
                    else if(r == "ok")
                    {
                        window.location.replace("products.php");
                    }
                    else{
                        $("#warning").html(r)
                    }
                }
            });
        }
        else
        {
            $("#warning").html('*Please enter all fields!')
        }
    }
    function back()
    {
        window.location.href = 'products.php'
    }
    </script>
    </head>
    <body>
        <div class="container">
            <div class="eds">
                <h2 class="abril">Register Product</h2>
                <form>
                    <p id="warning" style="color:red;"></p>
                    <div>
                        <label><i class="fa fa-drumstick-bite"></i></label><input type="text" placeholder="Enter product name" name="PRODUCT" id="productName" required>
                    </div>
                    <div>
                        <label>RM</label><input type="number" placeholder="Enter product price" name="PRICE" id="price" required>
                    </div>
                    <div>
                        <label><i class="fa fa-store-alt"></i></label><input type="text" placeholder="Enter vendor id" name="VENDOR" id="vendor" required>
                    </div>
                    <div>
                        <label><i class="fa fa-shield-alt"></i></label><input type="password" placeholder="Admin password" name="ADMIN" id="_admin" required>
                    </div>

                    <button type="button" class="abril sb obutton" style="width:50%" onclick="execute()">Submit</button>
                    <button type="button" class="abril sb bbutton" style="width:50%" onclick="back()">Back</button>
                </form>
            </div>
        </div>
    </body>
</html>