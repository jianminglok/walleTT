<?php
//_________________________timeout if its ajax file
include("conn.php");
if(isset($_SESSION['logout'])&&$_SESSION['logout']==TRUE){
    echo "signOut";
    exit();
}
//_____________________________________________________
if(isset($_POST['TYP'])){

    if($_SESSION['LEVEL']==0)
    {
        header("Location: stores.php");
        exit();
    }
    $id= $_SESSION['ID'];
    if($_POST['TYP']=="drop" && isset($_POST['CHANGES']))
    {
        //delete products if $_POST ==drop
        $stmt= mysqli_stmt_init($conn);
        $id=$_POST['CHANGES'];
        if(mysqli_stmt_prepare($stmt, "DELETE FROM `products` WHERE `products`.`_id` = ?")){
            mysqli_stmt_bind_param($stmt, 's', $id);
            if(mysqli_stmt_execute($stmt)){
                echo ":)";
            }else{
                echo "Failed to delete. Please try again.";
            }
            
        }
        
        
    }
    else if($_POST['TYP']=='updateProduct')
    {
        //edit info
        $pw= $_POST['PWD'];
        $stmt= mysqli_stmt_init($conn);
        if(mysqli_stmt_prepare($stmt, "SELECT _password FROM `agents` WHERE _id = ? "))
        {
            //ask for admin password
            mysqli_stmt_bind_param($stmt, 's', $id);
            mysqli_stmt_execute($stmt);
            mysqli_stmt_store_result($stmt);
            mysqli_stmt_bind_result($stmt, $pwd);
            mysqli_stmt_fetch($stmt);
            mysqli_stmt_close($stmt);
            
            if(password_verify( $pw, $pwd)){
                if(isset($_POST['CHANGES'])&& $_POST['CHANGES']!="{}"){
                    $success=true;
                    $changes=json_decode($_POST['CHANGES'], true);
                        $stmt = mysqli_stmt_init($conn);

                        foreach($changes as $id=>$type){
                            foreach($type as $key=>$value){
                                if($key=="_price"){
                                    $value=str_replace("RM","",$value);
                                }
                                $sql="UPDATE products SET $key = ? WHERE _id = ?";
                                if(mysqli_stmt_prepare($stmt,$sql)){
                                    mysqli_stmt_bind_param($stmt,'ss',$value,$id);
                                    if(!mysqli_stmt_execute($stmt)){
                                        $success= false;
                                    }
                                }
                            }
                        }
                        if($success===false){
                            echo "Some Error has occured. Please try again.";
                        }elseif ($success===true) {
                            echo ":)";
                        }
                    }
                    else
                    {
                        echo("No changes were detected");
                    }
                }
                else
                {
                    echo "Password does not match with user";
                }
            }
            else
            {
                echo "An error has occured, please try again";
            }
        }
}else{echo "Please enter all feilds";}

?>