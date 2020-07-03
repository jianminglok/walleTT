<html>
    <head>
        <?php
            include('conn.php');
            include('meta.html');
            
            $res = mysqli_query($conn, "SELECT * FROM transactions;");
            $tally=array();
            while($row=mysqli_fetch_assoc($res))
            {
                $row['_products'] = json_decode($row['_products']);
                $row['_amounts'] = json_decode($row['_amounts']);
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
                    TYPE : 'transactions',
                    PARA : $("#_search").val(),
                    SORT: $("#sort_sel").val(),
                    REM: $("#rem_sel").val()
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
                <div class='col-sm-4'>
                    <div class="input-group w-100">
                        <input type="text" id="_search"  placeholder="Search" class='sinput form-control poppins' name='search' style='border-radius:0px;' oninput='send()'>
                        <div class="input-group-prepend">
                            <label for='search' class="obutton" style='height:2rem;width:2rem;justify-content:center; display:flex;align-items:center;'><i class="fa fa-search"></i></label>
                        </div>
                    </div>
                </div>
                <div class='col-sm-4' style='display:flex;'>
                    <span class='poppins select-span'>Sort by: </span>
                    <div class="select-container">
                    <select id='sort_sel' onchange='send()'>
                        <option value='id_ASC' selected>ID (ASC)</option>
                        <option value='id_DESC' >ID (DESC)</option>
                        <option value='store_ASC' >store (ASC)</option>
                        <option value='store_DESC' >store (DESC)</option>
                        <option value='total_ASC' >store (ASC)</option>
                        <option value='total_DESC' >store (DESC)</option>
                        <option value='timestamp_DESC' >newest first</option>
                    </select>   
                    </div>
                </div>
                <div class='col-sm-4' style='display:flex;'>
                    <span class='poppins select-span'>Filter by status: </span>
                    <div class="select-container">
                    <select id='rem_sel' onchange='send()'>
                        <option value='all' selected>See all</option>
                        <option value='Approved'>Approved</option>
                        <option value='Reversed'>Reversed</option>
                    </select>   
                    </div>
                </div>
            </div>
        </br>
        <div id="_table">
            
        </div>
        </div>
    </body>
</html>