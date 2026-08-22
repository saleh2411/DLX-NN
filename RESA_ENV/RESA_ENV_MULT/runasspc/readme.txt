:: ###################### RunasSpc #########################
:: 
:: Examples:
::
:: 1) call runasspc without cryptfile:
:: runasspc /program:"prog.exe" /domain:"localhost" /user:"admin" /password:"pass"
:: 
:: 2) open a runasspc cryptfile and run the application without dialog of runasSpc:
:: runasspc /cryptfile:"path\crypt.spc" /quiet
::
:: 3) generate a cryptfile:
:: runasspc /cryptfile:"crypt.spc" /program:"prog.exe" /domain:"localhost" /user:"admin" /password:"pass"
::
::
:: *********************************************************
:: 
:: Parameters:
::
:: runasspc.exe	/program:"path\application" 
::		/domain:"localhost" or "yourDomainName.com"
::          	/user:"username" 
::	    	/password:"password" 
::		/cryptfile:"name of cryptfile"
::          	/param:"options for calling application" 
::		/executein:"start\in\folder"
::          	/logon:noprofile or netonly or env
::          	/wstyle:maximize or minimize or hide
::          	/crcoff
::		/quiet
::		/alldrives
:: 
:: *********************************************************
::
:: Description:
::
:: /program    = path and program (if your application expected parameters see /param)
:: /domain     = "localhost" for local user or your Domain for domain users 
:: /user       = name of account your program should be start
:: /password   = leave it empty if you want to ask for password on runtime
:: /cryptfile  = if you want to work with an encrypt file (see Examples below) 
:: /param      = if your program expected parameters enter here 
:: /executein  = working directory for application
:: /logon      = logonoptions (default = withprofile)
:: /wstyle     = Windowstyle of starting program. Not supported in all applications.
:: /crcoff     = without application checksum (checksum supported only with cryptfile)
:: /quiet      = hide runasspc startup dialog
:: /alldrives  = search application on current directory and all driveletter with same path. 
::               helpful for different drive letters on different computers (usb,cd...) 
::
:: *********************************************************
::
:: Additional examples:
::
:: 1) Call Runasspc without Cryptfile:
::
:: runasspc /program:"%systemroot%\system32\mmc.exe"  /param:"%systemroot%\system32\compmgmt.msc" /user:"administrator"
:: runasspc /program:"C:\Programme\Windows NT\Pinball\pinball.exe" /domain:"localhost" /user:"administrator" /password:"password" /wstyle:minimize
:: runasspc /program:"c:\winnt\system32\mmc.exe" /domain:"domainname.com" /user:"administrator" /password:"password" /executein:"c:\winnt" /param:"c:\konsole\adminkonsole.msc"
:: runasspc /program:"C:\windows\system32\msiexec.exe" /param:"/i c:\install\setup.msi" /domain:"localhost" /user:"administrator" /password:"password"
:: runasspc /program:"\\servername\share\foldername\j2re-1_4_2_05-windows-i586-p.exe" /domain:"domainname.com" /user:"administrator" /password:"password" /param:"/S /V/qn" /executein:"c:\temp" /logon:"noprofile"
:: runasspc /program:"%systemroot%\system32\xcopy.exe" /param:"d:\temp\file1 d:\images" /domain:"localhost" /user:"administrator" /password:"password"
::
::
:: 2) Call Runasspc with Cryptfile:
::
:: runasspc /cryptfile:"path\NameOfCryptfile.spc"
:: runasspc /cryptfile:"path\NameOfCryptfile.spc" /quiet
::
::
:: 3) Generate Cryptfile: 
::
:: runasspc /cryptfile:"crypt.spc" /program:"C:\WINDOWS\system32\calc.exe" /domain:"localhost" /user:"administrator" /password:"password"
:: runasspc /cryptfile:"\\servername\share\crypt.spc" /program:"c:\winnt\system32\mmc.exe" /domain:"domainname.com" /user:"administrator" /password:"password" /executein:"c:\windows" /param:"c:\konsole\adminkonsole.msc"
:: runasspc /cryptfile:"\\servername\share\crypt.spc" /program:"\\servername\share\foldername\j2re-1_4_2_05-windows-i586-p.exe" /domain:"domainname.com" /user:"administrator" /password:"password" /param:"/S /V/qn" /executein:"c:\temp" /logon:"noprofile"
:: runasspc /cryptfile:"d:\temp\crypt.spc" /program:"d:\temp\WindowsXP-KB894391-x86-DEU.exe" /domain:"domainname.com" /user:"administrator" /password:"password" /param:"/passive" /logon:"noprofile" /alldrives
:: *********************************************************
