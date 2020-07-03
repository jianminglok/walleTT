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

            .upper{
                margin-bottom: 1em;
            }

            .upper form{
                margin-bottom: 0;
            }
        </style>
        <script>

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
          if(sigh[1]=='telephone')
          {
              add += ' maxlength=11';
          }
          if(!content.includes('input'))
          {
              $('#' + id).html("<input value=\"" + content + "\" type='text' onblur='chng(\"" + id + "\")' "+add+"/>");
              $('#' + id).children().focus();
          }
      }

      function _submit()
      {
          var agent = $("#_agent").val()
          if(agent!='')
          {
              $.ajax({
              type: 'POST',
              url: 'ed.php',
              data: {
                  TYP: 'buyer',
                  AGENT: agent,
                  CHANGES: JSON.stringify(queries)
              }, 
              success: function(a){
                if(a=="signOut"){
                    window.location.replace("index.php?logout=true&err=4");
                    //session time out
                }
                else if(a!='ok'){
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
              alert('Please enter agent password!')
          }
          
      }

      function getQr(reg)
      {
            $("#qr_reg").val(reg);
            $("#qr_f").submit();
      }

      function send()
      {
        $.ajax({
            type: 'POST',
            url: 'table.php',
            data: {
                TYPE : 'buyer',
                PARA : $("#_search").val(),
                SORT: $("#sort_sel").val(),
                FILTER: $("#filter_sel").val()
            }, 
            success: function(result){
                $("#_table").html(result);
            }
        });
      }

      function freeze(buyer)
      {
        if(confirm('You are going to freeze user ' + buyer + '. This process is irreversible. Proceed?'))
        {
            $.ajax({
                type: 'POST',
                url: 'process.php',
                data: {
                    type : 'freeze',
                    name : $("#" + buyer + "_name").html(),
                    telephone : $("#" + buyer + "_telephone").html(), 
                    agent: '<?php echo $_SESSION['ID']; ?>',
                    Typ:"mysql"//timeout
                }, 
                success: function(result){
                    if(result=="signOut"){
                        //session time out
                        window.location.replace("index.php?logout=true&err=4");
                    }else{
                        var a =JSON.parse(result);
                        alert(a['status']);
                        $("#" + buyer + "_name").parent().addClass('d-none')   
                    }
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
            <input type="password" id="_agent"  placeholder="Enter agent password" class='sinput form-control poppins' name='PW' style='border-radius:0px;'>
            </div>
            `
            $("#edit-container").html(stuff)
            $("#_admin").focus()
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
            <div class='upper row'>
                <form method='POST' action='register.php' id='_reg' class='col-sm-6'>
                    <input class='d-none' name='TYPE' value='buyer'>
                    <button class="obutton abril mx-auto w-100" style="display: block; justify-content: center;" id='regb'><i class='fa fa-plus-square'></i> Register</button>
                </form>
                <div class='col-sm-6' id="edit-container">
                    <button id='edit_button' class="w-100 bbutton abril mx-auto" type='button' style="display:block;justify-content: center;" onclick='get_pw()'> Submit changes</button>
                </div>
            </div>
            <div class='row'>
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
            <br>
        <div id="_table">
            
        </div>
        <form class='d-none' method='POST' action='generate.php' id='qr_f'><input name='id' id='qr_reg' value=''></form>
        </div>
    </body>
</html>