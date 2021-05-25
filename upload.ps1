param (
  # Local path is folder on machine files are stored
  $LocalPath = "<add path here>" ,
  # sftp folder location ex. /folder_name/files/
  $RemotePath = "<add path here>",
  # Final desination for files after upload
  $BackupPath = "<add path here>",
  # Below is all sftp information
	$HostName = "<add credentials here>",
	$UserName = "<add credentials here>",
	$Password = "<add credentials here>",
	$SSHKey = "<add credentials here>"
)

try
  {
  # Load WinSCP .NET assembly
  # Check file path to make sure file is present
  Add-Type -Path "C:\Program Files (x86)\WinSCP\WinSCPnet.dll"

  # Set up session options
  $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
      Protocol = [WinSCP.Protocol]::Sftp
      HostName = $HostName
      UserName = $UserName
      Password = $Password
      SshHostKeyFingerprint = $SSHKey

  }
 
$session = New-Object WinSCP.Session
 
try
{
    $session.Open($sessionOptions)
 
        $transferResult = $session.PutFiles($LocalPath, $RemotePath)
 
        foreach ($transfer in $transferResult.Transfers)
        {
            if ($transfer.Error -eq $Null)
            {
				# If upload confirmation is needed for each file, uncomment the below line
                # Write-Output "Upload of $($transfer.FileName) succeeded, moving to backup"
				
                # After upload move filed to backup folder
                Move-Item $transfer.FileName $BackupPath
            }
            else
            {
                Write-Host "Upload of $($transfer.FileName) failed: $($transfer.Error.Message)"
            }
        }
    }
    finally
    {
        # Disconnect, clean up
        $session.Dispose()
    }
 
    exit 0
}
catch
{
    Write-Host "Error: $($_.Exception.Message)"
    exit 1
}
