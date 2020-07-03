<?php
//_________________________timeout if its ajax file
include("conn.php");
if(isset($_SESSION['logout'])&&$_SESSION['logout']==TRUE){
    echo "signOut";
    exit();
}
//_____________________________________________________
function deleteFolder($dir){
    array_map( 'unlink', array_filter((array) glob("$dir/*") ) );
    rmdir($dir);
}

if($_SESSION['LEVEL'] === 0)
{
    echo 'Unauthorised';
}
else if(isset($_POST['START'], $_POST['NUM']))
{
    $list = array();
    $start = $_POST['START'];
    $num = $_POST['NUM'];
    for($x = 0; $x < $num; $x++)
    {
        $base = $start + $x;
        if($base > 9999999)
        {
            break;
        }
        $_id =  str_pad($base, 7, "0", STR_PAD_LEFT);
        $crypt = str_split($_id);
        $cryptsum = 0;
        for($y = 0; $y < sizeof($crypt); $y++) {
            $cryptsum += (int)$_id[$y];
        }
        $code = password_hash(substr($_id, 2, -1), PASSWORD_DEFAULT);
        array_push($list, [$_id, $cryptsum % 10, $code]);
    }
    echo json_encode($list);
}
else if($_POST['DOWNLOAD'])
{
    $dirname = './tmp/qrcodes/';
    if(!mkdir($dirname))
    {
        echo $data;
        die(0);
    }

    $data = json_decode($_POST['DOWNLOAD'], TRUE);
    foreach($data as $id => $content)
    {
        list($type, $data) = explode(';', $content);
        if($type != 'data:image/png')
        {
            continue;
        }
        list(, $data) = explode(',', $data);
        $data = base64_decode($data);
        file_put_contents($dirname.$id.'.png', $data);
    }


    $zipcreated = "qrcodes.zip";

    if(file_exists($zipcreated))
    {
        unlink($zipcreated);
    }

    $newzip = new ZipArchive;
    if($newzip -> open($zipcreated, ZipArchive::CREATE ) === TRUE) {
         $dir = opendir($dirname);
         while($file = readdir($dir)) {
            if(is_file($dirname.$file)) {
               $newzip -> addFile($dirname.$file, $file);
            }
         }
         $newzip ->close();
    }
    else
    {
        echo 2;
    }
    

    if(file_exists($zipcreated))
    {
        echo ($zipcreated);
    }
    else
    {
         echo 1;
    }
        
    deleteFolder($dirname);

}
?>
