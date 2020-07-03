<!doctype html>
<html>
    <head>
        <title>QR Code</title>
        <?php 
            include("meta.html");
            include("conn.php");

            if($_SESSION['LEVEL']==0)
            {
                header("Location: buyer.php");
                exit();
            }
        ?>
        <script>

            var list = []
            var data = {};

            const puthref = id => {
                document.getElementById("download_" + id).href = document.getElementById(id).firstChild.toDataURL()
                data[id] = document.getElementById(id).firstChild.toDataURL()
                document.getElementById("download_" + id).parentElement.addEventListener("click", () => {
                    document.getElementById("download_" + id).click()
                })
            }

            const createQr = (div, code, crypt, id) => {
                
                $("#" + div).append(`<div id="${id}" style="margin: 10px;"></div>`)
                let qr = new QRCode(document.getElementById(id), 'U' + id + crypt + code)
                $("#" + id).append(`<p style="text-align:center">${id}</p><button class='bbutton w-100 abril'><a id="download_${id}" download="${id}.png" href="" style="text-decoration:none;color:white;"><i class="fa fa-cloud-download-alt"></i> Download</a></button>`)
            }

            // const delay = ms => new Promise(resolve => setTimeout(resolve, ms));

            // const downloadAll = async arr => {               
            //     if(arr !== [])
            //     {
            //         for (let x = 0; x < arr.length; x++) {                        
            //             await delay(x * 100);
            //             document.getElementById("download_" + arr[x][0]).click();
            //         }
            //     }
            // }

            const downloadZip = data => {
                if(data !== {})
                {
                    $.ajax({
                        type: 'POST',
                        url: 'genprocess.php',
                        data: {
                            DOWNLOAD: JSON.stringify(data)
                        }, 
                        success: (r) => {
                            if(r=="signOut"){
                                window.location.replace("index.php?logout=true&err=4");
                                //session time Out
                            }
                            else if(isNaN(r))
                            {
                                document.getElementById("zip").href = r
                                document.getElementById("zip").click()
                            }
                            else 
                            {
                                alert(r);
                            }
                            //alert(r);
                        }
                    });
                }
            }

            const send = () => {
                if( !isNaN($("#_start").val()) && $("#_start").val() > 0 && $("#_start").val() < 10000000 )
                {
                    document.getElementById("qrcodes").innerHTML = "<img src='./spinner.gif' alt='Loading...' >"
                    $.ajax({
                        type: 'POST',
                        url: 'genprocess.php',
                        data: {
                            START : $("#_start").val(),
                            NUM: $("#num_sel").val()
                        }, 
                        success: function(res){
                            if(res=="signOut"){
                                window.location.replace("index.php?logout=true&err=4");
                                //session time Out
                            }
                            else if(res == 'Unauthorised')
                            {
                                document.getElementById("qrcodes").innerHTML = 'User not authorised';
                            }
                            else
                            {
                                document.getElementById("qrcodes").innerHTML = ""
                                data = {}
                                list = JSON.parse(res)
                                list.map( i => {
                                    createQr("qrcodes", i[2], i[1], i[0])
                                    puthref(i[0])
                                })
                            }
                        }
                    });
                }
                else
                {
                    alert('Please enter a valid numeric ID to start with.')
                }
            }

            $(document).ready(function(){
                document.getElementById("download_btn").addEventListener("click", () => {
                    downloadZip(data)
                })
            })
        </script>
    </head>
    <?php include("nav.php"); ?>
    <body>
        <div class="container">
            <div class='row'>
                <div class='col-md-4'>
                    <div class="input-group w-100">
                        <div class="input-group-prepend">
                            <label for='start' class="obutton abril" style='height: 2rem; justify-content:center; display:flex;align-items:center;padding-right:2rem;padding-left:2rem;margin-bottom: 1em; cursor:pointer;' onclick="send()">Start from</label>
                        </div>
                        <input type="number" id="_start"  placeholder="Enter ID" class='sinput form-control poppins' name='start' style='border-radius:0px;' max="9999999" min="1">
                    </div>
                </div>
                <div class='col-md-4' style='display:flex;'>
                    <span class='poppins select-span'>Amount: </span>
                    <div class="select-container">
                    <select id='num_sel' onchange='send()' style="margin-bottom: 1em;">
                        <option value="1">1</option>
                        <option value="2">2</option>
                        <option value="3">3</option>
                        <option value="4">4</option>
                        <option value="5">5</option>
                        <option value="10">10</option>
                        <option value="20">20</option>
                        <option value="30">30</option>
                        <option value="50">50</option>
                        <option value="100">100</option>
                    </select>   
                    </div>
                </div>
                <div class='col-md-4' style='display:flex;'>
                    <button id='download_btn' class="w-100 bbutton abril mx-auto" type='button' style="display:block;justify-content: center; margin-bottom: 1em;"><i class="fa fa-cloud-download-alt"></i> Download All</button>
                </div>
            </div>
            <div id="qrcodes">
                <p class="poppins">Please enter a starting ID and the amount to generate.</p>
            </div>
            <a id="zip" style="display:none;" href=""></a>
        </div>
    </body>
</html>
