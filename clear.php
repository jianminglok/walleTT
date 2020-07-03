<?php
//_________________________timeout if its ajax file
include("conn.php");
if(isset($_SESSION['logout'])&&$_SESSION['logout']==TRUE){
    echo "signOut";
    exit();
}
//_____________________________________________________
if(isset($_POST['clear']))
{
    $reg = $_POST['clear'];
    $admin = $_SESSION['ID'];
    $money = $_POST['amount'];
    mysqli_begin_transaction($conn);
    try
    {
        mysqli_query($conn, "UPDATE agents SET _owing = 0 WHERE _id='$reg';");
        mysqli_query($conn, "INSERT INTO clears(_agent, _admin, _amount) VALUES('$reg', '$admin', $money);");
        mysqli_query($conn, "UPDATE topup SET _cleared = 1 WHERE _agent='$reg';");
        mysqli_commit($conn);
        echo 'ok';
    }
    catch(Exception $e)
    {
        mysqli_rollback($conn);
        echo 'Sorry, something went wrong!';
    }
}
?>