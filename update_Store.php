<?php
//_________________________timeout if its ajax file
include("conn.php");
if(isset($_SESSION['logout'])&&$_SESSION['logout']==TRUE){
    echo "signOut";
    exit();
}
//_____________________________________________________
if(isset($_POST['PWD'])){
    if($_SESSION['LEVEL']==0)
    {
        header("Location: stores.php");
        exit();
    }
    $id= $_SESSION['ID'];
    $pw= $_POST['PWD'];
    $stmt= mysqli_stmt_init($conn);
        //ask for admin password
        if(mysqli_stmt_prepare($stmt, "SELECT _password FROM `agents` WHERE _id=? ")){
            mysqli_stmt_bind_param($stmt, 's', $id);
            mysqli_stmt_execute($stmt);
            mysqli_stmt_store_result($stmt);
            mysqli_stmt_bind_result($stmt,$pwd);
            mysqli_stmt_fetch($stmt);
            if(password_verify( $pw, $pwd)){
                
            if(isset($_POST['CHANGES']) && $_POST['CHANGES']!="{}"){
                $Changes=json_decode($_POST['CHANGES']);
                $_keyID=array_keys((array)$Changes);
                $count=0;
                $stmt = mysqli_stmt_init($conn);
                foreach($Changes as $key){
                    $success=true;
                    $vendorid=$_keyID[$count];
                    $bind_param=[];
                    $a = array_keys((array)$key);
                    for($i=0; $i<count($a);$i++){
                        $str=$a[$i];
                        $value=$key->$str;
                        $sql="UPDATE stores SET ".$a[$i]."=? WHERE _id=?";
                        if(mysqli_stmt_prepare($stmt,$sql)){
                            mysqli_stmt_bind_param($stmt,'ss', $value, $vendorid);
                            if(!mysqli_stmt_execute($stmt)){
                                $success = false;
                            }
                        }
                    }
                    $count++;
                }
                mysqli_stmt_close($stmt);
                if($success==false){
                    echo "Some Error has occured. Please try again.";
                }elseif ($success==true) {
                    echo "ok";
                }
            }else{echo "No changes detected";}
        }else{ echo "Password does not match";}
    }else{echo "An error has occured";}
}else{echo "Please enter password";}
?>