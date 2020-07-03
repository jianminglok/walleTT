<html>
    <head>
        <?php
            include('conn.php');
            include('meta.html');
            
            $res = mysqli_query($conn, "SELECT * FROM clears;");
            $tally=array();
            while($row=mysqli_fetch_assoc($res))
            {
                array_push($tally, $row);
            }
        ?>
        <script>
            function send()
            {
                $.ajax({
                    type: 'POST',
                    url: 'table.php',
                    data: {
                        TYPE : 'crec',
                        PARA : $("#_search").val(),
                        SORT: $("#sort_sel").val()
                    }, 
                    success: function(result){
                        $("#_table").html(result);
                    }
                });
            }
            $(document).ready(function(){
                send();
            });
        </script>
    </head>
    <?php include('nav.php'); ?>
    <body>
        <div class="container">
        <div class='row'>
                <div class='col-sm-6'>
                    <div class="input-group w-100">
                        <input type="text" id="_search"  placeholder="Search" class='sinput form-control poppins' name='search' style='border-radius:0px;' oninput='send()'>
                        <div class="input-group-prepend">
                            <label for='search' class="obutton" style='height:2rem;width:2rem;justify-content:center; display:flex;align-items:center;'><i class="fa fa-search"></i></label>
                        </div>
                    </div>
                </div>
                <div class='col-sm-6' style='display:flex;'>
                    <span class='poppins select-span'>Sort by: </span>
                    <div class="select-container">
                    <select id='sort_sel' onchange='send()'>
                        <option value='id_ASC' selected>ID (ASC)</option>
                        <option value='id_DESC' >ID (DESC)</option>
                        <option value='agent_ASC' >Agent (ASC)</option>
                        <option value='agent_DESC' >Agent (DESC)</option>
                        <option value='admin_ASC' >Admin (ASC)</option>
                        <option value='admin_DESC' >Admin (DESC)</option>
                        <option value='timestamp_DESC' >newest first</option>
                    </select>   
                    </div>
                </div>
            </div>
        </br>
        <div id="_table">
            <table class="table table-bordered">
                <thead class="thead-light poppins">
                    <tr>
                        <th>ID</th>                        
                        <th>Agent ID</th>
                        <th>Admin ID</th>
                        <th>Amount</th>
                        <th>Datetime</th>
                    </tr>
                </thead>
                <tbody>
                    <?php
                        foreach($tally as $arr)
                        {
                            echo "<tr><td>".$arr['_id']."</td><td>".$arr['_agent']."</td><td>".$arr['_admin']."</td><td>RM".$arr['_amount']."</td><td>".$arr['_timestamp']."</td></tr>";
                        }
                    ?>
                </tbody>
            </table>
        </div>
        </div>
    </body>
</html>