<html>
    <head>
        <?php 
            include('conn.php');
            include('meta.html');
        ?>
        <style>
            body {
                background-color: #bfbfbf;
            }
            .regs {
                width: 75%;
                background-color: #ffffff;
                box-shadow: 0 0 9px 0 rgba(0, 0, 0, 0.3);
                margin: 100px auto;
            }
            .regs h2{
                text-align: center;
                color: #5b6574;
                font-size: 24px;
                padding: 20px 0 20px 0;
                border-bottom: 1px solid #dee0e4;
            }
            .regs form {
                display: flex;
                flex-wrap: wrap;
                justify-content: center;
                padding-top: 20px;
            }
            .regs form label {
                display: flex;
                justify-content: center;
                align-items: center;
                width: 3rem;
                height: 3rem;
                background-color: #ef4c3c;
                color: #ffffff;
            }
            .regs form div {
                display:flex;
                justify-content: center;
                width:80%;
            }
            .regs form p{
                width:75%
            }
            .regs form input{
                width: 75%;
                height: 3rem;
                border: 1px solid #dee0e4;
                margin-bottom: 20px;
                padding: 0 15px;
                border-radius: 0px;
            }
            .regs form select {
                -webkit-appearance:none;
                -moz-osx-appearance:none;
                border-radius: 0px;
                width: 75%;
                height: 3rem;
                margin-bottom:20px;
            }
           
        </style>
    </head>
    <?php include('nav.php'); 
        if(isset($_POST['TYPE']))
        {
            $type =  $_POST['TYPE'];
            if($type == 'agent')
            {
                if($_SESSION['LEVEL']!=2)
                {
                    header("Location: agent.php");
                    exit();
                }
                $max = intval(substr(mysqli_fetch_assoc(mysqli_query($conn, "SELECT * FROM agents ORDER BY _id DESC LIMIT 1;"))['_id'], 1)) + 1;
                $default = "A";
                for($i=0; $i < (2-floor(log($max, 10)));$i++)
                {
                    $default.="0";
                }
                $default.=$max;
            }
            else if($type=='buyer' && $_SESSION['LEVEL']==0)
            {
                header("Location: buyer.php");
                exit();
            }
        }
        else
        {
            header("Location: agent.php");
            exit();
        }
    ?>
    <body>
        <script>
            function back()
            {
                <?php if($type=='agent'):?>
                window.location.href = 'agent.php';
                <?php elseif($type=='buyer'):?>
                window.location.href = 'buyer.php'
                <?php endif; ?>
            }
            function send(shit)
            {
                <?php if($type=='agent'):?>
                if($("#lvl_sel").val()!='no' && $("#_id").val()!='' && $("#_username").val()!='' && $("#_admin").val()!='' && $("#_pass").val()!='')
                {
                    $.ajax({
                        type: 'POST',
                        url: 'reg.php',
                        data: {
                            reg: $("#_id").val(),
                            username: $("#_username").val(),
                            pass: $("#_pass").val(),
                            admin: $("#_admin").val(),
                            cla: $("#_cla").val(),
                            status:$("#lvl_sel").val(),
                            typ:shit
                        }, 
                        success: function(a){
                            if(a=="signOut"){
                                window.location.replace("index.php?logout=true&err=4");
                                //session time Out
                            }
                            else if(a!='ok')
                            {
                                $("#_warn").html(a);
                            }
                            else{
                                window.location.replace('agent.php');
                            }
                        }
                    });
                }
                else
                {
                    alert('Please fill all fields');
                }
                <?php elseif($type=='buyer'): ?>
                if(isNaN($("#_id").val()) || $("#_id").val() < 1 || $("#_id").val() > 9999999)
                {
                    alert("Invalid ID!")
                }
                else if($("#_id").val()!='' && $("#_agent").val()!='' && $("#_money").val()!='' && $("#_phone").val()!='' && $("#_username").val()!='')
                {
                    $.ajax({
                        type: 'POST',
                        url: 'reg.php',
                        data: {
                            reg: $("#_id").val(), //new id
                            username: $("#_username").val(), //new name
                            phone: $("#_phone").val(), //new phone no.
                            agent: $("#_agent").val(), //agent password
                            money:$("#_money").val(), //initial top up amount
                            typ:shit
                        }, 
                        success: function(a){
                            if(a=="signOut"){
                                window.location.replace("index.php?logout=true&err=4");
                                //session Time Out
                            }
                            else if(a!='ok')
                            {
                                $("#_warn").html(a);
                            }
                            else{
                                window.location.replace('buyer.php');
                            }
                        }
                    });
                }
                else
                {
                    alert('Please fill all fields');
                }
                <?php endif; ?>
                
            }
        </script>
        <div class="container">
            <?php if($type=='agent'):?>
            <div class="regs">
            <h2 class="abril">Agents registration</h2>
                <form>
                    <input class='d-none' name='typ' value='agent'>
                    <div><p id='_warn' style='color:red;'></p></div>
                    <div>
                        <label for='reg'>ID</label><input name="reg" type="text" placeholder='Enter ID' required id='_id' maxlength=4 value='<?php echo $default; ?>'>
                    </div>
                    <div >
                        <label for='username'><i class="fa fa-id-card"></i></label><input name="username" type="text" placeholder='Enter name' required id='_username'>
                    </div>
                    <div >
                        <label for='pass'><i class="fa fa-lock"></i></label><input name="pass" type="password" placeholder='Enter password' required id='_pass' maxlength=20>
                    </div>
                    <div >
                        <label for='cla'><i class="fa fa-users"></i></label><input name="cla" type="text" placeholder='Enter class' id='_cla' maxlength=3>
                    </div>
                    <div >
                        <label for='lvl'><i class="fa fa-user-cog"></i></label>
                        <select class="form-control" id="lvl_sel" name="lvl">
                            <option disabled selected value='no'>SELECT STATUS</option><option value="0">Top-up agent</option>
                            <option value="1">Customer Service</option><option value="2">Admin</option>
                        </select>
                    </div>
                    <div >
                        <label for='admin'><i class="fa fa-shield-alt"></i></label>
                        <input name="admin" type="password" placeholder='Admin password' required id='_admin'>
                    </div>
                </form>
                <button class="sb obutton abril" style="width:50%;" onclick="send('agent')">Submit</button><button class="sb bbutton abril" style="width:50%;" onclick="back()">Back</button>
            </div>
            <?php elseif($type=='buyer'):?>
            <div class="regs">
            <h2 class="abril">Users registration</h2>
                <form>
                    <input class='d-none' name='typ' value='buyer'>
                    <div><p id='_warn' style='color:red;'></p></div>
                    <div >
                        <label for='reg'><i class="fa fa-id-card"></i></label><input name="reg" type="text" placeholder='Enter ID' required id='_id' maxlength=7>
                    </div>
                    <div >
                        <label for='username'><i class="fa fa-portrait"></i></label><input name="username" type="text" placeholder='Enter name' required id='_username'>
                    </div>
                    <div >
                        <label for='phone'><i class="fa fa-phone"></i></label><input name="phone" type="number" placeholder='Enter phone no.' id='_phone' maxlength=11>
                    </div>
                    <div >
                        <label for='money'><i class="fa fa-dollar-sign"></i></label><input name="money" type="number" placeholder='First topup amount' id='_money' max='200' min='0'>
                    </div>
                    <div >
                        <label for='agent'><i class="fa fa-shield-alt"></i></label><input name="agent" type="password" placeholder='Agent password' required id='_agent'>
                    </div>
                </form>
                <button class="sb obutton abril" style="width:50%;" onclick="send('buyer')">Submit</button><button class="sb bbutton abril" style="width:50%;" onclick="back()">Back</button>
            </div>
            <?php endif; ?>
        </div>
    </body>
</html>