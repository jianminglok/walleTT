<html>
    <head>
        <?php
            include('conn.php');
            include('meta.html');
        ?>
        <script>
        function send()
        {
            $.ajax({
                type: 'POST',
                url: 'table.php',
                data: {
                    TYPE : 'tprec',
                    PARA : $("#_search").val(),
                    SORT: $("#sort_sel").val(),
                    STAT: $("#stat_sel").val(),
                    REM : $("#rem_sel").val()
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
                <div class='col-sm-3'>
                    <div class="input-group w-100">
                        <input type="text" id="_search"  placeholder="Search" class='sinput form-control poppins' name='search' style='border-radius:0px;' oninput='send()'>
                        <div class="input-group-prepend">
                            <label for='search' class="obutton" style='height:2rem;width:2rem;justify-content:center; display:flex;align-items:center;'><i class="fa fa-search"></i></label>
                        </div>
                    </div>
                </div>
                <div class='col-sm-3' style='display:flex;'>
                    <span class='poppins select-span'>Sort by: </span>
                    <div class="select-container">
                    <select id='sort_sel' onchange='send()'>
                        <option value='id_ASC' selected>ID (ASC)</option>
                        <option value='id_DESC' >ID (DESC)</option>
                        <option value='agent_ASC' >agent (ASC)</option>
                        <option value='agent_DESC' >agent (DESC)</option>
                        <option value='timestamp_DESC' >newest first</option>
                    </select>   
                    </div>
                </div>
                <div class='col-sm-3' style='display:flex;'>
                    <span class='poppins select-span'>Filter by status: </span>
                    <div class="select-container">
                    <select id='stat_sel' onchange='send()'>
                        <option value='all' selected>See all</option>
                        <option value='0'>owing</option>
                        <option value='1'>cleared</option>
                    </select>   
                    </div>
                </div>
                <div class='col-sm-3' style='display:flex;'>
                    <span class='poppins select-span'>Filter by remark: </span>
                    <div class="select-container">
                    <select id='rem_sel' onchange='send()'>
                        <option value='all' selected>See all</option>
                        <option value='registration'>registration</option>
                        <option value='topup'>top up</option>
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