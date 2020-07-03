<?php
include("conn.php");
$arr=array();
if(isset($_POST['USER'], $_POST['PASS']))
{   
    $user = $_POST['USER'];
    $pw = $_POST['PASS'];
    if($user!='' && $pw!='')
    { 
        
    //using prepared statements to prevent sql injections
        $stmt = mysqli_stmt_init($conn);
   
        if(mysqli_stmt_prepare($stmt, "SELECT _name, _level,_password, _owing  FROM agents WHERE _id = ?"))
        {
            mysqli_stmt_bind_param($stmt, 's', $user);
            mysqli_stmt_execute($stmt);
            mysqli_stmt_store_result($stmt);
            
            if (mysqli_stmt_num_rows($stmt)> 0) 
            {
                mysqli_stmt_bind_result($stmt, $name, $lvl, $pass, $balance);
                mysqli_stmt_fetch($stmt);
                // Account exists, now we verify the password.
                
                if (password_verify($pw, $pass)) 
                {
                    // Verification success! User has loggedin!
                    // Create sessions so we know the user is logged in, they basically act like cookies but remember the data on the server.
                    if(isset($_POST['type']) && $_POST['type']=='login')
                    {
                        $arr['name'] = $name;
                        $arr['status'] = 'agent';
                        $arr['balance'] = $balance;
                        echo json_encode($arr);
                    }
                    else
                    {
                        session_regenerate_id();
                        $_SESSION['LOGIN'] = true;
                        $_SESSION['NAME'] = $name;
                        $_SESSION['ID'] = $user;
                        $_SESSION['LEVEL'] = $lvl;
                        $_SESSION['last_time'] = time();
                        echo 'ok';
                    }
                } 
                else 
                {
                    $arr['status'] = 'ID/password incorrect';
                    echo (isset($_POST['type']) && $_POST['type']=='login' ? json_encode($arr) : 1);
                }
            } 
            else 
            {
                $arr['status'] = 'User does not exist';
                echo (isset($_POST['type']) && $_POST['type']=='login' ? json_encode($arr) : 2);
            }
            
            mysqli_stmt_close($stmt);
            
        }
        else
        {
            $arr['status'] = 'Server error';
            echo (isset($_POST['type']) && $_POST['type']=='login' ? json_encode($arr) : 3);
        }
    }
    else
    {
        $arr['status'] = 'Empty fields';
        echo (isset($_POST['type']) && $_POST['type']=='login' ? json_encode($arr) : 2);
    }
}
else
{
    echo "Empty fields";
}

?>