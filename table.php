<?php
        //_________________________timeout if its ajax file
    include("conn.php");
    if(isset($_SESSION['logout'])&&$_SESSION['logout']==TRUE){
        echo "<script>window.location.replace('index.php?logout=true&err=4');</script>";
        exit();
    }
    //_____________________________________________________
    function createTable($tally, $headers, $hide)
    {
        $size = array_shift($hide);
        echo <<<EOD
        <table class="table table-bordered" style="overflow-x:scroll;">
                <thead class="thead-light poppins">
EOD;
        foreach($headers as $head)
        {
            $c = in_array($head, $hide) ? "class='$size-hide'" : "" ;
            echo "<th $c>$head</th>";
        }
        echo "</thead><tbody>";

        foreach($tally as $row)
        {
            echo "<tr>";
            foreach($headers as $head)
            {
                $c = in_array($head, $hide) ? "class='$size-hide'" : "" ;
                echo "<td $c>".$row[$head]."</td>";
            }
            echo "</tr>";
        }

        echo "</tbody></table>";
    }

    if(isset($_POST['TYPE']))
    {
        $type = $_POST['TYPE'];
        if($type=='agent')
        {
            $sort = explode('_', $_POST['SORT']);
            $filter = ($_POST['FILTER'] == 'owing' ? 'AND _owing != 0': '');
            $para = "'%".$_POST['PARA']."%'";
            $res = mysqli_query($conn, "SELECT * FROM agents WHERE (_id LIKE $para OR _name LIKE $para OR _class LIKE $para) $filter ORDER BY _$sort[0] $sort[1];");
            $tally=array();
            $status=["top-up agent", "customer service", "admin"];
            while($row=mysqli_fetch_assoc($res))
            {
                array_push($tally, $row);
            }
            
            echo <<<EOD
            <table class="table table-bordered">
                <thead class="thead-light poppins">
                    <tr>
                        <th>ID</th>
                        <th class='xs-hide'>Name *</th>
                        <th class='xs-hide'>Class *</th>
                        <th>Owing</th>
                        <th>Status</th>
EOD;
                        if($_SESSION['LEVEL']>1):
                        echo '<th></th>';
                        endif;
            echo <<<EOD
                    </tr>
                </thead>
                <tbody>
EOD;
                        $clear = "";
                        $edit = "";
                        foreach($tally as $arr)
                        {
                            $chng_name='';
                            $chng_class='';
                            $_id=$arr['_id'];
                            if($_SESSION['LEVEL']>1)
                            {
                                $_owe=$arr['_owing'];
                                $add="background-color:#303030;color:#FFFFFF;";
                                $click='disabled';
                                if($arr['_owing']!=0)
                                {
                                    $add = "' class='obutton";
                                    $click = "onclick='_clear(\"$_id\", $_owe)' title='clear owing'";
                                }
                                $clear = "<button style='float:right;$add' $click><i class='fa fa-file-invoice-dollar'></i></button";
                                $edit = "<td><button class='obutton table-button' onclick='edit(\"agent\", \"$_id\")'>Edit Password</button></td>";
                                $chng_name = "onclick = 'turnToInput(\"$_id"."_name\")' title='click to edit'";
                                $chng_class = "onclick = 'turnToInput(\"$_id"."_class\")' title='click to edit'";
                            }
                            echo "<tr class='poppins'><td>".$arr['_id']."</td><td id='$_id"."_name' $chng_name class='xs-hide'>".$arr['_name']."</td><td id='$_id"."_class' $chng_class class='xs-hide'>".$arr['_class']."</td><td id='$_id'>RM".$arr['_owing']."$clear</td><td>".$status[$arr['_level']]."</td>$edit</tr>";
                            
                        }
                
                echo '</tbody></table>';
            if($_SESSION['LEVEL']>1):
                echo <<<EOD
            <form class='d-none' method='POST' action='edit.php' id='e_form'>
                <input name='TYPE' value='' id='e_typ'>
                <input name='REG' value='' id='e_id'>
            </form>
EOD;
             endif;
        }
        else if($type=='buyer')
        {
            $sort = explode('_', $_POST['SORT']);
            $filter = ($_POST['FILTER'] == 'all' ? '' : 'AND _balance > '.$_POST['FILTER']);
            $para = "'%".$_POST['PARA']."%'";
            $res = mysqli_query($conn, "SELECT * FROM users WHERE _remark='active' AND (_name LIKE $para OR _id LIKE $para OR _telephone LIKE $para) $filter ORDER BY _$sort[0] $sort[1];");
            $tally=array();
            while($row=mysqli_fetch_assoc($res))
            {
                $row['_id']=substr($row['_id'], 1);
                array_push($tally, $row);
            }
            echo <<<EOD
            <table class="table table-bordered">
            <thead class="thead-light poppins">
                <tr>
                    <th>ID</th>
                    <th class='xs-hide'>Name *</th>
                    <th class='xs-hide'>Telephone no. *</th>
                    <th>Balance</th>
EOD;
                    echo $_SESSION['LEVEL'] == 0  ? "" : "<th>QR code</th>";
            echo <<<EOD
                    <th></th>
                </tr>
            </thead>
            <tbody>
EOD;
            $edit = "";
            foreach($tally as $arr)
            {
                $_id=$arr['_id'];
                $chng_name="onclick='turnToInput(\"$_id"."_name\")' title='click to edit'";
                $chng_telephone="onclick='turnToInput(\"$_id"."_telephone\")' title='click to edit'";
                $fr = "<td><button class='obutton table-button' onclick='freeze(\"$_id\")'>Freeze user</button></td>";
                $qr = $_SESSION['LEVEL'] == 0 ? "" : "<td align='center'><button class='obutton' onclick='getQr(\"$_id\")'><i class='fa fa-qrcode'></i></button></td>";
                echo "<tr class='poppins'><td>".$arr['_id']."</td><td id='$_id"."_name' $chng_name class='xs-hide'>".$arr['_name']."</td><td id='$_id"."_telephone' $chng_telephone class='xs-hide'>".$arr['_telephone']."</td><td>RM".$arr['_balance']."</td>$qr$fr</tr>";
                
            }
            echo '</tbody></table>';

        }
        else if($type=='transfer')
        {
            $para = "'%".$_POST['PARA']."%'";
            $sort = explode('_', $_POST['SORT']);
            $filter = ($_POST['FILTER'] == 'all' ? '' : 'AND a._balance > '.$_POST['FILTER']);
            $res = mysqli_query($conn, "SELECT a._id AS _id, a._name AS _name, a._telephone AS _telephone, a._balance AS _balance, b._transfer AS _transfer FROM users a, freeze b WHERE a._remark = 'frozen' AND a._id = b._user AND (a._name LIKE $para OR a._telephone LIKE $para) $filter ORDER BY a._$sort[0] $sort[1];");
            $tally=array();
            while($row=mysqli_fetch_assoc($res))
            {
                $row['_id'] = substr($row['_id'], 1);
                array_push($tally, $row);
            }

            echo <<<EOD
            <table class="table table-bordered">
            <thead class="thead-light poppins">
                <tr>
                    <th class='xs-hide'>ID</th>
                    <th>Name</th>
                    <th class='xs-hide'>Telephone no.</th>
                    <th>Balance</th>
EOD;
                    echo ($_SESSION['LEVEL'] >= 1 ? '<th></th>' : ''); 
            
            echo <<<EOD
                </tr>
            </thead>
            <tbody>
EOD;

            foreach($tally as $arr)
            {
                $_id=$arr['_id'];
                $fr='';
                if($_SESSION['LEVEL']>=1)
                {
                    $fr = "<td><button ".($arr['_transfer'] != 'NONE' ? "style='background-color:#444444;color:#FFFFFF'" : "class='obutton table-button' onclick='transfer(\"$_id\")'").">Transfer balance</button></td>";
                }
                echo "<tr class='poppins'><td class='xs-hide'>".$arr['_id']."</td><td>".$arr['_name']."</td><td class='xs-hide'>".$arr['_telephone']."</td><td>RM".$arr['_balance']."</td>$fr</tr>";
            }
            

            echo '</tbody></table>';

        }
        else if($type == 'tprec')
        {
            $para = "'%".$_POST['PARA']."%'";
            $sort = explode('_', $_POST['SORT']);
            $rem = $_POST['REM'];
            $status = ($_POST['STAT'] == 'all' ? '' : 'AND a._cleared = '.$_POST['STAT']);
            $remark = ($_POST['REM'] == 'all' ? '' : "AND a._remark = '$rem'");

            $q = "SELECT a._id, a._agent, b._name, a._buyer, a._amount, a._timestamp, a._remark, a._cleared FROM topup a, agents b WHERE b._id = a._agent AND (b._name LIKE $para OR a._agent LIKE $para OR a._buyer LIKE $para OR a._timestamp LIKE $para) $status $remark ORDER BY a._$sort[0] $sort[1];";
            $res = mysqli_query($conn, $q);
            $tally=array();
            $headers = ['ID', 'Agent ID', 'Agent Name', 'User ID', 'Amount', 'Datetime', 'Remark', 'Cleared'];
            $hide = ['sm', 'Agent Name', 'User ID', 'Datetime', 'Remark'];
            $text= ['owing', 'cleared'];

            while($row=mysqli_fetch_assoc($res))
            {
                $row['_buyer'] = substr($row['_buyer'], 1);
                $row['_amount'] = 'RM'.$row['_amount'];
                $row['_cleared'] = $text[$row['_cleared']];
                $list = array_combine($headers, $row);
                array_push($tally, $list);
            }

            createTable($tally, $headers, $hide);
        }
        else if($type=='transactions')
        {
            $para = "'%".$_POST['PARA']."%'";
            $sort = explode('_', $_POST['SORT']);
            $remark = $_POST['REM'];
            $rem = ($_POST['REM'] == 'all' ? '' : "AND a._remark = '$remark'");
            $q = "SELECT a._id, a._store, a._buyer, a._products, a._amounts, a._total, a._timestamp, a._remark, b._vendor FROM transactions a, stores b WHERE b._id = a._store AND (b._vendor LIKE $para OR a._store LIKE $para OR a._buyer LIKE $para OR a._timestamp LIKE $para) $rem ORDER BY a._$sort[0] $sort[1];";
            $res = mysqli_query($conn, $q);
            $tally=array();

            while($row=mysqli_fetch_assoc($res))
            {
                $row['_buyer'] = substr($row['_buyer'], 1);
                $row['_products'] = json_decode($row['_products']);
                $row['_amounts'] = json_decode($row['_amounts']);
                array_push($tally, $row);
            }

            echo <<<EOD
            <table class="table table-bordered">
                <thead class="thead-light poppins">
                    <tr>
                        <th>ID</th>
                        <th>Store ID</th>
                        <th class='sm-hide'>Store Name</th>
                        <th>User ID</th>
                        <th class='sm-hide'>Product</th>
                        <th class='sm-hide'>Amount</th>
                        <th>Total</th>
                        <th class='sm-hide'>Datetime</th>
                        <th>Remark</th>
                    </tr>
                </thead>
                <tbody>
EOD;
                    
                        foreach($tally as $arr)
                        {
                            $height=sizeof($arr['_products']);
                            for($i=0;$i<$height;$i++)
                            {
                                if($i==0)
                                {
                                    echo "<tr><td rowspan=$height>".$arr['_id']."</td><td rowspan=$height>".$arr['_store']."</td><td rowspan=$height class='sm-hide'>".$arr['_vendor']."</td><td rowspan=$height>".$arr['_buyer']."</td><td class='sm-hide'>".$arr['_products'][$i]."</td><td class='sm-hide'>".$arr['_amounts'][$i]."</td><td rowspan=$height>RM".$arr['_total']."</td><td rowspan=$height class='sm-hide'>".$arr['_timestamp']."</td><td rowspan=$height>".$arr['_remark']."</td></tr>";
                                }
                                else
                                {
                                    echo "<tr><td class='sm-hide'>".$arr['_products'][$i]."</td><td class='sm-hide'>".$arr['_amounts'][$i]."</td></tr>";
                                }
                            }
                            
                        }
                
                echo '</tbody></table>';
        }
        else if($type == 'frrec')
        {
            $para = "'%".$_POST['PARA']."%'";
            $sort = explode('_', $_POST['SORT']);
            $remark = $_POST['REM'];
            $rem = ($_POST['REM'] == 'all' ? '' : "AND a._transfer $remark 'NONE'");
            $q = "SELECT a._id, a._agent, a._user, b._name, a._timestamp, a._transfer, a._tadmin FROM freeze a, users b WHERE a._user = b._id AND (a._agent LIKE $para OR a._timestamp LIKE $para OR a._user LIKE $para OR b._name LIKE $para) $rem ORDER BY a._$sort[0] $sort[1];";
            $res = mysqli_query($conn, $q);

            $headers = ['ID', 'Agent ID', 'User ID', 'User Name', 'Datetime', 'Transferred to', 'Admin concerned'];
            $hide = ['sm', 'User Name', 'Datetime', 'Admin concerned'];
            $tally=array();
            while($row=mysqli_fetch_assoc($res))
            {
                $row['_transfer'] = ($row['_transfer'] == 'NONE' ? 'NONE' : substr($row['_transfer'], 1));
                $row['_user'] = substr($row['_user'], 1);
                $list = array_combine($headers, $row);
                array_push($tally, $list);
            }

            createTable($tally, $headers, $hide);
        }
        else if($type == 'crec')
        {
            $para = "'%".$_POST['PARA']."%'";
            $sort = explode('_', $_POST['SORT']);
            $q = "SELECT a._id, a._agent, b._name, a._admin, a._amount, a._timestamp FROM clears a, agents b WHERE a._agent = b._id AND (a._agent LIKE $para OR a._timestamp LIKE $para OR a._admin LIKE $para OR b._name LIKE $para) ORDER BY a._$sort[0] $sort[1];";
            $res = mysqli_query($conn, $q);

            $headers = ['ID', 'Agent ID', 'Agent Name', 'Admin ID', 'Amount', 'Datetime'];
            $hide =['xs', 'Agent Name', 'Admin ID'];
            $tally=array();
            while($row=mysqli_fetch_assoc($res))
            {
                $row['_amount'] = 'RM'.$row['_amount'];
                $list = array_combine($headers, $row);
                array_push($tally, $list);
            }

            createTable($tally, $headers, $hide);
        }
        else if($type == 'store')
        {
            $filter = $_POST['FILTER'] == 'all' ? "" : "AND _claimed = ".$_POST['FILTER'];
            $para = "'%".$_POST['PARA']."%'";
            $sort = explode('_', $_POST['SORT']);
            $res = mysqli_query($conn, "SELECT * FROM stores WHERE (_telephone LIKE $para OR _vendor LIKE $para OR _id LIKE $para) $filter ORDER BY _$sort[0] $sort[1];");
            $tally=array();
            while($row=mysqli_fetch_assoc($res))
            {
                array_push($tally, $row);
            }

            echo <<<EOD
            <table class="table table-bordered">
                <thead class="thead-light poppins">
                    <th>ID</th>
                    <th>Vendor *</th>
                    <th class='xs-hide'>Telephone no. *</th>
                    <th>Sales</th>
EOD;
                    if($_SESSION['LEVEL']==2)
                    {
                        echo "<th>Claimed</th>";
                    }
                    if($_SESSION['LEVEL']>=1)
                    {
                        echo "<th></th>";
                    }
                    echo "</tr>
                </thead>
                <tbody>";
                foreach($tally as $arr){
                    $_id=$arr['_id'];
                    echo "<tr class='poppins'>
                        <td>".$arr['_id']."</td>
                        <td id='$_id"."_vendor' onclick='turnToInput(\"$_id"."_vendor\")' title='click to edit'>".$arr['_vendor']."</td>
                        <td id='$_id"."_telephone' onclick='turnToInput(\"$_id"."_telephone\")' title='click to edit' class='xs-hide'>".$arr['_telephone']."</td>
                        <td >RM".$arr['_balance']."</td>";
                    if($_SESSION['LEVEL']==2)
                    {
                        $extra = $arr['_claimed'] ? 'checked disabled' : '';
                        echo "<td align='center'><input type='checkbox' value='$_id' name='claim' $extra onchange='claim(\"$_id\", this.checked)'/></td>";
                    }
                    if($_SESSION['LEVEL']>0)
                    {
                        echo "<td><button onclick= \"window.location.href ='changePassword.php?r=$_id'\" class='obutton table-button'>Edit Password</button></td>";
                    }
                    echo "</tr>";
                }
                echo "</tbody>
            </table>";
            
        }
        else if($type == 'product')
        {
            $para = "'%".$_POST['PARA']."%'";
            $sort = explode('_', $_POST['SORT']);
            $filter = $_POST['FILTER'];
            $f = ($filter == 'all' ? "" : "AND (_price BETWEEN $filter AND ($filter + 9))");

            $res = mysqli_query($conn, "SELECT a._id, a._name, a._store, b._vendor, a._price, a._sales FROM products a, stores b WHERE a._store = b._id AND  (a._id LIKE $para OR a._store LIKE $para OR a._name LIKE $para OR b._vendor LIKE $para) $f ORDER BY _$sort[0] $sort[1];");
            $tally = array();

            while($row=mysqli_fetch_assoc($res))
            {
                array_push($tally, $row);
            }

            echo <<<EOD
            <table class="table table-bordered">
                <thead class="thead-light poppins">
                        <th>ID</th>
                        <th>Vendor</th>
                        <th class='sm-hide'>Vendor Name</th>
                        <th>Product Name *</th>
                        <th>Price *</th>
                        <th class='sm-hide'>Sales</th>
EOD;
                        if($_SESSION['LEVEL']>=1)
                        {
                            echo "<th class='sm-hide'></th>";
                        }
                        echo
                    '
                </thead>
                <tbody>';
                        foreach($tally as $arr){
                            $_id=$arr['_id'];
                            echo "<tr class='poppins'>
                                <td>".$arr['_id']."</td>
                                <td>".$arr['_store']."</td>
                                <td class='sm-hide'>".$arr['_vendor']."</td>
                                <td id='$_id"."_name' onclick='turnToInput(\"$_id"."_name\")' title='click to edit'>".$arr['_name']."</td>
                                <td id='$_id"."_price' onclick='turnToInput(\"$_id"."_price\")' title='click to edit'>RM".$arr['_price']."</td>
                                <td class='sm-hide'>".$arr['_sales']."</td>";
                                if($_SESSION['LEVEL']>=1)
                                {
                                    echo "<td class='sm-hide'><button class='obutton' onclick='_drop(\"$_id\")'>Delete</button></td>";
                                }
                                echo "</tr>";
                        }
                        echo
                '</tbody>
            </table>';
            
        }
    }
?>