<?php
    include("conn.php");
    date_default_timezone_set('Asia/Kuching');
    if(isset($_POST['Typ'],$_SESSION['logout']) && $_POST['Typ']=="mysql" && $_SESSION['logout']==TRUE){
        echo "signOut";
    }else if(isset($_POST['type'])){
        $type=$_POST['type'];
        //below are code for getting name and balance
        if($type=='checkbalance')
        {
            $arr=array();
            $stmt = mysqli_stmt_init($conn);
    
            if(mysqli_stmt_prepare($stmt, "SELECT _name, _balance, _remark  FROM users WHERE _id = ? ;"))
            {
                $stuff = explode(';', $_POST['id']);
                $user = substr($_POST['id'], 0, 8);
                $code = substr($_POST['id'], 9, 69);

                if(!password_verify(substr($user, 3, -1), $code))
                {
                    $arr['status'] = 'User does not exist';
                }
                else
                {
                    mysqli_stmt_bind_param($stmt, 's', $user);
                    mysqli_stmt_execute($stmt);
                    mysqli_stmt_store_result($stmt);
                    
                    if (mysqli_stmt_num_rows($stmt)> 0)
                    {
                        mysqli_stmt_bind_result($stmt, $name, $balance, $remark);
                        mysqli_stmt_fetch($stmt);
                        $arr['name']=$name;
                        $arr['balance']=$balance;
                        $arr['remark']=$remark;
                    }
                    else
                    {
                        $arr['status'] = 'User does not exist!';
                    }
                }
            }
            else
            {
                $arr['status'] = 'Failed to fetch data';
            }
            mysqli_stmt_close($stmt);
            echo json_encode($arr);
        }
        //below are code for payment
        else if($type=='payment')
        {
            $arr=array();
            $stuff = explode(';', $_POST['userId']);
            $user = substr($_POST['userId'], 0, 8);
            $code = substr($_POST['userId'], 9, 69);
            $store=$_POST['storeId'];
            $time=$_POST['time'];
            $total=intval($_POST['amount']);
            $products=$_POST['products'];
            $amounts=$_POST['numbers'];

            if(!password_verify(substr($user, 3, -1), $code))
            {
                $arr['status'] = 'User does not exist';
            }
            else
            {
                mysqli_begin_transaction($conn);
                try
                {
                    mysqli_query($conn, "UPDATE users SET _balance = _balance - $total WHERE _id = '$user';");
                    mysqli_query($conn, "UPDATE stores SET _balance = _balance + $total WHERE _id = '$store';");
                    if(json_decode($products) != ['-'])
                    {
                        foreach(json_decode($products) as $key=>$val)
                        {
                            $num = json_decode($amounts)[$key];
                            mysqli_query($conn, "UPDATE products SET _sales = _sales + $num WHERE _id = '$val';");
                        }
                    }
                    mysqli_query($conn, "INSERT INTO transactions(_buyer, _store, _products, _amounts, _total, _timestamp) VALUES('$user', '$store', '$products', '$amounts', $total, '$time');");

                    mysqli_commit($conn);

                    $arr['status']='successful';
                }
                catch(Exception $e)
                {
                    mysqli_rollback($conn);
                    $arr['status']='Transaction failed';
                }
            }
            echo json_encode($arr);
        }
        //below are code for top up
        else if($type=='topup')
        {
            $arr=array();
            $stuff = explode(';', $_POST['userId']);
            $user = substr($_POST['userId'], 0, 8);
            $code = substr($_POST['userId'], 9, 69);
            $amount = $_POST['amount'];
            $time = $_POST['time'];
            $agent = $_POST['agentId'];

            if(!password_verify(substr($user, 3, -1), $code))
            {
                $arr['status'] = 'User does not exist';
            }
            else
            {
                mysqli_autocommit($conn, FALSE);
                $query_success = TRUE;

                $stmt1 = mysqli_stmt_init($conn);
                mysqli_stmt_prepare($stmt1, "UPDATE users SET _balance = _balance + ? WHERE _id = ? ;");
                mysqli_stmt_bind_param($stmt1, 'is', $amount, $user);
                if(!mysqli_stmt_execute($stmt1))
                {
                    $query_success = FALSE;
                }
                mysqli_stmt_close($stmt1);

                $stmt2 = mysqli_stmt_init($conn);
                mysqli_stmt_prepare($stmt2, "UPDATE agents SET _owing = _owing + ? WHERE _id = ? ;");
                mysqli_stmt_bind_param($stmt2, 'is', $amount, $agent);
                if(!mysqli_stmt_execute($stmt2))
                {
                    $query_success = FALSE;
                }
                mysqli_stmt_close($stmt2);

                $stmt3 = mysqli_stmt_init($conn);
                mysqli_stmt_prepare($stmt3, "INSERT INTO topup(_buyer, _agent, _amount, _timestamp, _remark) VALUES(?, ?, ?, ?, 'topup');");
                mysqli_stmt_bind_param($stmt3, 'ssis', $user, $agent, $amount, $time);
                if(!mysqli_stmt_execute($stmt3))
                {
                    $query_success = FALSE;
                }
                mysqli_stmt_close($stmt3);

                if($query_success)
                {
                    mysqli_commit($conn);
                    $arr['status'] ='successful';
                }
                else
                {
                    mysqli_rollback($conn);
                    $arr['status'] = 'Top up failed';

                }
            }
            echo json_encode($arr);
        }
        //below are for retrieving transaction history
        else if($type == 'transactionhistory')
        {
            $vendor=$_POST['id'];
            $result=array();
            if ($res = mysqli_query($conn, "SELECT a._name, b._buyer, b._timestamp, b._total, b._id, b._remark, b._products, b._amounts FROM users a, transactions b WHERE b._store = '$vendor' AND a._id = b._buyer ORDER BY b._timestamp DESC;"))
            {
                while($row = mysqli_fetch_assoc($res))
                {
                    $arr=['id' => $row['_id'], 'status' => $row['_remark'], 'amount' => $row['_total'], 'time' => $row['_timestamp'], 'user' => ['id' => substr($row['_buyer'],1), 'name' => $row['_name']], 'products' => json_decode($row['_products']), 'amounts' => json_decode($row['_amounts'])];
                    array_push($result, $arr);
                }
            }
            else
            {
                $result['status']='Server error.';
            }
            echo json_encode($result);
        }
        //below are for retrieving top up history
        else if($type == 'topuphistory')
        {
            $agent=$_POST['id'];
            $result=array();
            $clear = ['owing', 'cleared'];
            if($res = mysqli_query($conn, "SELECT a._name, b._buyer, b._timestamp, b._amount, b._id, b._remark, b._reversed, b._cleared FROM users a, topup b WHERE b._agent = '$agent' AND a._id = b._buyer ORDER BY b._timestamp DESC;"))
            {
                while($row = mysqli_fetch_assoc($res))
                {
                    $arr=['id' => $row['_id'], 'amount' => $row['_amount'], 'time' => $row['_timestamp'], 'remark' => $row['_remark'], 'reversed' => $row['_reversed'], 'cleared' => $clear[$row['_cleared']], 'user' => ['id' => substr($row['_buyer'], 1), 'name' => $row['_name']]];
                    array_push($result, $arr);
                }
            }
            else
            {
                $result['status']='Server error';
            }
            echo json_encode($result);
        }
        //below are for retireving products data
        else if($type == 'products')
        {
            $vendor = $_POST['id'];
            $result=array();
            if($res = mysqli_query($conn, "SELECT _id, _name, _price, _sales FROM products WHERE _store = '$vendor';"))
            {
                while($row = mysqli_fetch_assoc($res))
                {
                    $arr=['id' => $row['_id'], 'name' => $row['_name'], 'price' => $row['_price'], 'sold' => $row['_sales']];
                    array_push($result, $arr);
                }
            }
            else
            {
                $result['status']='Server error';
            }
            echo json_encode($result);
        }
        //below are for freezing user account
        else if($type=='freeze')
        {
            $arr=array();
            $name = $_POST['name'];
            $phone = $_POST['telephone'];
            $agent = $_POST['agent'];

            $stmt = mysqli_stmt_init($conn);
    
            if(mysqli_stmt_prepare($stmt, "SELECT _id, _balance  FROM users WHERE _name = ? AND _telephone = ?;"))
            {
                
                mysqli_stmt_bind_param($stmt, 'ss', $name, $phone);
                mysqli_stmt_execute($stmt);
                mysqli_stmt_store_result($stmt);
                
                if (mysqli_stmt_num_rows($stmt)> 0)
                {
                    mysqli_stmt_bind_result($stmt, $id, $balance);
                    mysqli_stmt_fetch($stmt);
                    
                    if(mysqli_query($conn, "UPDATE users SET _remark = 'frozen' WHERE _id='$id';"))
                    {
                        mysqli_query($conn, "INSERT INTO freeze(_agent, _user) VALUES('$agent', '$id');");
                        $arr['name']=$name;
                        $arr['balance']=$balance;
                        $arr['status']='Successful!';
                    }
                    else
                    {
                        $arr['status'] = 'Server error, please try again.';
                    }
                }
                else
                {
                    $arr['status'] = $name.' '.$phone;
                }
            }
            else
            {
                $arr['status'] = 'Failed to fetch data';
            }
            mysqli_stmt_close($stmt);
            echo json_encode($arr);
        }
        //below are for vendor login
        else if($type=='login')
        {
            if(isset($_POST['STORE'], $_POST['PASS']))
            {
                $user = $_POST['STORE'];
                $pw = $_POST['PASS'];
                if($user!='' && $pw!='')
                {
                    $stmt = mysqli_stmt_init($conn);
            
                    if(mysqli_stmt_prepare($stmt, "SELECT _vendor,_password, _balance  FROM stores WHERE _id = ?"))
                    {
                        mysqli_stmt_bind_param($stmt, 's', $user);
                        mysqli_stmt_execute($stmt);
                        mysqli_stmt_store_result($stmt);
                        
                        if (mysqli_stmt_num_rows($stmt)> 0)
                        {
                            mysqli_stmt_bind_result($stmt, $name, $pass, $balance);
                            mysqli_stmt_fetch($stmt);
  
                            if (password_verify($pw, $pass))
                            {
                                
                                $arr['name'] = $name;
                                $arr['balance'] = $balance;
                                $arr['status'] = 'store';
                                echo json_encode($arr);
                           
                            }
                            else
                            {
                                $arr['status'] = 'ID or password incorrect';
                                echo json_encode($arr);
                            }
                        }
                        else
                        {
                            $arr['status'] = 'User does not exist';
                            echo json_encode($arr);
                        }
                        
                        mysqli_stmt_close($stmt);
                        
                    }
                    else
                    {
                        $arr['status'] = 'Server error';
                        echo json_encode($arr);
                    }
                }
                else
                {
                    $arr['status'] = 'Empty fields';
                    echo json_encode($arr);
                }
            }
            else
            {
                echo "Empty fields";
            }
        }
        //below is for transacton reversal
        else if($type=='reverse')
        {
            $result = array();
            $trans_id = $_POST['id'];
            $trans_time = $_POST['time'];
            $trans_user = 'U'.$_POST['userId'];
            $arr = mysqli_fetch_array(mysqli_query($conn, "SELECT _store, _total, _products, _amounts FROM transactions WHERE _id = $trans_id AND  _timestamp='$trans_time' AND _buyer='$trans_user' AND _remark = 'Approved';"));

            if(sizeof($arr)>0)
            {
                $arr[2] = json_decode($arr[2]);
                $arr[3] = json_decode($arr[3]);
                mysqli_begin_transaction($conn);
                try
                {
                    mysqli_query($conn, "UPDATE transactions SET _remark = 'Reversed' WHERE _id = $trans_id;");
                    mysqli_query($conn, "UPDATE users SET _balance = _balance + $arr[1] WHERE _id = '$trans_user';");
                    mysqli_query($conn, "UPDATE stores SET _balance = _balance - $arr[1] WHERE _id = '$arr[0]';");
                    foreach($arr[2] as $i => $val)
                    {
                        $a = $arr[3][$i];
                        mysqli_query($conn, "UPDATE products SET _sales = _sales - $a WHERE _id = '$val';");
                    }
                    mysqli_commit($conn);

                    $result['status'] ='Successful';
                }
                catch(Exception $e)
                {
                    mysqli_rollback($conn);
                    $result['status'] = 'Failed';
                }
            }
            else
            {
                $result['status'] = 'Cannot find transaction';
            }
            echo json_encode($result);
        }
        //below for topUp/Registration reversal
        else if($type=="topUp/RegistrationReversal"){
            $result=array();
            $id=$_POST['id'];
            $time=$_POST['time'];
            $agentId=$_POST['agentId'];

            $res=mysqli_fetch_array(mysqli_query($conn, "SELECT TIMESTAMPDIFF(MINUTE, _timestamp, NOW())AS n ,_amount,_buyer FROM `topup` WHERE _id='$id' AND _timestamp='$time' AND _agent='$agentId'"));
            if(isset($res)){
                $amount=$res['_amount'];
                $buyer=$res['_buyer'];
                if($res['n'] <= 20 && $res['n'] >= 0){//time limite until
                    try{
                        mysqli_query($conn,"UPDATE `users` SET `_balance`= _balance-$amount WHERE _id='$buyer'");
                        mysqli_query($conn,"UPDATE `agents` SET `_owing`=_owing-$amount WHERE _id='$agentId'");
                        mysqli_query($conn,"UPDATE `topup` SET `_reversed`='Voided',`_cleared`='1' WHERE _id='$id'");
                        $result['status'] = 'Success';
                    }catch(Exception $e)
                    {
                        mysqli_rollback($conn);
                        $result['status'] = 'Failed';
                    }
                }else{
                    $result['status'] = 'Transactions cannot be reversed after 20 minutes';
                }
            }else{
                $result['status'] = 'Failed';;
            }
            echo json_encode($result);
        }
   }
?>
