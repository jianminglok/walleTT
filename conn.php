<?php
    if(session_status() == PHP_SESSION_NONE)
    {
        session_start();
    }
    $servername='localhost';
    $username='root';
    $password='makerlab8899';
    $dbname='WalleTT';
    $conn = mysqli_connect($servername,$username,$password,$dbname);
    //timeout scripts____________________________________________________________
    $temp=basename($_SERVER['PHP_SELF']);
    if($temp!="index.php" && $temp!="verify.php" && $temp!="reg.php" && $temp!="process.php"){
        if(isset($_SESSION["NAME"])){
            if((time() - $_SESSION['last_time']) >(20*60)){ // Time in Seconds.(t*60s) t for how many minutes
                if(!empty($_POST) && $temp!="edit.php"&&$temp!="generate.php" && $temp!="register.php"){//add on pages that require a post data
                    $_SESSION['logout']=TRUE;
                }else{
                    session_unset();
                    header("location:index.php?logout=true&err=4");
                    exit();
                }
            }
            else{
                $_SESSION['last_time'] = time();
            }
        }else{ 
            header("location:index.php");
        }
    }
    if (mysqli_connect_errno())
    {
        echo "Failed to connect to MySQL: " . mysqli_connect_error();
    }
    
?>
