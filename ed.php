<?php
//_________________________timeout if its ajax file
include("conn.php");
if(isset($_SESSION['logout'])&&$_SESSION['logout']==TRUE){
    echo "signOut";
    exit();
}
//_____________________________________________________
if(isset($_POST['TYP']))
{
    if(($_POST['TYP']=='buyer' || $_POST['TYP']=='transfer') && $_SESSION['LEVEL']==0)
    {
        header("Location: buyer.php");
        exit();
    }
    else if($_POST['TYP']=='agent' && $_SESSION['LEVEL']!=2)
    {
        header("Location: agent.php");
        exit();
    }

    if($_POST['TYP']=='agent')
    {
        $admin = $_SESSION['ID'];
        $ver=mysqli_fetch_array(mysqli_query($conn, "SELECT _password FROM agents WHERE _id='$admin';"))[0];

        //check if admin password correct
        if(password_verify($_POST['AGENT'], $ver))
        {
            if(isset($_POST['CHANGES']))
            {
                mysqli_autocommit($conn, FALSE);
                $query_success = TRUE;
                $info=json_decode($_POST['CHANGES'], true);
                foreach($info as $cur_id=>$stuff)
                {
                    if(array_key_exists('_password', $stuff))
                    {
                        $stuff['_password']=password_hash($stuff['_password'], PASSWORD_DEFAULT);
                    }
                    //insert info
                    

                    foreach($stuff as $key=>$val)
                    {
                        $stmt = mysqli_stmt_init($conn);
                        mysqli_stmt_prepare($stmt, "UPDATE agents SET $key = ? WHERE _id ='$cur_id';");
                        mysqli_stmt_bind_param($stmt, 's', $val);
                        if(!mysqli_stmt_execute($stmt))
                        {
                            $query_success=FALSE;
                        }
                        mysqli_stmt_close($stmt);
                    }
                }
                if($query_success)
                {
                    mysqli_commit($conn);
                    echo 'ok';
                }
                else
                {
                    mysqli_rollback();
                    print_r($info);
                    //echo 'Failed to update database';
                }
            }
            else if(isset($_POST['DEL']))
            {
                $reg = $_POST['DEL'];
                $stmt = mysqli_stmt_init($conn);
                if(mysqli_stmt_prepare($stmt, "DELETE FROM agents WHERE _id = ?;"))
                {
                    mysqli_stmt_bind_param($stmt, 's', $reg);
                    mysqli_stmt_execute($stmt);
                    echo 'ok';
                }
                else
                {
                    echo 'Failed to delete.';
                }
                mysqli_stmt_close($stmt);
            }
        }
        else
        {
            echo 'Admin password incorrect';
        }

    }
    else if($_POST['TYP']=='buyer')
    {
        $agent = $_SESSION['ID'];
        $ver=mysqli_fetch_array(mysqli_query($conn, "SELECT _password FROM agents WHERE _id='$agent';"))[0];

        //check if admin password correct
        if(password_verify($_POST['AGENT'], $ver))
        {
            if(isset($_POST['CHANGES']))
            {
                $info=json_decode($_POST['CHANGES'], true);
                mysqli_autocommit($conn, FALSE);
                $query_success = TRUE;
                //insert info
                foreach($info as $cur_id=>$stuff)
                {

                    foreach($stuff as $key=>$val)
                    {
                        $stmt = mysqli_stmt_init($conn);
                        mysqli_stmt_prepare($stmt, "UPDATE users SET $key = ? WHERE _id ='U$cur_id';");
                        mysqli_stmt_bind_param($stmt, 's', $val);
                        if(!mysqli_stmt_execute($stmt))
                        {
                            $query_success=FALSE;
                        }
                        mysqli_stmt_close($stmt);
                    }
                }
                if($query_success)
                {
                    mysqli_commit($conn);
                    echo 'ok';
                }
                else
                {
                    mysqli_rollback($conn);
                    echo 'Failed to update database';
                }
            }
            else if(isset($_POST['DEL']))
            {
                $reg = 'U'.$_POST['DEL'];
                $stmt = mysqli_stmt_init($conn);
                if(mysqli_stmt_prepare($stmt, "DELETE FROM users WHERE _id = ?;"))
                {
                    mysqli_stmt_bind_param($stmt, 's', $reg);
                    mysqli_stmt_execute($stmt);
                    echo 'ok';
                }
                else
                {
                    echo 'Failed to delete.';
                }
                mysqli_stmt_close($stmt);
            }
        }
        else
        {
            echo 'Agent password incorrect';
        }
    }
    else if($_POST['TYP']=='transfer')
    {
        $pw = $_POST['ADMIN'];
        $froze = 'U'.$_POST['FROZE'];
        $new = 'U'.$_POST['NEW'];
        $admin=$_SESSION['ID'];

        $pass=mysqli_fetch_array(mysqli_query($conn, "SELECT _password FROM agents WHERE _id='$admin';"))[0];

        if(password_verify($pw, $pass))
        {
            $froze_balance = intval(mysqli_fetch_array(mysqli_query($conn, "SELECT _balance FROM users WHERE _id='$froze';"))[0]);
            $stmt = mysqli_stmt_init($conn);
            //check if the target user exist
            if(mysqli_stmt_prepare($stmt,"SELECT * FROM `users` WHERE _id= ?;")){
                mysqli_stmt_bind_param($stmt,'s',$new);
                mysqli_stmt_execute($stmt);
                mysqli_stmt_store_result($stmt);
                if(mysqli_stmt_num_rows($stmt) == 1){
                    //prepare to transfer
                    mysqli_stmt_prepare($stmt, "UPDATE users SET _balance = _balance + $froze_balance WHERE _id = ?;");
                    mysqli_stmt_bind_param($stmt, 's', $new);
                    if(mysqli_stmt_execute($stmt)){
                        mysqli_query($conn, "UPDATE users SET _balance = 0 WHERE _id = '$froze';");
                        mysqli_query($conn, "UPDATE freeze SET _transfer = '$new', _tadmin = '$admin' WHERE _user = '$froze';");
                        echo 'ok';
                    }else{echo"failed to transfer";};
                }else{echo "INvalid target id";};
            }else{echo 'Failed to transfer';}
            mysqli_stmt_close($stmt);
        }
        else
        {
            echo 'Admin password incorrect';
        }
    }
}
?>