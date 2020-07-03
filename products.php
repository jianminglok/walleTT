<html>
    <head>
        <?php 
            include('meta.html');
            include('conn.php');
            include('nav.php');

            $res = mysqli_query($conn, "SELECT * FROM `products`");
            $tally=array();
            while($row=mysqli_fetch_assoc($res))
            {
                array_push($tally, $row);
            }
            $status=["top-up agent", "admin"];
        ?>
        <style>
            button {
                height: 2rem
            }
            #row1 {
                margin-bottom: 1em
            }
        </style>
        <script>
            <?php if(isset($_SESSION['LEVEL']) && $_SESSION['LEVEL']>=1): ?>
            var queries= {};
            function chng(id){
                var edited=$('#'+id).children().val();
                var arr= id.split("_");
                if(arr[1]=='price')
                {
                    if(edited == '')
                    {
                        alert('Please enter numbers only!')
                    }
                    else
                    {
                        $('#'+id).html("RM" + edited);
                    }
                }
                else
                {
                    $('#'+id).html(edited);
                }
                arr[1]='_'+arr[1];
                if(!(arr[0] in queries)){
                    queries[arr[0]]={};
                }
                queries[arr[0]][arr[1]]=edited;
            }

            function turnToInput(id){
                var content = $('#'+id).html();
                var sigh=id.split("_");
                var l =$('#'+id).width();
                var add = "style='width:"+l+";'";
                var type = ""
                if(content.search("<input") < 0)
                {
                    if(sigh[1] == 'price')
                    {
                        type = " type='number'"
                        content = content.replace("RM", "")
                    }
                    $('#'+id).html("<input value='"+ content + "'" + type + " onblur='chng(\""+id+"\")'"+add+"/>");
                    $('#'+id).children().focus();
                }
            }
            //this is for deleting
            function _drop(_id){
                var admin=confirm('You are about to delete product ' + _id + '. This process is irreversible. Proceed?')
                if(admin!=''){
                    $.ajax({
                        type:'POST',
                        url:'update_Products.php',
                        data:{
                            TYP: 'drop',
                            CHANGES: _id
                        },
                        success: function(a){
                            if(a=="signOut"){
                                window.location.replace("index.php?logout=true&err=4");
                                //SessionTimeOut 
                            }
                            else if(a!=':)'){
                                alert(a);
                            }else{
                                alert('Database successfully updated!');
                                window.location.replace("products.php");
                            }
                        },
                        error: function(a){
                            alert("Somethin's wrong! Please try again")
                        }
                    })
                }
            }
            function get_pw(func)
            {
                var stuff = `
                <div class="input-group w-100">
                <div class="input-group-prepend">
                    <label for='PW' class="bbutton abril" onclick="_submit()" style='height:2rem;justify-content:center; display:flex;align-items:center;cursor:pointer;padding-right:2rem;padding-left:2rem;'>GO</label>
                </div>
                <input type="password" id="_agent"  placeholder="Enter admin password" class='sinput form-control poppins' name='PW' style='border-radius:0px;'>
                </div>
                `
                $("#edit-container").html(stuff)
                $("#_agent").focus()
            }
            //this is for updating database
            function _submit(){
                var admin=$("#_agent").val()
                if(admin!=''){
                    $.ajax({
                        type:'POST',
                        url:'update_Products.php',
                        data:{
                            TYP: 'updateProduct',
                            PWD: admin,
                            CHANGES: JSON.stringify(queries)
                        },
                        success: function(a){
                            if(a=="signOut"){
                                window.location.replace("index.php?logout=true&err=4");
                                //session Time Out
                            }
                            else if(a!=':)'){
                                alert(a);
                            }else{
                                alert('Database successfully updated!');
                            $("#edit-container").html("<button id='edit_button' class=\"w-100 bbutton abril mx-auto\" type='button' style=\"display:block;justify-content: center;\" onclick='get_pw()'> Submit changes</button>")
                            }
                        },
                        error: function(a){
                            alert("Somethin's wrong! Please try again")
                        }
                    })
                }
            }
            <?php endif; ?>
            function send()
        {
            $.ajax({
                type: 'POST',
                url: 'table.php',
                data: {
                    TYPE : 'product',
                    PARA : $("#_search").val(),
                    SORT : $("#sort_sel").val(),
                    FILTER: $("#filter_sel").val()
                }, 
                success: function(result){
                    $("#_table").html(result);
                }
            });
        }
        $(document).ready(function(){
            $( "#regb" ).click(function() {
                $("#_reg").submit();
            });
            send();
        });
        </script>
        
    </head>
    <body >  
        <div class="container">
        <div class='row' id='row1'>
            <div class='col-sm-6'>
                <button class='obutton abril w-100' onclick= "window.location.href ='newProduct.php';">Register Product</button>
            </div>
            <div class='col-sm-6' id="edit-container">
                <button id='edit_button' class="w-100 bbutton abril mx-auto" style="display:block;justify-content: center;" onclick='get_pw()'> Submit changes</button>
            </div>
        </div>
        <div class="row">
            <div class='col-sm-4'>
                <div class="input-group w-100">
                    <input type="text" id="_search"  placeholder="Search" class='sinput form-control poppins' name='search' style='border-radius:0px;' oninput="send()">
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
                    <option value='price_ASC' >price (ASC)</option>
                    <option value='price_DESC' >price (DESC)</option>
                    <option value='sales_ASC' >sales (ASC)</option>
                    <option value='sales_DESC' >sales (DESC)</option>
                </select>   
                </div>
            </div>
            <div class='col-sm-4' style='display:flex;'>
                <span class='poppins select-span'>Filter by price: </span>
                <div class="select-container">
                <select id='filter_sel' onchange='send()'>
                    <option value='all' selected>See All</option>
                    <option value='1' >RM1-10</option>
                    <option value='11'>RM11-20</option>
                    <option value='21'>RM21-30</option>
                </select>   
                </div>
            </div>
        </div>
        <br>
        <div id="_table">
            

        </div>
        </div>
    </body>
</html>