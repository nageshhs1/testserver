<!DOCTYPE html>
<html >
  <head>
    <link rel="stylesheet" type="text/css" href="css\style.css">
    <script src="js/prefixfree.min.js"></script>
  </head>

  <body>
     <?php include "menu.html"; ?>
     <script src="js/index.js"> </script>
     <p align="center">
     <strong><font size="5">
       Centralized Automation Test with Distributed Test Setup<p align="center">
        &nbsp&nbsp&nbsp (BSP/MPE Automation Test)
     </font></strong><p>
    <font size="4"><strong><p> Checkout "bsp_test.sh" script:- svn co svn://10.226.45.6/ppa/bsp_automation/CLI/bsp_test.sh</strong></font><p>
     <p> CLI Command: bsp_test.sh [-u/-U user] [-e/-E email] [-w wan_mode] [–t test_type] [-m meta_info] [-f TG_BSP_ALL] [-p/P buildbot image path/url]
     </p><p>&nbsp Parameter: 
     </p><p>&nbsp&nbsp&nbsp    -w [wan]: eth/atm/ptm/all
     </p><p>&nbsp&nbsp&nbsp    -t [test type]: smoke/full/mpe/
     </p><p>&nbsp&nbsp&nbsp    -m [meta info]: UGW <Changeset Branch> or customized information
     </p><p>&nbsp&nbsp&nbsp    –u/U [user]: user name  and save/not save to configuration file
     </p><p>&nbsp&nbsp&nbsp    –e/E [email]: user email address ex: bsp_test.sh -E  [Email_id1],[Email_id2],[Email_id3]
     </p><p>&nbsp&nbsp&nbsp    -p [buildbot image path/url]: image http url, ex: bsp_test.sh -p http://ServerIP/buildbot/default/6.1_w7/GRX330_GW_HE_VDSL_LTE/
     </p><p>&nbsp&nbsp&nbsp    -f [testgroup filename]: user selected testgroup_list.txt 
     </p><p><p></p>&nbspUsage:
      </p><p>&nbsp&nbsp&nbspNormal User: bsp_test.sh (first time prompt to key in username and email)
     </p><p>&nbsp&nbsp&nbspBuildbot: bsp_test.sh -U buildbot –E email_address
     </p>

      <font size="4">
	 &nbsp&nbsp&nbsp 1) Support BSP level automation test<p>
	 &nbsp&nbsp&nbsp 2) Support MPE FW level automation test<p>
      </font>
	<p><p>
    <img src="about.png" alt="Intel" align="middle">




    
    
  </body>
</html>
 
