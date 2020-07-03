<!DOCTYPE html>
<html>
    <head>
        <?php 
            include('meta.html');
            include('conn.php');
            include('nav.php');
        ?>
             <style>
            button{
                height:2rem;
            }

            #row1 {
                margin-bottom: 1em;
            }
        </style>
            <script>
                <?php if(isset($_SESSION['LEVEL']) && $_SESSION['LEVEL']>0): ?>
                var queries= {};
                function claim(id, val)
                {
                    if(!(id in queries)){
                        queries[id]={};
                    }
                    if(val)
                    {
                        queries[id]['_claimed'] = 1
                    }
                    else
                    {
                        delete queries[id]['_claimed']
                    }
                }

                function chng(id){
                    var edited=$('#'+id).children().val();
                    $('#'+id).html(edited);
                    var arr= id.split("_");
                    arr[1]='_'+arr[1];
                    if(!(arr[0] in queries)){
                        queries[arr[0]]={};
                    }
                    queries[arr[0]][arr[1]]=edited;
                }

                function turnToInput(id){
                    var content = $('#' + id).html();
                    var sigh = id.split("_");
                    var l = $('#'+id).width();
                    var add = "style='width:"+l+"px;'";
                    if(sigh[1]=="telephone")
                    {
                        add += ' maxlength=11';
                    }
                    if(!content.includes('input'))
                    {
                        $('#' + id).html("<input value=\"" + content + "\" type='text' onblur='chng(\"" + id + "\")' "+add+"/>");
                        $('#' + id).children().focus();

                    }
                }

                function _submit(){
                    var admin=$("#_admin").val()
                    if(admin!=''){
                        $.ajax({
                            type:'POST',
                            url:'update_Store.php',
                            data:{
                                TYP: 'agent',
                                PWD: admin,
                                CHANGES: JSON.stringify(queries)
                            },
                            success: function(a){
                                if(a=="signOut"){
                                    window.location.replace("index.php?logout=true&err=4");
                                    //session Time OUt
                                }
                                else if(a!='ok'){
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
                function get_pw()
                {
                    var stuff = `
                    <div class="input-group w-100">
                    <div class="input-group-prepend">
                        <label for='PW' class="bbutton abril" onclick="_submit()" style='height:2rem;justify-content:center; display:flex;align-items:center;cursor:pointer;padding-right:2rem;padding-left:2rem;'>GO</label>
                    </div>
                    <input type="password" id="_admin"  placeholder="Enter admin password" class='sinput form-control poppins' name='PW' style='border-radius:0px;'>
                    </div>
                    `
                    $("#edit-container").html(stuff)
                    $("#_admin").focus()
                }
                <?php endif; ?>
                function send()
                {
                    $.ajax({
                        type: 'POST',
                        url: 'table.php',
                        data: {
                            TYPE : 'store',
                            PARA : $("#_search").val(),
                            SORT : $("#sort_sel").val(),
                            FILTER : $("#filter_sel").val()
                        }, 
                        success: function(result){
                            $("#_table").html(result);
                        }
                    });
                }
                $(document).ready(function(){
                    $("#regb").click(function() {
                        $("#_reg").submit();
                    });
                    send();
                });
            </script>
    </head>
    <body >  
        <div class="container">
            <?php if($_SESSION['LEVEL']>0): ?>
            <div class="row" id='row1'>
                <div class="col-sm-6">
                    <button class='obutton abril w-100' onclick= "window.location.href ='RegisterStore.php';"><i class='fa fa-plus-square'></i> Register</button>
                </div>
                <div class="col-sm-6" id="edit-container">
                <button id='edit_button' class="w-100 bbutton abril mx-auto" style="display:block;justify-content: center;" onclick='get_pw()'> Submit changes</button>
                </div>
            </div>
            <?php endif; ?>
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
                    <option value='vendor_ASC' >Vendor Name (ASC)</option>
                    <option value='vendor_DESC' >Vendor Name (DESC)</option>
                    <option value='balance_ASC' >balance (ASC)</option>
                    <option value='balance_DESC' >balance (DESC)</option>
                </select>   
                </div>
            </div>
            <div class='col-sm-4' style='display:flex;'>
                <span class='poppins select-span'>Filter: </span>
                <div class="select-container">
                <select id='filter_sel' onchange='send()'>
                    <option value='all' selected>See all</option>
                    <option value='1' >Claimed</option>
                    <option value='0' >Not Claimed</option>
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