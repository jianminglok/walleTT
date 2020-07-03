<html>
    <head>
        <?php
            include('conn.php');
            include('meta.html');
        ?>
        <style>
            button{
                height:2rem;
            }

            .upper form{
                margin-bottom: 0;
            }

            .upper{
                margin-bottom: 1em;
            }
        </style>
        <script>
            <?php if($_SESSION['LEVEL']>1):?>
            var queries = {};
      
            function chng(id){
                var edited =  $('#' + id).children().val();
                $('#' + id).html(edited);
                var arr = id.split('_');
                arr[1] = '_' +arr[1];
                if(!(arr[0] in queries))
                {
                    queries[arr[0]] = {};
                }
                queries[arr[0]][arr[1]] = edited;
            }
            
            function turnToInput(id){
                var content = $('#' + id).html();
                var sigh = id.split('_');
                var l = $("#"+id).width();
                var add = "style='width:"+l+";'";
                if(sigh[1]=='class')
                {
                    add += ' maxlength=3';
                }
                if(!content.includes('input'))
                {
                    $('#' + id).html("<input value=\"" + content + "\" type='text' onblur='chng(\"" + id + "\")'"+add+"/>");
                    $('#' + id).children().focus();
                }
            }

            function _submit()
            {
                var admin = $("#_admin").val()
                if(admin!='')
                {
                    $.ajax({
                    type: 'POST',
                    url: 'ed.php',
                    data: {
                        TYP: 'agent',
                        AGENT: admin,
                        CHANGES: JSON.stringify(queries)
                    }, 
                    success: function(a){
                        if(a=="signOut"){
                            window.location.replace("index.php?logout=true&err=4");
                        }else if(a!='ok'){
                            alert(a);
                        }
                        else{
                            alert('Database successfully updated!');
                            $("#edit-container").html("<button id='edit_button' class=\"w-100 bbutton abril mx-auto\" type='button' style=\"display:block;justify-content: center;\" onclick='get_pw()'> Submit changes</button>")
                        }
                    },
                    error: function(a){
                        alert("Something's wrong! Please try again.")
                    }
                });
                }
                else
                {
                    alert("Please enter admin password!")
                }
                
            }

            function edit(type, reg)
            {
                $("#e_typ").val(type);
                $("#e_id").val(reg);
                $("#e_form").submit();
            }

            function _clear(id, money)
            {
                if(confirm('Clear amount owed by agent ' + id + '?'))
                {
                    $.ajax({
                        type: 'POST',
                        url: 'clear.php',
                        data: {
                            clear: id,
                            amount: money
                        }, 
                        success: function(a){
                            if(a=="signOut"){
                                //LogOut
                                window.location.replace("index.php?logout=true&err=4");
                                exit();
                            }
                            if(a!='ok')
                            {
                                alert(a);
                            }
                            else{
                                $("#" + id).html("RM0<button style='float:right;background-color:#303030;color:#FFFFFF;' disabled><i class='fa fa-file-invoice-dollar'></i></button>");
                            }
                        },
                        error: function(a){
                            alert("Something's wrong! Please try again.")
                        }
                    });
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
                    TYPE : 'agent',
                    PARA : $("#_search").val(),
                    SORT : $("#sort_sel").val(),
                    FILTER: $("#filter_sel").val()
                }, 
                success: function(result){
                    if(result=="signOut"){
                        //logOut
                        window.location.replace("index.php?logout=true");
                    }else{
                        $("#_table").html(result);
                    }
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
    <?php include('nav.php'); ?>
    <body>
        <div class="container">
        <?php if($_SESSION['LEVEL']>1): ?>
        <div class='upper row'>
            <form method='POST' action='register.php' id='_reg' class='col-sm-6'>
                <input class='d-none' name='TYPE' value='agent'>
                <button class="obutton abril mx-auto w-100" style="display: block; justify-content: center;" id='regb'><i class='fa fa-plus-square'></i> Register</button>
            </form>
            <div class='col-sm-6' id="edit-container">
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
                    <option value='class_ASC' >class (ASC)</option>
                    <option value='class_DESC' >class (DESC)</option>
                    <option value='level_DESC' >status</option>
                </select>   
                </div>
            </div>
            <div class='col-sm-4' style='display:flex;'>
                <span class='poppins select-span'>Filter: </span>
                <div class="select-container">
                <select id='filter_sel' onchange='send()'>
                    <option value='all' selected>See All</option>
                    <option value='owing'>Owing only</option>
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