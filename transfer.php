<html>
    <head>
        <?php
            include('conn.php');
            include('meta.html');
        ?>
        <script>
            function transfer(frozen)
            {

                $("#fr_input").val(frozen);
                $("#trans").submit();
            }
            function send()
            {
                $.ajax({
                    type: 'POST',
                    url: 'table.php',
                    data: {
                        TYPE : 'transfer',
                        PARA : $("#_search").val(),
                        SORT: $("#sort_sel").val(),
                        FILTER: $("#filter_sel").val()
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
            <form id='trans' class='d-none' method='POST' action='edit.php'>
                <input name='TYPE' value='transfer'>
                <input name='FROZE' id="fr_input" value=''>
            </form>
            <div class="row">
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
                    <option value='balance_ASC' >balance (ASC)</option>
                    <option value='balance_DESC' >balance (DESC)</option>
                    <option value='name_ASC' >name (ASC)</option>
                    <option value='name_DESC' >name (DESC)</option>
                </select>   
                </div>
            </div>
            <div class='col-sm-4' style='display:flex;'>
            <span class='poppins select-span'>Filter by balance: </span>
                <div class="select-container">
                <select id='filter_sel' onchange='send()'>
                    <option value='all' selected>See all</option>
                    <option value='0'>>RM0</option>
                    <option value='20'>>RM20</option>
                    <option value='50'>>RM50</option>
                    <option value='100'>>RM100</option>
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