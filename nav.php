<nav class="navbar navbar-dark fixed-top navbar-expand-lg" id='navbar'>
    <div class="container">
<a class="navbar-brand abril" href="#">WalleTT</a>
<button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#lowernav">
    <span class="navbar-toggler-icon"></span>
</button>
  <div class="collapse navbar-collapse" id="lowernav">
    <ul class="navbar-nav nav mr-auto" >
      <li class="nav-item dropdown disabled"><a class="nav-link dropdown-toggle abril" href="#" data-toggle="dropdown"  id="stores" data-toggled=0>Stores</a>
        <div class="dropdown-menu">
            <a class="dropdown-item" href="stores.php">Manage stores</a><!--Register and store infos-->
            <a class="dropdown-item" href="products.php">Manage products</a><!--See products record-->
        </div>
      </li>
     <li class="nav-item dropdown disabled"><a class="nav-link dropdown-toggle abril" href="#" data-toggle="dropdown"  id="users" data-toggled=0>People</a>
        <div class="dropdown-menu">
            <a class="dropdown-item" href="agent.php">Manage agents</a><!--Register agent info and clearing-->
            <a class="dropdown-item" href="buyer.php">Manage users</a><!--Register buyer info and top up-->
            <a class="dropdown-item" href="transfer.php">Transfer amount</a><!--View frozen users and transfer balance-->
        </div>
      </li>
      <li class="nav-item dropdown disabled"><a class="nav-link dropdown-toggle abril" href="#" data-toggle="dropdown" id="transcript">Transactions</a>
        <div class="dropdown-menu">
          <a class="dropdown-item" href="tprecord.php">Top up</a><!--See top up records-->
          <a class="dropdown-item" href="transactions.php">Sales</a><!--See sales records-->
          <a class="dropdown-item" href="crecord.php">Clearance</a><!--See clearing records-->
          <a class="dropdown-item" href="frrecord.php">Freezing</a><!--See freezing and transfering records-->
        </div>
      </li>
      <?php //if($_SESSION['LEVEL']!=0): ?>
      <li class="nav-item"><a class="nav-link abril" href="generates.php" id="profile">QR-codes</a></li>
      <?php //endif; ?>
    </ul>
    <a class="poppins" style="color:white; display:block;margin-right:2rem;" title="Profile"><?php echo $_SESSION['NAME']; ?> </a>
    <a href="index.php?logout=true" data-toggle="tooltip" title="Log out"><i class="fa fa-sign-out-alt " style="color:white;"></i></a>
</div>
  </div>
  </nav>
  <?php
  if(!isset($_SESSION['LOGIN']) || !isset($_SESSION['ID']) || $_SESSION['ID'] == '')
  {
    header("location: index.php");
    exit();
  }
  ?>
  
