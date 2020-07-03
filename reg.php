<?php
    //_________________________timeout session
    include("conn.php");
    if(isset($_SESSION['logout'])&&$_SESSION['logout']==TRUE){
        echo "signOut";
        exit();
    }
    //_____________________________________________________


    if(isset($_POST['typ']))
    {
        if($_POST['typ']=='agent' && $_SESSION['LEVEL']!=2)
        {
            header("Location: agent.php");
            exit();
        }

        if($_POST['typ']=='agent')
        {
            $new_id=$_POST['reg'];
            $new_name=$_POST['username'];
            $new_pass=password_hash($_POST['pass'], PASSWORD_DEFAULT);
            $new_lvl=$_POST['status'];
            $new_cla=$_POST['cla'];
            $admin_pass=$_POST['admin'];

            $list=array();
            $r=mysqli_query($conn, "SELECT _id FROM agents;");
            while($row=mysqli_fetch_assoc($r))
            {
                array_push($list, $row['_reg']);
            }

            //check if reg exists
            if(!in_array($new_id, $list))
            {

                $admin = $_SESSION['ID'];
                $ver=mysqli_fetch_array(mysqli_query($conn, "SELECT _password FROM agents WHERE _id='$admin';"))[0];

                //check if admin password correct
                if(password_verify($admin_pass, $ver))
                {
                    //insert info
                    $stmt = mysqli_stmt_init($conn);
        
                    if(mysqli_stmt_prepare($stmt, "INSERT INTO agents(_id, _name, _class, _level, _password) VALUES(?, ?, ?, ?, ?);"))
                    {
                        mysqli_stmt_bind_param($stmt, 'sssis', $new_id, $new_name, $new_cla, $new_lvl, $new_pass);
                        mysqli_stmt_execute($stmt);
                    }
                    else
                    {
                        echo 'Registration failed, please try again.';
                    }

                    $stmt->close();
                    echo 'ok';
                }
                else
                {
                    echo 'Admin password incorrect';
                }
            }
            else
            {
                echo 'User id already exists!';
            }

        }
        else if($_POST['typ']=='buyer')
        {
            $new_name=$_POST['username'];
            $new_amount=$_POST['money'];
            $new_phone=$_POST['phone'];
            $agent_pass=$_POST['agent'];

            $list=array();
            $r=mysqli_query($conn, "SELECT _id FROM users;");
            while($row=mysqli_fetch_assoc($r))
            {
                array_push($list, $row['_id']);
            }

            if(isset($_POST['type']) && $_POST['type']=='registration')
            {
                $agent = $_POST['agentId'];
                $stuff = explode(';', $_POST['reg']);
                $new_id = substr($_POST['reg'], 0, 8);
                $code = substr($_POST['reg'], 9, 69);
                $codesum = $_POST['reg'][8];
                
                $crypt = str_split($new_id);
                $cryptsum = 0;
                for($y = 0; $y < sizeof($crypt); $y++) {
                    $cryptsum += (int)$new_id[$y];
                }
                
                if((int)$codesum == $cryptsum % 10) {
                    $passed = true;
                } else {
                    $passed = false;
                }
            }
            else
            {
                $agent = $_SESSION['ID'];
                $new_id='U'.str_pad($_POST['reg'], 7, "0", STR_PAD_LEFT);
            }

            if((isset($_POST['type']) && !password_verify(substr($new_id, 3, -1), $code)) || (isset($_POST['type']) && !$passed))
            {
                echo 'Registration failed';
            }
            else
            {    //check if reg exists
                if(!in_array($new_id, $list))
                {
                    $ver=mysqli_fetch_array(mysqli_query($conn, "SELECT _password FROM agents WHERE _id='$agent';"))[0];

                    //check if admin password correct
                    if(password_verify($agent_pass, $ver))
                    {
                        //insert info
                        mysqli_autocommit($conn, FALSE);
                        $query_success = TRUE;

                        $stmt1 = mysqli_stmt_init($conn);
            
                        mysqli_stmt_prepare($stmt1, "INSERT INTO users(_id, _balance, _telephone, _name) VALUES(?, ?, ?, ?);");
                        mysqli_stmt_bind_param($stmt1, 'siss', $new_id, $new_amount, $new_phone, $new_name);
                        if(!mysqli_stmt_execute($stmt1))
                        {
                            $query_success = FALSE;
                        }
                        mysqli_stmt_close($stmt1);

                        if($new_amount>0)
                        {
                            $stmt2 = mysqli_stmt_init($conn);
                            mysqli_stmt_prepare($stmt2, "INSERT INTO topup( _buyer, _agent, _amount) VALUES(?, ?, ?);");
                            mysqli_stmt_bind_param($stmt2, 'ssi', $new_id, $agent, $new_amount);
                            if(!mysqli_stmt_execute($stmt2))
                            {
                                $query_success = FALSE;
                            }
                            mysqli_stmt_close($stmt2);

                            $stmt3 = mysqli_stmt_init($conn);
                            mysqli_stmt_prepare($stmt3, "UPDATE agents SET _owing = _owing + ? WHERE _id='$agent';");
                            mysqli_stmt_bind_param($stmt3, 'i', $new_amount);
                            if(!mysqli_stmt_execute($stmt3))
                            {
                                $query_success = FALSE;
                            }
                            mysqli_stmt_close($stmt3);

                        }
                        if($query_success)
                        {
                            mysqli_commit($conn);
                            echo 'ok';
                        }
                        else
                        {   
                            mysqli_rollback($conn);
                            echo 'Registration failed.';

                        }
                    }
                    else
                    {
                        echo 'Agent password incorrect';
                    }
                }
                else
                {
                    echo 'User id already exists!';
                }
            }
        }
    }
?>
