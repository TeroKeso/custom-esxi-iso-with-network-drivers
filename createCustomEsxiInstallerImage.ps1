##############################################################################################
#     ____________  __ _    _                               __          _ __    __         
#    / ____/ ___/ |/ /(_)  (_)___ ___  ____ _____ ____     / /_  __  __(_) /___/ /__  _____
#   / __/  \__ \|   // /  / / __ `__ \/ __ `/ __ `/ _ \   / __ \/ / / / / / __  / _ \/ ___/
#  / /___ ___/ /   |/ /  / / / / / / / /_/ / /_/ /  __/  / /_/ / /_/ / / / /_/ /  __/ /    
# /_____//____/_/|_/_/  /_/_/ /_/ /_/\__,_/\__, /\___/  /_.___/\__,_/_/_/\__,_/\___/_/     
#                                         /____/                                           
##############################################################################################
# Author: Jonas Werner
# Modified by Tero
# GitHub URL: https://github.com/jonas-werner/custom-esxi-iso-with-network-drivers
# Video: https://youtu.be/DbqZI1V6TK4
# Version: 0.7.2
##############################################################################
# Prerequisites
# Only needs to be executed once, not every time an image is built
# Must be Administrator to execute prerequisites
#

## Choco way for automation for alternative way
#choco install VMware.PowerCLI


Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Install-Module -Name VMware.PowerCLI -SkipPublisherCheck
Import-Module -Name VMware.PowerCLI
##############################################################################



##############################################################################
# Get the base ESXi image
##############################################################################
Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false

# Fetch ESXi image depot
Add-EsxSoftwareDepot https://hostupdate.vmware.com/software/VUM/PRODUCTION/main/vmw-depot-index.xml

# List avilable profiles if desired (show what images are available for download)
#Get-EsxImageProfile

# Download desired image
Export-ESXImageProfile -ImageProfile "ESXi-7.0.1-16850804-standard" -ExportToBundle -filepath ESXi-7.0.1-16850804-standard.zip

# Remove the depot
Remove-EsxSoftwareDepot https://hostupdate.vmware.com/software/VUM/PRODUCTION/main/vmw-depot-index.xml

# Add default ESXi image files to installation media
Add-EsxSoftwareDepot .\ESXi-7.0.1-16850804-standard.zip


##############################################################################
# Download additional drivers (can be done via browser too, either is fine) 
##############################################################################

# Get community network driver 
Invoke-WebRequest -Uri https://download3.vmware.com/software/vmw-tools/community-network-driver/Net-Community-Driver_1.2.2.0-1vmw.700.1.0.15843807_18835109.zip -OutFile Net-Community-Driver_1.2.2.0-1vmw.700.1.0.15843807_18835109.zip

# Get USB NIC driver
Invoke-WebRequest -Uri https://download3.vmware.com/software/vmw-tools/USBNND/ESXi701-VMKUSB-NIC-FLING-40599856-component-17078334.zip -OutFile ESXi701-VMKUSB-NIC-FLING-40599856-component-17078334.zip

# Get Community NVMe Driver for ESXi
Invoke-WebRequest -Uri https://download3.vmware.com/software/vmw-tools/community-nvme-driver/nvme-community-driver_1.0.1.0-3vmw.700.1.0.15843807-component-18902434.zip -OutFile nvme-community-driver_1.0.1.0-3vmw.700.1.0.15843807-component-18902434.zip

##############################################################################
# Add the additional drivers
##############################################################################

# Add community network driver
Add-EsxSoftwareDepot .\Net-Community-Driver_1.2.2.0-1vmw.700.1.0.15843807_18835109.zip

# Add USB NIC driver
Add-EsxSoftwareDepot .\ESXi701-VMKUSB-NIC-FLING-40599856-component-17078334.zip

# Get Community NVMe Driver for ESXi
Add-EsxSoftwareDepot .\nvme-community-driver_1.0.1.0-3vmw.700.1.0.15843807-component-18902434.zip

##############################################################################
# Create new installation media profile and add the additional drivers to it
##############################################################################

# Create new, custom profile
New-EsxImageProfile -CloneProfile "ESXi-7.0.1-16850804-standard" -name "ESXi-7.0.1-16850804-standard-home" -Vendor "Tero.local"

# Add community network driver package to custom profile
Add-EsxSoftwarePackage -ImageProfile "ESXi-7.0.1-16850804-standard-home" -SoftwarePackage "net-community"

# Add USB NIC driver package to custom profile
Add-EsxSoftwarePackage -ImageProfile "ESXi-7.0.1-16850804-standard-home" -SoftwarePackage "vmkusb-nic-fling"

# Add Community NVMe Driver for ESXi
Add-EsxSoftwarePackage -ImageProfile "ESXi-7.0.1-16850804-standard-home" -SoftwarePackage "nvme-community"

##############################################################################
# Export the custom profile to ISO
##############################################################################
Export-ESXImageProfile -ImageProfile "ESXi-7.0.1-16850804-standard-home" -ExportToIso -filepath ESXi-7.0.1-16850804-standard-home.iso
