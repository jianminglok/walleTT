<?php
function mysqliCommit($stmt) {
    mysqli_stmt_execute($stmt);
    mysqli_stmt_store_result($stmt);
}

//_________________________timeout if its ajax file
include("conn.php");
if(isset($_SESSION['logout'])&&$_SESSION['logout']==TRUE){
    echo "signOut";
    exit();
}
//_____________________________________________________
if($_SESSION['LEVEL']==0)
{
    header("Location: products.php");
    exit();
}

if(isset($_POST['PWD'],$_POST['ProductName'],$_POST['Vendor'],$_POST['Price'],$_SESSION['ID']))
{
    $product=$_POST['ProductName'];
    $vendor=$_POST['Vendor'];
    $Price=$_POST['Price'];
    $id=$_SESSION['ID'];
    $pw=$_POST['PWD'];
    $stores = array();

    $stores = array_map(function($i){ return $i[0]; } ,mysqli_fetch_all(mysqli_query($conn, "SELECT _id FROM stores;")));

    //ask for admin password
    $pwd = mysqli_fetch_array(mysqli_query($conn, "SELECT _password FROM `agents` WHERE _id = '$id';"))[0];

    if(password_verify($pw, $pwd))
    {
        if(in_array($vendor, $stores))
        {
            $stmt_check_product=mysqli_stmt_init($conn);
            $stmt_insert_new=mysqli_stmt_init($conn);
            if(mysqli_stmt_prepare($stmt_check_product,"SELECT * FROM products WHERE _name= ? AND _store = ? ") && 
            mysqli_stmt_prepare($stmt_insert_new,"INSERT INTO `products`(`_id`, `_store`, `_name`, `_price`) VALUES (?,?,?,?)"))
            {
                //"check if this product has been registered before in this store";
                mysqli_stmt_bind_param($stmt_check_product, 'ss', $product, $vendor);
                mysqliCommit($stmt_check_product);
                if(mysqli_stmt_num_rows($stmt_check_product)==0)
                {

                    $max = mysqli_fetch_array(mysqli_query($conn, "SELECT _id FROM `products` WHERE _store = '$vendor' ORDER BY _id DESC LIMIT 1;"))[0];
                    $ProductNumber = ($max != undefined ? intval(substr($max, 4)) : 0);

                    //create new id for the product
                    $NewProductVendorId = substr($vendor, 1);
                    $NewProductNumber=str_pad(($ProductNumber+1), 3, 0, STR_PAD_LEFT);
                    $NewProductId = "P".$NewProductVendorId.$NewProductNumber;
                    
                    
                    mysqli_stmt_bind_param($stmt_insert_new,"sssi",$NewProductId,$vendor,$product,$Price);
                    if(mysqli_stmt_execute($stmt_insert_new))
                    {
                        echo "ok";
                    }
                    else
                    {   
                        echo "Registration failed. Please try again.";
                    }
                }
                else
                {
                    echo "*Product already exists!";
                }
            }
            else
            { 
                echo "Sorry, something went wrong! Please try again.";
            }
            mysqli_stmt_close($stmt_check_product);
            mysqli_stmt_close($stmt_insert_new);
        }
        else
        {
            echo "*Vendor does not exist!";
        }
    }
    else
    {
        echo "*Admin password incorrect!";
    }
}
else
{
    echo "Couldn't get input. Please try again.";
}

?>