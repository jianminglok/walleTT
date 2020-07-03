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
            .eds {
                width: 75%;
                background-color: #ffffff;
                box-shadow: 0 0 9px 0 rgba(0, 0, 0, 0.3);
                margin: 100px auto;
            }
            .eds h2{
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
                display:flex;
                justify-content: center;
                width:80%;
            }
            .eds form p{
                width:75%
            }
            .eds form input{
                width: 75%;
                height: 3rem;
                border: 1px solid #dee0e4;
                margin-bottom: 20px;
                padding: 0 15px;
                border-radius: 0px;
            }
            .eds form select {
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
            $cur_id='';
            $type=$_POST['TYPE'];
            if($type=='agent')
            {
                if($_SESSION['LEVEL']!=2)
                {
                    header("Location: agent.php");
                    exit();
                }
                $cur_id = $_POST['REG'];
                $res = mysqli_query($conn, "SELECT _name, _class, _level FROM agents WHERE _id='$cur_id';");
                while($row=mysqli_fetch_assoc($res))
                {
                    $cur_name=$row['_name'];
                    $cur_cla=$row['_class'];
                    $cur_lvl=$row['_level'];
                }
            }
            else if($type=='buyer')
            {
                if($_SESSION['LEVEL']==0)
                {
                    header("Location: buyer.php");
                    exit();
                }
                $cur_id = $_POST['REG'];
                $res = mysqli_query($conn, "SELECT _name, _telephone FROM users WHERE _id = 'U$cur_id';");
                while($row=mysqli_fetch_assoc($res))
                {
                    $cur_name=$row['_name'];
                    $cur_phone=$row['_telephone'];
                }
            }
            else if($type=='transfer')
            {
                if($_SESSION['LEVEL']==0)
                {
                    header("Location: buyer.php");
                    exit();
                }
                $froze = $_POST['FROZE'];
            }
        }
        else
        {
            header("Location: ");
            exit();
        }
    ?>
    <body>
        <script>

            var type = '<?php echo $type; ?>';
            function back()
            {
                window.location.href = '<?php echo $type; ?>.php';
            }
            var cur = "<?php echo $cur_id; ?>";
            var stuff = {};
            stuff[cur]={}
            function edit(id)
            {
                stuff[cur][id] = $("#" + id).val();
            }
            function send(shit)
            {
                if($("#_agent").val()=='')
                {
                    $("#_warn").html("*Please enter admin password!")
                }
                else if(shit='agent' && $("#_password").val()=='')
                {
                    $("#_warn").html("*Password field can't be left empty!")
                }
                else if(shit='agent' && $("#_password").val()!=$("#_confirm").val())
                {
                    $("#_warn").html("*Passwords don't match. Please enter the same password for both the new password and confirmation fields")
                }
                else
                {
                    $.ajax({
                        type: 'POST',
                        url: 'ed.php',
                        data: {
                            CHANGES: JSON.stringify(stuff),
                            AGENT:$("#_agent").val(),
                            TYP: '<?php echo $type; ?>'
                        }, 
                        success: function(a){
                            if(a=="signOut"){
                                //sessionTimedOUT
                                window.location.replace('index.php?logout=true&err=4');
                            }
                            else if(a!='ok')
                            {
                                $("#_warn").html(a);
                            }
                            else{
                                <?php if($type=='agent'):?>
                                window.location.replace('agent.php');
                                <?php elseif($type=='buyer'): ?>
                                window.location.replace('buyer.php');
                                <?php endif;?>
                            }
                        }
                    });
                }
            }
            <?php if($type=='transfer'): ?>
            function trans()
            {
                if($("#_new").val()=='')
                {
                    alert("Please enter target user's ID!")
                }
                else if($("#_agent").val()=='')
                {
                    alert("Please enter agent password!")
                }
                else
                {
                    $.ajax({
                        type: 'POST',
                        url: 'ed.php',
                        data: {
                            NEW: $("#_new").val(),
                            FROZE: $("#_frozen").val(),
                            ADMIN:$("#_agent").val(),
                            TYP: '<?php echo $type; ?>'
                        }, 
                        success: function(a){
                            if(a=="signOut"){
                                window.location.replace('index.php?logout=true&err=4');
                            }
                            else if(a!='ok')
                            {
                                $("#_warn").html(a);
                            }
                            else{
                                window.location.replace('transfer.php');
                            }
                        }
                    });
                }
            }
        <?php endif;?>
        </script>
        <div class="container">
            <?php if($type=='agent'):?>
            <div class="eds">
            <h2 class="abril">Edit agents password</h2>
                <form>
                    <input class='d-none' name='typ' value='agent'>
                    <div><p id='_warn' style='color:red;'></p></div>
                    <div><label for='reg'><i class="fa fa-id-card"></i></label><input name="reg" type="text" disabled id='_id' value='<?php echo $cur_id; ?>'></div>
                    <div><label for='pass'><i class="fa fa-lock"></i></label><input name="pass" type="password" placeholder='Change password' required id='_password' maxlength=20 onchange='edit("_password")'></div>
                    <div><label for='pass'><i class="fa fa-check"></i></label><input name="pass" type="password" placeholder='Confirm password' required id='_confirm' maxlength=20></div>
                    <!--<div><label for='username'><i class="fa fa-portrait"></i></label><input name="username" type="text" placeholder='Change username' required id="_name" value="<?php //echo $cur_name; ?>" onchange='edit("_name")'></div>
                    <div><label for='cla'><i class="fa fa-users"></i></label><input name="cla" type="text" placeholder='Change class' id='_class' maxlength=3 value='<?php //echo $cur_cla; ?>' onchange='edit("_class")'></div>
                    <div><label for='lvl'><i class="fa fa-user-cog"></i></label><select class="form-control" id="lvl_sel" name="lvl" disabled><option value="0" <?php //if($cur_lvl==0){echo 'selected'; }?>>Top-up agent</option><option value="1"  <?php //if($cur_lvl==1){echo 'selected'; }?>>Admin</option></select></div>-->
                    <div><label for='admin'><i class="fa fa-shield-alt"></i></label><input name="admin" type="password" placeholder='Admin password' required id='_agent'></div>
                    <button type="button" class="sb obutton abril" style="width:50%;" onclick="send('agent')">Submit</button>
                    <button type="button" class="sb bbutton abril" style="width:50%;" onclick="back()">Back</button>
                </form>
                
            </div>
            <?php elseif($type=='buyer'):?>
            <div class="eds">
            <h2 class="abril">Edit users info</h2>
                <form>
                    <input class='d-none' name='typ' value='buyer'>
                    <div><p id='_warn' style='color:red;'></p></div>
                    <div><label for='reg'><i class="fa fa-id-card"></i></label><input name="reg" type="text" disabled id='_id' value='<?php echo $cur_id; ?>'></div>
                    <div><label for='username'><i class="fa fa-portrait"></i></label><input name="username" type="text" placeholder='Change username'  id="_name" value="<?php echo $cur_name; ?>" onchange='edit("_name")'></div>
                    <div><label for='phone'><i class="fa fa-phone"></i></label><input name="phone" type="number" placeholder='Change phone no.'  id='_telephone' maxlength=11 onchange='edit("_telephone")' value="<?php echo $cur_phone;?>"></div>
                    <div><label for='agent'><i class="fa fa-shield-alt"></i></label><input name="agent" type="password" placeholder='Agent password' required id='_agent'></div>
                </form>
                <button class="sb obutton abril" style="width:50%;" onclick="send('buyer')">Submit</button><button class="sb bbutton abril" style="width:50%;" onclick="back()">Back</button>
            </div>
            <?php elseif($type=='transfer'):?>
            <div class="eds">
            <h2 class="abril">Transfer user balance</h2>
                <form>
                    <input class='d-none' name='typ' value='transfer'>
                    <div><p id='_warn' style='color:red;'></p></div>
                    <div><label for='reg'><i class="fa fa-ice-cream"></i></label><input name="reg" type="text" disabled id='_frozen' value='<?php echo $froze; ?>'></div>
                    <div><label for='new' class='poppins'>NEW</label><input name="new" type="text" placeholder='Target user ID'  id="_new"></div>
                    <div><label for='agent'><i class="fa fa-shield-alt"></i></label><input name="agent" type="password" placeholder='Agent password' required id='_agent'></div>
                </form>
                <button class="sb obutton abril" style="width:50%;" onclick="trans()">Transfer</button><button class="sb bbutton abril" style="width:50%;" onclick="back()">Back</button>
            </div>
            <?php endif; ?>
        </div>
    </body>
</html>