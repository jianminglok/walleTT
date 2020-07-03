<!doctype html>
<html>
    <head>
        <title>QR Code</title>
        <?php 
            include("conn.php");
            include("meta.html");
            

            if($_SESSION['LEVEL']==0)
            {
                header("Location: buyer.php");
                exit();
            }

            $msg="no";

            if(isset($_POST["id"]) && $_POST["id"]!='')
            {
                $msg="go";
                $_id= $_POST["id"];
                $code=password_hash(substr($_id, 2, -1), PASSWORD_DEFAULT);
            }
        ?>
        <style>
            #qrcode{
                width:80%
            }
        </style>
        <script>
            var msg='<?php echo $msg;?>';

            const createQr = (div, code, id) => {
                
                $("#" + div).append(`<div id="${id}" style="margin-bottom: 2em;"></div>`)
                let qr = new QRCode(document.getElementById(id), 'U' + id + ';' + code)
                $("#" + id).append(`<p class="qr-text">${id}</p><button class='bbutton w-100 abril'><a id="download_${id}" download="${id}.png" href="" style="text-decoration:none;color:white;width: 100%;"><i class="fa fa-cloud-download-alt"></i> Download</a></button>`)
            }

            const puthref = id => {
                document.getElementById("download_" + id).href = document.getElementById(id).firstChild.toDataURL()
                document.getElementById("download_" + id).parentElement.addEventListener("click", () => {
                    document.getElementById("download_" + id).click()
                })
            }

            $(document).ready(function(){
                if(msg=='go')
                {
                    var id = '<?php echo $_id;?>';
                    var code = '<?php echo $code?>'
                    createQr("qrcode", code, id)
                    puthref(id)
                }
                else
                {
                    $("#qrcode").html("<p>NOT VALID</p>");
                }          
            });
            
        </script>
    </head>
    <?php include("nav.php"); ?>
    <body>
        <div class="container">
            <div id="qrcode" class="mx-auto" style="display: flex; justify-content: center; text-align: center;"></div>
            <div class="w-50 mx-auto">
            <form action='buyer.php'>
                <button class="obutton abril" style="width:100%; justify-self: center;"><span class="fa fa-undo"></span> Back</a>
            </form>
            </div>
        </div>
    </body>
</html>
