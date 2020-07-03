<?php
//_________________________timeout if its ajax file
include("conn.php");
if(isset($_SESSION['logout'])&&$_SESSION['logout']==TRUE){
    echo "signOut";
    exit();
}
//_____________________________________________________
if(isset($_POST['PWD']))
{
    if($_SESSION['LEVEL']==0)
    {
        header("Location: stores.php");
        exit();
    }
    $id= $_SESSION['ID'];
    $pw= $_POST['PWD'];
    //ask for admin password
    $adminPass = mysqli_fetch_array(mysqli_query($conn, "SELECT _password FROM agents WHERE _id = '$id';"))[0];
    if(password_verify($pw, $adminPass))
    {
        if(isset($_POST['NewUser'], $_POST['NewPass'], $_POST['PhoneNumber']))
        {
            $vendor = $_POST['NewUser'];
            $pw = password_hash($_POST['NewPass'], PASSWORD_DEFAULT);
            $Phone=$_POST['PhoneNumber'];

            $stmt_check_store = mysqli_stmt_init($conn);
            $stmt_insert_new = mysqli_stmt_init($conn);

            if(mysqli_stmt_prepare($stmt_check_store, "SELECT _id  FROM stores WHERE _vendor = ?") && mysqli_stmt_prepare($stmt_insert_new,"INSERT INTO stores(_id, _vendor, _password, _telephone) VALUES (?,?,?,?)"))
            {
                mysqli_stmt_bind_param($stmt_check_store,'s', $vendor);
                mysqli_stmt_execute($stmt_check_store);
                mysqli_stmt_store_result($stmt_check_store);

                if(mysqli_stmt_num_rows($stmt_check_store) == 0)
                {
                    //prepare to create new Vendor
                    $max=mysqli_fetch_array(mysqli_query($conn,"SELECT _id FROM stores ORDER BY _id DESC LIMIT 1;"))[0];
                    $newNum = intval(substr($max, 1)) + 1;
                    $newId = "S".str_pad($newNum, 3, '0', STR_PAD_LEFT);

                    mysqli_stmt_bind_param($stmt_insert_new,"ssss",$newId,$vendor,$pw,$Phone);
                    if(mysqli_stmt_execute($stmt_insert_new))
                    {
                        echo "ok";
                    }
                    else
                    {
                        echo "Failed to register. Please try again.";
                    }
                }
                else
                {
                    echo $pw;
                    echo "*Store with same name already exists!";
                }
                mysqli_stmt_close($stmt_check_store);
                mysqli_stmt_close($stmt_insert_new);
            }
            else
            {
                echo "Something went wrong! Please try again.";
            }
        }
        else
        {
            echo "Couldn't get info! Please try again.";
        }
    }
    else
    {
        echo "*Admin password incorrect!";
    }
}
else
{
    echo "*Please fill all fields.";
}
?>