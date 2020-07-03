<?php
//vendor change password
//_________________________timeout if its ajax file
include("conn.php");
if(isset($_SESSION['logout'])&&$_SESSION['logout']==TRUE){
    echo "signOut";
    exit();
}
//_____________________________________________________
if(isset($_POST['PWD'],$_POST['NewPassword'],$_POST['VENDORID']))
{
    $pw=$_POST['PWD'];
    $id=$_SESSION['ID'];
    $vendorId=$_POST['VENDORID'];
    //check for admin password-
    $adminPass = mysqli_fetch_array(mysqli_query($conn, "SELECT _password FROM `agents` WHERE _id = '$id';"))[0];

    if(password_verify($pw, $adminPass))
    {
        //update to new password
        $newPassword=password_hash($_POST['NewPassword'], PASSWORD_DEFAULT);

        $stmt=mysqli_stmt_init($conn);
        if(mysqli_stmt_prepare($stmt,"UPDATE `stores` SET _password = ? WHERE _id = ?;"))
        {
            mysqli_stmt_bind_param($stmt,"ss",$newPassword,$vendorId);
            if(mysqli_stmt_execute($stmt))
            {
                echo "ok";
            }
            else
            {
                echo "Failed to update database. Pleae try again.";
            }
        }
        else
        {
            echo "Something went wrong! Please try again.";
        }
        mysqli_stmt_close($stmt);
    }
    else
    {
        echo "*Admin password incorrect!";
    }
}
else
{
    echo "Couldn't get info! Please try again.";
}
?>